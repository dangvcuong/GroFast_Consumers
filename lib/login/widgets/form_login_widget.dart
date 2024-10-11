import 'package:flutter/material.dart';
import 'package:grofast_consumers/forget_password/forget_password_screen.dart';
import 'package:grofast_consumers/forget_password/form_enter_email_widget.dart';
import 'package:grofast_consumers/sigup/signup.dart';

class FormLoginWidget extends StatefulWidget {
  const FormLoginWidget({super.key});

  @override
  State<FormLoginWidget> createState() => _FormLoginWidgetState();
}

class _FormLoginWidgetState extends State<FormLoginWidget> {
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 20),
        const Text(
          "Chào mừng quay trở lại,",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text.rich(
          TextSpan(
            text: 'Bạn chưa có tài khoản? ',
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Signup())),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 40),
        TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Nhập email của bạn",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Bo tròn góc
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
          ),
        ),
        Container(height: 40),
        TextField(
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: "Nhập mật khẩu của bạn", // Chữ ghi chú
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Bo tròn góc
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
          ),
        ),
        Container(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgetPasswordScreen())),
                child: const Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      decoration: TextDecoration.underline),
                )),
          ),
        ),
        Container(height: 10),
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
          child: const Text("Đăng nhập", style: TextStyle(color: Colors.white)),
        ),
        Container(height: 20),
        const Row(
          children: [
            Expanded(
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
            Text(
              "Hoặc tiếp tục với",
              style: TextStyle(color: Colors.grey),
            ),
            Expanded(
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Container(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(100)),
              // child: SocialMediaButton.google(
              //   onTap: () => loginController.googleSignIn(),
              //   size: 30,
              //   color: HAppColor.hWhiteColor,
              // ),
            ),
            Container(width: 40),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 93, 159),
                  borderRadius: BorderRadius.circular(100)),
              // child: SocialMediaButton.facebook(
              //   onTap: () {},
              //   size: 30,
              //   color: HAppColor.hWhiteColor,
              // ),
            ),
          ],
        )
      ]),
    ));
  }
}
