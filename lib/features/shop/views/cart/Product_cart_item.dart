import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/cart/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:grofast_consumers/features/shop/models/shopping_cart_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 21.0),
            child: Text(
              'Giỏ Hàng',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Tính toán tổng giá tiền cho các sản phẩm đã chọn
          double totalPrice = cartProvider.cartItems
              .where((item) => item.isChecked) // Lọc các sản phẩm đã được chọn
              .fold(0, (total, item) => total + (item.price * item.quantity)); // Tính tổng giá

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return _buildCartItem(cartItem, cartProvider);
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        // Hiển thị tổng giá tiền đã tính toán
                        Text('$totalPrice ₫',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Thêm chức năng mua hàng ở đây
                          },
                          child: Text('Mua Hàng'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

    );
  }

  Widget _buildCartItem(CartItem cartItem, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: cartItem.isChecked, // Trạng thái checkbox
                onChanged: (bool? value) {
                  cartItem.isChecked = value ?? false; // Cập nhật trạng thái
                  cartProvider.notifyListeners(); // Thông báo cho UI cập nhật
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(cartItem.imageUrl), // Sử dụng NetworkImage
                          fit: BoxFit.cover,
                        ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   cartItem.unit, // Hiển thị đơn vị
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.blue),
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  cartItem.quantity--;
                                  cartProvider.notifyListeners();
                                } else {
                                  cartProvider.removeFromCart(cartItem);
                                }
                              },
                            ),
                            Text(
                              cartItem.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.blue),
                              onPressed: () {
                                cartItem.quantity++;
                                cartProvider.notifyListeners();
                              },
                            ),
                          ],
                        ),
                        Text(
                          '${cartItem.price} ₫',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            cartProvider.removeFromCart(cartItem);
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 4),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
