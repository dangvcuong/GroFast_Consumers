// ignore_for_file: non_constant_identifier_names, unused_field

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotifiApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  final DatabaseReference _chatBoxRef = FirebaseDatabase.instance.ref('chats');
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isUserLoggedIn = false;

  // Lắng nghe các thay đổi nếu có userId
  Future<void> initNotifications(String? userId) async {
    if (userId == null || userId.isEmpty) {
      print('Không có userId. Ngừng thông báo.');
      stopListening(); // Ngừng lắng nghe khi không có userId
      return;
    }

    // Nếu có userId, tiếp tục thực hiện
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Quyền thông báo đã được cấp.');

      final fCMToken = await _firebaseMessaging.getToken();
      print("FCM Token: $fCMToken");

      if (fCMToken != null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');
        await ref.update({
          'userDeviceToken': fCMToken,
        });
        print("FCM Token saved for user $userId: $fCMToken");

        await _firebaseMessaging.subscribeToTopic('allUsers');
        print('Đã đăng ký vào topic allUsers');
        isUserLoggedIn = true;
      } else {
        print('FCM Token là null');
      }
    } else {
      print('Người dùng từ chối quyền thông báo.');
    }
  }

  // Hủy lắng nghe và ngừng nhận thông báo khi không có userId
  void stopListening() {
    if (isUserLoggedIn) {
      _firebaseMessaging.unsubscribeFromTopic('allUsers'); // Hủy đăng ký topic
      print('Đã hủy đăng ký từ topic allUsers');
      isUserLoggedIn = false;
    }

    // Dừng lắng nghe thay đổi đơn hàng và hộp chat
    _ordersRef.onChildChanged.listen((event) {}).cancel();
    _chatBoxRef.onChildAdded.listen((event) {}).cancel();
    print('Đã dừng lắng nghe sự kiện thay đổi đơn hàng và hộp chat.');
  }

  // Khởi tạo thông báo cục bộ
  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    _localNotificationsPlugin.initialize(initializationSettings);
  }

  // Lắng nghe thay đổi đơn hàng
  void listenToOrderChanges(String userId) {
    _ordersRef
        .orderByChild('userId')
        .equalTo(userId)
        .onChildChanged
        .listen((event) {
      print('Firebase event triggered: ${event.snapshot.key}');
      print('New data: ${event.snapshot.value}');

      if (event.snapshot.exists && event.snapshot.value != null) {
        try {
          final orderData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          final orderId = event.snapshot.key;
          print(
              'Processing order for userId: $userId - Order: $orderId - Data: $orderData');
          print('Order data: $orderData');
          print('Order Status: ${orderData['orderStatus']}');

          String status = orderData['orderStatus'] ?? 'Unknown';
          print("STATUS: $status");

          String notificationTitle;
          String notificationBody;

          if (status == 'Đã hủy') {
            notificationTitle = 'Đơn hàng $orderId';
            notificationBody = 'Đơn hàng của bạn đã bị hủy!';
          } else if (status == 'Đang giao hàng') {
            notificationTitle = 'Đơn hàng $orderId';
            notificationBody = 'Đơn hàng của bạn đang trên đường giao!';
          } else if (status == 'Thành công') {
            notificationTitle = 'Đơn hàng $orderId';
            notificationBody = 'Đơn hàng của bạn đã giao hàng thành công!';
          } else {
            notificationTitle = 'Cập nhật đơn hàng';
            notificationBody = 'Trạng thái đơn hàng của bạn đã thay đổi!';
          }

          _showNotification(title: notificationTitle, body: notificationBody);
          _saveNotificationToDatabase(
              userId: userId, title: notificationTitle, body: notificationBody);
        } catch (e) {
          print('Error processing order data: $e');
        }
      } else {
        print('No valid data in event.');
      }
    });
  }

  void listenToChatBoxChanges(String userId) {
    final Set<String> notifiedMessages = {};
    int lastProcessedTimestamp = 0;

    _chatBoxRef.child(userId).child('messages').onChildAdded.listen((event) {
      print('Firebase event triggered: ${event.snapshot.key}');
      print('New data: ${event.snapshot.value}');

      if (event.snapshot.exists && event.snapshot.value != null) {
        try {
          final messageData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          String? messageId = event.snapshot.key;
          int? timestamp = messageData['createdAt'] as int?;

          if (messageId != null &&
              timestamp != null &&
              timestamp > lastProcessedTimestamp &&
              !notifiedMessages.contains(messageId)) {
            if (messageData['status'] == 2 &&
                messageData['trangThai'] == "Chưa xem") {
              String messageContent = messageData['text'] ?? 'No content';
              String authorId = messageData['authorId'] ?? 'Unknown';

              String notificationTitle = 'Tin nhắn mới từ cửa hàng';
              String notificationBody = messageContent;

              _showNotification(
                  title: notificationTitle, body: notificationBody);
              notifiedMessages.add(messageId);
              lastProcessedTimestamp = timestamp;
            } else {
              print('Message status is not 2');
            }
          } else {
            print('Message already notified, not the latest, or no timestamp.');
          }
        } catch (e) {
          print('Error processing message data: $e');
        }
      } else {
        print('No valid data in event.');
      }
    });
  }

  // Hàm lưu thông báo vào Firebase Realtime Database
  Future<void> _saveNotificationToDatabase({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final notificationsRef =
          FirebaseDatabase.instance.ref('notifications/$userId');
      final newNotification = {
        'title': title,
        'body': body,
        'timestamp': ServerValue.timestamp,
      };

      await notificationsRef.push().set(newNotification);
      print('Notification saved to Firebase Realtime Database');
    } catch (e) {
      print('Error saving notification to database: $e');
    }
  }

  // Hiển thị thông báo cục bộ
  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_channel',
      'Cập nhật đơn hàng',
      channelDescription: 'Thông báo khi đơn hàng được cập nhật',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
