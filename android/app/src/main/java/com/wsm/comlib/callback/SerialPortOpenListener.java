package com.wsm.comlib.callback;

public interface SerialPortOpenListener {


    /**
     * 连接失败
     * @param status USB连接的code
     */
    void onConnectStatusChange(int status);

}
