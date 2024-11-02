<<<<<<< HEAD
// ignore_for_file: file_names, unnecessary_import, use_build_context_synchronously, non_constant_identifier_names
=======
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/productdetailscreen.dart';
import 'package:provider/provider.dart';
=======
// ignore_for_file: file_names, unnecessary_import, use_build_context_synchronously, non_constant_identifier_names
>>>>>>> 7671276227ff1f94cfa2797eb8590d3d64947c30
>>>>>>> 191503ba77eb4a624c13538c621d9f4fd27aa7f7

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/search/widgets/productdetailscreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../showdialogs/show_dialogs.dart';
import '../../../models/category_model.dart';
<<<<<<< HEAD
=======
import '../../../models/shopping_cart_model.dart';
import '../../cart/providers/cart_provider.dart';
>>>>>>> 191503ba77eb4a624c13538c621d9f4fd27aa7f7
import '../providers/favorites_provider.dart';

class ProductFavoriteCard extends StatefulWidget {
  final Product product;

  const ProductFavoriteCard({
    super.key,
    required this.product,
    required String userId,
  });
<<<<<<< HEAD
=======

  @override
  _ProductFavoriteCardState createState() => _ProductFavoriteCardState();
}

class _ProductFavoriteCardState extends State<ProductFavoriteCard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String companyName = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _fetchCompanyName(widget.product.idHang);
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
>>>>>>> 7671276227ff1f94cfa2797eb8590d3d64947c30

  @override
  _ProductFavoriteCardState createState() => _ProductFavoriteCardState();
}

class _ProductFavoriteCardState extends State<ProductFavoriteCard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
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
    num priceValue = num.tryParse(widget.product.price) ?? 0;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
<<<<<<< HEAD
            builder: (context) => ProductDetailScreen(product: widget.product),
=======
<<<<<<< HEAD
            builder: (context) => ProductDetailScreen(
              product: product,
            ),
=======
            builder: (context) => ProductDetailScreen(product: widget.product),
>>>>>>> 7671276227ff1f94cfa2797eb8590d3d64947c30
>>>>>>> 191503ba77eb4a624c13538c621d9f4fd27aa7f7
          ),
        );
      },
      child: Card(
<<<<<<< HEAD
        color: Colors.white,
        elevation: 5,
=======
<<<<<<< HEAD
>>>>>>> 191503ba77eb4a624c13538c621d9f4fd27aa7f7
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
                          onPressed: () {
                            if (favoritesProvider.isFavorite(widget.product)) {
                              ShowDialogs().showDeleteFavoriteDialog(
                                  context, widget.product);
                            } else {
                              favoritesProvider.addFavorite(widget.product);
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
                const SizedBox(
                    height:
                        2), // Giảm khoảng cách giữa tên hãng và loại sản phẩm
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 1),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${widget.product.evaluate} ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          TextSpan(
                            text: "/5",
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 33),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${widget.product.quantity} ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          TextSpan(
                            text: "Đã bán",
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(priceValue),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_circle,
                            size: 35, color: Colors.blue),
                        onPressed: () {
                          print("Sản phẩm đã được thêm vào giỏ hàng!");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
<<<<<<< HEAD
          ),
=======
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2, // Giới hạn số dòng để đẹp hơn
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Giá: ${product.price}đ",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Đánh giá: ${product.evaluate}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                          width:
                              4), // Thêm khoảng cách giữa đánh giá và biểu tượng sao
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
=======
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
                          onPressed: () {
                            if (favoritesProvider.isFavorite(widget.product)) {
                              ShowDialogs().showDeleteFavoriteDialog(context, widget.product);
                            } else {
                              favoritesProvider.addFavorite(widget.product);
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
                      style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    Text(
                      displayUnit(widget.product.idHang),
                      style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 1),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${widget.product.evaluate} ",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12), // Kích thước nhỏ hơn
                          ),
                          TextSpan(
                            text: "/5",
                            style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12), // Kích thước nhỏ hơn
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 33),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${widget.product.quantity} ",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12), // Kích thước nhỏ hơn
                          ),
                          TextSpan(
                            text: "Đã bán",
                            style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12), // Kích thước nhỏ hơn
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(priceValue),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
>>>>>>> 7671276227ff1f94cfa2797eb8590d3d64947c30
>>>>>>> 191503ba77eb4a624c13538c621d9f4fd27aa7f7
        ),
      ),
    );
  }
}
