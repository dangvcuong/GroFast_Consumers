// ignore_for_file: unused_local_variable, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, depend_on_referenced_packages, non_constant_identifier_names, file_names, use_build_context_synchronously

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
  bool isEditing = false;
  bool isSelectAll = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Provider.of<CartProvider>(context, listen: false).fetchCartItems(userId);
      _isInitialized = true; // Ensure fetchCartItems is only called once
    }
  }

  // Biến để kiểm tra trạng thái của checkbox "Chọn tất cả"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Giỏ hàng của tôi',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? 'Xong' : 'Sửa',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          double totalPrice = cartProvider.cartItems
              .where((item) => item.isChecked)
              .fold(0, (total, item) => total + (item.price * item.quantity));

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
                padding: const EdgeInsets.all(5),
                child: isEditing
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Checkbox "Chọn tất cả"
                                Checkbox(
                                  value: isSelectAll,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isSelectAll = value ?? false;
                                      if (isSelectAll) {
                                        cartProvider.selectAllItems();
                                      } else {
                                        cartProvider.deselectAllItems();
                                      }
                                    });
                                  },
                                ),
                                const Text(
                                  'Tất cả',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            OutlinedButton(
                              onPressed: () {
                                final selectedItems = cartProvider.cartItems
                                    .where((item) => item.isChecked)
                                    .toList();

                                if (selectedItems.isEmpty) {
                                  // Hiển thị cảnh báo nếu không có sản phẩm nào được chọn
                                  return;
                                }

                                for (var item in selectedItems) {
                                  cartProvider.removeItem(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      item.productId);
                                }

                                setState(() {
                                  isEditing = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color:
                                        Colors.grey), // Đặt màu viền của button
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Để nút có hình vuông
                                ),
                              ),
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng cộng:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                formatter.format(totalPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () {
                                  final selectedProducts = cartProvider
                                      .cartItems
                                      .where((item) => item.isChecked)
                                      .toList();

                                  if (selectedProducts.isEmpty) {
                                    // Hiển thị cảnh báo nếu không có sản phẩm nào được chọn
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentCartScreen(
                                          products: selectedProducts),
                                    ),
                                  ).then((_) {
                                    String userId =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    Provider.of<CartProvider>(context,
                                            listen: false)
                                        .fetchCartItems(userId);
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors
                                          .blue), // Đặt màu viền của button
                                  textStyle: const TextStyle(fontSize: 16),
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Để nút có hình vuông
                                  ),
                                ),
                                child: const Text(
                                  'Mua Hàng',
                                  style: TextStyle(color: Colors.white),
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
                value: cartItem.isChecked,
                onChanged: (bool? value) {
                  cartItem.isChecked = value ?? false;
                  cartProvider.notifyListeners();
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
                          image: NetworkImage(cartItem.imageUrl),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatter.format(cartItem.price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          // Dấu cộng và trừ số lượng ở góc dưới
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.blue),
                                  onPressed: () {
                                    if (cartItem.quantity > 1) {
                                      cartItem.quantity--;
                                      cartProvider.updateQuantity(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        cartItem,
                                      );
                                    } else {
                                      cartProvider.removeItem(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        cartItem.productId,
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  cartItem.quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.add, color: Colors.blue),
                                  onPressed: () {
                                    cartItem.quantity++;
                                    cartProvider.updateQuantity(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      cartItem,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
 // GestureDetector(
                        //   onTap: () {
                        //     cartProvider.removeItem(
                        //         FirebaseAuth.instance.currentUser!.uid,
                        //         cartItem.productId);
                        //   },
                        //   child: const Row(
                        //     children: [
                        //       Icon(Icons.delete, size: 16),
                        //       SizedBox(width: 4),
                        //       Text('Xóa', style: TextStyle(color: Colors.red)),
                        //     ],
                        //   ),
                        // )



              //           Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       const Text('Tổng cộng:',
              //           style: TextStyle(
              //               fontSize: 18, fontWeight: FontWeight.bold)),
              //       Row(
              //         children: [
              //           // Hiển thị tổng giá tiền đã tính toán
              //           Text(formatter.format(totalPrice),
              //               style: const TextStyle(
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: 18,
              //                   color: Colors.red)),
              //           const SizedBox(width: 10),
              //           ElevatedButton(
              //             onPressed: () {
              //               // Lọc các sản phẩm đã được chọn
              //               final selectedProducts = cartProvider.cartItems
              //                   .where((item) => item.isChecked)
              //                   .toList();

              //               if (selectedProducts.isEmpty) {
              //                 // Nếu không có sản phẩm nào được chọn, hiển thị cảnh báo

              //                 login_controller.ThongBao(context,
              //                     'Vui lòng chọn ít nhất một sản phẩm để thanh toán.');
              //                 return;
              //               }

              //               // Tính toán tổng giá cho các sản phẩm đã chọn
              //               double totalPrice = selectedProducts.fold(
              //                 0,
              //                 (total, item) =>
              //                     total + (item.price * item.quantity),
              //               );

              //               // Điều hướng đến PaymentCartScreen với danh sách sản phẩm và tổng giá

              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => PaymentCartScreen(
              //                       products: selectedProducts),
              //                 ),
              //               ).then((_) {
              //                 String userId =
              //                     FirebaseAuth.instance.currentUser!.uid;
              //                 Provider.of<CartProvider>(context, listen: false)
              //                     .fetchCartItems(userId);
              //                 _isInitialized =
              //                     true; // Ensure fetchCartItems is only called once
              //               });
              //             },
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: Colors.blue,
              //               padding: const EdgeInsets.symmetric(
              //                   horizontal: 20, vertical: 10),
              //               textStyle: const TextStyle(fontSize: 16),
              //             ),
              //             child: const Text('Mua Hàng'),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),