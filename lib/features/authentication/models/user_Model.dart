// ignore_for_file: file_names

class UserModel {
  String id;
  String name;
  String phoneNumber;
  String email;
  String diaChi;
  String image;
  String gioiTinh;
  String ngayTao;
  String trangThai;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.diaChi,
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
      diaChi: map['diaChi'] ?? '',
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
      'diaChi': diaChi,
      'image': image,
      'gioiTinh': gioiTinh,
      'ngayTao': ngayTao,
      'trangThai': trangThai,
    };
  }

  // Tạo phương thức để chuyển đổi từ JSON (đối tượng) sang UserModel
  static UserModel fromJson(Map<String, dynamic> userData) {
    return UserModel(
      id: userData['id'] ?? '', // Cung cấp giá trị mặc định nếu không có
      name: userData['name'] ?? '',
      phoneNumber: userData['phoneNumber'] ?? '',
      email: userData['email'] ?? '',
      diaChi: userData['diaChi'] ?? '',
      image: userData['image'] ?? '',
      gioiTinh: userData['gioiTinh'] ?? '',
      ngayTao: userData['ngayTao'] ?? '',
      trangThai: userData['trangThai'] ?? '',
    );
  }

  // factory UserModel.empty() {
  //   return UserModel(
  //     id: '',
  //     name: '',
  //     phoneNumber: '',
  //     email: '',
  //     diaChi: '',
  //     image: '',
  //     gioiTinh: '',
  //     ngayTao: '',
  //     trangThai: '',
  //   );
  // }
  static UserModel empty() => UserModel(
        id: '',
        name: '',
        email: '',
        phoneNumber: '',
        diaChi: '',
        image: '',
        gioiTinh: '',
        ngayTao: '',
        trangThai: '',
      );
}
