import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class PaymenthistoryScreen extends StatefulWidget {
  final String userId;
  const PaymenthistoryScreen({super.key, required this.userId});

  @override
  State<PaymenthistoryScreen> createState() => _PaymenthistoryScreenState();
}

class _PaymenthistoryScreenState extends State<PaymenthistoryScreen> {
  DateTime? _selectedDate; // Thêm biến để lưu trữ ngày chọn

  Future<List<Map<String, dynamic>>> _getPaymentHistory(
      String userId, DateTime? date) async {
    try {
      final databaseRef =
          FirebaseDatabase.instance.ref("paymentinfo/$userId/paymenthistory");
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> paymentHistory = [];

        data.forEach((key, value) {
          paymentHistory.add(Map<String, dynamic>.from(value));
        });

        // Nếu có ngày được chọn, lọc dữ liệu theo ngày
        if (date != null) {
          paymentHistory = paymentHistory.where((payment) {
            DateTime paymentDate = DateTime.parse(payment["created_at"]);
            return paymentDate.year == date.year &&
                paymentDate.month == date.month &&
                paymentDate.day == date.day;
          }).toList();
        }

        // Sắp xếp lịch sử thanh toán theo thời gian (mới nhất lên đầu)
        paymentHistory.sort((a, b) {
          DateTime dateA = DateTime.parse(a["created_at"]);
          DateTime dateB = DateTime.parse(b["created_at"]);
          return dateB.compareTo(dateA); // Sắp xếp giảm dần
        });

        return paymentHistory;
      }
      return [];
    } catch (e) {
      print("Failed to fetch payment history: $e");
      return [];
    }
  }

  // Hàm định dạng ngày giờ
  String _formatDate(String dateStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return dateStr; // Trả về nguyên bản nếu có lỗi
    }
  }

  String _formatAmount(dynamic amount) {
    // Convert the amount to a double before formatting it
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(numericAmount);
  }

  // Hàm mở DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String maskPaymentCode(String? code) {
    if (code == null || code.length <= 9) {
      return code ?? ''; // Trả về chính nó nếu chuỗi nhỏ hơn hoặc bằng 8 ký tự
    }
    return code.substring(code.length - 9);
  }

  @override
  Widget build(BuildContext context) {
    final String userId = widget.userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: const Text(
          "Lịch sử nạp tiền",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          // Thêm button để chọn ngày
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPaymentHistory(userId, _selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có lịch sử thanh toán'));
          }

          final paymentHistory = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: paymentHistory.length,
            itemBuilder: (context, index) {
              final payment = paymentHistory[index];
              return Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mã giao dịch: ${maskPaymentCode(payment["paymentIntentClientSecret"])}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Số tiền: ${_formatAmount(payment["amount"])}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Thời gian: ${_formatDate(payment["created_at"])}', // Sử dụng hàm định dạng ngày giờ
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Trạng thái: ${payment["status"]}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: payment["status"] == "Completed"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // You could navigate to a detail screen or perform other actions
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentDetailScreen(payment: payment)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
