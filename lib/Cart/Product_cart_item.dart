import 'package:flutter/material.dart';

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
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                right: 50.0), // Để tránh chồng lên nút 3 chấm
            child: Text(
              'Giỏ Hàng',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Box chứa thông tin shop và ghi chú
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Di chuyển bóng xuống dưới
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon shop
                  Icon(Icons.store, color: Colors.blue, size: 40),
                  const SizedBox(width: 8),
                  // Tên shop và ghi chú
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coop Mart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ghi chú: Giao hàng trước 12h',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Checkbox và nút mũi tên
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down),
                        onPressed: () {
                          // Xử lý khi nhấn nút mũi tên
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Phần lựa chọn khi hết hàng và checkbox
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Lựa chọn khi hết hàng',
                  style: TextStyle(fontSize: 16),
                ),
                Icon(Icons.help_outline),
                SizedBox(width: 8),
              ],
            ),
          ),

          // Checkbox "Tôi muốn chọn sản phẩm thay thế"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (bool? value) {},
                ),
                Expanded(
                    child: Text('Tôi muốn chọn sản phẩm thay thế (tự chọn)')),
              ],
            ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: ListView(
              children: [
                _buildCartItem(
                    'Bơ', 'quả', 32000, 'assets/images/category/bo.png'),
                _buildCartItem(
                    'Chanh', 'quả', 32000, 'assets/images/category/chanh.png'),
                _buildCartItem('Nước Cam', 'lon', 32000,
                    'assets/images/category/lonuoc.png'),
              ],
            ),
          ),

          Divider(),

          // Tổng cộng và nút Thanh toán
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng cộng:', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text('110.000đ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Thanh toán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(String name, String unit, int price, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), // Lớp nền mờ
          borderRadius: BorderRadius.circular(10), // Bo góc là 10
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Bóng mờ nhẹ
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // Di chuyển bóng xuống dưới
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Tạo khoảng cách bên trong
          child: Row(
            children: [
              // Hình ảnh sản phẩm
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Tên và đơn vị sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Giá sản phẩm và nút "Thay thế"
              Column(
                children: [
                  Text(
                    '$price đ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      // Hành động thay thế sản phẩm
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.autorenew, size: 16),
                        SizedBox(width: 4),
                        Text('Thay thế', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
