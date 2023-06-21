package com.tencent.qcloud.tuicore;

import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * UI extension registration and acquisition
 */
class ExtensionManager {
    private static final String TAG = ExtensionManager.class.getSimpleName();

    private static class ExtensionManagerHolder {
        private static final ExtensionManager extensionManager = new ExtensionManager();
    }

    public static ExtensionManager getInstance() {
        return ExtensionManagerHolder.extensionManager;
    }

    private final Map<String, List<ITUIExtension>> extensionHashMap = new ConcurrentHashMap<>();

    private ExtensionManager() {}

    public void registerExtension(String extensionID, ITUIExtension extension) {
        Log.i(TAG, "registerExtension extensionID : " + extensionID + ", extension : " + extension);
        if (TextUtils.isEmpty(extensionID) || extension == null) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(extensionID);
        if (list == null) {
            list = new CopyOnWriteArrayList<>();
            extensionHashMap.put(extensionID, list);
        }
        if (!list.contains(extension)) {
            list.add(extension);
        }
    }

    public void unRegisterExtension(String extensionID, ITUIExtension extension) {
        Log.i(TAG, "removeExtension extensionID : " + extensionID + ", extension : " + extension);
        if (TextUtils.isEmpty(extensionID) || extension == null) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(extensionID);
        if (list == null) {
            return;
        }
        list.remove(extension);
    }

    @Deprecated
    public Map<String, Object> getExtensionInfo(String key, Map<String, Object> param) {
        Log.i(TAG, "getExtensionInfo key : " + key);
        if (TextUtils.isEmpty(key)) {
            return null;
        }
        List<ITUIExtension> list = extensionHashMap.get(key);
        if (list == null) {
            return null;
        }
        for (ITUIExtension extension : list) {
            return extension.onGetExtensionInfo(key, param);
        }
        return null;
    }

    public List<TUIExtensionInfo> getExtensionList(String extensionID, Map<String, Object> param) {
        Log.i(TAG, "getExtensionInfoList extensionID : " + extensionID);
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        if (TextUtils.isEmpty(extensionID)) {
            return extensionInfoList;
        }
        List<ITUIExtension> ituiExtensionList = extensionHashMap.get(extensionID);
        if (ituiExtensionList == null || ituiExtensionList.isEmpty()) {
            return extensionInfoList;
        }
        for (ITUIExtension ituiExtension : ituiExtensionList) {
            List<TUIExtensionInfo> extensionInfo = ituiExtension.onGetExtension(extensionID, param);
            if (extensionInfo != null) {
                extensionInfoList.addAll(extensionInfo);
            }
        }
        return extensionInfoList;
    }

    public void raiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        Log.i(TAG, "raiseExtension extensionID : " + extensionID);
        if (TextUtils.isEmpty(extensionID)) {
            return;
        }
        List<ITUIExtension> list = extensionHashMap.get(extensionID);
        if (list == null) {
            return;
        }
        for (ITUIExtension extension : list) {
            extension.onRaiseExtension(extensionID, parentView, param);
            return;
        }
    }
}
