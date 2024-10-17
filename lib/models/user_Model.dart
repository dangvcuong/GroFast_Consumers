// ignore_for_file: file_names

class UserModel {
  String id;
  String name;
  String phoneNumber;
  String email;
  String image;
  String gioiTinh;
  String ngayTao;
  String trangThai;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.image,
    required this.gioiTinh,
    required this.ngayTao,
    required this.trangThai,
  });

  // Tạo phương thức để chuyển đổi từ Map (dữ liệu từ Firebase) sang UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      gioiTinh: map['gioiTinh'] ?? '',
      ngayTao: map['ngayTao'] ?? '',
      trangThai: map['trangThai'] ?? '',
    );
  }

  // Tạo phương thức để chuyển từ UserModel sang Map (để lưu vào Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'image': image,
      'gioiTinh': gioiTinh,
      'ngayTao': ngayTao,
      'trangThai': trangThai,
    };
  }
}
