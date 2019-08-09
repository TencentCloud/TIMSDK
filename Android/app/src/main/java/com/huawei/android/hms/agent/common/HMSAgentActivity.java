package com.huawei.android.hms.agent.common;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.huawei.android.hms.agent.HMSAgent;
import com.huawei.hms.api.HuaweiApiAvailability;

/**
 * 代理Activity，用于弹出解决问题的引导
 */
public class HMSAgentActivity extends BaseAgentActivity {

    /**
     * 参数标签，用于取得要解决的错误码
     */
    public static final String CONN_ERR_CODE_TAG = "HMSConnectionErrorCode";

    /**
     * 解决错误后结果的标签，用来取得解决的结果
     */
    public static final String EXTRA_RESULT = "intent.extra.RESULT";

    /**
     * 解决错误的requestCode
     */
    private static final int REQUEST_HMS_RESOLVE_ERROR = 1000;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ApiClientMgr.INST.onActivityLunched();

        Intent intent = getIntent();
        if (intent != null) {
            int rstCode =  intent.getIntExtra(CONN_ERR_CODE_TAG, 0);
            HMSAgentLog.d("dispose code:" + rstCode);
            HuaweiApiAvailability.getInstance().resolveError(this, rstCode, REQUEST_HMS_RESOLVE_ERROR);
        } else {
            HMSAgentLog.e("intent is null");
            finish();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if(requestCode == REQUEST_HMS_RESOLVE_ERROR) {
            if(resultCode == Activity.RESULT_OK) {
                int result = data.getIntExtra(EXTRA_RESULT, -1);
                HMSAgentLog.d("dispose result:" + result);
                ApiClientMgr.INST.onResolveErrorRst(result);
            } else {
                HMSAgentLog.e("dispose error:" + resultCode);
                ApiClientMgr.INST.onResolveErrorRst(HMSAgent.AgentResultCode.ON_ACTIVITY_RESULT_ERROR);
            }
            finish();
        }
    }
}
