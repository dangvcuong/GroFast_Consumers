// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';

import '../cart/Product_cart_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('products');

  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _selectedBrandId;
  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                            return ProductCard(
                              product: _filteredProducts[index],
                              userId: FirebaseAuth.instance.currentUser!.uid,
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
    final chipData = [
      {"label": "Tất cả", "id": null},
      {"label": "Hoa Quả", "id": "-OAILvF-j4bmiGDvVuid"},
      {"label": "Dầu ăn & gia vị", "id": "-OAW4dwvRnrhTQHPwXrr"},
      {"label": "Đồ uống", "id": "-OAILiSWs97veFGxZRR0"},
      {"label": "Đồ ăn", "id": "-OAILnTvn0LS1XeKk7bs"},
      {"label": "Đánh giá cao", "id": "highRating"},
    ];

    return chipData.map((chip) {
      final isSelected = _selectedBrandId == chip['id'];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(
            chip['label'] as String,
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
