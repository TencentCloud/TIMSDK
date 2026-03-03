package com.tencent.qcloud.tuikit.tuicallkit.manager.feature.notification

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.View
import android.widget.Button
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger

class NotificationRequestActivity : Activity() {
    private var isReturningFromSettings = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Logger.i(TAG, "onCreate")
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            val decorView = window.decorView
            decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LAYOUT_STABLE)
            window.setStatusBarColor(Color.TRANSPARENT)
            window.setNavigationBarColor(Color.TRANSPARENT)
        }
        getActionBar()?.hide()

        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(arrayOf<String>("android.permission.POST_NOTIFICATIONS"), REQUEST_CODE_POST_NOTIFICATIONS)
        } else {
            showSettingsDialog()
        }
    }

    override fun onResume() {
        super.onResume()
        Logger.i(TAG, "onResume, isReturningFromSettings: $isReturningFromSettings")
        if (isReturningFromSettings) {
            isReturningFromSettings = false
            //TODO: UserGuidance.showUserGuidance()
            finish()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String?>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == REQUEST_CODE_POST_NOTIFICATIONS) {
            if (grantResults.size > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Logger.i(TAG, "PERMISSION_GRANTED")
                //TODO: UserGuidance.showUserGuidance()
                finish()
            } else {
                Logger.w(TAG, "PERMISSION_DENIED")
                showSettingsDialog()
            }
        }
    }

    private fun showSettingsDialog() {
        val dialog = Dialog(this, R.style.TUICallDialogTheme)
        dialog.setContentView(R.layout.tuicallkit_dialog_notification_request)

        val buttonNegative = dialog.findViewById<Button>(R.id.btn_negative)
        buttonNegative.setOnClickListener {
            dialog.dismiss()
            finish()
        }
        val buttonPositive = dialog.findViewById<Button>(R.id.btn_positive)
        buttonPositive.setOnClickListener {
            goToAppSettings(this)
            dialog.dismiss()
        }
        dialog.show()
    }

    private fun goToAppSettings(context: Context) {
        isReturningFromSettings = true
        val intent: Intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.setData(Uri.fromParts("package", context.packageName, null))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    companion object {
        private const val REQUEST_CODE_POST_NOTIFICATIONS = 101
        private const val TAG = "CallKit-NotificationRequest"

        fun request(context: Context) {
            Logger.i(TAG, "NotificationRequest: ${context.packageName}")
            val intent = Intent(context, NotificationRequestActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }
    }
}
