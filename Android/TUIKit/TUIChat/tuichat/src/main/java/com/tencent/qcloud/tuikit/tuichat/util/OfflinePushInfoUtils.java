package com.tencent.qcloud.tuikit.tuichat.util;

import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflinePushInfo;

public class OfflinePushInfoUtils {
    public static V2TIMOfflinePushInfo convertOfflinePushInfoToV2PushInfo(OfflinePushInfo offlinePushInfo) {
        if (offlinePushInfo == null) {
            return null;
        }
        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setTitle(offlinePushInfo.getTitle());
        v2TIMOfflinePushInfo.setDesc(offlinePushInfo.getDescription());
        v2TIMOfflinePushInfo.setExt(offlinePushInfo.getExtension());
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID(offlinePushInfo.getOppoChannelID());
        v2TIMOfflinePushInfo.setAndroidVIVOClassification(offlinePushInfo.getVivoClassification());
        v2TIMOfflinePushInfo.setIOSSound(offlinePushInfo.getSoundFilePath());
        v2TIMOfflinePushInfo.setIgnoreIOSBadge(offlinePushInfo.isIgnoreIOSBadge());
        return v2TIMOfflinePushInfo;
    }
}
