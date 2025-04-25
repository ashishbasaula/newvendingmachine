 package io.flutter.plugins;

import android.content.Context;
import android.serialport.SerialPort;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import amlib.ccid.SCError;
import amlib.hw.HWType;
import amlib.hw.HardwareInterface;
import amlib.hw.ReaderHwException;


public class HardwareInterfaceSerial implements HardwareInterface {

    private static final String TAG="SC-Serial";

    @Override
    /**To transfer data to hardware interface
     *
     * @param pBuff data to transfer, the length of pBuffer is specified in parameter 'Len'
     * @param Len length of data to transfer
     * @return  READER_SUCCESSFUL or other error code
     */

    public int Tx(byte []pBuff, int Len)
    {
        Log.d(TAG, "===========TX==========");
        int status = 0;
        int lenToSend = 0;
        int offset = 0;
        int pkSize = DefaultMaxCCIDMessageLength;
        byte []pBuffToSend = new byte[pkSize];
        if (IsDevSet() != true ){
            return  SCError.READER_NOT_INITIALED;
        }
        if (mCmdLock.tryLock() == false){
            return SCError.READER_CMD_BUSY;
        }

        cleanBuffer(pBuffToSend, pkSize);

        lenToSend = Len + 1; // + LRC byte
        System.arraycopy(pBuff, 0, pBuffToSend, 0, Len);
        pBuffToSend[lenToSend - 1] = getLRC(pBuff, Len);
        debugShowBuffer(pBuffToSend, lenToSend);

        try {
            status = rs232Write( pBuffToSend, lenToSend);
            if (status < 0){
                mCmdLock.unlock();
                Log.e(TAG, "rs232Write tx error "+ status);
                return SCError.READER_TRANSMIT_ERROR;
            }
            else{
                Log.d(TAG, "rs232Write write " + Integer.toString(status)+" bytes successfully");
            }
        } catch (IOException e) {
            Log.e(TAG, e.toString());
            mCmdLock.unlock();
            return SCError.READER_TRANSMIT_ERROR;
        }

        mCmdLock.unlock();
        return  SCError.READER_SUCCESSFUL;
    }
    @Override
    /**To receive data from hardware interface
     *
     * @param pBuff data to receive. Be aware that providing a buffer with enough size.
     * @param Len length of received  data
     * @return  READER_SUCCESSFUL or other error code
     */
    public int Rx(byte []pBuff, int[] Len)  {
        int status = 0;
        Log.d(TAG,"===========Rx==========");
        Log.d(TAG, "HardwareInterface-Rx");
        //dbgD("max Packet size is " + pkSize);
        if (IsDevSet() != true ){
            String msg = new String("Device is not initialed");
            Log.e(TAG, msg);
            return (SCError.READER_NOT_INITIALED);
        }
        if (mCmdLock.tryLock() == false){
            Log.e(TAG,"Device CMD trylock fail");
            return (SCError.READER_CMD_BUSY);
        }

        // Len[0]= 272;

        try {
            status = rs232Read(mReadBuffer, Len[0]);
        } catch (IOException e) {
            mCmdLock.unlock();
            Log.e(TAG, e.toString());
            return SCError.READER_TRANSMIT_ERROR;
        }

        if(status < 0){
            Log.e(TAG,"rs232Read error(" + status + ")  " );
            mCmdLock.unlock();
            return (SCError.READER_TRANSMIT_ERROR);
        }
        else{
            Log.d(TAG,"rs232Read " + Integer.toString(status)+" bytes successfully");
            Log.d(TAG,"LRC-"+ getLRC(mReadBuffer,status-1) +" vs " + "buf["+(Len[0]-1) +"]="+mReadBuffer[status-1]);
            status = status-1;//LRC byte
            System.arraycopy(mReadBuffer, 0, pBuff, 0, status);
            Len[0] = status ;
            Log.d(TAG,"-------------------------------");
        }

        mCmdLock.unlock();
        return SCError.READER_SUCCESSFUL;
    }

    /**To get the casted hardware interface instance (UsbDevice for instance)which has been stored
     *
     * @return Object
     * @see  Object
     */
    public Object getmDevObj() {
        return mDevObj;
    }

    @Override
    /**
     * Reserved
     * @return Reserved
     */
    public Object getPrivateData() {
        return (Object)null;
    }


    @Override
    /**To get the Hardware type
     *
     * @return HWType
     * @see HWType
     */
    public HWType getHWType() {
        return mHWType;
    }



    @Override
    public Object getPrivateData1() {
        return null;
    }

    @Override
    public Object getPrivateData2() {
        return null;
    }

    @Override
    public Object getPrivateData3() {
        return null;
    }




    private Object mDevObj;
    private boolean mIsDevInit;
    private HWType mHWType;
    private Lock mCmdLock;
    private static final byte File_TAG = 0;/*SCError.TAG_HwInterface;*/
    private static final int TIME_OUT = 5*1000;//5 seconds
    private static final byte CLASS_SMARTCARD = 0xb;

//    private UsbInterface mSecondInterface;

    private static final int SNOffset = 16;

    private static final int VERSION_LOLLIPOP = 21;
    private static final int VERSION_MARSHMALLOW = 23;
    private Context mAppCtx;

    private boolean isClone;
    HardwareInterface secondary;
    private static final int DefaultMaxCCIDMessageLength = 272;


    public HardwareInterfaceSerial(HWType Type){
        constructor(Type);
    }

    public int readerSetBaudRate(int baudrate)  {
        byte mBuf[] = new byte [11];
        int []len = new int[1];
        byte baudSelect = 3;
        int ret =0;
        switch (baudrate)
        {
            case 4800:
                baudSelect = 0;
            case 9600:
                baudSelect = 1;
                break;
            case 19200:
                baudSelect = 2;
                break;
            case 38400:
                baudSelect = 3;
                break;
            case 115200:
                baudSelect = 6;
                break;

        }
        mBuf[0] = (byte)0x66;
        mBuf[1] = (byte)0x0;
        mBuf[2] = (byte)0x0;
        mBuf[3] = (byte)0x0;
        mBuf[4] = (byte)0x0;
        mBuf[5] = (byte)0x0;
        mBuf[6] = (byte)0x0;
        mBuf[7] = baudSelect;
        mBuf[8] = (byte)0x0;
        mBuf[9] = (byte)0x0;

        Tx(mBuf, 10);
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        len[0] = 10;
        ret = Rx(mBuf, len);
        if (ret != SCError.READER_SUCCESSFUL)
            return ret;
        return ret;
    }

    private SerialPort mSp;
    private FileOutputStream mOutputStream;
    private FileInputStream mInputStream;
    public boolean Init(String devPath, int baudRate) throws ReaderHwException {
        Log.d(TAG," Hw init ... ");
        try {
            /*/dev/ttySAC3 for Tiny4412*/
            mSp = new SerialPort(new File(devPath),baudRate, 0);// O_RDWR | O_DIRECT | O_SYNC);
            setmDevObj(mSp);
            mOutputStream=(FileOutputStream) mSp.getOutputStream();
            mInputStream=(FileInputStream) mSp.getInputStream();


            mReadBuffer = new byte[DefaultMaxCCIDMessageLength];
            mIsDevInit = true;
//				mReadThread = new ReadThread();
//				mReadThread.start();
            //set baud rate

            int ret = readerSetBaudRate(38400);
            if ( ret ==0)
                return true;
            throw new ReaderHwException("readerSetBaudRate fail " + SCError.errorCode2String(ret));

        }
        catch (IOException e) {
            Log.e(TAG," IOException  ");
            e.printStackTrace();
            throw new ReaderHwException(e.toString());
        }
        catch (SecurityException e) {
            Log.e(TAG," SecurityException  ");
            e.printStackTrace();
            throw new ReaderHwException(e.toString());
        }
    }

    private void constructor(HWType Type) {
        EmptyMember();
        setupDebug();
        setHWType(Type);
        isClone = false;
        mCmdLock = new ReentrantLock();
    }


    /**To close hardware interface
     *
     * @return  true for successful.
     */
    public boolean Close( ) throws ReaderHwException {
        Log.d(TAG,"Close serial port");
        boolean result = false;
//		mDbg.close();
        if (isClone == true)
            throw new ReaderHwException("Don't close device in a clone");
        if (!mIsDevInit)
            return true;
        mSp.close();

        EmptyMember();
        return result;
    }


	/*
	private boolean getFeature(byte pData[]){
		int status = 0;
		dbgD("getFeature");
		if (IsDevSet() != true )
			throw new IllegalArgumentException("Device is not initialed");
		 //status = mDeviceConnection.controlTransfer(0x80, 0x6, 0x2100, 0x00, pData, 36, TIME_OUT);
		 status = mDeviceConnection.controlTransfer(0x80, 0x6, 0x0200, 0x00, pData, 128, TIME_OUT);
		 if (status < 0){
				Log.e( TAG, "control transfer error("+status+")" );
				return false;
			}
		 return true;
	}
	 */




    private void cleanBuffer (byte buf[], int len) {
        for (int i = 0; i < len; i++) {
            buf[i] = 0x00;
        }
    }
    private void debugShowBuffer (byte buf[], int len) {
        for (int i = 0; i < len; i++) {
            Log.v(TAG,"pBuff[" + i + "]=" + Integer.toHexString(buf[i] & 0x000000ff));
        }
    }

    private void setmDevObj(SerialPort Dev) {
        mDevObj = (Object)Dev;
    }


    private void setAppContext(Context ctx)
    {
        mAppCtx = ctx;

    }

    private void setupDebug() {
        if (mAppCtx == null)
            return;

    }
    private ReadThread mReadThread;
    private byte[] mReadBuffer ;//= new byte[64];
    private int mReadSize = 0;
    private final Lock mLock = new ReentrantLock();
    private void testWrite() {
        Log.d(TAG,"Tx...");
        byte mBuf[] = new byte [11];
        int []len = new int[1];
        byte baudSelect = 3;

        mBuf[0] = (byte)0x66;
        mBuf[1] = (byte)0x0;
        mBuf[2] = (byte)0x0;
        mBuf[3] = (byte)0x0;
        mBuf[4] = (byte)0x0;
        mBuf[5] = (byte)0x0;
        mBuf[6] = (byte)0x0;
        mBuf[7] = (byte)0xFF;
        mBuf[8] = (byte)0x0;
        mBuf[9] = (byte)0x0;

        try {
            mOutputStream.write(mBuf);
        } catch (IOException e) {
            e.printStackTrace();
        }


    }
    private void testRead() {

        if (mInputStream == null)
            return;
        //	dbgB("read loop");
        try {
            mReadSize = mInputStream.available();

            if (mReadSize > 0)
                Log.d(TAG,"mInputStream avaliable is "+mReadSize);
            mReadSize = mInputStream.read(mReadBuffer, 0, mInputStream.available());
            //mReadSize = mInputStream.read(mReadBuffer, 0, 64);
            if (mReadSize > 0) {
                for (int i=0; i< mReadSize; i++){
                    Log.d(TAG,"mReadBuffer[" + i +"]=" + Integer.toHexString(mReadBuffer[i]&0x000000ff));
                }//onDataReceived(buffer, size);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }



    }

    private class ReadThread extends Thread {

        @Override
        public void run() {
            super.run();
            Log.d(TAG," ReadThread init ");
            while(true) {
                //	while(!isInterrupted()) {
                //mLock.lock();
                mReadSize = 0;

//					testWrite();
                testRead();
					/*
					if (mInputStream == null)
						return;
					//	dbgB("read loop");
					mReadSize = mInputStream.available();
					if (mReadSize > 0)
						dbgB("mInputStream avaliable is "+mReadSize);
					mReadSize = mInputStream.read(mReadBuffer, 0, mInputStream.available());
					//mReadSize = mInputStream.read(mReadBuffer, 0, 64);
					if (mReadSize > 0) {
						for (int i=0; i< mReadSize; i++){
							dbgD("mReadBuffer[" + i +"]=" + Integer.toHexString(mReadBuffer[i]&0x000000ff));
						}//onDataReceived(buffer, size);
					}

					 */
                //	else
                //	dbgB("readInput return " +mReadSize);



                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        }
    }

    protected boolean IsDevSet()
    {
        if( mDevObj == null || mIsDevInit == false)
        {
            Log.e(TAG, "Hardware Interface is not ready");
            return false;
        }
        else
            return true;
    }

    private void EmptyMember()
    {
        mDevObj = null;

        mIsDevInit = false;
        //mHWType = HWType.eEMPTY;
    }




    private void setHWType(HWType mHWType) {
        switch (mHWType){
            case eEMPTY:
            case eUSB:
            case eRS232:
                this.mHWType = mHWType;
                break;
            default:
                throw new IllegalArgumentException("Hardware Interface HWType is invalid");
        }

    }

    /**To get maximum data length for each Tx packet.
     *
     * @return length of maximum data length for each Tx packet.
     */
    public int getMaxTxPkLength(){
        return DefaultMaxCCIDMessageLength;
    }

    /**To get maximum data length for each Rx packet.
     *
     * @return length of maximum data length for each Rx packet.
     */
    public int getMaxRxPkLength(){
        return DefaultMaxCCIDMessageLength;
    }

    private int rs232Write(byte mBuf[], int length)  throws IOException{
        Log.d(TAG,"rs232Write...");
        mOutputStream.write(mBuf, 0, length);
        return length;
    }

    private int rs232Read(byte buf[], int lenReserved) throws IOException {
        Log.d(TAG,"rs232Read...");
        int offset =0;
        int  readSize;
        do {
            if (mInputStream == null)
                throw new IOException("InputStream is null");
            waitData();
            readSize = readInputStream(buf, offset);
            offset += readSize;
            if (rxDataCompletedCheck(buf, offset) == true )
                break;
            checkOffset(offset);

        }while(true);
        return offset;
    }

    private void checkOffset (int offset) throws IOException {
        if (offset == DefaultMaxCCIDMessageLength) {
            String s = "read data size reaches " + DefaultMaxCCIDMessageLength +" but there are no" +
                    "correct LRC in the end of data";
            Log.e(TAG, s);
            throw  new IOException("s");
        }
    }
    private static final int WaitDataDelayMilliSecond = 5;
    private static final int WaitDataTimeoutMilliSecond = 5*1000;
    private void waitData() throws IOException {
        long startTime = System.currentTimeMillis();
        try {
            do {
                Thread.sleep(WaitDataDelayMilliSecond);
                if (System.currentTimeMillis() > startTime+WaitDataTimeoutMilliSecond) {
                    Log.e(TAG, "Waitting data timeout");
                    throw new IOException("Waitting data timeout");
                }
            }while (mInputStream.available() == 0 );}
        catch (InterruptedException e) {
            e.printStackTrace();
        }
        return;
    }

    private int readInputStream(byte []buf, int offset) throws IOException {
        int  readSize;
        readSize = mInputStream.available();
        Log.d(TAG,"mInputStream avaliable is " + readSize);
        if (readSize > buf.length) {
            StringBuilder s = new StringBuilder();
            s.append("available data is ").append(readSize).append("bytes, but buffer is ")
                    .append(buf.length).append("bytes");
            throw new IOException(s.toString());
        }

        readSize = mInputStream.read(buf, offset, mInputStream.available());
        //mReadSize = mInputStream.read(mReadBuffer, 0, 64);
        if (readSize > 0) {
            for (int i = offset; i < readSize+offset; i++) {
                Log.d(TAG,"mReadBuffer[" + i + "]=" + Integer.toHexString(buf[i] & 0x000000ff));
            }//onDataReceived(buffer, size);
        }

        return readSize;
    }

    private static final int CCID_HEADER_LENGTH = 10;
    private boolean rxDataCompletedCheck(byte []data, int rxLen) {

        byte LRC = getLRC(data, rxLen-1);
        if ( LRC != data[rxLen-1])
        {
            Log.d(TAG,"LRC not matching "+ String.format("0x%02x/",LRC)
                    + String.format("0x%02x",data[rxLen-1]));
            return false;
        }
        return true;
    }


    private int getLength(byte []data) {
        int len =
                data[1] &0x000000ff |
                        data[2] << 8 &0x0000ff00 |
                        data[3] << 16 &0x00ff0000 |
                        data[4] <<24 &0xff000000 ;
        return len;

    }
    private boolean isMessageTypeCorrect(byte data) {
        switch (data) {
            case (byte)0x80:
            case (byte)0x81:
            case (byte)0x82:
            case (byte)0x83:
            case (byte)0x84:
                return true;
            default:
                return false;
        }
    }
    private byte getLRC(byte []data, int len) {
        byte lrc = 0;
        for(int i=0; i<len;i++) {
            lrc  = (byte) (lrc^data[i]);
        }
        return lrc;
    }


}
