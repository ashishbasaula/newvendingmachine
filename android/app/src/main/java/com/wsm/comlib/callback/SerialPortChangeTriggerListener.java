package com.wsm.comlib.callback;

public interface SerialPortChangeTriggerListener {

    /**
     * 切换命令触发回调接口
     * @param actionStatus 触发扫描的状态
     */
    void onStatusChange(boolean actionStatus);

}
