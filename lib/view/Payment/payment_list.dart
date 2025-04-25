import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentList extends StatefulWidget {
  const PaymentList({super.key});

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  static const platform = MethodChannel('com.appAra.newVending/device');

  List<String> devices = [];

  String? statusMessage;

  Future<void> listDevices() async {
    try {
      final result =
          await platform.invokeMethod<List<dynamic>>('GetPaymentList');
      setState(() {
        devices = result?.map((e) => e.toString()).toList() ?? [];
        statusMessage = "Found ${devices.length} devices.";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error listing devices: ${e.toString()}";
      });
    }
  }

  // Future<void> selectDevice(String deviceName) async {
  //   try {
  //     final result =
  //         await platform.invokeMethod<String>('selectDevice', deviceName);
  //     setState(() {
  //       selectedDevice = deviceName;
  //       statusMessage = result;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       statusMessage = "Error selecting device: ${e.toString()}";
  //     });
  //   }
  // }

  // Future<void> setReaderMode(int index) async {
  //   try {
  //     final result =
  //         await platform.invokeMethod<String>('chooseReaderMode', index);
  //     setState(() {
  //       selectedModeIndex = index;
  //       statusMessage = result;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       statusMessage = "Error setting reader mode: ${e.toString()}";
  //     });
  //   }
  // }

  // Future<void> readCardDetails() async {
  //   try {
  //     final result = await platform.invokeMethod<String>('switchMode');
  //     setState(() {
  //       statusMessage = "Card Response:\n$result";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       statusMessage = "Error reading card: ${e.toString()}";
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    listDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Smart Card Payment Reader")),
        body: ListView.builder(
            itemCount: devices.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(devices[index]),
              );
            }));
  }
}
