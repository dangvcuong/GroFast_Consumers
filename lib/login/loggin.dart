import 'package:flutter/material.dart';
import 'package:grofast_consumers/login/widgets/form_login_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipPath(
              // clipper: ,
              child: Container(
            width: double.infinity, // Chiếm toàn bộ chiều rộng
            height: MediaQuery.of(context).size.height *
                0.3, // Chiếm 40% chiều cao màn hình
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/on_boarding_screen/on_boarding.jpg"),
                fit: BoxFit.cover, // Đảm bảo ảnh đầy đủ và không bị méo
              ),
            ),
          )),
          const FormLoginWidget()
        ],
      )),
    );
  }
}
