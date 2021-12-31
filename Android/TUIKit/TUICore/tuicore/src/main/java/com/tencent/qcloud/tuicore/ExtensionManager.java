package com.tencent.qcloud.tuicore;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * 页面扩展注册和获取
 */
class ExtensionManager {
    private static final String TAG = ExtensionManager.class.getSimpleName();

    private static class ExtensionManagerHolder {
        private static final ExtensionManager extensionManager = new ExtensionManager();
    }

    public static ExtensionManager getInstance() {
        return ExtensionManagerHolder.extensionManager;
    }

    private final Map<String, List<ITUIExtension>>  extensionHashMap = new ConcurrentHashMap<>();

    private ExtensionManager() {}

    public void registerExtension(String key, ITUIExtension extension) {
        Log.i(TAG, "registerExtension key : " + key + ", extension : " + extension);
        if (TextUtils.isEmpty(key) || extension == null) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            list = new CopyOnWriteArrayList<>();
            extensionHashMap.put(key, list);
        }
        if (!list.contains(extension)) {
            list.add(extension);
        }
    }

    public void unRegisterExtension(String key, ITUIExtension extension) {
        Log.i(TAG, "removeExtension key : " + key + ", extension : " + extension);
        if (TextUtils.isEmpty(key) || extension == null) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            return;
        }
        list.remove(extension);
    }

    public Map<String, Object> getExtensionInfo(String key, Map<String, Object> param) {
        Log.i(TAG, "getExtensionInfo key : " + key );
        if (TextUtils.isEmpty(key)) {
            return null;
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            return null;
        }
        for(ITUIExtension extension : list) {
            return extension.onGetExtensionInfo(key, param);
        }
        return null;
    }
}
