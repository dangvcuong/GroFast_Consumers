// ignore_for_file: file_names, unnecessary_import, use_build_context_synchronously, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/features/authentication/controllers/addres_Controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';

class ShowDialogs {
  final UserController userController = UserController();
  final AddRessController addRessController = AddRessController();
  User? currentUser = FirebaseAuth.instance.currentUser;
  //Xóa Tài khoản
  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String password) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Ngăn đóng dialog bằng cách chạm bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa tài khoản'),
          content:
              const Text('Bạn có chắc chắn muốn xóa tài khoản của mình không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () async {
                // Gọi phương thức xóa tài khoản ở đây
                try {
                  await userController.deleteUser(password, context);
                  Navigator.of(context).pop(); // Đóng dialog
                } catch (e) {
                  Navigator.of(context).pop(); // Đóng dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

// Đang xuất
  Future<void> Log_out(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Ngăn đóng dialog bằng cách chạm bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất tài khoản'),
          content: const Text(
              'Bạn có chắc chắn muốn đăng xuất tài khoản của mình không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () async {
                // Gọi phương thức xóa tài khoản ở đây
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop(); // Đóng dialog
                } catch (e) {
                  Navigator.of(context).pop(); // Đóng dialog
                }
              },
            ),
          ],
        );
      },
    );
  }
}
