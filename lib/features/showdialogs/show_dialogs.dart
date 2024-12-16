// ignore_for_file: file_names, unnecessary_import, use_build_context_synchronously, non_constant_identifier_names, depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grofast_consumers/features/authentication/controllers/addres_Controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/pay/pay_screen.dart';
import 'package:provider/provider.dart';

import '../shop/views/favorites/providers/favorites_provider.dart';

class ShowDialogs {
  final UserController userController = UserController();
  final AddRessController addRessController = AddRessController();
  User? currentUser = FirebaseAuth.instance.currentUser;
  final Login_Controller loginController = Login_Controller();
  // Xóa tài khoản
  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String password) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent, // Nền trong suốt
      isScrollControlled: true, // Kiểm soát chiều cao của bottom sheet
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 250, // Chiều cao của bottom sheet
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Xác nhận xóa tài khoản',
                    style: TextStyle(
                      color: Colors.red, // Màu tiêu đề nổi bật
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bạn có chắc chắn muốn xóa tài khoản của mình không?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dòng hành động với các nút
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // Nút Hủy
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng BottomSheet
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      // Nút Xóa
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await userController.deleteUser(password, context);
                            Navigator.of(context).pop(); // Đóng BottomSheet
                          } catch (e) {
                            Navigator.of(context)
                                .pop(); // Đóng BottomSheet nếu có lỗi
                          }
                        },
                        child: const Text(
                          'Xóa',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Đăng xuất
  Future<void> Log_out(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent, // Nền trong suốt
      isScrollControlled:
          true, // Để có thể kiểm soát chiều cao của bottom sheet
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Card(
            elevation: 10, // Thêm bóng cho card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Làm tròn các góc
            ),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Cho phép chiều cao của column điều chỉnh theo nội dung
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Đăng xuất tài khoản',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Bạn có chắc chắn muốn đăng xuất tài khoản của mình không?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Nút hủy
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                    ),
                    // Nút đăng xuất
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red, // Màu nền đỏ
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop(); // Đóng dialog sau khi đăng xuất thành công
                          loginController.ThongBao(
                              context, 'Đăng xuất thành công!');
                        } catch (e) {
                          Navigator.of(context).pop(); // Đóng dialog
                          loginController.ThongBao(
                              context, 'Có lỗi xảy ra khi đăng xuất.');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Xóa sản phẩm yêu thích
  Future<void> showDeleteFavoriteDialog(
      BuildContext context, Product product) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent, // Nền trong suốt
      isScrollControlled:
          true, // Để có thể kiểm soát chiều cao của bottom sheet
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Card(
            elevation: 12, // Thêm bóng cho card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Làm tròn các góc
            ),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Cho phép chiều cao của column điều chỉnh theo nội dung
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Bỏ yêu thích sản phẩm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Bạn có chắc chắn muốn bỏ sản phẩm này khỏi danh sách yêu thích không?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Nút thoát
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                    ),
                    // Nút xác nhận
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red, // Màu nền đỏ
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        try {
                          final favoritesProvider =
                              Provider.of<FavoritesProvider>(context,
                                  listen: false);
                          await favoritesProvider.removeFavorite(product);
                          Navigator.of(context)
                              .pop(); // Đóng dialog sau khi bỏ yêu thích thành công

                          loginController.ThongBao(
                              context, 'Sản phẩm đã được bỏ yêu thích!');
                        } catch (e) {
                          Navigator.of(context).pop(); // Đóng dialog nếu có lỗi

                          loginController.ThongBao(
                              context, 'Có lỗi xảy ra khi bỏ yêu thích.');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addProductToUserCart(String userId, Product product,
      BuildContext context, int quantity) async {
    String errorMessage;
    final DatabaseReference cartRef =
        FirebaseDatabase.instance.ref('users/$userId/carts');
    try {
      final DatabaseEvent event = await cartRef.child(product.id).once();
      if (event.snapshot.value != null) {
        final currentQuantity = (event.snapshot.value as Map)['quantity'] ?? 0;
        await cartRef.child(product.id).update({
          "quantity": currentQuantity + quantity,
        });
        errorMessage = "Đã tăng số lượng sản phẩm trong giỏ hàng!";
      } else {
        await cartRef.child(product.id).set({
          "id": product.id,
          "name": product.name,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "evaluate": product.evaluate,
          "quantity": quantity,
          "idHang": product.idHang,
        });
        errorMessage = "Sản phẩm đã được thêm vào giỏ hàng!";
      }
    } catch (error) {
      errorMessage = "Lỗi khi thêm sản phẩm vào giỏ hàng: $error";
    }
    loginController.ThongBao(context, errorMessage);
  }

  //
  Future<void> showAddCartDialog(
      BuildContext context, Product product, String userId) async {
    int quantity = 1; // Biến lưu trữ số lượng sản phẩm

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent, // Nền trong suốt
      isScrollControlled:
          true, // Để có thể kiểm soát chiều cao của bottom sheet
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 250,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chọn số lượng sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Trừ
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setModalState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                      // Hiển thị số lượng
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nút Cộng
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nút Xác nhận
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        // Thêm sản phẩm vào giỏ hàng với số lượng đã chọn
                        await addProductToUserCart(
                            userId, product, context, quantity);
                        Navigator.of(context).pop(); // Đóng BottomSheet
                      } catch (e) {
                        Navigator.of(context)
                            .pop(); // Đóng BottomSheet nếu có lỗi
                      }
                    },
                    child: const Text(
                      'Thêm vào giỏ hàng',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // mua ngay
  Future<void> buyProductNow(
      String userId, Product product, BuildContext context) async {
    // Đặt giá trị quantity ban đầu là 1
    int quantity = 1;
    List<Product> cartItems = [product];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 250,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chọn số lượng sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Trừ
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setModalState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                      // Hiển thị số lượng
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nút Cộng
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.blue),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nút Xác nhận mua ngay
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Đóng BottomSheet và chuyển đến màn hình thanh toán với số lượng đã chọn
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            products: cartItems.map((product) {
                              // Cập nhật số lượng của sản phẩm trong giỏ hàng
                              Product updatedProduct = product.copyWith(
                                quantity: quantity, // Sử dụng quantity đã chọn
                              );
                              return updatedProduct;
                            }).toList(),
                            quantity: quantity,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Mua ngay',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
