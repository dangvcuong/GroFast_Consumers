import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/shop/views/profile/servers/stripe_server.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/paymenthistory_screen.dart';
import 'package:intl/intl.dart';

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final TextEditingController _amountController = TextEditingController();
  int totalAmount = 0;
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final formatterInput = NumberFormat.currency(locale: 'vi_VN', symbol: "  ");
  @override
  void initState() {
    super.initState();
    _getUserInfo();
    Stripe.publishableKey =
        'pk_test_51QNuhqLA1LG9yr6DuAAqmLRrrAKQeuVTOt5LHuohApK6EU9DYTL1szIzlhD9PHXHNRyOpZYi68SoZatRT1F04BSd00R9QElBHq';

    // Lắng nghe thay đổi từ TextField
    _amountController.addListener(() {
      setState(() {
        totalAmount = int.tryParse(_amountController.text
                .replaceAll('.', '')
                .replaceAll(',', '')) ??
            0;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    currentUser = await userController.getUserInfo();
    setState(() {});
  }

  void _onAmountButtonPressed(String amount) {
    // Định dạng giá trị và gán vào _amountController
    String formattedAmount = formatterInput.format(int.parse(amount));
    setState(() {
      _amountController.value = TextEditingValue(
        text: formattedAmount,
        selection: TextSelection.collapsed(offset: formattedAmount.length),
      );
      totalAmount = int.parse(amount); // Cập nhật giá trị tổng số tiền
    });
  }

  String _formatInput(String value) {
    // Hàm định dạng số tiền
    String newValue = value.replaceAll('.', '').replaceAll(',', '');
    if (newValue.isNotEmpty) {
      return formatter.format(int.parse(newValue));
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nạp tiền",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập số tiền cần nạp (đ)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "0đ",
              ),
              onChanged: (value) {
                // Lúc người dùng đang nhập, chúng ta chỉ cập nhật giá trị không định dạng
                String rawValue = value.replaceAll('.', '').replaceAll(',', '');
                setState(() {
                  totalAmount = int.tryParse(rawValue) ?? 0;
                });
              },
              onEditingComplete: () {
                // Khi người dùng rời khỏi TextField, áp dụng định dạng
                String formattedValue = _formatInput(_amountController.text);
                _amountController.value = TextEditingValue(
                  text: formattedValue,
                  selection:
                      TextSelection.collapsed(offset: formattedValue.length),
                );
              },
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Số dư Ví hiện tại: ${formatter.format(currentUser?.balance ?? 0)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history, // Biểu tượng lịch sử
                    size: 25, // Kích thước biểu tượng
                    color: Colors.blue, // Màu sắc biểu tượng
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymenthistoryScreen(
                            userId: currentUser!
                                .id), // Thay thế YourCurrentPage bằng widget hiện tại của bạn
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountButton(context, "100000"),
                _buildAmountButton(context, "200000"),
                _buildAmountButton(context, "500000"),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nạp tiền",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  formatter.format(totalAmount),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const Divider(), // Khoảng cách giữa các dòng
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                "Tổng thanh toán",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                formatter.format(totalAmount),
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red, // Màu đỏ cho phần tổng thanh toán
                    fontWeight: FontWeight.bold),
              ),
            ]),
            const Spacer(),

            const Divider(),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (totalAmount >= 10000) {
                  // Tiến hành thanh toán nếu số tiền >= 10,000
                  StripeServer.instance.makePayment(
                    userId: currentUser!.id,
                    amount: totalAmount,
                    context: context,
                  );
                } else {
                  // Hiển thị thông báo lỗi nếu số tiền nhỏ hơn 10,000
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Số tiền nạp phải từ 10,000đ trở lên!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                    totalAmount >= 10000 ? Colors.blue : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bo tròn nhẹ
                ),
              ),
              child: const Text(
                "Nạp tiền với Stripe Payment",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Nhấn “Nạp tiền ”, bạn đã đồng ý tuân theo Điều khoản sử dụng và Chính sách bảo mật của GroFast",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(BuildContext context, String amount) {
    return ElevatedButton(
      onPressed: () {
        _onAmountButtonPressed(amount);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              8), // Bo tròn nhẹ (hoặc 0 để hoàn toàn vuông)
        ),
      ),
      child: Text(
        formatter.format(int.parse(amount)),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
//   void _onAmountButtonPressed(String amount) {
//     _amountController.text = amount;
//   }
// }
