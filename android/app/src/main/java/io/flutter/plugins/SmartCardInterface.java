package io.flutter.plugins;
import android.content.Context;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;
import android.os.Build;
import amlib.ccid.Reader;
import amlib.ccid.ReaderException;
import amlib.ccid.SCError;
import amlib.hw.HardwareInterface;
import amlib.hw.ReaderHwException;

public class SmartCardInterface {
    private static final String TAG = "SmartCardInterface";
 
    private Reader mReader;
    private HardwareInterface mMyDev;
    private UsbDevice mUsbDev;
    private UsbManager mManager;
    private Context mContext;
     

    public SmartCardInterface(Context context) {
        mContext = context;
        mManager = (UsbManager) mContext.getSystemService(Context.USB_SERVICE);
         
    }

    public int initializeReader(UsbDevice usbDevice) {
        mUsbDev = usbDevice;
        mMyDev = new HardwareInterface(amlib.hw.HWType.eUSB, mContext);
        try {
            if (!mMyDev.Init(mManager, mUsbDev)) {
                Log.e(TAG, "Device init fail");
                return -1;
            }
            mReader = new Reader(mMyDev);
            return mReader.open();
        } catch (ReaderHwException | ReaderException e) {
            Log.e(TAG, "Initialization failed: " + e.getMessage());
            return -1;
        }
    }

    public int closeReader() {
        if (mReader != null) {
            return mReader.close();
        }
        return 0;
    }

    public String getATR() {
        return mReader.getAtrString();
    }

    public String transmitAPDU(String apdu) {
        byte[] commandAPDU = toByteArray(apdu);
        byte[] responseAPDU = new byte[300];
        int[] responseLength = new int[] { 300 };

        int result = mReader.transmit(commandAPDU, commandAPDU.length, responseAPDU, responseLength);
        if (result == SCError.READER_SUCCESSFUL) {
            return "Receive APDU: " + byte2String(responseAPDU, responseLength[0]);
        } else {
            return "Fail to Send APDU: " + SCError.errorCode2String(result)
                    + "(0x" + Integer.toHexString(mReader.getCmdFailCode()) + ")";
        }
    }

    public int setPowerOn() {
        return mReader.setPower(Reader.CCID_POWERON);
    }

    public int setPowerOff() {
        return mReader.setPower(Reader.CCID_POWEROFF);
    }


    public static byte[] toByteArray(String hexString) {

		int hexStringLength = hexString.length();
		byte[] byteArray = null;
		int count = 0;
		char c;
		int i;

		// Count number of hex characters
		for (i = 0; i < hexStringLength; i++) {

			c = hexString.charAt(i);
			if (c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a'
					&& c <= 'f') {
				count++;
			}
		}

		byteArray = new byte[(count + 1) / 2];
		boolean first = true;
		int len = 0;
		int value;
		for (i = 0; i < hexStringLength; i++) {

			c = hexString.charAt(i);
			if (c >= '0' && c <= '9') {
				value = c - '0';
			} else if (c >= 'A' && c <= 'F') {
				value = c - 'A' + 10;
			} else if (c >= 'a' && c <= 'f') {
				value = c - 'a' + 10;
			} else {
				value = -1;
			}

			if (value >= 0) {

				if (first) {

					byteArray[len] = (byte) (value << 4);

				} else {

					byteArray[len] |= value;
					len++;
				}

				first = !first;
			}
		}

		return byteArray;
	}

public static String byte2String(byte[] buffer, int bufferLength) {

		StringBuilder bufferString = new StringBuilder();
		StringBuilder dbgString = new StringBuilder();

		for (int i = 0; i < bufferLength; i++) {

			String hexChar = Integer.toHexString(buffer[i] & 0xFF);
			if (hexChar.length() == 1) {
				hexChar = "0" + hexChar;
			}

			if (i % 16 == 0) {
				if (!dbgString.toString().equals("")) {
					//	                    Log.d(LOG_TAG, dbgString);
					bufferString.append(dbgString);
					dbgString = new StringBuilder("\n");
				}
			}

			dbgString.append(hexChar.toUpperCase()).append(" ");
		}

		if (!dbgString.toString().equals("")) {
			//	        	Log.d(LOG_TAG, dbgString);
			bufferString.append(dbgString);
		}

		return bufferString.toString();
	}
}
