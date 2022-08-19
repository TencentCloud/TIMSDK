package com.tencent.qcloud.tuikit.tuigroup;

import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUIGroupService extends ITUIService {

    @Override
    Object onCall(String method, Map<String, Object> param);

}
