import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/btn_order.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/orderaddress.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/price_order.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/productorder.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/tileorder.dart';

import '../../../models/order_model.dart';
import '../../../models/shopping_cart_model.dart';
import '../../pay/pay_cart_screen.dart';

class OrderDetail extends StatefulWidget {
  final String orderId;

  const OrderDetail(this.orderId, {super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late DatabaseReference database;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref('orders/${widget.orderId}');
  }

  void _handleReorder(List<Map<dynamic, dynamic>> products) {
    // Chuyển đổi danh sách sản phẩm sang kiểu CartItem
    List<CartItem> cartItems = products.map((product) {
      return CartItem(
        productId: product['id'],
        name: product['name'],
        description: product['description'],
        imageUrl: product['imageUrl'],
        price: (product['price'] as num).toDouble(),
        quantity: product['quantity'] as int,
        evaluate: double.tryParse(product['evaluate']?.toString() ?? '0') ?? 0.0,
        idHang: product['idHang'],
      );
    }).toList();

    // Chuyển sang màn hình thanh toán
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentCartScreen(products: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chi tiết đơn hàng'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder(
        stream: database.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Không có dữ liệu.'));
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Lấy danh sách sản phẩm từ dữ liệu
          final products =
          List<Map<dynamic, dynamic>>.from(data['products'] ?? []);

          // Kiểm tra trạng thái đơn hàng
          String orderStatus = data['orderStatus'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TileOrder(orderId: widget.orderId),
                const SizedBox(height: 16),
                OrderInfoAddRess(data: data),
                const SizedBox(height: 16),
                PriceOrder(data: data),
                const SizedBox(height: 16),
                Expanded(
                  child: ProductListOrder(products: products),
                ),
                const SizedBox(height: 20),
                ButtonRow(
                  data: data,
                  orderId: widget.orderId,
                ),
                const SizedBox(height: 20),

                // Kiểm tra trạng thái đơn hàng và chỉ hiển thị các nút khi "Thành công"
                if (orderStatus == 'Thành công')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Tính năng trả hàng/hoàn tiền đang phát triển!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Trả hàng/Hoàn tiền',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _handleReorder(products),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Mua lại',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}