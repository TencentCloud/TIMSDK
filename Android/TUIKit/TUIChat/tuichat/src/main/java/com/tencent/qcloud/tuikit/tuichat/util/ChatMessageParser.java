package com.tencent.qcloud.tuikit.tuichat.util;

import android.content.Context;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.CallModel;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageCustom;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageFeature;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageTyping;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.LocationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatMessageParser {
    private static final String TAG = ChatMessageParser.class.getSimpleName();

    public static TUIMessageBean parseMessage(V2TIMMessage v2TIMMessage) {
        return parseMessage(v2TIMMessage, false);
    }

    public static TUIMessageBean parseMessage(V2TIMMessage v2TIMMessage, boolean isIgnoreReply) {
        if (v2TIMMessage == null) {
            return null;
        }
        if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED || v2TIMMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_NONE) {
            return null;
        }
        TUIMessageBean message = null;
        if (!isIgnoreReply) {
            message = parseReplyMessage(v2TIMMessage);
        }
        if (message == null) {
            int msgType = v2TIMMessage.getElemType();
            switch (msgType) {
                case V2TIMMessage.V2TIM_ELEM_TYPE_TEXT:
                    message = new TextMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE:
                    message = new ImageMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_SOUND:
                    message = new SoundMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO:
                    message = new VideoMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_FILE:
                    message = new FileMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION:
                    message = new LocationMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_FACE:
                    message = new FaceMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS:
                    message = new TipsMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_MERGER:
                    message = new MergeMessageBean();
                    break;
                case V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM:
                    message = parseCustomMessage(v2TIMMessage);
                    break;
                default:
                    break;
            }
        }
        if (message != null) {
            message.setCommonAttribute(v2TIMMessage);
            message.onProcessMessage(v2TIMMessage);
        }
        return message;
    }

    private static TUIMessageBean parseCustomMessage(V2TIMMessage v2TIMMessage) {
        TUIMessageBean messageBean = parseCallingMessage(v2TIMMessage);
        if (messageBean == null) {
            messageBean = parseGroupCreateMessage(v2TIMMessage);
        }
        if (messageBean == null) {
            messageBean = parseCustomMessageFromMap(v2TIMMessage);
        }
        if (messageBean == null) {
            messageBean = new TextMessageBean();
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            ((TextMessageBean) messageBean).setText(text);
        }
        return messageBean;
    }

    private static TUIMessageBean parseCustomMessageFromMap(V2TIMMessage v2TIMMessage) {
        String businessId = getCustomBusinessId(v2TIMMessage);
        Class<? extends TUIMessageBean> messageBeanClazz = TUIChatService.getInstance().getMessageBeanClass(businessId);
        if (messageBeanClazz != null) {
            try {
                return messageBeanClazz.newInstance();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InstantiationException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    private static TUIMessageBean parseReplyMessage(V2TIMMessage v2TIMMessage) {
        String cloudCustomData = v2TIMMessage.getCloudCustomData();
        if (TextUtils.isEmpty(cloudCustomData)) {
            return null;
        }
        try {
            Gson gson = new Gson();
            HashMap replyHashMap = gson.fromJson(cloudCustomData, HashMap.class);
            if (replyHashMap != null) {
                Object replyContentObj = replyHashMap.get(TUIChatConstants.MESSAGE_REPLY_KEY);
                ReplyPreviewBean replyPreviewBean = null;
                if (replyContentObj instanceof Map) {
                    replyPreviewBean = gson.fromJson(gson.toJson(replyContentObj), ReplyPreviewBean.class);
                }
                if (replyPreviewBean != null) {
                    if (replyPreviewBean.getVersion() > ReplyPreviewBean.VERSION) {
                        return null;
                    }
                    if (TextUtils.isEmpty(replyPreviewBean.getMessageRootID())) {
                        return new QuoteMessageBean(replyPreviewBean);
                    } else {
                        return new ReplyMessageBean(replyPreviewBean);
                    }
                }
            }
        } catch (JsonSyntaxException e) {
            TUIChatLog.e(TAG, " getCustomJsonMap error ");
        }
        return null;
    }

    public static MessageReactBean parseMessageReact(TUIMessageBean messageBean) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        String cloudCustomData = message.getCloudCustomData();

        try {
            Gson gson = new Gson();
            HashMap hashMap = gson.fromJson(cloudCustomData, HashMap.class);
            if (hashMap != null) {
                Object reactContentObj = hashMap.get(TUIChatConstants.MESSAGE_REACT_KEY);
                MessageReactBean reactBean = null;
                if (reactContentObj instanceof Map) {
                    reactBean = gson.fromJson(gson.toJson(reactContentObj), MessageReactBean.class);
                }
                if (reactBean != null) {
                    if (reactBean.getVersion() > MessageReactBean.VERSION) {
                        return null;
                    }
                    return reactBean;
                }
            }
        } catch (JsonSyntaxException e) {
            TUIChatLog.e(TAG, " getCustomJsonMap error ");
        }
        return null;
    }

    public static MessageRepliesBean parseMessageReplies(TUIMessageBean messageBean) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        String cloudCustomData = message.getCloudCustomData();

        try {
            Gson gson = new Gson();
            HashMap hashMap = gson.fromJson(cloudCustomData, HashMap.class);
            if (hashMap != null) {
                Object repliesContentObj = hashMap.get(TUIChatConstants.MESSAGE_REPLIES_KEY);
                MessageRepliesBean repliesBean = null;
                if (repliesContentObj instanceof Map) {
                    repliesBean = gson.fromJson(gson.toJson(repliesContentObj), MessageRepliesBean.class);
                }
                if (repliesBean != null) {
                    if (repliesBean.getVersion() > MessageRepliesBean.VERSION) {
                        return null;
                    }
                    return repliesBean;
                }
            }
        } catch (JsonSyntaxException e) {
            TUIChatLog.e(TAG, " getCustomJsonMap error ");
        }
        return null;
    }

    public static boolean isTyping(byte[] data) {
        try {
            String str = new String(data, "UTF-8");
            MessageTyping typing = new Gson().fromJson(str, MessageTyping.class);
            if (typing != null
                    && typing.userAction == MessageTyping.TYPE_TYPING
                    && TextUtils.equals(typing.actionParam, MessageTyping.EDIT_START)) {
                return true;
            }
            return false;
        } catch (Exception e) {
            TUIChatLog.e(TAG, "parse json error");
        }
        return false;
    }

    private static String getCustomBusinessId(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem =  v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            return null;
        }
        String data = new String(customElem.getData());

        Gson gson = new Gson();
        HashMap customJsonMap = null;
        try {
            customJsonMap = gson.fromJson(data, HashMap.class);
        } catch (JsonSyntaxException e) {
            TUIChatLog.e(TAG, " getCustomJsonMap error ");
        }
        String businessId = null;
        Object businessIdObj = null;
        if (customJsonMap != null) {
            businessIdObj = customJsonMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
        }
        if (businessIdObj instanceof String) {
            businessId = (String) businessIdObj;
        }
        return businessId;
    }

    /**
     * 把 IMSDK 的消息 bean 列表转化为 TUIKit 的消息bean列表
     * 
     * Convert IMSDK's message bean list to TUIKit's message bean list
     *
     * @param v2TIMMessageList IMSDK 的消息 bean 列表
     * @return 转换后的 TUIKit bean 列表
     */
    public static List<TUIMessageBean> parseMessageList(List<V2TIMMessage> v2TIMMessageList) {
        if (v2TIMMessageList == null) {
            return null;
        }
        List<TUIMessageBean> messageList = new ArrayList<>();
        for (int i = 0; i < v2TIMMessageList.size(); i++) {
            V2TIMMessage timMessage = v2TIMMessageList.get(i);
            TUIMessageBean message = parseMessage(timMessage);
            if (message != null) {
                messageList.add(message);
            }
        }
        return messageList;
    }

    private static TUIMessageBean parseCallingMessage(V2TIMMessage v2TIMMessage) {
        V2TIMSignalingInfo signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(v2TIMMessage);
        if (signalingInfo != null) {
            String businessId = null;
            Double businessIdForTimeout = 0.0;
            Object businessIdObj = null;
            Gson gson = new Gson();
            try {
                HashMap signalDataMap = gson.fromJson(signalingInfo.getData(), HashMap.class);
                if (signalDataMap != null) {
                    businessIdObj = signalDataMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
                }
            } catch (JsonSyntaxException e) {
                TUIChatLog.e(TAG, " get signalingInfoCustomJsonMap error ");
            }
            if (businessIdObj instanceof String) {
                businessId = (String) businessIdObj;
            } else if (businessIdObj instanceof Double) {
                businessIdForTimeout = (Double) businessIdObj;
            }

            if (TextUtils.equals(businessId, TUIConstants.TUICalling.CUSTOM_MESSAGE_BUSINESS_ID) ||
                    Math.abs(businessIdForTimeout - TUIConstants.TUICalling.CALL_TIMEOUT_BUSINESS_ID) < 0.000001) {
                return getCallingMessage(v2TIMMessage);
            } else {
                return null;
            }
        }
        return null;
    }

    private static TUIMessageBean getCallingMessage(V2TIMMessage timMessage) {
        TUIMessageBean message;
        boolean isGroup = !TextUtils.isEmpty(timMessage.getGroupID());

        CallModel callModel = CallModel.convert2VideoCallData(timMessage);
        if (callModel == null) {
            return null;
        }
        String senderShowName = getDisplayName(timMessage);
        String content = "";
        Context context = TUIChatService.getAppContext();
        switch (callModel.action) {
            case CallModel.VIDEO_CALL_ACTION_DIALING:
                content = isGroup ? ("\"" + senderShowName + "\"" +
                        context.getString(R.string.start_group_call)) : (context.getString(R.string.start_call));
                break;
            case CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                content = isGroup ? context.getString(R.string.cancle_group_call) : context.getString(R.string.cancle_call);
                break;
            case CallModel.VIDEO_CALL_ACTION_LINE_BUSY:
                content = isGroup ? ("\"" + senderShowName + "\"" +
                        context.getString(R.string.line_busy)) : context.getString(R.string.other_line_busy);
                break;
            case CallModel.VIDEO_CALL_ACTION_REJECT:
                content = isGroup ? ("\"" + senderShowName + "\"" +
                        context.getString(R.string.reject_group_calls)) : context.getString(R.string.reject_calls);
                break;
            case CallModel.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT:
                if (isGroup && callModel.invitedList != null && callModel.invitedList.size() == 1
                        && callModel.invitedList.get(0).equals(timMessage.getSender())) {
                    content = "\"" + senderShowName + "\"" + context.getString(R.string.no_response_call);
                } else {
                    StringBuilder inviteeShowStringBuilder = new StringBuilder();
                    if (callModel.invitedList != null && callModel.invitedList.size() > 0) {
                        for (String invitee : callModel.invitedList) {
                            inviteeShowStringBuilder.append(invitee).append("、");
                        }
                        if (inviteeShowStringBuilder.length() > 0) {
                            inviteeShowStringBuilder.delete(inviteeShowStringBuilder.length() - 1, inviteeShowStringBuilder.length());
                        }
                    }
                    content = isGroup ? ("\"" + inviteeShowStringBuilder.toString() + "\""
                            + context.getString(R.string.no_response_call)) : context.getString(R.string.no_response_call);
                }
                break;
            case CallModel.VIDEO_CALL_ACTION_ACCEPT:
                content = isGroup ? ("\"" + senderShowName + "\"" +
                        context.getString(R.string.accept_call)) : context.getString(R.string.accept_call);
                break;
            case CallModel.VIDEO_CALL_ACTION_HANGUP:
                content = isGroup ? context.getString(R.string.stop_group_call) :
                        context.getString(R.string.stop_call_tip) + DateTimeUtil.formatSecondsTo00(callModel.duration);
                break;
            case CallModel.VIDEO_CALL_ACTION_SWITCH_TO_AUDIO:
                content = context.getString(R.string.chat_calling_switch_to_audio);
                break;
            case CallModel.VIDEO_CALL_ACTION_SWITCH_TO_AUDIO_ACCEPT:
                content = context.getString(R.string.chat_calling_switch_to_audio_accept);
                break;
            case CallModel.VIDEO_CALL_ACTION_UNKNOWN_INVITE:
                content = context.getString(R.string.chat_calling_unknown_invitation);
                break;
            default:
                content = context.getString(R.string.invalid_command);
                break;
        }
        if (isGroup) {
            TipsMessageBean tipsMessageBean = new TipsMessageBean();
            tipsMessageBean.setCommonAttribute(timMessage);
            tipsMessageBean.setText(content);
            tipsMessageBean.setExtra(content);
            message = tipsMessageBean;
        } else {
            CallingMessageBean callingMessageBean = new CallingMessageBean();
            callingMessageBean.setCommonAttribute(timMessage);
            callingMessageBean.setText(content);
            callingMessageBean.setExtra(content);
            callingMessageBean.setCallType(callModel.callType);
            message = callingMessageBean;
        }
        return message;
    }

    private static TUIMessageBean parseGroupCreateMessage(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            return null;
        }
        String data = new String(customElem.getData());
        Gson gson = new Gson();

        if (data.equals(MessageCustom.BUSINESS_ID_GROUP_CREATE)) {
            // 兼容4.7版本以前的 tuikit
            // Compatible with tuikit prior to version 4.7
            TipsMessageBean messageBean = new TipsMessageBean();
            messageBean.setCommonAttribute(v2TIMMessage);
            messageBean.setTipType(TipsMessageBean.MSG_TYPE_GROUP_CREATE);
            String message = TUIChatConstants.covert2HTMLString(getDisplayName(v2TIMMessage)) + TUIChatService.getAppContext().getString(R.string.create_group);
            messageBean.setText(message);
            messageBean.setExtra(message);
            return messageBean;
        } else {
            if (isTyping(customElem.getData())) {
                // 忽略正在输入，它不能作为真正的消息展示
                // Ignore being typed, it cannot be displayed as a real message
                return null;
            }
            TUIChatLog.i(TAG, "custom data:" + data);
            MessageCustom messageCustom = null;
            try {
                messageCustom = gson.fromJson(data, MessageCustom.class);
                if (!TextUtils.isEmpty(messageCustom.businessID) && messageCustom.businessID.equals(MessageCustom.BUSINESS_ID_GROUP_CREATE)) {
                    TipsMessageBean messageBean = new TipsMessageBean();
                    messageBean.setCommonAttribute(v2TIMMessage);
                    messageBean.setTipType(TipsMessageBean.MSG_TYPE_GROUP_CREATE);
                    String message = TUIChatConstants.covert2HTMLString(getDisplayName(v2TIMMessage)) + messageCustom.content;
                    messageBean.setText(message);
                    messageBean.setExtra(message);
                    return messageBean;
                }
            } catch (Exception e) {
                TUIChatLog.e(TAG, "invalid json: " + data + ", exception:" + e);
            }
        }
        return null;
    }

    public static String getDisplayName(V2TIMMessage timMessage) {
        String displayName;
        if (timMessage == null) {
            return null;
        }
        if (!TextUtils.isEmpty(timMessage.getNameCard())) {
            displayName = timMessage.getNameCard();
        } else if (!TextUtils.isEmpty(timMessage.getFriendRemark())) {
            displayName = timMessage.getFriendRemark();
        } else if (!TextUtils.isEmpty(timMessage.getNickName())) {
            displayName = timMessage.getNickName();
        } else {
            displayName = timMessage.getSender();
        }
        return displayName;
    }

    /**
     * 获取图片在本地的原始路径 (可能是沙盒中的路径)
     * @param messageBean 图片消息元组
     * @return 图片原始路径，如果不存在返回 null
     * 
     * Get the original path of the image locally (maybe the path in the sandbox)
     * @param messageBean message bean
     * @return The original path of the image, or null if it does not exist
     */
    public static String getLocalImagePath(TUIMessageBean messageBean) {
        if (messageBean == null || !messageBean.isSelf()) {
            return null;
        }
        V2TIMMessage message = messageBean.getV2TIMMessage();
        if (message == null || message.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
            return null;
        }
        V2TIMImageElem imageElem = message.getImageElem();
        if (imageElem == null) {
            return null;
        }
        String path = imageElem.getPath();
        File file = new File(path);
        if (file.exists()) {
            return path;
        }
        return null;
    }

    public static String getDisplayString(V2TIMMessage v2TIMMessage) {
        if (v2TIMMessage == null) {
            return null;
        }
        TUIMessageBean messageBean = parseMessage(v2TIMMessage);
        if (messageBean == null) {
            return null;
        }
        String displayString;
        if (messageBean.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            if (messageBean.isSelf()) {
                displayString = TUIChatService.getAppContext().getString(R.string.revoke_tips_you);
            } else if (messageBean.isGroup()) {
                String message = TUIChatConstants.covert2HTMLString(
                        TextUtils.isEmpty(messageBean.getNameCard())
                                ? messageBean.getSender()
                                : messageBean.getNameCard());
                displayString = message + TUIChatService.getAppContext().getString(R.string.revoke_tips);
            } else {
                displayString = TUIChatService.getAppContext().getString(R.string.revoke_tips_other);
            }
        } else {
            displayString = messageBean.onGetDisplayString();
        }
        displayString = FaceManager.emojiJudge(displayString);
        return displayString;
    }

    public static String getReplyMessageAbstract(TUIMessageBean messageBean) {
        String result = "";
        if (messageBean != null) {
            String extra = "";
            if (messageBean instanceof TextMessageBean) {
                extra = ((TextMessageBean) messageBean).getText();
            } else if (messageBean instanceof MergeMessageBean) {
                extra = ((MergeMessageBean) messageBean).getTitle();
            } else if (messageBean instanceof FileMessageBean) {
                extra = ((FileMessageBean) messageBean).getFileName();
            } else if (messageBean instanceof CustomLinkMessageBean) {
                extra = ((CustomLinkMessageBean) messageBean).getText();
            } else if (messageBean instanceof SoundMessageBean
                    || messageBean instanceof ImageMessageBean
                    || messageBean instanceof VideoMessageBean
                    || messageBean instanceof LocationMessageBean
                    || messageBean instanceof FaceMessageBean) {
                extra = "";
            } else {
                extra = messageBean.getExtra();
            }
            result = result + extra;
        }
        return result;
    }

    public static boolean isFileType(int msgType) {
        return msgType == V2TIMMessage.V2TIM_ELEM_TYPE_FILE;
    }

    public static String getMsgTypeStr(int msgType) {
        String typeStr;
        switch (msgType) {
            case V2TIMMessage.V2TIM_ELEM_TYPE_SOUND: {
                typeStr = TUIChatService.getAppContext().getString(R.string.audio_extra);
                break;
            }
            case V2TIMMessage.V2TIM_ELEM_TYPE_FILE: {
                typeStr = TUIChatService.getAppContext().getString(R.string.file_extra);
                break;
            }
            case V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE: {
                typeStr = TUIChatService.getAppContext().getString(R.string.picture_extra);
                break;
            }
            case V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION: {
                typeStr = TUIChatService.getAppContext().getString(R.string.location_extra);
                break;
            }
            case V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO: {
                typeStr = TUIChatService.getAppContext().getString(R.string.video_extra);
                break;
            }
            case V2TIMMessage.V2TIM_ELEM_TYPE_FACE: {
                typeStr = TUIChatService.getAppContext().getString(R.string.custom_emoji);
                break;
            }
            default: {
                typeStr = "";
            }
        }
        return typeStr;
    }

    public static MessageFeature isSupportTyping(TUIMessageBean messageBean) {
        String cloudCustomData = messageBean.getV2TIMMessage().getCloudCustomData();
        if (TextUtils.isEmpty(cloudCustomData)) {
            return null;
        }
        try {
            Gson gson = new Gson();
            HashMap featureHashMap = gson.fromJson(cloudCustomData, HashMap.class);
            if (featureHashMap != null) {
                Object featureContentObj = featureHashMap.get(TUIChatConstants.MESSAGE_FEATURE_KEY);
                MessageFeature messageFeature = null;
                if (featureContentObj instanceof Map) {
                    messageFeature = gson.fromJson(gson.toJson(featureContentObj), MessageFeature.class);
                }
                if (messageFeature != null) {
                    if (messageFeature.getVersion() > MessageFeature.VERSION) {
                        return null;
                    }

                    return messageFeature;
                }
            }
        } catch (JsonSyntaxException e) {
            TUIChatLog.e(TAG, " isSupportTyping exception e = " + e);
        }
        return null;
    }
    
}
