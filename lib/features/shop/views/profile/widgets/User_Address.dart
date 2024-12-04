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
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Future<void> fetchAddressFromCoordinates(double latitude, double longitude,
  //     TextEditingController addressController) async {
  //   const String apiKey =
  //       'AIzaSyDNxAxXj6JheBPM66aMpcG-FnI9zkLwobE'; // Thay bằng API Key của bạn
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  //   try {
  //     // Gửi yêu cầu HTTP đến Google Maps API
  //     final response = await http.get(Uri.parse(url));

  //     // Kiểm tra mã trạng thái HTTP
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       // In ra toàn bộ phản hồi từ API để kiểm tra thông tin chi tiết
  //       print("Response from Google API: $data");

  //       // Kiểm tra nếu có kết quả trả về
  //       if (data['results'].isNotEmpty) {
  //         // Lấy địa chỉ đầy đủ từ kết quả
  //         String fullAddress = data['results'][0]['formatted_address'];

  //         // In ra địa chỉ
  //         print('Full Address: $fullAddress');

  //         // Cập nhật ô input (TextField)
  //         addressController.text = fullAddress;
  //       } else {
  //         print('No results found.');
  //       }
  //     } else {
  //       print('Failed to fetch address. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching address: $e');
  //   }
  // }

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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                key == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên

                  TextField(
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
                  gapH20,
                  // Số điện thoại
                  TextField(
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
                  gapH20,
                  // Địa chỉ và Icon lấy vị trí
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Địa chỉ",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.location_on, color: Colors.blue),
                        onPressed: () async {
                          try {
                            // Position position =
                            //     await Geolocator.getCurrentPosition(
                            //   desiredAccuracy: LocationAccuracy.high,
                            // );

                            // print(
                            //     "Latitude: ${position.latitude}, Longitude: ${position.longitude}");

                            // fetchAddressFromCoordinates(position.latitude,
                            //     position.longitude, addressController);
                            // Lấy vị trí hiện tại
                            Position position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );

                            // Lấy thông tin địa điểm từ tọa độ
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                              position.latitude,
                              position.longitude,
                            );
                            if (placemarks.isNotEmpty) {
                              Placemark place = placemarks[0];

                              // Xây dựng địa chỉ đầy đủ
                              String fullAddress = [
                                place.street, // Số nhà, tên đường
                                place.subLocality, // Tên làng/xóm/thôn
                                place
                                    .locality, // Xã hoặc thành phố (nếu xã không có)
                                place.subAdministrativeArea, // Huyện
                                place.administrativeArea, // Tỉnh/Thành phố
                                place.country, // Quốc gia
                              ]
                                  .where((element) =>
                                      element != null && element.isNotEmpty)
                                  .join(', ');

                              setState(() {
                                addressController.text =
                                    fullAddress; // Hiển thị địa chỉ
                              });
                            }
                          } catch (e) {
                            print("Error: $e");
                          }
                        },
                      ),
                    ),
                    controller: addressController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: OutlinedButton(
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
                        addressController.text,
                      );
                    } else {
                      addRessController.editAddressInFirebase(
                        currentUser!.uid,
                        key,
                        nameController.text,
                        phoneController.text,
                        addressController.text,
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, // Màu chữ
                  side: const BorderSide(color: Colors.blueAccent), // Viền nút
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bo góc
                  ),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.only(top: 20),
          actionsPadding: const EdgeInsets.only(bottom: 20),
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
        title: const Text('Địa chỉ của tôi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: addresses.isNotEmpty
          ? ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final addressKey = addressKeys[index];

                return Dismissible(
                  key: Key(addressKey),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    addRessController.deleteAddressInFirebase(
                        currentUser!.uid, addressKey);
                    setState(() {
                      addresses.removeAt(index);
                      addressKeys.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa địa chỉ!')),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Khi click vào item, mở dialog để chỉnh sửa
                      showAddOrEditAddressDialog(
                        key: addressKey,
                        name: address.nameAddresUser,
                        phoneNumber: address.phoneAddresUser,
                        address: address.addressUser,
                      );
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            address.nameAddresUser,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Số điện thoại: ${address.phoneAddresUser}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Địa chỉ: ${address.addressUser}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  _setDefaultAddress(addressKey);
                                  addRessController.editStatus(
                                    currentUser!.uid,
                                    addressKey,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  backgroundColor: address.status == 'on'
                                      ? Colors.green[300]
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
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
