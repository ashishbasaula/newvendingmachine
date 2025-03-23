import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

class AdsController extends GetxController {
  var adsList = <AdsClass>[].obs;
  var isAdsLoaded = false.obs;

  @override
  void onInit() {
    getAds();
    super.onInit();
  }

  Future<void> getAds() async {
    String userId = await LocalStorageServices.getUserId();
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("Ads")
          .get();
      for (var doc in snapshot.docs) {
        if (doc['isAdsEnable'] == true) {
          adsList.add(AdsClass(
              adsImageUrl: doc['adsImage'],
              adsName: doc['adsName'],
              isEnabled: doc['isAdsEnable']));
        }
      }
    } catch (e) {
      MessageUtils.showError("Error fetching images: $e");
    } finally {
      isAdsLoaded.value = true;
    }
  }
}

class AdsClass {
  final String adsImageUrl;
  final String adsName;
  final bool isEnabled;
  AdsClass(
      {required this.adsImageUrl,
      required this.adsName,
      required this.isEnabled});
}
