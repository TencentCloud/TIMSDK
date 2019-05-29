package com.huawei.android.hms.agent.common;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import com.huawei.android.hms.agent.HMSAgent;
import com.huawei.android.hms.agent.common.handler.CheckUpdateHandler;
import com.huawei.hms.api.CheckUpdatelistener;
import com.huawei.hms.api.HuaweiApiClient;

/**
 * 应用自升级
 */
public class CheckUpdateApi extends BaseApiAgent implements CheckUpdatelistener {

    /**
     * 应用自升级回调接口
     */
    private CheckUpdateHandler handler;

    /**
     * 升级传入的activity
     */
    private Activity activity;

    /**
     * Huawei Api Client 连接回调
     * @param rst 结果码
     * @param client HuaweiApiClient 实例
     */
    @Override
    public void onConnect(int rst, HuaweiApiClient client) {

        HMSAgentLog.d("onConnect:" + rst);

        Activity activityCur = ActivityMgr.INST.getLastActivity();

        if (activityCur != null && client != null) {
            client.checkUpdate(activityCur, this);
        } else if (activity != null && client != null){
            client.checkUpdate(activity, this);
        } else {
            // 跟SE确认：activity 为 null ， 不处理 | Activity is null and does not need to be processed
            HMSAgentLog.e("no activity to checkUpdate");
            onCheckUpdateResult(HMSAgent.AgentResultCode.NO_ACTIVITY_FOR_USE);
            return;
        }
    }

    @Override
    public void onResult(int resultCode) {
        onCheckUpdateResult(resultCode);
    }

    private void onCheckUpdateResult(int retCode){
        HMSAgentLog.i("checkUpdate:callback=" + StrUtils.objDesc(handler) +" retCode=" + retCode);
        if (handler != null) {
            new Handler(Looper.getMainLooper()).post(new CallbackCodeRunnable(handler, retCode));
            handler = null;
        }

        activity = null;
    }

    /**
     * 应用自升级接口
     * @param handler 应用自升级结果回调
     */
    public void checkUpdate(Activity activity, CheckUpdateHandler handler) {
        HMSAgentLog.i("checkUpdate:handler=" + StrUtils.objDesc(handler));
        this.handler = handler;
        this.activity = activity;
        connect();
    }
}
