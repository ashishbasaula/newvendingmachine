package com.appAra.newVending

import android.os.Bundle
import com.zcapi 
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*
import cc.uling.usdk.USDK
import cc.uling.usdk.board.UBoard
import cc.uling.usdk.constants.ErrorConst
import cc.uling.usdk.board.wz.para.SVReplyPara
import cc.uling.usdk.board.wz.para.SReplyPara
import cc.uling.usdk.board.wz.para.SSReplyPara
import android.widget.Toast
import com.ys.rkapi.MyManager;



class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.appAra.newVending/device"
    private var displayer = zcapi() // Initialize zcapi
     private var baudrate: Int = 9600
    // serial driver
    private lateinit var driver: UBoard
    // serial address
    var commid = "/dev/ttyS0"
 init {
        System.loadLibrary("serial_port")
    }
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    displayer.getContext(applicationContext) // Set context for zcapi
    USDK.getInstance().init(application)

    // Initialize the serial port and keep it resident in memory.
    this.driver = USDK.getInstance().create(this.commid).apply {
        val result = this.EF_OpenDev(commid, baudrate)
        if (result == ErrorConst.MDB_ERR_NO_ERR) {
            Toast.makeText(this@MainActivity, "Serial port opened successfully", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this@MainActivity, "Failed to open serial port", Toast.LENGTH_SHORT).show()
        }
    }
}


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val manager = MyManager.getInstance(this)
            when (call.method) {
                  "getApiVersion" -> result.success(manager.apiVersion)
                "getModelNumber" -> result.success(manager.androidModle)
                "getSystemStorage" -> result.success(manager.internalStorageMemory)
                "getCPUTemp" -> result.success(manager.cpuTemperature)
                "getBuildModel" -> {
                    val buildModel = getBuildModel()
                    result.success(buildModel)
                }   "rebootDevice" -> {
                    manager.reboot()
                    result.success("Device is rebooting")
                }
                "setGpioDirection" -> {
                    val gpio: Int? = call.argument("gpio")
                    val direction: Int? = call.argument("direction")
                    if (gpio != null && direction != null) {
                        result.success(manager.setGpioDirection(gpio, direction))
                    }
                }
                "shutdownDevice" -> {
                    manager.shutdown()
                    result.success("Device is shutting down")
                }"upgradeFirmware" -> {
                    val firmwarePath: String? = call.argument("firmwarePath")
                    if (firmwarePath != null) {
                        manager.upgradeSystem(firmwarePath)
                        result.success("Firmware upgrade initiated")
                    }
                }
                "changeScreenBrightness" -> {
                    val brightnessValue: Int? = call.argument("brightness")
                    if (brightnessValue != null) {
                        result.success(manager.changeScreenLight(brightnessValue))
                    }
                }
                 "getSystemVersion" -> result.success(manager.androidVersion)
                "getSdCardPath" -> result.success(manager.sDcardPath)
                "getUsbPath" -> result.success(manager.getUSBStoragePath(0))
                "disableBacklight" -> result.notImplemented()
                "getCPUModel" -> result.success(manager.cpuType) 
                "toggleHDMIOutput" -> {
                    val hdmiEnabled: Boolean? = call.argument("enable")
                    if (hdmiEnabled != null) {
                        if (hdmiEnabled) {
                            manager.turnOnHDMI()
                        } else {
                            manager.turnOffHDMI()
                        }
                        result.success("HDMI output toggled")
                    }
                }
                 "getGpioLevel" -> {
                    val gpio: Int? = call.argument("gpio")
                    if (gpio != null) {
                        result.success(manager.getGpioValue(gpio))
                    }
                }
                "setGpioValue" -> {
                    val gpio: Int? = call.argument("gpio")
                    val value: String? = call.argument("value")
                    if (gpio != null && value != null) {
                        manager.writeGpioValue(gpio, value)
                        result.success("GPIO value set")
                    }
                }
                "getSerialNumber" -> {
                var serialNumber=   displayer.getBuildSerial()
                    result.success(serialNumber)
                }"initiateShipment" -> {
                    val args = call.arguments<Map<String, Any>>() ?: mapOf()
                    try {
    val addr = args["addr"] as? Int ?: 1
    val no = args["no"] as? Int ?: 100
    val type = args["type"] as? Int ?: 1
    val check = args["check"] as? Boolean ?: false
    val lift = args["lift"] as? Boolean ?: false

    // add toast printer: request params
    initiateShipment(addr, no, type, check, lift)
    result.success("Shipment successful")
} catch (e: Exception) {
    result.error("SHIPMENT_ERROR", e.message, null)
}
                }
                 "getShipmentStatus" -> {
                    try {
                        val status = getShipmentStatus(call.arguments as Int)
                        result.success(status)
                    } catch (e: Exception) {
                        result.error("STATUS_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

     override fun onDestroy() {
        super.onDestroy()
        if (this::driver.isInitialized) {
            this.driver.EF_CloseDev()
        }
    }


    
    private fun getBuildModel(): String {
        return displayer.getBuildModel() // Assuming getBuildModel() returns the build model as String
    }

  private fun initiateShipment(addr: Int, no: Int, type: Int, check: Boolean, lift: Boolean) {
        if (!driver.EF_Opened()) {  // Check if the serial port is open
            Toast.makeText(this, "Serial port is not open. Unable to initiate shipment.", Toast.LENGTH_LONG).show()
            return  // Exit the method if the serial port is not open
        }

        try {
            SReplyPara(addr, no % 100, type, check, lift).apply {
                driver.Shipment(this)
                if (!this.isOK) {
                    throw Exception("Shipping failed: Device reported an error")
                }else{
                     Toast.makeText(this@MainActivity, "Successful Shipment: Address=$addr, Number=${no % 100}, Type=$type, Check=$check, Lift=$lift", Toast.LENGTH_LONG).show()
                }
            }
         
            // add toast message
        } catch (e: Exception) {
            Toast.makeText(this@MainActivity, "Error initiating shipment: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }


     private fun getShipmentStatus(addr: Int): Map<String, Any> {
        val para = SSReplyPara(addr).apply {
            driver.GetShipmentStatus(this)
        }.apply {
            if (!this.isOK) {
                throw Exception("get shipment status failed")
            }
        }

        return mapOf(
            "runStatus" to para.runStatus,
            "faultCode" to para.faultCode
        )
    }
}
