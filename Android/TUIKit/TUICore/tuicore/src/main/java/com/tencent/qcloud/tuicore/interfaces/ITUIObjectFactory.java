package com.tencent.qcloud.tuicore.interfaces;

import java.util.Map;

public interface ITUIObjectFactory {
    Object onCreateObject(String objectName, Map<String, Object> param);
}
