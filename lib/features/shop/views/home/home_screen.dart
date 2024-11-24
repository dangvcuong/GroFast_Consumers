// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, unused_field, avoid_print

import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:grofast_consumers/features/shop/controllers/search_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/home/widget/category_menu.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:grofast_consumers/features/shop/views/chatbot/chat_screen.dart';
import 'package:grofast_consumers/features/shop/views/chatbot/chat.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import '../cart/Product_cart_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = "Đang lấy vị trí... ";

  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('products');

  final TextEditingController _searchController = TextEditingController();
  final searchProductController = Get.put(SearchProductController());

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _selectedBrandId;

  User? currentUser;
  List<AddressModel> addresses = [];
  AddressModel? defaultAddress;

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

    currentUser = FirebaseAuth.instance.currentUser;
    _fetchAddresses();

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
        _pageController.jumpToPage(_currentPage);
        return;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
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
        final productBrandId = product.idHang.toLowerCase();

        final matchesBrand = _selectedBrandId == null ||
            (_selectedBrandId == "highRating"
                ? (int.tryParse(product.evaluate) ?? 0) >= 4
                : product.idHang == _selectedBrandId);

        final matchesQuery = productName.contains(query) ||
            productDescription.contains(query) ||
            productBrandId
                .contains(query); // Kiểm tra idHang với từ khóa tìm kiếm

        return matchesBrand && matchesQuery;
      }).toList();
    });
  }

  Future<void> _fetchAddresses() async {
    final userId = currentUser!.uid;
    final databaseRef =
        FirebaseDatabase.instance.ref('users/$userId/addresses');
    final DatabaseEvent event = await databaseRef.once();
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        addresses = data.entries.map((entry) {
          final addressData = entry.value;
          return AddressModel.fromMap({
            'nameAddresUser': addressData['nameAddresUser'],
            'phoneAddresUser': addressData['phoneAddresUser'],
            'addressUser': addressData['addressUser'],
            'status': addressData['status'],
          });
        }).toList();

        defaultAddress = addresses.firstWhere(
          (address) => address.status == 'on',
          orElse: () => AddressModel(
              nameAddresUser: '',
              phoneAddresUser: '',
              addressUser: '',
              status: ''),
        );
      });
    }
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 0), // Tạo khoảng cách 15dp từ đầu màn hình
            child: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.location_on, color: Colors.blue),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressUser()),
                  ).then((_) {
                    _fetchAddresses();
                  });
                },
              ),
              title: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressUser()),
                  );
                  _fetchAddresses();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Giao tới",
                        style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text(
                      defaultAddress?.nameAddresUser != null &&
                              defaultAddress?.addressUser != null
                          ? '${defaultAddress!.nameAddresUser} - ${defaultAddress!.addressUser}'
                          : 'Chưa có địa chỉ',
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    hintText: 'Bạn muốn tìm gì?',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 170,
                        child: GridView.count(
                          crossAxisCount: 2,
                          scrollDirection: Axis.horizontal,
                          children:
                              CategoryMenu.getCategoryList().map((category) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 1.0, vertical: 4.0),
                              child: category,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 130,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 300,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_banners.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentPage =
                                    index; // Cập nhật trang hiện tại khi nhấn vào chấm
                              });
                              _pageController.animateToPage(
                                _currentPage,
                                duration: const Duration(milliseconds: 500),
                                // Hiệu ứng chuyển trang mượt mà
                                curve: Curves
                                    .easeInOut, // Dùng hiệu ứng curve cho chuyển trang
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors
                                        .grey, // Màu của chấm thay đổi khi chọn
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Sản phẩm mới nhất",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                    child: SizedBox(
                                      width: 200,
                                      child: ProductCard(
                                        product: _filteredProducts[index],
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
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
            gapH20,
          ],
        ),
      ),
    );
  }
}
