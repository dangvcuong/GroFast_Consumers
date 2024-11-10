import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceivedItem extends StatefulWidget {
  const ReceivedItem({super.key});

  @override
  State<ReceivedItem> createState() => _Received();
}

class _Received extends State<ReceivedItem> {
  final DateTime orderDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn Hàng Xác Nhận'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }
}