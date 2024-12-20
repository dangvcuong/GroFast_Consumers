// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/login/loggin.dart';
import 'package:grofast_consumers/features/navigation/btn_navigation.dart';

class ManChao extends StatefulWidget {
  const ManChao({super.key});

  @override
  State<ManChao> createState() => _ManChaoState();
}

class _ManChaoState extends State<ManChao> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Btn_Navigatin()),
      );
    });
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      width: 200, // Thay đổi kích thước theo ý muốn
      height: 200, // Thay đổi kích thước theo ý muốn
      child: Image.asset("assets/logos/grofast_splash.gif"),
    );
  }
}
