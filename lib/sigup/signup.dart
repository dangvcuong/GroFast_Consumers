import 'package:flutter/material.dart';
import 'package:grofast_consumers/sigup/widgets/formsignupwidget.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.arrow_back_ios_new_outlined),
            )),
      ),
      body: const SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: FormSignUpWidget(),
          )
        ],
      )),
    );
  }
}
