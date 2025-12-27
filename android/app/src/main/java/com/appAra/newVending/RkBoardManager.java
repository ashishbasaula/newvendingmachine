package com.appAra.newVending;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.MethodChannel;
import tp.xmaihh.serialport.SerialHelper;
import tp.xmaihh.serialport.bean.ComBean;
import tp.xmaihh.serialport.utils.ByteUtil;
import com.ys.rkapi.MyManager;

public class RkBoardManager {
    private static final String TAG = "RkBoardManager";
    private static final int REQUEST_SERIAL_PERMISSION = 1;
    
    private Context context;
    private MethodChannel methodChannel;
    private SerialHelper serialHelper;
    private StringBuffer buffer = new StringBuffer();
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private String lastUniqueData = "";

    public RkBoardManager(Context context, MethodChannel methodChannel) {
        this.context = context;
        this.methodChannel = methodChannel;
    }

    /**
     * Configure and open the serial port
     */
    public void configureSerialPort(String serialName, String baudRate, MethodChannel.Result result) {
        try {
            if (serialHelper != null && serialHelper.isOpen()) {
                serialHelper.close();
            }
            
            serialHelper = new SerialHelper(serialName, Integer.parseInt(baudRate)) {
                @Override
                protected void onDataReceived(final ComBean comBean) {
                    byte[] datas = comBean.bRec;
                    String receivedData = ByteUtil.ByteArrToHex(datas).toUpperCase() + "\n";
                    buffer.append(receivedData);
                    
                    // Send data back to Flutter
                    mHandler.post(() -> {
                        methodChannel.invokeMethod("updateLastUniqueData", buffer.toString());
                        buffer.setLength(0);
                    });
                }
            };
            
            serialHelper.open();
            result.success("Serial port opened successfully");
            Log.d(TAG, "Serial port opened: " + serialName + " at " + baudRate);
        } catch (Exception e) {
            Log.e(TAG, "Failed to open serial port", e);
            result.error("ERROR", "Failed to open serial port: " + e.getLocalizedMessage(), null);
        }
    }

    /**
     * Send command through serial port with optional wake signal
     */
    public synchronized void sendCommand(String data, boolean isNeedSendWake, MethodChannel.Result result) {
        if (serialHelper == null || !serialHelper.isOpen()) {
            result.error("ERROR", "Serial port is not open", null);
            return;
        }
        
        try {
            if (isNeedSendWake) {
                String wakeDatas = "0001";
                Log.d(TAG, "Sending wake data: " + wakeDatas);
                serialHelper.sendHex(wakeDatas.toUpperCase());
            }
            
            long delayTime = isNeedSendWake ? 100L : 0;
            mHandler.postDelayed(() -> {
                Log.d(TAG, "Sending command: " + data.toUpperCase());
                serialHelper.sendHex(data.toUpperCase());
            }, delayTime);
            
            result.success("Command sent successfully");
        } catch (Exception e) {
            Log.e(TAG, "Failed to send command", e);
            result.error("ERROR", "Failed to send command: " + e.getLocalizedMessage(), null);
        }
    }

    /**
     * Close the serial port
     */
    public void closeSerialPort(MethodChannel.Result result) {
        if (serialHelper != null && serialHelper.isOpen()) {
            serialHelper.close();
            buffer.setLength(0);
            result.success("Serial port closed successfully");
            Log.d(TAG, "Serial port closed");
        } else {
            result.error("ERROR", "Serial port is not open", null);
        }
    }

    /**
     * Check if serial port is open
     */
    public boolean isSerialPortOpen() {
        return serialHelper != null && serialHelper.isOpen();
    }

    /**
     * Cleanup resources
     */
    public void cleanup() {
        if (serialHelper != null && serialHelper.isOpen()) {
            serialHelper.close();
            Log.d(TAG, "RkBoardManager cleanup completed");
        }
        buffer.setLength(0);
    }

    /**
     * Get the serial number with permission handling
     */
    public String getSerialNumber() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) 
                    == PackageManager.PERMISSION_GRANTED) {
                return Build.getSerial();
            } else {
                // Permission not granted, need to request
                return null;
            }
        } else {
            MyManager manager = MyManager.getInstance(context);
            return manager.getSn();
        }
    }
}