// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/shop/models/order_model.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/views/oder/oder_screen.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher_list_screen.dart';
import 'package:intl/intl.dart';

import '../oder/OrderSuccessScreen.dart';

class PaymentScreen extends StatefulWidget {
  final List<Product> products;
  final int quantity;
  const PaymentScreen({
    super.key,
    required this.products,
    required this.quantity,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  double totalAmount = 0;
  int _selectedShippingOption = 1;
  int _selectedPaymentMethod = 1;
  int shippingFee = 0; // Phí giao hàng ban đầu là 10.000đ cho "Ưu tiên"
  DateTime? selectedDeliveryDate;
  User? currentUser;
  List<AddressModel> addresses = [];
  AddressModel? defaultAddress;
  double total = 0;
  double walletBalance = 0.0;
  final Login_Controller loginController = Login_Controller();
  late int soluong;
  String? selectedVoucher;
  String? nameVoucher;
  String? giamgia;
  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchAddresses();
    _getBalanceAndSet();
    _updateTotal();
    _updateShippingFee(1);
  }

  void _updateShippingFee(int option) {
    setState(() {
      switch (option) {
        case 1:
          shippingFee = 10000; // Ưu tiên
          break;
        case 2:
          shippingFee = 20000; // Đặt lịch
          break;
      }
      _selectedShippingOption = option;
      _updateTotal();
    });
  }

  Future<void> _selectVoucher() async {
    final selectedVoucherData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoucherListScreen()),
    );

    print("Voucher đã chọn: $selectedVoucherData");

    if (selectedVoucherData != null && selectedVoucherData is Map) {
      // Kiểm tra chắc chắn rằng selectedVoucherData là một Map
      print("Tên Voucher: ${selectedVoucherData['name']}");
      nameVoucher = selectedVoucherData['name'];
      var discount = selectedVoucherData['discount'];
      giamgia = selectedVoucherData['discount'];
      print("Kiểu dữ liệu của giảm giá: ${discount.runtimeType}");

      if (discount == null) {
        print("Giảm giá không hợp lệ");
        return; // Trả về nếu không có giá trị giảm giá hợp lệ
      }

      // Chuyển đổi discount thành kiểu số nếu cần thiết
      if (discount is String) {
        discount = double.tryParse(discount) ?? 0; // Chuyển đổi chuỗi thành số
      }

      // Kiểm tra nếu discount là kiểu số hợp lệ
      if (discount is num) {
        print("Giảm giá: $discount");

        double discountValue =
            discount / 100 * total; // Áp dụng giảm giá vào tổng tiền

        setState(() {
          selectedVoucher = selectedVoucherData['name']; // Cập nhật tên voucher
          total = total - discountValue; // Cập nhật tổng tiền
        });

        print("Giá trị giảm giá: $discountValue");
        print("Tổng tiền sau khi giảm: $total");
      } else {
        print("Giảm giá không phải là số hợp lệ");
      }
    } else {
      print("Dữ liệu voucher không hợp lệ");
    }
  }

  Future<double> _geBalance() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final databaseRef = FirebaseDatabase.instance.ref('users/$userId/balance');
    final snapshot = await databaseRef.get();

    if (snapshot.exists) {
      // Kiểm tra nếu giá trị là int, chuyển đổi thành double
      if (snapshot.value is int) {
        return (snapshot.value as int).toDouble();
      } else if (snapshot.value is double) {
        return snapshot.value as double;
      } else {
        return 0.0; // Trường hợp không phải int hoặc double
      }
    } else {
      return 0.0; // Trả về 0 nếu không có số dư ví
    }
  }

  void _getBalanceAndSet() async {
    walletBalance = await _geBalance(); // Gọi _geBalance và chờ kết quả
    setState(() {
      // Cập nhật lại giao diện nếu cần thiết
    });
    print("Tièn ví $walletBalance"); // Hiển thị giá trị walletBalance
  }

  void _updateTotal() {
    setState(() {
      // Nếu phương thức thanh toán là Ví GroFast (giả sử phương thức này có giá trị 2)
      totalAmount = widget.products.fold(0, (sum, item) {
        return sum + (int.parse(item.price.toString()) * widget.quantity);
      });
      double giam = double.tryParse(giamgia.toString()) ?? 0.0;
      if (_selectedPaymentMethod == 2) {
        // Kiểm tra nếu ví đủ tiền (số dư ví + phí giao hàng)
        if (walletBalance >= total) {
          total = 0.0; // Nếu ví đủ tiền, tổng cộng là 0
        } else {
          loginController.ThongBao(context, "Số dư ví của bạn không đủ");
          _selectedPaymentMethod = 1;
          if (giam == 0) {
            // Nếu thanh toán bằng tiền mặt
            total = totalAmount + shippingFee;
          } else {
            double tong = totalAmount + shippingFee;
            double giamgia = (totalAmount + shippingFee) * giam / 100;
            total = tong - giamgia;
          }
        }
      } else {
        if (giam == 0) {
          total = totalAmount + shippingFee;
          print("Gia chua giam: $total");
        } else {
          double tong = totalAmount + shippingFee;
          double giamgia = (totalAmount + shippingFee) * giam / 100;
          total = tong - giamgia;
          // print(
          //     "Gia da giam: $total, Gia tong san pham: ${totalAmount + shippingFee}, Giam: $giamgia");
        }
      }
    });
  }

  Future<void> _showPasswordBottomSheet(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false; // Biến trạng thái ẩn/hiện mật khẩu

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Không cho phép đóng khi nhấn ra ngoài
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Bo tròn góc của dialog
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Giới hạn chiều cao của Column
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Nhập mật khẩu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Màu tiêu đề
                    ),
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return TextField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordController,
                        obscureText:
                            !isPasswordVisible, // Điều khiển hiển thị mật khẩu
                        decoration: InputDecoration(
                          labelText: "Nhập mật khẩu của bạn",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.red, // Màu cho nút Hủy
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng hộp thoại
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.blue, // Màu cho nút Xác nhận
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          String password = passwordController.text;

                          // Kiểm tra mật khẩu hợp lệ
                          bool isPasswordValid = await _checkPassword(password);

                          if (isPasswordValid) {
                            Navigator.of(context)
                                .pop(); // Đóng hộp thoại khi mật khẩu đúng
                            _updateTotal(); // Tiến hành cập nhật tổng tiền
                          } else {
                            // Thông báo sai mật khẩu
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mật khẩu sai, vui lòng thử lại!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkPassword(String password) async {
    try {
      // Kiểm tra mật khẩu thông qua Firebase Authentication (hoặc cơ sở dữ liệu khác)
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true; // Nếu mật khẩu chính xác
    } catch (e) {
      return false; // Nếu mật khẩu sai
    }
  }

  Future<void> _fetchAddresses() async {
    final userId = currentUser!.uid;
    final databaseRef =
        FirebaseDatabase.instance.ref('users/$userId/addresses');
    final DatabaseEvent event = await databaseRef.once();
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      addresses = data.entries.map((entry) {
        final addressData = entry.value;
        return AddressModel.fromMap({
          'nameAddresUser': addressData['nameAddresUser'],
          'phoneAddresUser': addressData['phoneAddresUser'],
          'addressUser': addressData['addressUser'],
          'status': addressData['status'],
        });
      }).toList();

      defaultAddress = addresses.firstWhere(
        (address) => address.status == 'on',
        orElse: () => AddressModel(
            nameAddresUser: '',
            phoneAddresUser: '',
            addressUser: '',
            status: ''),
      );

      setState(() {});
    }
  }

  void _placeOrder() async {
    soluong = widget.quantity;

    if (defaultAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm địa chỉ giao hàng.')),
      );
      return;
    }

    // Chuyển đổi danh sách CartItem thành Product
    List<Product> products = widget.products.map((cartItem) {
      return Product(
        id: cartItem.id, // Sử dụng productId làm ID của Product
        name: cartItem.name,
        description: cartItem.description,
        imageUrl: cartItem.imageUrl,
        price: cartItem.price,
        evaluate: cartItem.evaluate.toString(),
        quantity: soluong,
        idHang: cartItem.idHang,
        quantitysold: 0,
      );
    }).toList();

    // Tạo đơn hàng
    Order order = Order(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUser!.uid,
      products: products,
      totalAmount: total.toString(),
      orderStatus: 'Đang chờ xác nhận',
      orderDate: DateTime.now(),
      shippingAddress: defaultAddress!,
      tong: (totalAmount + shippingFee).toString(),
    );
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref('orders');

    try {
      // Lưu đơn hàng vào Firebase
      if (_selectedPaymentMethod == 2) {
        double newBalance = walletBalance - (totalAmount + shippingFee);
        DatabaseReference balanceRef =
            FirebaseDatabase.instance.ref('users/${currentUser!.uid}/balance');
        await balanceRef.set(newBalance); // Cập nhật số dư ví mới
      }
      await ordersRef.child(order.id).set(order.toMap());
      loginController.ThongBao(context, 'Vui lòng chờ xác nhận!');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
              orderId: order
                  .id), // Truyền ID đơn hàng vào màn hình OrderSuccessScreen
        ),
      );

      // Xóa từng sản phẩm trong giỏ hàng
    } catch (error) {
      String errorMessage = 'Lỗi không xác định';
      if (error is FirebaseException) {
        errorMessage = error.message ?? 'Lỗi không xác định';
      }
      print('Error occurred: $errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.products);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thanh toán',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin giao hàng', 'Sửa', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressUser()),
              ).then((_) {
                _fetchAddresses();
              });
            }),
            const SizedBox(height: 8.0),
            _buildAddressCard(),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Phương thức giao hàng'),
            _buildShippingOptions(),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Phương thức thanh toán'),
            _buildPaymentMethods(),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Chi tiết đơn hàng'),
            _buildOrderDetails(),
            const SizedBox(height: 16.0),
            _buildDiscountSection(),
            const Divider(thickness: 1, height: 32.0),
          ],
        ),
      ),
      bottomNavigationBar: _buildTotalAndCheckoutButton(),
    );
  }

  Widget _buildSectionTitle(String title,
      [String? actionText, VoidCallback? onEdit]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (actionText != null && onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Text(actionText, style: const TextStyle(color: Colors.blue)),
          ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              defaultAddress?.nameAddresUser ?? 'Tên không xác định',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(defaultAddress?.phoneAddresUser ?? 'SĐT không xác định'),
            const SizedBox(height: 4.0),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                      defaultAddress?.addressUser ?? 'Địa chỉ không xác định'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOptions() {
    return Column(
      children: [
        _buildShippingOptionTile('Tiết kiệm', 1, '(+10.000đ)'),
        _buildShippingOptionTile('Nhanh', 2, '(+20.000đ)'),
      ],
    );
  }

  Widget _buildShippingOptionTile(String title, int value, String subtitle,
      {bool showDatePicker = false}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Radio(
        value: value,
        groupValue: _selectedShippingOption,
        onChanged: (int? option) {
          if (option != null) {
            _updateShippingFee(option);
          }
        },
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        ListTile(
          title: const Text('Tiền mặt'),
          leading: Radio(
            value: 1,
            groupValue: _selectedPaymentMethod,
            onChanged: (int? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Ví GroFast'),
          leading: Radio(
            value: 2,
            groupValue: _selectedPaymentMethod,
            onChanged: (int? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
              // Nếu chọn thanh toán bằng ví, gọi hàm cập nhật ví
              if (_selectedPaymentMethod == 2) {
                // Nếu số dư ví đủ, không cần thanh toán thêm
                _showPasswordBottomSheet(context);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tiền hàng (${widget.products.length} sản phẩm):'),
                Text(NumberFormat.currency(locale: 'vi', symbol: 'đ')
                    .format(totalAmount)),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phí giao hàng:'),
                Text(NumberFormat.currency(locale: 'vi', symbol: 'đ')
                    .format(shippingFee)),
              ],
            ),
            const Divider(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    NumberFormat.currency(locale: 'vi', symbol: 'đ')
                        .format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection() {
    return GestureDetector(
      onTap: () {
        _selectVoucher(); // Chọn voucher khi nhấn vào
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.grey),
              const SizedBox(width: 8.0),
              Text(
                nameVoucher?.isEmpty ?? true
                    ? 'Áp dụng mã ưu đãi'
                    : 'Áp dụng mã: $nameVoucher', // Nếu nameVoucher không rỗng, hiển thị tên voucher
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.0,
                  height: 1.5,
                ),
              )
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildTotalAndCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Thêm khoảng cách padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(formatter.format(total),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Đặt hàng',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
