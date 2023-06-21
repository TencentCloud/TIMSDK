package com.tencent.cloud.tuikit.roomkit.model.manager;

import android.util.Log;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.roomkit.model.entity.ExtensionSettingEntity;
import com.tencent.qcloud.tuicore.util.SPUtils;

public class ExtensionSettingManager {
    private static final String TAG                = "ExtensionSettingManager";
    private static final String PER_DATA           = "per_setting_manager";
    private static final String PER_SETTING_ENTITY = "per_setting_entity";

    private static ExtensionSettingManager sInstance;

    private ExtensionSettingEntity mEntity;

    public static ExtensionSettingManager getInstance() {
        if (sInstance == null) {
            synchronized (ExtensionSettingManager.class) {
                if (sInstance == null) {
                    sInstance = new ExtensionSettingManager();
                }
            }
        }
        return sInstance;
    }

    public synchronized ExtensionSettingEntity getExtensionSetting() {
        if (mEntity == null) {
            loadSetting();
        }
        return mEntity == null ? new ExtensionSettingEntity() : mEntity;
    }

    public synchronized void setExtensionSetting(ExtensionSettingEntity entity) {
        mEntity = entity;
        try {
            Gson gson = new Gson();
            SPUtils.getInstance(PER_DATA).put(PER_SETTING_ENTITY, gson.toJson(mEntity));
        } catch (Exception e) {
            Log.d(TAG, "");
        }
    }

    private void loadSetting() {
        try {
            String json = SPUtils.getInstance(PER_DATA).getString(PER_SETTING_ENTITY);
            Gson gson = new Gson();
            mEntity = gson.fromJson(json, ExtensionSettingEntity.class);
        } catch (Exception e) {
            Log.d(TAG, "loadSetting failed:" + e.getMessage());
        }
    }
}
