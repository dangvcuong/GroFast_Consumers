import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Đảm bảo bạn có dòng này cho MultiProvider
import 'package:grofast_consumers/features/authentication/login/widgets/man_chao.dart';
import 'package:grofast_consumers/features/Navigation/btn_navigation.dart';
import 'package:grofast_consumers/features/shop/providers/cart_provider.dart'; // Thêm import cho CartProvider
import 'features/shop/views/cart/providers/cart_provider.dart';
import 'features/shop/views/favorites/providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // Cung cấp FavoritesProvider
         // Cung cấp CartProvider
      ],
      child: const MyApp(),
    ),
  );
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
      theme: ThemeData(
        primarySwatch: Colors.blue, // Ví dụ về theme
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const Btn_Navigatin(); // Người dùng đã đăng nhập
            } else {
              return const ManChao(); // Người dùng chưa đăng nhập
            }
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}")); // Xử lý lỗi
          } else {
            return const Center(child: CircularProgressIndicator()); // Đang tải
          }
        },
      ),
    );
  }
}
