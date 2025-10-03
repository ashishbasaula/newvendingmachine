import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Ads/ads_controller.dart';
// import 'package:get/get_core/get_core.dart';

class BannerComponent extends StatelessWidget {
  BannerComponent({super.key});

  final adsController = Get.find<AdsController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !adsController.isAdsLoaded.value
          ? const SizedBox.shrink()
          : CarouselSlider(
              options:
                  CarouselOptions(autoPlay: true, height: Get.height * 0.2),
              items: adsController.adsList.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: Get.height * 0.3,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(
                                i.adsImageUrl,
                              ),
                              fit: BoxFit.cover),
                          color: Colors.cyan),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
