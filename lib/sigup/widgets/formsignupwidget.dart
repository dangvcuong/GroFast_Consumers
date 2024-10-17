// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:grofast_consumers/controllers/sign_up_controller.dart';
import 'package:grofast_consumers/login/loggin.dart';
import 'package:grofast_consumers/validates/validate_Dk.dart';

class FormSignUpWidget extends StatefulWidget {
  const FormSignUpWidget({super.key});

  @override
  State<FormSignUpWidget> createState() => _FormSignUpWidgetState();
}

class _FormSignUpWidgetState extends State<FormSignUpWidget> {
  final bool _isChecked = false;
  bool _isPasswordVisible = false;
  bool _isPasswordVisibleConfic = false;
  final SignUp__Controller signupController = SignUp__Controller();
  final valideteDK validateDK = valideteDK();
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        "Đăng ký,",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      Text.rich(
        TextSpan(
            text: 'Bạn đã có tài khoản? ',
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
            children: [
              WidgetSpan(
                  child: GestureDetector(
                onTap: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login())),
                  signupController.clear(),
                  validateDK.clear()
                },
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline),
                ),
              ))
            ]),
      ),
      Container(height: 30),
      TextField(
        keyboardType: TextInputType.name,
        controller: signupController.nameController,
        decoration: InputDecoration(
          labelText: "Nhập tên của bạn", // Chữ ghi chú
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Bo tròn góc
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
        ),
      ),
      Text(
        validateDK.errorMessageName,
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      Container(height: 20),
      TextField(
        keyboardType: TextInputType.emailAddress,
        controller: signupController.emailController,
        decoration: InputDecoration(
          labelText: "Nhập email của bạn", // Chữ ghi chú
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Bo tròn góc
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
        ),
      ),
      Text(
        validateDK.errorMessageEmail,
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      Container(height: 20),
      TextField(
        keyboardType: TextInputType.number,
        controller: signupController.phoneController,
        decoration: InputDecoration(
          labelText: "Nhập số điện thoại", // Chữ ghi chú
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Bo tròn góc
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
        ),
      ),
      Text(
        validateDK.errorMessagePhone,
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      Container(height: 20),
      TextField(
        keyboardType: TextInputType.visiblePassword,
        controller: signupController.passwordController,
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
        validateDK.errorMessagePass,
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      Container(height: 20),
      TextField(
        keyboardType: TextInputType.visiblePassword,
        controller: signupController.conficPasswordController,
        obscureText: !_isPasswordVisibleConfic, // Điều khiển hiển thị mật khẩu
        decoration: InputDecoration(
          labelText: "Nhập lại mật khẩu của bạn",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisibleConfic
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisibleConfic = !_isPasswordVisibleConfic;
              });
            },
          ),
        ),
      ),
      Text(
        validateDK.errorMessagePassConfic,
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      Container(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: signupController.ischeckBock,
              onChanged: (bool? value) {
                setState(() {
                  signupController.ischeckBock = value ?? false;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white, // Màu sắc của dấu kiểm
            ),
          ),
          Container(width: 20),
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Tôi đồng ý với ',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: ' và '),
                  TextSpan(
                    text: 'Chính sách bảo mật',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      Container(height: 20),
      ElevatedButton(
        onPressed: () {
          setState(() {
            signupController.signUp(context);
          });
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            fixedSize: const Size(double.maxFinite, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
        child: const Text("Đăng ký",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    ]));
  }
}
