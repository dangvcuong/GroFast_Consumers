// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart'; // Adjust file path as necessary

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void selectAllItems() {
    for (var item in cartItems) {
      item.isChecked = true;
    }
    notifyListeners();
  }

  // Hàm bỏ chọn tất cả sản phẩm
  void deselectAllItems() {
    for (var item in cartItems) {
      item.isChecked = false;
    }
    notifyListeners();
  }

  // Method to fetch cart items from Firebase
  Future<void> fetchCartItems(String userId) async {
    try {
      final DatabaseReference cartRef =
          FirebaseDatabase.instance.ref('users/$userId/carts');
      final DatabaseEvent event = await cartRef.once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value
            as Map<dynamic, dynamic>; // Use Map<dynamic, dynamic> here
        _cartItems = data.entries.map((entry) {
          // Convert each entry to Map<String, dynamic> for CartItem.fromMap
          final itemMap = Map<String, dynamic>.from(entry.value as Map);
          return CartItem.fromMap(itemMap, entry.key);
        }).toList();
        print("DanhsachCart: $_cartItems");
      } else {
        _cartItems = []; // Initialize as empty list if no data exists
      }

      notifyListeners(); // Notify the UI to update
    } catch (error) {
      print('Error fetching cart items: $error');
    }
  }

  Future<void> updateQuantity(String userId, CartItem cartItem) async {
    try {
      final DatabaseReference itemRef = FirebaseDatabase.instance.ref(
          'users/$userId/carts/${cartItem.productId}'); // Corrected reference
      await itemRef.update({
        'quantity': cartItem.quantity,
      });
      // Update local cart items as well
      final index =
          _cartItems.indexWhere((item) => item.productId == cartItem.productId);
      if (index != -1) {
        _cartItems[index] = cartItem; // Update the local cart item
        notifyListeners(); // Notify listeners after local update
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  // Optional method to remove an item from the cart
  Future<void> clearCart(String userId) async {
    try {
      // Tham chiếu đến giỏ hàng của người dùng trong Firebase
      final DatabaseReference cartRef =
          FirebaseDatabase.instance.ref('users/$userId/carts');

      // Xóa toàn bộ giỏ hàng từ Firebase
      await cartRef.remove();

      // Xóa toàn bộ giỏ hàng cục bộ trong ứng dụng
      _cartItems.clear();

      // Thông báo cho UI để cập nhật
      notifyListeners();
    } catch (error) {
      print('Lỗi khi xóa giỏ hàng: $error');
    }
  }

  Future<void> removeItem(String userId, String productId) async {
    try {
      final DatabaseReference itemRef =
          FirebaseDatabase.instance.ref('users/$userId/carts/$productId');

      // Xóa sản phẩm từ Firebase Realtime Database
      await itemRef.remove();

      // Xóa sản phẩm từ danh sách cục bộ
      _cartItems.removeWhere((item) => item.productId == productId);

      // Cập nhật giao diện
      notifyListeners();
      print('Đã xóa sản phẩm có ID: $productId');
    } catch (error) {
      print('Lỗi khi xóa sản phẩm: $error');
    }
  }
}
