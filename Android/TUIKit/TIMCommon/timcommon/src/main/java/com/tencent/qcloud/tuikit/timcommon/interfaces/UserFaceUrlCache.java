package com.tencent.qcloud.tuikit.timcommon.interfaces;

public interface UserFaceUrlCache {

    String getCachedFaceUrl(String userID);

    void pushFaceUrl(String userID, String faceUrl);
}
