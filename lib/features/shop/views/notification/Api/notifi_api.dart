// ignore_for_file: non_constant_identifier_names, unused_field

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotifiApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Biến lưu trữ trạng thái đăng nhập
  bool isUserLoggedIn = false;

  Future<void> initNotifications(String? userId) async {
    if (userId == null) {
      print('Người dùng chưa đăng nhập.');
      return; // Không làm gì nếu chưa có userId
    }

    // Yêu cầu quyền gửi thông báo
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Quyền thông báo đã được cấp.');

      // Lấy FCM Token
      final fCMToken = await _firebaseMessaging.getToken();
      print("FCM Token: $fCMToken");

      if (fCMToken != null) {
        // Lưu token vào Firebase Realtime Database
        DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');
        await ref.update({
          'userDeviceToken': fCMToken,
        });
        print("FCM Token saved for user $userId: $fCMToken");

        // Đăng ký lại vào topic 'allUsers' sau khi đăng nhập
        await _firebaseMessaging.subscribeToTopic('allUsers');
        print('Đã đăng ký vào topic allUsers');
        isUserLoggedIn = true; // Đánh dấu là đã đăng nhập
      } else {
        print('FCM Token là null');
      }
    } else {
      print('Người dùng từ chối quyền thông báo.');
    }
  }

  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  final DatabaseReference _chatBoxRef = FirebaseDatabase.instance.ref('chats');

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  OrderNotificationService() {
    _initializeNotifications();
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
    // Lấy userId của người dùng hiện tại

    // Lắng nghe sự thay đổi của các đơn hàng có userId khớp với userId của người dùng
    _ordersRef
        .orderByChild('userId') // Sắp xếp theo userId
        .equalTo(
            userId) // Lọc ra các đơn hàng của người dùng này (uid là chuỗi)
        .onChildChanged
        .listen((event) {
      print('Firebase event triggered: ${event.snapshot.key}');
      print('New data: ${event.snapshot.value}');

      if (event.snapshot.exists && event.snapshot.value != null) {
        try {
          // Trích xuất dữ liệu từ snapshot
          final orderData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          final orderId = event.snapshot.key;

          print(
              'Processing order for userId: $userId - Order: $orderId - Data: $orderData');
          print('Order data: $orderData');
          print('Order Status: ${orderData['orderStatus']}');

          // Kiểm tra trạng thái của đơn hàng
          String status = orderData['orderStatus'] ??
              'Unknown'; // Lấy giá trị trạng thái đơn hàng (mặc định là 'Unknown')
          print("STATUS: $status");

          // Tạo thông báo dựa trên trạng thái đơn hàng
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

          // Hiển thị thông báo cho người dùng khi trạng thái đơn hàng thay đổi
          _showNotification(
            title: notificationTitle,
            body: notificationBody,
          );

          // Lưu thông báo vào Firebase Realtime Database
          _saveNotificationToDatabase(
            userId: userId,
            title: notificationTitle,
            body: notificationBody,
          );
        } catch (e) {
          print('Error processing order data: $e');
        }
      } else {
        print('No valid data in event.');
      }
    });
  }

  void listenToChatBoxChanges(String userId) {
    final Set<String> notifiedMessages = {}; // Lưu messageId đã thông báo
    int lastProcessedTimestamp = 0; // Lưu thời gian xử lý cuối cùng

    _chatBoxRef.child(userId).child('messages').onChildAdded.listen((event) {
      print('Firebase event triggered: ${event.snapshot.key}');
      print('New data: ${event.snapshot.value}');

      if (event.snapshot.exists && event.snapshot.value != null) {
        try {
          final messageData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          String? messageId = event.snapshot.key;
          int? timestamp = messageData['createdAt'] as int?;

          // Kiểm tra điều kiện tin nhắn mới thực sự
          if (messageId != null &&
              timestamp != null &&
              timestamp > lastProcessedTimestamp &&
              !notifiedMessages.contains(messageId)) {
            if (messageData['status'] == 2 &&
                messageData['trangThai'] == "Chưa xem") {
              // Lấy nội dung tin nhắn
              String messageContent =
                  messageData['text'] ?? 'No content'; // Nội dung
              String authorId = messageData['authorId'] ?? 'Unknown';

              // Tạo thông báo
              String notificationTitle = 'Tin nhắn mới từ cửa hàng';
              String notificationBody = messageContent;

              // Hiển thị thông báo
              _showNotification(
                title: notificationTitle,
                body: notificationBody,
              );

              // Lưu thông báo vào Firebase nếu cần
              // _saveNotificationToDatabase(
              //   userId: currentUser.uid,
              //   title: notificationTitle,
              //   body: notificationBody,
              // );

              print('Notification sent for message with status = 2');

              // Cập nhật trạng thái
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
      // Lưu thông báo vào node 'notifications' của Firebase Realtime Database
      final notificationsRef =
          FirebaseDatabase.instance.ref('notifications/$userId');

      // Tạo một thông báo mới
      final newNotification = {
        'title': title,
        'body': body,
        'timestamp': ServerValue.timestamp, // Thêm timestamp
      };

      // Đẩy thông báo vào danh sách thông báo của người dùng
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
      'order_channel', // ID của kênh thông báo
      'Cập nhật đơn hàng',
      channelDescription: 'Thông báo khi đơn hàng được cập nhật',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Đảm bảo icon này tồn tại
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // ID thông báo (có thể thay đổi nếu cần quản lý nhiều thông báo)
      title,
      body,
      notificationDetails,
    );
  }
}
