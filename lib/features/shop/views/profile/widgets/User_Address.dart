// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/addres_Controller.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';

class AddressUser extends StatefulWidget {
  const AddressUser({super.key});

  @override
  State<AddressUser> createState() => _AddressUserState();
}

class _AddressUserState extends State<AddressUser> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AddRessController addRessController = AddRessController();
  final ShowDialogs showDiaLog = ShowDialogs();
  User? currentUser; // Biến lưu trữ user hiện tại
  List<AddressModel> addresses = []; // Danh sách địa chỉ
  List<String> addressKeys = []; // Lưu các key của địa chỉ

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Lấy thông tin người dùng
  }

  // Lấy thông tin userId hiện tại
  void _getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
    });
    if (user != null) {
      loadDataFromFirebase(user.uid); // Gọi hàm load dữ liệu theo userId
    }
  }

  // Hàm tải dữ liệu địa chỉ từ Firebase Realtime Database dựa theo userId
  void loadDataFromFirebase(String userId) {
    _database.child('users/$userId/addresses').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          addresses = data.entries
              .map((e) => AddressModel.fromMap(Map<String, dynamic>.from(
                  e.value))) // Sử dụng AddressModel.fromMap
              .toList();
          addressKeys = data.keys
              .cast<String>()
              .toList(); // Ép kiểu danh sách key sang List<String>
        });
      }
    });
  }

  // Hàm mở showDialog để nhập địa chỉ mới hoặc chỉnh sửa địa chỉ
  void showAddOrEditAddressDialog({
    key,
    String? name,
    String? phoneNumber,
    String? address,
  }) {
    String newName = name ?? '';
    String newPhoneNumber = phoneNumber ?? '';
    String newAddress = address ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(key == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Tên",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: TextEditingController(text: newName),
                  onChanged: (value) {
                    newName = value;
                  },
                ),
                gapH16,
                TextField(
                  decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  controller: TextEditingController(text: newPhoneNumber),
                  onChanged: (value) {
                    newPhoneNumber = value;
                  },
                ),
                gapH16,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Địa chỉ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: TextEditingController(text: newAddress),
                        onChanged: (value) {
                          newAddress = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_on, color: Colors.blue),
                      onPressed: () async {
                        Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                        setState(() {
                          newAddress =
                              "${position.latitude}, ${position.longitude}";
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty &&
                    newPhoneNumber.isNotEmpty &&
                    newAddress.isNotEmpty &&
                    currentUser != null) {
                  if (key == null) {
                    addRessController.addAddressToFirebase(
                        currentUser!.uid, newName, newPhoneNumber, newAddress);
                  } else {
                    addRessController.editAddressInFirebase(currentUser!.uid,
                        key, newName, newPhoneNumber, newAddress);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
  // Hàm thêm địa chỉ vào Firebase theo userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
        ),
        title: const Text("Địa chỉ của tôi"),
        centerTitle: true,
      ),
      body: addresses.isNotEmpty
          ? ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final addressKey = addressKeys[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(address.nameAddresUser),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số điện thoại: ${address.phoneAddresUser}'),
                        Text('Địa chỉ: ${address.addressUser}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => {
                            showAddOrEditAddressDialog(
                              key: addressKey,
                              name: address.nameAddresUser,
                              phoneNumber: address.phoneAddresUser,
                              address: address.addressUser,
                            )
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 25,
                          ),
                        ),
                        gapH6,
                        GestureDetector(
                          onTap: () => {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Xóa địa chỉ'),
                                  content: const Text(
                                      'Bạn có chắc chắn muốn xóa địa chỉ này không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addRessController
                                            .deleteAddressInFirebase(
                                                currentUser!.uid, addressKey);
                                        setState(() {
                                          addresses.removeAt(index);
                                          addressKeys.removeAt(index);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('Không có địa chỉ nào được lưu.'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddOrEditAddressDialog();
        },
        tooltip: 'Thêm địa chỉ mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
