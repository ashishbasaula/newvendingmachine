package com.appAra.newVending;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;

import com.tool.Scan;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class MainActivityHelper {
    private static final String TAG = "SCANDEMO";
    private final Context context;
    private final MethodChannel channel;

    private Scan tsexample;
    private List<ScanDevice> devicesList;
    private boolean busyFlag = false;
    private static int uiDecodeCnt = 0;
    private static int s_uiLanguage = 1; // 0 中文，1 English

    public MainActivityHelper(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    public void initializeScanner() {
        devicesList = new ArrayList<>();
        tsexample = new Scan(context, myHandler);

        // Data callback
        Scan.TsDataCallBack tsdatacallback = (iNode, pParam, pbuf, uiBufLen) -> {
            byte[] decode = new byte[uiBufLen];
            System.arraycopy(pbuf, 0, decode, 0, uiBufLen);
            ScanMsg(Scan.HANDLER_SCAN_DEC, iNode, 0, new String(decode));
            return 0;
        };

        // State callback
        Scan.TsStateCallBack tsstatecallback = (iNode, pParam, ucState) -> {
            if (ucState == 1) {
                String message = s_uiLanguage == 0 ?
                        "设备连接成功" : "Device connection successful";
                ScanMsg(Scan.HANDLER_SCAN_TEXT, 0, 0, message);
                getDeviceInfo(iNode);
            } else {
                String message = s_uiLanguage == 0 ?
                        "设备断开连接" : "Device disconnection";
                ScanMsg(Scan.HANDLER_SCAN_TEXT, 0, 0, message);
            }
            return 0;
        };

        tsexample.ts_scan_get_data_fun_register(null, tsdatacallback);
        tsexample.ts_scan_state_fun_register(null, tsstatecallback);

        String versionInfo = "Ver:V" + tsexample.ts_scan_get_version() +
                " [" + tsexample.ts_scan_get_product_type() + "]";
        ScanMsg(Scan.HANDLER_SCAN_VERSION_TEXT, 0, 0, versionInfo);

        tsexample.ts_scan_init();
    }

    public void startScan(int deviceNode) {
        new Thread(() -> {
            while (busyFlag) {
                sleep(10);
            }
            busyFlag = true;
            try {
                tsexample.ts_scan_decode_start(deviceNode);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            busyFlag = false;
        }).start();
    }

    public void stopScan(int deviceNode) {
        new Thread(() -> {
            while (busyFlag) {
                sleep(10);
            }
            busyFlag = true;
            try {
                tsexample.ts_scan_decode_stop(deviceNode);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            busyFlag = false;
        }).start();
    }

    private void getDeviceInfo(int iNode) {
        byte[] ucBufTemp = new byte[128];
        byte[] ucBufTemp1;
        int iRet;
        String stbuf;

        iRet = tsexample.ts_scan_get_product_name(iNode, ucBufTemp, ucBufTemp.length);
        if (iRet > 0) {
            ucBufTemp1 = new byte[iRet];
            System.arraycopy(ucBufTemp, 0, ucBufTemp1, 0, iRet);
            stbuf = new String(ucBufTemp1);
            Log.d(TAG, "Product name: " + stbuf);
        }

        iRet = tsexample.ts_scan_get_product_id(iNode, ucBufTemp, ucBufTemp.length);
        if (iRet > 0) {
            ucBufTemp1 = new byte[iRet];
            System.arraycopy(ucBufTemp, 0, ucBufTemp1, 0, iRet);
            stbuf = new String(ucBufTemp1);
            Log.d(TAG, "Product id: " + stbuf);
        }

        iRet = tsexample.ts_scan_get_firmware_version(iNode, ucBufTemp, ucBufTemp.length);
        if (iRet > 0) {
            ucBufTemp1 = new byte[iRet];
            System.arraycopy(ucBufTemp, 0, ucBufTemp1, 0, iRet);
            stbuf = new String(ucBufTemp1);
            Log.d(TAG, "Firmware version: " + stbuf);
        }

        iRet = tsexample.ts_scan_get_hardware_version(iNode, ucBufTemp, ucBufTemp.length);
        if (iRet > 0) {
            ucBufTemp1 = new byte[iRet];
            System.arraycopy(ucBufTemp, 0, ucBufTemp1, 0, iRet);
            stbuf = new String(ucBufTemp1);
            Log.d(TAG, "Hardware version: " + stbuf);
        }
    }

    private void ScanMsg(int mode, int type, int status, Object value) {
        Message msg = new Message();
        msg.what = mode;
        msg.arg1 = type;
        msg.arg2 = status;
        msg.obj = value;
        myHandler.sendMessage(msg);
    }

    private void addDevice(int node) {
        ScanDevice device = new ScanDevice(node);
        devicesList.add(device);
        Map<String, Object> args = new HashMap<>();
        args.put("node", node);
        channel.invokeMethod("onDeviceAdded", args);
    }

    private void changeDeviceStatus(int node, int status) {
        for (ScanDevice device : devicesList) {
            if (device.GetNode() == node) {
                device.setStatus(status);
                break;
            }
        }
        Map<String, Object> args = new HashMap<>();
        args.put("node", node);
        args.put("status", status);
        channel.invokeMethod("onDeviceStatusChanged", args);
    }

    private void clearDeviceList() {
        devicesList.clear();
        channel.invokeMethod("onDeviceListCleared", null);
    }

    private void sleep(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException e) { e.printStackTrace(); }
    }

    private final Handler myHandler = new Handler(Looper.getMainLooper()) {
        public void handleMessage(Message msg) {
            int deviceId = msg.arg1;
            switch (msg.what) {
                case Scan.HANDLER_SCAN_STATUS:
                    addDevice(deviceId);
                    changeDeviceStatus(deviceId, ScanDevice.DEVICE_CONNECT);
                    break;

                case Scan.HANDLER_SCAN_DEC:
                    String scanData = (String) msg.obj;
                    Map<String, Object> scanArgs = new HashMap<>();
                    scanArgs.put("deviceId", deviceId);
                    scanArgs.put("data", scanData);
                    scanArgs.put("count", uiDecodeCnt);
                    channel.invokeMethod("onScanResult", scanArgs);
                    break;

                case Scan.HANDLER_SCAN_TEXT:
                    Map<String, Object> statusArgs = new HashMap<>();
                    statusArgs.put("message", (String) msg.obj);
                    channel.invokeMethod("onStatusUpdate", statusArgs);
                    break;

                case Scan.HANDLER_SCAN_CLEAR:
                    clearDeviceList();
                    changeDeviceStatus(deviceId, ScanDevice.DEVICE_CONNECT);
                    break;

                case Scan.HANDLER_SCAN_VERSION_TEXT:
                    Map<String, Object> versionArgs = new HashMap<>();
                    versionArgs.put("version", (String) msg.obj);
                    channel.invokeMethod("onVersionUpdate", versionArgs);
                    break;
            }
        }
    };

    public void cleanup() {
        try {
            if (tsexample != null) tsexample.ts_scan_deinit();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
