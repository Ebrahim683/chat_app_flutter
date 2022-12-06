import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  var imagePath = ''.obs;
  //select image
  getImage() async {
    final pikedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pikedFile != null) {
      imagePath.value = pikedFile.path;
    } else {
      Get.snackbar('Error!', 'Mo image selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    }
  }
}
