// ignore_for_file: file_names, unused_import

import 'package:firebase_database/firebase_database.dart';

class AddressModel {
  String id; // ID của địa chỉ
  String nameAddresUser; // Tên người nhận
  String phoneAddresUser; // Số điện thoại
  String addressUser; // Địa chỉ

  AddressModel({
    required this.id,
    required this.nameAddresUser,
    required this.phoneAddresUser,
    required this.addressUser,
  });

  // Phương thức chuyển đổi từ Map sang AddressModel
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      nameAddresUser: map['nameAddresUser'] ?? '',
      phoneAddresUser: map['phoneAddresUser'] ?? '',
      addressUser: map['addressUser'] ?? '',
    );
  }

  // Phương thức chuyển đổi từ AddressModel sang Map (để lưu vào Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAddresUser': nameAddresUser,
      'phoneNumber': phoneAddresUser,
      'addressUser': addressUser,
    };
  }
}
