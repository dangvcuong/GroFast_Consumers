// ignore_for_file: camel_case_types, unused_element, unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/favorites/favorite_products_screen.dart';
import 'package:grofast_consumers/features/shop/views/home/home_screen.dart';
import 'package:grofast_consumers/features/shop/views/profile/profile_management.dart';
import 'package:grofast_consumers/features/shop/views/search/search_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class Btn_Navigatin extends StatefulWidget {
  const Btn_Navigatin({super.key});

  @override
  State<Btn_Navigatin> createState() => _Btn_NavigatinState();
}

class _Btn_NavigatinState extends State<Btn_Navigatin> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: HomeScreen()),
    const Center(child: SearchScreen()),
    const Center(child: FavoriteProductsScreen()),
    const Center(child: ProFile_Management()),
  ];

  @override
  void initState() {
    super.initState();
    // Yêu cầu quyền khi khởi động ứng dụng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0), // Thêm khoảng cách ở trên cùng
        child: _screens[_currentIndex], // Hiển thị màn hình tương ứng
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Chỉ số của tab đang được chọn
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Cập nhật chỉ số khi tab được chọn
          });
        },
        selectedItemColor: Colors.blue, // Màu sắc khi icon được chọn
        unselectedItemColor: Colors.black, // Màu sắc khi icon không được chọn
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '', // Có thể để trống nếu không muốn hiển thị
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '', // Có thể để trống nếu không muốn hiển thị
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '', // Có thể để trống nếu không muốn hiển thị
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '', // Có thể để trống nếu không muốn hiển thị
          ),
        ],
      ),
    );
  }
}
