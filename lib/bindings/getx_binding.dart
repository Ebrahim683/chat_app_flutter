import 'package:chat_app_flutter/controller/chat_controller.dart';
import 'package:get/get.dart';

class GetxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController());
  }
}
