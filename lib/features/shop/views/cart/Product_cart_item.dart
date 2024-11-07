// ignore_for_file: unused_local_variable, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, depend_on_referenced_packages, non_constant_identifier_names, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/cart/providers/cart_provider.dart';
import 'package:grofast_consumers/features/shop/views/pay/pay_cart_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Adjust to your actual CartProvider file path
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isInitialized =
      false; // Flag to check if fetchCartItems has been called
  final Login_Controller login_controller = Login_Controller();
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Provider.of<CartProvider>(context, listen: false).fetchCartItems(userId);
      _isInitialized = true; // Ensure fetchCartItems is only called once
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Giỏ Hàng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Tính toán tổng giá tiền cho các sản phẩm đã chọn
          double totalPrice = cartProvider.cartItems
              .where((item) => item.isChecked) // Lọc các sản phẩm đã được chọn
              .fold(
                  0,
                  (total, item) =>
                      total + (item.price * item.quantity)); // Tính tổng giá

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return _buildCartItem(cartItem, cartProvider);
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        // Hiển thị tổng giá tiền đã tính toán
                        Text(formatter.format(totalPrice),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.red)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Lọc các sản phẩm đã được chọn
                            final selectedProducts = cartProvider.cartItems
                                .where((item) => item.isChecked)
                                .toList();

                            if (selectedProducts.isEmpty) {
                              // Nếu không có sản phẩm nào được chọn, hiển thị cảnh báo

                              login_controller.ThongBao(context,
                                  'Vui lòng chọn ít nhất một sản phẩm để thanh toán.');
                              return;
                            }

                            // Tính toán tổng giá cho các sản phẩm đã chọn
                            double totalPrice = selectedProducts.fold(
                              0,
                              (total, item) =>
                                  total + (item.price * item.quantity),
                            );

                            // Điều hướng đến PaymentCartScreen với danh sách sản phẩm và tổng giá
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentCartScreen(
                                  products: selectedProducts,
                                ),
                              ),
                            ).then((_) {
                              String userId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              Provider.of<CartProvider>(context, listen: false)
                                  .fetchCartItems(userId);
                              _isInitialized =
                                  true; // Ensure fetchCartItems is only called once
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text(
                            'Mua Hàng',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                checkColor: Colors.white, // Màu của dấu tích khi được chọn
                activeColor: Colors.blue, // Màu nền của checkbox khi được chọn
                value: cartItem.isChecked, // Trạng thái checkbox
                onChanged: (bool? value) {
                  cartItem.isChecked = value ?? false; // Cập nhật trạng thái
                  cartProvider.notifyListeners(); // Thông báo cho UI cập nhật
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                              cartItem.imageUrl), // Sử dụng NetworkImage
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1, // Giới hạn hiển thị chỉ 1 dòng
                            overflow: TextOverflow
                                .ellipsis, // Hiển thị dấu "..." nếu nội dung vượt qu
                          ),
                          Text(
                            formatter.format(cartItem.price),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  cartItem.quantity--;
                                  cartProvider.updateQuantity(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      cartItem); // Update in Firebase
                                } else {
                                  cartProvider.removeItem(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      cartItem
                                          .productId); // Remove item if quantity is 1
                                }
                              },
                            ),
                            Text(
                              cartItem.quantity.toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () {
                                cartItem.quantity++;
                                cartProvider.updateQuantity(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    cartItem); // Update in Firebase
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            cartProvider.removeItem(
                                FirebaseAuth.instance.currentUser!.uid,
                                cartItem.productId);
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
