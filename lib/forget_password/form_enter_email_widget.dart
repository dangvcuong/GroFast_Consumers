import 'package:flutter/material.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/theme/app_style.dart';

class FormEnterEmailWidget extends StatefulWidget {
  const FormEnterEmailWidget({super.key});

  @override
  State<FormEnterEmailWidget> createState() => _FormEnterEmailWidgetState();
}

class _FormEnterEmailWidgetState extends State<FormEnterEmailWidget> {
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
              decoration: InputDecoration(
                labelText: "Nhập email của bạn", // Chữ ghi chú
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bo tròn góc
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
              ),
            ),
            gapH12,
            ElevatedButton(
              onPressed: () {
                // FocusScope.of(context).requestFocus(FocusNode());
                // loginController.login();
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
