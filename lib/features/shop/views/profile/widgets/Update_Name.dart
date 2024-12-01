// ignore_for_file: camel_case_types, unused_import, unnecessary_import, non_constant_identifier_names, file_names, avoid_print, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/shop/models/order_model.dart';
import 'package:grofast_consumers/features/shop/views/profile/profile_management.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

class Updata_Name extends StatefulWidget {
  const Updata_Name({super.key});

  @override
  State<Updata_Name> createState() => _Updata_NameState();
}

class _Updata_NameState extends State<Updata_Name> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final TextEditingController update_nameController = TextEditingController();
  String? errorMessage;
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
        title: const Text('Đổi tên',
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
            Text("Hãy nhập đầy đủ các thông tin dưới đây để tiến hành đổi tên.",
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600)),
            gapH16,
            TextField(
              keyboardType: TextInputType.name,
              controller: update_nameController,
              decoration: InputDecoration(
                labelText: "Nhập tên của bạn", // Chữ ghi chú
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bo tròn góc
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                errorMessage ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            gapH20,
            ElevatedButton(
              onPressed: () async {
                if (update_nameController.text.isEmpty) {
                  errorMessage = "Vui lòng không để trống!";
                } else if (update_nameController.text.length < 2) {
                  errorMessage = "Tên phải từ 2 kí tự";
                } else {
                  if (currentUser != null) {
                    // Null check for currentUser
                    await userController.updateUserName(currentUser!.id,
                        update_nameController.value.text, context);
                    await _getUserInfo();
                  } else {
                    errorMessage = "Không tìm thấy thông tin người dùng.";
                  }
                }
                setState(() {
                  update_nameController.text = "";
                }); // Update the UI to reflect the error message
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: const Text("Đổi",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
