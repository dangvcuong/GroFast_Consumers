import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/productdetailscreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/category_model.dart';
import '../providers/favorites_provider.dart';

class ProductFavoriteCard extends StatefulWidget {
  final Product product;

  const ProductFavoriteCard({
    super.key,
    required this.product,
    required String userId,
  });

  @override
  _ProductFavoriteCardState createState() => _ProductFavoriteCardState();
}

class _ProductFavoriteCardState extends State<ProductFavoriteCard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String companyName = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _fetchCompanyName(widget.product.idHang); // Gọi hàm để lấy tên hãng
  }

  void _fetchCompanyName(String idHang) async {
    try {
      final DatabaseEvent event = await _database.child('companys/$idHang').once();
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
      setState(() {
        companyName = "Lỗi tải hãng";
      });
      print("Lỗi khi tải tên hãng: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    num priceValue = num.tryParse(widget.product.price) ?? 0; // Chuyển đổi bằng num
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
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
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: favoritesProvider.isFavorite(widget.product)
                              ? Colors.grey.shade300
                              : Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            if (favoritesProvider.isFavorite(widget.product)) {
                              favoritesProvider.removeFavorite(widget.product);
                            } else {
                              favoritesProvider.addFavorite(widget.product);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(companyName), // Hiển thị tên hãng
                    Text(displayUnit(widget.product.idHang)), // Hiển thị đơn vị
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    Text(
                      formatter.format(priceValue),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.blue),
                    ),
                    // Nút cộng thêm vào giỏ hàng
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        print("Sản phẩm đã được thêm vào giỏ hàng!");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
