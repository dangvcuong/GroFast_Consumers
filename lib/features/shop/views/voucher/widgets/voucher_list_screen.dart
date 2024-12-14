import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({super.key});

  @override
  _VoucherListScreenState createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  List<Map<String, dynamic>> vouchers = []; // Danh sách voucher từ Firebase

  @override
  void initState() {
    super.initState();
    _fetchVouchers(); // Gọi hàm lấy danh sách voucher
  }

  // Hàm lấy danh sách voucher từ Firebase
  Future<void> _fetchVouchers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid; // Lấy uid của user hiện tại

      DatabaseReference ref =
          FirebaseDatabase.instance.ref('voucherUser/$uid/');
      ref.onValue.listen((event) {
        final data = event.snapshot.value;

        if (data != null && data is Map<dynamic, dynamic>) {
          setState(() {
            vouchers = data.entries.map((e) {
              return {
                'key': e.key, // Key duy nhất của voucher
                ...Map<String, dynamic>.from(e.value)
              };
            }).toList();
          });
        }
      });
    } else {
      print("User chưa đăng nhập.");
    }
  }

  // Hàm sử dụng voucher
  Future<void> _useVoucher(String voucherKey) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Tham chiếu đến voucher của người dùng
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('voucherUser/$uid/$voucherKey');
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        // Voucher tồn tại, lấy dữ liệu
        Map voucherData = snapshot.value as Map;

        // Kiểm tra ngày hết hạn
        String expiryDateStr = voucherData['ngayHetHan'] ?? ''; // yyyy-MM-dd
        if (expiryDateStr.isNotEmpty) {
          DateTime expiryDate = DateTime.parse(expiryDateStr);
          DateTime currentDate = DateTime.now();

          // So sánh ngày hết hạn
          if (currentDate.isBefore(expiryDate)) {
            // Voucher còn hiệu lực, tiếp tục sử dụng
            Navigator.pop(context, voucherData); // Trả lại voucher đã chọn
          } else {
            // Voucher đã hết hạn
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voucher đã hết hạn!')),
            );
          }
        } else {
          print('Dữ liệu voucher không hợp lệ!');
        }
      } else {
        // Voucher không tồn tại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Voucher không tồn tại hoặc đã hết hạn!')),
        );
      }
    } else {
      // Người dùng chưa đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để sử dụng voucher!')),
      );
    }
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
      body: vouchers.isEmpty
          ? const Center(child: Text('Không có voucher nào!'))
          : ListView.builder(
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];

                return Dismissible(
                  key: Key(voucher['key']), // Key duy nhất để định danh item
                  direction:
                      DismissDirection.endToStart, // Vuốt từ phải sang trái
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    // Thực hiện xóa voucher khỏi Firebase
                    final user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      String uid = user.uid;

                      DatabaseReference ref = FirebaseDatabase.instance
                          .ref('voucherUser/$uid/${voucher['key']}');
                      await ref.remove();

                      setState(() {
                        vouchers.removeAt(index); // Xóa khỏi danh sách hiện tại
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${voucher['name']} đã được xóa')),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(voucher['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Giảm ship: ${voucher['discount']}%'),
                          Text('Hạn sử dụng: ${voucher['ngayHetHan']}'),
                          Text('Trạng thái: ${voucher['status']}'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _useVoucher(voucher['key']),
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
                  ),
                );
              },
            ),
    );
  }
}
