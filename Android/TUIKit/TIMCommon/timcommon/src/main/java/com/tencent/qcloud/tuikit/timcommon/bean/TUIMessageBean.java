package com.tencent.qcloud.tuikit.timcommon.bean;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.util.MessageBuilder;
import com.tencent.qcloud.tuikit.timcommon.util.MessageParser;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonConstants;

import java.io.Serializable;

public abstract class TUIMessageBean implements Serializable {
    /**
     * 消息正常状态
     *
     * message normal
     */
    public static final int MSG_STATUS_NORMAL = 0;
    /**
     * 消息发送中状态
     *
     * message sending
     */
    public static final int MSG_STATUS_SENDING = 1;
    /**
     * 消息发送成功状态
     *
     * message send success
     */
    public static final int MSG_STATUS_SEND_SUCCESS = 2;
    /**
     * 消息发送失败状态
     *
     * message send failed
     */
    public static final int MSG_STATUS_SEND_FAIL = 3;

    /**
     * 消息撤回状态
     *
     * messaage revoked
     */
    public static final int MSG_STATUS_REVOKE = 0x113;

    private V2TIMMessage v2TIMMessage;
    private long msgTime;
    private String extra;
    private String id;
    private boolean isGroup;
    private int status;
    private String selectText;
    private boolean excludeFromHistory;
    private boolean isUseMsgReceiverAvatar = false;
    private boolean isEnableForward = true;

    public void setExcludeFromHistory(boolean excludeFromHistory) {
        this.excludeFromHistory = excludeFromHistory;
    }

    public boolean isExcludeFromHistory() {
        return excludeFromHistory;
    }

    public void setUseMsgReceiverAvatar(boolean useMsgReceiverAvatar) {
        isUseMsgReceiverAvatar = useMsgReceiverAvatar;
    }

    public boolean isUseMsgReceiverAvatar() {
        return isUseMsgReceiverAvatar;
    }

    public boolean isEnableForward() {
        return isEnableForward;
    }

    public void setEnableForward(boolean enableForward) {
        isEnableForward = enableForward;
    }

    private MessageReceiptInfo messageReceiptInfo;
    private MessageRepliesBean messageRepliesBean;
    private MessageReactBean messageReactBean;

    public MessageReactBean getMessageReactBean() {
        return messageReactBean;
    }

    public MessageRepliesBean getMessageRepliesBean() {
        return messageRepliesBean;
    }

    public void setMessageReactBean(MessageReactBean messageReactBean) {
        this.messageReactBean = messageReactBean;
        MessageBuilder.mergeCloudCustomData(this, TIMCommonConstants.MESSAGE_REACT_KEY, messageReactBean);
    }

    public void setMessageRepliesBean(MessageRepliesBean messageRepliesBean) {
        this.messageRepliesBean = messageRepliesBean;
        MessageBuilder.mergeCloudCustomData(this, TIMCommonConstants.MESSAGE_REPLIES_KEY, messageRepliesBean);
    }

    public void setMessageReceiptInfo(MessageReceiptInfo messageReceiptInfo) {
        this.messageReceiptInfo = messageReceiptInfo;
    }

    public long getReadCount() {
        if (messageReceiptInfo != null) {
            return messageReceiptInfo.getReadCount();
        }
        return 0;
    }

    public long getUnreadCount() {
        if (messageReceiptInfo != null) {
            return messageReceiptInfo.getUnreadCount();
        }
        return 0;
    }

    public void setCommonAttribute(V2TIMMessage v2TIMMessage) {
        msgTime = System.currentTimeMillis() / 1000;
        this.v2TIMMessage = v2TIMMessage;

        if (v2TIMMessage == null) {
            return;
        }

        id = v2TIMMessage.getMsgID();
        isGroup = !TextUtils.isEmpty(v2TIMMessage.getGroupID());

        if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
            status = MSG_STATUS_REVOKE;
            if (isSelf()) {
                extra = TIMCommonService.getAppContext().getString(R.string.revoke_tips_you);
            } else if (isGroup) {
                String message = TIMCommonConstants.covert2HTMLString(getSender());
                extra = message + TIMCommonService.getAppContext().getString(R.string.revoke_tips);
            } else {
                extra = TIMCommonService.getAppContext().getString(R.string.revoke_tips_other);
            }
        } else {
            if (isSelf()) {
                if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL) {
                    status = MSG_STATUS_SEND_FAIL;
                } else if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_SUCC) {
                    status = MSG_STATUS_SEND_SUCCESS;
                } else if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SENDING) {
                    status = MSG_STATUS_SENDING;
                }
            }
        }

        messageReactBean = MessageParser.parseMessageReact(this);
        messageRepliesBean = MessageParser.parseMessageReplies(this);
    }

    public boolean isPeerRead() {
        if (messageReceiptInfo != null) {
            return messageReceiptInfo.isPeerRead();
        }
        return false;
    }

    public boolean isAllRead() {
        return getUnreadCount() == 0 && getReadCount() > 0;
    }

    public boolean isUnread() {
        return getReadCount() == 0;
    }

    /**
     * 获取要显示在会话列表的消息摘要
     *
     * Get a summary of messages to display in the conversation list
     * @return
     */
    public abstract String onGetDisplayString();

    public abstract void onProcessMessage(V2TIMMessage v2TIMMessage);

    public final long getMessageTime() {
        if (v2TIMMessage != null) {
            long timestamp = v2TIMMessage.getTimestamp();
            if (timestamp != 0) {
                return timestamp;
            }
        }
        return msgTime;
    }

    public long getMsgSeq() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getSeq();
        }
        return 0;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public String getUserId() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getUserID();
        }
        return "";
    }

    public boolean isSelf() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.isSelf();
        }
        return true;
    }

    public String getSender() {
        String sender = null;
        if (v2TIMMessage != null) {
            sender = v2TIMMessage.getSender();
        }
        if (TextUtils.isEmpty(sender)) {
            sender = V2TIMManager.getInstance().getLoginUser();
        }
        return sender;
    }

    public V2TIMMessage getV2TIMMessage() {
        return v2TIMMessage;
    }

    public boolean isGroup() {
        return isGroup;
    }

    public void setGroup(boolean group) {
        isGroup = group;
    }

    public String getGroupId() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getGroupID();
        }
        return "";
    }

    public String getNameCard() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getNameCard();
        }
        return "";
    }

    public String getNickName() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getNickName();
        }
        return "";
    }

    public String getFriendRemark() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getFriendRemark();
        }
        return "";
    }

    public String getUserDisplayName() {
        String displayName;
        if (!TextUtils.isEmpty(getNameCard())) {
            displayName = getNameCard();
        } else if (!TextUtils.isEmpty(getFriendRemark())) {
            displayName = getFriendRemark();
        } else if (!TextUtils.isEmpty(getNickName())) {
            displayName = getNickName();
        } else {
            displayName = getSender();
        }
        return displayName;
    }

    public String getFaceUrl() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getFaceUrl();
        }
        return "";
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getStatus() {
        return status;
    }

    public void setExtra(String extra) {
        this.extra = extra;
    }

    public String getExtra() {
        return extra;
    }

    public int getMsgType() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.getElemType();
        } else {
            return V2TIMMessage.V2TIM_ELEM_TYPE_NONE;
        }
    }

    public boolean isNeedReadReceipt() {
        if (v2TIMMessage != null) {
            return v2TIMMessage.isNeedReadReceipt();
        }
        return false;
    }

    public void setNeedReadReceipt(boolean isNeedReceipt) {
        if (v2TIMMessage != null) {
            v2TIMMessage.setNeedReadReceipt(isNeedReceipt);
        }
    }

    public void setV2TIMMessage(V2TIMMessage v2TIMMessage) {
        this.v2TIMMessage = v2TIMMessage;
        setCommonAttribute(v2TIMMessage);
        onProcessMessage(v2TIMMessage);
    }

    public void update(TUIMessageBean messageBean) {
        setV2TIMMessage(messageBean.getV2TIMMessage());
    }

    public String getSelectText() {
        return selectText;
    }

    public void setSelectText(String text) {
        this.selectText = text;
    }

    public MessageFeature isSupportTyping() {
        return MessageParser.isSupportTyping(this);
    }

    public void setMessageTypingFeature(MessageFeature messageFeature) {
        MessageBuilder.mergeCloudCustomData(this, TIMCommonConstants.MESSAGE_FEATURE_KEY, messageFeature);
    }

    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return null;
    }
}
