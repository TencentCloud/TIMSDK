package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuichat.bean.CallModel;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;

import java.util.Set;

public class CallingTipsMessageBean extends TipsMessageBean {
    private CallModel callModel;

    @Override
    public String onGetDisplayString() {
        return getText();
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


    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return TextReplyQuoteBean.class;
    }

    public void setCallModel(CallModel callModel) {
        this.callModel = callModel;
    }

    public void setUserBean(String userID, UserBean userBean) {
        if (callModel != null) {
            callModel.setParticipant(userID, userBean);
        }
    }

    @Override
    public Set<String> getAdditionalUserIDList() {
        Set<String> userIDSet = super.getAdditionalUserIDList();
        if (callModel != null) {
            userIDSet.addAll(callModel.getParticipantIDs());
        }
        return userIDSet;
    }

    @Override
    public boolean needAsyncGetDisplayString() {
        if (callModel != null) {
            return callModel.getProtocolType() == CallModel.CALL_PROTOCOL_TYPE_TIMEOUT
                    && callModel.getParticipantIDs() != null && !callModel.getParticipantIDs().isEmpty();
        }
        return false;
    }
}
