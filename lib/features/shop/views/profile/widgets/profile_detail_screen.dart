// ignore_for_file: unused_import, non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/sign_up_controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/features/shop/views/profile/profile_management.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/Delete_User.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/Update_Name.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/Update_PassWord.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/Update_Sdt.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final ShowDialogs showDialog = ShowDialogs();
  final SignUp__Controller signUp__Controller = SignUp__Controller();
  String? ngay;
  @override
  void initState() {
    super.initState();
    getUserInfo();

    // Gọi hàm để lấy thông tin người dùng
  }

  Future<void> getUserInfo() async {
    currentUser = await userController.getUserInfo();
    String ngayTaoString = currentUser!.dateCreated; // Giả sử đây là chuỗi ngày
    DateTime ngayTaoDateTime = DateTime.parse(ngayTaoString);
    ngay = DateFormat(
      'EEEE, d-M-y',
    ).format(ngayTaoDateTime);
    setState(() {}); // Cập nhật lại giao diện sau khi có dữ liệu
  }

  Future<void> _pickImage(String userId) async {
    String? imagePath;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path; // Cập nhật đường dẫn ảnh
      });
      // Bạn có thể gọi hàm để cập nhật vào Realtime Database ở đây
      await updateImage(userId, imagePath!);
    }
  }

  Future<void> updateImage(String userId, String imageUrl) async {
    String? errorMessage;
    try {
      await FirebaseDatabase.instance
          .ref('users/$userId') // Đường dẫn đến user trong Realtime Database
          .update({'image': imageUrl}); // Cập nhật trường 'image' với URL ảnh
      errorMessage = "Cập nhật ảnh thành công!";
      await getUserInfo();
      setState(() {
        // Cập nhật trạng thái, nếu cần thiết
      });
    } catch (e) {
      errorMessage = "Lỗi khi cập nhật ảnh: $e";
    }
    signUp__Controller.ThongBao(context, errorMessage);
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
        title: const Text("Hồ sơ"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  SizedBox(
                    width: 100, // Chiều rộng mong muốn
                    height: 100, // Chiều cao mong muốn
                    child: currentUser != null && currentUser!.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                100), // Bo góc với bán kính 20
                            child: Image.file(
                              File(currentUser!
                                  .image), // Sử dụng FileImage để hiển thị ảnh từ đường dẫn cục bộ
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ))
                        : const Icon(Icons.account_circle, size: 100),
                  ),
                  gapH12,
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _pickImage(currentUser!.id);
                      });
                    },
                    child: Text(
                      'Đổi ảnh hồ sơ',
                      style: HAppStyle.heading5Style
                          .copyWith(color: HAppColor.hBluePrimaryColor),
                    ),
                  )
                ])),
            gapH24,
            Container(
              padding: const EdgeInsets.all(hAppDefaultPadding),
              // width: HAppSize.deviceWidth,
              decoration: BoxDecoration(
                  color: HAppColor.hWhiteColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tên",
                        style: HAppStyle.paragraph2Regular,
                        textAlign: TextAlign.right,
                      ),
                      GestureDetector(
                        onTap: () async => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Updata_Name())),
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 200, // Giới hạn chiều rộng
                              child: Text(
                                currentUser != null ? currentUser!.name : "",
                                style: HAppStyle.paragraph2Bold.copyWith(
                                    color: HAppColor.hGreyColorShade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            gapW20,
                            const Icon(Icons.arrow_forward_ios, size: 15),
                          ],
                        ),
                      )
                    ],
                  ),
                  gapH6,
                  Divider(
                    color: HAppColor.hGreyColorShade300,
                  ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Id",
                        style: HAppStyle.paragraph2Regular,
                        textAlign: TextAlign.right,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 200, // Giới hạn chiều rộng
                            child: Text(
                              currentUser != null ? currentUser!.id : "",
                              style: HAppStyle.paragraph2Bold.copyWith(
                                  color: HAppColor.hGreyColorShade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          gapW20,
                          GestureDetector(
                            onTap: () => userController.copyToClipboard(
                                currentUser!.id, context),
                            child: const Icon(
                              Icons.copy,
                              size: 15,
                            ),
                            // Gọi hàm copy
                          ),
                        ],
                      )
                    ],
                  ),
                  gapH6,
                  Divider(
                    color: HAppColor.hGreyColorShade300,
                  ),
                  gapH6,
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Updata_Sdt())),
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Số điện thoại",
                          style: HAppStyle.paragraph2Regular,
                          textAlign: TextAlign.right,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 200, // Giới hạn chiều rộng
                              child: Text(
                                currentUser != null
                                    ? currentUser!.phoneNumber
                                    : "",
                                style: HAppStyle.paragraph2Bold.copyWith(
                                    color: HAppColor.hGreyColorShade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            gapW20,
                            const Icon(Icons.arrow_forward_ios, size: 15),
                          ],
                        )
                      ],
                    ),
                  ),
                  gapH6,
                  Divider(
                    color: HAppColor.hGreyColorShade300,
                  ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Email",
                        style: HAppStyle.paragraph2Regular,
                        textAlign: TextAlign.right,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 200, // Giới hạn chiều rộng
                            child: Text(
                              currentUser != null ? currentUser!.email : "",
                              style: HAppStyle.paragraph2Bold.copyWith(
                                  color: HAppColor.hGreyColorShade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          gapW20,
                        ],
                      )
                    ],
                  ),
                  gapH6,
                  Divider(
                    color: HAppColor.hGreyColorShade300,
                  ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ngày tạo",
                        style: HAppStyle.paragraph2Regular,
                        textAlign: TextAlign.right,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 200, // Giới hạn chiều rộng
                            child: Text(
                              "$ngay",
                              style: HAppStyle.paragraph2Bold.copyWith(
                                  color: HAppColor.hGreyColorShade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          gapW20,
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            gapH40,
            GestureDetector(
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Updata_PassWord())),
              },
              child: Container(
                padding: const EdgeInsets.all(hAppDefaultPadding),
                // width: HAppSize.deviceWidth,
                decoration: BoxDecoration(
                    color: HAppColor.hWhiteColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Đổi mật khẩu",
                          style: HAppStyle.paragraph2Regular,
                          textAlign: TextAlign.right,
                        ),
                        Row(
                          children: [
                            gapW20,
                            Icon(Icons.arrow_forward_ios, size: 15),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            gapH20,
            GestureDetector(
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Delete_User())),
              },
              child: Container(
                padding: const EdgeInsets.all(hAppDefaultPadding),
                // width: HAppSize.deviceWidth,
                decoration: BoxDecoration(
                    color: HAppColor.hWhiteColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Xóa tài khoản",
                          style: HAppStyle.paragraph2Regular,
                          textAlign: TextAlign.right,
                        ),
                        Row(
                          children: [
                            gapW20,
                            Icon(Icons.arrow_forward_ios, size: 15),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
