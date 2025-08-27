package com.example.finance_assistant_flutter

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "app/sms"
	private val NOTIF_CHANNEL = "app/notifications"
	private val SMS_PERMISSION_REQUEST = 12345
	private val NOTIF_PERMISSION_REQUEST = 12346
	private var pendingNotifResult: MethodChannel.Result? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			if (call.method == "getSms") {
				if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
					ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_SMS), SMS_PERMISSION_REQUEST)
					result.error("PERMISSION", "SMS read permission required", null)
				} else {
					val messages = readSms()
					result.success(messages)
				}
			} else {
				result.notImplemented()
			}
		}

		// Expose a simple method channel so Flutter can request POST_NOTIFICATIONS at runtime
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIF_CHANNEL).setMethodCallHandler { call, result ->
			if (call.method == "requestNotificationPermission") {
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
					if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
						result.success(true)
					} else {
						// store the result and ask for permission; will reply from onRequestPermissionsResult
						pendingNotifResult = result
						ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIF_PERMISSION_REQUEST)
					}
				} else {
					// below Android 13 notifications are granted by default
					result.success(true)
				}
			} else {
				result.notImplemented()
			}
		}
	}

	private fun readSms(): List<Map<String, Any>> {
		val uriSms: Uri = Uri.parse("content://sms/inbox")
		val cursor: Cursor? = contentResolver.query(uriSms, null, null, null, null)
		val list = ArrayList<Map<String, Any>>()
		cursor?.use {
			val idxAddress = cursor.getColumnIndex("address")
			val idxBody = cursor.getColumnIndex("body")
			val idxDate = cursor.getColumnIndex("date")
			while (cursor.moveToNext()) {
				val map = HashMap<String, Any>()
				map["address"] = if (idxAddress >= 0) cursor.getString(idxAddress) ?: "" else ""
				map["body"] = if (idxBody >= 0) cursor.getString(idxBody) ?: "" else ""
				map["date"] = if (idxDate >= 0) cursor.getLong(idxDate) else 0L
				list.add(map)
			}
		}
		return list
	}

	override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		if (requestCode == SMS_PERMISSION_REQUEST) {
			// No direct callback to Flutter here; the previous MethodChannel call returned an error.
			// Apps can trigger the import again after granting permission.
			return
		}
		if (requestCode == NOTIF_PERMISSION_REQUEST) {
			val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
			pendingNotifResult?.success(granted)
			pendingNotifResult = null
			return
		}
	}
}
