// ignore_for_file: unused_import, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grofast_consumers/features/authentication/login/widgets/man_chao.dart';
import 'package:grofast_consumers/features/Navigation/btn_navigation.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const Btn_Navigatin(); // Nếu người dùng đã đăng nhập
            } else {
              return const ManChao(); // Nếu người dùng chưa đăng nhập
            }
          } else {
            return const Center(child: CircularProgressIndicator()); // Đợi tải
          }
        },
      ),
    );
  }
}
