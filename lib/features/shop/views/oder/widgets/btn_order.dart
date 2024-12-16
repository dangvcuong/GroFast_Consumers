import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../authentication/controllers/login_controller.dart';
import '../../../models/shopping_cart_model.dart';
import '../../pay/pay_cart_screen.dart';

class ButtonRow extends StatefulWidget {
  final String orderId;
  final Map data;

  const ButtonRow({super.key, required this.orderId, required this.data});

  @override
  _ButtonRowState createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("orders");
  final Login_Controller loginController = Login_Controller();
  final User? user = FirebaseAuth.instance.currentUser;
  String? totalAmount; // Tổng tiền từ Firebase
  String? refundAmount; // Số tiền cần hoàn lại
  String? tong;
  @override
  void initState() {
    super.initState();
    fetchTotalAmount(widget.orderId);
    fetchRefundAmount(widget.orderId);
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
      //Tien vi nguoi dung
      final double currentWallet =
          double.tryParse(walletSnapshot.value.toString()) ?? 0;
      final double orderTien = double.tryParse(totalAmount ?? '0') ?? 0;
      // Cập nhật số dư ví
      if (orderTien == 0) {
        final double updatedWallet = currentWallet + orderTotal;
        await userWalletRef.set(updatedWallet);
      } else {
        final double updatedWallet = currentWallet + 0;
        await userWalletRef.set(updatedWallet);
      }
      //Đổi trạng thái
      final orderRef = FirebaseDatabase.instance.ref().child('orders/$orderId');
      await orderRef.update({'orderStatus': 'Đã hủy'});
      print(
          'Đơn hàng với ID $orderId đã bị xóa và ví tiền của người dùng được cập nhật!');
    } catch (e) {
      print('Lỗi khi xóa đơn hàng hoặc cập nhật ví: $e');
    }
  }

  void _handleReorder(List<Map<dynamic, dynamic>> products) {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có sản phẩm nào trong đơn hàng!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      List<CartItem> cartItems = products.map((product) {
        return CartItem(
          productId: product['id'],
          name: product['name'],
          description: product['description'] ?? '',
          imageUrl: product['imageUrl'] ?? '',
          price: (product['price'] as num?)?.toDouble() ?? 0.0,
          quantity: product['quantity'] as int? ?? 1,
          evaluate:
              double.tryParse(product['evaluate']?.toString() ?? '0') ?? 0.0,
          idHang: product['idHang'] ?? '',
        );
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCartScreen(products: cartItems),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Lấy tổng tiền đơn hàng từ Firebase
  Future<void> fetchTotalAmount(String orderId) async {
    try {
      final snapshot =
          await databaseRef.child(orderId).child("totalAmount").get();
      final snapshot1 = await databaseRef.child(orderId).child("tong").get();
      if (snapshot.exists) {
        setState(() {
          totalAmount = snapshot.value.toString();
          print(totalAmount);
          tong = snapshot1.value.toString();
          print(tong);
        });
      } else {
        setState(() {
          totalAmount = "Không tìm thấy đơn hàng!";
        });
      }
    } catch (e) {
      setState(() {
        totalAmount = "Lỗi khi tải dữ liệu!";
      });
    }
  }

  // Lấy số tiền cần hoàn lại từ Firebase
  Future<void> fetchRefundAmount(String orderId) async {
    try {
      final snapshot = await databaseRef.child(orderId).child("refund").get();
      if (snapshot.exists) {
        setState(() {
          refundAmount = snapshot.value.toString();
        });
      } else {
        setState(() {
          refundAmount = "Không tìm thấy thông tin hoàn tiền!";
        });
      }
    } catch (e) {
      setState(() {
        refundAmount = "Lỗi khi tải dữ liệu!";
      });
    }
  }

  // Hủy đơn hàng và cập nhật trạng thái + hoàn tiền
  Future<void> cancelOrderAndUpdateStatus(String orderId, String userId) async {
    try {
      final orderRef = FirebaseDatabase.instance.ref().child('orders/$orderId');
      await orderRef.update({'orderStatus': 'Đã hủy'});

      final userWalletRef =
          FirebaseDatabase.instance.ref().child('users/$userId/balance');
      final walletSnapshot = await userWalletRef.get();
      if (!walletSnapshot.exists)
        throw Exception("Ví tiền của người dùng không tồn tại.");

      final double currentWallet =
          double.tryParse(walletSnapshot.value.toString()) ?? 0;
      final double orderRefund = double.tryParse(refundAmount ?? '0') ?? 0;

      final double updatedWallet = currentWallet + orderRefund;
      await userWalletRef.set(updatedWallet);
    } catch (e) {
      print('Lỗi khi hủy đơn hàng hoặc hoàn tiền: $e');
    }
  }

  // Hiển thị thông báo xác nhận hủy đơn hàng
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
            children: [
              const Text(
                'Xác nhận hủy đơn hàng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn có chắc chắn muốn hủy đơn hàng này?',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Hủy',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (user?.uid != null) {
                        final double orderTotal =
                            double.tryParse(tong ?? '0') ?? 0;

                        deleteOrderAndUpdateWallet(
                            orderId, user!.uid, orderTotal);

                        Navigator.of(context).pop();
                        loginController.ThongBao(
                            context, 'Đơn hàng của bạn đã được hủy.');
                      } else {
                        loginController.ThongBao(
                            context, 'Vui lòng đăng nhập!');
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Xác nhận',
                        style: TextStyle(color: Colors.white)),
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

    final double totalAmountValue = double.tryParse(totalAmount ?? '0') ?? 0;

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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Thành tiền: ${formatter.format(totalAmountValue)}',
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (orderStatus == 'Đang chờ xác nhận') ...[
          ElevatedButton(
            onPressed: () =>
                showDeleteConfirmationDialog(context, widget.orderId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Hủy đơn hàng',
                style: TextStyle(color: Colors.white)),
          ),
        ] else if (orderStatus == 'Đã xác nhận' || orderStatus == "Đang giao hàng") ...[
         ElevatedButton(
           onPressed: () => {},
           style: ElevatedButton.styleFrom(backgroundColor: Colors.white30),
           child: const Text('Hủy đơn hàng',
           style: TextStyle(color: Colors.white)),
           ),
        ] else if (orderStatus == 'Đã hủy' || orderStatus == "Thành công") ...[
          ElevatedButton(
            onPressed: () => _handleReorder(products),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Mua lại', style: TextStyle(color: Colors.white)),
          ),
        ],

      ],
    );
  }
}
