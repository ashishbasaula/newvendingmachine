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

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;

import com.wsm.comlib.SerialPortLibConfig;
import com.wsm.comlib.SerialPortManager;
import com.wsm.comlib.callback.SerialPortChangeTriggerListener;
import com.wsm.comlib.callback.SerialPortDataListener;
import com.wsm.comlib.callback.SerialPortOpenListener;
import com.wsm.comlib.callback.SerialPortDeviceInfoListener;
import com.wsm.comlib.callback.SerialPortScanTriggerListener;
import com.wsm.comlib.constant.FormatConstant;
import com.wsm.comlib.util.HexUtil;

import static com.wsm.comlib.constant.ConnectCostant.ACTION_NO_USB;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_DISCONNECTED;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_NOT_SUPPORTED;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_PERMISSION_GRANTED;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_PERMISSION_NOT_GRANTED;

public class ScannerHelper {
    private static final String TAG = "ScannerHelper";
    private static UsbService usbService;
    private static boolean isServiceBound = false;

    public interface ResultCallback {
        void onResult(String scanResult, String errorMessage);
    }

    public static void startScan(Context context, ResultCallback callback) {
        Log.d(TAG, "startScan called, isServiceBound: " + isServiceBound);
        if (!isServiceBound) {
            Log.d(TAG, "Attempting to bind USB service");
            try {
                Intent intent = new Intent(context.getApplicationContext(), UsbService.class);
                boolean bindingResult = context.getApplicationContext().bindService(intent, serviceConnection(context, callback), Context.BIND_AUTO_CREATE);
                Log.d(TAG, "Service binding result: " + bindingResult);

                if (bindingResult) {
                    //     public static void startScan(Context context, final ResultCallback callback) {
                    SerialPortDataListener mSerialPortDataListener = new SerialPortDataListener() {
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

                    SerialPortOpenListener mSerialPortOpenListener = new SerialPortOpenListener() {
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
                    };

                    Log.d(TAG, "Opening serial port...");
                    SerialPortManager.getInstance().openSerialPort(context, mSerialPortOpenListener, mSerialPortDataListener);
                }
            } catch (Exception e) {
                Log.e(TAG, "Error binding service: " + e.getMessage(), e);
                callback.onResult(null, "Error binding service: " + e.getMessage());
            }
        } else {
            Log.d(TAG, "Service already bound, setting up handler");
            setupHandler(callback);
        }
    }

    private static ServiceConnection serviceConnection(Context context, ResultCallback callback) {
        Log.d(TAG, "Creating new ServiceConnection");
        return new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName name, IBinder service) {
                Log.d(TAG, "onServiceConnected called with component: " + name);
                try {
                    usbService = ((UsbService.UsbBinder) service).getService();
                    isServiceBound = true;
                    Log.d(TAG, "USB Service successfully connected");
                    setupHandler(callback);
                } catch (Exception e) {
                    Log.e(TAG, "Error in onServiceConnected: " + e.getMessage(), e);
                    callback.onResult(null, "Service connection error: " + e.getMessage());
                }
            }

            @Override
            public void onServiceDisconnected(ComponentName name) {
                Log.d(TAG, "onServiceDisconnected called with component: " + name);
                usbService = null;
                isServiceBound = false;
                callback.onResult(null, "USB Service disconnected unexpectedly");
            }
        };
    }

    private static void setupHandler(ResultCallback callback) {
        Log.d(TAG, "setupHandler called, usbService is " + (usbService != null ? "not null" : "null"));
        if (usbService != null) {
            try {
                Handler handler = new Handler(Looper.getMainLooper()) {
                    @Override
                    public void handleMessage(android.os.Message msg) {
                        Log.d(TAG, "Handler received message: " + (msg != null ? msg.toString() : "null"));
                        if (msg != null && msg.obj != null) {
                            String data = msg.obj.toString();
                            Log.d(TAG, "Received scan data: " + data);
                            callback.onResult(data, null);
                        } else {
                            Log.w(TAG, "Received empty or null message");
                            callback.onResult(null, "Received empty data");
                        }
                    }
                };
                usbService.setHandler(handler);
                Log.d(TAG, "Handler successfully set up");
            } catch (Exception e) {
                Log.e(TAG, "Error setting up handler: " + e.getMessage(), e);
                callback.onResult(null, "Handler setup error: " + e.getMessage());
            }
        } else {
            Log.e(TAG, "USB Service not available when setting up handler");
            callback.onResult(null, "USB Service not available");
        }
    }

    public static void stopScan(Context context) {
        Log.d(TAG, "stopScan called, isServiceBound: " + isServiceBound);
        if (isServiceBound) {
            try {
                context.unbindService(serviceConnection(context, null));
                isServiceBound = false;
                usbService = null;
                Log.d(TAG, "Service successfully unbound");
            } catch (Exception e) {
                Log.e(TAG, "Error unbinding service: " + e.getMessage(), e);
            }
        } else {
            Log.d(TAG, "Service not bound, nothing to unbind");
        }
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
// import android.util.Log;

// import com.wsm.comlib.SerialPortManager;
// import com.wsm.comlib.callback.SerialPortOpenListener;
// import com.wsm.comlib.callback.SerialPortDataListener;

// import static com.wsm.comlib.constant.ConnectCostant.*;

// public class ScannerHelper {

//     private static final String ACTION_USB_PERMISSION = "io.flutter.plugins.USB_PERMISSION";
//     private static final String TAG = "ScannerHelper";
    
//     // Supported devices
//     private static final int[][] SUPPORTED_DEVICES = {
//         {11491, 38247},  // First device
//         {5418, 34831}    // Second device
//     };

//     private static SerialPortDataListener listener;
//     private static ResultCallback currentCallback;
//     private static Context appContext;
//     private static BroadcastReceiver usbPermissionReceiver;

//     public static void startScan(Context context, final ResultCallback callback) {
//         appContext = context.getApplicationContext();
//         currentCallback = callback;

//         UsbManager usbManager = (UsbManager) appContext.getSystemService(Context.USB_SERVICE);
//         UsbDevice device = findSupportedDevice(usbManager);

//         if (device == null) {
//             Log.e(TAG, "No supported USB device found");
//             callback.onResult(null, "Scanner not connected");
//             return;
//         }

//         // if (usbManager.hasPermission(device)) {
//         //     Log.d(TAG, "Permission already granted, starting scan");
//         //     setupAndStartScan();
//         // } else {
//         //     Log.d(TAG, "Requesting USB permission");
           
//         // }
//          requestUsbPermission(usbManager, device);
//     }

//     private static UsbDevice findSupportedDevice(UsbManager usbManager) {
//         for (UsbDevice device : usbManager.getDeviceList().values()) {
//             for (int[] supportedDevice : SUPPORTED_DEVICES) {
//                 if (device.getVendorId() == supportedDevice[0] && 
//                     device.getProductId() == supportedDevice[1]) {
//                     Log.d(TAG, "Found supported device: " + device.getDeviceName() + 
//                           " VID=" + supportedDevice[0] + " PID=" + supportedDevice[1]);
//                     return device;
//                 }
//             }
//         }
//         return null;
//     }

//     private static void requestUsbPermission(UsbManager usbManager, UsbDevice device) {
//         // Clean up any existing receiver
//         if (usbPermissionReceiver != null) {
//             try {
//                 appContext.unregisterReceiver(usbPermissionReceiver);
//             } catch (IllegalArgumentException e) {
//                 Log.w(TAG, "Receiver already unregistered");
//             }
//         }

//         usbPermissionReceiver = new BroadcastReceiver() {
//             public void onReceive(Context context, Intent intent) {
//                 String action = intent.getAction();
//                 if (ACTION_USB_PERMISSION.equals(action)) {
//                     synchronized (this) {
//                         UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
//                         if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
//                             if (device != null) {
//                                 Log.d(TAG, "USB permission granted for: " + device.getDeviceName());
//                                 setupAndStartScan();
//                             }
//                         } else {
//                             String error = "USB permission denied for: " + 
//                                         (device != null ? device.getDeviceName() : "null device");
//                             Log.e(TAG, error);
//                             currentCallback.onResult(null, error);
//                         }
//                         cleanup();
//                     }
//                 }
//             }
//         };

//         try {
//             IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
//             appContext.registerReceiver(usbPermissionReceiver, filter);

//             PendingIntent permissionIntent = PendingIntent.getBroadcast(
//                 appContext, 
//                 0, 
//                 new Intent(ACTION_USB_PERMISSION),
//                 PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
//             );
//             usbManager.requestPermission(device, permissionIntent);
//             Log.d(TAG, "USB permission request sent");
//         } catch (Exception e) {
//             Log.e(TAG, "Error requesting USB permission", e);
//             currentCallback.onResult(null, "Failed to request USB permission");
//             cleanup();
//         }
//     }

//     private static void setupAndStartScan() {
//         Log.d(TAG, "Setting up serial port and starting scan");
        
//         listener = new SerialPortDataListener() {
//             @Override
//             public void onDataReceived(byte status, String dataMessage) {
//                 Log.d(TAG, "Scan result received: " + dataMessage);
//                 currentCallback.onResult(dataMessage, null);
//                 SerialPortManager.getInstance().closeSerialPort();
//                 cleanup();
//             }

//             @Override
//             public void onOriginalDataReceived(byte status, byte[] bytes, int length) {
//                 Log.d(TAG, "Raw data received, length: " + length);
//             }
//         };

//         try {
//             SerialPortManager.getInstance().openSerialPort(appContext, new SerialPortOpenListener() {
//                 @Override
//                 public void onConnectStatusChange(int status) {
//                     switch (status) {
//                         case ACTION_USB_PERMISSION_GRANTED:
//                             Log.d(TAG, "Serial port opened, triggering scan");
//                             SerialPortManager.getInstance().scanTrigger(actionStatus -> {
//                                 Log.d(TAG, "Scan trigger result: " + actionStatus);
//                                 if (!actionStatus) {
//                                     currentCallback.onResult(null, "Scan trigger failed with status: " + actionStatus);
//                                     cleanup();
//                                 }
//                             });
//                             break;
//                         case ACTION_USB_PERMISSION_NOT_GRANTED:
//                             currentCallback.onResult(null, "USB permission not granted");
//                             break;
//                         case ACTION_NO_USB:
//                             currentCallback.onResult(null, "No USB device connected");
//                             break;
//                         case ACTION_USB_DISCONNECTED:
//                             currentCallback.onResult(null, "USB device disconnected");
//                             break;
//                         case ACTION_USB_NOT_SUPPORTED:
//                             currentCallback.onResult(null, "USB device not supported");
//                             break;
//                         default:
//                             currentCallback.onResult(null, "Unknown USB status: " + status);
//                             break;
//                     }
//                     cleanup();
//                 }
//             }, listener);
//         } catch (Exception e) {
//             Log.e(TAG, "Error opening serial port", e);
//             currentCallback.onResult(null, "Failed to open serial port");
//             cleanup();
//         }
//     }

//     public interface ResultCallback {
//         void onResult(String scanResult, String errorMessage);
//     }

//     public static void cleanup() {
//         Log.d(TAG, "Cleaning up resources");
//         if (usbPermissionReceiver != null) {
//             try {
//                 appContext.unregisterReceiver(usbPermissionReceiver);
//             } catch (IllegalArgumentException e) {
//                 Log.w(TAG, "Receiver already unregistered");
//             }
//             usbPermissionReceiver = null;
//         }
//     }
// }



// package io.flutter.plugins;

// import android.content.Context;
// import android.hardware.usb.UsbDevice;
// import android.hardware.usb.UsbManager;
// import android.content.Intent;
// import android.app.PendingIntent;
// import android.content.BroadcastReceiver;
// import android.content.IntentFilter;
// import android.util.Log;

// import com.wsm.comlib.SerialPortManager;
// import com.wsm.comlib.callback.SerialPortOpenListener;
// import com.wsm.comlib.callback.SerialPortDataListener;

// import static com.wsm.comlib.constant.ConnectCostant.*;

// public class ScannerHelper {

//     private static final String ACTION_USB_PERMISSION = "io.flutter.plugins.USB_PERMISSION";
//     private static final String TAG = "ScannerHelper";
    
//     private static final int[][] SUPPORTED_DEVICES = {
//         {11491, 38247},  // First device
//         {5418, 34831}    // Second device
//     };
 
//     private static SerialPortDataListener listener;
//     private static ResultCallback currentCallback;
//     private static Context appContext;
//     private static BroadcastReceiver usbPermissionReceiver;
//     private static UsbDevice currentDevice;

//     public static void startScan(Context context, final ResultCallback callback) {
//         appContext = context.getApplicationContext();
//         currentCallback = callback;

//         UsbManager usbManager = (UsbManager) appContext.getSystemService(Context.USB_SERVICE);
//         currentDevice = findSupportedDevice(usbManager);

//         if (currentDevice == null) {
//             Log.e(TAG, "No supported USB device found");
//             callback.onResult(null, "Scanner not connected");
//             return;
//         }

//         if (usbManager.hasPermission(currentDevice)) {
//             Log.d(TAG, "Permission already granted, starting scan");
//             setupAndStartScan();
//         } else {
//             Log.d(TAG, "Requesting USB permission for: " + currentDevice.getDeviceName());
//             requestUsbPermission(usbManager, currentDevice);
//         }
//     }

//     private static UsbDevice findSupportedDevice(UsbManager usbManager) {
//         for (UsbDevice device : usbManager.getDeviceList().values()) {
//             for (int[] supportedDevice : SUPPORTED_DEVICES) {
//                 if (device.getVendorId() == supportedDevice[0] && 
//                     device.getProductId() == supportedDevice[1]) {
//                     Log.d(TAG, "Found supported device: " + device.getDeviceName() + 
//                           " VID=" + supportedDevice[0] + " PID=" + supportedDevice[1]);
//                     return device;
//                 }
//             }
//         }
//         return null;
//     }

//     private static void requestUsbPermission(UsbManager usbManager, UsbDevice device) {
//         cleanup(); // Clean up any existing receiver

//         usbPermissionReceiver = new BroadcastReceiver() {
//             public void onReceive(Context context, Intent intent) {
//                 String action = intent.getAction();
//                 if (ACTION_USB_PERMISSION.equals(action)) {
//                     synchronized (this) {
//                         UsbDevice device = currentDevice; // Use our stored device reference
//                         boolean granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false);
                        
//                         if (granted && device != null) {
//                             Log.d(TAG, "USB permission granted for: " + device.getDeviceName());
//                             setupAndStartScan();
//                         } else {
//                             String error = "USB permission denied for: " + 
//                                         (device != null ? device.getDeviceName() : "unknown device");
//                             Log.e(TAG, error);
//                             currentCallback.onResult(null, error);
//                         }
//                         cleanup();
//                     }
//                 }
//             }
//         };

//         try {
//             IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
//             appContext.registerReceiver(usbPermissionReceiver, filter);

//             // Include the device in the permission intent
//             Intent permissionIntent = new Intent(ACTION_USB_PERMISSION);
//             permissionIntent.putExtra(UsbManager.EXTRA_DEVICE, device);

//             PendingIntent pendingIntent = PendingIntent.getBroadcast(
//                 appContext, 
//                 0, 
//                 permissionIntent,
//                 PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
//             );
            
//             usbManager.requestPermission(device, pendingIntent);
//             Log.d(TAG, "USB permission request sent for: " + device.getDeviceName());
//         } catch (Exception e) {
//             Log.e(TAG, "Error requesting USB permission", e);
//             currentCallback.onResult(null, "Failed to request USB permission");
//             cleanup();
//         }
//     }

//     private static void setupAndStartScan() {
//         Log.d(TAG, "Setting up serial port and starting scan");
        
//         listener = new SerialPortDataListener() {
//             @Override
//             public void onDataReceived(byte status, String dataMessage) {
//                 Log.d(TAG, "Scan result received: " + dataMessage);
//                 currentCallback.onResult(dataMessage, null);
//                 SerialPortManager.getInstance().closeSerialPort();
//                 cleanup();
//             }

//             @Override
//             public void onOriginalDataReceived(byte status, byte[] bytes, int length) {
//                 Log.d(TAG, "Raw data received, length: " + length);
//             }
//         };

//         try {
//             SerialPortManager.getInstance().openSerialPort(appContext, new SerialPortOpenListener() {
//                 @Override
//                 public void onConnectStatusChange(int status) {
//                     switch (status) {
//                         case ACTION_USB_PERMISSION_GRANTED:
//                             Log.d(TAG, "Serial port opened, triggering scan");
//                             SerialPortManager.getInstance().scanTrigger(success -> {
//                                 if (!success) {
//                                     Log.e(TAG, "Scan trigger failed");
//                                     currentCallback.onResult(null, "Failed to trigger scan");
//                                 }
//                                 cleanup();
//                             });
//                             break;
//                         case ACTION_USB_PERMISSION_NOT_GRANTED:
//                             currentCallback.onResult(null, "USB permission not granted");
//                             break;
//                         case ACTION_NO_USB:
//                             currentCallback.onResult(null, "No USB device connected");
//                             break;
//                         case ACTION_USB_DISCONNECTED:
//                             currentCallback.onResult(null, "USB device disconnected");
//                             break;
//                         case ACTION_USB_NOT_SUPPORTED:
//                             currentCallback.onResult(null, "USB device not supported");
//                             break;
//                         default:
//                             currentCallback.onResult(null, "Unknown USB status: " + status);
//                             break;
//                     }
//                     cleanup();
//                 }
//             }, listener);
//         } catch (Exception e) {
//             Log.e(TAG, "Error opening serial port", e);
//             currentCallback.onResult(null, "Failed to open serial port");
//             cleanup();
//         }
//     }

//     public interface ResultCallback {
//         void onResult(String scanResult, String errorMessage);
//     }

//     public static void cleanup() {
//         Log.d(TAG, "Cleaning up resources");
//         if (usbPermissionReceiver != null) {
//             try {
//                 appContext.unregisterReceiver(usbPermissionReceiver);
//             } catch (IllegalArgumentException e) {
//                 Log.w(TAG, "Receiver already unregistered");
//             }
//             usbPermissionReceiver = null;
//         }
//     }
// }