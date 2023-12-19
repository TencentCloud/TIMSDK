package com.tencent.qcloud.tuikit.tuichatbotplugin.bean;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichatbotplugin.TUIChatBotPluginService;

import org.json.JSONException;
import org.json.JSONObject;

public class InvisibleMessageBean extends TUIMessageBean {
    public class InvisibleBean {
        public int src = 0;
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
                invisibleBean.src = invisibleJson.optInt(TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_KEY);
            } catch (JSONException e) {
                TUIChatLog.e("InvisibleMessageBean", "exception e = " + e);
            }
        }

        if (invisibleBean != null) {
            if (invisibleBean.src == TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_HELLO_REQUEST) {
                setExtra("");
            } else {
                String text = TUIChatBotPluginService.getAppContext().getString(com.tencent.qcloud.tuikit.timcommon.R.string.timcommon_no_support_msg);
                setExtra(text);
            }
        } else {
            String text = TUIChatBotPluginService.getAppContext().getString(com.tencent.qcloud.tuikit.timcommon.R.string.timcommon_no_support_msg);
            setExtra(text);
        }
    }
}
