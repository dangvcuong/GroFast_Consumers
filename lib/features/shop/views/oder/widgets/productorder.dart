import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/oder/widgets/product_item.dart';

class ProductListOrder extends StatelessWidget {
  final List<Map<dynamic, dynamic>> products;
  final String orderStatus;

  const ProductListOrder({
    super.key,
    required this.products,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductItem(
          id: product['id'] ?? '',
          imageUrl: product['imageUrl'] ?? '',
          name: product['name'] ?? 'N/A',
          price: product['price'].toString(),
          quantity: product['quantity'].toString(),
          status: orderStatus, // Truyền trạng thái đơn hàng
        );
      },
    );
  }
}
