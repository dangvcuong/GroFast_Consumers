// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/favorites/providers/favorites_provider.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/productdetailscreen.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/category_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String userId;

  const ProductCard({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Login_Controller loginController = Login_Controller();
  final ShowDialogs showDialogs = ShowDialogs();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String companyName = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _fetchCompanyName(widget.product.idHang);
  }

  void _fetchCompanyName(String idHang) async {
    try {
      final DatabaseEvent event =
          await _database.child('companys/$idHang').once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          companyName = data['name'] ?? "Không xác định";
        });
      } else {
        setState(() {
          companyName = "Không tìm thấy hãng";
        });
      }
    } catch (error) {
      print("Lỗi khi tải tên hãng: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    num priceValue = num.tryParse(widget.product.price) ?? 0;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: widget.product,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        widget.product.imageUrl,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        shape: BoxShape.circle,
                      ),
                      width: 25,
                      height: 25,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.favorite,
                          size: 18,
                          color: favoritesProvider.isFavorite(widget.product)
                              ? Colors.red
                              : Colors.grey.shade300,
                        ),
                        onPressed: () async {
                          if (favoritesProvider.isFavorite(widget.product)) {
                            // favoritesProvider.removeFavorite(widget.product);
                            showDialogs.showDeleteFavoriteDialog(
                                context, widget.product);
                          } else {
                            await favoritesProvider.addProductToUserHeart(
                                userId, widget.product, context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              gapH8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    companyName,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  Text(
                    displayUnit(widget.product.idHang),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      Text("${widget.product.evaluate}/5"),
                    ],
                  ),
                  Text("${widget.product.quantity} Đã bán"),
                ],
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatter.format(priceValue),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF44336))),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () {
                        showDialogs.showAddCartDialog(
                            context, widget.product, userId);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
