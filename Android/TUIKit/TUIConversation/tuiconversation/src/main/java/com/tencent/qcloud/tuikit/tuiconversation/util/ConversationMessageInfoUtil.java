package com.tencent.qcloud.tuikit.tuiconversation.util;

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
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.bean.CallModel;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationMessageInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.MessageCustom;
import com.tencent.qcloud.tuikit.tuiconversation.bean.MessageTyping;

import java.io.File;
import java.util.HashMap;
import java.util.List;


public class ConversationMessageInfoUtil {
    private static final String TAG = ConversationMessageInfoUtil.class.getSimpleName();

    /**
     * 把SDK的消息bean转化为TUIKit的消息bean
     *
     * @param timMessage SDK的群消息bean
     * @return
     */
    public static ConversationMessageInfo convertTIMMessage2MessageInfo(V2TIMMessage timMessage) {
        if (timMessage == null || timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED || timMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_NONE) {
            return null;
        }
        return createMessageInfo(timMessage);
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
            TUIConversationLog.e(TAG, "parse json error");
        }
        return false;
    }

    public static ConversationMessageInfo createMessageInfo(V2TIMMessage timMessage) {
        if (timMessage == null
                || timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED
                || timMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_NONE) {
            TUIConversationLog.e(TAG, "ele2MessageInfo parameters error");
            return null;
        }

        Context context = TUIConversationService.getAppContext();
        if (context == null){
            TUIConversationLog.e(TAG, "context == null");
            return new ConversationMessageInfo();
        }

        final ConversationMessageInfo msgInfo;

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
            msgInfo.setStatus(ConversationMessageInfo.MSG_STATUS_REVOKE);
            msgInfo.setMsgType(ConversationMessageInfo.MSG_STATUS_REVOKE);
            if (msgInfo.isSelf()) {
                msgInfo.setExtra(context.getString(R.string.revoke_tips_you));
            } else if (msgInfo.isGroup()) {
                String message = TUIConversationConstants.covert2HTMLString(msgInfo.getFromUser());
                msgInfo.setExtra(message + context.getString(R.string.revoke_tips));
            } else {
                msgInfo.setExtra(context.getString(R.string.revoke_tips_other));
            }
        } else {
            if (msgInfo.isSelf()) {
                if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL) {
                    msgInfo.setStatus(ConversationMessageInfo.MSG_STATUS_SEND_FAIL);
                } else if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_SUCC) {
                    msgInfo.setStatus(ConversationMessageInfo.MSG_STATUS_SEND_SUCCESS);
                } else if (timMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SENDING) {
                    msgInfo.setStatus(ConversationMessageInfo.MSG_STATUS_SENDING);
                }
            }
        }
        return msgInfo;
    }

    private static ConversationMessageInfo createCustomMessageInfo(V2TIMMessage timMessage, Context context) {
        ConversationMessageInfo msgInfo = new ConversationMessageInfo();
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
            TUIConversationLog.e(TAG, " getCustomJsonMap error ");
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
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_CUSTOM);
            msgInfo.setExtra(customJsonMap.get("text"));
        } else if (signalingInfo != null) { // 信令消息
            try {
                HashMap signalDataMap = gson.fromJson(signalingInfo.getData(), HashMap.class);
                if (signalDataMap != null) {
                    businessIdObj = signalDataMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
                }
            } catch (JsonSyntaxException e) {
                TUIConversationLog.e(TAG, " get signalingInfoCustomJsonMap error ");
            }
            if (businessIdObj instanceof String) {
                businessId = (String) businessIdObj;
            } else if (businessIdObj instanceof Double) {
                businessIdForTimeout = (Double) businessIdObj;
            }
            if (TextUtils.equals(businessId, TUIConstants.TUICalling.CUSTOM_MESSAGE_BUSINESS_ID) ||
                    Math.abs(businessIdForTimeout - TUIConstants.TUICalling.CALL_TIMEOUT_BUSINESS_ID) < 0.000001) {
                boolean isGroup = !TextUtils.isEmpty(timMessage.getGroupID());
                if (isGroup) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_TIPS);
                } else {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_TEXT);
                }
                setCallingExtra(msgInfo);
            } else {
                return null;
            }
        } else if (data.equals(MessageCustom.BUSINESS_ID_GROUP_CREATE)) {
            // 兼容4.7版本以前的 tuikit
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_CREATE);
            String message = TUIConversationConstants.covert2HTMLString(getDisplayName(timMessage)) + context.getString(R.string.create_group);
            msgInfo.setExtra(message);
        } else {
            if (isTyping(customElem.getData())) {
                // 忽略正在输入，它不能作为真正的消息展示
                return null;
            }
            TUIConversationLog.i(TAG, "custom data:" + data);
            String content = context.getString(R.string.custom_msg);
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_CUSTOM);
            msgInfo.setExtra(content);
            MessageCustom messageCustom = null;
            try {
                messageCustom = gson.fromJson(data, MessageCustom.class);
                if (!TextUtils.isEmpty(messageCustom.businessID) && messageCustom.businessID.equals(MessageCustom.BUSINESS_ID_GROUP_CREATE)) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_CREATE);
                    String message = TUIConversationConstants.covert2HTMLString(getDisplayName(timMessage)) + messageCustom.content;
                    msgInfo.setExtra(message);
                }
            } catch (Exception e) {
                TUIConversationLog.e(TAG, "invalid json: " + data + ", exception:" + e);
            }
        }
        return msgInfo;
    }

    private static void setCallingExtra(ConversationMessageInfo messageInfo) {
        V2TIMMessage timMessage = messageInfo.getTimMessage();
        CallModel callModel = CallModel.convert2VideoCallData(timMessage);
        if (callModel == null) {
            return;
        }
        boolean isGroup = messageInfo.isGroup();
        String senderShowName = getDisplayName(timMessage);
        String content = "";
        Context context = TUIConversationService.getAppContext();
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

    private static ConversationMessageInfo createGroupTipsMessageInfo(V2TIMMessage timMessage, Context context) {
        ConversationMessageInfo msgInfo = new ConversationMessageInfo();
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
            targetUser = TUIConversationConstants.covert2HTMLString(targetUser);
        }

        if (!TextUtils.isEmpty(operationUser)) {
            operationUser = TUIConversationConstants.covert2HTMLString(operationUser);
        }

        String tipsMessage = "";
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_JOIN) {
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_JOIN);
            tipsMessage = targetUser + context.getString(R.string.join_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_INVITE) {
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_JOIN);
            tipsMessage = targetUser + context.getString(R.string.invite_joined_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_QUIT) {
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_QUITE);
            tipsMessage = operationUser + context.getString(R.string.quit_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_KICKED) {
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_KICK);
            tipsMessage = targetUser + context.getString(R.string.kick_group_tip);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN) {
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = targetUser + context.getString(R.string.be_group_manager);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN) {
            msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = targetUser + context.getString(R.string.cancle_group_manager);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE) {
            List<V2TIMGroupChangeInfo> modifyList = groupTipElem.getGroupChangeInfoList();
            for (int i = 0; i < modifyList.size(); i++) {
                V2TIMGroupChangeInfo modifyInfo = modifyList.get(i);
                int modifyType = modifyInfo.getType();
                if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NAME);
                    tipsMessage = operationUser + context.getString(R.string.modify_group_name_is) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + context.getString(R.string.modify_notice) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    if (!TextUtils.isEmpty(targetUser)) {
                        // 后台把新群主的资料放到了 getMemberList 中
                        tipsMessage = operationUser + context.getString(R.string.move_owner) + "\"" + targetUser + "\"";
                    } else {
                        // modifyInfo 中只有新群主的 userID
                        tipsMessage =
                                operationUser + context.getString(R.string.move_owner) + "\"" + TUIConversationConstants.covert2HTMLString(modifyInfo.getValue()) + "\"";
                    }
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + context.getString(R.string.modify_group_avatar);
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + context.getString(R.string.modify_notice) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL) {
                    msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
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
                msgInfo.setMsgType(ConversationMessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE);
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


    private static ConversationMessageInfo createNormalMessageInfo(V2TIMMessage timMessage, Context context, int type) {
        final ConversationMessageInfo msgInfo = new ConversationMessageInfo();
        setMessageInfoCommonAttributes(msgInfo, timMessage);
        if (type == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
            V2TIMTextElem txtEle = timMessage.getTextElem();
            msgInfo.setExtra(txtEle.getText());
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
            V2TIMFaceElem faceElem = timMessage.getFaceElem();
            if (faceElem.getIndex() < 1 || faceElem.getData() == null) {
                TUIConversationLog.e("ConversationMessageInfoUtil", "faceElem data is null or index<1");
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
                            TUIConversationLog.i("ConversationMessageInfoUtil getSoundToFile", "progress:" + progress);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            TUIConversationLog.e("ConversationMessageInfoUtil getSoundToFile", code + ":" + desc);
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
                    msgInfo.setStatus(ConversationMessageInfo.MSG_STATUS_SEND_SUCCESS);
                }
                msgInfo.setDownloadStatus(ConversationMessageInfo.MSG_STATUS_DOWNLOADED);
            } else {
                if (msgInfo.isSelf()) {
                    if (TextUtils.isEmpty(fileElem.getPath())) {
                        msgInfo.setDownloadStatus(ConversationMessageInfo.MSG_STATUS_UN_DOWNLOAD);
                    } else {
                        file = new File(fileElem.getPath());
                        if (file.exists()) {
                            msgInfo.setStatus(ConversationMessageInfo.MSG_STATUS_SEND_SUCCESS);
                            msgInfo.setDownloadStatus(ConversationMessageInfo.MSG_STATUS_DOWNLOADED);
                            finalPath = fileElem.getPath();
                        } else {
                            msgInfo.setDownloadStatus(ConversationMessageInfo.MSG_STATUS_UN_DOWNLOAD);
                        }
                    }
                } else {
                    msgInfo.setDownloadStatus(ConversationMessageInfo.MSG_STATUS_UN_DOWNLOAD);
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

    public static void setMessageInfoCommonAttributes(ConversationMessageInfo msgInfo, V2TIMMessage timMessage) {
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

    public static String getConversationDisplayString(ConversationMessageInfo messageInfo) {
        return messageInfo.getExtra().toString();
    }

    public static int convertTIMElemType2MessageInfoType(int type) {
        switch (type) {
            case V2TIMMessage.V2TIM_ELEM_TYPE_TEXT:
                return ConversationMessageInfo.MSG_TYPE_TEXT;
            case V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM:
                return ConversationMessageInfo.MSG_TYPE_CUSTOM;
            case V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE:
                return ConversationMessageInfo.MSG_TYPE_IMAGE;
            case V2TIMMessage.V2TIM_ELEM_TYPE_SOUND:
                return ConversationMessageInfo.MSG_TYPE_AUDIO;
            case V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO:
                return ConversationMessageInfo.MSG_TYPE_VIDEO;
            case V2TIMMessage.V2TIM_ELEM_TYPE_FILE:
                return ConversationMessageInfo.MSG_TYPE_FILE;
            case V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION:
                return ConversationMessageInfo.MSG_TYPE_LOCATION;
            case V2TIMMessage.V2TIM_ELEM_TYPE_FACE:
                return ConversationMessageInfo.MSG_TYPE_CUSTOM_FACE;
            case V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS:
                return ConversationMessageInfo.MSG_TYPE_TIPS;
            case V2TIMMessage.V2TIM_ELEM_TYPE_MERGER:
                return ConversationMessageInfo.MSG_TYPE_MERGE;
        }

        return -1;
    }
}
