// ignore_for_file: file_names

class UserModel {
  String id;
  String name;
  String phoneNumber;
  String email;
  List<String> address; // Danh sách địa chỉ
  String image;
  String dateCreated;
  String status;
  int balance;
  String userDeviceToken;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.image,
    required this.dateCreated,
    required this.status,
    required this.balance,
    required this.userDeviceToken,
  });

  // Tạo phương thức để chuyển đổi từ Map (dữ liệu từ Firebase) sang UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      address:
          List<String>.from(map['address'] ?? []), // Đảm bảo là List<String>
      image: map['image'] ?? '',
      dateCreated: map['dateCreated'] ?? '',
      status: map['status'] ?? '',
      balance: map['balance'] != null
          ? map['balance'] as int
          : 0, // Kiểm tra nếu 'balance' có dữ liệu hợp lệ
      userDeviceToken: map['userDeviceToken'] ?? '',
    );
  }

  // Tạo phương thức để chuyển từ UserModel sang Map (để lưu vào Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address, // Sẽ tự động chuyển thành List<String>
      'image': image,
      'dateCreated': dateCreated,
      'status': status,
      'balance': balance,
      'userDeviceToken': userDeviceToken,
    };
  }

  // Tạo phương thức để chuyển đổi từ JSON (đối tượng) sang UserModel
  static UserModel fromJson(Map<String, dynamic> userData) {
    return UserModel(
      id: userData['id'] ?? '',
      name: userData['name'] ?? '',
      phoneNumber: userData['phoneNumber'] ?? '',
      email: userData['email'] ?? '',
      address: List<String>.from(
          userData['address'] ?? []), // Đảm bảo là List<String>
      image: userData['image'] ?? '',
      dateCreated: userData['dateCreated'] ?? '',
      status: userData['status'] ?? '',
      balance: userData['balance'] != null
          ? userData['balance'] as int
          : 0, // Kiểm tra nếu 'balance' có dữ liệu hợp lệ
      userDeviceToken: userData['userDeviceToken'] ?? '',
    );
  }

  // Phương thức để tạo một đối tượng UserModel rỗng
  static UserModel empty() => UserModel(
        id: '',
        name: '',
        email: '',
        phoneNumber: '',
        address: [], // Khởi tạo là danh sách trống
        image: '',
        dateCreated: '',
        status: '',
        balance: 0, userDeviceToken: '',
      );
}
