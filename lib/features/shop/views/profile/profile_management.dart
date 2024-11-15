// ignore_for_file: camel_case_types, prefer_const_constructors

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
import 'package:grofast_consumers/features/shop/views/chatbot/chat_screen.dart';
import 'package:grofast_consumers/features/authentication/sigup/widgets/complete_create_account_screen.dart';
import 'package:grofast_consumers/features/shop/views/cart/Product_cart_item.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/features/shop/views/voucher/voucher_screen.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

import '../oder/oder_screen.dart';

class ProFile_Management extends StatefulWidget {
  const ProFile_Management({super.key});

  @override
  State<ProFile_Management> createState() => _ProFile_ManagementState();
}

class _ProFile_ManagementState extends State<ProFile_Management> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final ShowDialogs showDialog = ShowDialogs();
  bool isLoading = true; // Thêm biến trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    setState(() {
      isLoading = true;
    });
    currentUser = await userController.getUserInfo();
    setState(() {
      isLoading = false; // Dữ liệu đã tải xong
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'GroFast',
              style: HAppStyle.heading3Style,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: isLoading // Kiểm tra trạng thái tải dữ liệu
          ? const Center(
              child:
                  CircularProgressIndicator(), // Hiển thị vòng chờ khi đang tải
            )
          : SingleChildScrollView(
              child: Padding(
                padding: hAppDefaultPaddingLR,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileDetailScreen(),
                          ),
                        ).then((_) {
                          _getUserInfo();
                        });
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: currentUser != null &&
                                    currentUser!.image.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      currentUser!
                                          .image, // Sử dụng trực tiếp URL ảnh từ Realtime Database
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
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
                                style: HAppStyle.paragraph3Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    gapH20,
                    const Text(
                      'Tài khoản',
                      style: HAppStyle.heading4Style,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OrderScreen()),
                        );
                      },
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.shopping_bag,
                          color: Colors.grey,
                        ),
                        title: Text('Đơn hàng'),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        );
                      },
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                        ),
                        title: Text('Giỏ hàng'),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddressUser()),
                        );
                      },
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                        ),
                        title: Text('Địa chỉ'),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen()),
                        );
                      },
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.message,
                          color: Colors.pink,
                        ),
                        title: Text('Tin nhắn'),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoucherScreen(),
                          ),
                        );
                      },
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.local_offer,
                          color: Colors.red,
                        ),
                        title: Text('Mã ưu đãi'),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_add),
                      title: Text('Giới thiệu với bạn bè'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ),
                    ),
                    const Divider(
                      thickness: 1, // Độ dày của gạch ngang
                      color: Colors.grey, // Màu sắc của gạch ngang
                      height:
                          1, // Khoảng cách của gạch ngang so với các thành phần xung quanh
                    ),
                    gapH100,
                    Center(
                      child: GestureDetector(
                        onTap: () async {
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
                  ],
                ),
              ),
            ),
    );
  }
}
