import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/orderaddress.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/price_order.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/productorder.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/tileorder.dart';
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
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có sản phẩm nào trong đơn hàng!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      List<CartItem> cartItems = products.map((product) {
        return CartItem(
          productId: product['id'],
          name: product['name'],
          description: product['description'] ?? '',
          imageUrl: product['imageUrl'] ?? '',
          price: (product['price'] as num?)?.toDouble() ?? 0.0,
          quantity: product['quantity'] as int? ?? 1,
          evaluate:
              double.tryParse(product['evaluate']?.toString() ?? '0') ?? 0.0,
          idHang: product['idHang'] ?? '',
        );
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCartScreen(products: cartItems),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
          final products =
              List<Map<dynamic, dynamic>>.from(data['products'] ?? []);
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
                                  content: Text(
                                      'Tính năng trả hàng/hoàn tiền đang phát triển!'),
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
