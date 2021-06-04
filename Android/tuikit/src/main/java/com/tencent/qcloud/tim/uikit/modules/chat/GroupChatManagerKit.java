package com.tencent.qcloud.tim.uikit.modules.chat;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCreateGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupTipsElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.group.apply.GroupApplyInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoProvider;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageCustom;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class GroupChatManagerKit extends ChatManagerKit {

    private static final String TAG = GroupChatManagerKit.class.getSimpleName();
    private static GroupChatManagerKit mKit;
    private GroupInfo mCurrentChatInfo;
    private List<GroupApplyInfo> mCurrentApplies = new ArrayList<>();
    private List<GroupMemberInfo> mCurrentGroupMembers = new ArrayList<>();
    private GroupNotifyHandler mGroupHandler;
    private GroupInfoProvider mGroupInfoProvider;

    private GroupChatManagerKit() {
        init();
    }

    public static GroupChatManagerKit getInstance() {
        if (mKit == null) {
            mKit = new GroupChatManagerKit();
        }
        return mKit;
    }

    private static void sendTipsMessage(String groupID, V2TIMMessage message, final IUIKitCallBack callBack) {
        V2TIMManager.getMessageManager().sendMessage(message, null, groupID, V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, null, new V2TIMSendCallback<V2TIMMessage>() {
            @Override
            public void onProgress(int progress) {

            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "sendTipsMessage fail:" + code + "=" + desc);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                TUIKitLog.i(TAG, "sendTipsMessage onSuccess");
                if (callBack != null) {
                    callBack.onSuccess(v2TIMMessage);
                }
            }
        });
    }

    public static void createGroupChat(final GroupInfo chatInfo, final IUIKitCallBack callBack) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupType(chatInfo.getGroupType());
        v2TIMGroupInfo.setGroupName(chatInfo.getGroupName());
        v2TIMGroupInfo.setGroupAddOpt(chatInfo.getJoinType());

        List<V2TIMCreateGroupMemberInfo> v2TIMCreateGroupMemberInfoList = new ArrayList<>();
        for (int i = 0; i < chatInfo.getMemberDetails().size(); i++) {
            GroupMemberInfo groupMemberInfo = chatInfo.getMemberDetails().get(i);
            V2TIMCreateGroupMemberInfo v2TIMCreateGroupMemberInfo = new V2TIMCreateGroupMemberInfo();
            v2TIMCreateGroupMemberInfo.setUserID(groupMemberInfo.getAccount());
            v2TIMCreateGroupMemberInfoList.add(v2TIMCreateGroupMemberInfo);
        }

        V2TIMManager.getGroupManager().createGroup(v2TIMGroupInfo, v2TIMCreateGroupMemberInfoList, new V2TIMValueCallback<String>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "createGroup failed, code: " + code + "|desc: " + desc);
                if (callBack != null) {
                    callBack.onError(TAG, code, desc);
                }
            }

            @Override
            public void onSuccess(final String groupId) {
                chatInfo.setId(groupId);
                Gson gson = new Gson();
                MessageCustom messageCustom = new MessageCustom();
                messageCustom.version = TUIKitConstants.version;
                messageCustom.businessID = MessageCustom.BUSINESS_ID_GROUP_CREATE;
                messageCustom.opUser = V2TIMManager.getInstance().getLoginUser();
                messageCustom.content = TUIKit.getAppContext().getString(R.string.create_group);
                String data = gson.toJson(messageCustom);

                V2TIMMessage createTips = MessageInfoUtil.buildGroupCustomMessage(data);

                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                sendTipsMessage(groupId, createTips, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        if (callBack != null) {
                            callBack.onSuccess(groupId);
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIKitLog.e(TAG, "sendTipsMessage failed, code: " + errCode + "|desc: " + errMsg);
                    }
                });
            }
        });
    }

    @Override
    protected void init() {
        super.init();
        mGroupInfoProvider = new GroupInfoProvider();
    }

    public GroupInfoProvider getProvider() {
        return mGroupInfoProvider;
    }

    @Override
    public ChatInfo getCurrentChatInfo() {
        return mCurrentChatInfo;
    }

    @Override
    public void setCurrentChatInfo(ChatInfo info) {
        super.setCurrentChatInfo(info);

        mCurrentChatInfo = (GroupInfo) info;
        mCurrentApplies.clear();
        mCurrentGroupMembers.clear();
        mGroupInfoProvider.loadGroupInfo(mCurrentChatInfo);
    }

    @Override
    protected void addGroupMessage(MessageInfo msgInfo) {
        V2TIMGroupTipsElem groupTips = null;
        if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_JOIN
                || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_QUITE
                || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_KICK
                || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME
                || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE) {
            V2TIMMessage v2TIMMessage = msgInfo.getTimMessage();
            if (v2TIMMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
                return;
            }
            groupTips = v2TIMMessage.getGroupTipsElem();
        } else {
            return;
        }
        if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_JOIN) {
            List<V2TIMGroupMemberInfo> memberInfos = groupTips.getMemberList();
            if (memberInfos.size() > 0) {
                for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberInfos) {
                    GroupMemberInfo member = new GroupMemberInfo();
                    member.covertTIMGroupMemberInfo(v2TIMGroupMemberInfo);
                    mCurrentGroupMembers.add(member);
                }
            } else {
                GroupMemberInfo member = new GroupMemberInfo();
                member.covertTIMGroupMemberInfo(groupTips.getOpMember());
                mCurrentGroupMembers.add(member);
            }
            mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
        } else if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_QUITE || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_KICK) {
            List<V2TIMGroupMemberInfo> memberInfos = groupTips.getMemberList();
            if (memberInfos.size() > 0) {
                for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : memberInfos) {
                    String memberUserID = v2TIMGroupMemberInfo.getUserID();
                    for (int i = 0; i < mCurrentGroupMembers.size(); i++) {
                        if (mCurrentGroupMembers.get(i).getAccount().equals(memberUserID)) {
                            mCurrentGroupMembers.remove(i);
                            break;
                        }
                    }
                }
            } else {
                V2TIMGroupMemberInfo memberInfo = groupTips.getOpMember();
                for (int i = 0; i < mCurrentGroupMembers.size(); i++) {
                    if (mCurrentGroupMembers.get(i).getAccount().equals(memberInfo.getUserID())) {
                        mCurrentGroupMembers.remove(i);
                        break;
                    }
                }
            }
            mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
        } else if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE) {
            List<V2TIMGroupChangeInfo> modifyList = groupTips.getGroupChangeInfoList();
            if (modifyList.size() > 0) {
                V2TIMGroupChangeInfo modifyInfo = modifyList.get(0);
                int modifyType = modifyInfo.getType();
                if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                    mCurrentChatInfo.setGroupName(modifyInfo.getValue());
                    if (mGroupHandler != null) {
                        mGroupHandler.onGroupNameChanged(modifyInfo.getValue());
                    }
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                    mCurrentChatInfo.setNotice(modifyInfo.getValue());
                }
            }
        }
    }

    public void notifyJoinGroup(String groupID, boolean isInvited) {
        if (isInvited) {
            ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.join_group_tip)+ groupID);
        } else {
            ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.joined_tip) + groupID);
        }
    }

    public void notifyJoinGroupRefused(String groupID) {
        ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.reject_join_tip) + groupID);
    }

    public void notifyKickedFromGroup(String groupID) {
        ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.kick_group) + groupID);
        ConversationManagerKit.getInstance().deleteConversation(groupID, true);
        if (mCurrentChatInfo != null && groupID.equals(mCurrentChatInfo.getId())) {
            onGroupForceExit();
        }
    }

    public void notifyGroupDismissed(String groupID) {
        ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.dismiss_tip_before) + groupID + TUIKit.getAppContext().getString(R.string.dismiss_tip_after));
        if (mCurrentChatInfo != null && groupID.equals(mCurrentChatInfo.getId())) {
            onGroupForceExit();
        }
        ConversationManagerKit.getInstance().deleteConversation(groupID, true);
    }

    public void notifyGroupRESTCustomSystemData(String groupID, byte[] customData) {
        if (mCurrentChatInfo != null && groupID.equals(mCurrentChatInfo.getId())) {
            ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.get_system_notice) + new String(customData));
        }
    }

    public void onGroupForceExit() {
        if (mGroupHandler != null) {
            mGroupHandler.onGroupForceExit();
        }
    }

    @Override
    public void destroyChat() {
        super.destroyChat();
        mCurrentChatInfo = null;
        mGroupHandler = null;
        mCurrentApplies.clear();
        mCurrentGroupMembers.clear();
    }

    public void setGroupHandler(GroupNotifyHandler mGroupHandler) {
        this.mGroupHandler = mGroupHandler;
    }

    public void onApplied(int unHandledSize) {
        if (mGroupHandler != null) {
            mGroupHandler.onApplied(unHandledSize);
        }
    }

    @Override
    protected boolean isGroup() {
        return true;
    }

    @Override
    protected void assembleGroupMessage(MessageInfo message) {
        message.setGroup(true);
        message.setFromUser(V2TIMManager.getInstance().getLoginUser());
    }

    public interface GroupNotifyHandler {

        void onGroupForceExit();

        void onGroupNameChanged(String newName);

        void onApplied(int size);
    }
}
