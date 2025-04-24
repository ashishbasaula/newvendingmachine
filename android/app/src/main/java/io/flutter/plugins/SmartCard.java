package io.flutter.plugins;


import android.content.Context;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import android.os.Bundle;
import android.content.Intent;
import android.content.IntentFilter;
import io.flutter.plugin.common.MethodChannel;
import amlib.ccid.Reader;


public class SmartCard {
    private static final String TAG = "SmartCard";
    private Context context;
    private UsbManager usbManager;
    public UsbDevice _selectedDevice;
    private int currentMode;

	private static final int MODE_7816 = Reader.CardModeASYNC;
	private static final int MODE_24C = Reader.CardModeI2C;
	private static final int MODE_4428 = Reader.CardModeSLE4428;
	private static final int MODE_4442 = Reader.CardModeSLE4442;
	private static final int MODE_88SC1608 = Reader.CardModeAT88SC1608;
	private static final int MODE_AT45D = Reader.CardModeAT45D041;
	private static final int MODE_6636 = Reader.CardModeSLE6636;
	private static final int MODE_88SC102 = Reader.CardModeAT88SC102;
	private static final int MODE_88SC153 = Reader.CardModeAT88SC153;

	private static final int MODE_NFC_MifareS50 = 0x200;
	private static final int INTERFACE_SMARTCARD = 0xB;
 


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


    


public int chooseReaderMode(int index,MethodChannel.Result result){
    switch(index){
        case 0:
            currentMode=Reader.CardModeASYNC;
		result.success("Reader Set Sucessfully");
			return currentMode;
          
            case  1:
                currentMode=Reader.CardModeI2C;
                result.success("Reader Set Sucessfully");
				return currentMode;
             
            case 2:
                currentMode=Reader.CardModeSLE4428;
                result.success("Reader Set Sucessfully");
				return currentMode;
            
            case 3:
                currentMode=Reader.CardModeSLE4442;
                result.success("Reader Set Sucessfully");
				return currentMode;
             
            case 4:
                currentMode=Reader.CardModeAT88SC1608;
                result.success("Reader Set Sucessfully");
				return currentMode;
           
            case 5:
                currentMode=Reader.CardModeAT45D041;
                result.success("Reader Set Sucessfully");
				return currentMode;
        
            case 6:
                currentMode=Reader.CardModeSLE6636;
                result.success("Reader Set Sucessfully");
				return currentMode;
            
            case 7:
                currentMode=Reader.CardModeAT88SC102;
                result.success("Reader Set Sucessfully");
				return currentMode;
           
                 case 8:
                currentMode=Reader.CardModeAT88SC153;
                result.success("Reader Set Sucessfully");
				return currentMode;
            
                 case 9:
                currentMode=0x200;
                result.success("Reader Set Sucessfully");
				return currentMode;
          
                 case 10:
                currentMode=0xB;
                result.success("Reader Set Sucessfully");
				return currentMode;

				default:
					return 0;
            
    }
}

public void getSelectedDevice(String deviceName,MethodChannel.Result result) {
    HashMap<String, UsbDevice> devices = usbManager.getDeviceList();
    for (UsbDevice device : devices.values()) {
        // Assuming the deviceName format is exactly how you set in Flutter's Dropdown
        if (deviceName.equals(device.getDeviceName() + "-" + Integer.toHexString(device.getProductId()))) {
            _selectedDevice= device;
            result.success("Device Selected Sucessfully");
        }
    }
    
}


private void switchMode(MethodChannel.Result result) {
    try {
        UsbDevice dev = _selectedDevice;
        if (dev == null) {
            result.error("NO_DEVICE", "No USB device selected", null);
            return;
        }

        Reader reader = new Reader(context);
        if (reader.OpenDevice(dev) != 0) {
            result.error("OPEN_FAIL", "Could not open smart card reader", null);
            return;
        }

        reader.SetCardType(currentMode);
        byte[] atr = new byte[64];
        int[] atrLen = new int[1];
        int powerStatus = reader.PowerOn(0, atr, atrLen);
        if (powerStatus != 0) {
            result.error("CARD_FAIL", "Could not power on the card", null);
            return;
        }

        // SELECT Payment App
        byte[] select = hexStringToByteArray("00A404000E315041592E5359532E4444463031");
        byte[] recv = new byte[300];
        int[] recvLen = new int[1];
        int selectStatus = reader.Transmit(0, select, select.length, recv, recvLen);
        if (selectStatus != 0) {
            result.error("APDU_FAIL", "Failed SELECT AID", null);
            return;
        }

        // READ RECORD (Track 2 Equivalent)
        byte[] readRecord = hexStringToByteArray("00B2010C00");
        recv = new byte[300];
        recvLen[0] = 0;
        int readStatus = reader.Transmit(0, readRecord, readRecord.length, recv, recvLen);

        if (readStatus != 0) {
            result.error("APDU_FAIL", "Failed READ RECORD", null);
            return;
        }

        // Parse PAN and Expiry from Track 2
        String track2 = bytesToHex(recv, recvLen[0]);
        String cardDetails = extractPanAndExpiry(track2);
        result.success("Card Details: " + cardDetails);

    } catch (Exception e) {
        result.error("ERROR", "Exception: " + e.getMessage(), null);
    }
}

private byte[] hexStringToByteArray(String s) {
    int len = s.length();
    byte[] data = new byte[len / 2];
    for (int i = 0; i < len; i += 2) {
        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                             + Character.digit(s.charAt(i+1), 16));
    }
    return data;
}

private String bytesToHex(byte[] bytes, int len) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < len; i++) {
        sb.append(String.format("%02X", bytes[i]));
    }
    return sb.toString();
}

private String extractPanAndExpiry(String track2Data) {
    // EMV Track 2 equivalent format: PAN + D + Expiry + ServiceCode
    int index = track2Data.indexOf("D");
    if (index == -1) return "Track2 Format Not Found";

    String pan = track2Data.substring(0, index);
    String expiry = track2Data.substring(index + 1, index + 5); // YYMM
    return "PAN: " + pan + ", Expiry: " + expiry;
}




}
