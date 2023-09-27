package com.tencent.qcloud.tuicore.permission;

import android.annotation.SuppressLint;
import android.app.AppOpsManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.os.Parcel;
import android.os.Parcelable;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.annotation.Size;
import androidx.core.content.ContextCompat;

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class PermissionRequester {
    private static final String TAG = "PermissionRequester";

    public static final String PERMISSION_NOTIFY_EVENT_KEY = "PERMISSION_NOTIFY_EVENT_KEY";
    public static final String PERMISSION_NOTIFY_EVENT_SUB_KEY = "PERMISSION_NOTIFY_EVENT_SUB_KEY";
    public static final String PERMISSION_RESULT = "PERMISSION_RESULT";
    public static final String PERMISSION_REQUEST_KEY = "PERMISSION_REQUEST_KEY";
    private static final Object sLock = new Object();

    private static AtomicBoolean sIsRequesting = new AtomicBoolean(false);

    private PermissionCallback mPermissionCallback;
    private String[] mPermissions;
    private String mTitle;
    private String mDescription;
    private String mSettingsTip;
    private ITUINotification mPermissionNotification;

    public enum Result { Granted, Denied, Requesting }

    public static final String FLOAT_PERMISSION    = "PermissionOverlayWindows";
    public static final String BG_START_PERMISSION = "PermissionStartActivityFromBackground";

    private List<String> mDirectPermissionList   = new ArrayList<>();
    private List<String> mIndirectPermissionList = new ArrayList<>();

    private PermissionRequester(String... permissions) {
        mPermissions = permissions;
        for (String permission : mPermissions) {
            if (FLOAT_PERMISSION.equals(permission) || BG_START_PERMISSION.equals(permission)) {
                mIndirectPermissionList.add(permission);
            } else {
                mDirectPermissionList.add(permission);
            }
        }

        mPermissionNotification = (key, subKey, param) -> {
            if (param == null) {
                return;
            }
            Object result = param.get(PERMISSION_RESULT);
            if (result == null) {
                return;
            }
            notifyPermissionRequestResult((Result) result);
        };
    }

    /**
     * 生成 PermissionRequester 的实例，其中参数为具体需要申请的权限，可以传入一个或多个权限。
     *
     * @param permissions 需要申请的权限名称。
     * @return PermissionRequester 的实例。
     *
     * Generate an instance of PermissionRequester, where the parameters are the specific permissions that need to be
     * applied for, and one or more permissions can be passed in.
     *
     * @param permissions The name of the permission that needs to be applied for.
     * @return An instance of PermissionRequester.
     */
    public static PermissionRequester newInstance(@NonNull @Size(min = 1) String... permissions) {
        return new PermissionRequester(permissions);
    }

    /**
     * 理由的标题：安全合规要求，请求权限时，须向用户解释为什么需要申请该权限；
     *
     * @param title 理由的标题；
     * @return PermissionRequester 的实例。
     *
     * The title of the reason: security compliance requirements, when requesting permission, you
     * must explain to the user why you need to apply for the permission;
     *
     * @param title The title of the reason;
     * @return An instance of PermissionRequester.
     */
    public PermissionRequester title(@NonNull String title) {
        mTitle = title;
        return this;
    }

    /**
     * 理由的正文：安全合规要求，请求权限时，须向用户解释为什么需要申请该权限；
     *
     * @param description 理由的正文；
     * @return PermissionRequester 的实例。
     *
     * The text of the reason: security compliance requirements, when requesting permission,
     * explain to the user why the permission is required;
     *
     * @param description The text of the reason;
     * @return An instance of PermissionRequester.
     */
    public PermissionRequester description(@NonNull String description) {
        mDescription = description;
        return this;
    }

    /**
     * 向用户说明到 Settings 后需要打开什么权限，以保证功能的正常运行；
     *
     * @param settingsTip 提示用户到设置中做什么；
     * @return PermissionRequester 的实例。
     *
     * Explain to the user what permissions need to be opened after entering the Settings to
     * ensure the normal operation of the function;
     *
     * @param settingsTip Prompt user what to do in settings;
     * @return An instance of PermissionRequester.
     */
    public PermissionRequester settingsTip(@NonNull String settingsTip) {
        mSettingsTip = settingsTip;
        return this;
    }

    /**
     * 设置用于获取权限申请结果的回调。
     *
     * @param callback 权限申请的回调；
     * @return PermissionRequester 的实例。
     *
     * Set the callback used to get the permission application result.
     *
     * @param callback callback for permission application;
     * @return An instance of PermissionRequester.
     */
    public PermissionRequester callback(@NonNull PermissionCallback callback) {
        mPermissionCallback = callback;
        return this;
    }

    /**
     * 开始请求权限。
     *
     * Start requesting permission.
     */
    @SuppressLint("NewApi")
    public void request() {
        Log.i(TAG, "request, directPermissionList: " + mDirectPermissionList
                + " ,indirectPermissionList:  " + mIndirectPermissionList);
        if (mDirectPermissionList != null && mDirectPermissionList.size() > 0) {
            requestDirectPermission(mDirectPermissionList.toArray(new String[0]));
        }
        if (mIndirectPermissionList != null && mIndirectPermissionList.size() > 0) {
            startAppDetailsSettingsByBrand();
        }
    }

    @SuppressLint("NewApi")
    private void requestDirectPermission(String[] permissions) {
        synchronized (sLock) {
            if (sIsRequesting.get()) {
                Log.e(TAG, "can not request during requesting");
                if (mPermissionCallback != null) {
                    mPermissionCallback.onDenied();
                }
                return;
            }
            sIsRequesting.set(true);
        }

        TUICore.registerEvent(PERMISSION_NOTIFY_EVENT_KEY, PERMISSION_NOTIFY_EVENT_SUB_KEY, mPermissionNotification);
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.M) {
            Log.i(TAG, "current version is lower than 23");
            notifyPermissionRequestResult(Result.Granted);
            return;
        }
        String[] unauthorizedPermissions = findUnauthorizedPermissions(permissions);
        if (unauthorizedPermissions.length <= 0) {
            notifyPermissionRequestResult(Result.Granted);
            return;
        }
        RequestData realRequest = new RequestData(mTitle, mDescription, mSettingsTip, unauthorizedPermissions);
        startPermissionActivity(realRequest);
    }

    /**
     * 不支持悬浮窗和后台拉起应用权限 与 麦克风\相机\蓝牙等其他权限一起进行检查
     * <p>
     * Do not support check float permission(or background permission) with microphone(or camera\bluetooth) together
     */
    public boolean has() {
        if (mIndirectPermissionList.contains(BG_START_PERMISSION)) {
            return hasFloatPermission() && hasBgStartPermission();
        } else if (mIndirectPermissionList.contains(FLOAT_PERMISSION)) {
            return hasFloatPermission();
        }

        for (String permission : mDirectPermissionList) {
            if (!has(permission)) {
                return false;
            }
        }
        return true;
    }

    private boolean has(final String permission) {
        return TUIBuild.getVersionInt() < Build.VERSION_CODES.M
            || PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(TUIConfig.getAppContext(), permission);
    }

    private void notifyPermissionRequestResult(Result result) {
        TUICore.unRegisterEvent(PERMISSION_NOTIFY_EVENT_KEY, PERMISSION_NOTIFY_EVENT_SUB_KEY, mPermissionNotification);
        sIsRequesting.set(false);
        if (mPermissionCallback == null) {
            return;
        }
        if (Result.Granted.equals(result)) {
            mPermissionCallback.onGranted();
        } else if (Result.Requesting.equals(result)) {
            mPermissionCallback.onRequesting();
        } else {
            mPermissionCallback.onDenied();
        }
        mPermissionCallback = null;
    }

    private String[] findUnauthorizedPermissions(String[] permissions) {
        Context appContext = TUIConfig.getAppContext();
        if (appContext == null) {
            Log.e(TAG, "findUnauthorizedPermissions appContext is null");
            return permissions;
        }
        List<String> unauthorizedList = new LinkedList<>();
        for (String permission : permissions) {
            if (PackageManager.PERMISSION_GRANTED != ContextCompat.checkSelfPermission(appContext, permission)) {
                unauthorizedList.add(permission);
            }
        }
        return unauthorizedList.toArray(new String[0]);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void startPermissionActivity(RequestData request) {
        Context context = TUIConfig.getAppContext();
        if (context == null) {
            return;
        }
        Intent intent = new Intent(context, PermissionActivity.class);
        intent.putExtra(PERMISSION_REQUEST_KEY, request);
        // 在Activity之外startActivity需要添加FLAG_ACTIVITY_NEW_TASK，否则会crash
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    static class RequestData implements Parcelable {
        private final String[] mPermissions;
        private final String mTitle;
        private final String mDescription;
        private final String mSettingsTip;
        private int mPermissionIconId;

        public RequestData(@NonNull String title, @NonNull String description, @NonNull String settingsTip, @NonNull String... perms) {
            mTitle = title;
            mDescription = description;
            mSettingsTip = settingsTip;
            mPermissions = perms.clone();
        }

        protected RequestData(Parcel in) {
            mPermissions = in.createStringArray();
            mTitle = in.readString();
            mDescription = in.readString();
            mSettingsTip = in.readString();
            mPermissionIconId = in.readInt();
        }

        public static final Creator<RequestData> CREATOR = new Creator<RequestData>() {
            @Override
            public RequestData createFromParcel(Parcel in) {
                return new RequestData(in);
            }

            @Override
            public RequestData[] newArray(int size) {
                return new RequestData[size];
            }
        };

        public boolean isPermissionsExistEmpty() {
            if (mPermissions == null || mPermissions.length <= 0) {
                return true;
            }
            for (String permission : mPermissions) {
                if (TextUtils.isEmpty(permission)) {
                    return true;
                }
            }
            return false;
        }

        public String[] getPermissions() {
            return mPermissions.clone();
        }

        public String getTitle() {
            return mTitle;
        }

        public String getDescription() {
            return mDescription;
        }

        public String getSettingsTip() {
            return mSettingsTip;
        }

        public int getPermissionIconId() {
            return mPermissionIconId;
        }

        public void setPermissionIconId(int permissionIconId) {
            mPermissionIconId = permissionIconId;
        }

        @Override
        public String toString() {
            return "PermissionRequest{"
                + "mPermissions=" + Arrays.toString(mPermissions) + ", mTitle=" + mTitle + ", mDescription='" + mDescription + ", mSettingsTip='" + mSettingsTip
                + '}';
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeStringArray(mPermissions);
            dest.writeString(mTitle);
            dest.writeString(mDescription);
            dest.writeString(mSettingsTip);
            dest.writeInt(mPermissionIconId);
        }
    }

    private void startAppDetailsSettingsByBrand() {
        if (TUIBuild.isBrandVivo()) {
            startVivoPermissionSettings(TUIConfig.getAppContext());
        } else if (TUIBuild.isBrandHuawei()) {
            startHuaweiPermissionSettings(TUIConfig.getAppContext());
        } else if (TUIBuild.isBrandXiaoMi()) {
            startXiaomiPermissionSettings(TUIConfig.getAppContext());
        } else {
            startCommonSettings(TUIConfig.getAppContext());
        }
    }

    private void startCommonSettings(Context context) {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
                intent.setData(Uri.parse("package:" + context.getPackageName()));
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void startVivoPermissionSettings(Context context) {
        try {
            Intent intent = new Intent();
            intent.setClassName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity");
            intent.setAction("secure.intent.action.softPermissionDetail");
            intent.putExtra("packagename", context.getPackageName());
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            ToastUtil.toastShortMessage(context.getResources().getString(R.string.core_float_permission_hint));
        } catch (Exception e) {
            Log.w(TAG, "startVivoPermissionSettings: open common settings");
            startCommonSettings(context);
        }
    }

    private void startHuaweiPermissionSettings(Context context) {
        if (!TUIBuild.isHarmonyOS()) {
            Log.i(TAG, "The device is not Harmony or cannot get system operator");
            startCommonSettings(context);
            return;
        }

        try {
            Intent intent = new Intent();
            intent.putExtra("packageName", context.getPackageName());
            ComponentName comp = new ComponentName("com.huawei.systemmanager",
                    "com.huawei.permissionmanager.ui.MainActivity");
            intent.setComponent(comp);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);

            ToastUtil.toastShortMessage(context.getResources().getString(R.string.core_float_permission_hint));
        } catch (Exception e) {
            Log.w(TAG, "startHuaweiPermissionSettings: open common settings");
            startCommonSettings(context);
        }
    }

    private void startXiaomiPermissionSettings(Context context) {
        if (!TUIBuild.isMiuiOptimization()) {
            Log.i(TAG, "The device do not open miuiOptimization or cannot get miui property");
            startCommonSettings(context);
            return;
        }

        try {
            Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
            intent.setClassName("com.miui.securitycenter",
                    "com.miui.permcenter.permissions.PermissionsEditorActivity");
            intent.putExtra("extra_pkgname", context.getPackageName());
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);

            ToastUtil.toastShortMessage(context.getResources().getString(R.string.core_float_permission_hint));
        } catch (Exception e) {
            Log.w(TAG, "startXiaomiPermissionSettings: open common settings");
            startCommonSettings(context);
        }
    }

    /**
     * 1. 大部分机型,悬浮窗和后台拉起应用是同一个权限;
     * 2. 若小米手机关闭了miui优化,申请权限时会跳转原生界面(该界面无法开启后台拉起应用权限),需用户手动到系统应用管理中开启;
     * <p>
     * 1. For most phone, floating permissions and background permission are the same.
     * 2. If the xiaomi phone has turned off MIUI optimization. When requesting float or background
     * pop-ups permission, it will start Settings.canDrawOverlays which cannot support open background pop-ups
     * permission. You need manually enable the background pop-ups permission in the system application Settings.
     */
    private boolean hasBgStartPermission() {
        if (TUIBuild.isBrandHuawei() && TUIBuild.isHarmonyOS()) {
            return isHarmonyBgStartPermissionAllowed(TUIConfig.getAppContext());
        } else if (TUIBuild.isBrandVivo()) {
            return isVivoBgStartPermissionAllowed(TUIConfig.getAppContext());
        } else if (TUIBuild.isBrandXiaoMi() && TUIBuild.isMiuiOptimization()) {
            return isXiaomiBgStartPermissionAllowed(TUIConfig.getAppContext());
        }

        return hasFloatPermission();
    }

    private boolean hasFloatPermission() {
        try {
            Context context = TUIConfig.getAppContext();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context);
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                AppOpsManager manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
                if (manager == null) {
                    return false;
                }
                Method method = AppOpsManager.class.getMethod("checkOp", int.class, int.class, String.class);
                int result = (Integer) method.invoke(manager, 24, Binder.getCallingUid(), context.getPackageName());
                Log.i(TAG, "hasFloatPermission, result: " + (AppOpsManager.MODE_ALLOWED == result));
                return AppOpsManager.MODE_ALLOWED == result;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean isHarmonyBgStartPermissionAllowed(Context context) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                AppOpsManager manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
                if (manager == null) {
                    return false;
                }
                Class<?> clz = Class.forName("com.huawei.android.app.AppOpsManagerEx");
                Method method = clz.getDeclaredMethod("checkHwOpNoThrow", AppOpsManager.class, int.class, int.class,
                        String.class);
                int result = (int) method.invoke(clz.newInstance(), new Object[]{manager, 100000,
                        android.os.Process.myUid(), context.getPackageName()});
                Log.i(TAG, "isHarmonyBgStartPermissionAllowed, result: " + (result == 0));
                return result == 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean isVivoBgStartPermissionAllowed(Context context) {
        try {
            Uri uri = Uri.parse("content://com.vivo.permissionmanager.provider.permission/start_bg_activity");
            Cursor cursor = context.getContentResolver().query(uri, null, "pkgname = ?",
                    new String[]{context.getPackageName()}, null);
            if (cursor == null) {
                return false;
            }
            if (cursor.moveToFirst()) {
                int result = cursor.getInt(cursor.getColumnIndex("currentstate"));
                cursor.close();
                Log.i(TAG, "isVivoBgStartPermissionAllowed, result: " + (0 == result));
                return 0 == result;
            } else {
                cursor.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean isXiaomiBgStartPermissionAllowed(Context context) {
        try {
            AppOpsManager appOpsManager = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                appOpsManager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            }
            if (appOpsManager == null) {
                return false;
            }
            int op = 10021;
            Method method = appOpsManager.getClass().getMethod("checkOpNoThrow",
                    new Class[]{int.class, int.class, String.class});
            method.setAccessible(true);
            int result = (int) method.invoke(appOpsManager, op, android.os.Process.myUid(), context.getPackageName());
            Log.i(TAG, "isXiaomiBgStartPermissionAllowed, result: " + (AppOpsManager.MODE_ALLOWED == result));
            return AppOpsManager.MODE_ALLOWED == result;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
