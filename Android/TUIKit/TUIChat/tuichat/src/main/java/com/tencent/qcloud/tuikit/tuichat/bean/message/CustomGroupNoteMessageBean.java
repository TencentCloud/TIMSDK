package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomGroupNoteReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class CustomGroupNoteMessageBean extends TUIMessageBean{

    public class CustomGroupNoteMessage implements Serializable {
        public String businessID = TUIConstants.TUIPlugin.BUSINESS_ID_PLUGIN_GROUP_NOTE;
    }

    private CustomGroupNoteMessage customGroupNoteMessage;

    private Object groupNoteBeanObject;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        TUIChatLog.d("CustomGroupNoteMessageBean", "data = " + data);
        if(!TextUtils.isEmpty(data)) {
            try {
                customGroupNoteMessage = new Gson().fromJson(data, CustomGroupNoteMessage.class);
            } catch (Exception e) {
                TUIChatLog.e("CustomGroupNoteMessageBean", "exception e = " + e);
            }
        }
        if (customGroupNoteMessage != null) {
            setExtra(TUIChatService.getAppContext().getString(R.string.group_note_extra));
        } else {
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            setExtra(text);
        }
    }

    public String getText() {
        return getExtra();
    }

    public CustomGroupNoteMessage getCustomGroupNoteMessage() {
        return customGroupNoteMessage;
    }

    public Object getGroupNoteBeanObject() {
        return groupNoteBeanObject;
    }

    public void setGroupNoteBeanObject(Object groupNoteBeanObject) {
        this.groupNoteBeanObject = groupNoteBeanObject;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return CustomGroupNoteReplyQuoteBean.class;
    }
}
