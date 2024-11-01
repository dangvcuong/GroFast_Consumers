// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/favorites/widgets/favorite_product_item.dart';

class FavoriteProductsScreen extends StatefulWidget {
  const FavoriteProductsScreen({super.key});

  @override
  _FavoriteProductsScreenState createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  // Đường dẫn đến sản phẩm yêu thích
  late final DatabaseReference _favoritesRef;

  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _favoritesRef = FirebaseDatabase.instance.ref('users/$userId/favorites');
      _fetchFavoriteProducts();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchFavoriteProducts() async {
    const timeoutDuration = Duration(seconds: 10);
    bool dataLoaded = false;

    _favoritesRef.onValue.timeout(timeoutDuration, onTimeout: (eventSink) {
      if (!dataLoaded) {
        setState(() => _isLoading = false);
        print("Timeout: Quá trình tải dữ liệu mất quá lâu.");
      }
    }).listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      print("Dữ liệu từ Firebase: $data"); // In ra dữ liệu để kiểm tra

      if (data != null) {
        final loadedProducts = data.entries.map((entry) {
          return Product.fromMap(
              Map<String, dynamic>.from(entry.value), entry.key);
        }).toList();

        setState(() {
          _favoriteProducts = loadedProducts;
          _isLoading = false;
          dataLoaded = true;
        });
      } else {
        print("Không tìm thấy dữ liệu trong Firebase.");
        setState(() => _isLoading = false);
      }
    }, onError: (error) {
      print("Lỗi khi tải sản phẩm yêu thích: $error");
      setState(() => _isLoading = false);
    });
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
                  "Sản phẩm yêu thích",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.shopping_cart),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _favoriteProducts.isNotEmpty
                ? GridView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _favoriteProducts.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Số cột (2 cột)
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7, // Điều chỉnh tỷ lệ theo ý muốn
              ),
              itemBuilder: (context, index) {
                return ProductFavoriteCard(
                  product: _favoriteProducts[index],
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
