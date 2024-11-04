import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart'; // Adjust file path as necessary

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

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
        print("DánhachCart: $_cartItems");
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
  void removeItem(CartItem cartItem) {
    _cartItems.remove(cartItem);
    notifyListeners();
  }
}
