import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product_model.dart';
import '../providers/favorites_provider.dart';

class ProductFavoriteCard extends StatelessWidget {
  final Product product;

  const ProductFavoriteCard({
    Key? key,
    required this.product, required String userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4, // Thêm độ cao cho card
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(
                  product.imageUrl,
                  height: 120, // Tăng chiều cao cho hình ảnh
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    favoritesProvider.isFavorite(product)
                        ? Icons.favorite_border
                        : Icons.favorite,
                    color: favoritesProvider.isFavorite(product)
                        ? Colors.white // Nếu là sản phẩm yêu thích, màu đỏ
                        : Colors.red, // Nếu không phải, màu trắng
                  ),
                  onPressed: () {
                    if (favoritesProvider.isFavorite(product)) {
                      favoritesProvider.removeFavorite(product);
                    } else {
                      favoritesProvider.addFavorite(product);
                    }
                  },
                ),
              ),
            ],
          ),
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
                    const SizedBox(width: 4), // Thêm khoảng cách giữa đánh giá và biểu tượng sao
                    Icon(
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
      ),
    );
  }
}
