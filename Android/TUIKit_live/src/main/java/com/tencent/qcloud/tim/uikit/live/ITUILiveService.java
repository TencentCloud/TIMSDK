package com.tencent.qcloud.tim.uikit.live;

import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUILiveService extends ITUIService, ITUIExtension, ITUINotification {
    @Override
    Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param);

    @Override
    Object onCall(String method, Map<String, Object> param);

    @Override
    void onNotifyEvent(String key, String subKey, Map<String, Object> param);

}
