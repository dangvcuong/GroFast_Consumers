// ignore: unused_import
// ignore_for_file: unnecessary_import, unused_import, camel_case_types, duplicate_ignore, file_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/profile_Management/profile_management.dart';
import 'package:grofast_consumers/features/profile_Management/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/theme/app_style.dart';

class Updata_PassWord extends StatefulWidget {
  const Updata_PassWord({super.key});

  @override
  State<Updata_PassWord> createState() => _Updata_PassWord();
}

class _Updata_PassWord extends State<Updata_PassWord> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final TextEditingController update_PassWordController =
      TextEditingController();
  final TextEditingController ord_PassWordController = TextEditingController();
  final TextEditingController nhaplai_update_PassWordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordUpdateVisible = false;
  bool _isPasswordUpdateNhapLaiVisible = false;
  @override
  void initState() {
    super.initState();
    _getUserInfo(); // Gọi hàm để lấy thông tin người dùng
  }

  Future<void> _getUserInfo() async {
    currentUser = await userController.getUserInfo();
    setState(() {}); // Cập nhật lại giao diện sau khi có dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                )),
          ),
        ),
        title: const Text("Đổi mất khẩu"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
                "Hãy nhập đầy đủ các thông tin dưới đây để tiến hành đổi mật khẩu.",
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600)),
            gapH16,
            TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: ord_PassWordController,
              obscureText: !_isPasswordVisible, // Điều khiển hiển thị mật khẩu
              decoration: InputDecoration(
                labelText: "Nhập mật khẩu cũ",
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
            gapH20,
            TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: update_PassWordController,
              obscureText:
                  !_isPasswordUpdateVisible, // Điều khiển hiển thị mật khẩu
              decoration: InputDecoration(
                labelText: "Nhập mới mật khẩu",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordUpdateVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordUpdateVisible = !_isPasswordUpdateVisible;
                    });
                  },
                ),
              ),
            ),
            gapH20,
            TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: nhaplai_update_PassWordController,
              obscureText:
                  !_isPasswordUpdateNhapLaiVisible, // Điều khiển hiển thị mật khẩu
              decoration: InputDecoration(
                labelText: "Nhập lại mật khẩu mới",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordUpdateNhapLaiVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordUpdateNhapLaiVisible =
                          !_isPasswordUpdateNhapLaiVisible;
                    });
                  },
                ),
              ),
            ),
            gapH20,
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userController.updatePassword(
                      ord_PassWordController.text,
                      update_PassWordController.text,
                      nhaplai_update_PassWordController.text,
                      context);
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: const Text("Xác nhận",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
