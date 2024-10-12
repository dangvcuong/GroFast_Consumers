// ignore_for_file: camel_case_types, unused_local_variable, unused_field, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/login/loggin.dart';
import 'package:grofast_consumers/validates/validate_Dk.dart';

class SignUp__Controller {
  static final SignUp__Controller _instance = SignUp__Controller._internal();

  // Private constructor
  SignUp__Controller._internal();

  // Factory constructor to return the same instance
  factory SignUp__Controller() {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final valideteDK validateSignup = valideteDK();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController conficPasswordController =
      TextEditingController();
  bool ischeckBock = false;
  String errorMessage = "";

  bool checkDK() {
    var check = true;
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    if (emailController.text.isEmpty) {
      check = false;
    } else if (!regExp.hasMatch(emailController.text)) {
      check = false;
    }

    if (passwordController.text.isEmpty) {
      check = false;
    } else if (passwordController.text.length < 6) {
      check = false;
    }

    if (passwordController.text.isEmpty) {
      check = false;
    } else if (conficPasswordController.text.length < 6) {
      check = false;
    } else if (conficPasswordController.text != passwordController.text) {
      check = false;
    }

    final RegExp phoneRegExp = RegExp(r'^[0-9]+$');
    if (phoneController.text.isEmpty) {
      check = false;
    } else if (phoneController.text.length < 10 ||
        !phoneRegExp.hasMatch(phoneController.text)) {
      check = false;
    }

    if (nameController.text.isEmpty) {
      check = false;
    }
    if (ischeckBock == false) {
      errorMessage = "Bạn cần đồng ý với các điều khoản và điều kiện";
      check = false;
    }

    return check;
  }

  void clear() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    conficPasswordController.clear();
    ischeckBock = false;
  }

  void signUp(BuildContext context) async {
    bool? nameError = validateSignup.validateName(nameController.value.text);
    bool? phoneError = validateSignup.validatePhone(phoneController.value.text);
    bool? emailError = validateSignup.validateEmail(emailController.value.text);
    bool? passwordError =
        validateSignup.validatePassword(passwordController.value.text);
    bool? passConficError = validateSignup.validatePasswordConfic(
        conficPasswordController.value.text, passwordController.value.text);
    if (checkDK()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        // Đăng ký thành công
        errorMessage = 'Đăng ký thành công!';
        clear();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Login()));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          errorMessage = 'Mật khẩu quá yếu.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Email đã được sử dụng.';
        } else {
          errorMessage = 'Đã có lỗi xảy ra.';
        }
      } catch (e) {
        errorMessage = 'Đã có lỗi xảy ra.';
      }
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
