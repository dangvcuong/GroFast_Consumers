// ignore: unused_import
// ignore_for_file: unnecessary_import, unused_import, camel_case_types, duplicate_ignore, file_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features//shop/views/profile/profile_management.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';
import 'package:grofast_consumers/validates/validate_Dk.dart';

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
  String? errorMessagePass;
  String? errorMessagePassNew;
  String? errorMessagePassConfic;

  @override
  void initState() {
    super.initState();
    _getUserInfo(); // Gọi hàm để lấy thông tin người dùng
  }

  Future<void> _getUserInfo() async {
    currentUser = await userController.getUserInfo();
    setState(() {}); // Cập nhật lại giao diện sau khi có dữ liệu
  }

  Future<bool> check() async {
    bool check = true;
    if (ord_PassWordController.text.isEmpty) {
      errorMessagePass = "Vui lòng không để trống";
      check = false;
    } else {
      errorMessagePass = "";
      check = true;
    }

    if (update_PassWordController.text.isEmpty) {
      errorMessagePassNew = "Mật khẩu không được để trống";
      check = false;
    } else if (update_PassWordController.text.length < 6) {
      errorMessagePassNew = "Mật khẩu phải có ít nhất 6 ký tự";
      check = false;
    } else if (!RegExp(r'(?=.*[A-Z])')
        .hasMatch(update_PassWordController.text)) {
      errorMessagePassNew = "Mật khẩu phải có ít nhất một chữ in hoa";
      check = false;
    } else if (!RegExp(r'(?=.*\d)').hasMatch(update_PassWordController.text)) {
      errorMessagePassNew = "Mật khẩu phải có ít nhất một chữ số";
      check = false;
    } else if (!RegExp(r'(?=.*[@$!%*?&])')
        .hasMatch(update_PassWordController.text)) {
      errorMessagePassNew = "Mật khẩu phải có ít nhất một ký tự đặc biệt";
      check = false;
    } else {
      errorMessagePassNew = ""; // Không có lỗi
      check = true;
    }

    if (nhaplai_update_PassWordController.text.isEmpty) {
      errorMessagePassConfic = "Nhập lại mật khẩu không được để trống";
      check = false;
    } else if (nhaplai_update_PassWordController.text !=
        update_PassWordController.text) {
      errorMessagePassConfic = "Nhập lại mật khẩu không đúng";
      check = false;
    } else {
      errorMessagePassConfic = ""; // Không có lỗi
      check = true;
    }
    return check;
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
            SizedBox(
              width: double.infinity,
              child: Text(
                errorMessagePass ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 10),
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
            SizedBox(
              width: double.infinity,
              child: Text(
                errorMessagePassNew ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 10),
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
            SizedBox(
              width: double.infinity,
              child: Text(
                errorMessagePassConfic ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            gapH20,
            ElevatedButton(
              onPressed: () async {
                bool isValid = await check(); // Await the result of check()
                if (isValid) {
                  setState(() {
                    // Cập nhật thông báo khi xác nhận thành công
                    userController.updatePassword(
                      ord_PassWordController.text,
                      update_PassWordController.text,
                      nhaplai_update_PassWordController.text,
                      context,
                    );
                    update_PassWordController.text = "";
                    ord_PassWordController.text = "";
                    nhaplai_update_PassWordController.text = "";
                  });
                } else {
                  setState(() {
                    // Cập nhật thông báo khi có lỗi
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(double.maxFinite, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: const Text("Xác nhận",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
