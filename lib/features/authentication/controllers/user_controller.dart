// ignore_for_file: unused_element, use_build_context_synchronously, unused_import, non_constant_identifier_names, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grofast_consumers/features/authentication/controllers/sign_up_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/validates/validate_Dk.dart';
import 'package:image_picker/image_picker.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('users');
  final SignUp__Controller signUp__Controller = SignUp__Controller();
  final valideteDK validateSignup = valideteDK();
  final ProfileDetailScreen profile = const ProfileDetailScreen();

  Future<UserModel?> getUserInfo() async {
    User? user = _auth.currentUser; // Lấy người dùng hiện tại

    if (user != null) {
      try {
        // Truy cập vào dữ liệu người dùng trong Realtime Database
        DatabaseEvent event = await _databaseRef.child(user.uid).once();

        if (event.snapshot.value != null) {
          final userData = event.snapshot.value as Map<Object?, Object?>;
          print("User Data: $userData"); // Kiểm tra dữ liệu trả về

          // Chuyển đổi userData sang Map<String, dynamic>
          Map<String, dynamic> userMap = userData
              .map((key, value) => MapEntry(key.toString(), value as dynamic));

          try {
            return UserModel.fromJson(userMap); // Gọi phương thức fromJson
          } catch (e) {
            print("Error converting user data to UserModel: $e");
            return null; // Xử lý lỗi
          }
        } else {
          print("User data not found");
          return null; // Không tìm thấy dữ liệu người dùng
        }
      } catch (e) {
        print("Error fetching user info: $e");
        return null; // Xử lý lỗi
      }
    } else {
      print("No user is currently logged in.");
      return null; // Không có người dùng hiện tại
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      String downloadUrl =
          await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error getting image URL: $e"); // Ghi lại lỗi
      return ""; // Trả về chuỗi rỗng nếu có lỗi
    }
  }

  void copyToClipboard(String errorMessage, BuildContext context) {
    Clipboard.setData(ClipboardData(text: errorMessage)).then((_) {
      // Có thể hiển thị thông báo cho người dùng
      signUp__Controller.ThongBao(context, "Đã copy ID: $errorMessage");
    });
  }

  Future<void> updateUserName(
      String userId, String newName, BuildContext context) async {
    String? errorMessage;
    try {
      await FirebaseDatabase.instance
          .ref('users/$userId') // Đường dẫn đến user trong Realtime Database
          .update({'name': newName}); // Cập nhật chỉ field 'name'
      errorMessage = "Đổi tên thành công";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const ProfileDetailScreen()), // ProfileScreen là màn hình đích
      );
    } catch (e) {
      print("Error updating user name: $e");
    }
    signUp__Controller.ThongBao(context, errorMessage!);
  }

  Future<void> updateSDT(
      String userId, String newPhoneNumber, BuildContext context) async {
    String? errorMessage;
    try {
      await FirebaseDatabase.instance
          .ref('users/$userId') // Đường dẫn đến user trong Realtime Database
          .update({'phoneNumber': newPhoneNumber}); // Cập nhật chỉ field 'name'
      errorMessage = "Cập nhật số điện thoại thành công";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const ProfileDetailScreen()), // ProfileScreen là màn hình đích
      );
    } catch (e) {
      print("Error updating user name: $e");
    }
    signUp__Controller.ThongBao(context, errorMessage!);
  }

  Future<void> updatePassword(String oldPassword, String newPassword,
      String nhaplaiMKmoi, BuildContext context) async {
    User? user = _auth.currentUser;
    String? errorMessage;
    // Kiểm tra xem người dùng có đăng nhập không
    if (user != null) {
      // Kiểm tra xem mật khẩu mới có giống mật khẩu nhập lại không
      if (newPassword != nhaplaiMKmoi) {
        errorMessage = "Mật khẩu mới và mật khẩu nhập lại không khớp.";
      }

      // Kiểm tra độ dài mật khẩu mới
      if (newPassword.length < 6) {
        errorMessage = "Mật khẩu mới phải có ít nhất 6 ký tự.";
      }

      // Để đổi mật khẩu, bạn cần xác thực mật khẩu cũ
      try {
        // Đăng nhập tạm thời với mật khẩu cũ
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: user.email!, password: oldPassword),
        );

        // Đổi mật khẩu
        await user.updatePassword(newPassword);
        errorMessage = "Đổi mật khẩu thành công!";
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ProfileDetailScreen()), // ProfileScreen là màn hình đích
        );
      } catch (e) {
        // Kiểm tra lỗi khi xác thực mật khẩu cũ
        if (e is FirebaseAuthException && e.code == 'wrong-password') {
          errorMessage =
              "Mật khẩu cũ không chính xác."; // Thông báo cho người dùng
        } else {
          errorMessage = "Lỗi khi đổi mật khẩu";
          // Ném lỗi lên trên để xử lý tại nơi gọi
        }
      }
    } else {
      errorMessage = "Người dùng chưa đăng nhập.";
    }
    signUp__Controller.ThongBao(context, errorMessage);
  }

  Future<void> deleteUser(String password, BuildContext context) async {
    User? user = _auth.currentUser;
    String? errorMessage;
    if (user != null) {
      try {
        // Xác thực lại người dùng với mật khẩu
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: password, // Mật khẩu người dùng nhập vào
          ),
        );

        // Xóa thông tin người dùng từ Firestore
        await FirebaseDatabase.instance.ref('users/${user.uid}').remove();

        // Xóa tài khoản người dùng
        await user.delete();
        errorMessage = "Tài khoản đã được xóa thành công!";
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          errorMessage = "Mật khẩu không đúng.";
        } else if (e.code == 'requires-recent-login') {
          errorMessage = "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
        } else {
          errorMessage = "Lỗi xác thực lại: ";
        }
      } catch (e) {
        errorMessage = "Lỗi khi xóa tài khoản: ";
      }
    } else {
      errorMessage = "Người dùng chưa đăng nhập.";
    }
    signUp__Controller.ThongBao(context, errorMessage);
  }

  Future<void> XoaUsser(String password) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Xác thực lại người dùng với mật khẩu
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: password, // Mật khẩu người dùng nhập vào
          ),
        );

        // Xóa thông tin người dùng từ Firestore
        await FirebaseDatabase.instance.ref('users/${user.uid}').remove();

        // Xóa tài khoản người dùng
        await user.delete();
        print("Tài khoản đã được hủy thành công!");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          print("Mật khẩu không đúng.");
        } else if (e.code == 'requires-recent-login') {
          print("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
        } else {
          print("Lỗi xác thực lại: ");
        }
      } catch (e) {
        print("Lỗi khi hủy tài khoản: ");
      }
    } else {
      print("Người dùng chưa đăng nhập.");
    }
  }
}
