package com.tencent.qcloud.tuikit.tuichat.model;

import static com.tencent.imsdk.BaseConstants.ERR_SDK_MSG_MODIFY_CONFLICT;
import static com.tencent.imsdk.BaseConstants.ERR_SUCC;
import static com.tencent.imsdk.v2.V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL;

import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;

import com.google.gson.Gson;
import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMCompleteCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMGroupApplicationResult;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMessageReadMemberList;
import com.tencent.imsdk.v2.V2TIMGroupTipsElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageListGetOption;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageFeature;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflineMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflineMessageContainerBean;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflinePushInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.UserStatusBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.OfflinePushInfoUtils;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatProvider {
    private static final String TAG = ChatProvider.class.getSimpleName();

    public static final int ERR_REVOKE_TIME_LIMIT_EXCEED = BaseConstants.ERR_REVOKE_TIME_LIMIT_EXCEED;
    public static final int ERR_REVOKE_TIME_LIMIT_SVR_GROUP = BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT;
    public static final int ERR_REVOKE_TIME_LIMIT_SVR_MESSAGE = BaseConstants.ERR_SVR_MSG_REVOKE_TIME_LIMIT;

    public void loadC2CMessage(String userId, int count, TUIMessageBean lastMessageInfo, IUIKitCallback<List<TUIMessageBean>> callBack) {
        V2TIMMessage lastTIMMsg = null;
        if (lastMessageInfo != null) {
            lastTIMMsg = lastMessageInfo.getV2TIMMessage();
        }
        V2TIMManager.getMessageManager().getC2CHistoryMessageList(userId, count, lastTIMMsg, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.e(
                    TAG, "loadChatMessages getC2CHistoryMessageList failed, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }

    public void loadGroupMessage(String groupId, int count, TUIMessageBean lastMessageInfo, IUIKitCallback<List<TUIMessageBean>> callBack) {
        V2TIMMessage lastTimMsg = null;
        if (lastMessageInfo != null) {
            lastTimMsg = lastMessageInfo.getV2TIMMessage();
        }
        V2TIMManager.getMessageManager().getGroupHistoryMessageList(groupId, count, lastTimMsg, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.e(
                    TAG, "loadChatMessages getC2CHistoryMessageList failed, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }

    public void loadHistoryMessageList(
        String chatId, boolean isGroup, int loadCount, TUIMessageBean locateMessageInfo, int getType, IUIKitCallback<List<TUIMessageBean>> callBack) {
        V2TIMMessageListGetOption optionBackward = new V2TIMMessageListGetOption();
        optionBackward.setCount(loadCount);
        if (getType == TUIChatConstants.GET_MESSAGE_FORWARD) {
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_OLDER_MSG);
        } else if (getType == TUIChatConstants.GET_MESSAGE_BACKWARD) {
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_CLOUD_NEWER_MSG);
        }
        if (locateMessageInfo != null) {
            optionBackward.setLastMsg(locateMessageInfo.getV2TIMMessage());
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
                TUIChatLog.e(TAG,
                    "loadChatMessages getHistoryMessageList optionBackward failed, code = " + code
                        + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }

    public void c2cReadReport(String userId) {
        V2TIMManager.getMessageManager().markC2CMessageAsRead(userId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(
                    TAG, "markC2CMessageAsRead setReadMessage failed, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess() {
                TUIChatLog.d(TAG, "markC2CMessageAsRead setReadMessage success");
            }
        });

        String conversationID = "c2c_" + userId;
        List<String> conversationIDList = new ArrayList<>();
        conversationIDList.add(conversationID);
        V2TIMManager.getConversationManager().markConversation(
            conversationIDList, V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD, false, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
                @Override
                public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                    if (v2TIMConversationOperationResults.size() > 0) {
                        V2TIMConversationOperationResult result = v2TIMConversationOperationResults.get(0);
                        TUIChatLog.d(TAG, "mark C2C conversation unread disable success, code:" + result.getResultCode() + "|msg:" + result.getResultInfo());
                    } else {
                        TUIChatLog.e(TAG, "mark C2C conversation unread disable failed, results size = 0");
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e(
                        TAG, "mark C2C conversation unread disable failed, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                }
            });
    }

    public void groupReadReport(String groupId) {
        V2TIMManager.getMessageManager().markGroupMessageAsRead(groupId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "markGroupMessageAsRead failed, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess() {
                TUIChatLog.d(TAG, "markGroupMessageAsRead success");
            }
        });

        String conversationID = "group_" + groupId;
        List<String> conversationIDList = new ArrayList<>();
        conversationIDList.add(conversationID);
        V2TIMManager.getConversationManager().markConversation(
            conversationIDList, V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD, false, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
                @Override
                public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                    if (v2TIMConversationOperationResults.size() > 0) {
                        V2TIMConversationOperationResult result = v2TIMConversationOperationResults.get(0);
                        TUIChatLog.d(TAG, "mark group conversation unread disable success, code:" + result.getResultCode() + "|msg:" + result.getResultInfo());
                    } else {
                        TUIChatLog.e(TAG, "mark group conversation unread disable failed, results size = 0");
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e(
                        TAG, "mark group conversation unread disable failed, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                }
            });
    }

    public void loadApplyInfo(final IUIKitCallback<List<GroupApplyInfo>> callBack) {
        final List<GroupApplyInfo> applies = new ArrayList<>();

        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "getGroupPendencyList failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                callBack.onError(TAG, code, ErrorMessageConverter.convertIMError(code, desc));
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

    private void setMessageTypingFeature(TUIMessageBean messageBean) {
        MessageFeature messageFeature = new MessageFeature();
        messageFeature.setNeedTyping(1);
        messageBean.setMessageTypingFeature(messageFeature);
    }

    public String sendTypingStatusMessage(TUIMessageBean message, String receiver, IUIKitCallback<TUIMessageBean> callBack) {
        String msgID = V2TIMManager.getMessageManager().sendMessage(
            message.getV2TIMMessage(), receiver, null, V2TIMMessage.V2TIM_PRIORITY_DEFAULT, true, null, new V2TIMSendCallback<V2TIMMessage>() {
                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.v(TAG, "sendMessage fail:" + code + "=" + ErrorMessageConverter.convertIMError(code, desc));
                    TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                }

                @Override
                public void onSuccess(V2TIMMessage v2TIMMessage) {
                    TUIChatLog.v(TAG, "sendMessage onSuccess:" + v2TIMMessage.getMsgID());
                    message.setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                    message.setV2TIMMessage(v2TIMMessage);
                    TUIChatUtils.callbackOnSuccess(callBack, message);
                    Map<String, Object> param = new HashMap<>();
                    param.put(TUIConstants.TUIChat.CHAT_ID, receiver);
                    TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS, param);
                }

                @Override
                public void onProgress(int progress) {}
            });
        return msgID;
    }

    public String sendMessage(TUIMessageBean message, ChatInfo chatInfo, IUIKitCallback<TUIMessageBean> callBack) {
        final V2TIMMessage v2TIMMessage = message.getV2TIMMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        // support message typing flag
        setMessageTypingFeature(message);

        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = message.getExtra();
        entity.sender = message.getSender();
        entity.nickname = chatInfo.getChatName();
        entity.faceUrl = TUIConfig.getSelfFaceUrl();
        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        containerBean.entity = entity;

        String userID = "";
        String groupID = "";
        boolean isGroup = false;
        if (chatInfo.getType() == V2TIMConversation.V2TIM_GROUP) {
            groupID = chatInfo.getId();
            isGroup = true;
            entity.chatType = V2TIMConversation.V2TIM_GROUP;
            entity.sender = groupID;
        } else {
            userID = chatInfo.getId();
        }

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isAndroidPrivateRing()) {
            v2TIMOfflinePushInfo.setAndroidSound(OfflinePushInfoUtils.PRIVATE_RING_NAME);
            v2TIMOfflinePushInfo.setAndroidFCMChannelID(OfflinePushInfoUtils.FCM_PUSH_CHANNEL_ID);
        }
        v2TIMOfflinePushInfo.setAndroidHuaWeiCategory("IM");
        v2TIMOfflinePushInfo.setAndroidVIVOCategory("IM");

        v2TIMMessage.setExcludedFromUnreadCount(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        v2TIMMessage.setExcludedFromLastMessage(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

        String msgID = V2TIMManager.getMessageManager().sendMessage(v2TIMMessage, isGroup ? null : userID, isGroup ? groupID : null,
                V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int progress) {
                        TUIChatUtils.callbackOnProgress(callBack, progress);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                        Map<String, Object> param = new HashMap<>();
                        param.put(TUIConstants.TUIChat.V2TIMMESSAGE, v2TIMMessage);
                        TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_FAILED, param);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        TUIChatLog.v(TAG, "sendMessage onSuccess:" + v2TIMMessage.getMsgID());
                        message.setV2TIMMessage(v2TIMMessage);
                        TUIChatUtils.callbackOnSuccess(callBack, message);
                        Map<String, Object> param = new HashMap<>();
                        param.put(TUIConstants.TUIChat.CHAT_ID, chatInfo.getId());
                        param.put(TUIConstants.TUIChat.V2TIMMESSAGE, v2TIMMessage);
                        TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS, param);
                    }
                });
        return msgID;
    }

    public String sendMessage(
        TUIMessageBean messageInfo, boolean isGroup, String id, OfflinePushInfo offlinePushInfo, IUIKitCallback<TUIMessageBean> callBack) {
        V2TIMMessage forwardMessage = messageInfo.getV2TIMMessage();
        forwardMessage.setExcludedFromUnreadCount(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromUnreadCount());
        forwardMessage.setExcludedFromLastMessage(TUIChatConfigs.getConfigs().getGeneralConfig().isExcludedFromLastMessage());

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = OfflinePushInfoUtils.convertOfflinePushInfoToV2PushInfo(offlinePushInfo);
        String msgId = V2TIMManager.getMessageManager().sendMessage(forwardMessage, isGroup ? null : id, isGroup ? id : null,
            V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {
                @Override
                public void onProgress(int progress) {
                    TUIChatUtils.callbackOnProgress(callBack, progress);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                }

                @Override
                public void onSuccess(V2TIMMessage v2TIMMessage) {
                    TUIMessageBean data = ChatMessageParser.parseMessage(v2TIMMessage);
                    TUIChatUtils.callbackOnSuccess(callBack, data);
                    Map<String, Object> param = new HashMap<>();
                    param.put(TUIConstants.TUIChat.CHAT_ID, id);
                    TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS, param);
                }
            });
        return msgId;
    }

    public void revokeMessage(TUIMessageBean messageInfo, IUIKitCallback<Void> callBack) {
        V2TIMManager.getMessageManager().revokeMessage(messageInfo.getV2TIMMessage(), new V2TIMCallback() {
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

    public void deleteMessages(List<TUIMessageBean> messageInfoList, IUIKitCallback<Void> callBack) {
        List<V2TIMMessage> v2TIMDeleteMessages = new ArrayList<>();
        for (int i = 0; i < messageInfoList.size(); i++) {
            v2TIMDeleteMessages.add(messageInfoList.get(i).getV2TIMMessage());
        }

        V2TIMManager.getMessageManager().deleteMessages(v2TIMDeleteMessages, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.w(TAG, "deleteMessages code:" + code + "|desc:" + ErrorMessageConverter.convertIMError(code, desc));
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
                TUIChatLog.e(TAG, "set drafts error : " + code + " " + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    public void getConversationLastMessage(String conversationId, IUIKitCallback<TUIMessageBean> callback) {
        V2TIMManager.getConversationManager().getConversation(conversationId, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "getConversationLastMessage error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                V2TIMMessage lastMessage = v2TIMConversation.getLastMessage();
                TUIMessageBean messageInfo = ChatMessageParser.parseMessage(lastMessage);
                TUIChatUtils.callbackOnSuccess(callback, messageInfo);
            }
        });
    }

    public void sendGroupTipsMessage(String groupId, String message, IUIKitCallback<TUIMessageBean> callback) {
        V2TIMMessage createTips = ChatMessageBuilder.buildGroupCustomMessage(message);
        V2TIMManager.getMessageManager().sendMessage(
            createTips, null, groupId, V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, null, new V2TIMSendCallback<V2TIMMessage>() {
                @Override
                public void onProgress(int progress) {}

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, TAG, code, desc);
                }

                @Override
                public void onSuccess(V2TIMMessage v2TIMMessage) {
                    TUIChatLog.i(TAG, "sendTipsMessage onSuccess");
                    TUIMessageBean messageInfo = ChatMessageParser.parseMessage(v2TIMMessage);
                    TUIChatUtils.callbackOnSuccess(callback, messageInfo);
                }
            });
    }

    public void addJoinGroupMessage(TUIMessageBean messageInfo, IUIKitCallback<List<GroupMemberInfo>> callback) {
        V2TIMGroupTipsElem groupTips = null;
        V2TIMMessage v2TIMMessage = messageInfo.getV2TIMMessage();
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

    public void addLeaveGroupMessage(TUIMessageBean messageInfo, IUIKitCallback<List<String>> callback) {
        V2TIMGroupTipsElem groupTips = null;
        V2TIMMessage v2TIMMessage = messageInfo.getV2TIMMessage();
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

    public void addModifyGroupMessage(TUIMessageBean message, IUIKitCallback<Pair<Integer, String>> callback) {
        V2TIMGroupTipsElem groupTips = null;
        V2TIMMessage v2TIMMessage = message.getV2TIMMessage();
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
                TUIChatUtils.callbackOnSuccess(callback, new Pair<>(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME, modifyInfo.getValue()));
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                TUIChatUtils.callbackOnSuccess(callback, new Pair<>(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE, modifyInfo.getValue()));
            }
        }
    }

    public boolean checkFailedMessageInfo(TUIMessageBean message) {
        if (message == null) {
            return true;
        }
        V2TIMMessage v2TIMMessage = message.getV2TIMMessage();
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

    public void findMessage(List<String> msgIds, IUIKitCallback<List<TUIMessageBean>> callback) {
        V2TIMManager.getMessageManager().findMessages(msgIds, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> messages) {
                List<TUIMessageBean> messageBeans = ChatMessageParser.parseMessageList(messages);
                TUIChatUtils.callbackOnSuccess(callback, messageBeans);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getGroupMessageBySeq(String chatId, long seq, IUIKitCallback<List<TUIMessageBean>> callback) {
        V2TIMMessageListGetOption optionBackward = new V2TIMMessageListGetOption();
        optionBackward.setCount(1);
        optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_LOCAL_OLDER_MSG);
        optionBackward.setLastMsgSeq(seq);
        optionBackward.setGroupID(chatId);

        V2TIMManager.getMessageManager().getHistoryMessageList(optionBackward, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, TAG, code, desc);
                TUIChatLog.e(TAG, "loadChatMessages getHistoryMessageList optionBackward failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(v2TIMMessages);
                TUIChatUtils.callbackOnSuccess(callback, messageInfoList);
            }
        });
    }

    public void downloadMergerMessage(MergeMessageBean messageBean, IUIKitCallback<List<TUIMessageBean>> callback) {
        V2TIMMergerElem mergerElem = messageBean.getMergerElem();
        if (mergerElem != null) {
            mergerElem.downloadMergerMessage(new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onSuccess(List<V2TIMMessage> messageList) {
                    List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(messageList);
                    TUIChatUtils.callbackOnSuccess(callback, messageInfoList);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, "MergeMessageElemBean", code, desc);
                }
            });
        }
    }

    public void getMessageReadReceipt(List<TUIMessageBean> messageBeanList, IUIKitCallback<List<MessageReceiptInfo>> callback) {
        List<V2TIMMessage> messageList = new ArrayList<>();
        for (TUIMessageBean messageBean : messageBeanList) {
            messageList.add(messageBean.getV2TIMMessage());
        }

        V2TIMManager.getMessageManager().getMessageReadReceipts(messageList, new V2TIMValueCallback<List<V2TIMMessageReceipt>>() {
            @Override
            public void onSuccess(List<V2TIMMessageReceipt> v2TIMGroupMessageReceipts) {
                List<MessageReceiptInfo> messageReceiptInfoList = new ArrayList<>();
                for (V2TIMMessageReceipt receipt : v2TIMGroupMessageReceipts) {
                    MessageReceiptInfo messageReceiptInfo = new MessageReceiptInfo();
                    messageReceiptInfo.setMessageReceipt(receipt);
                    messageReceiptInfoList.add(messageReceiptInfo);
                }
                TUIChatUtils.callbackOnSuccess(callback, messageReceiptInfoList);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void sendMessageReadReceipt(List<TUIMessageBean> messageBeanList, IUIKitCallback<Void> callback) {
        List<V2TIMMessage> messageList = new ArrayList<>();
        for (TUIMessageBean messageBean : messageBeanList) {
            messageList.add(messageBean.getV2TIMMessage());
        }

        V2TIMManager.getMessageManager().sendMessageReadReceipts(messageList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIChatUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getGroupMessageReadMembers(
        TUIMessageBean messageBean, boolean isRead, int count, long nextSeq, IUIKitCallback<GroupMessageReadMembersInfo> callback) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        int filter = isRead ? V2TIMMessage.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ : V2TIMMessage.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD;
        V2TIMManager.getMessageManager().getGroupMessageReadMemberList(
            message, filter, nextSeq, count, new V2TIMValueCallback<V2TIMGroupMessageReadMemberList>() {
                @Override
                public void onSuccess(V2TIMGroupMessageReadMemberList v2TIMGroupMessageReadMembers) {
                    GroupMessageReadMembersInfo messageReadMembersInfo = new GroupMessageReadMembersInfo();
                    messageReadMembersInfo.setReadMembers(v2TIMGroupMessageReadMembers);
                    TUIChatUtils.callbackOnSuccess(callback, messageReadMembersInfo);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, code, desc);
                }
            });
    }

    public void modifyMessage(TUIMessageBean messageBean, IUIKitCallback<TUIMessageBean> callback) {
        V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
        V2TIMManager.getMessageManager().modifyMessage(v2TIMMessage, new V2TIMCompleteCallback<V2TIMMessage>() {
            @Override
            public void onComplete(int code, String desc, V2TIMMessage v2TIMMessage) {
                TUIMessageBean modifiedMessage = ChatMessageParser.parseMessage(v2TIMMessage);
                if (code == ERR_SDK_MSG_MODIFY_CONFLICT) {
                    TUIChatUtils.callbackOnError(callback, code, desc, modifiedMessage);
                } else {
                    TUIChatUtils.callbackOnSuccess(callback, modifiedMessage);
                }
            }
        });
    }

    public void getUserBean(List<String> userIds, IUIKitCallback<List<UserBean>> callback) {
        V2TIMManager.getFriendshipManager().getFriendsInfo(userIds, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                List<UserBean> reactUserBeanList = new ArrayList<>();
                for (V2TIMFriendInfoResult result : v2TIMFriendInfoResults) {
                    UserBean reactUserBean = new UserBean();
                    reactUserBean.setUserId(result.getFriendInfo().getUserID());
                    reactUserBean.setFriendRemark(result.getFriendInfo().getFriendRemark());
                    reactUserBean.setFaceUrl(result.getFriendInfo().getUserProfile().getFaceUrl());
                    if (result.getFriendInfo().getUserProfile() != null) {
                        reactUserBean.setNikeName(result.getFriendInfo().getUserProfile().getNickName());
                    }
                    reactUserBeanList.add(reactUserBean);
                }
                TUIChatUtils.callbackOnSuccess(callback, reactUserBeanList);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getGroupMembersInfo(String groupId, List<String> groupMemberIds, IUIKitCallback<List<GroupMemberInfo>> callback) {
        if (TUIChatUtils.isTopicGroup(groupId)) {
            groupId = TUIChatUtils.getGroupIDFromTopicID(groupId);
        }
        V2TIMManager.getGroupManager().getGroupMembersInfo(groupId, groupMemberIds, new V2TIMValueCallback<List<V2TIMGroupMemberFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfos) {
                List<GroupMemberInfo> groupMemberInfos = new ArrayList<>();
                for (V2TIMGroupMemberFullInfo fullInfo : v2TIMGroupMemberFullInfos) {
                    groupMemberInfos.add(new GroupMemberInfo().covertTIMGroupMemberInfo(fullInfo));
                }
                TUIChatUtils.callbackOnSuccess(callback, groupMemberInfos);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void loadUserStatus(List<String> userIDs, IUIKitCallback<Map<String, UserStatusBean>> callback) {
        if (userIDs == null || userIDs.size() == 0) {
            TUIChatLog.d(TAG, "loadContactUserStatus datasource is null");
            TUIChatUtils.callbackOnError(callback, -1, "data list is empty");
            return;
        }

        V2TIMManager.getInstance().getUserStatus(userIDs, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                TUIChatLog.i(TAG, "getUserStatus success");
                Map<String, UserStatusBean> userStatusBeanMap = new HashMap<>();
                for (V2TIMUserStatus item : v2TIMUserStatuses) {
                    UserStatusBean statusBean = new UserStatusBean();
                    statusBean.setUserID(item.getUserID());
                    statusBean.setOnlineStatus(item.getStatusType());
                    userStatusBeanMap.put(item.getUserID(), statusBean);
                }
                TUIChatUtils.callbackOnSuccess(callback, userStatusBeanMap);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "getUserStatus error code = " + code + ",des = " + desc);
                TUIChatUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void loadGroupMembers(String groupID, long nextSeq, final IUIKitCallback<List<GroupMemberInfo>> callBack) {
        int filter = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL;
        V2TIMManager.getGroupManager().getGroupMemberList(groupID, filter, nextSeq, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "loadGroupMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                TUIChatUtils.callbackOnError(callBack, code, desc);
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<GroupMemberInfo> members = new ArrayList<>();
                for (int i = 0; i < v2TIMGroupMemberInfoResult.getMemberInfoList().size(); i++) {
                    GroupMemberInfo member = new GroupMemberInfo();
                    members.add(member.covertTIMGroupMemberInfo(v2TIMGroupMemberInfoResult.getMemberInfoList().get(i)));
                }
                TUIChatUtils.callbackOnSuccess(callBack, members);
            }
        });
    }

    public void getChatName(String chatID, boolean isGroup, IUIKitCallback<String> callback) {
        if (!isGroup) {
            V2TIMManager.getFriendshipManager().getFriendsInfo(Collections.singletonList(chatID), new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
                @Override
                public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                    if (v2TIMFriendInfoResults != null && !v2TIMFriendInfoResults.isEmpty()) {
                        V2TIMFriendInfo v2TIMFriendInfo = v2TIMFriendInfoResults.get(0).getFriendInfo();
                        String result;
                        if (v2TIMFriendInfo != null) {
                            String remark = v2TIMFriendInfo.getFriendRemark();
                            String nickName = null;
                            String id = v2TIMFriendInfo.getUserID();
                            V2TIMUserFullInfo fullInfo = v2TIMFriendInfo.getUserProfile();
                            if (fullInfo != null) {
                                nickName = fullInfo.getNickName();
                            }
                            if (!TextUtils.isEmpty(remark)) {
                                result = remark;
                            } else if (!TextUtils.isEmpty(nickName)) {
                                result = nickName;
                            } else {
                                result = id;
                            }
                        } else {
                            result = chatID;
                        }
                        TUIChatUtils.callbackOnSuccess(callback, result);
                    } else {
                        V2TIMManager.getInstance().getUsersInfo(Collections.singletonList(chatID), new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                            @Override
                            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                                if (v2TIMUserFullInfos != null && !v2TIMUserFullInfos.isEmpty()) {
                                    TUIChatUtils.callbackOnSuccess(callback, v2TIMUserFullInfos.get(0).getUserID());
                                } else {
                                    TUIChatUtils.callbackOnError(callback, -1, "get userInfo failed");
                                }
                            }

                            @Override
                            public void onError(int code, String desc) {
                                TUIChatUtils.callbackOnError(callback, code, desc);
                            }
                        });
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, code, desc);
                }
            });
        } else {
            V2TIMManager.getGroupManager().getGroupsInfo(Collections.singletonList(chatID), new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
                @Override
                public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                    if (v2TIMGroupInfoResults != null && !v2TIMGroupInfoResults.isEmpty()) {
                        V2TIMGroupInfoResult v2TIMGroupInfoResult = v2TIMGroupInfoResults.get(0);
                        if (v2TIMGroupInfoResult.getResultCode() == ERR_SUCC) {
                            V2TIMGroupInfo groupInfo = v2TIMGroupInfoResults.get(0).getGroupInfo();
                            String result;
                            if (groupInfo != null) {
                                result = groupInfo.getGroupName();
                            } else {
                                result = chatID;
                            }
                            TUIChatUtils.callbackOnSuccess(callback, result);
                        } else {
                            TUIChatUtils.callbackOnError(callback, v2TIMGroupInfoResult.getResultCode(), v2TIMGroupInfoResult.getResultMessage());
                        }
                    } else {
                        TUIChatUtils.callbackOnError(callback, -1, "getGroupsInfo failed");
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, code, desc);
                }
            });
        }
    }

    public void getChatFaceUrl(String chatID, boolean isGroup, IUIKitCallback<String> callback) {
        if (isGroup) {
            V2TIMManager.getGroupManager().getGroupsInfo(Collections.singletonList(chatID), new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
                @Override
                public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                    V2TIMGroupInfoResult result = v2TIMGroupInfoResults.get(0);
                    if (result.getResultCode() == ERR_SUCC) {
                        TUIChatUtils.callbackOnSuccess(callback, result.getGroupInfo().getFaceUrl());
                    } else {
                        TUIChatUtils.callbackOnError(callback, result.getResultCode(), result.getResultMessage());
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, code, desc);
                }
            });
        } else {
            V2TIMManager.getInstance().getUsersInfo(Collections.singletonList(chatID), new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                @Override
                public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                    V2TIMUserFullInfo result = v2TIMUserFullInfos.get(0);
                    TUIChatUtils.callbackOnSuccess(callback, result.getFaceUrl());
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, code, desc);
                }
            });
        }
    }

    public void getChatGridFaceUrls(String groupID, IUIKitCallback<List<Object>> callback) {
        V2TIMManager.getGroupManager().getGroupMemberList(
            groupID, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL, 0, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
                @Override
                public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                    List<V2TIMGroupMemberFullInfo> infoList = v2TIMGroupMemberInfoResult.getMemberInfoList();
                    int max = 9;
                    List<Object> faceUrls = new ArrayList<>();
                    for (V2TIMGroupMemberFullInfo fullInfo : infoList) {
                        if (max > 0) {
                            faceUrls.add(fullInfo.getFaceUrl());
                            max--;
                        } else {
                            break;
                        }
                    }
                    TUIChatUtils.callbackOnSuccess(callback, faceUrls);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, code, desc);
                }
            });
    }
}
