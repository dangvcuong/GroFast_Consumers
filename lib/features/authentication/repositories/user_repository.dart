// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  static UserRepository get instance => _instance;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _dbRef.child(user.id).set(user.toJson());
    } catch (e) {
      print("Failed to save user record: $e");
      rethrow; // Bắt lỗi nếu có vấn đề khi lưu
    }
  }
}
