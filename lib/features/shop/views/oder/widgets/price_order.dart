// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceOrder extends StatelessWidget {
  final Map<dynamic, dynamic> data;

  const PriceOrder({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final shippingAddress = data['shippingAddress'] as Map<dynamic, dynamic>;
    // Parse thời gian từ Firebase (nếu là timestamp)
    final timestamp = data['orderDate']; // Giá trị gốc từ Firebase
    DateTime orderDate;

    // Xử lý nếu là int (Unix timestamp)
    if (timestamp is int) {
      orderDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      // Xử lý nếu là String (ISO 8601 format)
      orderDate = DateTime.parse(timestamp);
    } else {
      orderDate = DateTime.now(); // Mặc định nếu lỗi
    }

    // Format thời gian theo ý muốn
    String displayDate = DateFormat('dd/MM/yyyy HH:mm').format(orderDate);

    double totalAmount = 0;
    if (data['totalAmount'] is String) {
      totalAmount = double.tryParse(data['totalAmount']) ?? 0;
    } else if (data['totalAmount'] is num) {
      totalAmount = data['totalAmount'].toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thời gian', style: TextStyle(color: Colors.grey)),
              Text(
                displayDate,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trạng thái đơn hàng',
                  style: TextStyle(color: Colors.grey)),
              Text(
                data['orderStatus'],
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng thu', style: TextStyle(color: Colors.grey)),
              Text(
                formatter.format(totalAmount),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//