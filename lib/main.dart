import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grofast_consumers/features/Navigation/btn_navigation.dart';
import 'package:provider/provider.dart'; // Đảm bảo bạn có dòng này cho MultiProvider
import 'features/authentication/login/widgets/man_chao.dart';
import 'features/shop/views/cart/providers/cart_provider.dart';
import 'features/shop/views/favorites/providers/favorites_provider.dart';
import 'features/shop/views/home/home_screen.dart'; // Thêm HomeScreen vào import
import 'features/shop/views/notification/Api/notifi_api.dart'; // Đảm bảo chỉ có một đường dẫn đúng cho CartProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
            create: (_) => FavoritesProvider()), // Cung cấp FavoritesProvider
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
  String? userId;
  @override
  void initState() {
    super.initState();
    final NotifiApi notifiApi;
    _requestLocationPermission();
    notifiApi = NotifiApi();
    notifiApi.listenToOrderChanges();
    notifiApi.listenToChatBoxChanges();
    // notifiApi.initNotifications(userId ?? '');
  }

  void _checkUserStatus() {
    setState(() {
      userId =
          FirebaseAuth.instance.currentUser?.uid; // Lấy userId nếu đăng nhập
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission == await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permisson are denied');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // Người dùng đã đăng nhập
              return const Btn_Navigatin();
            } else {
              // Người dùng chưa đăng nhập
              return const ManChao();
            }
          } else if (snapshot.hasError) {
            // Xử lý lỗi nếu có
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else {
            // Trạng thái đang tải
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
