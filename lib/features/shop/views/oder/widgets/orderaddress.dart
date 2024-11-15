// ignore_for_file: file_names

import 'package:flutter/material.dart';

class OrderInfoAddRess extends StatelessWidget {
  final Map<dynamic, dynamic> data;

  const OrderInfoAddRess({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final shippingAddress = data['shippingAddress'] as Map<dynamic, dynamic>;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Địa chỉ khách hàng:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(shippingAddress['nameAddresUser'] ?? 'N/A'),
          Text(shippingAddress['phoneAddresUser'] ?? 'N/A'),
          Text(shippingAddress['addressUser'] ?? 'N/A'),
        ],
      ),
    );
  }
}
