import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  File? selectedImage;
  //select image
  getImage() async {
    XFile? selectImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (selectImage != null) {
      File castFile = File(selectImage.path);
      selectedImage = castFile;
      log('selected image: ${selectedImage?.path}');
    }
  }
}
