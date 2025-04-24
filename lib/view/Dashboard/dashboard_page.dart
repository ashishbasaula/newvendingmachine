import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/scanner_service.dart';
import 'package:newvendingmachine/controller/Ads/ads_controller.dart';
import 'package:newvendingmachine/controller/Helper/device_ui_helper.dart';
import 'package:newvendingmachine/controller/Helper/helper_controller.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/controller/items/items_controller.dart';
import 'package:newvendingmachine/module/user_items_model.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';
import 'package:newvendingmachine/view/Dashboard/components/banner_component.dart';
import 'package:newvendingmachine/view/Dashboard/components/purchase_description.dart';
import 'package:newvendingmachine/view/Payment/payment_list.dart';
import 'package:newvendingmachine/view/Setting/setting_page.dart';

import '../../utils/colors_utils.dart';
import '../shopping/check_out_page.dart';
import 'components/product_card_component.dart';

// Enum for shipment status for better readability

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<String> chipItems = [
    "Cold Beverages",
    "Hot Beverages",
    "Chips",
    "Candies",
    "Chocolates",
    "Cookies",
    "Gum & Mints",
    "Healthy Snacks",
    "Pastries",
    "Sandwiches",
    "Frozen Treats",
    "Non-Food Items" // For machines that also vend items like headphones, chargers, etc.
  ];
  final cartController = Get.find<CartController>();
  final itemsController = Get.find<ItemsController>();
  final helperController = Get.put(HelperController());
  final ads = Get.put(AdsController());
  String scanResult = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scanResult),
        actions: [
          const Icon(
            Icons.storefront_outlined,
            size: 35,
          ),
          const SizedBox(
            width: 5,
          ),
          Obx(
            () => !helperController.isUserIdLoaded.value
                ? const SizedBox.shrink()
                : FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(helperController.userId.value)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Something went wrong");
                      }

                      if (snapshot.hasData && !snapshot.data!.exists) {
                        return const Text("Document does not exist");
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            // machineInfoController.getMachineInformation();
                          },
                          child: Text(
                            data['serialNumber'] ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                          ),
                        );
                      }

                      return const Text("loading");
                    },
                  ),
          ),
          const SizedBox(
            width: 30,
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              color: Colors.cyan,
              height: 100,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Setting"),
              onTap: () {
                Get.to(() => const SettingPage());
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: PaddingUtils.SCREEN_PADDING,
        child: Column(
          children: [
            BannerComponent(),

            const SizedBox(
              height: 10,
            ),
            const PurchaseDescription(),
            const SizedBox(
              height: 10,
            ),

            ElevatedButton(
                onPressed: () async {
                  // final value = await ScannerService().getScannerResult();
                  // debugPrint(value);
                  // setState(() {
                  //   scanResult = value ?? "NO Result";
                  // });
                  Get.to(() => const PaymentList());
                },
                child: Text("Scan bar code ")),

            Obx(() {
              if (!helperController.isUserIdLoaded.value) {
                return const SizedBox.shrink();
              }

              return Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(helperController.userId.value)
                      .collection("Items")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No items available"));
                    }

                    // Parse Firestore data into a list (assuming ItemsModel exists)
                    List<UserItemModel> drinkItems =
                        snapshot.data!.docs.map((doc) {
                      return UserItemModel.fromFirestore(
                          doc.data() as Map<String, dynamic>);
                    }).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: drinkItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCardComponent(
                            itemsModel: drinkItems[index]);
                      },
                    );
                  },
                ),
              );
            }),

            // Expanded(
            //   child: GridView.builder(
            //       itemCount: channelNumber.length,
            //       gridDelegate:
            //           const SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 2),
            //       itemBuilder: (context, index) {
            //         return TextButton(
            //             onPressed: () async {
            //               String message =
            //                   await ShipmentService.initiateShipment(
            //                       1, channelNumber[index], 1, false, false);
            //               print(message);
            //             },
            //             child:
            //                 Text("Check motor no ${channelNumber[index]}"));
            //       }),
            // )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(
        () => cartController.items.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    width: Get.width * 0.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.shopping_cart_checkout,
                            size: DeviceUiHelper.isNotMobile() ? 50 : 30,
                            color: VendingMachineColors.primaryColor,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$ ${cartController.totalPrice.toStringAsFixed(2)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                "${cartController.items.length} goods selected",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.black),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: DeviceUiHelper.isNotMobile()
                                      ? Size(Get.width * 0.3, Get.height * 0.06)
                                      : null,
                                  backgroundColor:
                                      VendingMachineColors.primaryColor),
                              onPressed: () {
                                Get.to(() => CheckOutPage());
                              },
                              child: Text(
                                "Go to checkout",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: DeviceUiHelper.isNotMobile()
                                            ? 20
                                            : null),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
