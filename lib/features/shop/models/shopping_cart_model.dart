// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';

class CartItem {
  final String productId; // ID của sản phẩm
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double evaluate;
  int quantity; // Sử dụng biến int thay vì final để có thể thay đổi
  final String idHang; // ID của hãng
  bool isChecked;

  CartItem({
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.evaluate,
    this.quantity = 1, // Khởi tạo số lượng mặc định là 1
    required this.idHang,
    this.isChecked = false,
  });

  // Hàm chuyển đổi từ Map (dữ liệu Firebase) sang CartItem object
  factory CartItem.fromMap(Map<String, dynamic> map, String productId) {
    return CartItem(
      productId: productId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] is double
          ? map['price']
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      evaluate: map['evaluate'] is double
          ? map['evaluate']
          : double.tryParse(map['evaluate']?.toString() ?? '0') ?? 0.0,
      quantity: map['quantity'] is int
          ? map['quantity']
          : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      idHang: map['idHang'] ?? '',
    );
  }

  // Hàm chuyển CartItem object thành Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price.toString(),
      'evaluate': evaluate.toString(),
      'quantity': quantity.toString(),
      'idHang': idHang,
    };
  }
}
