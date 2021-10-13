package com.tencent.qcloud.tuikit.tuisearch.util;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMFaceElem;
import com.tencent.imsdk.v2.V2TIMFileElem;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupTipsElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchConstants;
import com.tencent.qcloud.tuikit.tuisearch.TUISearchService;
import com.tencent.qcloud.tuikit.tuisearch.bean.CallModel;
import com.tencent.qcloud.tuikit.tuisearch.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuisearch.message.MessageCustom;
import com.tencent.qcloud.tuikit.tuisearch.message.MessageTyping;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class MessageInfoUtil {
    private static final String TAG = MessageInfoUtil.class.getSimpleName();

    /**
     * 创建一条文本消息
     *
     * @param message 消息内容
     * @return
     */
    public static MessageInfo buildTextMessage(String message) {
        MessageInfo info = new MessageInfo();
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextMessage(message);

        info.setExtra(message);
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_TEXT);
        return info;
    }

    public static MessageInfo buildTextAtMessage(List<String> atUserList, String message) {
        MessageInfo info = new MessageInfo();
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createTextAtMessage(message, atUserList);

        info.setExtra(message);
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_TEXT);
        return info;
    }

    /**
     * 创建一条自定义表情的消息
     *
     * @param groupId  自定义表情所在的表情组id
     * @param faceName 表情的名称
     * @return
     */
    public static MessageInfo buildCustomFaceMessage(int groupId, String faceName) {
        MessageInfo info = new MessageInfo();
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createFaceMessage(groupId, faceName.getBytes());

        info.setExtra(TUISearchService.getAppContext().getString(R.string.custom_emoji));
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_CUSTOM_FACE);
        return info;
    }

    /**
     * 创建一条图片消息
     *
     * @param uri        图片URI
     * @param compressed 是否压缩
     * @return
     */
    public static MessageInfo buildImageMessage(final Uri uri, boolean compressed) {
        final MessageInfo info = new MessageInfo();
        String path = ImageUtil.getImagePathAfterRotate(uri);
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createImageMessage(path);

        info.setDataUri(uri);
        int[] size = ImageUtil.getImageSize(path);
        info.setDataPath(path);
        info.setImgWidth(size[0]);
        info.setImgHeight(size[1]);
        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setExtra(TUISearchService.getAppContext().getString(R.string.picture_extra));
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_IMAGE);
        return info;
    }

    /**
     * 创建一条视频消息
     *
     * @param imgPath   视频缩略图路径
     * @param videoPath 视频路径
     * @param width     视频的宽
     * @param height    视频的高
     * @param duration  视频的时长
     * @return
     */
    public static MessageInfo buildVideoMessage(String imgPath, String videoPath, int width, int height, long duration) {
        MessageInfo info = new MessageInfo();
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createVideoMessage(videoPath, "mp4", (int) duration / 1000, imgPath);

        Uri videoUri = Uri.fromFile(new File(videoPath));
        info.setSelf(true);
        info.setImgWidth(width);
        info.setImgHeight(height);
        info.setDataPath(imgPath);
        info.setDataUri(videoUri);
        info.setTimMessage(v2TIMMessage);
        info.setExtra(TUISearchService.getAppContext().getString(R.string.video_extra));
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_VIDEO);
        return info;
    }

    /**
     * 创建一条音频消息
     *
     * @param recordPath 音频路径
     * @param duration   音频的时长
     * @return
     */
    public static MessageInfo buildAudioMessage(String recordPath, int duration) {
        MessageInfo info = new MessageInfo();
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createSoundMessage(recordPath, duration / 1000);

        info.setDataPath(recordPath);
        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setExtra(TUISearchService.getAppContext().getString(R.string.audio_extra));
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setMsgType(MessageInfo.MSG_TYPE_AUDIO);
        return info;
    }

    /**
     * 创建一条文件消息
     *
     * @param fileUri 文件路径
     * @return
     */
    public static MessageInfo buildFileMessage(Uri fileUri) {
        String filePath = FileUtil.getPathFromUri(fileUri);
        File file = new File(filePath);
        if (file.exists()) {
            MessageInfo info = new MessageInfo();
            V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createFileMessage(filePath, file.getName());

            info.setDataPath(filePath);
            info.setSelf(true);
            info.setTimMessage(v2TIMMessage);
            info.setExtra(TUISearchService.getAppContext().getString(R.string.file_extra));
            info.setMsgTime(System.currentTimeMillis() / 1000);
            info.setFromUser(V2TIMManager.getInstance().getLoginUser());
            info.setMsgType(MessageInfo.MSG_TYPE_FILE);
            return info;
        }
        return null;
    }

    /**
     * 创建一条 onebyone 转发消息
     *
     * @param v2TIMMessage 要转发的消息
     * @return
     */
    public static MessageInfo buildForwardMessage(V2TIMMessage v2TIMMessage) {
        V2TIMMessage forwardMessage = V2TIMManager.getInstance().getMessageManager().createForwardMessage(v2TIMMessage);
        MessageInfo info = MessageInfoUtil.createMessageInfo(forwardMessage);

        info.setSelf(true);
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        return info;
    }

    /**
     * 创建一条 merge 转发消息
     *
     * @param v2TIMMessage 要转发的消息,经过 createMergerMessage 之后的转发消息
     * @return
     */
    public static MessageInfo buildMergeMessage(V2TIMMessage v2TIMMessage) {
        MessageInfo info = new MessageInfo();

        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setMsgType(MessageInfo.MSG_TYPE_MERGE);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        info.setExtra(TUISearchService.getAppContext().getString(R.string.forward_extra));
        return info;
    }

    /**
     * 创建一条 merge 转发消息
     *
     * @return
     */
    public static MessageInfo buildMergeMessage(List<MessageInfo> messageInfoList,
                                                String title,
                                                List<String> abstractList,
                                                String compatibleText) {
        if (messageInfoList == null || messageInfoList.isEmpty()){
            return null;
        }
        List<V2TIMMessage> msgList = new ArrayList<>();
        for(int i = 0; i < messageInfoList.size(); i++){
            msgList.add(messageInfoList.get(i).getTimMessage());
        }
        V2TIMMessage mergeMsg = V2TIMManager.getMessageManager()
                .createMergerMessage(msgList, title, abstractList, compatibleText);
        return buildMergeMessage(mergeMsg);
    }

    /**
     * 创建一条自定义消息
     * @param data 自定义消息内容，可以是任何内容
     * @param description 自定义消息描述内容，可以被搜索到
     * @param extension 扩展内容
     * @return
     */
    public static MessageInfo buildCustomMessage(String data, String description, byte[] extension) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createCustomMessage(data.getBytes(), description, extension);
        MessageInfo info = new MessageInfo();
        setMessageInfoCommonAttributes(info, v2TIMMessage);
        info.setSelf(true);
        info.setTimMessage(v2TIMMessage);
        info.setMsgTime(System.currentTimeMillis() / 1000);
        info.setMsgType(MessageInfo.MSG_TYPE_CUSTOM);
        info.setFromUser(V2TIMManager.getInstance().getLoginUser());
        if (info.getExtra() == null) {
            info.setExtra(TUISearchService.getAppContext().getString(R.string.custom_msg));
        }
        return info;
    }

    /**
     * 创建一条群消息自定义内容
     *
     * @param customMessage 消息内容
     * @return
     */
    public static V2TIMMessage buildGroupCustomMessage(String customMessage) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createCustomMessage(customMessage.getBytes());
        return v2TIMMessage;
    }

    /**
     * 把SDK的消息bean列表转化为TUIKit的消息bean列表
     *
     * @param timMessages SDK的群消息bean列表
     * @return
     */
    public static List<MessageInfo> convertTIMMessages2MessageInfos(List<V2TIMMessage> timMessages) {
        if (timMessages == null) {
            return null;
        }
        List<MessageInfo> messageInfos = new ArrayList<>();
        for (int i = 0; i < timMessages.size(); i++) {
            V2TIMMessage timMessage = timMessages.get(i);
            MessageInfo info = convertTIMMessage2MessageInfo(timMessage);
            if (info != null) {
                messageInfos.add(info);
            }
        }
        return messageInfos;
    }

    /**
     * 把SDK的消息bean转化为TUIKit的消息bean
     *
     * @param timMessage SDK的群消息bean
     * @return
     */
    public static MessageInfo convertTIMMessage2MessageInfo(V2TIMMessage timMessage) {
        if (timMessage == null || timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED || timMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_NONE) {
            return null;
        }
        return createMessageInfo(timMessage);
    }

    public static boolean isOnlineIgnored(MessageInfo messageInfo) {
        if (messageInfo == null || messageInfo.getIsIgnoreShow()) {
            return true;
        }
        return false;
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
            TUISearchLog.e(TAG, "parse json error");
        }
        return false;
    }

    public static MessageInfo createMessageInfo(V2TIMMessage timMessage) {
        if (timMessage == null
                || timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED
                || timMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_NONE) {
            TUISearchLog.e(TAG, "ele2MessageInfo parameters error");
            return null;
        }

        Context context = TUISearchService.getAppContext();
        if (context == null){
            TUISearchLog.e(TAG, "context == null");
            return new MessageInfo();
        }

        final MessageInfo msgInfo;

        int type = timMessage.getElemType();
        if (type == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            msgInfo = createCustomMessageInfo(timMessage, context);
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            msgInfo = createGroupTipsMessageInfo(timMessage, context);
        } else {
            msgInfo = createNormalMessageInfo(timMessage, context, type);
        }

        if (msgInfo == null) {
            return null;
        }

        if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
            msgInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
            msgInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
            if (msgInfo.isSelf()) {
                msgInfo.setExtra(context.getString(R.string.revoke_tips_you));
            } else if (msgInfo.isGroup()) {
                String message = TUISearchConstants.covert2HTMLString(msgInfo.getFromUser());
                msgInfo.setExtra(message + context.getString(R.string.revoke_tips));
            } else {
                msgInfo.setExtra(context.getString(R.string.revoke_tips_other));
            }
        } else {
            if (msgInfo.isSelf()) {
                if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_FAIL);
                } else if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_SUCC) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                } else if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SENDING) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SENDING);
                }
            }
        }
        return msgInfo;
    }

    private static MessageInfo createCustomMessageInfo(V2TIMMessage timMessage, Context context) {
        MessageInfo msgInfo = new MessageInfo();
        setMessageInfoCommonAttributes(msgInfo, timMessage);

        V2TIMCustomElem customElem = timMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null) {
            return null;
        }
        String data = new String(customElem.getData());

        Gson gson = new Gson();
        HashMap customJsonMap = null;
        try {
            customJsonMap = gson.fromJson(data, HashMap.class);
        } catch (JsonSyntaxException e) {
            TUISearchLog.e(TAG, " getCustomJsonMap error ");
        }
        String businessId = null;
        Double businessIdForTimeout = 0.0;
        Object businessIdObj = null;
        if (customJsonMap != null) {
            businessIdObj = customJsonMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
        }
        if (businessIdObj instanceof String) {
            businessId = (String) businessIdObj;
        } else if (businessIdObj instanceof Double) {
            businessIdForTimeout = (Double) businessIdObj;
        }

        V2TIMSignalingInfo signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msgInfo.getTimMessage());

        // 欢迎消息
        if (TextUtils.equals(businessId, "text_link")) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_CUSTOM);
            msgInfo.setExtra(customJsonMap.get("text"));
        } else if (TextUtils.equals(businessId, TUIConstants.TUILive.CUSTOM_MESSAGE_BUSINESS_ID)) { // 群直播消息
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_CUSTOM);
            setLiveExtra(msgInfo, customJsonMap);
        } else if (signalingInfo != null) { // 信令消息
            try {
                HashMap signalDataMap = gson.fromJson(signalingInfo.getData(), HashMap.class);
                if (signalDataMap != null) {
                    businessIdObj = signalDataMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
                }
            } catch (JsonSyntaxException e) {
                TUISearchLog.e(TAG, " get signalingInfoCustomJsonMap error ");
            }
            if (businessIdObj instanceof String) {
                businessId = (String) businessIdObj;
            } else if (businessIdObj instanceof Double) {
                businessIdForTimeout = (Double) businessIdObj;
            }
            // 音视频自定义消息
            if (TextUtils.equals(businessId, TUIConstants.TUICalling.CUSTOM_MESSAGE_BUSINESS_ID) ||
                    Math.abs(businessIdForTimeout - TUIConstants.TUICalling.CALL_TIMEOUT_BUSINESS_ID) < 0.000001) {
                boolean isGroup = !TextUtils.isEmpty(timMessage.getGroupID());
                if (isGroup) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_TIPS);
                } else {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_TEXT);
                }
                setCallingExtra(msgInfo);
            } else {
                return null;
            }
        } else if (data.equals(MessageCustom.BUSINESS_ID_GROUP_CREATE)) {
            // 兼容4.7版本以前的 tuikit
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_CREATE);
            String message = TUISearchConstants.covert2HTMLString(getDisplayName(timMessage)) + context.getString(R.string.create_group);
            msgInfo.setExtra(message);
        } else {
            if (isTyping(customElem.getData())) {
                // 忽略正在输入，它不能作为真正的消息展示
                return null;
            }
            TUISearchLog.i(TAG, "custom data:" + data);
            String content = context.getString(R.string.custom_msg);
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_CUSTOM);
            msgInfo.setExtra(content);
            MessageCustom messageCustom = null;
            try {
                messageCustom = gson.fromJson(data, MessageCustom.class);
                if (!TextUtils.isEmpty(messageCustom.businessID) && messageCustom.businessID.equals(MessageCustom.BUSINESS_ID_GROUP_CREATE)) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_CREATE);
                    String message = TUISearchConstants.covert2HTMLString(getDisplayName(timMessage)) + messageCustom.content;
                    msgInfo.setExtra(message);
                }
            } catch (Exception e) {
                TUISearchLog.e(TAG, "invalid json: " + data + ", exception:" + e);
            }
        }
        return msgInfo;
    }

    private static void setCallingExtra(MessageInfo messageInfo) {
        V2TIMMessage timMessage = messageInfo.getTimMessage();
        CallModel callModel = CallModel.convert2VideoCallData(timMessage);
        if (callModel == null) {
            return;
        }
        boolean isGroup = messageInfo.isGroup();
        String senderShowName = getDisplayName(timMessage);
        String content = "";
        Context context = TUISearchService.getAppContext();
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
            default:
                content = context.getString(R.string.invalid_command);
                break;
        }
        messageInfo.setExtra(content);
    }

    private static void setLiveExtra(MessageInfo messageInfo, HashMap customJsonMap) {
        if (messageInfo == null || customJsonMap == null) {
            return;
        }
        String content;
        String anchorName = (String) customJsonMap.get(TUIConstants.TUILive.ANCHOR_NAME);
        String anchorId = (String) customJsonMap.get(TUIConstants.TUILive.ANCHOR_ID);
        String roomName = (String) customJsonMap.get(TUIConstants.TUILive.ROOM_NAME);

        if (TextUtils.isEmpty(anchorName)) {
            if (!TextUtils.isEmpty(anchorId)) {
                anchorName = anchorId;
            } else {
                anchorName = roomName;
            }
        }
        content = "[" + anchorName + TUISearchService.getAppContext().getString(R.string.live) + "]";
        messageInfo.setExtra(content);
    }


    public static String getDisplayName(V2TIMMessage timMessage) {
        String displayName;
        if (timMessage == null) {
            return null;
        }
        // 群名片->好友备注->昵称->ID
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

    public static String getDisplayName(V2TIMGroupMemberInfo groupMemberInfo) {
        String displayName;
        if (groupMemberInfo == null) {
            return null;
        }
        // 群名片->好友备注->昵称->ID
        if (!TextUtils.isEmpty(groupMemberInfo.getNameCard())) {
            displayName = groupMemberInfo.getNameCard();
        } else if (!TextUtils.isEmpty(groupMemberInfo.getFriendRemark())) {
            displayName = groupMemberInfo.getFriendRemark();
        } else if (!TextUtils.isEmpty(groupMemberInfo.getNickName())) {
            displayName = groupMemberInfo.getNickName();
        } else {
            displayName = groupMemberInfo.getUserID();
        }

        return displayName;
    }

    private static MessageInfo createGroupTipsMessageInfo(V2TIMMessage timMessage, Context context) {
        MessageInfo msgInfo = new MessageInfo();
        setMessageInfoCommonAttributes(msgInfo, timMessage);

        V2TIMGroupTipsElem groupTipElem = timMessage.getGroupTipsElem();
        int tipsType = groupTipElem.getType();
        String operationUser = "";
        String targetUser = "";
        if (groupTipElem.getMemberList().size() > 0) {
            List<V2TIMGroupMemberInfo> v2TIMGroupMemberInfoList = groupTipElem.getMemberList();
            for (int i = 0; i < v2TIMGroupMemberInfoList.size(); i++) {
                V2TIMGroupMemberInfo v2TIMGroupMemberInfo = v2TIMGroupMemberInfoList.get(i);
                if (i == 0) {
                    targetUser = targetUser + getDisplayName(v2TIMGroupMemberInfo);
                } else {
                    if (i == 2 && v2TIMGroupMemberInfoList.size() > 3) {
                        targetUser = targetUser + context.getString(R.string.etc);
                        break;
                    } else {
                        targetUser = targetUser + "，" + getDisplayName(v2TIMGroupMemberInfo);
                    }
                }
            }
        }

        operationUser = getDisplayName(groupTipElem.getOpMember());

        if (!TextUtils.isEmpty(targetUser)) {
            targetUser = TUISearchConstants.covert2HTMLString(targetUser);
        }

        if (!TextUtils.isEmpty(operationUser)) {
            operationUser = TUISearchConstants.covert2HTMLString(operationUser);
        }

        String tipsMessage = "";
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_JOIN) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_JOIN);
            tipsMessage = targetUser + context.getString(R.string.join_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_INVITE) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_JOIN);
            tipsMessage = targetUser + context.getString(R.string.invite_joined_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_QUIT) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_QUITE);
            tipsMessage = operationUser + context.getString(R.string.quit_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_KICKED) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_KICK);
            tipsMessage = targetUser + context.getString(R.string.kick_group_tip);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = targetUser + context.getString(R.string.be_group_manager);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN) {
            msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = targetUser + context.getString(R.string.cancle_group_manager);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE) {
            List<V2TIMGroupChangeInfo> modifyList = groupTipElem.getGroupChangeInfoList();
            for (int i = 0; i < modifyList.size(); i++) {
                V2TIMGroupChangeInfo modifyInfo = modifyList.get(i);
                int modifyType = modifyInfo.getType();
                if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME);
                    tipsMessage = operationUser + context.getString(R.string.modify_group_name_is) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + context.getString(R.string.modify_notice) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    if (!TextUtils.isEmpty(targetUser)) {
                        // 后台把新群主的资料放到了 getMemberList 中
                        tipsMessage = operationUser + context.getString(R.string.move_owner) + "\"" + targetUser + "\"";
                    } else {
                        // modifyInfo 中只有新群主的 userID
                        tipsMessage =
                                operationUser + context.getString(R.string.move_owner) + "\"" + TUISearchConstants.covert2HTMLString(modifyInfo.getValue()) + "\"";
                    }
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + context.getString(R.string.modify_group_avatar);
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + context.getString(R.string.modify_notice) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL) {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    boolean isShutUpAll = modifyInfo.getBoolValue();
                    if (isShutUpAll) {
                        tipsMessage = operationUser + context.getString(R.string.modify_shut_up_all);
                    } else {
                        tipsMessage = operationUser + context.getString(R.string.modify_cancel_shut_up_all);
                    }
                }
                if (i < modifyList.size() - 1) {
                    tipsMessage = tipsMessage + "、";
                }
            }
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE) {
            List<V2TIMGroupMemberChangeInfo> modifyList = groupTipElem.getMemberChangeInfoList();
            if (modifyList.size() > 0) {
                long shutupTime = modifyList.get(0).getMuteTime();
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (shutupTime > 0) {
                    tipsMessage = targetUser + context.getString(R.string.banned) + "\"" + DateTimeUtil.formatSeconds(shutupTime) + "\"";
                } else {
                    tipsMessage = targetUser + context.getString(R.string.cancle_banned);
                }
            }
        }
        if (TextUtils.isEmpty(tipsMessage)) {
            return null;
        }
        msgInfo.setExtra(tipsMessage);
        return msgInfo;
    }


    private static MessageInfo createNormalMessageInfo(V2TIMMessage timMessage, Context context, int type) {
        final MessageInfo msgInfo = new MessageInfo();
        setMessageInfoCommonAttributes(msgInfo, timMessage);
        if (type == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
            V2TIMTextElem txtEle = timMessage.getTextElem();
            msgInfo.setExtra(txtEle.getText());
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
            V2TIMFaceElem faceElem = timMessage.getFaceElem();
            if (faceElem.getIndex() < 1 || faceElem.getData() == null) {
                TUISearchLog.e("MessageInfoUtil", "faceElem data is null or index<1");
                return null;
            }
            msgInfo.setExtra(context.getString(R.string.custom_emoji));
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
            V2TIMSoundElem soundElemEle = timMessage.getSoundElem();
            if (msgInfo.isSelf()) {
                msgInfo.setDataPath(soundElemEle.getPath());
            } else {
                final String path = TUIConfig.getRecordDownloadDir() + soundElemEle.getUUID();
                File file = new File(path);
                if (!file.exists()) {
                    soundElemEle.downloadSound(path, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                            long currentSize = progressInfo.getCurrentSize();
                            long totalSize = progressInfo.getTotalSize();
                            int progress = 0;
                            if (totalSize > 0) {
                                progress = (int) (100 * currentSize / totalSize);
                            }
                            if (progress > 100) {
                                progress = 100;
                            }
                            TUISearchLog.i("MessageInfoUtil getSoundToFile", "progress:" + progress);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            TUISearchLog.e("MessageInfoUtil getSoundToFile", code + ":" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            msgInfo.setDataPath(path);
                        }
                    });
                } else {
                    msgInfo.setDataPath(path);
                }
            }
            msgInfo.setExtra(context.getString(R.string.audio_extra));
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
            V2TIMImageElem imageEle = timMessage.getImageElem();
            String localPath = imageEle.getPath();
            if (msgInfo.isSelf() && !TextUtils.isEmpty(localPath) && new File(localPath).exists()) {
                msgInfo.setDataPath(localPath);
                int size[] = ImageUtil.getImageSize(localPath);
                msgInfo.setImgWidth(size[0]);
                msgInfo.setImgHeight(size[1]);
            }
            //本地路径为空，可能为更换手机或者是接收的消息
            else {
                List<V2TIMImageElem.V2TIMImage> imgs = imageEle.getImageList();
                for (int i = 0; i < imgs.size(); i++) {
                    V2TIMImageElem.V2TIMImage img = imgs.get(i);
                    if (img.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB) {
                        final String path = ImageUtil.generateImagePath(img.getUUID(), V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB);
                        msgInfo.setImgWidth(img.getWidth());
                        msgInfo.setImgHeight(img.getHeight());
                        File file = new File(path);
                        if (file.exists()) {
                            msgInfo.setDataPath(path);
                        }
                    }
                }
            }
            msgInfo.setExtra(context.getString(R.string.picture_extra));
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
            V2TIMVideoElem videoEle = timMessage.getVideoElem();
            if (msgInfo.isSelf() && !TextUtils.isEmpty(videoEle.getSnapshotPath())) {
                int size[] = ImageUtil.getImageSize(videoEle.getSnapshotPath());
                msgInfo.setImgWidth(size[0]);
                msgInfo.setImgHeight(size[1]);
                msgInfo.setDataPath(videoEle.getSnapshotPath());
                msgInfo.setDataUri(FileUtil.getUriFromPath(videoEle.getVideoPath()));
            } else {
                final String videoPath = TUIConfig.getVideoDownloadDir() + videoEle.getVideoUUID();
                Uri uri = Uri.parse(videoPath);
                msgInfo.setDataUri(uri);
                msgInfo.setImgWidth((int) videoEle.getSnapshotWidth());
                msgInfo.setImgHeight((int) videoEle.getSnapshotHeight());
                final String snapPath = TUIConfig.getImageDownloadDir() + videoEle.getSnapshotUUID();
                //判断快照是否存在,不存在自动下载
                if (new File(snapPath).exists()) {
                    msgInfo.setDataPath(snapPath);
                }
            }

            msgInfo.setExtra(context.getString(R.string.video_extra));
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
            V2TIMFileElem fileElem = timMessage.getFileElem();
            String filename = fileElem.getUUID();
            if (TextUtils.isEmpty(filename)) {
                filename = System.currentTimeMillis() + fileElem.getFileName();
            }
            final String path = TUIConfig.getFileDownloadDir() + filename;
            String finalPath = path;
            File file = new File(path);
            if (file.exists()) {
                if (msgInfo.isSelf()) {
                    msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                }
                msgInfo.setDownloadStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
            } else {
                if (msgInfo.isSelf()) {
                    if (TextUtils.isEmpty(fileElem.getPath())) {
                        msgInfo.setDownloadStatus(MessageInfo.MSG_STATUS_UN_DOWNLOAD);
                    } else {
                        file = new File(fileElem.getPath());
                        if (file.exists()) {
                            msgInfo.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                            msgInfo.setDownloadStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
                            finalPath = fileElem.getPath();
                        } else {
                            msgInfo.setDownloadStatus(MessageInfo.MSG_STATUS_UN_DOWNLOAD);
                        }
                    }
                } else {
                    msgInfo.setDownloadStatus(MessageInfo.MSG_STATUS_UN_DOWNLOAD);
                }
            }
            msgInfo.setDataPath(finalPath);
            msgInfo.setExtra(context.getString(R.string.file_extra));
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_MERGER) {
            // 合并转发消息
            msgInfo.setExtra("[聊天记录]");
        }
        msgInfo.setMsgType(convertTIMElemType2MessageInfoType(type));
        return msgInfo;
    }

    public static void setMessageInfoCommonAttributes(MessageInfo msgInfo, V2TIMMessage timMessage) {
        if (msgInfo == null) {
            return;
        }
        boolean isGroup = !TextUtils.isEmpty(timMessage.getGroupID());
        String sender = timMessage.getSender();
        if (TextUtils.isEmpty(sender)) {
            sender = V2TIMManager.getInstance().getLoginUser();
        }
        msgInfo.setTimMessage(timMessage);
        msgInfo.setGroup(isGroup);
        msgInfo.setId(timMessage.getMsgID());
        msgInfo.setPeerRead(timMessage.isPeerRead());
        msgInfo.setFromUser(sender);
        msgInfo.setNameCard(timMessage.getNameCard());
        msgInfo.setNickName(timMessage.getNickName());
        msgInfo.setFaceUrl(timMessage.getFaceUrl());
        msgInfo.setFriendRemark(timMessage.getFriendRemark());
        msgInfo.setUserId(timMessage.getUserID());
        msgInfo.setGroupId(timMessage.getGroupID());
        if (isGroup) {
            if (!TextUtils.isEmpty(timMessage.getNameCard())) {
                msgInfo.setGroupNameCard(timMessage.getNameCard());
            }
        }
        msgInfo.setMsgTime(timMessage.getTimestamp());
        msgInfo.setSelf(sender.equals(V2TIMManager.getInstance().getLoginUser()));
    }

    /**
     * 获取图片在本地的原始路径 (可能是沙盒中的路径)
     * @param messageInfo 图片消息元组
     * @return 图片原始路径，如果不存在返回 null
     */
    public static String getLocalImagePath(MessageInfo messageInfo) {
        if (messageInfo == null || !messageInfo.isSelf()) {
            return null;
        }
        V2TIMMessage message = messageInfo.getTimMessage();
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

    public static int convertTIMElemType2MessageInfoType(int type) {
        switch (type) {
            case V2TIMMessage.V2TIM_ELEM_TYPE_TEXT:
                return MessageInfo.MSG_TYPE_TEXT;
            case V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM:
                return MessageInfo.MSG_TYPE_CUSTOM;
            case V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE:
                return MessageInfo.MSG_TYPE_IMAGE;
            case V2TIMMessage.V2TIM_ELEM_TYPE_SOUND:
                return MessageInfo.MSG_TYPE_AUDIO;
            case V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO:
                return MessageInfo.MSG_TYPE_VIDEO;
            case V2TIMMessage.V2TIM_ELEM_TYPE_FILE:
                return MessageInfo.MSG_TYPE_FILE;
            case V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION:
                return MessageInfo.MSG_TYPE_LOCATION;
            case V2TIMMessage.V2TIM_ELEM_TYPE_FACE:
                return MessageInfo.MSG_TYPE_CUSTOM_FACE;
            case V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS:
                return MessageInfo.MSG_TYPE_TIPS;
            case V2TIMMessage.V2TIM_ELEM_TYPE_MERGER:
                return MessageInfo.MSG_TYPE_MERGE;
        }

        return -1;
    }
}
