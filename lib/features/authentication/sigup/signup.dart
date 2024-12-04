import 'package:flutter/material.dart';
import 'package:grofast_consumers/features/authentication/controllers/sign_up_controller.dart';
import 'package:grofast_consumers/features/authentication/sigup/widgets/formsignupwidget.dart';
import 'package:grofast_consumers/validates/validate_Dk.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final SignUp__Controller signupController = SignUp__Controller();
  final valideteDK validateDK = valideteDK();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () => {
                  Navigator.pop(context),
                  signupController.clear(),
                  validateDK.clear()
                },
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
