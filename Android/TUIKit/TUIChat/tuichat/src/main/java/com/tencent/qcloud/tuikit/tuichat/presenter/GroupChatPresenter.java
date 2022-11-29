package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.List;

public class GroupChatPresenter extends ChatPresenter {
    private static final String TAG = GroupChatPresenter.class.getSimpleName();

    private GroupInfo groupInfo;
    private List<GroupApplyInfo> currentApplies = new ArrayList<>();
    private List<GroupMemberInfo> currentGroupMembers = new ArrayList<>();

    private GroupChatEventListener groupChatEventListener;

    public GroupChatPresenter() {
        super();
        TUIChatLog.i(TAG, "GroupChatPresenter Init");
    }

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
                if (TextUtils.equals(chatId, groupInfo.getId())) {
                    GroupChatPresenter.this.clearMessage();
                }
            }

            @Override
            public void onApplied(int unHandledSize) {
                GroupChatPresenter.this.onApplied(unHandledSize);
            }

            @Override
            public void handleRevoke(String msgId) {
                GroupChatPresenter.this.handleRevoke(msgId);
            }

            @Override
            public void onRecvNewMessage(TUIMessageBean message) {
                if (groupInfo == null || !TextUtils.equals(message.getGroupId(), groupInfo.getId())) {
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
                if (groupInfo == null || !TextUtils.equals(groupId, groupInfo.getId())) {
                    return;
                }
                GroupChatPresenter.this.onGroupNameChanged(newName);
            }

            @Override
            public void onGroupFaceUrlChanged(String groupId, String faceUrl) {
                if (groupInfo == null || !TextUtils.equals(groupId, groupInfo.getId())) {
                    return;
                }
                GroupChatPresenter.this.onGroupFaceUrlChanged(faceUrl);
            }

            @Override
            public void onRecvMessageModified(TUIMessageBean messageBean) {
                if (groupInfo != null && TextUtils.equals(messageBean.getGroupId(), groupInfo.getId())) {
                    GroupChatPresenter.this.onRecvMessageModified(messageBean);
                }
            }

            @Override
            public void addMessage(TUIMessageBean messageBean, String chatId) {
                if (TextUtils.equals(chatId, groupInfo.getId())) {
                    addMessageInfo(messageBean);
                }
            }

            @Override
            public void onMessageChanged(TUIMessageBean messageBean) {
                updateMessageInfo(messageBean);
            }
        };
        TUIChatService.getInstance().addGroupChatEventListener(groupChatEventListener);
        initMessageSender();
    }

    public void onReadReport(List<MessageReceiptInfo> receiptList) {
        if (groupInfo != null) {
            List<MessageReceiptInfo> processReceipts = new ArrayList<>();
            for (MessageReceiptInfo messageReceiptInfo : receiptList) {
                if (!TextUtils.equals(messageReceiptInfo.getGroupID(), groupInfo.getId())) {
                    continue;
                }
                processReceipts.add(messageReceiptInfo);
            }
            onMessageReadReceiptUpdated(loadedMessageInfoList, processReceipts);
        }
    }

    @Override
    public void loadMessage(int type, TUIMessageBean lastMessageInfo, IUIKitCallback<List<TUIMessageBean>> callback) {
        if (groupInfo == null || isLoading) {
            return;
        }
        isLoading = true;
        String chatId = groupInfo.getId();
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD) {
            provider.loadGroupMessage(chatId, MSG_PAGE_COUNT, lastMessageInfo, new IUIKitCallback<List<TUIMessageBean>>() {

                @Override
                public void onSuccess(List<TUIMessageBean> data) {
                    TUIChatLog.i(TAG, "load group message success " + data.size());
                    if (lastMessageInfo == null) {
                        isHaveMoreNewMessage = false;
                    }
                    if (data.size() < MSG_PAGE_COUNT) {
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

    // 加载消息成功之后会调用此方法
    // This method is called after the message is loaded successfully
    @Override
    protected void onMessageLoadCompleted(List<TUIMessageBean> data, int getType) {
        groupReadReport(groupInfo.getId());
        getMessageReadReceipt(data, getType);
    }

    private void sendGroupTipsMessage(String groupId, String message, final IUIKitCallback<String> callBack) {
        provider.sendGroupTipsMessage(groupId, message, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                TUIChatUtils.callbackOnSuccess(callBack, groupId);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callBack, module, errCode, errMsg);
            }
        });
    }

    protected void addMessageInfo(TUIMessageBean messageInfo) {
        super.addMessageInfo(messageInfo);
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
                    groupInfo.setMemberDetails(currentGroupMembers);
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
                    groupInfo.setMemberDetails(currentGroupMembers);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {

                }
            });
        } else if (tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME || tipsMessage.getTipType() == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE) {
            provider.addModifyGroupMessage(tipsMessage, new IUIKitCallback<Pair<Integer, String>>() {
                @Override
                public void onSuccess(Pair<Integer, String> data) {
                    if (data.first == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME) {
                        groupInfo.setGroupName(data.second);
                        if (chatNotifyHandler != null) {
                            chatNotifyHandler.onGroupNameChanged(data.second);
                        }
                    }
                    if (data.first == TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE) {
                        groupInfo.setNotice(data.second);
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
        String groupType = groupInfo.getGroupType();
        if (TextUtils.equals(groupType, GroupInfo.GROUP_TYPE_AVCHATROOM) || TextUtils.equals(groupType, GroupInfo.GROUP_TYPE_COMMUNITY)
                || (TUIChatUtils.isCommunityGroup(groupInfo.getId()))) {
            message.setNeedReadReceipt(false);
        }
    }

    public void loadGroupMembers(String groupID, IUIKitCallback<List<GroupMemberInfo>> callback) {
        provider.loadGroupMembers(groupID, 0, callback);
    }

    public void onGroupForceExit(String groupId) {
        if (chatNotifyHandler != null && TextUtils.equals(groupId, groupInfo.getId())) {
            chatNotifyHandler.onGroupForceExit();
        }
    }

    public void onApplied(int unHandledSize) {
        if (chatNotifyHandler != null) {
            chatNotifyHandler.onApplied(unHandledSize);
        }
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
        return groupInfo;
    }

    public void setGroupInfo(GroupInfo groupInfo) {
        this.groupInfo = groupInfo;
    }
}
