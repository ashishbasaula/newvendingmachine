import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Device/setting_controller.dart';

class DisplaySettingsPage extends StatefulWidget {
  const DisplaySettingsPage({super.key});

  @override
  DisplaySettingsPageState createState() => DisplaySettingsPageState();
}

class DisplaySettingsPageState extends State<DisplaySettingsPage> {
  double _brightness = 50; // Assuming brightness is between 0 to 100
  bool _hdmiOutput = false; // HDMI output toggle

  final settingController = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Brightness'),
            subtitle: Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: _brightness,
              label: _brightness.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _brightness = value;
                  settingController.dsBrightness(value.toInt());
                });
              },
            ),
          ),
          SwitchListTile(
            title: const Text('HDMI Output'),
            value: _hdmiOutput,
            onChanged: (bool value) {
              setState(() {
                _hdmiOutput = value;
                settingController.dsToggleHdmi(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
