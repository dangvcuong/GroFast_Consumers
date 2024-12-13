import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoucherListScreen extends StatefulWidget {
  final List<Voucher> vouchers;

  const VoucherListScreen({super.key, required this.vouchers});

  @override
  _VoucherListScreenState createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  late String usedQuantity = "0"; // Biến lưu số lượng đã trừ

  @override
  void initState() {
    super.initState();
    _loadUsedQuantity(); // Tải số lượng đã trừ từ SharedPreferences khi vào màn hình
  }

  // Hàm để tải số lượng đã trừ từ SharedPreferences
  Future<void> _loadUsedQuantity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsedQuantity = prefs.getString('usedQuantity');
    if (savedUsedQuantity != null) {
      setState(() {
        usedQuantity = savedUsedQuantity;
      });
    }
    print('Số lượng đã trừ: $usedQuantity');
  }

  // Hàm sử dụng voucher
  void _useVoucher(Voucher voucher) async {
    // Hiển thị SnackBar thông báo voucher đã được sử dụng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Voucher '${voucher.name}' đã được sử dụng thành công!"),
        duration: const Duration(seconds: 2),
      ),
    );

    // Cập nhật lại số lượng đã trừ (ví dụ: tăng giảm số lượng hoặc lưu lại số lượng đã trừ)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUsedQuantity = int.parse(usedQuantity);
    currentUsedQuantity++; // Tăng số lượng đã trừ
    await prefs.setString('usedQuantity', currentUsedQuantity.toString());

    // Cập nhật lại số lượng đã trừ
    setState(() {
      usedQuantity = currentUsedQuantity.toString();
    });

    // Xóa voucher khỏi danh sách và cập nhật giao diện
    setState(() {
      widget.vouchers.remove(voucher);
    });

    // Cập nhật dữ liệu vào Firebase (nếu cần)
    // DatabaseReference ref = FirebaseDatabase.instance.ref().child('vouchers');
    // await ref.child(voucher.id).update({'soluong': voucher.soluong});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách voucher',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: widget.vouchers.isEmpty
          ? const Center(child: Text('Không có voucher nào trúng thưởng!'))
          : ListView.builder(
        itemCount: widget.vouchers.length,
        itemBuilder: (context, index) {
          final voucher = widget.vouchers[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(voucher.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Giảm ship: ${voucher.discount}%'),
                  Text('Hạn sử dụng: ${voucher.ngayHetHan}'),
                  Text('Ngày tạo: ${voucher.ngayTao}'),
                  Text('Số lượng: ${voucher.soluong}'),
                  Text('Trạng thái: ${voucher.status}'),
                  // Hiển thị số lượng đã trừ
                  Text('Số lượng đã trừ: $usedQuantity'),
                ],
              ),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () => _useVoucher(voucher),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Sử dụng"),
              ),
            ),
          );
        },
      ),
    );
  }
}
