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
  late List<String> voucher=[];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }


  // Hàm xóa voucher khỏi danh sách
  void _useVoucher(Voucher voucher) {
    // Hiển thị popup thông báo
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sử dụng thành công!"),
          content: Text("Voucher '${voucher.name}' đã được sử dụng."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                // Xóa voucher khỏi danh sách và cập nhật giao diện
                setState(() {
                  widget.vouchers.remove(voucher);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
