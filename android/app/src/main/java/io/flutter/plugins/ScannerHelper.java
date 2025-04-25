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
import android.content.Intent;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.util.Log;

import com.wsm.comlib.SerialPortManager;
import com.wsm.comlib.callback.SerialPortOpenListener;
import com.wsm.comlib.callback.SerialPortDataListener;

import static com.wsm.comlib.constant.ConnectCostant.*;

public class ScannerHelper {

    private static final String ACTION_USB_PERMISSION = "io.flutter.plugins.USB_PERMISSION";
    private static final String TAG = "ScannerHelper";
    
    // Device VID/PID pairs from your logs
    private static final int[][] SUPPORTED_DEVICES = {
        {11491, 38247},  // First device
        {5418, 34831}    // Second device
    };

    private static SerialPortDataListener listener;
    private static ResultCallback currentCallback;
    private static Context appContext;
    private static BroadcastReceiver usbPermissionReceiver;

    public static void startScan(Context context, final ResultCallback callback) {
        appContext = context.getApplicationContext();
        currentCallback = callback;

        UsbManager usbManager = (UsbManager) appContext.getSystemService(Context.USB_SERVICE);
        UsbDevice device = findSupportedDevice(usbManager);

        if (device == null) {
            callback.onResult(null, "Supported USB device not found");
            return;
        }

        if (usbManager.hasPermission(device)) {
            setupAndStartScan();
        } else {
            requestUsbPermission(usbManager, device);
        }
    }

    private static UsbDevice findSupportedDevice(UsbManager usbManager) {
        for (UsbDevice device : usbManager.getDeviceList().values()) {
            for (int[] supportedDevice : SUPPORTED_DEVICES) {
                if (device.getVendorId() == supportedDevice[0] && 
                    device.getProductId() == supportedDevice[1]) {
                    Log.d(TAG, "Found supported device: VID=" + supportedDevice[0] + 
                          " PID=" + supportedDevice[1]);
                    return device;
                }
            }
        }
        return null;
    }

    private static void requestUsbPermission(UsbManager usbManager, UsbDevice device) {
        if (usbPermissionReceiver != null) {
            try {
                appContext.unregisterReceiver(usbPermissionReceiver);
            } catch (IllegalArgumentException e) {
                // Receiver wasn't registered, ignore
            }
        }

        usbPermissionReceiver = new BroadcastReceiver() {
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                if (ACTION_USB_PERMISSION.equals(action)) {
                    synchronized (this) {
                        UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                        if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                            if (device != null) {
                                setupAndStartScan();
                            }
                        } else {
                            currentCallback.onResult(null, "USB permission denied for device: " + 
                                device.getDeviceName());
                        }
                        try {
                            appContext.unregisterReceiver(this);
                        } catch (IllegalArgumentException e) {
                            // Ignore if already unregistered
                        }
                        usbPermissionReceiver = null;
                    }
                }
            }
        };

        IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
        appContext.registerReceiver(usbPermissionReceiver, filter);

        PendingIntent permissionIntent = PendingIntent.getBroadcast(
            appContext, 
            0, 
            new Intent(ACTION_USB_PERMISSION),
            PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
        );
        usbManager.requestPermission(device, permissionIntent);
    }

    private static void setupAndStartScan() {
        listener = new SerialPortDataListener() {
            @Override
            public void onDataReceived(byte status, String dataMessage) {
                currentCallback.onResult(dataMessage, null);
                SerialPortManager.getInstance().closeSerialPort();
            }

            @Override
            public void onOriginalDataReceived(byte status, byte[] bytes, int length) {
                // Optional raw data handling
            }
        };

        SerialPortManager.getInstance().openSerialPort(appContext, new SerialPortOpenListener() {
            @Override
            public void onConnectStatusChange(int status) {
                switch (status) {
                    case ACTION_USB_PERMISSION_GRANTED:
                        SerialPortManager.getInstance().scanTrigger(actionStatus -> {
                            Log.d(TAG, "Scan trigger status: " + actionStatus);
                        });
                        break;
                    case ACTION_USB_PERMISSION_NOT_GRANTED:
                        currentCallback.onResult(null, "USB permission not granted");
                        break;
                    case ACTION_NO_USB:
                        currentCallback.onResult(null, "No USB device connected");
                        break;
                    case ACTION_USB_DISCONNECTED:
                        currentCallback.onResult(null, "USB device disconnected");
                        break;
                    case ACTION_USB_NOT_SUPPORTED:
                        currentCallback.onResult(null, "USB device not supported");
                        break;
                    default:
                        currentCallback.onResult(null, "Unknown USB status: " + status);
                        break;
                }
            }
        }, listener);
    }

    public interface ResultCallback {
        void onResult(String scanResult, String errorMessage);
    }

    public static void cleanup() {
        if (usbPermissionReceiver != null) {
            try {
                appContext.unregisterReceiver(usbPermissionReceiver);
            } catch (IllegalArgumentException e) {
                // Ignore if already unregistered
            }
            usbPermissionReceiver = null;
        }
    }
}