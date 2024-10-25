// ignore_for_file: camel_case_types, unused_import, duplicate_ignore, avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/sign_up_controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';

// ignore: unused_import
import 'package:grofast_consumers/features/authentication/sigup/widgets/complete_create_account_screen.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

class ProFile_Management extends StatefulWidget {
  const ProFile_Management({super.key});

  @override
  State<ProFile_Management> createState() => _ProFile_ManagementState();
}

class _ProFile_ManagementState extends State<ProFile_Management> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final ShowDialogs showDialog = ShowDialogs();

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
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GroFast',
              style: HAppStyle.heading3Style,
            ),
            Container(
              width: 50, // Chiều rộng mong muốn của khung tròn
              height: 50, // Chiều cao mong muốn của khung tròn
              padding: const EdgeInsets.all(
                  5), // Điều chỉnh khoảng cách giữa ảnh và viền
              decoration: BoxDecoration(
                // Nền trắng
                shape: BoxShape.circle, // Bo tròn hoàn toàn
                border: Border.all(
                  color: Colors.black, // Viền đen
                  width: 1, // Độ dày của viền
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/icons/ShoppingCart.png",
                  fit: BoxFit.contain, // Đảm bảo ảnh nhỏ hơn và nằm giữa
                ),
              ),
            )
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: hAppDefaultPaddingLR,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileDetailScreen()));
              },
              child: Row(
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
                  gapW10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser != null ? currentUser!.name : "",
                        style: HAppStyle.heading4Style,
                      ),
                      gapH4,
                      Text(
                        'Xem hồ sơ',
                        style: HAppStyle.paragraph3Regular
                            .copyWith(color: HAppColor.hGreyColorShade600),
                      )
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  )
                ],
              ),
            ),
            gapH20,
            const Text(
              'Tài khoản',
              style: HAppStyle.heading4Style,
            ),
            GestureDetector(
              // onTap: () => Get.toNamed(HAppRoutes.listOrder),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                // leading: Icon(EvaIcons.shoppingBagOutline),
                title: Text('Đơn hàng'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
            GestureDetector(
              // onTap: () => Get.toNamed(HAppRoutes.cart),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                // leading: Icon(EvaIcons.shoppingCartOutline),
                title: Text('Giỏ hàng'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressUser()));
              },
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                // leading: Icon(EneftyIcons.location_outline),
                title: Text('Địa chỉ'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
            GestureDetector(
              // onTap: () => Get.to(AllChatScreen()),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                // leading: Icon(EvaIcons.messageSquareOutline),
                title: Text('Tin nhắn'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Get.to(const AllVoucherScreen());
              },
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                // leading: Icon(EvaIcons.pricetagsOutline),
                title: Text('Mã ưu đãi'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Get.to(const NotificationScreen());
              },
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                // leading: Icon(EvaIcons.bellOutline),
                title: Text('Thông báo'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              // leading: Icon(EvaIcons.externalLinkOutline),
              title: Text('Giới thiệu với bạn bè'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ),
            gapH40,
            Center(
              child: GestureDetector(
                onTap: () async {
                  // try {
                  //   await FirebaseAuth.instance.signOut();
                  //   // Thực hiện các hành động khác, như điều hướng về màn hình đăng nhập
                  // } catch (e) {
                  //   print("Error signing out: $e");
                  // }
                  await showDialog.Log_out(context);
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
