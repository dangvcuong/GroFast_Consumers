import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:grofast_consumers/features/shop/views/home/home_screen.dart';

class NotificationService{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert:  true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('user granter permission');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('user provisional granter permision');
    }
    else{
      Get.snackbar(
        'Notification permission denied',
          "Please allow notifications to recevice update.",
        snackPosition: SnackPosition.BOTTOM
      );
// Future.delayed(Duration(seconds: 3),  (){
//   AppSettings.openAppSettings(type: AppSettingsType.notification);
// });
//
    }
  }



//get token
// Future<String> getDeviceToken() async {
//     NotificationSettings settings = await messaging.requestPermission(
// alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     String? token = await messaging.getToken();
//     print("token => $token");
//     return token!;
//  }


 //init
void initLocalNotification(BuildContext context, RemoteMessage message) async{
    var androidInitSetting =
    const AndroidInitializationSettings("@mimap/ic_laucher");
    var isoInitSetting = const DarwinInitializationSettings();
    var initialaizationSetting = InitializationSettings(
      android: androidInitSetting,
      iOS: isoInitSetting,
    );

    await _flutterLocalNotificationsPlugin.initialize(
        initialaizationSetting,
        onDidReceiveNotificationResponse: (payload) {},
    );
}
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }
//iso
      if (Platform.isIOS) {
        isoForgroundMessage();
      }

//android
    if(Platform.isAndroid){
      initLocalNotification(context, message);
// handleMessage(context, message);
    showNotification(message);
    }
    },
    );
  }
  
  //function to show notification
  Future<void> showNotification(RemoteMessage message) async{
    AndroidNotificationChannel channel = AndroidNotificationChannel(message.notification!.android!.channelId.toString(), message.notification!.android!.channelId.toString(),
   importance: Importance.high,
      showBadge: true,
      playSound: true,

    );

    //androi setting
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.name.toString(),
      channelDescription: "Channel Description",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: channel.sound,
      icon: 'ic_notification',
    );

    //iso setting
    DarwinNotificationDetails darwinNotificationDetails =
       const DarwinNotificationDetails(
         presentAlert: true,
         presentBadge: true,
         presentSound: true,
       );

    //marget setting
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    //show notification
    Future.delayed(Duration.zero,()
    {
      _flutterLocalNotificationsPlugin.show(
      0, message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails,payload: "my_data"
      );
    });
  }
  
  
  
//background and terminated
  Future<void> setupInteractMessage(BuildContext context) async{
    
    
    //background state
    FirebaseMessaging.onMessageOpenedApp.listen(
            (event) {},
      
    );
    //terniated state
    FirebaseMessaging.instance.getInitialMessage().then(
            (RemoteMessage? message){
              if(message != null && message.data.isNotEmpty){
                handleMessage(context, message);
              }
            },
    );
  }

  //handle mess
  Future<void> handleMessage(
      BuildContext context,
      RemoteMessage message,
      ) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),
      ),
    );

  }
  
  //iso mess
  Future isoForgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

}