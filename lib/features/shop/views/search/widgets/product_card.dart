// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/favorites/providers/favorites_provider.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/productdetailscreen.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/category_model.dart';
import '../../cart/providers/cart_provider.dart';

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
  final HAppStyle hAppStyle = HAppStyle();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String companyName = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _fetchCompanyName(widget.product.idHang); // Gọi hàm để lấy tên hãng
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
        print("Không tìm thấy hãng với ID: $idHang");
      }
    } catch (error) {
      setState(() {});
      print("Lỗi khi tải tên hãng: $error");
    }
  }

  Future<void> addProductToUserCart(
      String userId, Product product, BuildContext context) async {
    String errorMessage;
    final DatabaseReference cartRef =
        FirebaseDatabase.instance.ref('users/$userId/carts');
    try {
      // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
      final DatabaseEvent event = await cartRef.child(product.id).once();
      if (event.snapshot.value != null) {
        // Nếu sản phẩm đã có, tăng quantity lên 1
        final currentQuantity = (event.snapshot.value as Map)['quantity'] ?? 0;
        await cartRef.child(product.id).update({
          "quantity": currentQuantity + 1,
        });
        errorMessage = "Đã tăng số lượng sản phẩm trong giỏ hàng!";
      } else {
        // Nếu sản phẩm chưa có, thêm sản phẩm mới vào giỏ hàng
        await cartRef.child(product.id).set({
          "id": product.id,
          "name": product.name,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "evaluate": product.evaluate,
          "quantity": 1,
          "idHang": product.idHang,
        });
        errorMessage = "Sản phẩm đã được thêm vào giỏ hàng!";
      }
    } catch (error) {
      errorMessage = "Lỗi khi thêm sản phẩm vào giỏ hàng: $error";
    }
    loginController.ThongBao(context, errorMessage);
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
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(8.0),
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
                            ShowDialogs().showDeleteFavoriteDialog(
                                context, widget.product);
                          } else {
                            favoritesProvider.addProductToUserHeart(
                                userId, widget.product, context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    companyName,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                  Text(
                    displayUnit(widget.product.idHang),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: 35,
                      ),
                      onPressed: () {
                        addProductToUserCart(userId, widget.product, context);
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
