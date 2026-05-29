package io.trtc.tuikit.atomicx.common.permission

import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.os.Parcel
import android.os.Parcelable
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.annotation.Size
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.common.event.EventManager
import io.trtc.tuikit.atomicx.common.event.INotification
import com.tencent.cloud.tuikit.engine.common.ContextProvider
import io.trtc.tuikit.atomicx.common.util.TUIBuild
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast
import java.util.concurrent.atomic.AtomicBoolean

class PermissionRequester private constructor(private vararg val permissions: String) {

    companion object {
        private const val TAG = "PermissionRequester"

        const val PERMISSION_NOTIFY_EVENT_KEY = "PERMISSION_NOTIFY_EVENT_KEY"
        const val PERMISSION_NOTIFY_EVENT_SUB_KEY = "PERMISSION_NOTIFY_EVENT_SUB_KEY"
        const val PERMISSION_RESULT = "PERMISSION_RESULT"
        const val PERMISSION_REQUEST_KEY = "PERMISSION_REQUEST_KEY"
        private val sLock = Any()

        private val sIsRequesting = AtomicBoolean(false)

        const val FLOAT_PERMISSION = "PermissionOverlayWindows"
        const val BG_START_PERMISSION = "PermissionStartActivityFromBackground"

        /**
         * Generate an instance of PermissionRequester, where the parameters are the specific permissions that need to be
         * applied for, and one or more permissions can be passed in.
         *
         * @param permissions The name of the permission that needs to be applied for.
         * @return An instance of PermissionRequester.
         */
        @JvmStatic
        fun newInstance(@Size(min = 1) vararg permissions: String): PermissionRequester {
            return PermissionRequester(*permissions)
        }
    }

    enum class Result { Granted, Denied, Requesting }

    private var permissionCallback: PermissionCallback? = null
    private var title: String? = null
    private var description: String? = null
    private var settingsTip: String? = null
    private val permissionNotification: INotification

    private val directPermissionList = ArrayList<String>()
    private val indirectPermissionList = ArrayList<String>()

    init {
        for (permission in permissions) {
            if (FLOAT_PERMISSION == permission || BG_START_PERMISSION == permission) {
                indirectPermissionList.add(permission)
            } else {
                directPermissionList.add(permission)
            }
        }

        permissionNotification = INotification { key, subKey, param ->
            if (param == null) {
                return@INotification
            }
            val result = param[PERMISSION_RESULT]
            if (result == null) {
                return@INotification
            }
            notifyPermissionRequestResult(result as Result)
        }
    }

    /**
     * The title of the reason: security compliance requirements, when requesting permission, you
     * must explain to the user why you need to apply for the permission;
     *
     * @param title The title of the reason;
     * @return An instance of PermissionRequester.
     */
    fun title(title: String): PermissionRequester {
        this@PermissionRequester.title = title
        return this
    }

    /**
     * The text of the reason: security compliance requirements, when requesting permission,
     * explain to the user why the permission is required;
     *
     * @param description The text of the reason;
     * @return An instance of PermissionRequester.
     */
    fun description(description: String): PermissionRequester {
        this@PermissionRequester.description = description
        return this
    }

    /**
     * Explain to the user what permissions need to be opened after entering the Settings to
     * ensure the normal operation of the function;
     *
     * @param settingsTip Prompt user what to do in settings;
     * @return An instance of PermissionRequester.
     */
    fun settingsTip(settingsTip: String): PermissionRequester {
        this@PermissionRequester.settingsTip = settingsTip
        return this
    }

    /**
     * Set the callback used to get the permission application result.
     *
     * @param callback callback for permission application;
     * @return An instance of PermissionRequester.
     */
    fun callback(callback: PermissionCallback): PermissionRequester {
        permissionCallback = callback
        return this
    }

    /**
     * Start requesting permission.
     */
    @SuppressLint("NewApi")
    fun request() {
        Log.i(
            TAG, "request, directPermissionList: $directPermissionList" +
                 " ,indirectPermissionList:  $indirectPermissionList"
        )
        if (directPermissionList.isNotEmpty()) {
            requestDirectPermission(directPermissionList.toTypedArray())
        }
        if (indirectPermissionList.isNotEmpty()) {
            startAppDetailsSettingsByBrand()
        }
    }

    @SuppressLint("NewApi")
    private fun requestDirectPermission(permissions: Array<String>) {
        synchronized(sLock) {
            if (sIsRequesting.get()) {
                Log.e(TAG, "can not request during requesting")
                permissionCallback?.onRequesting()
                return
            }
            sIsRequesting.set(true)
        }

        EventManager.instance.registerEvent(
            PERMISSION_NOTIFY_EVENT_KEY,
            PERMISSION_NOTIFY_EVENT_SUB_KEY,
            permissionNotification
        )
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.M) {
            Log.i(TAG, "current version is lower than 23")
            notifyPermissionRequestResult(Result.Granted)
            return
        }
        val unauthorizedPermissions = findUnauthorizedPermissions(permissions)
        if (unauthorizedPermissions.isEmpty()) {
            notifyPermissionRequestResult(Result.Granted)
            return
        }
        val realRequest =
            RequestData(title, description, settingsTip, *unauthorizedPermissions)
        startPermissionActivity(realRequest)
    }

    /**
     * Do not support check float permission(or background permission) with microphone(or camera\bluetooth) together
     */
    fun has(): Boolean {
        return when {
            indirectPermissionList.contains(BG_START_PERMISSION) -> {
                hasFloatPermission() && hasBgStartPermission()
            }

            indirectPermissionList.contains(FLOAT_PERMISSION) -> {
                hasFloatPermission()
            }

            else -> {
                directPermissionList.all { has(it) }
            }
        }
    }

    private fun has(permission: String): Boolean {
        val context = ContextProvider.getApplicationContext() ?: return false
        return TUIBuild.getVersionInt() < Build.VERSION_CODES.M ||
               PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(
            context,
            permission
        )
    }

    private fun notifyPermissionRequestResult(result: Result) {
        EventManager.instance.unRegisterEvent(
            PERMISSION_NOTIFY_EVENT_KEY,
            PERMISSION_NOTIFY_EVENT_SUB_KEY,
            permissionNotification
        )
        sIsRequesting.set(false)
        if (permissionCallback == null) {
            return
        }
        when (result) {
            Result.Granted -> permissionCallback?.onGranted()
            Result.Requesting -> permissionCallback?.onRequesting()
            Result.Denied -> permissionCallback?.onDenied()
        }
        permissionCallback = null
    }

    private fun findUnauthorizedPermissions(permissions: Array<String>): Array<String> {
        val appContext = ContextProvider.getApplicationContext()
        if (appContext == null) {
            Log.e(TAG, "findUnauthorizedPermissions appContext is null")
            return permissions
        }
        val unauthorizedList = mutableListOf<String>()
        for (permission in permissions) {
            if (PackageManager.PERMISSION_GRANTED != ContextCompat.checkSelfPermission(
                    appContext,
                    permission
                )
            ) {
                unauthorizedList.add(permission)
            }
        }
        return unauthorizedList.toTypedArray()
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private fun startPermissionActivity(request: RequestData) {
        val context = ContextProvider.getApplicationContext() ?: return
        val intent = Intent(context, PermissionActivity::class.java)
        intent.putExtra(PERMISSION_REQUEST_KEY, request)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    class RequestData : Parcelable {
        private val permissions: Array<String>
        val title: String?
        val description: String?
        val settingsTip: String?
        var permissionIconId: Int = 0

        constructor(title: String?, description: String?, settingsTip: String?, vararg perms: String) {
            this.title = title
            this.description = description
            this.settingsTip = settingsTip
            this.permissions = perms.clone() as Array<String>
        }

        protected constructor(parcel: Parcel) {
            permissions = parcel.createStringArray() ?: emptyArray()
            title = parcel.readString() ?: ""
            description = parcel.readString() ?: ""
            settingsTip = parcel.readString() ?: ""
            permissionIconId = parcel.readInt()
        }

        fun isPermissionsExistEmpty(): Boolean {
            if (permissions.isEmpty()) {
                return true
            }
            for (permission in permissions) {
                if (TextUtils.isEmpty(permission)) {
                    return true
                }
            }
            return false
        }

        fun getPermissions(): Array<String> {
            return permissions.clone()
        }

        override fun toString(): String {
            return "PermissionRequest{" +
                   "mPermissions=${permissions.contentToString()}, mTitle=$title, mDescription='$description, mSettingsTip='$settingsTip" +
                   '}'
        }

        override fun describeContents(): Int {
            return 0
        }

        override fun writeToParcel(dest: Parcel, flags: Int) {
            dest.writeStringArray(permissions)
            dest.writeString(title)
            dest.writeString(description)
            dest.writeString(settingsTip)
            dest.writeInt(permissionIconId)
        }

        companion object CREATOR : Parcelable.Creator<RequestData> {
            override fun createFromParcel(parcel: Parcel): RequestData {
                return RequestData(parcel)
            }

            override fun newArray(size: Int): Array<RequestData?> {
                return arrayOfNulls(size)
            }
        }
    }

    private fun startAppDetailsSettingsByBrand() {
        val context = ContextProvider.getApplicationContext() ?: return
        when {
            TUIBuild.isBrandVivo() -> startVivoPermissionSettings(context)
            TUIBuild.isBrandHuawei() -> startHuaweiPermissionSettings(context)
            TUIBuild.isBrandXiaoMi() -> startXiaomiPermissionSettings(context)
            else -> startCommonSettings(context)
        }
    }

    private fun startCommonSettings(context: Context) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.data = Uri.parse("package:${context.packageName}")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startVivoPermissionSettings(context: Context) {
        try {
            val intent = Intent()
            intent.setClassName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity"
            )
            intent.action = "secure.intent.action.softPermissionDetail"
            intent.putExtra("packagename", context.packageName)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            AtomicToast.show(
                context,
                context.resources.getString(R.string.common_float_permission_hint),
                AtomicToast.Style.INFO
            )
        } catch (e: Exception) {
            Log.w(TAG, "startVivoPermissionSettings: open common settings")
            startCommonSettings(context)
        }
    }

    private fun startHuaweiPermissionSettings(context: Context) {
        if (!TUIBuild.isHarmonyOS()) {
            Log.i(TAG, "The device is not Harmony or cannot get system operator")
            startCommonSettings(context)
            return
        }

        try {
            val intent = Intent()
            intent.putExtra("packageName", context.packageName)
            val comp = ComponentName(
                "com.huawei.systemmanager",
                "com.huawei.permissionmanager.ui.MainActivity"
            )
            intent.component = comp
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            AtomicToast.show(
                context,
                context.resources.getString(R.string.common_float_permission_hint),
                AtomicToast.Style.INFO
            )
        } catch (e: Exception) {
            Log.w(TAG, "startHuaweiPermissionSettings: open common settings")
            startCommonSettings(context)
        }
    }

    private fun startXiaomiPermissionSettings(context: Context) {
        if (!TUIBuild.isMiuiOptimization()) {
            Log.i(TAG, "The device do not open miuiOptimization or cannot get miui property")
            startCommonSettings(context)
            return
        }

        try {
            val intent = Intent("miui.intent.action.APP_PERM_EDITOR")
            intent.setClassName(
                "com.miui.securitycenter",
                "com.miui.permcenter.permissions.PermissionsEditorActivity"
            )
            intent.putExtra("extra_pkgname", context.packageName)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)

            AtomicToast.show(
                context,
                context.resources.getString(R.string.common_float_permission_hint),
                AtomicToast.Style.INFO
            )
        } catch (e: Exception) {
            Log.w(TAG, "startXiaomiPermissionSettings: open common settings")
            startCommonSettings(context)
        }
    }

    /**
     * 1. For most phone, floating permissions and background permission are the same.
     * 2. If the xiaomi phone has turned off MIUI optimization. When requesting float or background
     * pop-ups permission, it will start Settings.canDrawOverlays which cannot support open background pop-ups
     * permission. You need manually enable the background pop-ups permission in the system application Settings.
     */
    private fun hasBgStartPermission(): Boolean {
        val context = ContextProvider.getApplicationContext() ?: return false
        return when {
            TUIBuild.isBrandHuawei() && TUIBuild.isHarmonyOS() -> {
                isHarmonyBgStartPermissionAllowed(context)
            }

            TUIBuild.isBrandVivo() -> {
                isVivoBgStartPermissionAllowed(context)
            }

            TUIBuild.isBrandXiaoMi() && TUIBuild.isMiuiOptimization() -> {
                isXiaomiBgStartPermissionAllowed(context)
            }

            else -> hasFloatPermission()
        }
    }

    private fun hasFloatPermission(): Boolean {
        try {
            val context = ContextProvider.getApplicationContext() ?: return false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                val manager = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
                              ?: return false
                val method =
                    AppOpsManager::class.java.getMethod(
                        "checkOp",
                        Int::class.java,
                        Int::class.java,
                        String::class.java
                    )
                val result =
                    method.invoke(manager, 24, Binder.getCallingUid(), context.packageName) as Int
                Log.i(TAG, "hasFloatPermission, result: ${AppOpsManager.MODE_ALLOWED == result}")
                return AppOpsManager.MODE_ALLOWED == result
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun isHarmonyBgStartPermissionAllowed(context: Context): Boolean {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                val manager = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
                              ?: return false
                val clz = Class.forName("com.huawei.android.app.AppOpsManagerEx")
                val method = clz.getDeclaredMethod(
                    "checkHwOpNoThrow",
                    AppOpsManager::class.java,
                    Int::class.java,
                    Int::class.java,
                    String::class.java
                )
                val result = method.invoke(
                    clz.newInstance(),
                    manager,
                    100000,
                    android.os.Process.myUid(),
                    context.packageName
                ) as Int
                Log.i(TAG, "isHarmonyBgStartPermissionAllowed, result: ${result == 0}")
                return result == 0
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun isVivoBgStartPermissionAllowed(context: Context): Boolean {
        try {
            val uri =
                Uri.parse("content://com.vivo.permissionmanager.provider.permission/start_bg_activity")
            val cursor: Cursor? = context.contentResolver.query(
                uri, null, "pkgname = ?",
                arrayOf(context.packageName), null
            )
            if (cursor == null) {
                return false
            }
            if (cursor.moveToFirst()) {
                val result = cursor.getInt(cursor.getColumnIndex("currentstate"))
                cursor.close()
                Log.i(TAG, "isVivoBgStartPermissionAllowed, result: ${0 == result}")
                return 0 == result
            } else {
                cursor.close()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun isXiaomiBgStartPermissionAllowed(context: Context): Boolean {
        try {
            val appOpsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
            } else {
                null
            }
            if (appOpsManager == null) {
                return false
            }
            val op = 10021
            val method = appOpsManager.javaClass.getMethod(
                "checkOpNoThrow",
                Int::class.java,
                Int::class.java,
                String::class.java
            )
            method.isAccessible = true
            val result =
                method.invoke(
                    appOpsManager,
                    op,
                    android.os.Process.myUid(),
                    context.packageName
                ) as Int
            Log.i(
                TAG,
                "isXiaomiBgStartPermissionAllowed, result: ${AppOpsManager.MODE_ALLOWED == result}"
            )
            return AppOpsManager.MODE_ALLOWED == result
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }
}
