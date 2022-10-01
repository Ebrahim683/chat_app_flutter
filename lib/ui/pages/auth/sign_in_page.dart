import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/ui/pages/auth/sign_up_page.dart';
import 'package:chat_app_flutter/ui/pages/home/home_page.dart';
import 'package:chat_app_flutter/utils/getstoragemanager/get_storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var secure = true;
  var isLoading = false;
  //input text widget
  Widget inputText(
      {required IconData prefexIcon,
      required TextEditingController textEditingController,
      required String hint,
      required TextInputType type,
      IconData? sufixIcon}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      child: TextField(
        keyboardType: type,
        controller: textEditingController,
        decoration: InputDecoration(
          prefixIcon: Icon(prefexIcon),
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.black54, width: 1.w)),
        ),
      ),
    );
  }

  //input password widget
  Widget inputPassword(
      {required IconData prefexIcon,
      required TextEditingController textEditingController,
      required String hint,
      required TextInputType type,
      IconData? sufixIcon}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      child: TextField(
        keyboardType: type,
        controller: textEditingController,
        obscureText: secure,
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  secure = !secure;
                });
              },
              icon: Icon(sufixIcon)),
          prefixIcon: Icon(prefexIcon),
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.black54, width: 1.w)),
        ),
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  //user log in
  signInUser(String email, String password) async {
    try {
      var credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      var uid = credential.user?.uid.toString();

      print('auth:$uid');
      if (uid != null) {
        GetStorageManager.saveToken(uid);
        setState(() {
          isLoading = false;
          AppConstant.goToFinal(context, const HomePage());
        });
      }
    } on FirebaseAuthException catch (e) {
      print('auth:${e.message}');
      AppConstant.snackBar(context: context, msg: e.message.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 80.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green),
                  ),
                ),

                //email
                inputText(
                    prefexIcon: Icons.email,
                    textEditingController: _emailController,
                    hint: 'Email',
                    type: TextInputType.emailAddress),
                //password
                inputPassword(
                    prefexIcon: Icons.lock,
                    textEditingController: _passwordController,
                    hint: 'Password',
                    type: TextInputType.text,
                    sufixIcon: secure == true
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off_outlined),

                SizedBox(height: 10.h),
                //button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 35.h,
                    child: MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      onPressed: () {
                        var email = _emailController.text.toString();
                        var password = _passwordController.text.toString();
                        if (email == '') {
                          AppConstant.snackBar(
                              context: context,
                              msg: 'Enter correct email address');
                        } else if (password == '') {
                          AppConstant.snackBar(
                              context: context, msg: 'Enter password');
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          signInUser(email, password);
                        }
                      },
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : Text(
                              'Sign in',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Don\'t have an account?'),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: (() {
                setState(() {
                  AppConstant.goToFinal(context, const SignUpPage());
                });
              }),
              child: const Text(
                'Sign up',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
