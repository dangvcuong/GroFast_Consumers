// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously, unused_import, unused_local_variable, unused_field

import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text,
        );
        print("Đăng nhập thành công: ${userCredential.user?.email}");
        errorMessage = 'Đăng nhập thành công!';
        validateLogin.clear();
        clear();
      } catch (e) {
        errorMessage = "Tài khoản hoặc mật khẩu không đúng!";
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

  void resetPassword(BuildContext context) async {
    bool? emailError =
        validateLogin.validateEmail(email_Resst_Controller.value.text);
    print(checkResstPass());
    if (checkResstPass()) {
      try {
        await _auth.sendPasswordResetEmail(
            email: email_Resst_Controller.text.trim());
        errorMessage = "Đã gửi email đặt lại mật khẩu!";
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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Bước 1: Thực hiện đăng nhập Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // Nếu người dùng hủy đăng nhập
        return null;
      }

      // Bước 2: Lấy thông tin xác thực từ tài khoản Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Bước 3: Tạo credential từ token Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Bước 4: Đăng nhập Firebase với credential từ Google
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Lỗi khi đăng nhập bằng Google: $e");
      return null;
    }
  }
}
