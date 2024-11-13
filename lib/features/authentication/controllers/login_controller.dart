// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously, unused_import, unused_local_variable, unused_field, non_constant_identifier_names

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/Navigation/btn_navigation.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
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
        // Đăng nhập bằng email và mật khẩu
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text,
        );

        User? user = userCredential.user;

        // Kiểm tra xem người dùng có tồn tại hay không
        if (user != null) {
          // Lấy thông tin người dùng từ Firebase Realtime Database
          final databaseRef =
              FirebaseDatabase.instance.ref("users/${user.uid}");
          DatabaseEvent event = await databaseRef.once();

          // Kiểm tra nếu dữ liệu tồn tại
          if (event.snapshot.value != null) {
            final userData = event.snapshot.value;

            // Chuyển đổi dữ liệu sang Map nếu cần
            if (userData is Map<Object?, Object?>) {
              Map<String, dynamic> userMap = userData.map((key, value) {
                return MapEntry(key.toString(), value);
              });

              UserModel currentUser = UserModel.fromJson(userMap);

              // Kiểm tra trạng thái người dùng
              if (currentUser.status == "Ngừng hoạt động") {
                errorMessage =
                    'Tài khoản của bạn đã bị ngừng hoạt động. Vui lòng liên hệ hỗ trợ.';

                // Đăng xuất người dùng ngay lập tức
                await FirebaseAuth.instance.signOut();
              } else if (user.emailVerified) {
                // Người dùng đã xác thực email và trạng thái hoạt động bình thường
                errorMessage = 'Đăng nhập thành công.';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Btn_Navigatin()),
                );
              } else {
                errorMessage =
                    'Vui lòng xác thực email của bạn trước khi đăng nhập.';
                // Đăng xuất người dùng nếu email chưa được xác thực
                await FirebaseAuth.instance.signOut();
              }
            } else {
              print('Dữ liệu người dùng không đúng định dạng Map.');
            }
          } else {
            print('Không tìm thấy dữ liệu người dùng trong Realtime Database.');
          }
        }
      } catch (e) {
        // Bắt lỗi và hiển thị thông báo nếu có lỗi xảy ra
        errorMessage = "Tài khoản hoặc mật khẩu không đúng!";
        print('Lỗi khi đăng nhập: $e');
      }

      // Hiển thị thông báo lỗi (nếu có)
      ThongBao(context, errorMessage);
    }
  }

  void ThongBao(BuildContext context, String errorMessage) {
    // Ẩn nhanh SnackBar hiện tại nếu có
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 1), // Thời gian hiển thị ngắn
      backgroundColor: Colors.blue,
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
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

//Đăng xuất
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      errorMessage = "Đăng xuất thành công!";
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } catch (e) {
      errorMessage = "Lỗi đăng xuất: $e";
    }
    ThongBao(context, errorMessage);
  }
}
