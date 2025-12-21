import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/view/sumupTest/new_sumup_test.dart';

class PowerManagementPage extends StatefulWidget {
  const PowerManagementPage({super.key});

  @override
  PowerManagementPageState createState() => PowerManagementPageState();
}

class PowerManagementPageState extends State<PowerManagementPage> {
  bool _isBatterySaverEnabled = false; // Track battery saver status
  DateTime _powerOnTime = DateTime.now(); // Default to current time
  DateTime _powerOffTime =
      DateTime.now().add(const Duration(hours: 1)); // Default to an hour later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Management'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable Battery Saver'),
            value: _isBatterySaverEnabled,
            onChanged: (bool value) {
              setState(() {
                _isBatterySaverEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Set Power On Time'),
            subtitle: Text('${_powerOnTime.hour}:${_powerOnTime.minute}'),
            onTap: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_powerOnTime),
              );
              if (selectedTime != null) {
                setState(() {
                  _powerOnTime = DateTime(
                    _powerOnTime.year,
                    _powerOnTime.month,
                    _powerOnTime.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                });
              }
            },
          ),
          ListTile(
            title: const Text('Set Power Off Time'),
            subtitle: Text('${_powerOffTime.hour}:${_powerOffTime.minute}'),
            onTap: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_powerOffTime),
              );
              if (selectedTime != null) {
                setState(() {
                  _powerOffTime = DateTime(
                    _powerOffTime.year,
                    _powerOffTime.month,
                    _powerOffTime.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                });
              }
            },
          ),
          // ListTile(
          //   title: const Text('Save Settings'),
          //   trailing: const Icon(Icons.save),
          //   onTap: () {
          //     Get.to(() => SumUpLoginWebView());
          //   },
          // ),
        ],
      ),
    );
  }
}
