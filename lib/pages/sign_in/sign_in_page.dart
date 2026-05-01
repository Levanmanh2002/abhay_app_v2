import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sign_in_controller.dart';

class SignInPage extends GetWidget<SignInController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: const Center(
              child: Text('Sign In Page'),
            ),
          ),
        ),
      ),
    );
  }
}
