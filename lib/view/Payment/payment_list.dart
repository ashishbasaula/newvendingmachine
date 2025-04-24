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
        statusMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment List"),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: devices.length,
          itemBuilder: (contex, index) {
            return ListTile(
              title: Text(devices[index]),
            );
          }),
    );
  }
}
