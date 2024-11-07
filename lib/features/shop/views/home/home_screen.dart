// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/home/widget/category_menu.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';

import '../cart/Product_cart_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref('products');

  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _selectedBrandId;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _banners = [
    'https://img.pikbest.com/templates/20240902/food-sale-promotion-banner-for-supermarket-restaurants_10785489.jpg!w700wp',
    'https://www.bigc.vn/files/banners/2021/may-21/resize-template-black-red-banner-web-go-2.jpg',
    'https://img.freepik.com/free-vector/hand-drawn-fast-food-sale-banner_23-2150970571.jpg',
    'https://channel.mediacdn.vn/2021/4/27/photo-1-1619536488295922378403.jpg',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 950),
        curve: Curves.easeIn,
      );
    });
  }

  void _fetchProducts() async {
    const timeoutDuration = Duration(seconds: 10);
    bool dataLoaded = false;

    _databaseRef.onValue.timeout(timeoutDuration, onTimeout: (eventSink) {
      if (!dataLoaded) {
        setState(() => _isLoading = false);
        print("Timeout: Quá trình tải dữ liệu mất quá lâu.");
      }
    }).listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final loadedProducts = data.entries.map((entry) {
          return Product.fromMap(
              Map<String, dynamic>.from(entry.value), entry.key);
        }).toList();
        setState(() {
          _products = loadedProducts;
          _filteredProducts = loadedProducts;
          _isLoading = false;
          dataLoaded = true;
        });
      } else {
        print("Không tìm thấy dữ liệu trong Firebase.");
        setState(() => _isLoading = false);
      }
    }, onError: (error) {
      print("Lỗi khi tải sản phẩm: $error");
      setState(() => _isLoading = false);
    });
  }

  void _filterProducts() {
    final query = removeDiacritics(_searchController.text.toLowerCase());
    setState(() {
      _filteredProducts = _products.where((product) {
        final productName = removeDiacritics(product.name.toLowerCase());
        final productDescription =
        removeDiacritics(product.description.toLowerCase());

        final matchesBrand = _selectedBrandId == null ||
            (_selectedBrandId == "highRating"
                ? (int.tryParse(product.evaluate) ?? 0) >= 4
                : product.idHang == _selectedBrandId);
        final matchesQuery =
            productName.contains(query) || productDescription.contains(query);

        return matchesBrand && matchesQuery;
      }).toList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: AppBar(
          backgroundColor: Colors.white,
          leading: const Icon(Icons.location_on, color: Colors.blue),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Giao tới",
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text("07.BT8, Foresa 6B, Nam từ Liêm, Hà Nội",
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProfileDetailScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                  Icons.shopping_cart_outlined, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const CartScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Bạn muốn tìm gì?',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CategoryMenu(
                                    title: "Trái cây",
                                    imagePath: "assets/images/category/vegetable.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Hoa quả",
                                    imagePath: "assets/images/category/fruit.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Thực phẩm",
                                    imagePath: "assets/images/category/basket.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Bánh",
                                    imagePath: "assets/images/category/milk.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Hoa quả",
                                    imagePath: "assets/images/category/fruit.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Thực phẩm",
                                    imagePath: "assets/images/category/basket.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Bánh",
                                    imagePath: "assets/images/category/milk.png"),
                              ],
                            ),
                            gapH10,
                            Row(
                              children: [
                                CategoryMenu(
                                    title: "Đồ uống",
                                    imagePath: "assets/images/category/milk.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Rau củ",
                                    imagePath: "assets/images/category/vegetable.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Đồ dùng",
                                    imagePath: "assets/images/category/fruit.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Thịt",
                                    imagePath: "assets/images/category/basket.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Rau củ",
                                    imagePath: "assets/images/category/vegetable.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Đồ dùng",
                                    imagePath: "assets/images/category/fruit.png"),
                                gapW4,
                                CategoryMenu(
                                    title: "Thịt",
                                    imagePath: "assets/images/category/basket.png"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    gapH16,
                    // Các banner cuộn
                    SizedBox(
                      height: 130,
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
                    gapH6,
                    // Dấu chấm chỉ mục cho các banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_banners.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? Colors.blue : Colors
                                .grey,
                          ),
                        );
                      }),
                    ),
                    gapH16,
                    const Text("Sản phẩm mới nhất",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    gapH8,
                    // Hiển thị các sản phẩm đã lọc
                    _filteredProducts.isNotEmpty
                        ? SizedBox(
                      height: 265,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0),
                            child: Container(
                              width: 200,
                              child: ProductCard(
                                product: _filteredProducts[index],
                                userId: FirebaseAuth.instance.currentUser!.uid,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                        : const Center(
                      child: Text("Không tìm thấy sản phẩm nào"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
