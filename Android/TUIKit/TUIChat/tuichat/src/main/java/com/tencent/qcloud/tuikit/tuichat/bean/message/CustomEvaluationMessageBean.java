package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;
import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomEvaluationMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.Serializable;

public class CustomEvaluationMessageBean extends TUIMessageBean {
    public class CustomEvaluationMessage implements Serializable {
        // public static final int CUSTOM_EVALUATION_ACTION_ID = 4;

        public String businessID = TUIChatConstants.BUSINESS_ID_CUSTOM_EVALUATION;
        public int score = 0;
        public String comment = "";

        public int version = TUIChatConstants.JSON_VERSION_UNKNOWN;
    }

    private CustomEvaluationMessage customEvaluationMessage;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        TUIChatLog.d("CustomEvaluationMessageBean", "data = " + data);
        if (!TextUtils.isEmpty(data)) {
            try {
                customEvaluationMessage = new Gson().fromJson(data, CustomEvaluationMessage.class);
            } catch (Exception e) {
                TUIChatLog.e("CustomEvaluationMessage", "exception e = " + e);
            }
        }
        if (customEvaluationMessage != null) {
            setExtra(TUIChatService.getAppContext().getString(R.string.custom_msg));
        } else {
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            setExtra(text);
        }
    }

    public int getScore() {
        if (customEvaluationMessage != null) {
            return customEvaluationMessage.score;
        }
        return 0;
    }

    public String getContent() {
        if (customEvaluationMessage != null) {
            return customEvaluationMessage.comment;
        }
        return "";
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return CustomEvaluationMessageReplyQuoteBean.class;
    }
}
