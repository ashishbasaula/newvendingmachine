package io.flutter.plugins;

import android.content.Context;

import com.wsm.comlib.SerialPortManager;
import com.wsm.comlib.callback.SerialPortOpenListener;
import com.wsm.comlib.callback.SerialPortDataListener;

import static com.wsm.comlib.constant.ConnectCostant.*;

public class ScannerHelper {

    private static SerialPortDataListener listener;

    public static void startScan(Context context, final ResultCallback callback) {
        listener = new SerialPortDataListener() {
            @Override
            public void onDataReceived(byte status, String dataMessage) {
                callback.onResult(dataMessage, null);
                SerialPortManager.getInstance().closeSerialPort(); // optional
            }

            @Override
            public void onOriginalDataReceived(byte status, byte[] bytes, int length) {
                // optional
            }
        };

        SerialPortManager.getInstance().openSerialPort(context, new SerialPortOpenListener() {
            @Override
            public void onConnectStatusChange(int status) {
                switch (status) {
                    case ACTION_USB_PERMISSION_GRANTED:
                        // USB ready, now trigger scan
                        SerialPortManager.getInstance().scanTrigger(actionStatus -> {
                            // optionally log
                        });
                        break;
                    case ACTION_USB_PERMISSION_NOT_GRANTED:
                        callback.onResult(null, "USB permission not granted");
                        break;
                    case ACTION_NO_USB:
                        callback.onResult(null, "No USB connected");
                        break;
                    case ACTION_USB_DISCONNECTED:
                        callback.onResult(null, "USB disconnected");
                        break;
                    case ACTION_USB_NOT_SUPPORTED:
                        callback.onResult(null, "USB not supported");
                        break;
                    default:
                        callback.onResult(null, "Unknown USB status");
                        break;
                }
            }
        }, listener);
    }

    public interface ResultCallback {
        /**
         * Called with scan result or error.
         * @param scanResult The scan result, or null if error.
         * @param errorMessage The error message, or null if success.
         */
        void onResult(String scanResult, String errorMessage);
    }
}



// package io.flutter.plugins;

// import android.content.Context;
// import android.hardware.usb.UsbDevice;
// import android.hardware.usb.UsbManager;
// import android.content.Intent;
// import android.app.PendingIntent;
// import android.content.BroadcastReceiver;
// import android.content.IntentFilter;

// import com.wsm.comlib.SerialPortManager;
// import com.wsm.comlib.callback.SerialPortOpenListener;
// import com.wsm.comlib.callback.SerialPortDataListener;

// import static com.wsm.comlib.constant.ConnectCostant.*;

// public class ScannerHelper {

//     private static final String ACTION_USB_PERMISSION = "io.flutter.plugins.USB_PERMISSION";
//     private static SerialPortDataListener listener;
//     private static ResultCallback currentCallback;
//     private static Context appContext;
//     private static BroadcastReceiver usbPermissionReceiver;

//     public static void startScan(Context context, final ResultCallback callback) {
//         appContext = context.getApplicationContext();
//         currentCallback = callback;

//         // Initialize USB manager and find device
//         UsbManager usbManager = (UsbManager) appContext.getSystemService(Context.USB_SERVICE);
//         SerialPortManager serialPortManager = SerialPortManager.getInstance();

//         // You'll need to know your device's vendor and product IDs
//         // Replace these with your actual scanner's IDs
//         int vendorId = 1234; // Example - get your device's actual vendor ID
//         int productId = 5678; // Example - get your device's actual product ID

//         UsbDevice device = findUsbDevice(usbManager, vendorId, productId);

//         if (device == null) {
//             callback.onResult(null, "USB device not found");
//             return;
//         }

//         if (usbManager.hasPermission(device)) {
//             // Already have permission, proceed with scan
//             setupAndStartScan();
//         } else {
//             // Request permission
//             requestUsbPermission(usbManager, device);
//         }
//     }

//     private static UsbDevice findUsbDevice(UsbManager usbManager, int vendorId, int productId) {
//         for (UsbDevice device : usbManager.getDeviceList().values()) {
//             if (device.getVendorId() == vendorId && device.getProductId() == productId) {
//                 return device;
//             }
//         }
//         return null;
//     }

//     private static void requestUsbPermission(UsbManager usbManager, UsbDevice device) {
//         // Create the permission receiver if not already created
//         if (usbPermissionReceiver == null) {
//             usbPermissionReceiver = new BroadcastReceiver() {
//                 public void onReceive(Context context, Intent intent) {
//                     String action = intent.getAction();
//                     if (ACTION_USB_PERMISSION.equals(action)) {
//                         synchronized (this) {
//                             UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
//                             if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
//                                 if (device != null) {
//                                     // Permission granted, proceed with scan
//                                     setupAndStartScan();
//                                 }
//                             } else {
//                                 currentCallback.onResult(null, "USB permission denied");
//                             }
//                             appContext.unregisterReceiver(usbPermissionReceiver);
//                             usbPermissionReceiver = null;
//                         }
//                     }
//                 }
//             };
//         }

//         // Register the receiver
//         IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
//         appContext.registerReceiver(usbPermissionReceiver, filter);

//         // Create the permission intent and request
//         PendingIntent permissionIntent = PendingIntent.getBroadcast(
//             appContext, 
//             0, 
//             new Intent(ACTION_USB_PERMISSION),
//             PendingIntent.FLAG_IMMUTABLE
//         );
//         usbManager.requestPermission(device, permissionIntent);
//     }

//     private static void setupAndStartScan() {
//         // Initialize the listener
//         listener = new SerialPortDataListener() {
//             @Override
//             public void onDataReceived(byte status, String dataMessage) {
//                 currentCallback.onResult(dataMessage, null);
//                 SerialPortManager.getInstance().closeSerialPort();
//             }

//             @Override
//             public void onOriginalDataReceived(byte status, byte[] bytes, int length) {
//                 // optional
//             }
//         };

//         // Open the serial port and start scanning
//         SerialPortManager.getInstance().openSerialPort(appContext, new SerialPortOpenListener() {
//             @Override
//             public void onConnectStatusChange(int status) {
//                 if (status == ACTION_USB_PERMISSION_GRANTED) {
//                     SerialPortManager.getInstance().scanTrigger(actionStatus -> {
//                         // optionally log
//                     });
//                 } else {
//                     currentCallback.onResult(null, "Failed to open serial port");
//                 }
//             }
//         }, listener);
//     }

//     public interface ResultCallback {
//         void onResult(String scanResult, String errorMessage);
//     }
// }