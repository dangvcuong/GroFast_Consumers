import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final String quantity;

  const ProductItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    double priceValue = double.tryParse(price) ?? 0.0;
    String formattedPrice = formatter.format(priceValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Border color
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          color: Colors.white, // Background color
        ),
        padding: const EdgeInsets.all(8.0), // Padding inside the container
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey,
                  child: const Icon(Icons.image, color: Colors.white),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16)),
                  Text(formattedPrice,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Text('x$quantity'),
          ],
        ),
      ),
    );
  }
}
