package io.flutter.plugins;

import android.content.Context;
import android.util.Log;
import java.util.List;
import java.util.HashMap;
import java.util.ArrayList;
import io.flutter.plugin.common.MethodChannel;
import amlib.ccid.Reader;
import amlib.ccid.SCError;
import amlib.ccid.ReaderException;
import amlib.hw.HWType;
import amlib.hw.ReaderHwException;
 
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;

public class SmartCard {
    private static final String TAG = "SmartCard";
    private final Context context;
    private UsbManager usbManager;
    private UsbDevice _selectedDevice;
    private int currentMode;
 private Reader reader;
   

    public SmartCard(Context context) {
        this.context = context;
        this.usbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);
    }

    public void listAvailableDevices(MethodChannel.Result result) {
        try {
            Log.d(TAG, "Enumerating Devices");
            HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
            List<String> availableDevices = new ArrayList<>();
            for (UsbDevice device : deviceList.values()) {
                Log.d(TAG, String.format("Vendor ID: %s, Product ID: %s", Integer.toHexString(device.getVendorId()), Integer.toHexString(device.getProductId())));
                if (isAlcorReader(device)) {
                    Log.d(TAG, "Found Device: " + device.getDeviceName());
                    availableDevices.add(device.getDeviceName() + "-" + Integer.toHexString(device.getProductId()));
                }
            }
            if (availableDevices.isEmpty()) {
                Log.d(TAG, "No Supported Reader Found");
                result.success(new ArrayList<String>()); // return an empty list if no devices found
            } else {
                result.success(availableDevices);
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to list devices", e);
            result.error("DEVICE_ERROR", "Failed to list devices: " + e.getMessage(), null);
        }
    }

    private boolean isAlcorReader(UsbDevice device) {
    int vendorId = device.getVendorId();
    int productId = device.getProductId();
    return (vendorId == 0x058f && (productId == 0x9540 || productId == 0x9520 || productId == 0x9522 || productId == 0x9525 || productId == 0x9526)) ||
           (vendorId == 0x2CE3 && (productId == 0x9571 || productId == 0x9572 || productId == 0x9563 || productId == 0x9573 || productId == 0x9567));
}


    public void getSelectedDevice(String deviceName, MethodChannel.Result result) {
        HashMap<String, UsbDevice> devices = usbManager.getDeviceList();
        for (UsbDevice device : devices.values()) {
            if (deviceName.equals(device.getDeviceName() + "-" + Integer.toHexString(device.getProductId()))) {
                _selectedDevice = device;
                result.success("Device Selected Successfully");
                return;
            }
        }
        result.error("DEVICE_NOT_FOUND", "Selected device not found", null);
    }

//    public void readCard(MethodChannel.Result result) {
//         try {
//             interfaceSerial = new HardwareInterfaceSerial(HWType.eRS232);
//             interfaceSerial.Init("/dev/ttyS0", 38400); // Adjust if needed

//             reader = new Reader(interfaceSerial);
//             reader.setSlot((byte) 0);

//             int openResult = reader.open();
//             if (openResult != SCError.READER_SUCCESSFUL) {
//                 result.error("OPEN_FAIL", "Failed to open reader", null);
//                 return;
//             }

//             int powerResult = reader.setPower(Reader.CCID_POWERON, Reader.VoltageSwitch.Auto);
//             if (powerResult != SCError.READER_SUCCESSFUL) {
//                 result.error("POWER_FAIL", "Failed to power on card", null);
//                 return;
//             }

//             byte[] atr = reader.getATR();
//             Log.d(TAG, "ATR: " + bytesToHex(atr));

//             // Send SELECT AID command for payment card
//             byte[] select = hexStringToByteArray("00A404000E315041592E5359532E4444463031");
//             byte[] recv = new byte[300];
//             int[] recvLen = new int[1];

//             int selectResult = reader.transmit(select, select.length, recv, recvLen);
//             if (selectResult != SCError.READER_SUCCESSFUL) {
//                 result.error("APDU_FAIL", "SELECT AID failed", null);
//                 return;
//             }

//             // Send READ RECORD
//             byte[] readRecord = hexStringToByteArray("00B2010C00");
//             recvLen[0] = 300;
//             int readResult = reader.transmit(readRecord, readRecord.length, recv, recvLen);
//             if (readResult != SCError.READER_SUCCESSFUL) {
//                 result.error("APDU_FAIL", "READ RECORD failed", null);
//                 return;
//             }

//             String track2 = bytesToHex(recv, recvLen[0]);
//             String cardDetails = extractPanAndExpiry(track2);
//             result.success("Card Details: " + cardDetails);

//             reader.setPower(Reader.CCID_POWEROFF);

//         } catch (ReaderHwException | ReaderException e) {
//             result.error("EXCEPTION", e.getMessage(), null);
//         }
//     }

//     private String extractPanAndExpiry(String track2Data) {
//         int index = track2Data.indexOf("D");
//         if (index == -1) return "Track2 format not found";

//         String pan = track2Data.substring(0, index);
//         String expiry = track2Data.substring(index + 1, index + 5); // YYMM
//         return "PAN: " + pan + ", Expiry: " + expiry;
//     }

//     private String bytesToHex(byte[] bytes, int len) {
//         StringBuilder sb = new StringBuilder();
//         for (int i = 0; i < len; i++) {
//             sb.append(String.format("%02X", bytes[i]));
//         }
//         return sb.toString();
//     }

//     private byte[] hexStringToByteArray(String s) {
//         int len = s.length();
//         byte[] data = new byte[len / 2];
//         for (int i = 0; i < len; i += 2) {
//             data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
//                     + Character.digit(s.charAt(i + 1), 16));
//         }
//         return data;
//     }
}
