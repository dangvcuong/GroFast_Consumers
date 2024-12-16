// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously, unused_import, unused_local_variable, unused_field, non_constant_identifier_names

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/Navigation/btn_navigation.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/validates/vlidedate_dN.dart';

import '../../shop/views/notification/Api/notifi_api.dart';

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
  final notifi = NotifiApi();
  final _firebaseMessaging = FirebaseMessaging.instance;
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

        // Kiểm tra xem người dùng có tồn tại không
        if (user != null) {
          // Lấy thông tin người dùng từ Firebase Realtime Database
          final databaseRef =
              FirebaseDatabase.instance.ref("users/${user.uid}");
          DatabaseEvent event = await databaseRef.once();

          if (event.snapshot.value != null) {
            final userData = event.snapshot.value;

            // Chuyển đổi dữ liệu sang Map nếu cần
            if (userData is Map<Object?, Object?>) {
              Map<String, dynamic> userMap = userData.map((key, value) {
                return MapEntry(key.toString(), value);
              });

              UserModel currentUser = UserModel.fromJson(userMap);

              if (currentUser.status == "Ngừng hoạt động") {
                errorMessage =
                    'Tài khoản của bạn đã bị ngừng hoạt động. Vui lòng liên hệ hỗ trợ.';
                await FirebaseAuth.instance.signOut(); // Đăng xuất người dùng
              } else if (user.emailVerified) {
                // Người dùng đã xác thực email và trạng thái hoạt động bình thường
                errorMessage = 'Đăng nhập thành công.';

                // Gọi hàm thông báo khi đăng nhập thành công
                await notifi.initNotifications(user.uid);

                // Điều hướng đến màn hình chính
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Btn_Navigatin()),
                );
              } else {
                errorMessage =
                    'Vui lòng xác thực email của bạn trước khi đăng nhập.';
                await FirebaseAuth.instance.signOut(); // Đăng xuất người dùng
              }
            } else {
              print('Dữ liệu người dùng không đúng định dạng Map.');
              errorMessage = 'Dữ liệu người dùng không hợp lệ.';
            }
          } else {
            print('Không tìm thấy dữ liệu người dùng trong Realtime Database.');
            errorMessage = 'Không tìm thấy dữ liệu người dùng.';
          }
        } else {
          errorMessage = 'Không tìm thấy người dùng.';
        }
      } catch (e) {
        errorMessage = "Tài khoản hoặc mật khẩu không đúng!";
        print('Lỗi khi đăng nhập: $e');
      }

      ThongBao(context, errorMessage); // Hiển thị thông báo lỗi nếu có
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

      // Bước 5: Lấy thông tin người dùng từ Google
      final user = FirebaseAuth.instance.currentUser;

      // Bước 6: Lưu thông tin người dùng vào Firestore
      if (user != null) {
        // Kiểm tra nếu tên người dùng (displayName) không có, dùng email làm tên
        String userName = user.displayName ?? user.email?.split('@')[0] ?? '';

        // Dữ liệu người dùng
        UserModel newUser = UserModel(
          id: user.uid, // Sử dụng UID của người dùng
          name: userName, // Dùng tên từ email nếu không có displayName
          phoneNumber: "", // Có thể để trống nếu không có số điện thoại
          email: user.email ?? '',
          address: [],
          image: user.photoURL ?? '',
          dateCreated: DateTime.now().toString(),
          status: "Hoạt động",
          balance: 0,
          userDeviceToken: '',
        );

        // Lưu vào Firestore (hoặc Realtime Database)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson()); // Sử dụng toJson để lưu

        errorMessage = "Đăng nhập thành công";
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Btn_Navigatin()));
      }
    } catch (e) {
      print("Lỗi khi đăng nhập bằng Google: $e");
      errorMessage = "Lỗi khi đăng nhập bằng Google";
      return null;
    }

    ThongBao(context, errorMessage);
  }

//Đăng xuất
  Future<void> signOut(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        // Kiểm tra nếu có userId, thực hiện hủy đăng ký khỏi topic
        if (user.uid.isNotEmpty) {
          print("Đang hủy đăng ký khỏi topic allUsers...");
          await _firebaseMessaging.unsubscribeFromTopic('allUsers');
          print('Đã hủy đăng ký khỏi topic allUsers');
        }

        // Xóa token FCM trong Firebase Realtime Database
        DatabaseReference ref =
            FirebaseDatabase.instance.ref('users/${user.uid}');
        await ref.update({'userDeviceToken': null}); // Xóa token FCM
        print('Token FCM đã được xóa khỏi Firebase Realtime Database');

        // Đăng xuất khỏi Firebase Auth
        await _auth.signOut();
        errorMessage = "Đăng xuất thành công!";

        // Cập nhật trạng thái đăng xuất (nếu cần thiết)

        // Chuyển hướng về màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        errorMessage = "Không có người dùng để đăng xuất!";
      }
    } catch (e) {
      errorMessage = "Lỗi đăng xuất: $e";
      print('Lỗi đăng xuất: $e');
    }

    ThongBao(context, errorMessage);
  }
}
