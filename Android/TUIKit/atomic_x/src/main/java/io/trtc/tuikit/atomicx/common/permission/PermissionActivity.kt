package io.trtc.tuikit.atomicx.common.permission

import android.annotation.SuppressLint
import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.net.toUri
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.common.event.EventManager
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester.Companion.PERMISSION_NOTIFY_EVENT_KEY
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester.Companion.PERMISSION_NOTIFY_EVENT_SUB_KEY
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester.Companion.PERMISSION_REQUEST_KEY
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester.Companion.PERMISSION_RESULT
import io.trtc.tuikit.atomicx.common.util.TUIBuild

@RequiresApi(api = Build.VERSION_CODES.M)
class PermissionActivity : Activity() {

    companion object {
        private const val TAG = "PermissionActivity"
        private const val PERMISSION_REQUEST_CODE = 100
    }

    private lateinit var rationaleTitleTv: TextView
    private lateinit var rationaleDescriptionTv: TextView
    private lateinit var permissionIconIv: ImageView
    private var requestData: PermissionRequester.RequestData? = null

    private var result = PermissionRequester.Result.Denied

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestData = getPermissionRequest()
        if (requestData == null || requestData?.isPermissionsExistEmpty() == true) {
            Log.e(TAG, "onCreate mRequestData exist empty permission")
            finishWithResult(PermissionRequester.Result.Denied)
            return
        }
        Log.i(TAG, "onCreate : ${requestData.toString()}")
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.M) {
            finishWithResult(PermissionRequester.Result.Granted)
            return
        }

        makeBackGroundTransparent()
        initView()
        showPermissionRationale()

        requestPermissions(
            (requestData?.getPermissions() ?: emptyArray()) as Array<String>,
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        hidePermissionRationale()
        if (isAllPermissionsGranted(grantResults)) {
            finishWithResult(PermissionRequester.Result.Granted)
            return
        }
        showSettingsTip()
    }

    private fun showSettingsTip() {
        if (requestData == null) {
            return
        }

        val tipLayout =
            LayoutInflater.from(this).inflate(R.layout.common_permission_tip_layout, null)
        val tipsTv = tipLayout.findViewById<TextView>(R.id.tips)
        val positiveBtn = tipLayout.findViewById<TextView>(R.id.positive_btn)
        val negativeBtn = tipLayout.findViewById<TextView>(R.id.negative_btn)
        tipsTv.text = requestData?.settingsTip

        val permissionTipDialog: Dialog = AlertDialog.Builder(this)
            .setView(tipLayout)
            .setCancelable(false)
            .create()

        positiveBtn.setOnClickListener {
            permissionTipDialog.dismiss()
            launchAppDetailsSettings()
            finishWithResult(PermissionRequester.Result.Requesting)
        }

        negativeBtn.setOnClickListener {
            permissionTipDialog.dismiss()
            finishWithResult(PermissionRequester.Result.Denied)
        }

        permissionTipDialog.setOnKeyListener { dialog, keyCode, event ->
            if (keyCode == KeyEvent.KEYCODE_BACK && event.action == KeyEvent.ACTION_UP) {
                permissionTipDialog.dismiss()
            }
            true
        }

        val dialogWindow = permissionTipDialog.window
        dialogWindow?.setBackgroundDrawable(ColorDrawable())
        val layoutParams = dialogWindow?.attributes
        layoutParams?.width = WindowManager.LayoutParams.WRAP_CONTENT
        layoutParams?.height = WindowManager.LayoutParams.WRAP_CONTENT
        dialogWindow?.attributes = layoutParams
        permissionTipDialog.show()
    }

    /**
     * Launch the application's details settings.
     */
    private fun launchAppDetailsSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = "package:$packageName".toUri()
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (packageManager.queryIntentActivities(
                intent,
                PackageManager.MATCH_DEFAULT_ONLY
            ).isEmpty()
        ) {
            Log.e(TAG, "launchAppDetailsSettings can not find system settings")
            return
        }
        startActivity(intent)
    }

    private fun finishWithResult(result: PermissionRequester.Result) {
        Log.i(TAG, "finishWithResult : $result")
        this@PermissionActivity.result = result
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        val result = hashMapOf<String, Any>(PERMISSION_RESULT to result)
        EventManager.instance.notifyEvent(
            PERMISSION_NOTIFY_EVENT_KEY,
            PERMISSION_NOTIFY_EVENT_SUB_KEY,
            result
        )
    }

    private fun getPermissionRequest(): PermissionRequester.RequestData? {
        val intent = intent ?: return null
        return intent.getParcelableExtra(PERMISSION_REQUEST_KEY)
    }

    @SuppressLint("NewApi")
    private fun makeBackGroundTransparent() {
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            val decorView = window.decorView
            decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            window.statusBarColor = Color.TRANSPARENT
            window.navigationBarColor = Color.TRANSPARENT
        }

        actionBar?.hide()
    }

    private fun initView() {
        setContentView(R.layout.common_permission_activity_layout)
        rationaleTitleTv = findViewById(R.id.permission_reason_title)
        rationaleDescriptionTv = findViewById(R.id.permission_reason)
        permissionIconIv = findViewById(R.id.permission_icon)
    }

    /**
     *
     * Security compliance requires that when applying for permission, the reason for applying for permission must be
     * displayed.
     */
    private fun showPermissionRationale() {
        if (requestData == null) {
            return
        }
        rationaleTitleTv.text = requestData?.title
        rationaleDescriptionTv.text = requestData?.description
        permissionIconIv.setBackgroundResource(requestData?.permissionIconId ?: 0)

        rationaleTitleTv.visibility = View.VISIBLE
        rationaleDescriptionTv.visibility = View.VISIBLE
        permissionIconIv.visibility = View.VISIBLE
    }

    private fun hidePermissionRationale() {
        rationaleTitleTv.visibility = View.INVISIBLE
        rationaleDescriptionTv.visibility = View.INVISIBLE
        permissionIconIv.visibility = View.INVISIBLE
    }

    private fun isAllPermissionsGranted(grantResults: IntArray): Boolean {
        for (result in grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return true
    }
}
