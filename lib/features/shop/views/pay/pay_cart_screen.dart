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
import 'package:grofast_consumers/features/shop/views/profile/widgets/User_Address.dart';
import 'package:intl/intl.dart';

class PaymentCartScreen extends StatefulWidget {
  final List<CartItem> products;

  const PaymentCartScreen({
    super.key,
    required this.products,
  });

  @override
  _PaymentCartScreenState createState() => _PaymentCartScreenState();
}

class _PaymentCartScreenState extends State<PaymentCartScreen> {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  double totalAmount = 0;
  int _selectedShippingOption = 1;
  int _selectedPaymentMethod = 1;
  int shippingFee = 10000; // Phí giao hàng ban đầu là 10.000đ cho "Ưu tiên"
  DateTime? selectedDeliveryDate;
  User? currentUser;
  List<AddressModel> addresses = [];
  AddressModel? defaultAddress;
  double total = 0;
  final CartProvider cartProvider = CartProvider();
  final Login_Controller loginController = Login_Controller();
  String idProduct = '';
  @override
  void initState() {
    super.initState();
    currentUser =
        FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng hiện tại
    _fetchAddresses(); // Gọi hàm để lấy địa chỉ
  }

  void _updateShippingFee(int option) {
    setState(() {
      switch (option) {
        case 1:
          shippingFee = 10000; // Phí 10.000đ cho "Ưu tiên"
          break;
        case 2:
          shippingFee = 0; // Miễn phí cho "Tiêu chuẩn"
          break;
        case 3:
          shippingFee = 20000; // Phí 20.000đ cho "Đặt lịch"
          break;
      }
      _selectedShippingOption = option;
    });
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDeliveryDate) {
      setState(() {
        selectedDeliveryDate = picked;
      });
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
    );

    DatabaseReference ordersRef = FirebaseDatabase.instance.ref('orders');

    try {
      // Lưu đơn hàng vào Firebase
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh Toán'),
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
          title: const Text('Ưu tiên'),
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
          title: const Text('Tiêu chuẩn'),
          subtitle: const Text('(Miễn phí)'),
          leading: Radio(
            value: 2,
            groupValue: _selectedShippingOption,
            onChanged: (int? value) {
              if (value != null) _updateShippingFee(value);
            },
          ),
        ),
        ListTile(
          title: const Text('Đặt lịch'),
          subtitle: selectedDeliveryDate != null
              ? Text(
                  'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDeliveryDate!)}')
              : null,
          leading: Radio(
            value: 3,
            groupValue: _selectedShippingOption,
            onChanged: (int? value) {
              if (value != null) {
                _updateShippingFee(value);
                _selectDeliveryDate(context);
              }
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
            },
          ),
        ),
        ListTile(
          title: const Text('Ví điện tử MoMo'),
          leading: Radio(
            value: 2,
            groupValue: _selectedPaymentMethod,
            onChanged: (int? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    totalAmount = widget.products
        .fold(0, (sum, cartItem) => sum + (cartItem.price * cartItem.quantity));

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
                        .format(totalAmount + shippingFee),
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
      onTap: () {},
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
    total = totalAmount + shippingFee;

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
