package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IGroupPinnedView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class GroupChatPresenter extends ChatPresenter {
    private static final String TAG = GroupChatPresenter.class.getSimpleName();

    private GroupChatInfo groupChatInfo;
    private List<GroupMemberInfo> currentGroupMembers = new ArrayList<>();

    private GroupChatEventListener groupChatEventListener;
    private final List<TUIMessageBean> pinnedMessageList = new ArrayList<>();
    private IGroupPinnedView groupPinnedView;
    private int selfRoleInGroup = 0;

    public void initListener() {
        groupChatEventListener = new GroupChatEventListener() {
            @Override
            public void onGroupForceExit(String groupId) {
                GroupChatPresenter.this.onGroupForceExit(groupId);
            }

            @Override
            public void exitGroupChat(String chatId) {
                GroupChatPresenter.this.onExitChat(chatId);
            }

            @Override
            public void clearGroupMessage(String chatId) {
                if (TextUtils.equals(chatId, groupChatInfo.getId())) {
                    GroupChatPresenter.this.clearMessage();
                }
            }

            @Override
            public void onApplied() {
                GroupChatPresenter.this.onApplied();
            }

            @Override
            public void onRecvMessageRevoked(String msgID, UserBean userBean, String reason) {
                GroupChatPresenter.this.handleRevoke(msgID, userBean);
            }

            @Override
            public void onRecvNewMessage(TUIMessageBean message) {
                if (groupChatInfo == null || !TextUtils.equals(message.getGroupId(), groupChatInfo.getId())) {
                    TUIChatLog.i(TAG, "receive a new message , not belong to current chat.");
                } else {
                    GroupChatPresenter.this.onRecvNewMessage(message);
                }
            }

            @Override
            public void onReadReport(List<MessageReceiptInfo> receiptInfoList) {
                GroupChatPresenter.this.onReadReport(receiptInfoList);
            }

            @Override
            public void onGroupNameChanged(String groupId, String newName) {
                if (groupChatInfo == null || !TextUtils.equals(groupId, groupChatInfo.getId())) {
                    return;
                }
                GroupChatPresenter.this.onGroupNameChanged(newName);
            }

            @Override
            public void onGroupFaceUrlChanged(String groupId, String faceUrl) {
                if (groupChatInfo == null || !TextUtils.equals(groupId, groupChatInfo.getId())) {
                    return;
                }
                GroupChatPresenter.this.onGroupFaceUrlChanged(faceUrl);
            }

            @Override
            public void onRecvMessageModified(TUIMessageBean messageBean) {
                if (groupChatInfo != null && TextUtils.equals(messageBean.getGroupId(), groupChatInfo.getId())) {
                    GroupChatPresenter.this.onRecvMessageModified(messageBean);
                }
            }

            @Override
            public void addMessage(TUIMessageBean messageBean, String chatId) {
                if (TextUtils.equals(chatId, groupChatInfo.getId())) {
                    addMessageToUI(messageBean);
                }
            }

            @Override
            public void onMessageChanged(TUIMessageBean messageBean, int dataChangeType) {
                updateMessageInfo(messageBean, dataChangeType);
            }

            @Override
            public void onGroupMessagePinned(String groupID, TUIMessageBean messageBean, UserBean opUser) {
                if (groupChatInfo != null && TextUtils.equals(groupID, groupChatInfo.getId())) {
                    GroupChatPresenter.this.onGroupMessagePinned(messageBean, opUser);
                }
            }

            @Override
            public void onGroupMessageUnPinned(String groupID, String messageID, UserBean opUser) {
                if (groupChatInfo != null && TextUtils.equals(groupID, groupChatInfo.getId())) {
                    GroupChatPresenter.this.onGroupMessageUnPinned(messageID, opUser);
                }
            }

            @Override
            public void onGrantGroupAdmin(String groupID, List<String> newAdminUserIDList) {
                if (groupChatInfo != null) {
                    if (TextUtils.equals(groupID, groupChatInfo.getId()) && newAdminUserIDList.contains(TUILogin.getLoginUser())) {
                        selfRoleInGroup = GroupMemberInfo.ROLE_ADMIN;
                        onPinnedListChanged();
                    }
                }
            }

            @Override
            public void onRevokeGroupAdmin(String groupID, List<String> oldAdminUserIDList) {
                if (groupChatInfo != null) {
                    if (TextUtils.equals(groupID, groupChatInfo.getId()) && oldAdminUserIDList.contains(TUILogin.getLoginUser())) {
                        selfRoleInGroup = GroupMemberInfo.ROLE_MEMBER;
                        onPinnedListChanged();
                    }
                }
            }

            @Override
            public void onGrantGroupOwner(String groupID, String groupOwner) {
                if (groupChatInfo != null) {
                    if (TextUtils.equals(groupID, groupChatInfo.getId())) {
                        if (TextUtils.equals(groupOwner, TUILogin.getLoginUser())) {
                            selfRoleInGroup = GroupMemberInfo.ROLE_OWNER;
                            onPinnedListChanged();
                        } else {
                            if (selfRoleInGroup == GroupMemberInfo.ROLE_OWNER) {
                                selfRoleInGroup = GroupMemberInfo.ROLE_MEMBER;
                                onPinnedListChanged();
                            }
                        }
                    }
                }
            }
        };
        TUIChatService.getInstance().addGroupChatEventListener(groupChatEventListener);
        initMessageSender();
    }

    public void onReadReport(List<MessageReceiptInfo> receiptList) {
        if (groupChatInfo != null) {
            List<MessageReceiptInfo> processReceipts = new ArrayList<>();
            for (MessageReceiptInfo messageReceiptInfo : receiptList) {
                if (!TextUtils.equals(messageReceiptInfo.getGroupID(), groupChatInfo.getId())) {
                    continue;
                }
                processReceipts.add(messageReceiptInfo);
            }
            onMessageReadReceiptUpdated(loadedMessageInfoList, processReceipts);
        }
    }

    @Override
    public void loadMessage(int type, TUIMessageBean lastMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        if (groupChatInfo == null || isLoading) {
            return;
        }
        isLoading = true;
        String chatId = groupChatInfo.getId();
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD) {
            provider.loadGroupMessage(chatId, MSG_PAGE_COUNT, lastMessageInfo, new IUIKitCallback<Pair<List<TUIMessageBean>, Integer>>() {
                @Override
                public void onSuccess(Pair<List<TUIMessageBean>, Integer> dataPair) {
                    List<TUIMessageBean> data = dataPair.first;
                    TUIChatLog.i(TAG, "load group message success " + data.size());
                    if (lastMessageInfo == null) {
                        isHaveMoreNewMessage = false;
                    }
                    if (dataPair.second < MSG_PAGE_COUNT) {
                        isHaveMoreOldMessage = false;
                    }
                    onMessageLoadCompleted(data, type);
                    TUIChatUtils.callbackOnSuccess(callback, data);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "load group message failed " + errCode + "  " + errMsg);
                    TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                }
            });
        } else {
            loadHistoryMessageList(chatId, true, type, MSG_PAGE_COUNT, lastMessageInfo, callback);
        }
    }

    // This method is called after the message is loaded successfully
    @Override
    protected void onMessageLoadCompleted(List<TUIMessageBean> data, int getType) {
        groupReadReport(groupChatInfo.getId());
        getMessageReadReceipt(data, getType);
    }

    protected void addMessageToUI(TUIMessageBean messageInfo) {
        super.addMessageToUI(messageInfo, true);
        addGroupMessage(messageInfo);
    }

    private void addGroupMessage(TUIMessageBean message) {
        if (!(message instanceof TipsMessageBean)) {
            return;
        }
        TipsMessageBean tipsMessage = (TipsMessageBean) message;
        if (tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_JOIN) {
            provider.addJoinGroupMessage(tipsMessage, new IUIKitCallback<List<GroupMemberInfo>>() {
                @Override
                public void onSuccess(List<GroupMemberInfo> data) {
                    currentGroupMembers.addAll(data);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "addJoinGroupMessage error : " + errMsg);
                }
            });

        } else if (tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_QUITE || tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_KICK) {
            provider.addLeaveGroupMessage(tipsMessage, new IUIKitCallback<List<String>>() {
                @Override
                public void onSuccess(List<String> data) {
                    for (String memberUserId : data) {
                        for (int i = 0; i < currentGroupMembers.size(); i++) {
                            if (currentGroupMembers.get(i).getAccount().equals(memberUserId)) {
                                currentGroupMembers.remove(i);
                                break;
                            }
                        }
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {}
            });
        } else if (tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME
            || tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE) {
            provider.addModifyGroupMessage(tipsMessage, new IUIKitCallback<Pair<Integer, String>>() {
                @Override
                public void onSuccess(Pair<Integer, String> data) {
                    if (data.first == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME) {
                        groupChatInfo.setGroupName(data.second);
                        if (chatNotifyHandler != null) {
                            chatNotifyHandler.onGroupNameChanged(data.second);
                        }
                    }
                    if (data.first == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE) {
                        groupChatInfo.setNotice(data.second);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "addModifyGroupMessage error " + errMsg);
                }
            });
        }
    }

    protected void assembleGroupMessage(TUIMessageBean message) {
        message.setGroup(true);
        String groupType = groupChatInfo.getGroupType();
        if (TextUtils.equals(groupType, GroupChatInfo.GROUP_TYPE_AVCHATROOM) || TextUtils.equals(groupType, GroupChatInfo.GROUP_TYPE_COMMUNITY)
            || (TUIChatUtils.isCommunityGroup(groupChatInfo.getId()))) {
            message.setNeedReadReceipt(false);
        }
    }

    public void loadGroupMembers(String groupID, IUIKitCallback<List<GroupMemberInfo>> callback) {
        provider.loadGroupMembers(groupID, 0, callback);
    }

    public void onGroupForceExit(String groupId) {
        if (chatNotifyHandler != null && TextUtils.equals(groupId, groupChatInfo.getId())) {
            chatNotifyHandler.onGroupForceExit();
        }
    }

    public void onApplied() {
        loadApplyList(new IUIKitCallback<List<GroupApplyInfo>>() {
            @Override
            public void onSuccess(List<GroupApplyInfo> data) {
                if (chatNotifyHandler != null) {
                    chatNotifyHandler.onApplied(data.size());
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                super.onError(module, errCode, errMsg);
            }
        });
    }

    public void onGroupNameChanged(String newName) {
        if (chatNotifyHandler != null) {
            chatNotifyHandler.onGroupNameChanged(newName);
        }
    }

    public void onGroupFaceUrlChanged(String faceUrl) {
        if (chatNotifyHandler != null) {
            chatNotifyHandler.onGroupFaceUrlChanged(faceUrl);
        }
    }

    @Override
    public ChatInfo getChatInfo() {
        return groupChatInfo;
    }

    public void setGroupInfo(GroupChatInfo groupChatInfo) {
        this.groupChatInfo = groupChatInfo;
    }

    public void setGroupPinnedView(IGroupPinnedView groupPinnedView) {
        this.groupPinnedView = groupPinnedView;
    }

    @Override
    public void getChatName(String chatID, IUIKitCallback<String> callback) {
        if (!TextUtils.isEmpty(chatID)) {
            provider.getChatName(chatID, true, new IUIKitCallback<String>() {
                @Override
                public void onSuccess(String data) {
                    TUIChatUtils.callbackOnSuccess(callback, data);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnSuccess(callback, chatID);
                }
            });
        }
    }

    public void getGroupType(String groupID, TUIValueCallback<String> callback) {
        provider.getGroupInfo(groupID, new TUIValueCallback<V2TIMGroupInfo>() {
            @Override
            public void onSuccess(V2TIMGroupInfo object) {
                selfRoleInGroup = object.getRole();
                onPinnedListChanged();
                TUIValueCallback.onSuccess(callback, object.getGroupType());
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    @Override
    public void getChatFaceUrl(String chatID, IUIKitCallback<List<Object>> callback) {
        if (!TextUtils.isEmpty(chatID)) {
            provider.getChatFaceUrl(chatID, true, new IUIKitCallback<String>() {
                @Override
                public void onSuccess(String data) {
                    if (TextUtils.isEmpty(data) && TUIConfig.isEnableGroupGridAvatar()) {
                        provider.getChatGridFaceUrls(chatID, new IUIKitCallback<List<Object>>() {
                            @Override
                            public void onSuccess(List<Object> faceUrls) {
                                TUIChatUtils.callbackOnSuccess(callback, faceUrls);
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                            }
                        });
                    } else {
                        TUIChatUtils.callbackOnSuccess(callback, Collections.singletonList(data));
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                }
            });
        }
    }

    public void pinnedMessage(TUIMessageBean messageBean, TUICallback callback) {
        if (groupChatInfo == null) {
            return;
        }
        String groupID = groupChatInfo.getId();
        TUIChatLog.i(TAG, "pinnedMessage groupID:" + groupID);
        provider.pinGroupMessage(groupID, messageBean, true, new TUICallback() {
            @Override
            public void onSuccess() {
                onGroupMessagePinned(messageBean, null);
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "pinnedMessage failed, code:" + errorCode + ", msg:" + errorMessage);
                String errorString = ErrorMessageConverter.convertIMError(errorCode, errorMessage);
                if (errorCode == 10004) {
                    errorString = TUIChatService.getAppContext().getString(R.string.chat_message_is_pinned);
                }
                TUICallback.onError(callback, errorCode, errorString);
            }
        });
    }

    public void unpinnedMessage(TUIMessageBean messageBean, TUICallback callback) {
        if (groupChatInfo == null) {
            return;
        }
        String groupID = groupChatInfo.getId();
        TUIChatLog.i(TAG, "unpinnedMessage groupID:" + groupID);
        provider.pinGroupMessage(groupID, messageBean, false, new TUICallback() {
            @Override
            public void onSuccess() {
                onGroupMessageUnPinned(messageBean.getId(), null);
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "unpinnedMessage failed, code:" + errorCode + ", msg:" + errorMessage);
                String errorString = ErrorMessageConverter.convertIMError(errorCode, errorMessage);
                if (errorCode == 10004) {
                    errorString = TUIChatService.getAppContext().getString(R.string.chat_message_is_unpinned);
                }
                TUICallback.onError(callback, errorCode, errorString);
            }
        });
    }

    public void loadPinnedMessage(String groupID) {
        TUIChatLog.i(TAG, "loadPinnedMessage groupID:" + groupID);
        provider.getGroupPinnedMessageList(groupID, new TUIValueCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> messageBeans) {
                if (messageBeans != null) {
                    Collections.reverse(messageBeans);
                    pinnedMessageList.addAll(messageBeans);
                }
                onPinnedListChanged();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "loadPinnedMessage failed. code:" + errorCode + ", msg:" + errorMessage);
            }
        });
    }

    public void onGroupMessagePinned(TUIMessageBean messageBean, UserBean opUser) {
        boolean find = false;
        for (TUIMessageBean pinnedMessage : pinnedMessageList) {
            if (TextUtils.equals(pinnedMessage.getId(), messageBean.getId())) {
                int index = pinnedMessageList.indexOf(pinnedMessage);
                pinnedMessageList.set(index, messageBean);
                find = true;
                break;
            }
        }
        if (!find) {
            pinnedMessageList.add(0, messageBean);
        }
        onPinnedListChanged();
    }

    public void onGroupMessageUnPinned(String messageID, UserBean opUser) {
        for (TUIMessageBean pinnedMessage : pinnedMessageList) {
            if (TextUtils.equals(pinnedMessage.getId(), messageID)) {
                pinnedMessageList.remove(pinnedMessage);
                break;
            }
        }
        onPinnedListChanged();
    }

    public boolean isMessagePinned(String messageID) {
        for (TUIMessageBean pinnedMessage : pinnedMessageList) {
            if (TextUtils.equals(pinnedMessage.getId(), messageID)) {
                return true;
            }
        }
        return false;
    }

    public boolean canPinnedMessage() {
        return selfRoleInGroup == GroupMemberInfo.ROLE_ADMIN || selfRoleInGroup == GroupMemberInfo.ROLE_OWNER;
    }

    private void onPinnedListChanged() {
        if (groupPinnedView != null) {
            groupPinnedView.onPinnedListChanged(pinnedMessageList);
        }
    }
}
