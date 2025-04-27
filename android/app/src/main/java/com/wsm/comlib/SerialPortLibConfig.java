package com.wsm.comlib;

import com.wsm.comlib.constant.ConnectCostant;
import com.wsm.comlib.constant.FormatConstant;

/**
 * Created by sunwei on 2020/6/29 0029.
 */
public class SerialPortLibConfig {
    public static long timelone = 500L;
    public static String format = FormatConstant.FORMAT_UTF8;
    public static int hidStatus = ConnectCostant.ACTION_USB_DISCONNECTED;
    public static int deviceVID = 0x152A;
    public static int devicePID = 0x880F;

}
