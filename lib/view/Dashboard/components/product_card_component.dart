import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/module/cart_model.dart';
import 'package:newvendingmachine/module/user_items_model.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

class ProductCardComponent extends StatelessWidget {
  final UserItemModel itemsModel;
  ProductCardComponent({super.key, required this.itemsModel});
  final cartController = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black12, width: 1.5),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.14,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                    image: NetworkImage(itemsModel.goodsImage),
                    fit: BoxFit.fill)),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              itemsModel.goodsName,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.normal, color: Colors.green),
            ),
          ),
          // const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${itemsModel.sellingPrice}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Obx(
                  () => cartController
                          .isItemInCart(itemsModel.goodsNumber.toString())
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton.filled(
                                onPressed: () {
                                  if (itemsModel.inventoryThreshold <=
                                      cartController.getItemQuantity(
                                          itemsModel.goodsNumber.toString())) {
                                    MessageUtils.showWarning(
                                        "Inventory Threshold Reached");
                                    return;
                                  }
                                  cartController.incrementItemQuantity(
                                      itemsModel.goodsNumber.toString());
                                },
                                icon: const Icon(Icons.add)),
                            Text(
                              cartController
                                  .getItemQuantity(
                                      itemsModel.goodsNumber.toString())
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 20),
                            ),
                            IconButton.filled(
                                onPressed: () {
                                  cartController.decrementItemQuantity(
                                      itemsModel.goodsNumber.toString());
                                },
                                icon: const Icon(Icons.remove)),
                          ],
                        )
                      : IconButton.filled(
                          style: IconButton.styleFrom(
                              backgroundColor:
                                  VendingMachineColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            // storeUsername();
                            cartController.addItem(CartItem(
                                id: itemsModel.goodsNumber.toString(),
                                name: itemsModel.goodsName,
                                price: itemsModel.sellingPrice,
                                imageUrl: itemsModel.goodsImage,
                                channelNumber:
                                    itemsModel.channelNo.toString()));
                          },
                          icon: const Icon(Icons.shopping_cart)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
