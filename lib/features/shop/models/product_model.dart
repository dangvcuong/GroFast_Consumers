class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String evaluate;
  final int quantity;
  final String idHang; // Thêm thuộc tính idHang
  final int quantitysold;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.evaluate,
    required this.quantity,
    required this.quantitysold,
    required this.idHang, // Thêm vào constructor
  });
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['describe'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] is int
          ? map['price']
          : int.tryParse(map['price'].toString()) ??
              0, // Ensure price is an int
      evaluate: map['evaluate'] ?? '0', // Ensure evaluate is a String
      quantity: map['quantity'] is int
          ? map['quantity']
          : int.tryParse(map['quantity'].toString()) ??
              0, // Ensure quantity is an int
      quantitysold: map['quantitysold'] is int
          ? map['quantitysold']
          : 0, // Ensure quantitysold is an int
      idHang: map['id_Hang'] ?? '', // Get id_Hang from Firebase
    );
  }

  // Thêm phương thức toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'describe': description,
      'imageUrl': imageUrl,
      'price': price,
      'evaluate': evaluate,
      'quantity': quantity,
      'quantitysold': quantitysold,
      'id_Hang': idHang,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? price,
    String? evaluate,
    int? quantity,
    int? quantitysold,
    String? idHang,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      evaluate: evaluate ?? this.evaluate,
      quantity: quantity ?? this.quantity,
      quantitysold: quantitysold ?? this.quantitysold,
      idHang: idHang ?? this.idHang,
    );
  }
}
