package com.appAra.newVending;

public class ScanDevice {
    private String devicename;  
    private int node;
    private int DevStatus;
    
    public final static int DEVICE_NONE = 0;
    public final static int DEVICE_INPUT = 1;
    public final static int DEVICE_CONNECT = 2;
    
    public ScanDevice(int node){  
        this.node = node;
        this.devicename = "Device" + Integer.toString(node);    
        this.DevStatus = DEVICE_NONE;
    }  
    
    public String getBandname() { 
        return devicename;    
    }
    
    public int GetNode() {
        return node;
    }
    
    public void setStatus(int status) {
        DevStatus = status;
    }
    
    public int getStatus() {
        return DevStatus;
    }
}