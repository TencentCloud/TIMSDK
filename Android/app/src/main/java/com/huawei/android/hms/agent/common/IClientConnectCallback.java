package com.huawei.android.hms.agent.common;

import com.huawei.hms.api.HuaweiApiClient;

/**
 * HuaweiApiClient 连接结果回调
 */
public interface IClientConnectCallback {
    /**
     * HuaweiApiClient 连接结果回调
     * @param rst 结果码
     * @param client HuaweiApiClient 实例
     */
    void onConnect(int rst, HuaweiApiClient client);
}
