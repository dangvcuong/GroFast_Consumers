// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/favorites/providers/favorites_provider.dart';
import 'package:grofast_consumers/features/shop/views/pay/pay_screen.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/product_card.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
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

  bool isDescriptionExpanded = false;
  final ShowDialogs showdialog = ShowDialogs();
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
            .where((entry) =>
                entry.key != widget.product.id &&
                Product.fromMap(
                            Map<String, dynamic>.from(entry.value), entry.key)
                        .idHang ==
                    widget.product.idHang)
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

  // Biến để lưu số lượng sản phẩm

  @override
  Widget build(BuildContext context) {
    final Login_Controller loginController = Login_Controller();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
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
                    "${widget.product.quantitysold} sản phẩm đã bán",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${formatter.format(widget.product.price)}/${displayUnit(widget.product.idHang)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Mô tả",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isDescriptionExpanded = !isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      isDescriptionExpanded ? "Thu gọn" : "Xem thêm",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              // Phần mô tả sản phẩm với nút toggle

              const SizedBox(height: 8),
              AnimatedCrossFade(
                firstChild: Text(
                  widget.product.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                secondChild: Text(
                  widget.product.description,
                  style: const TextStyle(fontSize: 16),
                ),
                crossFadeState: isDescriptionExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
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
        height: 60,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nút Thêm vào yêu thích
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  await favoritesProvider.addProductToUserHeart(
                      userId, widget.product, context);
                  setState(
                      () {}); // Cập nhật lại trạng thái khi thêm/xóa yêu thích
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: favoritesProvider.isFavorite(widget.product)
                          ? Colors
                              .red // Nếu đã có trong danh sách yêu thích, đặt màu đỏ
                          : Colors.black, // Nếu chưa có, đặt màu đen
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey,
            ),
            // Nút Thêm vào giỏ hàng
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  if (int.tryParse(widget.product.quantity.toString()) == 0) {
                    // Hiển thị thông báo nếu số lượng là 0
                    loginController.ThongBao(context, 'Sản phẩm đã hết hàng');
                  } else {
                    showdialog.showAddCartDialog(
                        context, widget.product, userId);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color:
                          int.tryParse(widget.product.quantity.toString()) == 0
                              ? Colors.black // Nếu hết hàng, đặt màu xám
                              : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            // Nút Thanh Toán
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: () {
                  if (int.tryParse(widget.product.quantity.toString()) == 0) {
                    // Không cho phép mua ngay khi hết hàng
                    loginController.ThongBao(context, 'Sản phẩm đã hết hàng');
                  } else {
                    showdialog.buyProductNow(userId, widget.product, context);
                  }
                },
                child: Container(
                  color: int.tryParse(widget.product.quantity.toString()) == 0
                      ? Colors.grey // Nếu hết hàng, đặt màu xám
                      : Colors.blue, // Đặt màu nền cho nút "Mua ngay"
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        int.tryParse(widget.product.quantity.toString()) == 0
                            ? "Hết hàng"
                            : "Mua ngay",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Đổi màu chữ thành trắng
                        ),
                      ),
                      if (int.tryParse(widget.product.quantity.toString()) != 0)
                        Text(
                          formatter.format(widget.product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
