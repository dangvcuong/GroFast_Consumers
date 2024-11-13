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
    const Center(child: FavoriteProductsScreen()),
    const Center(child: ProFile_Management()),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 0), // Thêm khoảng cách ở trên cùng
        child: _screens[_currentIndex], // Hiển thị màn hình tương ứng
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex, // Chỉ số của tab đang được chọn
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Cập nhật chỉ số khi tab được chọn
          });
        },
        selectedItemColor: Colors.blue, // Màu sắc khi icon được chọn
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed, // Màu sắc khi icon không được chọn
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_outlined, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}
