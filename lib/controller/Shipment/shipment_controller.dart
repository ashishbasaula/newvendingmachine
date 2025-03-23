import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/shipment_service.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

class ShipmentController extends GetxController {

  
  Future<void> dispenseItems({required int channelNumber}) async {
    try {
      String message = await ShipmentService.initiateShipment(
          1, channelNumber, 1, false, false);
      debugPrint(message);
    } on PlatformException catch (e) {
      MessageUtils.showError("Error dispensing items: ${e.toString()}");
    }
  }
}
