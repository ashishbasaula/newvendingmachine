package com.wsm.comlib;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.wsm.comlib.callback.SerialPortChangeTriggerListener;
import com.wsm.comlib.callback.SerialPortDataListener;
import com.wsm.comlib.callback.SerialPortOpenListener;
import com.wsm.comlib.callback.SerialPortServiceConnectionListener;
import com.wsm.comlib.callback.SerialPortDeviceInfoListener;
import com.wsm.comlib.callback.SerialPortScanTriggerListener;
import com.wsm.comlib.constant.FormatConstant;
import com.wsm.comlib.service.UsbService;
import com.wsm.comlib.util.BleLog;
import com.wsm.comlib.util.HexUtil;
import com.wsm.comlib.util.StringFormat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.Locale;
import java.util.Set;

import static android.content.Context.BIND_AUTO_CREATE;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_NO_USB;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_DISCONNECTED;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_NOT_SUPPORTED;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_PERMISSION_GRANTED;
import static com.wsm.comlib.constant.ConnectCostant.ACTION_USB_PERMISSION_NOT_GRANTED;
import static com.wsm.comlib.service.UsbService.ACTION_USB_DEVICE_NOT_WORKING;
import static com.wsm.comlib.service.UsbService.CHANGETRIGGER;
import static com.wsm.comlib.service.UsbService.READ_SUCCESS;
import static com.wsm.comlib.service.UsbService.SCANTRIGGER;

public class SerialPortManager {
    private static Context mContext;
    MyHandler mHandler;
    private static SerialPortManager instance;
    private SerialPortOpenListener mSerialPortOpenListener;
    private SerialPortDataListener mSerialPortDataListener;
    private UsbService usbService;
    public static String TAG = "SerialPortManager";
    public static final int MSG_CHANGE_TRIGGER = 101;
    public static final int MSG_SCAN_TRIGGER = 102;
    public static int CMDMODE = 0;
    private SerialPortChangeTriggerListener mSerialPortChangeTriggerListener;
    private SerialPortScanTriggerListener mSerialPortScanTriggerListener;
    private String mDeviceInfoType = null;
    private SerialPortDeviceInfoListener mSerialPortDeviceInfoListener;
    private SerialPortServiceConnectionListener mSerialPortServiceConnectionListener;
    private boolean awaitingScan = false;
    private SerialPortScanTriggerListener tempScanTriggerListener = null;

    public static SerialPortManager getInstance() {
        synchronized (SerialPortManager.class) {
            if (instance == null) {
                instance = new SerialPortManager();
            }
        }
        return instance;
    }

    private SerialPortManager() {
        mHandler = new MyHandler(mContext);
    }

    /**
     * 打开USB通讯
     *
     * @param context
     * @param serialPortOpenListener
     * @param serialPortDataListener
     */
    public void openSerialPort(Context context, SerialPortOpenListener serialPortOpenListener, SerialPortDataListener serialPortDataListener, SerialPortServiceConnectionListener serialPortServiceConnectionListener) {
        if (context == null) {
            throw new IllegalArgumentException("context can not be Null!");
        }
        if (serialPortOpenListener == null) {
            throw new IllegalArgumentException("serialPortOpenListener can not be Null!");
        }
        if (serialPortDataListener == null) {
            throw new IllegalArgumentException("serialPortDataListener can not be Null!");
        }
        mContext = context.getApplicationContext();
        mSerialPortOpenListener = serialPortOpenListener;
        mSerialPortDataListener = serialPortDataListener;
        mSerialPortServiceConnectionListener = serialPortServiceConnectionListener;

        startService(UsbService.class,usbConnection,null);
        //动态注册广播接收器

        setFilters();

        BleLog.d("注册广播1");
    }

    /**
     * 关闭USB通讯
     */
    public void closeSerialPort() {
        if (mContext == null) {
            BleLog.d("服务销毁 mContext null");
            return;
        }
        try {
            mContext.unregisterReceiver(mUsbReceiver);
            Intent endService = new Intent(mContext, UsbService.class);

            mContext.unbindService(usbConnection);
            mContext.stopService(endService);
            usbService = null;

            BleLog.d("服务销毁");
        } catch (Exception e) {
            BleLog.e("Service not registered");
        }
        if (mSerialPortOpenListener != null) {
            mSerialPortOpenListener.onConnectStatusChange(ACTION_USB_DISCONNECTED);
        }

    }

    /**
     * @return 返回USB连接状态
     */
    public int getSerialPortStatus() {
        return SerialPortLibConfig.hidStatus;
    }

    /**
     * 设置输出字符串编码格式
     *
     * @param format 字符串编码格式
     * @return
     */
    public boolean setFormat(String format) {
        if (TextUtils.isEmpty(format)) {
            throw new IllegalArgumentException("format can not be Null!");
        }
        if (format.equalsIgnoreCase(FormatConstant.FORMAT_GBK)) {
            SerialPortLibConfig.format = format;
            return true;
        }
        if (format.equalsIgnoreCase(FormatConstant.FORMAT_UTF8)) {
            SerialPortLibConfig.format = format;
            return true;
        }
        if (format.equalsIgnoreCase(FormatConstant.FORMAT_HEX)) {
            SerialPortLibConfig.format = format;
            return true;
        }
        return false;
    }

    /***
     * @param timelone 传入的设置超时时间，取值范围50L-5000L,默认500L
     * @return 设置是否成功
     */
    public boolean setPackageTimeOut(long timelone) {
        if (timelone >= 50L && timelone <= 5000L) {
            SerialPortLibConfig.timelone = timelone;
            return true;
        } else {
            return false;
        }
    }

    /***
     * @param vid ,pid
     * @return 设置是否成功
     */
    public boolean setDeviceID(int vid, int pid) {
        if (vid >= 0 && pid >= 0) {
            SerialPortLibConfig.deviceVID = vid;
            SerialPortLibConfig.devicePID = pid;
            Log.d(TAG, "setDeviceID1: " +
                    SerialPortLibConfig.deviceVID);
            Log.d(TAG, "setDeviceID2: " +
                    SerialPortLibConfig.devicePID);


            return true;
        } else {
            return false;
        }
    }

    /**
     * 向扫码设备发送数据
     *
     * @param sendMessage 16进制的字符串
     */

    public boolean sendData(String sendMessage) {
        if (sendMessage == null) {
            throw new IllegalArgumentException("sendMessage can not be Null!");
        }
        Log.d(TAG, "sendData: " + sendMessage);
        if (usbService != null) {
            return usbService.write(HexUtil.hexStringToBytes(sendMessage));
        }
        return false;
    }


    public void enableLog(boolean enable) {
        BleLog.isPrint = enable;
    }

    private final ServiceConnection usbConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName arg0, IBinder arg1) {
            Log.d(TAG, "USB service connected");
            usbService = ((UsbService.UsbBinder) arg1).getService();
            usbService.setHandler(mHandler);

            if (awaitingScan && tempScanTriggerListener != null) {
                scanTrigger(tempScanTriggerListener);
                awaitingScan = false;
                tempScanTriggerListener = null;
            }

            if (mSerialPortServiceConnectionListener != null) {
                mSerialPortServiceConnectionListener.onServiceConnected(arg0, arg1);
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
            usbService = null;
            if (mSerialPortServiceConnectionListener != null) {
                mSerialPortServiceConnectionListener.onServiceDisconnected(arg0);
            }
        }
    };

    private void startService(Class<?> service, ServiceConnection serviceConnection, Bundle extras) {
        if (!UsbService.SERVICE_CONNECTED) {
            Intent startService = new Intent(mContext, service);
            if (extras != null && !extras.isEmpty()) {
                Set<String> keys = extras.keySet();
                for (String key : keys) {
                    String extra = extras.getString(key);
                    startService.putExtra(key, extra);
                }
            }
            mContext.startService(startService);
        }
        Intent bindingIntent = new Intent(mContext, service);
        mContext.bindService(bindingIntent, serviceConnection, Context.BIND_AUTO_CREATE);
    }

    private void setFilters() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(UsbService.ACTION_USB_PERMISSION_GRANTED);
        filter.addAction(UsbService.ACTION_USB_PERMISSION_NOT_GRANTED);
        filter.addAction(UsbService.ACTION_USB_DISCONNECTED);
        filter.addAction(UsbService.ACTION_USB_NOT_SUPPORTED);
        filter.addAction(UsbService.ACTION_NO_USB);
        mContext.registerReceiver(mUsbReceiver, filter);
    }


    private BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent == null || intent.getAction() == null) {
                return;
            }
            Log.d(TAG, "mUsbReceiver onReceive: " + intent.getAction());
            switch (intent.getAction()) {
                case UsbService.ACTION_USB_PERMISSION_GRANTED:
                case UsbService.ACTION_USB_READY:
                    mSerialPortOpenListener.onConnectStatusChange(ACTION_USB_PERMISSION_GRANTED);
                    break;

                case UsbService.ACTION_NO_USB:
                    mSerialPortOpenListener.onConnectStatusChange(ACTION_NO_USB);
                    break;

                case UsbService.ACTION_USB_DEVICE_NOT_WORKING:
                case UsbService.ACTION_USB_DISCONNECTED:
                    mSerialPortOpenListener.onConnectStatusChange(ACTION_USB_DISCONNECTED);
                    break;

                case UsbService.ACTION_USB_NOT_SUPPORTED:
                    mSerialPortOpenListener.onConnectStatusChange(ACTION_USB_NOT_SUPPORTED);
                    break;

                case UsbService.ACTION_USB_PERMISSION_NOT_GRANTED:
                    mSerialPortOpenListener.onConnectStatusChange(ACTION_USB_PERMISSION_NOT_GRANTED);
                    break;
            }
        }
    };

    public boolean getDeviceInfo(String type, SerialPortDeviceInfoListener serialPortDeviceInfoListener) {
        if (serialPortDeviceInfoListener == null) {
            throw new IllegalArgumentException("serialPortDeviceInfoListener can not be Null!");
        }
        String getSN = "ReadDeviceInfo.";

        Log.d(TAG, "getSequenceNumber: " + getSN);
        Log.d(TAG, "getSequenceNumber2: " + HexUtil.formatHexString(getSN.getBytes()));
        char[] chars = getSN.toCharArray();
        mDeviceInfoType = type;
        mSerialPortDeviceInfoListener = serialPortDeviceInfoListener;
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 0; i < chars.length; i++) {
            String hexString = Integer.toHexString(chars[i]);
            stringBuilder.append(hexString);
        }
        Log.d(TAG, "getSequenceNumber1: " + stringBuilder.toString());
        if (usbService != null) {
            return usbService.write(HexUtil.hexStringToBytes(stringBuilder.toString()));
        }
        return false;
    }


    public void changeTriggerMode(SerialPortChangeTriggerListener serialPortChangeTriggerListener) {
        //todo
        if (serialPortChangeTriggerListener == null) {
            throw new IllegalArgumentException("serialPortChangeTriggerListener can not be Null!");
        }
        mSerialPortChangeTriggerListener = serialPortChangeTriggerListener;
        String getSN = "7E000701000001ABCD";
        CMDMODE = CHANGETRIGGER;
        Log.d(TAG, "changeTriggerMode: " + getSN);
        if (usbService != null) {
            usbService.write(HexUtil.hexStringToBytes(getSN));
        }
        if (mHandler != null) {
            mHandler.sendEmptyMessageDelayed(MSG_CHANGE_TRIGGER, SerialPortLibConfig.timelone);
        }
    }

    public void scanTrigger(SerialPortScanTriggerListener serialPortScanTriggerListener) {
        if (serialPortScanTriggerListener == null) {
            throw new IllegalArgumentException("serialPortScanTriggerListener can not be Null!");
        }
        mSerialPortScanTriggerListener = serialPortScanTriggerListener;
        String getSN = "7E00080100020102DA";
        CMDMODE = SCANTRIGGER;

        if (usbService != null) {
            Log.d(TAG, "scanTrigger: " + getSN);
            usbService.write(HexUtil.hexStringToBytes(getSN));

            if (mHandler != null) {
                mHandler.sendEmptyMessageDelayed(MSG_SCAN_TRIGGER, SerialPortLibConfig.timelone);
            }
        } else {
            awaitingScan = true;
            tempScanTriggerListener = serialPortScanTriggerListener;
            Log.d(TAG, "scanTrigger failed: waiting for usbService");
        }
    }

    private class MyHandler extends Handler {
        private final WeakReference<Context> mActivity;

        public MyHandler(Context activity) {
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            Log.d(TAG, "handleMessage: " + msg.what);
            switch (msg.what) {
                case MSG_CHANGE_TRIGGER:
                    if (mSerialPortChangeTriggerListener != null) {
                        mSerialPortChangeTriggerListener.onStatusChange(false);
                    }
                    String data2 = (String) msg.obj;
                    if (data2 != null) {
                        Log.d(TAG, "handleMessage MSG_CHANGE_TRIGGER: " + data2);
                    }

                    break;
                case MSG_SCAN_TRIGGER:
                    if (mSerialPortScanTriggerListener != null) {
                        mSerialPortScanTriggerListener.onStatusChange(false);
                    }
                    String data1 = (String) msg.obj;
                    if (data1 != null) {
                        Log.d(TAG, "handleMessage MSG_SCAN_TRIGGER: " + data1);
                    }

                    break;


                case UsbService.MESSAGE_FROM_SERIAL_PORT:
                    String data = (String) msg.obj;
                    Log.d(TAG, "MESSAGE_FROM_SERIAL_PORT handleMessage: " + data);
                    if (CMDMODE == CHANGETRIGGER && data.toUpperCase().startsWith("02000001D")) {
                        String SN2 = "7E0008010000";
                        byte[] bytes = HexUtil.hexStringToBytes(data);
                        byte[] byte4 = new byte[1];
                        int a = bytes[4] & 0xFF;
                        int b = a >> 2;
                        int c = b << 2;
                        int d = c + 1;
                        byte4[0] = (byte) (d);
                        SN2 = SN2 + HexUtil.formatHexString(byte4) + "ABCD";
                        sendData(SN2);
                    }
                    if (data.startsWith("0200000100")) {
                        if (CMDMODE == CHANGETRIGGER && mSerialPortChangeTriggerListener != null) {
                            mSerialPortChangeTriggerListener.onStatusChange(true);
                        }
                        if (CMDMODE == SCANTRIGGER && mSerialPortScanTriggerListener != null) {
                            mSerialPortScanTriggerListener.onStatusChange(true);
                        }
                        CMDMODE = 0;
                        mHandler.removeMessages(MSG_CHANGE_TRIGGER);
                    }
                    if (data.toLowerCase().startsWith("70726f7669646572436f64653a4d45")) {
                        byte[] bytes = HexUtil.hexStringToBytes(data);

                        if (mDeviceInfoType == null) {
                            byte[] deviceInfoBytes = HexUtil.hexStringToBytes(data);
                            String bytes2String = StringFormat.bytes2String(deviceInfoBytes, SerialPortLibConfig.format);

                            Log.d(TAG, "handleMessage: " + bytes2String);

                            mSerialPortDataListener.onDataReceived(READ_SUCCESS, bytes2String);
                            mSerialPortDataListener.onOriginalDataReceived(READ_SUCCESS,deviceInfoBytes,bytes.length);
                        }

                        StringBuilder stringBuilder = new StringBuilder();
                        for (int i = 0; i < bytes.length; i++) {
                            stringBuilder.append((char) bytes[i]);
                        }
                        System.out.println(stringBuilder.toString());
                        String[] strings = stringBuilder.toString().split("\n");
                        JSONArray jsonArray = new JSONArray();
                        for (int i = 0; i < strings.length; i++) {
                            String string = strings[i];
                            System.out.println(string);

                            String[] split = string.split(":");
                            String key = "key";
                            String vaule = "value";
                            for (int i1 = 0; i1 < split.length; i1++) {
                                if (i1 == 0) {
                                    key = split[i1].trim();
                                }
                                if (i1 == 1) {
                                    vaule = split[i1].trim();

                                }
                            }
                            JSONObject jsonObject = new JSONObject();

                            try {
                                jsonObject.put(key, vaule);
                                jsonArray.put(jsonObject);
                                Log.d(TAG, "handleMessage key: "+key);
                                Log.d(TAG, "handleMessage mDeviceInfoType: "+mDeviceInfoType);

                                if (mSerialPortDeviceInfoListener != null && key.equals(mDeviceInfoType)) {
                                    mSerialPortDeviceInfoListener.onDeviceInfoReceived(vaule, vaule.length());
                                    mDeviceInfoType = null;
                                    return;
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        Log.d(TAG, "handleMessage jsonArray: " + jsonArray.toString());


                    }else {
                        byte[] bytes = HexUtil.hexStringToBytes(data);
                        String bytes2String = StringFormat.bytes2String(bytes, SerialPortLibConfig.format);

                        Log.d(TAG, "handleMessage: " + bytes2String);

                        mSerialPortDataListener.onDataReceived(READ_SUCCESS, bytes2String);
                        mSerialPortDataListener.onOriginalDataReceived(READ_SUCCESS,bytes,bytes.length);
                    }
                    break;

                case UsbService.CTS_CHANGE:
                    Toast.makeText(mActivity.get(), "CTS_CHANGE", Toast.LENGTH_LONG).show();
                    break;
                case UsbService.DSR_CHANGE:
                    Toast.makeText(mActivity.get(), "DSR_CHANGE", Toast.LENGTH_LONG).show();
                    break;
            }
        }
    }
}
