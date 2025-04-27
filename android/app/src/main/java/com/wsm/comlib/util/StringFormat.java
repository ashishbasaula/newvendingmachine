package com.wsm.comlib.util;

import com.wsm.comlib.constant.FormatConstant;

import java.io.UnsupportedEncodingException;

public class StringFormat {

    public static byte[] delete(int index, byte array[]) {
        //数组的删除其实就是覆盖前一位
        byte[] arrNew = new byte[array.length - 1];
        for (int i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        System.arraycopy(array, 0, arrNew, 0, arrNew.length);
        return arrNew;
    }

    public static byte[] concat(byte[] a, byte[] b) {
        byte[] c = new byte[a.length + b.length];
        System.arraycopy(a, 0, c, 0, a.length);
        System.arraycopy(b, 0, c, a.length, b.length);
        return c;
    }

    public static String bytes2Strings(byte[] bytes, String format) {
        if (format.equalsIgnoreCase(FormatConstant.FORMAT_GBK)) {
            return HexUtil.formatChar(bytes);

        } else if (format.equalsIgnoreCase(FormatConstant.FORMAT_UTF8)) {
            return HexUtil.formatChar(bytes);

        } else {
            return HexUtil.formatHexString(bytes);
        }
    }

    public static String bytes2String(byte[] bytes, String format) {
        if (format.equalsIgnoreCase(FormatConstant.FORMAT_GBK)) {
            try {
                return new String(bytes, FormatConstant.FORMAT_GBK);
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
                return HexUtil.formatHexString(bytes);
            }
        } else if (format.equalsIgnoreCase(FormatConstant.FORMAT_UTF8)) {
            try {
                return new String(bytes, FormatConstant.FORMAT_UTF8);
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
                return HexUtil.formatHexString(bytes);
            }
        } else {
            return HexUtil.formatHexString(bytes);
        }
    }


}
