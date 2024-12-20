// ignore_for_file: file_names, unused_import, unnecessary_import, non_constant_identifier_names, camel_case_types, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

class Delete_User extends StatefulWidget {
  const Delete_User({super.key});

  @override
  State<Delete_User> createState() => _Delete_UserState();
}

class _Delete_UserState extends State<Delete_User> {
  bool _isPasswordVisible = false;
  final TextEditingController passWord_Controller = TextEditingController();
  final UserController user_Controller = UserController();
  final ShowDialogs showDiaLog = ShowDialogs();
  String? errorMessagePass;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xóa tài khoản',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
                "Bạn hãy nhập mật khẩu để xác thực trước khi xóa tài khoản của bạn.",
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600)),
            gapH16,
            TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: passWord_Controller,
              obscureText: !_isPasswordVisible, // Điều khiển hiển thị mật khẩu
              decoration: InputDecoration(
                labelText: "Nhập mật khẩu",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                errorMessagePass ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            gapH20,
            ElevatedButton(
              onPressed: () async {
                if (passWord_Controller.text.isEmpty) {
                  setState(() {
                    errorMessagePass = "Vui lòng không để trống";
                  });
                } else {
                  try {
                    // Hiển thị dialog xác nhận
                    await showDiaLog.showDeleteConfirmationDialog(
                        context,
                        passWord_Controller
                            .text); // Sau khi xác thực, xóa tài khoản
                  } catch (e) {
                    setState(() {
                      errorMessagePass = "Lỗi khi xóa tài khoản: $e";
                    });
                    print("Lỗi khi xóa tài khoản: $e");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: const Text("Xác thực",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
