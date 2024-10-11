import 'package:flutter/material.dart';
import 'package:grofast_consumers/login/loggin.dart';

class FormSignUpWidget extends StatefulWidget {
  const FormSignUpWidget({super.key});

  @override
  State<FormSignUpWidget> createState() => _FormSignUpWidgetState();
}

class _FormSignUpWidgetState extends State<FormSignUpWidget> {
  bool _isChecked = false;

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
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
            children: [
              WidgetSpan(
                  child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login())),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      decoration: TextDecoration.underline),
                ),
              ))
            ]),
      ),
      Container(height: 40),
      TextField(
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          labelText: "Nhập tên của bạn", // Chữ ghi chú
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Bo tròn góc
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
        ),
      ),
      Container(height: 40),
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
      Container(height: 40),
      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Nhập số điện thoại", // Chữ ghi chú
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
          labelText: "Nhập mật khẩu", // Chữ ghi chú
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Bo tròn góc
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
        ),
      ),
      Container(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
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
          // FocusScope.of(context).requestFocus(FocusNode());
          // loginController.login();
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            fixedSize: const Size(double.maxFinite, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
        child: const Text("Đăng ký", style: TextStyle(color: Colors.white)),
      ),
    ]));
  }
}
