import 'package:flutter/material.dart';
import 'dart:math';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  bool _isSpinning = false;

  // Danh sách phần thưởng
  final List<String> rewards = [
    "Chúc bạn may mắn lần sau",
    "Thẻ quà tặng",
    "Mất lượt",
    "Mã giảm giá",
    "Voucher ăn uống",
    "Phần thưởng đặc biệt"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _currentAngle = _animation.value * 2 * pi * 5; // Xoay 5 vòng
        });
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showRewardDialog();
        _controller.reset();
      }
    });
  }

  void _spinWheel() {
    if (!_isSpinning) {
      setState(() {
        _isSpinning = true;
      });
      _controller.forward();
    }
  }

  void _showRewardDialog() {
    // Tính chỉ số phần thưởng dựa trên góc hiện tại
    int rewardIndex = ((-(_currentAngle % (2 * pi)) + (pi / rewards.length)) /
                (2 * pi / rewards.length))
            .floor() %
        rewards.length; // Đảm bảo rằng rewardIndex là kiểu int

    String reward = rewards[rewardIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chúc mừng!"),
          content: Text("Bạn đã trúng: $reward"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Vòng Quay May Mắn"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _currentAngle,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: WheelPainter(rewards),
                  ),
                ),
                const Positioned(
                  top: 10,
                  child: Icon(
                    Icons.arrow_drop_up,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSpinning ? null : _spinWheel,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.all(24),
                  ),
                  child: const Text(
                    "QUAY",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Logic cho nút "Thêm lượt" (nếu có)
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Thêm lượt",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mã dự thưởng tháng 10",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> rewards;

  WheelPainter(this.rewards);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final radius = size.width / 2;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = (i * 2 * pi) / rewards.length;
      final sweepAngle = (2 * pi) / rewards.length;

      // Chọn màu cho mỗi phần
      paint.color = Colors.primaries[i % Colors.primaries.length];

      // Vẽ hình tròn
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Vẽ chữ phần thưởng
      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i],
          style: const TextStyle(
            color: Colors.white, // Màu chữ chính
            fontSize: 16, // Kích thước chữ lớn hơn
            fontWeight: FontWeight.bold, // Chữ in đậm
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final x = radius +
          (radius / 2) * cos(startAngle + sweepAngle / 2) -
          textPainter.width / 2;
      final y = radius +
          (radius / 2) * sin(startAngle + sweepAngle / 2) -
          textPainter.height / 2;

      // Vẽ viền chữ (bóng chữ)
      final textBorderPainter = TextPainter(
        text: TextSpan(
          text: rewards[i],
          style: const TextStyle(
            color: Colors.black, // Màu viền
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textBorderPainter.layout();
      textBorderPainter.paint(
          canvas, Offset(x + 1, y + 1)); // Dịch chuyển viền một chút

      // Vẽ chữ chính
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
