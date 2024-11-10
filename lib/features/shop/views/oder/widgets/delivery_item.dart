import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryItem extends StatefulWidget {
  const DeliveryItem({super.key});

  @override
  State<DeliveryItem> createState() => _Delivery();
}

class _Delivery extends State<DeliveryItem> {
  final DateTime orderDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn Hàng Đã Nhan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }
}

