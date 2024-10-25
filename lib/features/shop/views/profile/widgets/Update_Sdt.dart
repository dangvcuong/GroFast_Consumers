// ignore_for_file: unused_import, unnecessary_import, camel_case_types, non_constant_identifier_names, file_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/shop/views/profile/profile_management.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

class Updata_Sdt extends StatefulWidget {
  const Updata_Sdt({super.key});

  @override
  State<Updata_Sdt> createState() => _Updata_SdtState();
}

class _Updata_SdtState extends State<Updata_Sdt> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final TextEditingController update_sdtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserInfo(); // Gọi hàm để lấy thông tin người dùng
  }

  Future<void> _getUserInfo() async {
    currentUser = await userController.getUserInfo();
    setState(() {
      const ProfileDetailScreen();
      const ProFile_Management();
    }); // Cập nhật lại giao diện sau khi có dữ liệu
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
        title: const Text("Đổi số điện thoại"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Hãy nhập số điện thoại bạn muốn đôi.",
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600)),
            gapH16,
            TextField(
              keyboardType: TextInputType.phone,
              controller: update_sdtController,
              decoration: InputDecoration(
                labelText: "Nhập số điện thoại",
                hintText: currentUser?.phoneNumber ?? "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bo tròn góc
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto, // Chế độ nổi
              ),
            ),
            gapH20,
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userController.updateSDT(currentUser!.id,
                      update_sdtController.value.text, context);
                  print(update_sdtController.text);
                });
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
