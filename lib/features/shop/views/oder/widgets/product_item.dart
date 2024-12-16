import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/ReviewPage_screen.dart';
import 'package:intl/intl.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String price;
  final String quantity;
  final String status; // Thêm trạng thái đơn hàng

  const ProductItem({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.quantity,
    required this.status, // Truyền trạng thái đơn hàng
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
              width: 70,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
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
                  Text('Số lượng: $quantity'),
                ],
              ),
            ),
            // Kiểm tra trạng thái đơn hàng
            if (status == "Thành công")
              GestureDetector(
                onTap: () {
                  // Chuyển sang màn hình đánh giá
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        productId: id,
                        ten: name,
                        gia: price,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Đánh giá',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
