// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/favorites/providers/favorites_provider.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/profile_detail_screen.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';

import '../cart/Product_cart_item.dart';

class FavoriteProductsScreen extends StatelessWidget {
  const FavoriteProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ẩn nút quay lại
        backgroundColor: Colors.blue, // Màu nền của AppBar
        title: const Text(
          "Sản phẩm yêu thích", // Tiêu đề
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        elevation: 4, // Độ đổ bóng của AppBar

      ),
      body: favoritesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: favoritesProvider.favorites.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: favoritesProvider.favorites.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: favoritesProvider.favorites[index],
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
