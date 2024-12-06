import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String discount;
  final String name;
  final String ngayHetHan;
  final String ngayTao;
  final String soluong;
  final String status;

  Voucher({
    required this.discount,
    required this.name,
    required this.ngayHetHan,
    required this.ngayTao,
    required this.soluong,
    required this.status,
  });

  // Sử dụng DocumentSnapshot để lấy dữ liệu từ Firestore
  factory Voucher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Voucher(
      discount: data['discount'] ?? '',
      name: data['name'] ?? '',
      ngayHetHan: data['ngayHetHan'] ?? '',
      ngayTao: data['ngayTao'] ?? '',
      soluong: data['soluong'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
