package com.wsm.comlib.callback;

import android.content.ComponentName;
import android.os.IBinder;

public interface SerialPortServiceConnectionListener {

    void onServiceConnected(ComponentName name, IBinder service);
    void onServiceDisconnected(ComponentName name);

}
