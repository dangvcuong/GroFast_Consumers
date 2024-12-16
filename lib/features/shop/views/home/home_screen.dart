import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/shop/controllers/search_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/chatbot/chat_screen.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:grofast_consumers/features/shop/views/voucher/voucher_screen.dart';

import '../cart/Product_cart_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isImageTapped = false;
  bool _isImageVisible = true;
  double _imageTop = 100;
  double _imageLeft = 100;
  Timer? _imageTimer;

  late double screenWidth;
  late double screenHeight;
  late AnimationController _controller;
  late Animation<double> _animation;

  final String _currentLocation = "Đang lấy vị trí... ";

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
    'assets/images/benners/benner1.png',
    'assets/images/benners/benner2.png',
    'assets/images/benners/benner3.png',
  ];

  Timer? _timer;
  String? userId;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _scheduleImageReappear();
    _checkUserStatus();
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

  void _checkUserStatus() {
    setState(() {
      userId =
          FirebaseAuth.instance.currentUser?.uid; // Lấy userId nếu đăng nhập
    });
  }

  void _animateToEdge(bool moveToLeft) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetLeft =
        moveToLeft ? 0.0 : screenWidth - 100.0; // Lề trái hoặc phải
    _animation = Tween<double>(begin: _imageLeft, end: targetLeft).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _imageLeft = _animation.value;
        });
      });

    _controller.forward(from: 0.0);
  }

  void _scheduleImageReappear() {
    _imageTimer?.cancel();
    _imageTimer = Timer(const Duration(minutes: 1), () {
      setState(() {
        _isImageVisible = true;
      });
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

        // Sắp xếp theo thuộc tính khác, ví dụ `id`
        loadedProducts.sort((a, b) => b.id.compareTo(a.id));

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
    _controller.dispose();

    _imageTimer?.cancel();

    _timer?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const imageSize = 120.0;

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
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  onPressed: () {
                    if (userId == null) {
                      // Hiển thị dialog yêu cầu đăng nhập
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Thông báo'),
                          content: const Text('Bạn cần đăng nhập để truy cập giỏ hàng.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                              },
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog trước khi chuyển màn hình
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },
                              child: const Text('Đăng nhập'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    // Chuyển đến màn hình giỏ hàng
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_outlined, color: Colors.black),
                  onPressed: () {
                    if (userId == null) {
                      // Hiển thị dialog yêu cầu đăng nhập
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Thông báo'),
                          content: const Text('Bạn cần đăng nhập để sử dụng tính năng chat.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                              },
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog trước khi chuyển màn hình
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },
                              child: const Text('Đăng nhập'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    // Chuyển đến màn hình chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                ),
              ],

            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
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
                      padding: const EdgeInsets.all(3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _banners.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 300,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: AssetImage(_banners[
                                          index]), // Đổi từ NetworkImage sang AssetImage
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
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
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
                                  height: 266, // Chiều cao của danh sách
                                  child: ListView.builder(
                                    scrollDirection: Axis
                                        .horizontal, // Cuộn theo chiều ngang
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                4.0), // Khoảng cách giữa các sản phẩm
                                        child: SizedBox(
                                          width:
                                              200, // Độ rộng của mỗi sản phẩm
                                          child: ProductCard(
                                            product: _filteredProducts[index],
                                            userId: userId ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Text("Không tìm thấy sản phẩm nào"),
                                ),
                          gapH20,
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Sản phẩm đánh giá cao nhất",
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
                                    itemCount: _filteredProducts
                                        .where((product) =>
                                            (int.tryParse(product.evaluate) ??
                                                0) >=
                                            4)
                                        .length,
                                    itemBuilder: (context, index) {
                                      final highRatedProducts =
                                          _filteredProducts
                                              .where((product) =>
                                                  (int.tryParse(
                                                          product.evaluate) ??
                                                      0) >=
                                                  4)
                                              .toList();

                                      // Sắp xếp sản phẩm từ cao đến thấp theo đánh giá
                                      highRatedProducts.sort((a, b) {
                                        final ratingA =
                                            int.tryParse(a.evaluate) ?? 0;
                                        final ratingB =
                                            int.tryParse(b.evaluate) ?? 0;
                                        return ratingB.compareTo(
                                            ratingA); // So sánh từ cao đến thấp
                                      });

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: SizedBox(
                                          width: 200,
                                          child: ProductCard(
                                            product: highRatedProducts[
                                                index], // Dùng highRatedProducts đã sắp xếp
                                            userId: userId ?? '',
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
            if (_isImageVisible)
              Positioned(
                bottom: 0,
                right: 0,

                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _imageTop = (_imageTop + details.delta.dy)
                          .clamp(0.0, screenHeight - imageSize); // Giới hạn không cho vượt khỏi màn hình
                      _imageLeft = (_imageLeft + details.delta.dx)
                          .clamp(0.0, screenWidth - imageSize); // Giới hạn không cho vượt khỏi màn hình
                      _isImageTapped = true; // Làm đậm khi kéo
                    });
                  },
                  onPanEnd: (details) {
                    final isLeftSide = _imageLeft < screenWidth / 2;
                    _animateToEdge(isLeftSide);

                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        _isImageTapped = false; // Làm mờ sau 3 giây
                      });
                    });
                  },
                  onTap: () {
                    setState(() {
                      _isImageTapped = true;
                    });
                    Future.delayed(const Duration(milliseconds: 200), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VoucherScreen()));
                    });
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Hình ảnh
                      AnimatedOpacity(
                        opacity: _isImageTapped ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          'assets/logos/voucher.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Nút "X" để tắt hình ảnh
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isImageVisible = false;
                            });
                            _scheduleImageReappear(); // Hẹn giờ bật lại sau 1 phút
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
