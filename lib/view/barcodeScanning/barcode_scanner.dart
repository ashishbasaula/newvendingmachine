import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScannerHomePage extends StatefulWidget {
  @override
  _ScannerHomePageState createState() => _ScannerHomePageState();
}

class _ScannerHomePageState extends State<ScannerHomePage> {
  static const platform = MethodChannel('com.appAra.newVending/scanner');

  String _status = 'Ready';
  String _scanMessage = 'No code scanning information is available';
  String _version = '';
  List<ScanDevice> _devices = [];
  int _selectedIndex = -1;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDeviceAdded':
          _handleDeviceAdded(call.arguments['node']);
          break;
        case 'onDeviceStatusChanged':
          _handleDeviceStatusChanged(
            call.arguments['node'],
            call.arguments['status'],
          );
          break;
        case 'onScanResult':
          _handleScanResult(
            call.arguments['deviceId'],
            call.arguments['data'],
            call.arguments['count'],
          );
          break;
        case 'onStatusUpdate':
          _handleStatusUpdate(call.arguments['message']);
          break;
        case 'onVersionUpdate':
          _handleVersionUpdate(call.arguments['version']);
          break;
        case 'onDeviceListCleared':
          _handleDeviceListCleared();
          break;
      }
    });
  }

  Future<void> _initializeScanner() async {
    try {
      final String version = await platform.invokeMethod('initializeScanner');
      setState(() {
        _version = version;
      });
    } on PlatformException catch (e) {
      print("Failed to initialize scanner: '${e.message}'");
    }
  }

  Future<void> _startScan() async {
    if (_selectedIndex < 0) {
      _showSnackBar('Please select a device first');
      return;
    }

    try {
      await platform.invokeMethod('startScan', {
        'deviceNode': _devices[_selectedIndex].node,
      });
      setState(() {
        _isScanning = true;
      });
    } on PlatformException catch (e) {
      _showSnackBar("Failed to start scan: '${e.message}'");
    }
  }

  Future<void> _stopScan() async {
    if (_selectedIndex < 0) {
      _showSnackBar('Please select a device first');
      return;
    }

    try {
      await platform.invokeMethod('stopScan', {
        'deviceNode': _devices[_selectedIndex].node,
      });
      setState(() {
        _isScanning = false;
      });
    } on PlatformException catch (e) {
      _showSnackBar("Failed to stop scan: '${e.message}'");
    }
  }

  void _handleDeviceAdded(int node) {
    setState(() {
      _devices.add(ScanDevice(node: node, name: 'Device$node'));
    });
  }

  void _handleDeviceStatusChanged(int node, int status) {
    setState(() {
      final deviceIndex = _devices.indexWhere((device) => device.node == node);
      if (deviceIndex != -1) {
        _devices[deviceIndex] = _devices[deviceIndex].copyWith(status: status);
      }
    });
  }

  void _handleScanResult(int deviceId, String data, int count) {
    setState(() {
      _scanMessage = '[$count][device number:$deviceId] Buf: $data';
    });
  }

  void _handleStatusUpdate(String message) {
    setState(() {
      _status = message;
    });
  }

  void _handleVersionUpdate(String version) {
    setState(() {
      _version = version;
    });
  }

  void _handleDeviceListCleared() {
    setState(() {
      _devices.clear();
      _selectedIndex = -1;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'not detected';
      case 1:
        return 'inserted';
      case 2:
        return 'connected';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode setup",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _version,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _status.contains('successful')
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _status.contains('successful')
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          Text(_status, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Scan Message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_scanMessage,
                          style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !_isScanning ? null : _stopScan,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Device List Header
            const Text(
              'Devices',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Device List
            Expanded(
              child: _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No devices found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isSelected = _selectedIndex == index;

                        return Card(
                          elevation: isSelected ? 4 : 1,
                          color: isSelected ? Colors.blue[50] : null,
                          child: ListTile(
                            leading: Radio<int>(
                              value: index,
                              groupValue: _selectedIndex,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIndex = value!;
                                });
                              },
                            ),
                            title: Text(
                              device.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(_getStatusText(device.status)),
                            trailing: Icon(
                              _getStatusIcon(device.status),
                              color: _getStatusColor(device.status),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.help_outline;
      case 1:
        return Icons.usb;
      case 2:
        return Icons.link;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class ScanDevice {
  final int node;
  final String name;
  final int status;

  ScanDevice({required this.node, required this.name, this.status = 0});

  ScanDevice copyWith({int? node, String? name, int? status}) {
    return ScanDevice(
      node: node ?? this.node,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}
