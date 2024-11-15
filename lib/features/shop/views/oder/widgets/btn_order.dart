import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:intl/intl.dart';

class ButtonRow extends StatelessWidget {
  final Map<dynamic, dynamic> data;
  final String orderId;
  const ButtonRow({super.key, required this.data, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    final Login_Controller loginController = Login_Controller();
    Future<void> deleteOrder(String orderId) async {
      try {
        // Đường dẫn tới đơn hàng cụ thể
        final orderRef = dbRef.child('orders/$orderId');

        // Xóa đơn hàng khỏi database
        await orderRef.remove();

        print('Đơn hàng với ID $orderId đã bị xóa!');
      } catch (e) {
        print('Lỗi khi xóa đơn hàng: $e');
      }
    }

    // Hàm hiển thị Dialog xác nhận
    void showDeleteConfirmationDialog(BuildContext context, String orderId) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tiêu đề
                const Text(
                  'Xác nhận hủy đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Nội dung
                const Text(
                  'Bạn có chắc chắn muốn hủy đơn hàng này?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Các nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nút Hủy
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Màu nút Hủy
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nút Xác nhận
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Gọi hàm xóa đơn hàng nếu người dùng xác nhận
                          deleteOrder(orderId);
                          Navigator.of(context).pop(); // Đóng dialog
                          loginController.ThongBao(
                              context, 'Đơn hàng của bạn đã được hủy.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Màu nút Xác nhận
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    // Xử lý tính tổng số lượng
    final List<Map<dynamic, dynamic>> products =
        List<Map<dynamic, dynamic>>.from(data['products'] ?? []);
    final int soluong = products.fold<int>(
        0,
        (sum, product) =>
            sum + (int.tryParse(product['quantity'].toString()) ?? 0));

    // Xử lý `totalAmount`
    double totalAmount = 0;
    if (data['totalAmount'] is String) {
      totalAmount = double.tryParse(data['totalAmount']) ?? 0;
    } else if (data['totalAmount'] is num) {
      totalAmount = data['totalAmount'].toDouble();
    }

    // Lấy trạng thái đơn hàng
    String orderStatus = data['orderStatus'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hiển thị số lượng
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Số lượng: $soluong',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                Row(
                  children: [
                    const Text(
                      'Thành tiền: ',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      formatter.format(totalAmount),
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ],
            )),
        const SizedBox(height: 8),

        // Các nút "Từ chối" và "Xác nhận"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kiểm tra nếu trạng thái đơn hàng không phải "Đang giao hàng" thì mới hiển thị nút "Hủy đơn hàng"
            if (orderStatus != 'Đang giao hàng') ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDeleteConfirmationDialog(context, orderId);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Hủy đơn hàng',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            // Nút Xác nhận có thể thêm vào nếu cần
          ],
        ),
      ],
    );
  }
}
