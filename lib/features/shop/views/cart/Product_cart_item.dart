import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';
import 'package:grofast_consumers/features/shop/views/cart/providers/cart_provider.dart';
import 'package:grofast_consumers/features/shop/views/pay/pay_cart_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isInitialized = false;
  final Login_Controller login_controller = Login_Controller();
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  bool isEditing = false;
  bool isSelectAll = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Provider.of<CartProvider>(context, listen: false).fetchCartItems(userId);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Giỏ hàng của tôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? 'Xong' : 'Sửa',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          double totalPrice = cartProvider.cartItems
              .where((item) => item.isChecked)
              .fold(0, (total, item) => total + (item.price * item.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return _buildCartItem(cartItem, cartProvider);
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: isEditing
                    ? _buildEditActions(cartProvider)
                    : _buildSummary(totalPrice, cartProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, CartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: cartItem.isChecked,
              onChanged: (bool? value) {
                cartItem.isChecked = value ?? false;
                cartProvider.notifyListeners();
              },
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.imageUrl,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(cartItem.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.grey),
                        onPressed: () {
                          if (cartItem.quantity > 1) {
                            cartItem.quantity--;
                            cartProvider.updateQuantity(
                              FirebaseAuth.instance.currentUser!.uid,
                              cartItem,
                            );
                          }
                        },
                      ),
                      Text(
                        cartItem.quantity.toString(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.grey),
                        onPressed: () {
                          cartItem.quantity++;
                          cartProvider.updateQuantity(
                            FirebaseAuth.instance.currentUser!.uid,
                            cartItem,
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditActions(CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: isSelectAll,
              onChanged: (bool? value) {
                setState(() {
                  isSelectAll = value ?? false;
                  isSelectAll
                      ? cartProvider.selectAllItems()
                      : cartProvider.deselectAllItems();
                });
              },
            ),
            const Text(
              'Chọn tất cả',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final selectedItems =
            cartProvider.cartItems.where((item) => item.isChecked).toList();
            if (selectedItems.isEmpty) {
              // Hiển thị thông báo khi không có sản phẩm nào được chọn
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng chọn sản phẩm để xóa.'),
                ),
              );
              return;
            }

            // Hiển thị hộp thoại xác nhận
            final confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận'),
                content: const Text('Bạn có chắc muốn xóa các sản phẩm đã chọn?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Đồng ý'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              for (var item in selectedItems) {
                cartProvider.removeItem(
                    FirebaseAuth.instance.currentUser!.uid, item.productId);
              }
            }
          },
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          label: const Text(
            'Xóa',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(double totalPrice, CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tổng cộng:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(
              formatter.format(totalPrice),
              style: const TextStyle(
                  fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                final selectedProducts =
                cartProvider.cartItems.where((item) => item.isChecked).toList();
                if (selectedProducts.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaymentCartScreen(products: selectedProducts),
                  ),
                ).then((_) {
                  String userId = FirebaseAuth.instance.currentUser!.uid;
                  Provider.of<CartProvider>(context, listen: false)
                      .fetchCartItems(userId);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Mua hàng',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
