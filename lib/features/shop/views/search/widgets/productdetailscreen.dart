// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
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
  String? userId; // Cho phép userId là null
  String errorMessage = "";
  List<Map> reviews = []; // Danh sách lưu trữ đánh giá sản phẩm
  bool showAllReviews =
      false; // Biến để kiểm tra xem có hiển thị tất cả đánh giá không

  bool isDescriptionExpanded = false;
  final ShowDialogs showdialog = ShowDialogs();

  @override
  void initState() {
    super.initState();
    _fetchOtherProducts();
    _getReviews();
    _checkUserStatus(); // Kiểm tra trạng thái đăng nhập
  }

  void _checkUserStatus() {
    setState(() {
      userId =
          FirebaseAuth.instance.currentUser?.uid; // Lấy userId nếu đăng nhập
    });
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

  Future<void> _getReviews() async {
    DatabaseReference reviewRef =
        FirebaseDatabase.instance.ref('reviews/${widget.product.id}');

    DataSnapshot snapshot = await reviewRef.get();

    if (snapshot.exists) {
      List<Map> fetchedReviews = [];
      Map<dynamic, dynamic> reviewsData =
          snapshot.value as Map<dynamic, dynamic>;

      reviewsData.forEach((key, value) {
        if (value['status'] == 'đã xác nhận') {
          fetchedReviews.add({
            'rating': value['rating'],
            'review': value['review'],
            'userName': value['userName'],
            'userPhotoURL': value['userPhotoURL'],
            'userId': value['userId'],
            'timestamp': value['timestamp'],
          });
        }
      });

      setState(() {
        reviews = fetchedReviews;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                formatter.format(widget.product.price),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Đánh giá sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAllReviews =
                            !showAllReviews; // Thay đổi trạng thái khi nhấn "Xem thêm"
                      });
                    },
                    child: Text(
                      showAllReviews
                          ? "Ẩn bớt"
                          : "Xem thêm", // Thay đổi tên nút tùy vào trạng thái
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              ...reviews
                  .take(showAllReviews
                      ? reviews.length
                      : 2) // Nếu showAllReviews là true, hiển thị tất cả đánh giá
                  .map((review) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bo tròn các góc
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hàng hiển thị ảnh người dùng và tên người dùng
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  review['userPhotoURL'] ??
                                      '', // Lấy ảnh người dùng từ Firebase
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover, // Cắt ảnh thành hình tròn
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.account_circle,
                                        size:
                                            40); // Nếu có lỗi tải ảnh, hiển thị icon mặc định
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                review['userName'] ?? 'Tên người dùng',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Hiển thị sao đánh giá
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(' ${review['rating']}'),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Hiển thị nội dung đánh giá
                          Text(
                            "Nội dung: ${review['review']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Text(
                "Sản phẩm khác",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: ProductCard(
                      product: product,
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    ),
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
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  if (userId == null) {
                    // Hiển thị dialog yêu cầu đăng nhập
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Thông báo'),
                          content: const Text('Bạn cần đăng nhập để thực hiện thao tác này.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                              },
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                ); // Chuyển sang màn hình đăng nhập
                              },
                              child: const Text('Đăng nhập'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  await favoritesProvider.addProductToUserHeart(
                      userId!, widget.product, context);
                  setState(() {});
                },
                child: Icon(
                  Icons.favorite,
                  color: userId != null &&
                      favoritesProvider.isFavorite(widget.product)
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  if (userId == null) {
                    // Hiển thị dialog yêu cầu đăng nhập
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Thông báo'),
                          content: const Text('Bạn cần đăng nhập để thực hiện thao tác này.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                              },
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                ); // Chuyển sang màn hình đăng nhập
                              },
                              child: const Text('Đăng nhập'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  showdialog.showAddCartDialog(context, widget.product, userId!);
                },
                child: const Icon(Icons.shopping_cart),
              ),
            ),

            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: () {
                  if (widget.product.quantity <= 0) {
                    // Thông báo sản phẩm hết hàng
                    loginController.ThongBao(context, 'Sản phẩm đã hết hàng');
                  } else if (userId == null) {
                    // Hiển thị dialog yêu cầu đăng nhập
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Thông báo'),
                        content: const Text('Bạn cần đăng nhập để thực hiện hành động này.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Đóng dialog
                            },
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Đóng dialog trước khi chuyển màn hình
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            },
                            child: const Text('Đăng nhập'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Mua ngay
                    showdialog.buyProductNow(userId!, widget.product, context);
                  }
                },
                child: Container(
                  color: widget.product.quantity <= 0 ? Colors.grey : Colors.blue,
                  child: Center(
                    child: Text(
                      widget.product.quantity > 0 ? "Mua ngay" : "Hết hàng",
                      style: const TextStyle(color: Colors.white),
                    ),
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
