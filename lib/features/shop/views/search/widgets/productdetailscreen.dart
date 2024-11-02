import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/shopping_cart_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    num priceValue = num.tryParse(widget.product.price) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
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
              // Danh sách sản phẩm khác sẽ được thêm vào sau
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
                onPressed: () {
                  final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
                  if (favoritesProvider.isFavorite(widget.product)) {
                    favoritesProvider.removeFavorite(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã xóa sản phẩm khỏi danh sách yêu thích!")),
                    );
                  } else {
                    favoritesProvider.addFavorite(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Sản phẩm đã được thêm vào danh sách yêu thích!")),
                    );
                  }
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
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} đã được thêm vào giỏ hàng!'),
                      duration: Duration(seconds: 2), // Thời gian hiển thị của thông báo
                    ),
                  );
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  String displayUnit(String idHang) {
    // Hàm này sẽ trả về đơn vị sản phẩm dựa trên idHang
    // Thay đổi logic này theo nhu cầu của bạn
    return 'đơn vị';
  }
}
