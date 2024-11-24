import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/views/profile/keys.dart';
import 'package:firebase_database/firebase_database.dart';

class StripeServer {
  StripeServer._();

  static final StripeServer instance = StripeServer._();
  final Login_Controller login_controller = Login_Controller();

  Future<void> makePayment(
      {required String userId,
      required int amount,
      required BuildContext context}) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, "vnd");
      if (paymentIntentClientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "GroFast Store",
        ),
      );

      // Gọi _processPayment và truyền context
      await _processPayment(userId: userId, amount: amount, context: context);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency, // Đổi thành "vnd"
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization":
                "Bearer $stripeSecretKey", // Thay bằng khóa bí mật Stripe của bạn
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );
      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _processPayment(
      {required String userId,
      required int amount,
      required BuildContext context}) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Nếu thanh toán thành công, cập nhật số dư
      await _updateBalance(userId, amount);

      // Hiển thị thông báo thanh toán thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);

      // Hiển thị thông báo lỗi nếu có sự cố trong quá trình thanh toán
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra trong quá trình thanh toán.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _calculateAmount(int amount) {
    // Stripe yêu cầu số tiền phải là đơn vị nhỏ nhất của tiền tệ (VND không có thập phân)
    return amount.toString();
  }

//Update
  Future<void> _updateBalance(String userId, int amount) async {
    try {
      final databaseRef =
          FirebaseDatabase.instance.ref("users/$userId/balance");

      // Lấy giá trị hiện tại của balance
      final snapshot = await databaseRef.get();
      int currentBalance = snapshot.exists ? snapshot.value as int : 0;

      // Cộng thêm số tiền vừa thanh toán
      int updatedBalance = currentBalance + amount;

      // Cập nhật lại giá trị mới
      await databaseRef.set(updatedBalance);
      print("Balance updated successfully: $updatedBalance");
    } catch (e) {
      print("Failed to update balance: $e");
    }
  }
}
