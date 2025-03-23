import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  NetworkSettingsPageState createState() => NetworkSettingsPageState();
}

class NetworkSettingsPageState extends State<NetworkSettingsPage> {
  final methodChannel = MethodChannel("com.yourdomain.vending/channel");

  bool _isEthernetEnabled = false;
  String _ipAddress = '192.168.1.1';
  String _subnetMask = '255.255.255.0';
  String _gateway = '192.168.1.254';
  String _dnsPrimary = '8.8.8.8';
  String _dnsSecondary = '8.8.4.4';

  void _updateEthernetSettings() async {
    if (_isEthernetEnabled) {
      try {
        final String result =
            await methodChannel.invokeMethod('setEthernetMode', {
          'mode': 'Static',
          'ip': _ipAddress,
          'gateway': _gateway,
          'mask': _subnetMask,
          'dns1': _dnsPrimary,
          'dns2': _dnsSecondary,
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Settings updated: $result')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update settings: ${e.toString()}')));
      }
    } else {
      try {
        final String result = await methodChannel
            .invokeMethod('setEthernetMode', {'mode': 'DHCP'});
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ethernet mode set to DHCP: $result')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to set DHCP mode: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateEthernetSettings,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable Ethernet'),
            value: _isEthernetEnabled,
            onChanged: (bool value) {
              setState(() {
                _isEthernetEnabled = value;
              });
            },
          ),
          Visibility(
            visible: _isEthernetEnabled,
            child: Column(
              children: [
                _buildTextField(
                    'IP Address', _ipAddress, (val) => _ipAddress = val),
                _buildTextField(
                    'Subnet Mask', _subnetMask, (val) => _subnetMask = val),
                _buildTextField(
                    'Default Gateway', _gateway, (val) => _gateway = val),
                _buildTextField(
                    'Primary DNS', _dnsPrimary, (val) => _dnsPrimary = val),
                _buildTextField('Secondary DNS', _dnsSecondary,
                    (val) => _dnsSecondary = val),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    return ListTile(
      title: Text(label),
      subtitle: TextField(
        decoration: InputDecoration(hintText: 'Enter $label'),
        controller: TextEditingController(text: initialValue)
          ..selection = TextSelection.fromPosition(
              TextPosition(offset: initialValue.length)),
        keyboardType: TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }
}
