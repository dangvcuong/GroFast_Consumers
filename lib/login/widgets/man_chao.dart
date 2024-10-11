import 'package:flutter/material.dart';
import 'package:grofast_consumers/login/loggin.dart';

class ManChao extends StatefulWidget {
  const ManChao({super.key});

  @override
  State<ManChao> createState() => _ManChaoState();
}

class _ManChaoState extends State<ManChao> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
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
