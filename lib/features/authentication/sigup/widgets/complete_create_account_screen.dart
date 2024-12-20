import 'package:flutter/material.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/navigation/btn_navigation.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';

class CompleteCreateAccountScreen extends StatefulWidget {
  const CompleteCreateAccountScreen({super.key});

  @override
  State<CompleteCreateAccountScreen> createState() =>
      _CompleteCreateAccountScreenState();
}

class _CompleteCreateAccountScreenState
    extends State<CompleteCreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Center(
        // Sử dụng Center để căn giữa toàn bộ nội dung
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icons/emailSucFull.png'),
              Container(height: 20),
              const Text(
                'Tạo tài khoản thành công',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Container(height: 30),
              Text(
                'Tài khoản của bạn đã được tạo thành công, nhấn tiếp tục để phám phá những điều hay ho nhé',
                style: HAppStyle.paragraph3Regular
                    .copyWith(color: HAppColor.hGreyColorShade600),
                textAlign: TextAlign.center,
              ),
              Container(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Btn_Navigatin()));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(HAppSize.p100 * 0.5, 50),
                  backgroundColor: HAppColor.hBluePrimaryColor,
                ),
                child: const Text("Tiếp tục",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
