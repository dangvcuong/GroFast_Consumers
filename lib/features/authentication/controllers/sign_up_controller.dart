// ignore_for_file: camel_case_types, unused_local_variable, unused_field, use_build_context_synchronously, await_only_futures, non_constant_identifier_names, avoid_print, duplicate_ignore, no_leading_underscores_for_local_identifiers
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/authentication/sigup/widgets/email_verification_widget.dart';
import 'package:grofast_consumers/validates/validate_Dk.dart';
import 'package:firebase_database/firebase_database.dart';

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
  String? errorMessage;

  bool checkDK(BuildContext context) {
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
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(passwordController.text)) {
      check = false;
    } else if (!RegExp(r'(?=.*\d)').hasMatch(passwordController.text)) {
      check = false;
    } else if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(passwordController.text)) {
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
      ThongBao(context, errorMessage!);
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

  // Future<void> addUserToFirebase() async {
  //   final databaseRef =
  //       FirebaseDatabase.instance.ref("users/${UserCredential.user!.uid}");
  //   UserModel newUser = UserModel(
  //     id: DateTime.now().microsecondsSinceEpoch.toString(), // Tạo ID duy nhất
  //     name: nameController.text.toString(),
  //     phoneNumber: phoneController.text.toString(),
  //     email: emailController.text.toString(),
  //     diaChi: "",
  //     image: "", // Thay thế bằng URL thực tế nếu có
  //     gioiTinh: "",
  //     ngayTao: DateTime.now().toString(), // Thời gian hiện tại
  //     trangThai: "Hoạt động",
  //   );
  //   try {
  //     // Sử dụng ID của user làm key trong database
  //     await databaseRef.child(newUser.id).set(newUser.toJson()).then((_) {
  //       print("User added successfully with ID: ${newUser.id}");
  //     }).catchError((error) {
  //       print("Failed to add user: $error");
  //     });
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  void signUp(BuildContext context) async {
    bool? nameError = validateSignup.validateName(nameController.value.text);
    bool? phoneError = validateSignup.validatePhone(phoneController.value.text);
    bool? emailError = validateSignup.validateEmail(emailController.value.text);
    bool? passwordError =
        validateSignup.validatePassword(passwordController.value.text);
    bool? passConficError = validateSignup.validatePasswordConfic(
        conficPasswordController.value.text, passwordController.value.text);
    late DatabaseReference _database;
    if (checkDK(context)) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.value.text.trim(),
          password: passwordController.text.trim(),
        );

        // Kiểm tra xem user có tồn tại không
        if (userCredential.user != null) {
          final databaseRef = FirebaseDatabase.instance
              .ref("users/${userCredential.user!.uid}");

          UserModel newUser = UserModel(
            id: userCredential.user!.uid, // Sử dụng UID của người dùng
            name: nameController.text.toString(),
            phoneNumber: phoneController.text.toString(),
            email: emailController.text.toString(),
            address: [],
            image: "",
            dateCreated: DateTime.now().toString(),
            status: "Hoạt động",
          );

          await databaseRef.set(newUser.toJson()).then((_) {
            print(
                "User added successfully with ID: ${userCredential.user!.uid}");
          }).catchError((error) {
            print("Failed to add user: $error");
          });
          sendVerificationEmail();
          errorMessage =
              'Vui lòng kiểm tra Email xác thực để hoàn thành đăng ký';
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const VerifyScreen()));
        } else {
          errorMessage = 'Người dùng không tồn tại.';
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          errorMessage = 'Mật khẩu quá yếu.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Email đã được sử dụng.';
        } else {
          errorMessage = 'Đã có lỗi xảy ra 1.';
        }
      } catch (e) {
        errorMessage = 'Đã có lỗi xảy ra 2.';
      }
      ThongBao(context, errorMessage!);
    }
  }

//Hiển thị thông báo
  void ThongBao(BuildContext context, String errorMessage) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 1),
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

//Gửi emali xác thực
  sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      // ignore: avoid_print
      print('Email xác thực đã được gửi.');
    }
  }

// gửi lại
  resendVerificationEmail(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? errorMessage;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        errorMessage = 'Email xác thực đã được gửi lại.';
      } catch (e) {
        print('Error: $e');
      }
    } else {
      errorMessage = 'Không thể gửi email xác thực.';
    }
    ThongBao(context, errorMessage!);
  }
}
