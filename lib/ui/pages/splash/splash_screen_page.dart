import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/ui/pages/auth/sign_in_page.dart';
import 'package:chat_app_flutter/ui/pages/home/home_page.dart';
import 'package:chat_app_flutter/utils/getstoragemanager/get_storage_manager.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  goToNextPage() async {
    print('splash: ${GetStorageManager.isLoggedIn()}');
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        if (GetStorageManager.isLoggedIn() == true) {
          AppConstant.goToFinal(context, const HomePage());
        } else {
          AppConstant.goToFinal(context, const SignInPage());
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    goToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      backgroundColor: Colors.redAccent,
      // ignore: prefer_const_constructors
      body: Center(
          child: const CircularProgressIndicator(
        color: Colors.grey,
      )),
    );
  }
}
