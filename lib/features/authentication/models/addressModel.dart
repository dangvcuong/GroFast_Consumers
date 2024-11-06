// ignore_for_file: file_names

class AddressModel {
  final String nameAddresUser;
  final String phoneAddresUser;
  final String addressUser;
  final String status; // Giữ nguyên final

  AddressModel({
    required this.nameAddresUser,
    required this.phoneAddresUser,
    required this.addressUser,
    this.status = 'off', // Mặc định là 'off'
  });

  AddressModel copyWith({String? status}) {
    return AddressModel(
      nameAddresUser: nameAddresUser,
      phoneAddresUser: phoneAddresUser,
      addressUser: addressUser,
      status: status ?? this.status, // Cập nhật trạng thái nếu có
    );
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      nameAddresUser: map['nameAddresUser'] ?? '',
      phoneAddresUser: map['phoneAddresUser'] ?? '',
      addressUser: map['addressUser'] ?? '',
      status: map['status'] ?? 'off',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameAddresUser': nameAddresUser,
      'phoneAddresUser': phoneAddresUser,
      'addressUser': addressUser,
      'status': status,
    };
  }

  // Thêm phương thức toString
  @override
  String toString() {
    return 'AddressModel(nameAddresUser: $nameAddresUser, phoneAddresUser: $phoneAddresUser, addressUser: $addressUser, status: $status)';
  }
}
