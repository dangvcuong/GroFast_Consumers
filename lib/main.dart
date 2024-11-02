import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grofast_consumers/features/Navigation/btn_navigation.dart';
import 'package:provider/provider.dart'; // Đảm bảo bạn có dòng này cho MultiProvider
import 'features/authentication/login/widgets/man_chao.dart';
import 'features/shop/views/cart/providers/cart_provider.dart';
import 'features/shop/views/favorites/providers/favorites_provider.dart';
import 'features/shop/views/home/home_screen.dart'; // Thêm HomeScreen vào import
import 'features/shop/providers/cart_provider.dart'; // Đảm bảo chỉ có một đường dẫn đúng cho CartProvider


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // Cung cấp FavoritesProvider
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
              return const Btn_Navigatin(); // Sử dụng HomeScreen làm trang chính khi đăng nhập
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