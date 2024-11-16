import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoucherListScreen extends StatefulWidget {
  final List<String> vouchers;

  VoucherListScreen({required this.vouchers});

  @override
  _VoucherListScreenState createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  late List<String> vouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  // Hàm tải voucher từ SharedPreferences
  void _loadVouchers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedVouchers = prefs.getStringList('voucherList');

    if (savedVouchers != null) {
      setState(() {
        vouchers = savedVouchers;
      });
    }
  }

  // Hàm xử lý khi sử dụng voucher
  void _useVoucher(String voucher) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Xóa voucher khỏi danh sách và cập nhật SharedPreferences
    setState(() {
      vouchers.remove(voucher);
    });

    await prefs.setStringList('voucherList', vouchers);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voucher "$voucher" đã được sử dụng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voucher của tôi'),
      ),
      body: ListView.builder(
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          String voucher = vouchers[index];

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
              color: Colors.white,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(voucher, style: TextStyle(fontSize: 16)),
              trailing: TextButton(
                onPressed: () => _useVoucher(voucher),
                child: Text(
                  'Sử dụng',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
