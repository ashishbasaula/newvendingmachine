import 'package:flutter/services.dart';

class ShipmentService {
  // Define the method channel
  static const platform = MethodChannel('com.appAra.newVending/device');

  // Function to initiate shipment
  static Future<String> initiateShipment(
      int addr, int no, int type, bool check, bool lift) async {
    try {
      final String result = await platform.invokeMethod('initiateShipment',
          {'addr': addr, 'no': no, 'type': type, 'check': check, 'lift': lift});
      return result;
    } on PlatformException catch (e) {
      return "Failed to initiate shipment: ${e.message}";
    }
  }
}
