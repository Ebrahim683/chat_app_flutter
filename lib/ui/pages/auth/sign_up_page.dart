import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/ui/pages/auth/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var secure = true;
  var isLoading = false;
  //text input widget
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

  //password input widget
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
  //sign up user
  signUpUser(
      String? fullName, String email, String password, String cPassword) async {
    try {
      var credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      var uid = credential.user?.uid.toString();
      if (uid != null) {
        print('auth:$uid');
        //save data
        UserModel userModel = UserModel(
            emailAddress: email,
            fullName: fullName,
            profilePic: '',
            userId: uid);
        await FirebaseFirestore.instance
            .collection('usersData')
            .doc(uid)
            .set(userModel.toMap())
            .then((value) {
          print('user: saved user');
          setState(() {
            isLoading = false;
            AppConstant.goToFinal(context, const SignInPage());
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      print('auth: ${e.message}');
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                //full name
                inputText(
                    prefexIcon: Icons.account_box_outlined,
                    textEditingController: _fullNameController,
                    hint: 'Full name',
                    type: TextInputType.text),
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
                //confirm password
                inputPassword(
                    prefexIcon: Icons.lock,
                    textEditingController: _confirmPasswordController,
                    hint: 'Confirm password',
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
                        String fullName = _fullNameController.text.toString();
                        String email = _emailController.text.toString();
                        String password = _passwordController.text.toString();
                        String cPassword =
                            _confirmPasswordController.text.toString();
                        if (fullName == '') {
                          AppConstant.snackBar(
                              context: context, msg: 'Enter full name');
                        } else if (email == '') {
                          AppConstant.snackBar(
                              context: context,
                              msg: 'Enter correct email adress');
                        } else if (password == '') {
                          AppConstant.snackBar(
                              context: context, msg: 'Enter password');
                        } else if (cPassword == '') {
                          AppConstant.snackBar(
                              context: context, msg: 'Confirm your password');
                        } else if (password != cPassword) {
                          AppConstant.snackBar(
                              context: context, msg: 'Password did not match');
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          signUpUser(fullName, email, password, cPassword);
                        }
                      },
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : Text(
                              'Sign up',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Wrap(
                  children: [
                    const Text('Already have an account?'),
                    SizedBox(width: 5.w),
                    GestureDetector(
                      onTap: (() {
                        setState(() {
                          AppConstant.goToFinal(context, const SignInPage());
                        });
                      }),
                      child: const Text(
                        'Log in',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
