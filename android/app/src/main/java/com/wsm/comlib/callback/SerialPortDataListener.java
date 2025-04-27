package com.wsm.comlib.callback;

public interface SerialPortDataListener {
    /**
     *收到数据
     * @param status 0x00读取成功，0x01读取超时
     * @param dataMessage 数据内容
     */
    void onDataReceived(byte status, String dataMessage);

    /**
     *收到原始数据
     * @param status 0x00读取成功，0x01读取超时
     * @param bytes 原始字节数组
     * @param length 字节数组长度
     */
    void onOriginalDataReceived(byte status, byte[] bytes, int length);

}
