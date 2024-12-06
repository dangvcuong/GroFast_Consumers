import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';

class Order {
  final String id; // ID đơn hàng
  final String userId; // ID người dùng
  final List<Product> products; // Danh sách sản phẩm trong đơn hàng
  final String totalAmount; // Tổng tiền của đơn hàng
  final String tong;
  final String orderStatus; // Trạng thái đơn hàng
  final DateTime orderDate; // Ngày đặt hàng
  final AddressModel shippingAddress; // Địa chỉ giao hàng
  final String review;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.tong,
    required this.orderStatus,
    required this.orderDate,
    required this.shippingAddress,
    required this.review,
  });

  // Tạo Order từ Map
  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      products: (map['products'] as List<dynamic>)
          .map((productMap) =>
              Product.fromMap(productMap as Map<String, dynamic>, ''))
          .toList(),
      totalAmount: map['totalAmount'] ?? '0',
      tong: map['tong'] ?? '0',
      orderStatus: map['orderStatus'] ?? 'pending',
      orderDate: DateTime.parse(map['orderDate']),
      shippingAddress: AddressModel.fromMap(map['shippingAddress']),
      review: map['review'] ?? '',
    );
  }

  // Chuyển Order thành Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'products': products.map((product) => product.toMap()).toList(),
      'totalAmount': totalAmount,
      'tong': tong,
      'orderStatus': orderStatus,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddress': shippingAddress.toMap(),
      'review': review,
    };
  }
}

Future<List<Order>> getOrdersByUserIdAndStatus(
    String userId, String status) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot snapshot = await firestore
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .where('orderStatus', isEqualTo: status)
      .get();

  return snapshot.docs.map((doc) {
    return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }).toList();
}
