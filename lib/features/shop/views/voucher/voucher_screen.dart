import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  // Sử dụng broadcast để nhiều widget có thể lắng nghe stream
  StreamController<int> selected = StreamController<int>.broadcast();

  final List<String> rewards = [
    "Chúc bạn may mắn lần sau",
    "Thẻ quà tặng",
    "Mất lượt",
    "Mã giảm giá",
    "Voucher ăn uống",
    "Phần thưởng đặc biệt"
  ];
  List<String> voucherList = [];
  bool isSpinning = false; // Trạng thái vòng quay đang quay hay không

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

    String wonReward= rewards[randomIndex];
    if(wonReward !="Mất lượt"){
      voucherList.add(wonReward);
    }

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isSpinning = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Chúc mừng!"),
            content: Text("Bạn đã trúng: $wonReward"),
            actions: <Widget>[
              TextButton(
                child: Text("Đóng"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Xem Voucher"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> VoucherListScreen(vouchers: voucherList)));
                },
              ),
            ],
          );
        },
      );
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
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Container(
                  height: 300,
                  width: 300,
                  child: FortuneWheel(
                    selected: selected.stream,
                    items: [
                      for (var it in rewards)
                        FortuneItem(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.primaries[rewards.indexOf(it) %
                                  Colors.primaries.length],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(30),
                            child: Text(
                              it,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
            Positioned(
              top: MediaQuery.of(context).size.height * 0.41,
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
    );
  }
}
class VoucherListScreen extends StatelessWidget {
  final List<String> vouchers;
  
  const VoucherListScreen({super.key, required this.vouchers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh Sách Voucher của bạn"),
      ),
      body: ListView.builder(
        itemCount: vouchers.length,
          itemBuilder: (context,index){
          return ListTile(
            title: Text(vouchers[index]),
          );
          }),
    );
  }
}

