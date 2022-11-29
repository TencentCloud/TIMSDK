package com.tencent.qcloud.tuikit.tuichat.bean.message;


import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomOrderMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class CustomOrderMessageBean extends TUIMessageBean{

    public class CustomOrderMessage implements Serializable {
        //public static final int CUSTOM_EVALUATION_ACTION_ID = 5;

        public String businessID = TUIChatConstants.BUSINESS_ID_CUSTOM_ORDER;
        public String imageUrl = "";
        public String title = "";
        public String description = "";
        public String price = "";
        public String link = "";

        public int version = TUIChatConstants.JSON_VERSION_UNKNOWN;
    }

    private CustomOrderMessage orderMessage;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        TUIChatLog.d("CustomOrderMessageBean", "data = " + data);
        if(!TextUtils.isEmpty(data)) {
            try {
                orderMessage = new Gson().fromJson(data, CustomOrderMessage.class);
            } catch (Exception e) {
                TUIChatLog.e("CustomOrderMessageBean", "exception e = " + e);
            }
        }
        if (orderMessage != null) {
            setExtra(TUIChatService.getAppContext().getString(R.string.custom_msg));
        } else {
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            setExtra(text);
        }
    }

    public String getImageUrl() {
        if (orderMessage != null) {
            return orderMessage.imageUrl;
        }
        return "";
    }

    public String getDescription() {
        if (orderMessage != null) {
            return orderMessage.description;
        }
        return "";
    }

    public String getTitle() {
        if (orderMessage != null) {
            return orderMessage.title;
        }
        return "";
    }

    public String getPrice() {
        if (orderMessage != null) {
            return orderMessage.price;
        }
        return "";
    }

    public String getLink() {
        if (orderMessage != null) {
            return orderMessage.link;
        }
        return "";
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return CustomOrderMessageReplyQuoteBean.class;
    }
}
