package com.tencent.cloud.tuikit.roomkit.utils;

import android.Manifest;
import android.content.Context;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.utils.CommonUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;

public class RoomPermissionUtil {
    public static void requestCameraPermission(Context context, PermissionCallback callback) {
        String title =
                context.getString(R.string.tuiroomkit_permission_camera_reason_title, CommonUtils.getAppName(context));
        String description = (String) TUICore.createObject(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null);
        description = TextUtils.isEmpty(description) ? context.getString(R.string.tuiroomkit_permission_camera_reason) :
                description;

        String tip = (String) TUICore.createObject(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS_TIP, null);
        tip = TextUtils.isEmpty(tip) ? context.getString(R.string.tuiroomkit_tips_start_camera) : tip;

        PermissionRequester.newInstance(Manifest.permission.CAMERA)
                .title(title)
                .description(description)
                .settingsTip(tip)
                .callback(callback)
                .request();
    }

    public static void requestAudioPermission(Context context, PermissionCallback callback) {
        String title =
                context.getString(R.string.tuiroomkit_permission_mic_reason_title, CommonUtils.getAppName(context));
        String description = (String) TUICore.createObject(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS, null);
        description = TextUtils.isEmpty(description) ? context.getString(R.string.tuiroomkit_permission_mic_reason) :
                description;

        String tip = (String) TUICore.createObject(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS_TIP, null);
        tip = TextUtils.isEmpty(tip) ? context.getString(R.string.tuiroomkit_tips_start_audio) : tip;

        PermissionRequester.newInstance(Manifest.permission.RECORD_AUDIO)
                .title(title)
                .description(description)
                .settingsTip(tip)
                .callback(callback)
                .request();
    }
}
