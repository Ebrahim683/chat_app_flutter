import 'package:flutter/material.dart';

class AppConstant {
  static int videoAppId = 1502543303;
  static String videoAppSignIn =
      '4498867f96d91dde8850cddc80593bfe9843f9e2514cdbd9af8b1f52172b1af6';

  //snackbar
  static snackBar({required BuildContext context, required String msg}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

//routs
  static goToFinal(BuildContext context, Widget page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static goTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
