package com.huawei.android.hms.agent.common;

import com.huawei.hms.api.HuaweiApiClient;

/**
 * 连接client空回调
 */
public class EmptyConnectCallback implements IClientConnectCallback {

    private String msgPre;

    public EmptyConnectCallback(String msgPre){
        this.msgPre = msgPre;
    }

    /**
     * HuaweiApiClient 连接结果回调
     *
     * @param rst    结果码
     * @param client HuaweiApiClient 实例
     */
    @Override
    public void onConnect(int rst, HuaweiApiClient client) {
        HMSAgentLog.d(msgPre + rst);
    }
}