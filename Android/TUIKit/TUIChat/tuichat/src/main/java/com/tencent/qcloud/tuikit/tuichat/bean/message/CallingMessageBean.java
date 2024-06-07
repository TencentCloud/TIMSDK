package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuichat.bean.CallModel;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;

import java.util.List;
import java.util.Set;

public class CallingMessageBean extends TextMessageBean {
    private CallModel callModel;
    private int callType; // 1：audio; 2:video
    private boolean isCaller;
    private String sender;
    private boolean isShowUnreadPoint;
    public static final int ACTION_ID_AUDIO_CALL = 1;
    public static final int ACTION_ID_VIDEO_CALL = 2;

    @Override
    public String onGetDisplayString() {
        if (callModel != null) {
            return callModel.getContent();
        }
        return "";
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
    }

    @Override
    public String getText() {
        if (callModel != null) {
            return callModel.getContent();
        }
        return "";
    }

    @Override
    public String getExtra() {
        if (callModel != null) {
            return callModel.getContent();
        }
        return "";
    }

    public int getCallType() {
        return callType;
    }

    public void setCallType(int callType) {
        this.callType = callType;
    }

    public void setCaller(boolean isCaller) {
        this.isCaller = isCaller;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public void setShowUnreadPoint(boolean show) {
        this.isShowUnreadPoint = show;
    }

    public boolean isShowUnreadPoint() {
        return isShowUnreadPoint;
    }

    @Override
    public boolean isSelf() {
        return isCaller;
    }

    @Override
    public String getSender() {
        if (!TextUtils.isEmpty(sender)) {
            return this.sender;
        }
        return super.getSender();
    }

    public void setCallModel(CallModel callModel) {
        this.callModel = callModel;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return TextReplyQuoteBean.class;
    }
}
