import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import '../cart/Product_cart_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(); // Điều khiển PageView
  int _currentPage = 0; // Biến lưu trang hiện tại
  final List<String> _banners = [
    'https://img.pikbest.com/templates/20240902/food-sale-promotion-banner-for-supermarket-restaurants_10785489.jpg!w700wp',
    'https://www.bigc.vn/files/banners/2021/may-21/resize-template-black-red-banner-web-go-2.jpg',
    'https://img.freepik.com/free-vector/hand-drawn-fast-food-sale-banner_23-2150970571.jpg',
    'https://channel.mediacdn.vn/2021/4/27/photo-1-1619536488295922378403.jpg',
  ]; // Danh sách URL của banner

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      // Cập nhật trang hiện tại khi PageView thay đổi
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    // Tạo Timer để tự động chuyển trang
    Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Quay lại trang đầu
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 950),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Icon(Icons.location_on, color: Colors.blue),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text("Giao tới", style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text("07.BT8, Foresa 6B, Nam từ Liêm, Hà Nội", style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileDetailScreen()), // Điều hướng đến ProfileDetail
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()), // Điều hướng đến CartScreen
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              TextField(
                decoration: InputDecoration(
                  hintText: 'Bạn muốn tìm gì?',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Danh mục sản phẩm với 2 hàng ngang
              SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildCategoryItem("Trái cây", "assets/images/category/vegetable.png"),
                          const SizedBox(width: 16),
                          _buildCategoryItem("Hoa quả", "assets/images/category/fruit.png"),
                          const SizedBox(width: 16),
                          _buildCategoryItem("Thực phẩm", "assets/images/category/basket.png"),
                          const SizedBox(width: 16),
                          _buildCategoryItem("Bánh", "assets/images/category/milk.png"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCategoryItem("Đồ uống", "assets/images/category/milk.png"),
                          const SizedBox(width: 16),
                          _buildCategoryItem("Rau củ", "assets/images/category/vegetable.png"),
                          const SizedBox(width: 16),
                          _buildCategoryItem("Đồ dùng", "assets/images/category/fruit.png"),
                          const SizedBox(width: 16),
                          _buildCategoryItem("Thịt", "assets/images/category/basket.png"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Banner quảng cáo với PageView
              SizedBox(
                height: 120,
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

              // Thanh trượt indicator
              const SizedBox(height: 5), // Thêm khoảng cách 5dp
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4, // Thay đổi chiều cao thanh trượt
                    width: _currentPage == index ? 10 : 4, // Thay đổi chiều rộng của thanh trượt
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Sản phẩm gần đây
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Sản phẩm gần đây", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Xem tất cả"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildProductItem("Hoa quả", "Táo", "assets/images/apple.png"),
                    _buildProductItem("Đồ uống", "Sữa tươi", "assets/images/milk.png"),
                    // Thêm sản phẩm khác nếu cần
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Giải phóng PageController khi không còn sử dụng
    super.dispose();
  }

  // Hàm xây dựng một mục danh mục
  Widget _buildCategoryItem(String title, String imagePath) {
    return Container(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 48, // Đặt chiều rộng cho hình ảnh
            height: 48, // Đặt chiều cao cho hình ảnh
            decoration: BoxDecoration(
              // Bỏ borderRadius để không có bo tròn
              image: DecorationImage(
                image: AssetImage(imagePath), // Sử dụng hình ảnh từ assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Hàm xây dựng một mục sản phẩm
  Widget _buildProductItem(String category, String name, String imageUrl) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}