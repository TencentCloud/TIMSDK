package com.tencent.qcloud.tuicore.interfaces;

import java.util.Map;

public interface ITUIService {
    default Object onCall(String method, Map<String, Object> param) {
        return null;
    }

    default Object onCall(String method, Map<String, Object> param, TUIServiceCallback callback) {
        return null;
    }
}
