package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomGroupPollReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class CustomPollMessageBean extends TUIMessageBean {

    public class CustomPollMessage implements Serializable {
        public String businessID = TUIConstants.TUIPlugin.BUSINESS_ID_PLUGIN_POLL;
    }

    private CustomPollMessage customPollMessage;

    private Object pollBeanObject;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        TUIChatLog.d("CustomPollMessageBean", "data = " + data);
        if(!TextUtils.isEmpty(data)) {
            try {
                customPollMessage = new Gson().fromJson(data, CustomPollMessage.class);
            } catch (Exception e) {
                TUIChatLog.e("CustomPollMessageBean", "exception e = " + e);
            }
        }
        if (customPollMessage != null) {
            setExtra(TUIChatService.getAppContext().getString(R.string.group_poll_extra));
        } else {
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            setExtra(text);
        }
    }

    public String getText() {
        return getExtra();
    }

    public CustomPollMessage getCustomPollMessage() {
        return customPollMessage;
    }

    public Object getPollBeanObject() {
        return pollBeanObject;
    }

    public void setPollBeanObject(Object pollBeanObject) {
        this.pollBeanObject = pollBeanObject;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return CustomGroupPollReplyQuoteBean.class;
    }
}
