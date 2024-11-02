// ignore_for_file: file_names, unnecessary_import, use_build_context_synchronously, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/features/authentication/controllers/addres_Controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:provider/provider.dart';


import '../shop/views/favorites/providers/favorites_provider.dart';

class ShowDialogs {
  final UserController userController = UserController();
  final AddRessController addRessController = AddRessController();
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Xóa tài khoản
  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String password) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa tài khoản'),
          content:
          const Text('Bạn có chắc chắn muốn xóa tài khoản của mình không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () async {
                try {
                  await userController.deleteUser(password, context);
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Đăng xuất
  Future<void> Log_out(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất tài khoản'),
          content: const Text(
              'Bạn có chắc chắn muốn đăng xuất tài khoản của mình không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Xóa sản phẩm yêu thích
  Future<void> showDeleteFavoriteDialog(
      BuildContext context, Product product) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm yêu thích'),
          content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này khỏi danh sách yêu thích không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () async {
                try {
                  final favoritesProvider =
                  Provider.of<FavoritesProvider>(context, listen: false);
                  await favoritesProvider.removeFavorite(product);
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
