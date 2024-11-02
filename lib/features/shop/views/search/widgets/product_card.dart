// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/productdetailscreen.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:grofast_consumers/features/shop/providers/cart_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    num priceValue = num.tryParse(widget.product.price) ?? 0;

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
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.product.imageUrl,
                  height: 89,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    companyName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  )),
                  Text(
                    displayUnit(widget.product.idHang),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatter.format(priceValue),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addToCart(CartItem(
                        productId: widget.product.id,
                        name: widget.product.name,
                        description: widget.product.description,
                        imageUrl: widget.product.imageUrl,
                        price: double.tryParse(widget.product.price) ?? 0.0,
                        evaluate:
                            double.tryParse(widget.product.evaluate) ?? 0.0,
                        idHang: widget.product.idHang,
                      ));
                      loginController.ThongBao(
                        context,
                        "Sản phẩm đã được thêm vào giỏ hàng!",
                      );
                    },
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
