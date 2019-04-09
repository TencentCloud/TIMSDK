package com.huawei.android.hms.agent.common.handler;

/**
 * 回调接口
 */
public interface ICallbackResult<R> {
    /**
     * 回调接口
     * @param rst 结果码
     * @param result 结果信息
     */
    void onResult(int rst, R result);
}
