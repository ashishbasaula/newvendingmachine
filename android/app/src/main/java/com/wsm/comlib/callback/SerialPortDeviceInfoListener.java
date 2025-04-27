package com.wsm.comlib.callback;

public interface SerialPortDeviceInfoListener {

    /**
     *收到设备信息
     * @param deviceJson 原始字节数组
     * @param length 字节数组长度
     */
    void onDeviceInfoReceived(String deviceJson, int length);

}
