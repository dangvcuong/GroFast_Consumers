import 'package:flutter/material.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/controllers/login_controller.dart';
import 'package:grofast_consumers/theme/app_style.dart';
import 'package:grofast_consumers/validates/vlidedate_dN.dart';

class FormEnterEmailWidget extends StatefulWidget {
  const FormEnterEmailWidget({super.key});

  @override
  State<FormEnterEmailWidget> createState() => _FormEnterEmailWidgetState();
}

class _FormEnterEmailWidgetState extends State<FormEnterEmailWidget> {
  final validete validateLogin = validete();
  final Login_Controller loginController = Login_Controller();
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(hAppDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapH10,
            const Text(
              "Quên mật khẩu",
              style: HAppStyle.heading3Style,
            ),
            gapH6,
            Text.rich(
              TextSpan(
                text:
                    'Đừng lo lắng, chúng tôi sẽ gửi 1 đường dẫn đến email của bạn đặt lại mật khẩu.',
                style: HAppStyle.paragraph2Regular
                    .copyWith(color: HAppColor.hGreyColorShade600),
                children: const [],
              ),
            ),
            gapH12,
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: loginController.email_Resst_Controller,
              decoration: InputDecoration(
                labelText: "Nhập email của bạn",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bo tròn góc
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
              ),
            ),
            Text(
              validateLogin.errorMessageEmail,
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
            gapH12,
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loginController.resetPassword(context);
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child:
                  const Text("Tiếp tục", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
