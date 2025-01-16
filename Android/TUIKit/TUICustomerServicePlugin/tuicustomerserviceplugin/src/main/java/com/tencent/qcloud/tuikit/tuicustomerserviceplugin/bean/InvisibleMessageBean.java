package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServicePluginService;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;

public class InvisibleMessageBean extends TUIMessageBean {
    public static class InvisibleBean implements Serializable {
        public String src = "";

        // Satisfaction Setting
        // Indicates that users can actively initiate evaluations.
        public final int RULE_USER_TRIGGER_EVALUATION = 1 << 2;
        public static final String MENU_SEND_RULE_FLAG = "menuSendRuleFlag";
        public int menuSendRuleFlag;
    }

    private InvisibleBean invisibleBean;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        if (!TextUtils.isEmpty(data)) {
            invisibleBean = new InvisibleBean();
            try {
                JSONObject invisibleJson = new JSONObject(data);
                invisibleBean.src = invisibleJson.optString(TUIConstants.TUICustomerServicePlugin.CUSTOMER_SERVICE_BUSINESS_ID_SRC_KEY);
                JSONObject contentJson = invisibleJson.optJSONObject(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT);
                if (contentJson != null) {
                    invisibleBean.menuSendRuleFlag = contentJson.optInt(InvisibleBean.MENU_SEND_RULE_FLAG);
                }
            } catch (JSONException e) {
                TUIChatLog.e("InvisibleMessageBean", "exception e = " + e);
            }
        }

        if (invisibleBean != null) {
            if (invisibleBean.src.equals(TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_EVALUATION_SELECTED)) {
                setExtra(TUIChatService.getAppContext().getString(R.string.satisfaction_evaluation));
            } else if (invisibleBean.src.equals(TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_END)) {
                setExtra(TUIChatService.getAppContext().getString(R.string.session_end));
            } else if (invisibleBean.src.equals(TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_TIMEOUT)) {
                setExtra(TUIChatService.getAppContext().getString(R.string.session_timeout));
            } else if (invisibleBean.src.equals(TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_EVALUATION_SETTING)) {
                int triggerResult = invisibleBean.menuSendRuleFlag & invisibleBean.RULE_USER_TRIGGER_EVALUATION;
                TUICustomerServicePluginService.getInstance().setCanTriggerEvaluation(triggerResult > 0 ? true : false);
            } else if (invisibleBean.src.equals(TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_TRIGGER_EVALUATION)) {
            } else if (invisibleBean.src.equals(TUIConstants.TUICustomerServicePlugin.BUSINESS_ID_SRC_CUSTOMER_SERVICE_SAY_HELLO)) {
            } else {
                String text = TUICustomerServicePluginService.getAppContext().getString(com.tencent.qcloud.tuikit.timcommon.R.string.timcommon_no_support_msg);
                setExtra(text);
            }
        } else {
            String text = TUICustomerServicePluginService.getAppContext().getString(com.tencent.qcloud.tuikit.timcommon.R.string.timcommon_no_support_msg);
            setExtra(text);
        }
    }
}
