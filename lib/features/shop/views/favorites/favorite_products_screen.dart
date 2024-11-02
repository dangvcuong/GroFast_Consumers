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
      body: favoritesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10.0), // Cách trái 10dp
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileDetailScreen(),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: Image.asset("assets/logos/logo.png"),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Sản phẩm yêu thích",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CartScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
