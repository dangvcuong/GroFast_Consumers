// ignore_for_file: use_build_context_synchronously, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import '../../../models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = []; // Danh sách sản phẩm yêu thích
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  String errorMessage = "";
  final Login_Controller loginController = Login_Controller();
  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _clearFavorites(); // Xóa danh sách nếu người dùng đăng xuất
      } else {
        _fetchFavorites(); // Tải danh sách yêu thích nếu có người dùng mới
      }
    });
  }
  void _clearFavorites() {
    _favorites.clear(); // Xóa danh sách yêu thích
    notifyListeners(); // Cập nhật giao diện
  }

  // Hàm tải sản phẩm yêu thích từ Firebase
  Future<void> _fetchFavorites() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final DatabaseReference favoritesRef =
          _database.child('users/$userId/favorites');
      _setLoading(true);

      // Lắng nghe sự thay đổi dữ liệu từ Firebase theo thời gian thực
      favoritesRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        _favorites.clear();
        if (data != null) {
          data.forEach((key, value) {
            _favorites
                .add(Product.fromMap(Map<String, dynamic>.from(value), key));
          });
        }

        _setLoading(false); // Cập nhật trạng thái tải sau khi nhận dữ liệu
      }, onError: (error) {
        // ignore: avoid_print
        print("Lỗi khi tải sản phẩm yêu thích: $error");
        _setLoading(false);
      });
    } else {
      _setLoading(false);
    }
  }

  // Hàm để cập nhật trạng thái tải
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Thêm sản phẩm vào danh sách yêu thích trong Firebase

  Future<void> addProductToUserHeart(
      String userId, Product product, BuildContext context) async {
    final DatabaseReference userFavoritesRef =
        FirebaseDatabase.instance.ref('users/$userId/favorites');

    try {
      // Kiểm tra xem sản phẩm đã tồn tại trong danh sách yêu thích chưa
      final snapshot = await userFavoritesRef.child(product.id).once();
      if (snapshot.snapshot.exists) {
        errorMessage = "Sản phẩm đã có trong danh sách yêu thích!";
      } else {
        // Nếu chưa tồn tại, thêm sản phẩm vào Firebase
        Map<String, dynamic> productData = product.toMap();
        await userFavoritesRef.child(product.id).set(productData);

        errorMessage = "Sản phẩm đã được thêm vào danh sách yêu thích!";
      }
    } catch (error) {
      errorMessage = "Lỗi khi thêm sản phẩm vào yêu thích: $error";
    }

    // Hiển thị thông báo cho người dùng
    loginController.ThongBao(context, errorMessage);
  }

  // Xóa sản phẩm khỏi danh sách yêu thích trong Firebase
  Future<void> removeFavorite(Product product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await _database.child('users/$userId/favorites/${product.id}').remove();
        _favorites.removeWhere((favProduct) =>
            favProduct.id == product.id); // Xóa sản phẩm trong danh sách
        notifyListeners();
      } catch (error) {
        print("Lỗi khi xóa sản phẩm yêu thích: $error");
      }
    }
  }

  // Kiểm tra xem sản phẩm đã có trong danh sách yêu thích chưa
  bool isFavorite(Product product) {
    return _favorites.any((favProduct) => favProduct.id == product.id);
  }
}
