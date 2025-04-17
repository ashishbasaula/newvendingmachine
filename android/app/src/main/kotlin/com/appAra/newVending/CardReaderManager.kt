package com.appAra.newVending


import amlib.hw.HardwareInterface
import amlib.hw.HWType
import android.content.Context
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.util.Log
import com.appAra.newVending.LogFileWriter


class CardReaderManager(private val context: Context) {
    private lateinit var usbManager: UsbManager
    private var usbDevice: UsbDevice? = null
    private lateinit var hardwareInterface: HardwareInterface
    val logFileWriter=LogFileWriter(context);



    fun initUsbConnection(): Boolean {
        usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager

        // Search for supported Alcorlink reader
        usbDevice = usbManager.deviceList.values.firstOrNull { device ->
            isAlcorReader(device)
        }

        if (usbDevice == null) {
            logFileWriter.writeLog("CardReader", "No supported Alcorlink reader found")
            ToastUtils.showShort(context, "No supported Alcorlink reader found")
            Log.e("CardReader", "No supported Alcorlink reader found")
            return false
        }
            logFileWriter.writeLog("CardReader", "Supported Alcorlink reader found")
            ToastUtils.showShort(context, "Supported Alcorlink reader found")

        hardwareInterface = HardwareInterface(HWType.eUSB, context.applicationContext)
        return try {
            hardwareInterface.Init(usbManager, usbDevice)
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun isAlcorReader(device: UsbDevice): Boolean {
        val vid = device.vendorId
        val pid = device.productId

        return when (vid) {
            0x058F -> pid in listOf(0x9540, 0x9520, 0x9522, 0x9525, 0x9526)
            0x2CE3 -> pid in listOf(0x9571, 0x9572, 0x9563, 0x9573)
            else -> false
        }
    }

    fun getUsbDevice(): UsbDevice? = usbDevice
    fun getHardwareInterface(): HardwareInterface = hardwareInterface
}
