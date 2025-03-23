import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';

class HelperController extends GetxController {
  var userId = "".obs;
  var isUserIdLoaded = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getUserId();
  }

  void getUserId() async {
    userId.value = await LocalStorageServices.getUserId();
    isUserIdLoaded.value = true;
  }
}
