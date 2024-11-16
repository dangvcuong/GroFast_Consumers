class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String price;
  final String evaluate;
  final String quantity;
  final String idHang; // Thêm thuộc tính idHang

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.evaluate,
    required this.quantity,
    required this.idHang, // Thêm vào constructor
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['describe'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] ?? '0',
      evaluate: map['evaluate'] ?? '0',
      quantity: map['quantity'] ?? '0',
      idHang: map['id_Hang'] ?? '', // Lấy id_Hang từ Firebase
    );
  }

  // Thêm phương thức toMap
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'describe': description,
      'imageUrl': imageUrl,
      'price': price,
      'evaluate': evaluate,
      'quantity': quantity,
      'id_Hang': idHang,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? price,
    String? evaluate,
    int? quantity,
    String? idHang,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      evaluate: evaluate ?? this.evaluate,
      quantity: (quantity ?? this.quantity).toString(),
      idHang: idHang ?? this.idHang,
    );
  }
}
