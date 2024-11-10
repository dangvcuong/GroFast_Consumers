import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/delivery_item.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/identify_item.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/received_item.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final DateTime orderDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReceivedItem()));
                  },
                  child: Column(
                    children: [
                      Icon(Icons.pending_actions, color: Colors.grey),
                      Text("Đang chờ xác nhận"),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const IdentifyItem()));
                  },
                  child: Column(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.grey),
                      Text("Đang giao hàng"),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DeliveryItem()));
                  },
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.grey),
                      Text("Đã nhận hàng"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Phần danh sách đơn hàng
          Expanded(
            child: ListView.builder(
              itemCount: 1, // Số lượng đơn hàng
              itemBuilder: (context, index) {
                // Định dạng giờ và ngày
                String formattedTime = DateFormat('HH:mm').format(orderDate);
                String formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white54, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Đưa ID vào bên trái
                          Expanded(
                            child: Text(
                              '#4c348350-a168-1...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 18), // Khoảng cách giữa ID và giờ
                          Text(
                            formattedTime,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          Text("Số lượng: 2 sản phẩm"),
                          SizedBox(height: 5),
                          Text(
                            "Giá: 168.000đ",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Xem chi tiết"),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
