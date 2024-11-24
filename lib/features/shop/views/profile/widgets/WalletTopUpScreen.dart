import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/shop/views/profile/servers/stripe_server.dart';
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
        title: const Text("Nạp tiền", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              "Nhập số tiền (đ)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "đ ",
                hintText: "0",
              ),
              onChanged: (value) {
                String formattedValue = _formatInput(value);
                _amountController.value = TextEditingValue(
                  text: formattedValue,
                  selection:
                      TextSelection.collapsed(offset: formattedValue.length),
                );
                setState(() {
                  totalAmount = int.tryParse(formattedValue
                          .replaceAll('.', '')
                          .replaceAll(',', '')) ??
                      0;
                });
              },
            ),

            const SizedBox(height: 20),
            Text(
              "Số dư Ví hiện tại: ${formatter.format(currentUser?.balance ?? 0)}",
              style: const TextStyle(color: Colors.grey),
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
                StripeServer.instance.makePayment(
                    userId: currentUser!.id,
                    amount: totalAmount,
                    context: context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                    totalAmount > 0 ? Colors.blue : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bo tròn nhẹ
                ),
              ),
              child: const Text(
                "Thanh toán ngay với Stripe Payment",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Nhấn “Nạp tiền ngay”, bạn đã đồng ý tuân theo Điều khoản sử dụng và Chính sách bảo mật của GroFast",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTopUpPressed() {
    // Thực hiện hành động khi nhấn "Nạp tiền ngay"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nạp số tiền: $formatter.format(totalAmount)')),
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
