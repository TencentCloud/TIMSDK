package com.huawei.android.hms.agent.common;

/**
 * API 实现类基类，用于处理公共操作
 * 目前实现的是client的连接及回调
 */
public abstract class BaseApiAgent implements IClientConnectCallback {
    protected void connect() {
        HMSAgentLog.d("connect");
        ApiClientMgr.INST.connect(this, true);
    }
}
