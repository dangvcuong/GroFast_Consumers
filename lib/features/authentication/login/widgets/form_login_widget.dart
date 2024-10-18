import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/forget_password/forget_password_screen.dart';

import 'package:grofast_consumers/features/authentication/sigup/signup.dart';
import 'package:grofast_consumers/validates/vlidedate_dN.dart';

class FormLoginWidget extends StatefulWidget {
  const FormLoginWidget({super.key});

  @override
  State<FormLoginWidget> createState() => _FormLoginWidgetState();
}

class _FormLoginWidgetState extends State<FormLoginWidget> {
  final Login_Controller loginController = Login_Controller();
  final validete validateLogin = validete();
  bool _isPasswordVisible = false;
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
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Signup())),
                    validateLogin.clear(),
                    loginController.clear()
                  },
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
          controller: loginController.emailController,
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
        Container(height: 20),
        TextField(
          keyboardType: TextInputType.visiblePassword,
          controller: loginController.passController,
          obscureText: !_isPasswordVisible, // Điều khiển hiển thị mật khẩu
          decoration: InputDecoration(
            labelText: "Nhập mật khẩu của bạn",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        Text(
          validateLogin.errorMessagePass,
          style: const TextStyle(color: Colors.red, fontSize: 10),
        ),
        Container(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgetPasswordScreen())),
                      validateLogin.clear(),
                      loginController.clear()
                    },
                child: const Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      decoration: TextDecoration.underline),
                )),
          ),
        ),
        Container(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              loginController.login(context);
            });
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              fixedSize: const Size(double.maxFinite, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50))),
          child: const Text("Đăng nhập",
              style: TextStyle(color: Colors.white, fontSize: 18)),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: GestureDetector(
                  onTap: () => loginController.signInWithGoogle(context),
                  child: Image.asset(
                    "assets/icons/google.png",
                    width: 20,
                    height: 20,
                  )),
            ),
            Container(width: 40),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: GestureDetector(
                  onTap: () => loginController.signInWithGoogle(context),
                  child: Image.asset(
                    "assets/icons/facebook.png",
                    width: 20,
                    height: 20,
                  )),
            ),
          ],
        )
      ]),
    ));
  }
}
