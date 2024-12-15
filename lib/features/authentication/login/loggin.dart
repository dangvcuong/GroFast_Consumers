import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/login/widgets/form_login_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black, // Màu mũi tên
            size: 30, // Kích thước mũi tên
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: screenHeight * 0.3,
        elevation: 0, // Tắt bóng dưới AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            image: DecorationImage(
              image: AssetImage(
                  "assets/images/on_boarding_screen/on_boarding.jpg"),
              fit: BoxFit.cover, // Đảm bảo ảnh phủ toàn bộ AppBar
            ),
          ),
        ),
      ),
      body: const SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [FormLoginWidget()],
      )),
    );
  }
}
