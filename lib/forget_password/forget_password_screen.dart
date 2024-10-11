import 'package:flutter/material.dart';
import 'package:grofast_consumers/forget_password/form_enter_email_widget.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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
