import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:grofast_consumers/features/authentication/controllers/login_controller.dart';
import 'package:intl/intl.dart';

class ReviewPage extends StatefulWidget {
  final String productId; // Biến để nhận id sản phẩm
  final String ten;
  final String gia;
  const ReviewPage(
      {super.key,
      required this.productId,
      required this.ten,
      required this.gia});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0.0; // Biến lưu trữ giá trị rating sao
  final TextEditingController _reviewController =
      TextEditingController(); // Điều khiển TextField nhập nội dung đánh giá
  final Login_Controller login_contriller = Login_Controller();
  String userName = '';
  String userPhotoURL = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Lấy uid của người dùng
      String userId = user.uid;

      // Lấy thông tin người dùng từ Firebase Realtime Database
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/$userId');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        // Lấy dữ liệu từ snapshot
        var userData = snapshot.value as Map?;
        setState(() {
          userName = userData?['name'] ?? 'Chưa có tên';
          userPhotoURL = userData?['image'] ?? '';
        });
      } else {
        print("Không tìm thấy người dùng trong database.");
      }
    } else {
      print("Người dùng chưa đăng nhập.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    double priceValue = double.tryParse(widget.gia) ?? 0.0;
    String formattedPrice = formatter.format(priceValue);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị sản phẩm (giả sử bạn có thông tin sản phẩm từ Firebase hoặc API)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tên sản phẩm: ', // Nhãn
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.ten, // Giá trị tên sản phẩm
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      softWrap: true, // Cho phép tự xuống dòng
                      maxLines: null, // Không giới hạn số dòng
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4), // Khoảng cách giữa 2 dòng
            Row(
              children: [
                const Text(
                  'Giá: ', // Nhãn
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  formattedPrice, // Giá trị giá
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hiển thị sao đánh giá
            const Text("Đánh giá sao:"),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, index) {
                return const Icon(
                  Icons.star,
                  color: Colors.amber,
                );
              },
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 10),

            // Ô nhập nội dung đánh giá
            const Text("Nội dung đánh giá:"),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              minLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập nội dung đánh giá...',
              ),
            ),
            const SizedBox(height: 20),

            // Nút gửi đánh giá
            ElevatedButton(
              onPressed: () {
                submitReview();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Gửi đánh giá',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm để gửi đánh giá lên Firebase (hoặc lưu trữ ở đâu đó)
  void submitReview() async {
    final reviewText = _reviewController.text;
    final rating = _rating;

    if (reviewText.isEmpty || rating == 0.0) {
      // Kiểm tra xem người dùng đã chọn đánh giá và nhập nội dung chưa
      login_contriller.ThongBao(
          context, "Vui lòng chọn đánh giá và nhập nội dung");
      return;
    }

    // Lấy thông tin người dùng từ FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      login_contriller.ThongBao(
          context, "Vui lòng đăng nhập trước khi đánh giá");
      return;
    }

    // Lấy thông tin người dùng
    String userId = user.uid;

    // Dữ liệu đánh giá bao gồm thông tin người dùng và đánh giá
    final reviewData = {
      'nameProduct': widget.ten,
      'rating': rating,
      'review': reviewText,
      'userId': userId,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'status': 'đã xác nhận',
      'timestamp': DateTime.now().toString(),
    };

    // Lưu dữ liệu vào Firebase Realtime Database
    final reviewRef =
        FirebaseDatabase.instance.ref('reviews/${widget.productId}');
    reviewRef.push().set(reviewData).then((_) async {
      // Cập nhật trạng thái "đã đánh giá" cho đơn hàng
      login_contriller.ThongBao(context, "Đánh giá của bạn đã được gửi");

      // Quay lại trang trước sau khi gửi đánh giá
      Navigator.pop(context);
    }).catchError((error) {
      print("Lỗi: $error");
    });
  }
}
