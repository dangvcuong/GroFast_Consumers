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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        title: const Text('Giỏ hàng của tôi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
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
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
        foregroundColor: Colors.white,
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
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16), // Thêm padding ở trên cùng
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
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(
                10), // Left padding increased to make room for checkbox
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cartItem.imageUrl,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatter.format(cartItem.price),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Add/Subtract buttons (horizontal, at the bottom, Shopee style)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Checkbox positioned absolutely
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Checkbox(
                                value: cartItem.isChecked,
                                onChanged: (bool? value) {
                                  cartItem.isChecked = value ?? false;
                                  cartProvider.notifyListeners();
                                },
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                _buildQuantityButton(
                                  icon: Icons.remove,
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
                                Container(
                                  width: 40,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.symmetric(
                                      vertical:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  child: Text(
                                    cartItem.quantity.toString(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _buildQuantityButton(
                                  icon: Icons.add,
                                  onPressed: () {
                                    cartItem.quantity++;
                                    cartProvider.updateQuantity(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      cartItem,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.grey[600]),
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
                content:
                    const Text('Bạn có chắc muốn xóa các sản phẩm đã chọn?'),
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
    // Tính tổng số lượng sản phẩm đã chọn (mỗi sản phẩm chỉ tính 1 lần)
    int totalQuantity = cartProvider.cartItems
        .where((item) => item.isChecked) // Lọc ra các sản phẩm đã chọn
        .length; // Đếm số lượng sản phẩm đã chọn

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Hiển thị "Tổng thanh toán" và tổng giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(
                  fontSize: 18, // Giảm kích thước chữ
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatter.format(totalPrice),
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
              height:
                  8), // Khoảng cách giữa "Tổng thanh toán" và nút "Mua hàng"

          // Nút "Mua hàng" và tổng số sản phẩm đã chọn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hiển thị nút chọn tất cả
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
                    'tất cả',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              // Hiển thị nút "Mua hàng" với tổng số sản phẩm đã chọn
              ElevatedButton(
                onPressed: () {
                  final selectedProducts = cartProvider.cartItems
                      .where((item) => item.isChecked)
                      .toList();
                  if (selectedProducts.isEmpty) {
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Không cho phép đóng bằng cách nhấn ra ngoài
                      barrierColor: Colors
                          .transparent, // Màu nền mờ của background (nền đen trong)
                      builder: (context) => Dialog(
                        backgroundColor: Colors.black
                            .withOpacity(0.6), // Nền của dialog trong suốt
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber,
                                size: 40, // Kích thước icon
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Bạn vẫn chưa có sản phẩm nào để mua.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white, // Màu chữ trắng
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    // Tự động đóng popup sau 2 giây
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context, rootNavigator: true).pop();
                    });
                    return;
                  }
                  // Tiếp tục với việc xử lý nếu có sản phẩm được chọn
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
                child: Text(
                  'Mua hàng ($totalQuantity)', // Hiển thị tổng số sản phẩm đã chọn
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
