package com.wsm.comlib.util;


import android.util.Log;

public final class BleLog {

    public static boolean isPrint = false;
    private static String defaultTag = "TstudyBle_tag";

    public static void d(String msg) {
        if (isPrint && msg != null) {
            Log.d(defaultTag, msg);
        }
    }
    public static void d(String tag,String msg) {
        if (isPrint && msg != null&&tag!=null) {
            Log.d(tag, msg);
        }
    }

    public static void i(String msg) {
        if (isPrint && msg != null) {
            Log.i(defaultTag, msg);
        }
    }

    public static void w(String msg) {
        if (isPrint && msg != null) {
            Log.w(defaultTag, msg);
        }
    }

    public static void e(String msg) {
        if (isPrint && msg != null) {
            Log.e(defaultTag, msg);
        }
    }

}
