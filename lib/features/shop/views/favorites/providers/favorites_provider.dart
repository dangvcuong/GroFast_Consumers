import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = []; // Danh sách sản phẩm yêu thích
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;

  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _fetchFavorites(); // Tải danh sách yêu thích khi khởi tạo provider
  }

  // Hàm tải sản phẩm yêu thích từ Firebase
  Future<void> _fetchFavorites() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final DatabaseReference favoritesRef = _database.child('users/$userId/favorites');
      _setLoading(true);

      // Lắng nghe sự thay đổi dữ liệu từ Firebase theo thời gian thực
      favoritesRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        _favorites.clear();
        if (data != null) {
          data.forEach((key, value) {
            _favorites.add(Product.fromMap(Map<String, dynamic>.from(value), key));
          });
        }

        _setLoading(false); // Cập nhật trạng thái tải sau khi nhận dữ liệu
      }, onError: (error) {
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
  Future<void> addFavorite(Product product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && !isFavorite(product)) { // Kiểm tra xem sản phẩm đã tồn tại trong danh sách chưa
      try {
        await _database.child('users/$userId/favorites/${product.id}').set(product.toMap());
        _favorites.add(product); // Thêm sản phẩm vào danh sách yêu thích
        notifyListeners();
      } catch (error) {
        print("Lỗi khi thêm sản phẩm yêu thích: $error");
      }
    }
  }

  // Xóa sản phẩm khỏi danh sách yêu thích trong Firebase
  Future<void> removeFavorite(Product product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await _database.child('users/$userId/favorites/${product.id}').remove();
        _favorites.removeWhere((favProduct) => favProduct.id == product.id); // Xóa sản phẩm trong danh sách
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
