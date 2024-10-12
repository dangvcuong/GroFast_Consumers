import 'package:flutter/material.dart';
import 'package:grofast_consumers/controllers/login_controller.dart';
import 'package:grofast_consumers/forget_password/widgets/form_enter_email_widget.dart';
import 'package:grofast_consumers/validates/vlidedate_dN.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final validete validateLogin = validete();
    final Login_Controller loginController = Login_Controller();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => {
                Navigator.pop(context),
                validateLogin.clear(),
                loginController.clear(),
              },
              child: const Icon(Icons.close),
            ),
          )
        ],
      ),
      body: const SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [FormEnterEmailWidget()],
      )),
    );
  }
}
