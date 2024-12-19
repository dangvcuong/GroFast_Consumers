// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';

import '../cart/Product_cart_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('products');
  final ShowDialogs showDialog = ShowDialogs();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? userId;
  String? _selectedBrandId;
  final Login_Controller loginController = Login_Controller();
  List<Map<String, dynamic>> chipData = [
    {"name": "Tất cả", "id": null},
    {"name": "Đánh giá cao", "id": "highRating"},
  ];
  final DatabaseReference _companyRef =
      FirebaseDatabase.instance.ref('companys');

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
    _fetchCompanyData();
    _filterProducts();
    _checkUserStatus();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        userId = user?.uid; // Cập nhật lại userId
      });

      // Nếu có userId, tải lại dữ liệu
      if (user != null) {}
    });
  }

  void _checkUserStatus() {
    setState(() {
      userId =
          FirebaseAuth.instance.currentUser?.uid; // Lấy userId nếu đăng nhập
    });
  }

  void _fetchCompanyData() async {
    _companyRef.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        chipData.add({
          'name': data['name'], // Dữ liệu label từ Firebase
          'id': data['id'], // Dữ liệu id từ Firebase
        });
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

        // Kiểm tra đánh giá cao hơn hoặc bằng 4.0
        final rating = double.tryParse(product.evaluate) ?? 0.0;
        final matchesHighRating = rating >= 4.0;

        final matchesBrand = _selectedBrandId == null ||
            (_selectedBrandId == "highRating"
                ? matchesHighRating
                : product.idHang == _selectedBrandId);
        final matchesQuery =
            productName.contains(query) || productDescription.contains(query);

        return matchesBrand && matchesQuery;
      }).toList();

      // Sắp xếp theo đánh giá từ cao xuống thấp
      _filteredProducts.sort((a, b) {
        final ratingA = double.tryParse(a.evaluate) ?? 0.0;
        final ratingB = double.tryParse(b.evaluate) ?? 0.0;
        return ratingB.compareTo(ratingA); // Sắp xếp từ cao xuống thấp
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ẩn nút quay lại
        backgroundColor: Colors.blue, // Màu nền của AppBar
        title: const Text(
          "Khám phá", // Tiêu đề
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        elevation: 4, // Độ đổ bóng của AppBar
        actions: [
          IconButton(
            // Nút giỏ hàng
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              if (userId == null) {
                // Hiển thị dialog yêu cầu đăng nhập
                showDialog.thongbaoDangNhap(context);
                return;
              }
              // Chuyển đến màn hình giỏ hàng
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: "Tìm kiếm...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0)),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Lướt ngang
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildChoiceChips(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _filteredProducts.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _filteredProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Số cột (2 cột)
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio:
                                0.7, // Điều chỉnh tỷ lệ theo ý muốn
                          ),
                          itemBuilder: (context, index) {
                            final userId = FirebaseAuth.instance.currentUser
                                ?.uid; // Kiểm tra nếu người dùng đã đăng nhập
                            return ProductCard(
                              product: _filteredProducts[index],
                              userId: userId ??
                                  '', // Truyền userId, nếu null thì người dùng chưa đăng nhập
                            );
                          },
                        )
                      : const Center(
                          child: Text("Không tìm thấy sản phẩm nào"),
                        ),
                ),
              ],
            ),
    );
  }

  // Hàm xây dựng các `ChoiceChip`
  List<Widget> _buildChoiceChips() {
    return chipData.map((chip) {
      final isSelected = _selectedBrandId == chip['id'];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(
            chip['name'] != null ? chip['name'] as String : 'Unknown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          onSelected: (isSelected) {
            setState(() {
              _selectedBrandId = isSelected ? chip['id'] : null;
              _filterProducts();
            });
          },
        ),
      );
    }).toList();
  }
}
