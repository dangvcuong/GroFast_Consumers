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
                  controller: nameController,
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
                  controller: phoneController,
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
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultAddress(String key) {
    setState(() {
      defaultAddressKey = key; // Cập nhật địa chỉ mặc định

      // Cập nhật trạng thái của tất cả các địa chỉ
      for (int i = 0; i < addressKeys.length; i++) {
        if (addressKeys[i] == key) {
          addresses[i] =
              addresses[i].copyWith(status: 'on'); // Cập nhật trạng thái
        } else {
          addresses[i] =
              addresses[i].copyWith(status: 'off'); // Cập nhật trạng thái
        }
      }
    });
  }

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
                            backgroundColor:
                                buttonColor, // Sử dụng màu đã kiểm tra
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
          : const Center(child: Text('Bạn chưa có địa chỉ nào!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddOrEditAddressDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
