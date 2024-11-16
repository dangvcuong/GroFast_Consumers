// ignore_for_file: unused_local_variable, file_names, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/addres_Controller.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/shop/views/pay/pay_cart_screen.dart';
import 'package:grofast_consumers/features/showdialogs/show_dialogs.dart';
import 'package:geocoding/geocoding.dart';

class AddressUser extends StatefulWidget {
  const AddressUser({super.key});

  @override
  State<AddressUser> createState() => _AddressUserState();
}

class _AddressUserState extends State<AddressUser> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AddRessController addRessController = AddRessController();
  final ShowDialogs showDiaLog = ShowDialogs();

  User? currentUser;
  List<AddressModel> addresses = [];
  List<String> addressKeys = [];
  String? defaultAddressKey;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: avoid_print
        print('Location permissions are denied');
      }
    }
  }

  void _getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
    });
    if (user != null) {
      loadDataFromFirebase(user.uid);
    }
  }

  void loadDataFromFirebase(String userId) {
    _database.child('users/$userId/addresses').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          addresses = data.entries
              .map((e) =>
                  AddressModel.fromMap(Map<String, dynamic>.from(e.value)))
              .toList();
          addressKeys = data.keys.cast<String>().toList();
        });
      }
    });
  }

  void showAddOrEditAddressDialog({
    String? key,
    String? name,
    String? phoneNumber,
    String? address,
  }) {
    nameController.text = name ?? '';
    phoneController.text = phoneNumber ?? '';
    addressController.text = address ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            key == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Tên",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    controller: nameController,
                  ),
                ),

                // Số điện thoại
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Số điện thoại",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                  ),
                ),

                // Địa chỉ và Icon lấy vị trí
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Địa chỉ",
                            labelStyle:
                                const TextStyle(color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          controller: addressController,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on, color: Colors.blue),
                        onPressed: () async {
                          try {
                            Position position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                              position.latitude,
                              position.longitude,
                            );
                            if (placemarks.isNotEmpty) {
                              Placemark place = placemarks[0];
                              String fullAddress =
                                  '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
                              setState(() {
                                addressController.text = fullAddress;
                              });
                            }
                          } catch (e) {
                            print("Error: $e");
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Nút Hủy
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Hủy'),
            ),
            // Nút Lưu
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    currentUser != null) {
                  if (key == null) {
                    addRessController.addAddressToFirebase(
                        currentUser!.uid,
                        nameController.text,
                        phoneController.text,
                        addressController.text);
                  } else {
                    addRessController.editAddressInFirebase(
                        currentUser!.uid,
                        key,
                        nameController.text,
                        phoneController.text,
                        addressController.text);
                  }
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultAddress(String key) async {
    for (int i = 0; i < addressKeys.length; i++) {
      final addressKey = addressKeys[i];
      final newStatus = addressKey == key ? 'on' : 'off';

      // Cập nhật trạng thái trong danh sách tạm thời
      setState(() {
        addresses[i] = addresses[i].copyWith(status: newStatus);
      });

      // Cập nhật trạng thái trong Firebase
      await _database
          .child('users/${currentUser!.uid}/addresses/$addressKey')
          .update({'status': newStatus});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        actions: const [],
      ),
      body: addresses.isNotEmpty
          ? ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final addressKey = addressKeys[index];

                // Kiểm tra trạng thái
                Color buttonColor =
                    address.status == 'on' ? Colors.green[300]! : Colors.grey;

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
                        ElevatedButton(
                          onPressed: () async {
                            _setDefaultAddress(addressKey);
                            addRessController.editStatus(
                              currentUser!.uid,
                              addressKey,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5),
                            backgroundColor: address.status == 'on'
                                ? Colors.green[300]!
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Mặc định',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
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
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setModalState) {
                                    return Container(
                                      padding: const EdgeInsets.all(16.0),
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Bạn có chắc chắn muốn xóa địa chỉ này?',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Nút Hủy
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                icon: const Icon(Icons.cancel,
                                                    color: Colors.red),
                                                iconSize: 30,
                                              ),
                                              const SizedBox(width: 30),
                                              // Nút Xóa
                                              IconButton(
                                                onPressed: () {
                                                  addRessController
                                                      .deleteAddressInFirebase(
                                                          currentUser!.uid,
                                                          addressKey);
                                                  setState(() {
                                                    addresses.removeAt(index);
                                                    addressKeys.removeAt(index);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.blue),
                                                iconSize: 30,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            )
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
          : const Center(child: Text('Bạn chưa có địa chỉ nào!')),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(left: 25), // Thêm khoảng cách từ dưới lên
        child: Align(
          alignment: Alignment.bottomCenter, // Căn giữa nút dưới cùng
          child: FloatingActionButton.extended(
            onPressed: () {
              showAddOrEditAddressDialog();
            },
            backgroundColor: Colors.blueAccent, // Màu nền
            elevation: 8.0, // Độ nổi bật
            shape: RoundedRectangleBorder(
              // Hình dạng
              borderRadius: BorderRadius.circular(16), // Góc bo tròn
            ),
            icon: const SizedBox.shrink(), // Không hiển thị icon
            label: const Text(
              "Thêm địa chỉ mới", // Hiển thị văn bản thay vì icon
              style: TextStyle(
                color: Colors.white, // Màu văn bản
                fontWeight: FontWeight.bold, // Đậm
                fontSize: 16.0, // Kích thước văn bản
              ),
            ),
          ),
        ),
      ),
    );
  }
}
