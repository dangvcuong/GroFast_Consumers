// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:grofast_consumers/features/navigation/btn_navigation.dart';
import 'package:grofast_consumers/features/shop/views/home/home_screen.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher_list_screen.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  StreamController<int> selected = StreamController<int>.broadcast();

  final List<String> rewards = [
    "Mã giảm giá 10%",
    "Thẻ quà tặng",
    "Mất lượt",
    "Mã giảm giá 15%",
    "Voucher ăn uống",
    "FreeShip Extra"
  ];
  List<String> voucherList = [];
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    isSpinning = false;
  }

  void spinWheel() {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
    });

    int randomIndex = Fortune.randomInt(0, rewards.length);
    selected.add(randomIndex);

    String wonReward = rewards[randomIndex];

    if (wonReward != "Mất lượt") {
      voucherList.add(wonReward);
    }

    bool autoCloseDialog = true; // Biến để kiểm tra tự động đóng popup

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isSpinning = false;
      });

      // Nếu người chơi quay trúng "Mất lượt", hiển thị popup thông báo
      if (wonReward == "Mất lượt") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Stack(
                children: [
                  Text(
                    "Rất tiếc!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -17,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        autoCloseDialog =
                            false; // Hủy tự động đóng khi nhấn icon
                        Navigator.of(context)
                            .pop(); // Đóng popup khi nhấn vào icon
                      },
                    ),
                  ),
                ],
              ),
              content: Text("Hãy thử lại sau nhé!"),
            );
          },
        );

        // Đóng popup sau 3 giây nếu không nhấn icon đóng
        Future.delayed(Duration(seconds: 3), () {
          if (autoCloseDialog) {
            Navigator.of(context)
                .pop(); // Đóng popup tự động nếu không nhấn icon đóng
          }
        });
      } else {
        // Popup "Chúc mừng" không có tự động đóng
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Stack(
                children: [
                  Text(
                    "Chúc mừng!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -17,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Đóng popup khi nhấn vào icon
                      },
                    ),
                  ),
                ],
              ),
              content: Text("Bạn đã trúng: $wonReward"),
              actions: <Widget>[
                TextButton(
                  child: Text("Xem Voucher"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VoucherListScreen(vouchers: voucherList),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mã ưu đãi của tôi'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/category/banner.jpg'), // Thay thế bằng URL ảnh của bạn
            fit: BoxFit.cover, // Điều chỉnh ảnh để bao phủ toàn bộ nền
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => Btn_Navigatin(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ).copyWith(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.red;
                        }
                        return Colors.blue;
                      }),
                    ),
                    child: Text("Trang chủ"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VoucherListScreen(vouchers: voucherList),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ).copyWith(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.red;
                        }
                        return Colors.blue;
                      }),
                    ),
                    child: Text("Xem Voucher"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: AbsorbPointer(
                          absorbing: !isSpinning,
                          child: Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.amber,
                                  width: 8), // Border color and width
                              shape: BoxShape.circle,
                            ),
                            child: FortuneWheel(
                              selected: selected.stream,
                              items: [
                                for (var it in rewards)
                                  FortuneItem(
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.primaries[
                                            rewards.indexOf(it) %
                                                Colors.primaries.length],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.all(30),
                                      child: Text(
                                        it,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.38,
                      left: MediaQuery.of(context).size.width * 0.5 - 25,
                      child: GestureDetector(
                        onTap: spinWheel,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Quay",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
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
