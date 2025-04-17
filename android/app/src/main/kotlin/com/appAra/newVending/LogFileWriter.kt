package com.appAra.newVending

import android.content.Context
import android.os.Environment
import android.util.Log
import java.io.File
import java.io.FileWriter
import java.text.SimpleDateFormat
import java.util.*

class LogFileWriter(private val context: Context) {

    private val logFileName = "SmartCardLog.txt"

    // Get log file path in external storage
    private fun getLogFile(): File {
        val dir = context.getExternalFilesDir(null)
        return File(dir, logFileName)
    }

    // Call this to append a log line to the file
    fun writeLog(tag: String, message: String) {
        try {
            val logFile = getLogFile()
            val writer = FileWriter(logFile, true)
            val timeStamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
            writer.append("[$timeStamp][$tag] $message\n")
            writer.flush()
            writer.close()
        } catch (e: Exception) {
            Log.e("LogFileWriter", "Error writing log to file", e)
        }
    }

    // Optional: Save entire Logcat output to file
    fun saveFullLogcatToFile() {
        try {
            val process = Runtime.getRuntime().exec("logcat -d")
            val logFile = getLogFile()
            logFile.writeText(process.inputStream.bufferedReader().readText())
        } catch (e: Exception) {
            Log.e("LogFileWriter", "Failed to dump Logcat", e)
        }
    }

    fun clearLogcat() {
        try {
            Runtime.getRuntime().exec("logcat -c")
        } catch (e: Exception) {
            Log.e("LogFileWriter", "Failed to clear Logcat", e)
        }
    }
}
