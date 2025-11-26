import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';

class HelperController extends GetxController {
  var userId = "".obs;
  var deviceId = "".obs;
  var isUserIdLoaded = false.obs;
  var isDeviceIdLoaded = false.obs;
  var canShowLogoutButton = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getUserId();
    getDeviceId();
  }

  void getUserId() async {
    userId.value = await LocalStorageServices.getUserId();
    isUserIdLoaded.value = true;
  }

  void getDeviceId() async {
    deviceId.value = await LocalStorageServices.getDeviceId();
    isDeviceIdLoaded.value = true;
  }
}
