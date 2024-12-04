import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/oder_detailscreen.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String _currentStatus = 'Đang chờ xác nhận'; // Trạng thái mặc định
  String? _selectedStatus; // Biến lưu trạng thái được chọn
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _selectedStatus = _currentStatus; // Mặc định là "Đang chờ xác nhận"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Cuộn ngang
              child: Row(
                children: [
                  buildStatusIcon(
                    context,
                    icon: Icons.pending_actions,
                    label: "Đang chờ xác nhận",
                    status: 'Đang chờ xác nhận',
                  ),
                  SizedBox(width: 20), // Khoảng cách giữa các tab
                  buildStatusIcon(
                    context,
                    icon: Icons.local_shipping,
                    label: "Đang giao hàng",
                    status: 'Đang giao hàng',
                  ),
                  SizedBox(width: 20),
                  buildStatusIcon(
                    context,
                    icon: Icons.check_circle_outline,
                    label: "Đã nhận hàng",
                    status: 'Thành công',
                  ),
                  SizedBox(width: 20),
                  buildStatusIcon(
                    context,
                    icon: Icons.history,
                    label: "Lịch sử",
                    status: 'Lịch sử', // Tab Lịch sử
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _ordersRef
                  .orderByChild('userId')
                  .equalTo(_currentUserId)
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Đã xảy ra lỗi!'));
                }

                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text('Không có đơn hàng.'));
                }

                final Map<dynamic, dynamic> ordersMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                // Lọc đơn hàng theo trạng thái: Thành công hoặc Đã hủy khi chọn "Lịch sử"
                final List<Map<String, dynamic>> orders = ordersMap.entries
                    .map((entry) => {
                  'id': entry.key.toString(),
                  ...(entry.value as Map<dynamic, dynamic>).map(
                        (key, value) => MapEntry(key.toString(), value),
                  ),
                })
                    .where((order) {
                  if (_currentStatus == 'Lịch sử') {
                    return order['orderStatus'] == 'Thành công' ||
                        order['orderStatus'] == 'Đã hủy';
                  }
                  return order['orderStatus'] == _currentStatus; // Hiển thị theo trạng thái đã chọn
                }).toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                        'Không có đơn hàng trạng thái "$_currentStatus".'),
                  );
                }
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    double totalAmount = 0;
                    if (order['totalAmount'] is String) {
                      totalAmount = double.tryParse(order['totalAmount']) ?? 0;
                    } else if (order['totalAmount'] is num) {
                      totalAmount = order['totalAmount'].toDouble();
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white, // Màu nền trắng cho card
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white54, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            final orderId = order['id']?.toString();
                            if (orderId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetail(orderId),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Lỗi: Không có ID đơn hàng')));
                            }
                          },
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '#${order['id']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Số lượng: ${order['products']?.length ?? 0} sản phẩm",
                                    style: const TextStyle(color: Colors.black)),
                                const SizedBox(height: 5),
                                Text(
                                  formatter.format(totalAmount),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                if (order['orderStatus'] == 'Thành công')
                                  const Text(
                                    'Hoàn thành',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (order['orderStatus'] == 'Đã hủy')
                                  const Text(
                                    'Đã hủy',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusIcon(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String status,
      }) {
    // Kiểm tra nếu biểu tượng này được chọn
    bool isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentStatus = status; // Cập nhật trạng thái đơn hàng
          _selectedStatus =
              status; // Cập nhật trạng thái của biểu tượng được chọn
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? Colors.blue
                : Colors.grey, // Thay đổi màu khi được chọn
          ),
          Text(
            label,
            style: TextStyle(
                color: isSelected
                    ? Colors.blue
                    : Colors.black), // Màu văn bản thay đổi khi được chọn
          ),
        ],
      ),
    );
  }
}
