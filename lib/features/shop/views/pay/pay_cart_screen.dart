// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/authentication/models/addressModel.dart';
import 'package:grofast_consumers/features/shop/models/order_model.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/cart/providers/cart_provider.dart';
import 'package:grofast_consumers/features/shop/views/oder/OrderSuccessScreen.dart';
import 'package:grofast_consumers/features/shop/views/oder/oder_screen.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher_list_screen.dart';
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:intl/intl.dart';

class PaymentCartScreen extends StatefulWidget {
  final List<CartItem> products;
  final String? selectedVouchers;

  const PaymentCartScreen(
      {super.key, required this.products, this.selectedVouchers});

  @override
  _PaymentCartScreenState createState() => _PaymentCartScreenState();
}

class _PaymentCartScreenState extends State<PaymentCartScreen> {
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
  final CartProvider cartProvider = CartProvider();
  final Login_Controller loginController = Login_Controller();
  String idProduct = '';
  String? selectedVoucher;
  double discountValue = 0;
  List<Voucher> vouchers = [];
  double walletBalance = 0.0;
  @override
  void initState() {
    super.initState();
    currentUser =
        FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng hiện tại
    _fetchAddresses(); // Gọi hàm để lấy địa chỉ
    _applyVoucher();
    _getBalanceAndSet();
    _updateTotal();
    _updateShippingFee(1);
  }

  void _updateShippingFee(int option) {
    setState(() {
      switch (option) {
        case 1:
          shippingFee = 10000; // Phí 10.000đ cho "Ưu tiên"
          break;
        case 2:
          shippingFee = 20000; // Miễn phí cho "Tiêu chuẩn"
          break;
      }
      _selectedShippingOption =
          option; // Cập nhật phương thức giao hàng đã chọn
      _updateTotal(); // Cập nhật lại tổng sau khi thay đổi phương thức giao hàng
    });
  }

  void _applyVoucher() {
    if (widget.selectedVouchers != null) {
      final voucher = widget.selectedVouchers!;
      if (voucher == 'freeship') {
        shippingFee = 0;
      } else if (voucher.endsWith('%')) {
        final discount = int.parse(voucher.replaceAll('%', ''));
        shippingFee = (shippingFee * (1 - discount / 100)).round();
      }
    }
    setState(() {
      totalAmount = widget.products.fold(0.0,
              (sum, cartItem) => sum + (cartItem.price * cartItem.quantity)) +
          shippingFee;
    });
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
              // Sử dụng SingleChildScrollView để cuộn
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
                  TextField(
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

  void _updateTotal() {
    setState(() {
      // Nếu phương thức thanh toán là Ví GroFast (giả sử phương thức này có giá trị 2)
      if (_selectedPaymentMethod == 2) {
        // Kiểm tra nếu ví đủ tiền (số dư ví + phí giao hàng)
        if (walletBalance >= totalAmount + shippingFee) {
          total = 0.0; // Nếu ví đủ tiền, tổng cộng là 0
        } else {
          loginController.ThongBao(context, "Số dư ví của bạn không đủ");
        }
      } else {
        // Nếu thanh toán bằng tiền mặt
        total = totalAmount + shippingFee;
      }
    });
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

      // Kiểm tra xem có địa chỉ nào có trạng thái 'on' không
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
    if (defaultAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm địa chỉ giao hàng.')),
      );
      return;
    }

    // Kiểm tra số dư ví trước khi đặt hàng
    if (_selectedPaymentMethod == 2) {
      if (walletBalance < totalAmount + shippingFee) {
        return; // Nếu số dư ví không đủ, không cho phép đặt hàng
      }
    }

    // Chuyển đổi danh sách CartItem thành Product
    List<Product> products = widget.products.map((cartItem) {
      return Product(
        id: cartItem.productId, // Sử dụng productId làm ID của Product
        name: cartItem.name,
        description: cartItem.description,
        imageUrl: cartItem.imageUrl,
        price: cartItem.price.toInt(),
        evaluate: cartItem.evaluate.toString(),
        quantity: cartItem.quantity,
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
      review: "",
    );

    DatabaseReference ordersRef = FirebaseDatabase.instance.ref('orders');

    try {
      // Lưu đơn hàng vào Firebase
      await ordersRef.child(order.id).set(order.toMap());
      loginController.ThongBao(context, 'Vui lòng chờ xác nhận!');

      // Cập nhật số dư ví của người dùng
      if (_selectedPaymentMethod == 2) {
        double newBalance = walletBalance - (totalAmount + shippingFee);
        DatabaseReference balanceRef =
            FirebaseDatabase.instance.ref('users/${currentUser!.uid}/balance');
        await balanceRef.set(newBalance); // Cập nhật số dư ví mới
      }

      // Chuyển hướng đến màn hình thành công
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(orderId: order.id),
        ),
      );

      // Xóa từng sản phẩm trong giỏ hàng
      for (var product in products) {
        cartProvider.removeItem(
            FirebaseAuth.instance.currentUser!.uid, product.id);
      }
    } catch (error) {
      String errorMessage = 'Lỗi không xác định';
      if (error is FirebaseException) {
        errorMessage = error.message ?? 'Lỗi không xác định';
      }
      print('Error occurred: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt hàng thất bại: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildSectionTitle('Thông tin giao hàng', 'Sửa', () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressUser(),
                ),
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
      bottomNavigationBar: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: _buildTotalAndCheckoutButton(),
      ),
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
            onTap: () => onEdit(),
            child: Text(actionText, style: const TextStyle(color: Colors.blue)),
          ),
      ],
    );
  }

  Widget _buildAddressCard() {
    if (defaultAddress == null) {
      return const Text('Chưa có địa chỉ mặc định.');
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(defaultAddress!.nameAddresUser,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(defaultAddress!.phoneAddresUser),
            const SizedBox(height: 4.0),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4.0),
                Expanded(child: Text(defaultAddress!.addressUser)),
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
        ListTile(
          title: const Text('Tiết kiệm'),
          subtitle: const Text('(+10.000đ)'),
          leading: Radio(
            value: 1,
            groupValue: _selectedShippingOption,
            onChanged: (int? value) {
              if (value != null) _updateShippingFee(value);
            },
          ),
        ),
        ListTile(
          title: const Text('Nhanh'),
          subtitle: const Text('(+20.000đ)'),
          leading: Radio(
            value: 2,
            groupValue: _selectedShippingOption,
            onChanged: (int? value) {
              if (value != null) _updateShippingFee(value);
            },
          ),
        ),
      ],
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
              if (_selectedPaymentMethod == 1) {
                // Nếu số dư ví đủ, không cần thanh toán thêm
                total = totalAmount + shippingFee;
              }
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
    totalAmount = widget.products.fold(
        0.0, (sum, cartItem) => sum + (cartItem.price * cartItem.quantity));

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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VoucherListScreen(vouchers: vouchers)));
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Colors.grey),
              SizedBox(width: 8.0),
              Text('Áp dụng mã ưu đãi'),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildTotalAndCheckoutButton() {
    // Tính tổng tiền cho từng sản phẩm cộng với phí giao hàng

    return Column(
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
          onPressed: () {
            _placeOrder();
          },
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
    );
  }
}
