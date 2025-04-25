package io.flutter.plugins;

import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbManager;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import com.felhr.usbserial.UsbSerialDevice;
import com.felhr.usbserial.UsbSerialInterface;
import com.wsm.comlib.SerialPortLibConfig;
import com.wsm.comlib.util.HexUtil;
import java.util.HashMap;
import java.util.Map;
import android.os.Build;

public class UsbService extends Service {
  public static final String ACTION_USB_READY = "com.felhr.connectivityservices.USB_READY";
  
  public static final String ACTION_USB_ATTACHED = "android.hardware.usb.action.USB_DEVICE_ATTACHED";
  
  public static final String ACTION_USB_DETACHED = "android.hardware.usb.action.USB_DEVICE_DETACHED";
  
  public static final String ACTION_USB_NOT_SUPPORTED = "com.felhr.usbservice.USB_NOT_SUPPORTED";
  
  public static final String ACTION_NO_USB = "com.felhr.usbservice.NO_USB";
  
  public static final String ACTION_USB_PERMISSION_GRANTED = "com.felhr.usbservice.USB_PERMISSION_GRANTED";
  
  public static final String ACTION_USB_PERMISSION_NOT_GRANTED = "com.felhr.usbservice.USB_PERMISSION_NOT_GRANTED";
  
  public static final String ACTION_USB_DISCONNECTED = "com.felhr.usbservice.USB_DISCONNECTED";
  
  public static final String ACTION_CDC_DRIVER_NOT_WORKING = "com.felhr.connectivityservices.ACTION_CDC_DRIVER_NOT_WORKING";
  
  public static final String ACTION_USB_DEVICE_NOT_WORKING = "com.felhr.connectivityservices.ACTION_USB_DEVICE_NOT_WORKING";
  
  public static final int MESSAGE_FROM_SERIAL_PORT = 0;
  
  public static final int CTS_CHANGE = 1;
  
  public static final int DSR_CHANGE = 2;
  
  public static final int CHANGETRIGGER = 1;
  
  public static final int SCANTRIGGER = 2;
  
  public static final byte READ_SUCCESS = 0;
  
  public static final byte READ_FAILD = 1;
  
  private static final String ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION";
  
  private static final int BAUD_RATE = 9600;
  
  public static boolean SERVICE_CONNECTED = false;
  
  public static String TAG = "usbserbice_tag";
  
  private IBinder binder = (IBinder)new UsbBinder();
  
  private Context context;
  
  private Handler mHandler;
  
  private UsbManager usbManager;
  
  private UsbDevice device;
  
  private UsbDeviceConnection connection;
  
  private UsbSerialDevice serialPort;
  
  private boolean serialPortConnected;
  
  private UsbSerialInterface.UsbReadCallback mCallback = new UsbSerialInterface.UsbReadCallback() {
      public void onReceivedData(byte[] arg0) {
        if (arg0 == null || arg0.length < 1) {
          Log.d(UsbService.TAG, "onReceivedData: null");
          return;
        } 
        Log.d(UsbService.TAG, "onReceivedData: " + HexUtil.formatHexString(arg0));
        String data = HexUtil.formatHexString(arg0);
        if (UsbService.this.mHandler != null)
          UsbService.this.mHandler.obtainMessage(0, data).sendToTarget(); 
      }
    };
  
  private UsbSerialInterface.UsbCTSCallback ctsCallback = new UsbSerialInterface.UsbCTSCallback() {
      public void onCTSChanged(boolean state) {
        if (UsbService.this.mHandler != null)
          UsbService.this.mHandler.obtainMessage(1).sendToTarget(); 
      }
    };
  
  private UsbSerialInterface.UsbDSRCallback dsrCallback = new UsbSerialInterface.UsbDSRCallback() {
      public void onDSRChanged(boolean state) {
        if (UsbService.this.mHandler != null)
          UsbService.this.mHandler.obtainMessage(2).sendToTarget(); 
      }
    };
  
  private final BroadcastReceiver usbReceiver = new BroadcastReceiver() {
      public void onReceive(Context arg0, Intent arg1) {
        if (arg1.getAction().equals("com.android.example.USB_PERMISSION")) {
   boolean granted = arg1.getBooleanExtra("permission", false);
          if (granted) {
            Intent intent = new Intent("com.felhr.usbservice.USB_PERMISSION_GRANTED");
            Log.d(UsbService.TAG, "UsbService: ACTION_USB_PERMISSION_GRANTED");
            arg0.sendBroadcast(intent);
            UsbService.this.connection = UsbService.this.usbManager.openDevice(UsbService.this.device);
            (new UsbService.ConnectionThread()).start();
          } else {
            Intent intent = new Intent("com.felhr.usbservice.USB_PERMISSION_NOT_GRANTED");
            Log.d(UsbService.TAG, "UsbService: ACTION_USB_PERMISSION_NOT_GRANTED");
            arg0.sendBroadcast(intent);
          } 
        } else if (arg1.getAction().equals("android.hardware.usb.action.USB_DEVICE_ATTACHED")) {
          if (!UsbService.this.serialPortConnected)
            UsbService.this.findSerialPortDevice(); 
        } else if (arg1.getAction().equals("android.hardware.usb.action.USB_DEVICE_DETACHED")) {
          Intent intent = new Intent("com.felhr.usbservice.USB_DISCONNECTED");
          arg0.sendBroadcast(intent);
          Log.d(UsbService.TAG, "UsbService: ACTION_USB_DISCONNECTED");
          if (UsbService.this.serialPortConnected)
            UsbService.this.serialPort.close(); 
          UsbService.this.serialPortConnected = false;
        } 
      }
    };
  
  public void onCreate() {
    Log.d(TAG, "onCreate: ");
    this.context = (Context)this;
    this.serialPortConnected = false;
    SERVICE_CONNECTED = true;
    setFilter();
    this.usbManager = (UsbManager)getSystemService("usb");
    findSerialPortDevice();
  }
  
  public IBinder onBind(Intent intent) {
    return this.binder;
  }
  
  public int onStartCommand(Intent intent, int flags, int startId) {
    return 2;
  }
  
  public void onDestroy() {
    if (this.serialPortConnected && this.serialPort != null)
      this.serialPort.close(); 
    this.serialPortConnected = false;
    unregisterReceiver(this.usbReceiver);
    SERVICE_CONNECTED = false;
    Log.d(TAG, "onDestroy: ");
    super.onDestroy();
  }
  
  public boolean write(byte[] data) {
    if (this.serialPort != null) {
      this.serialPort.write(data);
      return true;
    } 
    return false;
  }
  
  public void setHandler(Handler mHandler) {
    this.mHandler = mHandler;
  }
  
  private void findSerialPortDevice() {
    HashMap<String, UsbDevice> usbDevices = this.usbManager.getDeviceList();
    if (!usbDevices.isEmpty()) {
      boolean keep = true;
      for (Map.Entry<String, UsbDevice> entry : usbDevices.entrySet()) {
        this.device = entry.getValue();
        int deviceVID = this.device.getVendorId();
        int devicePID = this.device.getProductId();
        Log.w("UsbService_tag", "deviceVID:" + deviceVID + " devicePID:" + devicePID);
        if (deviceVID == SerialPortLibConfig.deviceVID && devicePID == SerialPortLibConfig.devicePID) {
          requestUserPermission();
          Log.d(TAG, "findSerialPortDevice: requestUserPermission");
          keep = false;
        } else {
          this.connection = null;
          this.device = null;
        } 
        if (!keep)
          break; 
      } 
      if (!keep) {
        Intent intent = new Intent("com.felhr.usbservice.NO_USB");
        Log.d(TAG, "findSerialPortDevice: !keep");
      } 
    } else {
      Intent intent = new Intent("com.felhr.usbservice.NO_USB");
      Log.d(TAG, "findSerialPortDevice: else");
      sendBroadcast(intent);
    } 
  }
  
  private void setFilter() {
    IntentFilter filter = new IntentFilter();
    filter.addAction("com.android.example.USB_PERMISSION");
    filter.addAction("android.hardware.usb.action.USB_DEVICE_DETACHED");
    filter.addAction("android.hardware.usb.action.USB_DEVICE_ATTACHED");
    registerReceiver(this.usbReceiver, filter);
  }
  
  private void requestUserPermission() {
    //PendingIntent mPendingIntent = PendingIntent.getBroadcast((Context)this, 0, new Intent("com.android.example.USB_PERMISSION"), 0);
   PendingIntent mPendingIntent;
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    mPendingIntent = PendingIntent.getBroadcast((Context)this, 0, new Intent("com.android.example.USB_PERMISSION"), PendingIntent.FLAG_IMMUTABLE);
} else {
    mPendingIntent = PendingIntent.getBroadcast((Context)this, 0, new Intent("com.android.example.USB_PERMISSION"), 0);
}
   
    this.usbManager.requestPermission(this.device, mPendingIntent);
  }
  
  public class UsbBinder extends Binder {
    public UsbService getService() {
      return UsbService.this;
    }
  }
  
  private class ConnectionThread extends Thread {
    private ConnectionThread() {}
    
    public void run() {
      UsbService.this.serialPort = UsbSerialDevice.createUsbSerialDevice(UsbService.this.device, UsbService.this.connection);
      if (UsbService.this.serialPort != null) {
        if (UsbService.this.serialPort.open()) {
          UsbService.this.serialPortConnected = true;
          UsbService.this.serialPort.setBaudRate(9600);
          UsbService.this.serialPort.setDataBits(8);
          UsbService.this.serialPort.setStopBits(1);
          UsbService.this.serialPort.setParity(0);
          UsbService.this.serialPort.setFlowControl(0);
          UsbService.this.serialPort.read(UsbService.this.mCallback);
          UsbService.this.serialPort.getCTS(UsbService.this.ctsCallback);
          UsbService.this.serialPort.getDSR(UsbService.this.dsrCallback);
          Intent intent = new Intent("com.felhr.connectivityservices.USB_READY");
          UsbService.this.context.sendBroadcast(intent);
          Log.d(UsbService.TAG, "UsbService: ACTION_USB_READY");
        } else if (UsbService.this.serialPort instanceof com.felhr.usbserial.CDCSerialDevice) {
          Intent intent = new Intent("com.felhr.connectivityservices.ACTION_CDC_DRIVER_NOT_WORKING");
          UsbService.this.context.sendBroadcast(intent);
        } else {
          Intent intent = new Intent("com.felhr.connectivityservices.ACTION_USB_DEVICE_NOT_WORKING");
          UsbService.this.context.sendBroadcast(intent);
        } 
      } else {
        Intent intent = new Intent("com.felhr.usbservice.USB_NOT_SUPPORTED");
        UsbService.this.context.sendBroadcast(intent);
      } 
    }
  }
}