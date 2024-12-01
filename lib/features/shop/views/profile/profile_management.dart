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
import 'package:grofast_consumers/features/shop/views/profile/widgets/WalletTopUpScreen.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/features/shop/views/voucher/voucher_screen.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
  bool isBalanceVisible = false; // Trạng thái hiển thị số dư
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  // Tạo đối tượng user mẫu
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

  void openPaymentLink() async {
    const url = 'https://buy.stripe.com/test_28o8ykaIO84n8kU4gh';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Không thể mở liên kết $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                    child: currentUser != null && currentUser!.image.isNotEmpty
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
                        : Icon(Icons.account_circle, size: 100),
                  ),
                  gapW10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser != null ? currentUser!.name : "",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      gapH4,
                      Text(
                        'Xem hồ sơ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ],
              ),
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
                      gapH20,
                      const Text(
                        'Tài khoản',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      gapH20,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isBalanceVisible =
                                        !isBalanceVisible; // Đổi trạng thái
                                  });
                                },
                                child: Icon(
                                  isBalanceVisible
                                      ? Icons.visibility
                                      : Icons
                                          .visibility_off, // Biểu tượng thay đổi
                                  color: Colors.black, // Màu cho icon
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                "Số dư ví: ",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                isBalanceVisible
                                    ? formatter.format(currentUser!.balance)
                                    : '***', // Hiển thị số dư hoặc ***
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              // Khoảng cách giữa text và icon
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WalletTopUpScreen(),
                                ),
                              ).then((_) {
                                _getUserInfo();
                              });
                            },
                            child: Text(
                              'Nạp tiền',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Colors.red, // Gạch chân văn bản
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                      gapH10,
                      const Divider(thickness: 1, color: Colors.grey),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderScreen(),
                            ),
                          ).then((_) {
                            _getUserInfo();
                          });
                        },
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.shopping_bag,
                            color: Colors.blue, // Màu cho icon
                          ),
                          title: Text(
                            'Đơn hàng',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            // Màu cho icon
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
                            color: Colors.orange, // Màu cho icon
                          ),
                          title: Text(
                            'Giỏ hàng',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            // Màu cho icon
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
                            color: Colors.green, // Màu cho icon
                          ),
                          title: Text(
                            'Địa chỉ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            // Màu cho icon
                          ),
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen()),
                          );
                        },
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.message,
                            color: Colors.purple, // Màu cho icon
                          ),
                          title: Text(
                            'Tin nhắn',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            // Màu cho icon
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
                            color: Colors.red, // Màu cho icon
                          ),
                          title: Text(
                            'Mã ưu đãi',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            // Màu cho icon
                          ),
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      InkWell(
                        onTap: () async {
                          await showDialog.Log_out(context);
                        },
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.logout,
                            color: Colors.red, // Màu cho icon
                          ),
                          title: Text(
                            'Đăng xuất',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            // Màu cho icon
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 1, // Độ dày của gạch ngang
                        color: Colors.grey, // Màu sắc của gạch ngang
                        height:
                            1, // Khoảng cách của gạch ngang so với các thành phần xung quanh
                      ),
                    ],
                  )),
            ),
    );
  }
}
