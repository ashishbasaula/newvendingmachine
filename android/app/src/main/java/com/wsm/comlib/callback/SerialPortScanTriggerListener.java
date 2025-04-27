package com.wsm.comlib.callback;

public interface SerialPortScanTriggerListener {


    /**
     * 触发扫描回调接口
     * @param actionStatus 触发扫描的状态
     */
    void onStatusChange(boolean actionStatus);

}
