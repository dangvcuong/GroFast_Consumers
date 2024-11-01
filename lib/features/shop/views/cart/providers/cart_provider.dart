import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem cartItem) {
    final existingItemIndex = _cartItems.indexWhere(
          (item) => item.productId == cartItem.productId,
    );

    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(CartItem(
        productId: cartItem.productId,
        name: cartItem.name,
        description: cartItem.description,
        imageUrl: cartItem.imageUrl,
        price: cartItem.price,
        evaluate: cartItem.evaluate,
        quantity: 1,
        idHang: cartItem.idHang,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem cartItem) {
    _cartItems.removeWhere((item) => item.productId == cartItem.productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
