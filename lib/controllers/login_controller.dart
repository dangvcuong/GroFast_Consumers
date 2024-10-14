// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously, unused_import, unused_local_variable, unused_field, non_constant_identifier_names

import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/login/loggin.dart';
import 'package:grofast_consumers/ulits/btn_navigation.dart';
import 'package:grofast_consumers/validates/vlidedate_dN.dart';

class Login_Controller {
  static final Login_Controller _instance = Login_Controller._internal();

  // Private constructor
  Login_Controller._internal();

  // Factory constructor to return the same instance
  factory Login_Controller() {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController email_Resst_Controller = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final validete validateLogin = validete();

  String errorMessage = "";
  bool checkDN() {
    var check = true;
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    if (emailController.text.isEmpty) {
      check = false;
    } else if (!regExp.hasMatch(emailController.text)) {
      check = false;
    }

    if (passController.text.isEmpty) {
      check = false;
    } else if (passController.text.length < 6) {
      check = false;
    }
    return check;
  }

  bool checkResstPass() {
    var check = true;
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    if (email_Resst_Controller.text.isEmpty) {
      check = false;
    } else if (!regExp.hasMatch(email_Resst_Controller.text)) {
      check = false;
    }
    return check;
  }

  void clear() {
    emailController.clear();
    passController.clear();
  }

  void login(BuildContext context) async {
    bool? emailError = validateLogin.validateEmail(emailController.value.text);
    bool? passwordError =
        validateLogin.validatePassword(passController.value.text);
    if (checkDN()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text,
        );

        User? user = userCredential.user;

        // Kiểm tra xem email đã được xác thực hay chưa
        if (user != null && user.emailVerified) {
          errorMessage = 'Đăng nhập thành công.';
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Btn_Navigatin()));
        } else {
          errorMessage = 'Vui lòng xác thực email của bạn trước khi đăng nhập.';
          // Đăng xuất người dùng vì email chưa được xác thực
          await FirebaseAuth.instance.signOut();
        }
      } catch (e) {
        errorMessage = "Tài khoản hoặc mật khẩu không đúng!";
      }
      ThongBao(context, errorMessage);
    }
  }

  void ThongBao(BuildContext context, String errorMessage) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      content: Row(
        children: [
          const Icon(Icons.check_circle,
              color: Colors.white), // Icon thành công
          const SizedBox(width: 10),
          Expanded(
            // Sử dụng Expanded để giãn nội dung
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis, // Để cắt ngắn nếu quá dài
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void resetPassword(BuildContext context) async {
    bool? emailError =
        validateLogin.validateEmail(email_Resst_Controller.value.text);
    print(checkResstPass());
    if (checkResstPass()) {
      try {
        await _auth.sendPasswordResetEmail(
            email: email_Resst_Controller.value.text);
        errorMessage = "Đã gửi email đặt lại mật khẩu!";
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Login()));
        clear();
        validateLogin.clear();
      } catch (error) {
        errorMessage = "Email không hợp lệ hoặc không tồn tại!";
      }
      final snackBar = SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue,
        content: Row(
          children: [
            const Icon(Icons.check_circle,
                color: Colors.white), // Icon thành công
            const SizedBox(width: 10),
            Expanded(
              // Sử dụng Expanded để giãn nội dung
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis, // Để cắt ngắn nếu quá dài
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      // Bước 1: Thực hiện đăng nhập Google
      final googleUser = await GoogleSignIn().signIn();
      // Bước 2: Lấy thông tin xác thực từ tài khoản Google
      final googleAuth = await googleUser?.authentication;

      // Bước 3: Tạo credential từ token Google
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );
      // Bước 4: Đăng nhập Firebase với credential từ Google
      await _auth.signInWithCredential(credential);
      errorMessage = "Đăng nhập thành công";
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const Btn_Navigatin()));
    } catch (e) {
      print("Lỗi khi đăng nhập bằng Google: $e");
      errorMessage = "Lỗi khi đăng nhập bằng Google";
      return null;
    }
    ThongBao(context, errorMessage);
  }
}
