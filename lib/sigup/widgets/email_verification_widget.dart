// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_field, avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/controllers/sign_up_controller.dart';
import 'package:grofast_consumers/sigup/widgets/complete_create_account_screen.dart';

import 'package:grofast_consumers/theme/app_style.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final SignUp__Controller signUp_Controller = SignUp__Controller();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    checkEmailVerification();
  }

  void checkEmailVerification() async {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      user = _auth.currentUser; // Cập nhật lại user từ Firebase

      if (user != null) {
        await user!.reload(); // Tải lại thông tin người dùng từ Firebase

        if (user!.emailVerified) {
          timer.cancel(); // Hủy timer khi email đã được xác thực
          print("Chuyển màn hình");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CompleteCreateAccountScreen(),
            ),
          );
        } else {
          print("Email chưa được xác thực");
        }
      }
    });
  }

  @override
  void dispose() {
    // Hủy kiểm tra khi thoát màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => {Navigator.pop(context)},
              child: const Icon(Icons.close),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icons/email_verification.png'),
              Container(height: 20),
              const Text(
                'Xác thực email của bạn',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Container(height: 30),
              Text(
                'Một email đã được gửi tới ${signUp_Controller.emailController.text} với 1 đường dẫn để xác thực tài khoản của bạn. Nếu không nhận được email sau vài phút, hãy kiểm tra trong hòm thư spam của bạn.',
                style: HAppStyle.paragraph3Regular
                    .copyWith(color: HAppColor.hGreyColorShade600),
                textAlign: TextAlign.center,
              ),
              Container(height: 70),
              Text.rich(
                TextSpan(
                  text: 'Không nhận được email? ',
                  style: HAppStyle.paragraph3Regular
                      .copyWith(color: HAppColor.hGreyColorShade600),
                  children: [
                    WidgetSpan(
                        child: GestureDetector(
                      onTap: () => setState(() {
                        signUp_Controller.resendVerificationEmail();
                      }),
                      child: Text(
                        'Gửi lại.',
                        style: HAppStyle.paragraph3Regular
                            .copyWith(color: HAppColor.hBluePrimaryColor),
                      ),
                    ))
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
