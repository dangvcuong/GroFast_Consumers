// ignore_for_file: camel_case_types, unused_element, unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/profile/profile_management.dart';
import 'package:permission_handler/permission_handler.dart';

class Btn_Navigatin extends StatefulWidget {
  const Btn_Navigatin({super.key});

  @override
  State<Btn_Navigatin> createState() => _Btn_NavigatinState();
}

class _Btn_NavigatinState extends State<Btn_Navigatin> {
  int _currentIndex = 2;
  String _appBarTitle = 'Home';

  final List<Widget> _screens = [
    const Center(child: Text('Home Screen')),
    const Center(child: Text('Search Screen')),
    const Center(child: ProFile_Management()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Cập nhật chỉ số tab hiện tại
      // Cập nhật tiêu đề dựa trên chỉ số
      if (index == 0) {
        _appBarTitle = 'Home';
      } else if (index == 1) {
        _appBarTitle = 'Search';
      } else if (index == 2) {
        _appBarTitle = 'Profile';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Yêu cầu quyền khi khởi động ứng dụng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: Text(_appBarTitle),
      ),
      body: _screens[_currentIndex], // Hiển thị màn hình tương ứng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Chỉ số của tab đang được chọn
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Cập nhật chỉ số khi tab được chọn
            _onItemTapped(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}