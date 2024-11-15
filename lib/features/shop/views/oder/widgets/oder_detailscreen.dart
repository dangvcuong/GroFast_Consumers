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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                const SizedBox(height: 16),
                ButtonRow(
                  data: data,
                  orderId: widget.orderId,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
