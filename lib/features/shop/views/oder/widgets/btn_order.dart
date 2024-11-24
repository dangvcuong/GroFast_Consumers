import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:intl/intl.dart';

class ButtonRow extends StatefulWidget {
  final Map<dynamic, dynamic> data;
  final String orderId;

  const ButtonRow({super.key, required this.data, required this.orderId});

  @override
  _ButtonRowState createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("orders");
  final Login_Controller loginController = Login_Controller();
  final User? user = FirebaseAuth.instance.currentUser;
  String? tong;
  String? tien;

  @override
  void initState() {
    super.initState();
    fetchTotalAmount(
        widget.orderId); // Tải dữ liệu ngay khi widget được khởi tạo
    fetchTotal(widget.orderId);
  }

  Future<void> fetchTotalAmount(String orderId) async {
    try {
      final snapshot = await databaseRef.child(orderId).child("tong").get();
      if (snapshot.exists) {
        setState(() {
          tong = snapshot.value.toString(); // Gán dữ liệu vào biến `tong`
          print("Tong $tong");
        });
      } else {
        setState(() {
          tong = "Không tìm thấy đơn hàng!";
        });
      }
    } catch (e) {
      setState(() {
        tong = "Lỗi khi tải dữ liệu!";
      });
    }
  }

  Future<void> fetchTotal(String orderId) async {
    try {
      final snapshot =
          await databaseRef.child(orderId).child("totalAmount").get();
      if (snapshot.exists) {
        setState(() {
          tien = snapshot.value.toString(); // Gán dữ liệu vào biến `tong`
          print("Tien $tien");
        });
      } else {
        setState(() {
          tien = "Không tìm thấy đơn hàng!";
        });
      }
    } catch (e) {
      setState(() {
        tien = "Lỗi khi tải dữ liệu!";
      });
    }
  }

  Future<void> deleteOrderAndUpdateWallet(
      String orderId, String userId, double orderTotal) async {
    try {
      // Tham chiếu đến ví tiền của người dùng
      final userWalletRef =
          FirebaseDatabase.instance.ref().child('users/$userId/balance');

      // Lấy số dư ví hiện tại
      final walletSnapshot = await userWalletRef.get();
      if (!walletSnapshot.exists) {
        throw Exception("Ví tiền của người dùng không tồn tại.");
      }

      final double currentWallet =
          double.tryParse(walletSnapshot.value.toString()) ?? 0;

      final double orderTien = double.tryParse(tien ?? '0') ?? 0;
      // Cập nhật số dư ví
      if (orderTien == 0) {
        final double updatedWallet = currentWallet + orderTotal;
        await userWalletRef.set(updatedWallet);
      } else {
        final double updatedWallet = currentWallet + 0;
        await userWalletRef.set(updatedWallet);
      }

      // Xóa đơn hàng
      final orderRef = FirebaseDatabase.instance.ref().child('orders/$orderId');
      await orderRef.remove();

      print(
          'Đơn hàng với ID $orderId đã bị xóa và ví tiền của người dùng được cập nhật!');
    } catch (e) {
      print('Lỗi khi xóa đơn hàng hoặc cập nhật ví: $e');
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const Text(
                'Bạn có chắc chắn muốn hủy đơn hàng này?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (user?.uid != null) {
                          // Chuyển đổi 'tong' thành kiểu double, nếu không có giá trị thì đặt mặc định là 0
                          final double orderTotal =
                              double.tryParse(tong ?? '0') ?? 0;

                          // Gọi hàm để xóa đơn hàng và cập nhật ví
                          deleteOrderAndUpdateWallet(
                              widget.orderId, user!.uid, orderTotal);

                          // Đóng modal bottom sheet
                          Navigator.of(context).pop();

                          // Hiển thị thông báo
                          loginController.ThongBao(
                              context, 'Đơn hàng của bạn đã được hủy.');
                        } else {
                          // Nếu user chưa đăng nhập, hiển thị thông báo lỗi
                          loginController.ThongBao(context,
                              'Vui lòng đăng nhập để thực hiện thao tác này.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final List<Map<dynamic, dynamic>> products =
        List<Map<dynamic, dynamic>>.from(widget.data['products'] ?? []);
    final int soluong = products.fold<int>(
        0,
        (sum, product) =>
            sum + (int.tryParse(product['quantity'].toString()) ?? 0));

    double totalAmount = 0;
    if (widget.data['totalAmount'] is String) {
      totalAmount = double.tryParse(widget.data['totalAmount']) ?? 0;
    } else if (widget.data['totalAmount'] is num) {
      totalAmount = widget.data['totalAmount'].toDouble();
    }

    String orderStatus = widget.data['orderStatus'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          ),
        ),
        const SizedBox(height: 8),
        if (orderStatus != 'Đang giao hàng' && orderStatus != 'Thành công') ...[
          ElevatedButton(
            onPressed: () {
              showDeleteConfirmationDialog(context, widget.orderId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Hủy đơn hàng',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}
