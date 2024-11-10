import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IdentifyItem extends StatefulWidget {
  const IdentifyItem({super.key});

  @override
  State<IdentifyItem> createState() => _Identify();
}

class _Identify extends State<IdentifyItem> {
  final DateTime orderDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn Hàng Dang Giao'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }
}

