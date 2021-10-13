package com.tencent.qcloud.tuicore.interfaces;

import java.util.Map;

public interface ITUIService {
    Object onCall(String method, Map<String, Object> param);
}
