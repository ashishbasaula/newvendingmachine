package io.flutter.plugins;

import android.content.Context;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import amlib.ccid.Reader;
import amlib.hw.HardwareInterface;
import amlib.hw.HardwareInterfaceSerial;
import amlib.hw.HWType;

public class SmartCard {
    private static final String TAG = "SmartCard";
    private final Context context;
    private UsbManager usbManager;
    private UsbDevice _selectedDevice;
    private int currentMode;

    private HardwareInterfaceSerial hardwareInterface;

    public SmartCard(Context context) {
        this.context = context;
        this.usbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);
    }

    public void listAvailableDevices(MethodChannel.Result result) {
        try {
            HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();
            List<String> availableDevices = new ArrayList<>();
            for (UsbDevice device : deviceList.values()) {
                Log.d(TAG, String.format("Vendor ID: %s, Product ID: %s",
                        Integer.toHexString(device.getVendorId()),
                        Integer.toHexString(device.getProductId())));
                if (isAlcorReader(device)) {
                    availableDevices.add(device.getDeviceName() + "-" + Integer.toHexString(device.getProductId()));
                }
            }
            result.success(availableDevices);
        } catch (Exception e) {
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

    public int chooseReaderMode(int index, MethodChannel.Result result) {
        currentMode = index;
        result.success("Reader Mode Set Successfully");
        return currentMode;
    }

    public void initHardwareInterface(MethodChannel.Result result) {
        try {
            if (_selectedDevice == null) {
                result.error("NO_DEVICE", "No device selected", null);
                return;
            }

            hardwareInterface = new HardwareInterfaceSerial(HWType.eUSB);
            boolean initialized = hardwareInterface.Init(usbManager, _selectedDevice);
            if (!initialized) {
                result.error("INIT_FAILED", "Failed to initialize hardware interface", null);
                return;
            }

            result.success("HardwareInterface initialized successfully");
        } catch (Exception e) {
            result.error("INIT_ERROR", "Exception during initialization: " + e.getMessage(), null);
        }
    }

    public void switchMode(MethodChannel.Result result) {
        try {
            if (hardwareInterface == null) {
                result.error("NOT_INITIALIZED", "Hardware interface not initialized", null);
                return;
            }

            Reader reader = new Reader(hardwareInterface);
            reader.setSlot((byte) 0);
            int openStatus = reader.open();

            if (openStatus != 0) {
                result.error("READER_OPEN_FAIL", "Reader open failed with status: " + openStatus, null);
                return;
            }

            int powerStatus = reader.setPower(Reader.CCID_POWERON);
            if (powerStatus != 0) {
                result.error("CARD_POWER_FAIL", "Failed to power on card", null);
                return;
            }

            // SELECT AID
            byte[] select = hexStringToByteArray("00A404000E315041592E5359532E4444463031");
            byte[] recv = new byte[300];
            int[] recvLen = new int[]{300};

            int selectStatus = reader.transmit(select, select.length, recv, recvLen);
            if (selectStatus != 0) {
                result.error("SELECT_AID_FAIL", "Failed to SELECT AID", null);
                return;
            }

            // READ RECORD
            byte[] readRecord = hexStringToByteArray("00B2010C00");
            recv = new byte[300];
            recvLen[0] = 300;

            int readStatus = reader.transmit(readRecord, readRecord.length, recv, recvLen);
            if (readStatus != 0) {
                result.error("READ_RECORD_FAIL", "Failed to READ RECORD", null);
                return;
            }

            String track2 = bytesToHex(recv, recvLen[0]);
            String cardDetails = extractPanAndExpiry(track2);
            result.success("Card Details: " + cardDetails);

        } catch (Exception e) {
            result.error("EXCEPTION", "Exception during card operation: " + e.getMessage(), null);
        }
    }

    private byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                                + Character.digit(s.charAt(i + 1), 16));
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
        int index = track2Data.indexOf("D");
        if (index == -1) return "Track2 Format Not Found";

        String pan = track2Data.substring(0, index);
        String expiry = track2Data.substring(index + 1, index + 5); // YYMM
        return "PAN: " + pan + ", Expiry: " + expiry;
    }
}
