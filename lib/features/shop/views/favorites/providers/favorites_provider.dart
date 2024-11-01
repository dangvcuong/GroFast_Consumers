import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;

  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _fetchFavorites(); // Tải danh sách yêu thích khi khởi tạo provider
  }

  // Hàm để tải sản phẩm yêu thích từ Firebase
  Future<void> _fetchFavorites() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final DatabaseReference favoritesRef = _database.child('users/$userId/favorites');
      _isLoading = true;
      notifyListeners();

      favoritesRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          _favorites.clear();
          data.forEach((key, value) {
            _favorites.add(Product.fromMap(Map<String, dynamic>.from(value), key));
          });
        } else {
          _favorites.clear();
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        print("Lỗi khi tải sản phẩm yêu thích: $error");
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm sản phẩm vào danh sách yêu thích trong Firebase
  Future<void> addFavorite(Product product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await _database.child('users/$userId/favorites/${product.id}').set(product.toMap());
        _favorites.add(product);
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
        _favorites.removeWhere((favProduct) => favProduct.id == product.id);
        notifyListeners();
      } catch (error) {
        print("Lỗi khi xóa sản phẩm yêu thích: $error");
      }
    }
  }

  // Kiểm tra sản phẩm có trong danh sách yêu thích không
  bool isFavorite(Product product) {
    return _favorites.any((favProduct) => favProduct.id == product.id);
  }
}
