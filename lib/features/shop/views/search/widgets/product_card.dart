import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});
  String displayUnit(String idHang) {
    return (idHang == "-OAILvF-j4bmiGDvVuid")
        ? "kg"
        : "cái"; // Sử dụng toán tử ba ngôi
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Image.network(product.imageUrl,
            width: 50, height: 50, fit: BoxFit.cover),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                Text("${product.evaluate}/5"),
                const SizedBox(width: 10),
                Text("${product.quantity} Đã bán"),
              ],
            ),
            Text('${product.price}₫/${displayUnit(product.idHang)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.blue),
          onPressed: () {
            // Logic thêm vào giỏ hàng
          },
        ),
      ),
    );
  }
}
