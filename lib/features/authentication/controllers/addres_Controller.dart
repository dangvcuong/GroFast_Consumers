// ignore_for_file: file_names, avoid_print

import 'package:firebase_database/firebase_database.dart';

class AddRessController {
  static final AddRessController _instance = AddRessController._internal();

  // Private constructor
  AddRessController._internal();

  // Factory constructor to return the same instance
  factory AddRessController() {
    return _instance;
  }

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  void addAddressToFirebase(String userId, String nameAddresUser,
      String phoneAddresUser, String addressUser) {
    final newAddressRef = _database
        .child('users/$userId/addresses')
        .push(); // Tạo node địa chỉ mới theo userId
    newAddressRef.set({
      'nameAddresUser': nameAddresUser,
      'phoneAddresUser': phoneAddresUser,
      'addressUser': addressUser,
      'status': 'off'
    });
  }

  // Hàm sửa địa chỉ trong Firebase theo userId và key
  void editAddressInFirebase(String userId, String key, String nameAddresUser,
      String phoneAddresUser, String addressUser) {
    final addressRef = _database.child('users/$userId/addresses/$key');
    addressRef.update({
      'nameAddresUser': nameAddresUser,
      'phoneAddresUser': phoneAddresUser,
      'addressUser': addressUser,
    });
  }

  void editStatus(
    String userId,
    String key,
  ) {
    final addressRef = _database.child('users/$userId/addresses/$key');
    addressRef.update({
      'status': 'on',
    });
    print("Thay đôi mạc định");
  }

  // Hàm xóa địa chỉ trong Firebase theo userId và key
  void deleteAddressInFirebase(String userId, String key) {
    final addressRef = _database.child('users/$userId/addresses/$key');
    addressRef.remove();
  }

  // Thêm địa chỉ vào Realtime Database
}
