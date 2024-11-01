import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/favorites/providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/favorites/widgets/favorite_product_item.dart';


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
                return ProductFavoriteCard(
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
