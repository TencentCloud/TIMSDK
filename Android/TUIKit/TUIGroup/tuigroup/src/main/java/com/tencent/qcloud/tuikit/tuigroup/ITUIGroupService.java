package com.tencent.qcloud.tuikit.tuigroup;

import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUIGroupService extends ITUIService {

    /**
     * 尚无提供服务
     */
    @Override
    Object onCall(String method, Map<String, Object> param);

}
