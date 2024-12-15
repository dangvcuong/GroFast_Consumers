// ignore_for_file: file_names, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/ReviewPage_screen.dart';

class EvaluateScreen extends StatefulWidget {
  const EvaluateScreen({super.key});

  @override
  State<EvaluateScreen> createState() => _EvaluateScreenState();
}

class _EvaluateScreenState extends State<EvaluateScreen> {
  List<Map<String, dynamic>> _successfulProducts = [];
  bool _isLoading = true;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchSuccessfulOrderProducts(user!.uid);
  }

  Future<void> fetchSuccessfulOrderProducts(String userId) async {
    final databaseRef = FirebaseDatabase.instance.ref("orders");

    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> successfulProducts = [];

        // Duyệt qua tất cả các đơn hàng
        Map<dynamic, dynamic> orders = snapshot.value as Map<dynamic, dynamic>;
        orders.forEach((orderId, orderData) {
          // Your condition for successful orders
          if (orderData["orderStatus"] == "Thành công" &&
              orderData["userId"] == userId &&
              orderData['review'] == '') {
            List<dynamic> products = orderData["products"] ?? [];
            for (var product in products) {
              successfulProducts.add({
                "orderId": orderId, // Store the orderId here
                ...Map<String, dynamic>.from(product),
              });
            }
          }
        });

        // Cập nhật danh sách sản phẩm và trạng thái loading
        setState(() {
          _successfulProducts = successfulProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Không có dữ liệu.");
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Lỗi khi lấy dữ liệu: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đánh giá',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _successfulProducts.isEmpty
              ? const Center(
                  child: Text(
                    "Không có sản phẩm nào trong đơn hàng thành công.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _successfulProducts.length,
                  itemBuilder: (context, index) {
                    final product = _successfulProducts[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.network(
                          product["imageUrl"] ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        title: Text(product["name"] ?? "No Name"),
                        subtitle: Text(
                          "Giá: ${product["price"]} VNĐ\nSố lượng: ${product["quantity"]}",
                        ),
                        trailing: const Text(
                          "Đánh giá",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          // Chuyển sang trang đánh giá và truyền id sản phẩm
                          final orderId = product['orderId'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                productId: product["id"],
                                ten: '',
                                gia: '',
                              ),
                            ),
                          ).then((_) {
                            fetchSuccessfulOrderProducts(user!.uid);
                          });
                          print("IDSANPHAM: $product[id]");
                          print("IDSANPHAM: $orderId");
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
