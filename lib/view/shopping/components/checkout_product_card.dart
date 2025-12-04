import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Helper/helper_controller.dart';
import 'package:newvendingmachine/controller/Helper/price_format_helper.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/module/cart_model.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

class CheckoutProductCard extends StatelessWidget {
  final CartItem cartItem;
  CheckoutProductCard({super.key, required this.cartItem});
  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth * 0.25;
        double fontSize = constraints.maxWidth * 0.05;
        double priceFontSize = constraints.maxWidth * 0.06;
        double iconSize = constraints.maxWidth * 0.06;
        return Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cartItem.imageUrl,
                    height: imageSize,
                    width: imageSize,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.name,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                      ),
                      Text(
                        cartItem.itemCategory,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black45,
                              fontSize: fontSize * 0.7,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "\$${PriceFormatHelper.formatPrice(cartItem.price)}",
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: priceFontSize,
                                color: Colors.green,
                              ),
                    ),
                    SizedBox(height: constraints.maxWidth * 0.02),
                    Row(
                      children: [
                        IconButton(
                          iconSize: iconSize,
                          onPressed: () {
                            final item = cartController.items
                                .where((e) => e.id == cartItem.id)
                                .first;
                            if (item.inventoryThreasHold <=
                                cartController.getItemQuantity(cartItem.id)) {
                              MessageUtils.showWarning(
                                  "Inventory Threshold Reached");
                              return;
                            }
                            cartController.incrementItemQuantity(cartItem.id);
                          },
                          icon: const Icon(Icons.add),
                        ),
                        Text(
                          cartController
                              .getItemQuantity(cartItem.id)
                              .toString(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: fontSize * 0.8,
                                  ),
                        ),
                        IconButton(
                          iconSize: iconSize,
                          onPressed: () {
                            cartController.decrementItemQuantity(cartItem.id);
                          },
                          icon: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
