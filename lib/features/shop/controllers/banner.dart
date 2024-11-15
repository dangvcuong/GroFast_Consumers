// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diacritic/diacritic.dart';
import 'dart:async';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _banners = [
    'https://img.pikbest.com/templates/20240902/food-sale-promotion-banner-for-supermarket-restaurants_10785489.jpg!w700wp',
    'https://www.bigc.vn/files/banners/2021/may-21/resize-template-black-red-banner-web-go-2.jpg',
    'https://img.freepik.com/free-vector/hand-drawn-fast-food-sale-banner_23-2150970571.jpg',
    'https://channel.mediacdn.vn/2021/4/27/photo-1-1619536488295922378403.jpg',
  ];

  Timer? _timer; // Đảm bảo chỉ có một Timer duy nhất

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (_timer != null) {
      _timer!.cancel(); // Hủy timer cũ nếu có
    }

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        // Nếu đã ở trang cuối cùng, quay lại trang đầu tiên và cuộn mượt mà
        _currentPage = 0;
      }

      // Chuyển trang tiếp theo với hiệu ứng mượt mà
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500), // Thời gian chuyển trang
        curve: Curves.easeInOut, // Sử dụng curve cho hiệu ứng mượt mà
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Hủy timer khi dispose để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 200, // Chiều cao của banner
        child: PageView.builder(
          controller: _pageController,
          itemCount: _banners.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(_banners[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
