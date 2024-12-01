import 'package:flutter/material.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/controllers/user_controller.dart';
import 'package:grofast_consumers/features/authentication/models/user_Model.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

class Updata_Sdt extends StatefulWidget {
  const Updata_Sdt({super.key});

  @override
  State<Updata_Sdt> createState() => _Updata_SdtState();
}

class _Updata_SdtState extends State<Updata_Sdt> {
  UserModel? currentUser;
  final UserController userController = UserController();
  final TextEditingController update_sdtController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getUserInfo(); // Gọi hàm để lấy thông tin người dùng
  }

  Future<void> _getUserInfo() async {
    currentUser = await userController.getUserInfo();
    setState(() {}); // Cập nhật lại giao diện sau khi có dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi số điện thoại',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Hãy nhập số điện thoại bạn muốn đổi.",
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600)),
            gapH16,
            TextField(
              keyboardType: TextInputType.phone,
              controller: update_sdtController,
              decoration: InputDecoration(
                labelText: "Nhập số điện thoại",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Bo tròn góc
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                errorMessage ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
            gapH20,
            ElevatedButton(
              onPressed: () {
                final RegExp phoneRegExp = RegExp(r'^[0-9]+$');
                if (update_sdtController.text.isEmpty) {
                  setState(() {
                    errorMessage = "Vui lòng không để trống";
                  });
                } else if (update_sdtController.text.length < 10 ||
                    !phoneRegExp.hasMatch(update_sdtController.text)) {
                  setState(() {
                    errorMessage = "Số điện thoại không hợp lệ";
                  });
                } else {
                  setState(() async {
                    errorMessage = null;

                    await userController.updateSDT(
                        currentUser!.id, update_sdtController.text, context);
                    update_sdtController.text = "";
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(double.maxFinite, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: const Text("Đổi",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
