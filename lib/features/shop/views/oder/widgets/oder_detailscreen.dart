import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/btn_order.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/orderaddress.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/price_order.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/productorder.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/tileorder.dart';

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

          // Kiểm tra trạng thái đơn hàng
          String orderStatus = data['orderStatus'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TileOrder(
                  orderId: widget.orderId,
                ),
                const SizedBox(height: 16),
                OrderInfoAddRess(data: data),
                const SizedBox(height: 16),
                PriceOrder(data: data),
                const SizedBox(height: 16),
                Expanded(
                  child: ProductListOrder(
                      products:
                      List<Map<dynamic, dynamic>>.from(data['products'])),
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
                      // "Trả hàng/Hoàn tiền" button
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tính năng trả hàng/hoàn tiền đang phát triển!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Red for "Trả hàng"
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
                      // "Mua lại" button
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vin đang làm nút này'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Green for "Mua lại"
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
