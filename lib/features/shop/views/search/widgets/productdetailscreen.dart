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
  int quantity = 1;
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

  Future<void> addProductToUserCart(
      String userId, Product product, BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // hiệu ứng bóng
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chọn số lượng sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Trừ
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setModalState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                      // Hiển thị số lượng
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nút Cộng
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nút Thêm vào giỏ hàng
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final DatabaseReference cartRef =
                          FirebaseDatabase.instance.ref('users/$userId/carts');
                      try {
                        await cartRef.child(product.id).set({
                          "id": product.id,
                          "name": product.name,
                          "description": product.description,
                          "imageUrl": product.imageUrl,
                          "price": product.price,
                          "evaluate": product.evaluate,
                          "quantity": quantity,
                          "idHang": product.idHang,
                        });
                        Navigator.pop(context); // Đóng BottomSheet
                        loginController.ThongBao(
                            context, "Sản phẩm đã được thêm vào giỏ hàng!");
                      } catch (error) {
                        loginController.ThongBao(context,
                            "Lỗi khi thêm sản phẩm vào giỏ hàng: $error");
                      }
                    },
                    child: const Text(
                      'Thêm vào giỏ hàng',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Đảm bảo quantity được đặt lại thành 1 khi người dùng nhấn ra ngoài
      quantity = 1;
    });
  }

  Future<void> buyProductNow(
      String userId, Product product, BuildContext context) async {
    // Đặt giá trị quantity ban đầu là 1
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chọn số lượng sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Trừ
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setModalState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                      // Hiển thị số lượng
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nút Cộng
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nút Xác nhận mua ngay
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Đóng BottomSheet và đặt lại quantity
                      Navigator.pop(context);
                      setModalState(() {
                        quantity = 1; // Đặt lại quantity sau khi mua
                      });
                      // Chuyển đến màn hình thanh toán với số lượng đã chọn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            product: product,
                            products: List.filled(quantity, product),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Mua ngay',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Đảm bảo quantity được đặt lại thành 1 khi người dùng nhấn ra ngoài
      quantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    num priceValue = num.tryParse(widget.product.price) ?? 0;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    String gia = widget.product.price;
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
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
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
                    addProductToUserCart(userId, widget.product, context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.black),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              // Nút Thanh Toán
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () {
                    buyProductNow(userId, widget.product, context);
                  },
                  child: Container(
                    color: Colors.blue, // Đặt màu nền cho nút "Mua ngay"
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Mua ngay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Đổi màu chữ thành trắng để dễ đọc trên nền xanh
                          ),
                        ),
                        Text(
                          formatter.format(priceValue),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Đổi màu chữ thành trắng để dễ đọc trên nền xanh
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
