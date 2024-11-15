import 'package:flutter/material.dart';

class TileOrder extends StatelessWidget {
  final String orderId;
  const TileOrder({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Đảm bảo chiếm hết chiều rộng của màn hình
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Canh lề trái
        children: [
          Text(
            'Đơn hàng: #$orderId',
            style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4), // Khoảng cách nhỏ giữa các dòng
          const Text(
            'Dưới đây là chi tiết đơn hàng này',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
