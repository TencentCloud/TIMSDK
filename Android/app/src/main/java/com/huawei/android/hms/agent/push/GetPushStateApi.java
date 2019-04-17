package com.huawei.android.hms.agent.push;

import android.os.Handler;
import android.os.Looper;

import com.huawei.android.hms.agent.HMSAgent;
import com.huawei.android.hms.agent.common.ApiClientMgr;
import com.huawei.android.hms.agent.common.BaseApiAgent;
import com.huawei.android.hms.agent.common.CallbackCodeRunnable;
import com.huawei.android.hms.agent.common.HMSAgentLog;
import com.huawei.android.hms.agent.common.StrUtils;
import com.huawei.android.hms.agent.common.ThreadUtil;
import com.huawei.android.hms.agent.push.handler.GetPushStateHandler;
import com.huawei.hms.api.HuaweiApiClient;
import com.huawei.hms.support.api.push.HuaweiPush;

/**
 * 获取push状态的接口。
 */
public class GetPushStateApi extends BaseApiAgent {

    /**
     * 调用接口回调
     */
    private GetPushStateHandler handler;

    /**
     * HuaweiApiClient 连接结果回调
     *
     * @param rst    结果码
     * @param client HuaweiApiClient 实例
     */
    @Override
    public void onConnect(final int rst, final HuaweiApiClient client) {
        //需要在子线程中执行获取push状态的操作
        ThreadUtil.INST.excute(new Runnable() {
            @Override
            public void run() {
                if (client == null || !ApiClientMgr.INST.isConnect(client)) {
                    HMSAgentLog.e("client not connted");
                    onGetPushStateResult(rst);
                } else {
                    HuaweiPush.HuaweiPushApi.getPushState(client);
                    onGetPushStateResult(HMSAgent.AgentResultCode.HMSAGENT_SUCCESS);
                }
            }
        });
    }

    void onGetPushStateResult(int rstCode) {
        HMSAgentLog.i("getPushState:callback=" + StrUtils.objDesc(handler) +" retCode=" + rstCode);
        if (handler != null) {
            new Handler(Looper.getMainLooper()).post(new CallbackCodeRunnable(handler, rstCode));
            handler = null;
        }
    }

    /**
     * 获取push状态，push状态的回调通过广播发送。
     * 要监听的广播，请参见HMS-SDK开发准备中PushReceiver的注册
     */
    public void getPushState(GetPushStateHandler handler) {
        HMSAgentLog.i("getPushState:handler=" + StrUtils.objDesc(handler));
        this.handler = handler;
        connect();
    }
}
