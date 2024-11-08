// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:diacritic/diacritic.dart';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset("assets/logos/logo.png"),
                      ),
                      const Text(
                        "Khám phá",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,color: Colors.black),
                        onPressed: () {
                          // Thực hiện hành động khi nhấn vào biểu tượng giỏ hàng
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CartScreen()), // Điều hướng đến màn hình giỏ hàng
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Lướt ngang
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text("Tất cả"),
                          selected: _selectedBrandId == null,
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedBrandId = null; // Không lọc theo hãng
                              _filterProducts();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Hoa Quả"),
                          selected: _selectedBrandId == "-OAILvF-j4bmiGDvVuid",
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedBrandId =
                                  isSelected ? "-OAILvF-j4bmiGDvVuid" : null;
                              _filterProducts();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Dầu ăn & gia vị"),
                          selected: _selectedBrandId == "-OAW4dwvRnrhTQHPwXrr",
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedBrandId =
                                  isSelected ? "-OAW4dwvRnrhTQHPwXrr" : null;
                              _filterProducts();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Đồ uống"),
                          selected: _selectedBrandId == "-OAILiSWs97veFGxZRR0",
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedBrandId =
                                  isSelected ? "-OAILiSWs97veFGxZRR0" : null;
                              _filterProducts();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Đồ ăn"),
                          selected: _selectedBrandId == "-OAILnTvn0LS1XeKk7bs",
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedBrandId =
                                  isSelected ? "-OAILnTvn0LS1XeKk7bs" : null;
                              _filterProducts();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Đánh giá cao"),
                          selected: _selectedBrandId == "highRating",
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedBrandId = "highRating";
                              _filterProducts();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
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
}
