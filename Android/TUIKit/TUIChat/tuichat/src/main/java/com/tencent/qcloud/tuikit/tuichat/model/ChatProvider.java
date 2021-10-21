package com.tencent.qcloud.tuikit.tuichat.model;

import android.util.Log;
import android.util.Pair;

import com.google.gson.Gson;
import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMCreateGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMGroupApplicationResult;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupTipsElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageListGetOption;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflineMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflineMessageContainerBean;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflinePushInfo;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageInfoUtil;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.util.OfflinePushInfoUtils;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.imsdk.v2.V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL;

public class ChatProvider {
    private static final String TAG = ChatProvider.class.getSimpleName();

    public static final int ERR_REVOKE_TIME_LIMIT_EXCEED = BaseConstants.ERR_REVOKE_TIME_LIMIT_EXCEED;

    public void loadC2CMessage(String userId, int count, MessageInfo lastMessageInfo, IUIKitCallback<List<MessageInfo>> callBack) {
        V2TIMMessage lastTIMMsg = null;
        if (lastMessageInfo != null) {
            lastTIMMsg = lastMessageInfo.getTimMessage();
        }
        V2TIMManager.getMessageManager().getC2CHistoryMessageList(userId, count, lastTIMMsg, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.e(TAG, "loadChatMessages getC2CHistoryMessageList failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<MessageInfo> messageInfoList = ChatMessageInfoUtil.convertTIMMessages2MessageInfos(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }

    public void loadGroupMessage(String groupId, int count, MessageInfo lastMessageInfo, IUIKitCallback<List<MessageInfo>> callBack) {
        V2TIMMessage lastTimMsg = null;
        if (lastMessageInfo != null) {
            lastTimMsg = lastMessageInfo.getTimMessage();
        }
        V2TIMManager.getMessageManager().getGroupHistoryMessageList(groupId, count, lastTimMsg, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.e(TAG, "loadChatMessages getGroupHistoryMessageList failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<MessageInfo> messageInfoList = ChatMessageInfoUtil.convertTIMMessages2MessageInfos(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }

    public void loadHistoryMessageList(String chatId, boolean isGroup, int loadCount,
                                       MessageInfo locateMessageInfo, int getType, IUIKitCallback<List<MessageInfo>> callBack) {
        V2TIMMessageListGetOption optionBackward = new V2TIMMessageListGetOption();
        optionBackward.setCount(loadCount);
        if (getType == TUIChatConstants.GET_MESSAGE_FORWARD) {
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_OLDER_MSG);
        } else if (getType == TUIChatConstants.GET_MESSAGE_BACKWARD) {
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_NEWER_MSG);
        }
        if (locateMessageInfo != null) {
            optionBackward.setLastMsg(locateMessageInfo.getTimMessage());
        }
        if (isGroup) {
            optionBackward.setGroupID(chatId);
        } else {
            optionBackward.setUserID(chatId);
        }

        V2TIMManager.getMessageManager().getHistoryMessageList(optionBackward, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.e(TAG, "loadChatMessages getHistoryMessageList optionBackward failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<MessageInfo> messageInfoList = ChatMessageInfoUtil.convertTIMMessages2MessageInfos(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }

    public void c2cReadReport(String userId) {
        V2TIMManager.getMessageManager().markC2CMessageAsRead(userId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "markC2CMessageAsRead setReadMessage failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {
                TUIChatLog.d(TAG, "markC2CMessageAsRead setReadMessage success");
            }
        });
    }

    public void groupReadReport(String groupId) {
        V2TIMManager.getMessageManager().markGroupMessageAsRead(groupId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "markGroupMessageAsRead failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {
                TUIChatLog.d(TAG, "markGroupMessageAsRead success");
            }
        });
    }

    public void loadApplyInfo(final IUIKitCallback<List<GroupApplyInfo>> callBack) {
        final List<GroupApplyInfo> applies = new ArrayList<>();

        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "getGroupPendencyList failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(V2TIMGroupApplicationResult v2TIMGroupApplicationResult) {
                List<V2TIMGroupApplication> v2TIMGroupApplicationList = v2TIMGroupApplicationResult.getGroupApplicationList();
                for (int i = 0; i < v2TIMGroupApplicationList.size(); i++) {
                    GroupApplyInfo info = new GroupApplyInfo(v2TIMGroupApplicationList.get(i));
                    info.setStatus(0);
                    applies.add(info);
                }
                callBack.onSuccess(applies);
            }
        });
    }

    public String sendMessage(MessageInfo message, ChatInfo chatInfo, IUIKitCallback<MessageInfo> callBack) {
        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = message.getExtra().toString();
        entity.sender = message.getFromUser();
        entity.nickname = chatInfo.getChatName();
        entity.faceUrl = TUIChatConfigs.getConfigs().getGeneralConfig().getUserFaceUrl();
        containerBean.entity = entity;

        String userID = "";
        String groupID = "";
        String groupType = "";
        boolean isGroup = false;
        if (chatInfo.getType() == V2TIMConversation.V2TIM_GROUP) {
            groupID = chatInfo.getId();
            groupType = chatInfo.getGroupType();
            isGroup = true;
            entity.chatType = V2TIMConversation.V2TIM_GROUP;
            entity.sender = groupID;
        } else {
            userID = chatInfo.getId();
        }

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");

        final V2TIMMessage v2TIMMessage = message.getTimMessage();
        v2TIMMessage.setExcludedFromUnreadCount(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        v2TIMMessage.setExcludedFromLastMessage(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

        String msgID = V2TIMManager.getMessageManager().sendMessage(v2TIMMessage, isGroup ? null : userID, isGroup ? groupID : null,
                V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int progress) {

                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        TUIChatLog.v(TAG, "sendMessage onSuccess:" + v2TIMMessage.getMsgID());
                        message.setMsgTime(v2TIMMessage.getTimestamp());
                        TUIChatUtils.callbackOnSuccess(callBack, message);
                    }
                });
        return msgID;
    }

    public String sendMessage(MessageInfo message, String groupType, OfflinePushInfo pushInfo,
                              String receiver, boolean isGroup, boolean onlineUserOnly, IUIKitCallback<MessageInfo> callBack) {
        final V2TIMMessage v2TIMMessage = message.getTimMessage();
        v2TIMMessage.setExcludedFromUnreadCount(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        v2TIMMessage.setExcludedFromLastMessage(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

        TUIChatLog.i(TAG, "sendMessage to " + receiver);
        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = OfflinePushInfoUtils.convertOfflinePushInfoToV2PushInfo(pushInfo);
        String msgID = V2TIMManager.getMessageManager().sendMessage(message.getTimMessage(),
                isGroup ? null : receiver, isGroup ? receiver : null, V2TIMMessage.V2TIM_PRIORITY_DEFAULT,
                onlineUserOnly, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {

                    @Override
                    public void onError(int code, String desc) {
                        TUIChatLog.v(TAG, "sendMessage fail:" + code + "=" + desc);
                        TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        TUIChatLog.v(TAG, "sendMessage onSuccess:" + v2TIMMessage.getMsgID());
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                        message.setMsgTime(v2TIMMessage.getTimestamp());
                        TUIChatUtils.callbackOnSuccess(callBack, message);
                    }

                    @Override
                    public void onProgress(int progress) {

                    }
                });
        return msgID;
    }

    public String sendMessage(MessageInfo messageInfo, boolean isGroup, String id, OfflinePushInfo offlinePushInfo, IUIKitCallback<MessageInfo> callBack) {
        V2TIMMessage forwardMessage = messageInfo.getTimMessage();
        forwardMessage.setExcludedFromUnreadCount(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        forwardMessage.setExcludedFromLastMessage(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = OfflinePushInfoUtils.convertOfflinePushInfoToV2PushInfo(offlinePushInfo);
        String msgId = V2TIMManager.getMessageManager().sendMessage(forwardMessage, isGroup ? null : id, isGroup ? id : null,
                V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int progress) {

                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        MessageInfo data = ChatMessageInfoUtil.convertTIMMessage2MessageInfo(v2TIMMessage);
                        TUIChatUtils.callbackOnSuccess(callBack, data);
                    }
                });
        return msgId;
    }


    public void revokeMessage(MessageInfo messageInfo, IUIKitCallback<Void> callBack) {
        V2TIMManager.getMessageManager().revokeMessage(messageInfo.getTimMessage(), new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                TUIChatUtils.callbackOnSuccess(callBack, null);
            }
        });
    }

    public void deleteMessages(List<MessageInfo> messageInfoList, IUIKitCallback<Void> callBack) {

        List<V2TIMMessage> v2TIMDeleteMessages = new ArrayList<>();
        for (int i = 0; i < messageInfoList.size(); i++) {
            v2TIMDeleteMessages.add(messageInfoList.get(i).getTimMessage());
        }

        V2TIMManager.getMessageManager().deleteMessages(v2TIMDeleteMessages, new V2TIMCallback() {

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.w(TAG, "deleteMessages code:" + code + "|desc:" + desc);
            }

            @Override
            public void onSuccess() {
                TUIChatLog.i(TAG, "deleteMessages success");
                TUIChatUtils.callbackOnSuccess(callBack, null);
            }
        });
    }

    public void setDraft(String conversationId, String draft) {
        V2TIMManager.getConversationManager().setConversationDraft(conversationId, draft, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIChatLog.i(TAG, "set draft success " + draft);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "set drafts error : " + code + " " + desc);
            }
        });
    }

    public void getConversationLastMessage(String conversationId, IUIKitCallback<MessageInfo> callback) {
        V2TIMManager.getConversationManager().getConversation(conversationId, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "getConversationLastMessage error:" + code + ", desc:" + desc);
            }

            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                V2TIMMessage lastMessage = v2TIMConversation.getLastMessage();
                MessageInfo messageInfo = ChatMessageInfoUtil.convertTIMMessage2MessageInfo(lastMessage);
                TUIChatUtils.callbackOnSuccess(callback, messageInfo);
            }
        });
    }

    public void createGroup(GroupInfo groupInfo, IUIKitCallback<String> callback) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupType(groupInfo.getGroupType());
        v2TIMGroupInfo.setGroupName(groupInfo.getGroupName());
        v2TIMGroupInfo.setGroupAddOpt(groupInfo.getJoinType());

        List<V2TIMCreateGroupMemberInfo> v2TIMCreateGroupMemberInfoList = new ArrayList<>();
        for (int i = 0; i < groupInfo.getMemberDetails().size(); i++) {
            GroupMemberInfo groupMemberInfo = groupInfo.getMemberDetails().get(i);
            V2TIMCreateGroupMemberInfo v2TIMCreateGroupMemberInfo = new V2TIMCreateGroupMemberInfo();
            v2TIMCreateGroupMemberInfo.setUserID(groupMemberInfo.getAccount());
            v2TIMCreateGroupMemberInfoList.add(v2TIMCreateGroupMemberInfo);
        }

        V2TIMManager.getGroupManager().createGroup(v2TIMGroupInfo, v2TIMCreateGroupMemberInfoList, new V2TIMValueCallback<String>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "createGroup failed, code: " + code + "|desc: " + desc);
                TUIChatUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(final String groupId) {

            }
        });
    }

    public void sendGroupTipsMessage(String groupId, String message, IUIKitCallback<MessageInfo> callback) {
        V2TIMMessage createTips = ChatMessageInfoUtil.buildGroupCustomMessage(message);
        V2TIMManager.getMessageManager().sendMessage(createTips, null, groupId,
                V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, null, new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int progress) {

                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIChatUtils.callbackOnError(callback, TAG, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        TUIChatLog.i(TAG, "sendTipsMessage onSuccess");
                        MessageInfo messageInfo = ChatMessageInfoUtil.convertTIMMessage2MessageInfo(v2TIMMessage);
                        TUIChatUtils.callbackOnSuccess(callback, messageInfo);
                    }
                });

    }

    public void addJoinGroupMessage(MessageInfo messageInfo, IUIKitCallback<List<GroupMemberInfo>> callback) {
        V2TIMGroupTipsElem groupTips = null;
        V2TIMMessage v2TIMMessage = messageInfo.getTimMessage();
        if (v2TIMMessage != null) {
            groupTips = v2TIMMessage.getGroupTipsElem();
        }
        if (groupTips == null) {
            TUIChatUtils.callbackOnError(callback, TAG, -1, "groupTips is null");
            return;
        }
        List<V2TIMGroupMemberInfo> memberInfos = groupTips.getMemberList();
        List<GroupMemberInfo> groupMemberInfoList = new ArrayList<>();
        if (memberInfos.size() > 0) {
            for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberInfos) {
                GroupMemberInfo member = new GroupMemberInfo();
                member.covertTIMGroupMemberInfo(v2TIMGroupMemberInfo);
                groupMemberInfoList.add(member);
            }
        } else {
            GroupMemberInfo member = new GroupMemberInfo();
            member.covertTIMGroupMemberInfo(groupTips.getOpMember());
            groupMemberInfoList.add(member);
        }
        TUIChatUtils.callbackOnSuccess(callback, groupMemberInfoList);
    }
    public void addLeaveGroupMessage(MessageInfo messageInfo, IUIKitCallback<List<String>> callback) {
        V2TIMGroupTipsElem groupTips = null;
        V2TIMMessage v2TIMMessage = messageInfo.getTimMessage();
        if (v2TIMMessage != null) {
            groupTips = v2TIMMessage.getGroupTipsElem();
        }
        if (groupTips == null) {
            TUIChatUtils.callbackOnError(callback, TAG, -1, "groupTips is null");
            return;
        }
        List<V2TIMGroupMemberInfo> memberInfos = groupTips.getMemberList();
        List<String> memberUserIds = new ArrayList<>();
        if (memberInfos.size() > 0) {
            for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberInfos) {
                String memberUserID = v2TIMGroupMemberInfo.getUserID();
                memberUserIds.add(memberUserID);
            }
        } else {
            V2TIMGroupMemberInfo memberInfo = groupTips.getOpMember();
            memberUserIds.add(memberInfo.getUserID());
        }
        TUIChatUtils.callbackOnSuccess(callback, memberUserIds);
    }
    public void addModifyGroupMessage(MessageInfo messageInfo, IUIKitCallback<Pair<Integer, String>> callback) {
        V2TIMGroupTipsElem groupTips = null;
        V2TIMMessage v2TIMMessage = messageInfo.getTimMessage();
        if (v2TIMMessage != null) {
            groupTips = v2TIMMessage.getGroupTipsElem();
        }
        if (groupTips == null) {
            TUIChatUtils.callbackOnError(callback, TAG, -1, "groupTips is null");
            return;
        }
        List<V2TIMGroupChangeInfo> modifyList = groupTips.getGroupChangeInfoList();
        if (modifyList.size() > 0) {
            V2TIMGroupChangeInfo modifyInfo = modifyList.get(0);
            int modifyType = modifyInfo.getType();
            if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                TUIChatUtils.callbackOnSuccess(callback, new Pair<>(MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME, modifyInfo.getValue()));
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                TUIChatUtils.callbackOnSuccess(callback, new Pair<>(MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE, modifyInfo.getValue()));
            }
        }
    }

    public boolean checkFailedMessageInfo(MessageInfo messageInfo) {
        if (messageInfo == null) {
            return true;
        }
        V2TIMMessage v2TIMMessage = messageInfo.getTimMessage();
        if (v2TIMMessage.getStatus() == V2TIM_MSG_STATUS_SEND_FAIL) {
            return true;
        } else {
            return false;
        }
    }

    public void getFriendName(String id, IUIKitCallback<String[]> callback) {
        List<String> userIdList = new ArrayList<>();
        userIdList.add(id);
        V2TIMManager.getFriendshipManager().getFriendsInfo(userIdList, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                V2TIMFriendInfoResult result = v2TIMFriendInfoResults.get(0);
                String[] nameArray = {result.getFriendInfo().getFriendRemark(), result.getFriendInfo().getUserProfile().getNickName()};
                TUIChatUtils.callbackOnSuccess(callback, nameArray);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }
}