// ignore_for_file: file_names, avoid_print, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('users');
  Future<UserModel?> getUserInfo(String userId) async {
    User? user = _auth.currentUser; // Lấy người dùng hiện tại

    if (user != null) {
      try {
        // Truy cập vào dữ liệu người dùng trong Realtime Database
        DatabaseEvent event = await _databaseRef.child(user.uid).once();

        if (event.snapshot.value != null) {
          final userData = event.snapshot.value as Map<Object?, Object?>;
          // ignore: avoid_print
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

  void setUser(UserModel user) {
    _currentUser = user; // Cập nhật dữ liệu người dùng
    notifyListeners(); // Thông báo cho các widget lắng nghe
  }

  void clearUser() {
    _currentUser = null; // Đặt lại dữ liệu người dùng
    notifyListeners(); // Thông báo cho các widget lắng nghe
  }
}
