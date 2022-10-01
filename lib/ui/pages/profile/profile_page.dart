import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SizedBox(
                  height: 120.h,
                  width: 120.w,
                  child: const CircleAvatar(
                    child: Expanded(child: Icon(Icons.people)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'FullName',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'demo@gmail.com',
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Update'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
