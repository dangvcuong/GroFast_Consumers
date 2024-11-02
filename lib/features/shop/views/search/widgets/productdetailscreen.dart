// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/category_model.dart';
import '../../cart/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Product> otherProducts = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Login_Controller loginController = Login_Controller();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String errorMessage = "";
  @override
  void initState() {
    super.initState();
    _fetchOtherProducts();
  }

  void _fetchOtherProducts() async {
    try {
      final DatabaseEvent event = await _database.child('products').once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        otherProducts = data.entries
            .where((entry) => entry.key != widget.product.id)
            .map((entry) => Product.fromMap(
                Map<String, dynamic>.from(entry.value), entry.key))
            .toList();

        setState(() {});
      } else {
        print("Không tìm thấy dữ liệu trong Firebase.");
      }
    } catch (error) {
      print("Lỗi khi tải sản phẩm khác: $error");
    }
  }

  Future<void> addProductToUserHeart(String userId, Product product) async {
    final DatabaseReference userFavoritesRef =
        FirebaseDatabase.instance.ref('users/$userId/favorites');

    try {
      Map<String, dynamic> productData = product.toMap();

      // Thêm sản phẩm vào Firebase
      await userFavoritesRef.child(product.id).set(productData);

      errorMessage = "Sản phẩm đã được thêm vào danh sách yêu thích!";
    } catch (error) {
      errorMessage = "Lỗi khi thêm sản phẩm vào yêu thích: $error";
    }
    loginController.ThongBao(context, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    num priceValue = num.tryParse(widget.product.price) ?? 0;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.product.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      Text(
                        "${widget.product.evaluate}/5",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.product.quantity} sản phẩm đã bán",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${formatter.format(priceValue)}/${displayUnit(widget.product.idHang)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                "Mô tả",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sản phẩm khác",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                shrinkWrap: true, // Thu nhỏ GridView vừa với nội dung
                physics:
                    const NeverScrollableScrollPhysics(), // Không cuộn được
                children: otherProducts.map((product) {
                  return ProductCard(
                    product: product,
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nút Thêm vào yêu thích
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await addProductToUserHeart(userId, widget.product);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Nút Thêm vào giỏ hàng
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  cartProvider.addToCart(CartItem(
                    productId: widget.product.id,
                    name: widget.product.name,
                    description: widget.product.description,
                    imageUrl: widget.product.imageUrl,
                    price: double.tryParse(widget.product.price) ?? 0.0,
                    evaluate: double.tryParse(widget.product.evaluate) ?? 0.0,
                    idHang: widget.product.idHang,
                  ));

                  // Hiển thị thông báo khi thêm sản phẩm vào giỏ hàng
                  loginController.ThongBao(
                      context, "Sản phẩm đã được thêm vào giỏ hàng!");

                  print("Sản phẩm đã được thêm vào giỏ hàng!");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Nút Thanh Toán
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Logic xử lý thanh toán
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Thanh Toán',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
