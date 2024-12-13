class Voucher {
  String id = "";
  String name;
  String discount;
  String ngayHetHan;
  String ngayTao;
  String soluong;
  String status;

  Voucher({
    required this.name,
    required this.discount,
    required this.ngayHetHan,
    required this.ngayTao,
    required this.soluong,
    required this.status,
  });

  // Convert Voucher object to a map (for Firestore or API purposes)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'discount': discount,
      'ngayHetHan': ngayHetHan,
      'ngayTao': ngayTao,
      'soluong': soluong,
      'status': status,
    };
  }

  // Factory constructor to create Voucher object from Firestore data (or JSON)
  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      name: map['name'] ?? '',
      discount: map['discount'] ?? '',
      ngayHetHan: map['ngayHetHan'] ?? '',
      ngayTao: map['ngayTao'] ?? '',
      soluong: map['soluong'] ?? '',
      status: map['status'] ?? '',
    );
  }


}
