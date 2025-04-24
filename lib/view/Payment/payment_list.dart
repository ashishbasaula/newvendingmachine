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
  String? selectedDevice;
  int? selectedModeIndex;
  String? statusMessage;

  final readerModes = <int, String>{
    0: 'ISO 7816 (ASYNC)',
    1: 'AT24Cxx (I2C)',
    2: 'SLE4428',
    3: 'SLE4442',
    4: 'AT88SC1608',
    5: 'AT45D041',
    6: 'SLE6636',
    7: 'AT88SC102',
    8: 'AT88SC153',
    9: 'Mifare S50 (NFC)',
    10: 'SmartCard Interface (B)',
  };

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

  Future<void> selectDevice(String deviceName) async {
    try {
      final result =
          await platform.invokeMethod<String>('selectDevice', deviceName);
      setState(() {
        selectedDevice = deviceName;
        statusMessage = result;
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error selecting device: ${e.toString()}";
      });
    }
  }

  Future<void> setReaderMode(int index) async {
    try {
      final result =
          await platform.invokeMethod<String>('chooseReaderMode', index);
      setState(() {
        selectedModeIndex = index;
        statusMessage = result;
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error setting reader mode: ${e.toString()}";
      });
    }
  }

  Future<void> readCardDetails() async {
    try {
      final result = await platform.invokeMethod<String>('switchMode');
      setState(() {
        statusMessage = "Card Response:\n$result";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error reading card: ${e.toString()}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Card Payment Reader")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: listDevices,
                child: const Text("Refresh Device List"),
              ),
              const SizedBox(height: 16),
              if (devices.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Device:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      hint: const Text("Select Device"),
                      value: selectedDevice,
                      isExpanded: true,
                      items: devices.map((device) {
                        return DropdownMenuItem(
                            value: device, child: Text(device));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) selectDevice(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Select Reader Mode:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      hint: const Text("Select Reader Mode"),
                      value: selectedModeIndex,
                      isExpanded: true,
                      items: readerModes.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text("${entry.key} - ${entry.value}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setReaderMode(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: readCardDetails,
                      child: const Text("Read Card Details"),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              if (statusMessage != null)
                Text(
                  statusMessage!,
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
