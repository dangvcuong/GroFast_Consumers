import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:grofast_consumers/features/navigation/btn_navigation.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher.dart';
import 'package:grofast_consumers/features/shop/views/voucher/widgets/voucher_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  StreamController<int> selected = StreamController<int>.broadcast();
  List<String> rewards = [];
  List<Voucher> voucherList = [];
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    isSpinning = false;
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('vouchers');
    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      print("Snapshot value: ${snapshot.value}"); // Kiểm tra dữ liệu từ Firebase

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> vouchersData = Map.from(snapshot.value as Map);
        setState(() {
          print(vouchersData);
          voucherList = vouchersData.values
              .where((voucherData) => voucherData is Map) // Chỉ xử lý nếu voucherData là Map
              .map((voucherData) => Voucher.fromMap(Map.from(voucherData)))
              .toList();
          voucherList = voucherList.asMap().entries.map((entry){
            var index = entry.key;
            Voucher voucher = entry.value;
            voucher.id = vouchersData.entries.toList()[index].key;
            return voucher;
          }).toList();
          rewards = voucherList.map((voucher) => voucher.name).toList();
        });
      } else {
        print("Dữ liệu không phải kiểu Map");
      }
    } else {
      print("Snapshot không có dữ liệu");
    }
  }


  void spinWheel() async {
    if (isSpinning) return;

    bool autoCloseDialog = true; // Biến để kiểm tra tự động đóng popup

    // String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    //
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? lastSpindate = prefs.getString('lastSpinDate');
    //
    // // Kiểm tra nếu đã quay trong ngày hôm nay
    // if (lastSpindate != null && lastSpindate == today) {
    //   // Hiển thị popup thông báo
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     // Không cho phép đóng bằng cách nhấn ngoài popup
    //     builder: (BuildContext context) {
    //       // Khởi tạo một Timer để tự động đóng popup sau 3 giây
    //       Timer? autoCloseTimer;
    //
    //       autoCloseTimer = Timer(Duration(seconds: 3), () {
    //         if (autoCloseDialog) {
    //           Navigator.of(context)
    //               .pop(); // Đóng popup sau 3 giây nếu không có hành động từ người dùng
    //         }
    //       });
    //
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text("Thông báo!",style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
    //             Positioned(
    //               top: -10,
    //               right: -17,
    //               child: IconButton(
    //                 icon: const Icon(Icons.close),
    //                 onPressed: () {
    //                   autoCloseDialog = false; // Hủy tự động đóng khi nhấn icon
    //                   Navigator.of(context)
    //                       .pop(); // Đóng popup khi nhấn vào icon
    //                   autoCloseTimer?.cancel();
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //         content: Text("Bạn đã hết lượt quay. Hãy đợi đến ngày mai!",style: TextStyle(fontSize: 15),),
    //       );
    //     },
    //   );
    //   return;
    // }
    // await prefs.setString('lastSpinDate', today);

    setState(() {
      isSpinning = true;
    });

    int randomIndex = Fortune.randomInt(0, rewards.length);
    selected.add(randomIndex);

    Voucher wonVoucher = voucherList[randomIndex];
    String wonReward = wonVoucher.name;

    if (wonReward != "Mất lượt") {
      int initialQuantity = int.parse(wonVoucher.soluong);

      int soLuong = initialQuantity - 1;

      int useQuanlity = initialQuantity - soLuong;

      // int soluongInt = int.parse(wonVoucher.soluong);  // Chuyển chuỗi thành số
      // soluongInt -= 1;  // Thực hiện phép trừ

      wonVoucher.soluong =
          soLuong.toString(); // Chuyển số thành chuỗi và gán lại

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'wonVoucher',
          '${wonVoucher.name},${wonVoucher.discount},${wonVoucher.ngayHetHan},${wonVoucher.ngayTao},${useQuanlity},${wonVoucher.status}');
      String? savedVoucher = prefs.getString('wonVoucher');
      print("Vouchersave: $savedVoucher");

      // Cập nhật dữ liệu vào Firebase
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('vouchers');
      await ref.child(wonVoucher.id).update({
        'soluong': wonVoucher.soluong,  // Cập nhật soluong dưới dạng String
      });
      print("idddd: ${wonVoucher.id}");
    }


    setState(() {
      isSpinning = false;
    });
    bool isNavigating =
        false; // Trạng thái để kiểm tra xem có đang điều hướng hay không

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        isSpinning = false;
      });

      // Nếu người chơi quay trúng "Mất lượt", hiển thị popup thông báo
      if (wonReward == "Mất lượt") {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Stack(
                children: [
                  const Text(
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
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        autoCloseDialog = false; // Hủy tự động đóng khi nhấn icon
                        Navigator.of(context).pop(); // Đóng popup khi nhấn vào icon
                      },
                    ),
                  ),
                ],
              ),
              content: const Text("Hãy thử lại sau nhé!"),
            );
          },
        );

        // Đóng popup sau 3 giây nếu không nhấn icon đóng
        Future.delayed(const Duration(seconds: 3), () {
          if (autoCloseDialog && !isNavigating) {
            Navigator.of(context).pop(); // Đóng popup tự động nếu không nhấn icon đóng
          }
        });
      } else {
        // Popup "Chúc mừng" không có tự động đóng
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Stack(
                children: [
                  const Text(
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
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        autoCloseDialog = false; // Hủy tự động đóng khi nhấn icon
                        Navigator.of(context).pop(); // Đóng popup khi nhấn vào icon
                      },
                    ),
                  ),
                ],
              ),
              content: Text("Bạn đã trúng: $wonReward"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Xem Voucher"),
                  onPressed: () {
                    isNavigating =
                        true; // Đánh dấu bắt đầu quá trình điều hướng
                    Navigator.of(context)
                        .pop(); // Đóng popup trước khi chuyển màn hình
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

        // Đóng popup sau 3 giây nếu không nhấn icon đóng
        Future.delayed(const Duration(seconds: 3), () {
          if (autoCloseDialog && !isNavigating) {
            Navigator.of(context).pop(); // Đóng popup tự động nếu không nhấn icon đóng
          }
        });
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
        title: const Text('Vòng quay ưu đãi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/category/banner.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AbsorbPointer(
                    absorbing: isSpinning,
                    // Vô hiệu hóa khi vòng quay đang diễn ra
                    child: SizedBox(
                      width: 130, // Đặt chiều rộng của nút tại đây (ví dụ 200)
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const Btn_Navigatin(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.green, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ).copyWith(
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.red;
                            }
                            return Colors.blue;
                          }),
                        ),
                        child: const Text("Trang chủ"),
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: isSpinning,
                    // Vô hiệu hóa khi vòng quay đang diễn ra
                    child: ElevatedButton(
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
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.red;
                          }
                          return Colors.blue;
                        }),
                      ),
                      child: const Text("Xem Voucher"),
                    ),
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
                                width: 8, // Border color and width
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: rewards.length > 1
                                ? FortuneWheel(
                                    animateFirst: false,
                                    selected: selected.stream,
                              items: List.generate(
                                      rewards.length + 1, // Thêm 1 ô
                                      (index) {
                                        if (index == rewards.length) {
                                          // Ô cuối cùng là "Mất lượt"
                                          return FortuneItem(
                                            child: Text(
                                              "Mất lượt",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: FortuneItemStyle(
                                              color: Color(
                                                  0xFFFF1744), // Màu nền ô "Mất lượt"
                                            ),
                                          );
                                        }
                                        return FortuneItem(
                                          style: FortuneItemStyle(
                                            color: Colors.primaries[index %
                                                Colors.primaries
                                                    .length], // Màu sắc ngẫu nhiên
                                          ),
                                          child: Text(
                                            rewards[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      "Danh sách phần thưởng không đủ!",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.red),
                                    ),
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
                          decoration: const BoxDecoration(
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
                          child: const Center(
                            child: Text(
                              "Quay",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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