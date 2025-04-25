// package io.flutter.plugins;

// import android.content.Context;

// import com.wsm.comlib.SerialPortManager;
// import com.wsm.comlib.callback.SerialPortOpenListener;
// import com.wsm.comlib.callback.SerialPortDataListener;

// import static com.wsm.comlib.constant.ConnectCostant.*;

// public class ScannerHelper {

//     private static SerialPortDataListener listener;

//     public static void startScan(Context context, final ResultCallback callback) {
//         listener = new SerialPortDataListener() {
//             @Override
//             public void onDataReceived(byte status, String dataMessage) {
//                 callback.onResult(dataMessage, null);
//                 SerialPortManager.getInstance().closeSerialPort(); // optional
//             }

//             @Override
//             public void onOriginalDataReceived(byte status, byte[] bytes, int length) {
//                 // optional
//             }
//         };

//         SerialPortManager.getInstance().openSerialPort(context, new SerialPortOpenListener() {
//             @Override
//             public void onConnectStatusChange(int status) {
//                 switch (status) {
//                     case ACTION_USB_PERMISSION_GRANTED:
//                         // USB ready, now trigger scan
//                         SerialPortManager.getInstance().scanTrigger(actionStatus -> {
//                             // optionally log
//                         });
//                         break;
//                     case ACTION_USB_PERMISSION_NOT_GRANTED:
//                         callback.onResult(null, "USB permission not granted");
//                         break;
//                     case ACTION_NO_USB:
//                         callback.onResult(null, "No USB connected");
//                         break;
//                     case ACTION_USB_DISCONNECTED:
//                         callback.onResult(null, "USB disconnected");
//                         break;
//                     case ACTION_USB_NOT_SUPPORTED:
//                         callback.onResult(null, "USB not supported");
//                         break;
//                     default:
//                         callback.onResult(null, "Unknown USB status");
//                         break;
//                 }
//             }
//         }, listener);
//     }

//     public interface ResultCallback {
//         /**
//          * Called with scan result or error.
//          * @param scanResult The scan result, or null if error.
//          * @param errorMessage The error message, or null if success.
//          */
//         void onResult(String scanResult, String errorMessage);
//     }
// }



package io.flutter.plugins;

import android.content.Context;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;

import com.wsm.comlib.SerialPortManager;
import com.wsm.comlib.callback.SerialPortOpenListener;
import com.wsm.comlib.callback.SerialPortDataListener;

import static com.wsm.comlib.constant.ConnectCostant.*;

public class ScannerHelper {

    private static SerialPortDataListener listener;

    public static void startScan(Context context, final ResultCallback callback) {
        // First check if we have USB permission
        UsbManager usbManager = (UsbManager) context.getSystemService(Context.USB_SERVICE);
        SerialPortManager serialPortManager = SerialPortManager.getInstance();
        
        // Check if the USB device is already available and permission is granted
        UsbDevice usbDevice = serialPortManager.getUsbDevice(usbManager);
        if (usbDevice != null && usbManager.hasPermission(usbDevice)) {
            // If we already have permission, proceed with scanning
            setupListenerAndStartScan(context, callback);
        } else {
            // Request USB permission
            serialPortManager.requestUsbPermission(context, new SerialPortOpenListener() {
                @Override
                public void onConnectStatusChange(int status) {
                    switch (status) {
                        case ACTION_USB_PERMISSION_GRANTED:
                            // Permission granted, now setup listener and start scan
                            setupListenerAndStartScan(context, callback);
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
            });
        }
    }

    private static void setupListenerAndStartScan(Context context, final ResultCallback callback) {
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

        // Now that we have permission, open the serial port
        SerialPortManager.getInstance().openSerialPort(context, new SerialPortOpenListener() {
            @Override
            public void onConnectStatusChange(int status) {
                if (status == ACTION_USB_PERMISSION_GRANTED) {
                    // Trigger the scan
                    SerialPortManager.getInstance().scanTrigger(actionStatus -> {
                        // optionally log
                    });
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