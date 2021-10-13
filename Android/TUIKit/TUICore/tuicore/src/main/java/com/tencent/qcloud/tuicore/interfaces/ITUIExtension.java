package com.tencent.qcloud.tuicore.interfaces;

import java.util.Map;

public interface ITUIExtension {
    Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param);
}
