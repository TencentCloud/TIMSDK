package com.tencent.qcloud.tim.uikit.modules.chat;

import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMGroupAddOpt;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupSystemElem;
import com.tencent.imsdk.TIMGroupSystemElemType;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMGroupTipsElemGroupInfo;
import com.tencent.imsdk.TIMGroupTipsGroupInfoType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.group.apply.GroupApplyInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoProvider;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class GroupChatManagerKit extends ChatManagerKit {

    private static final String TAG = GroupChatManagerKit.class.getSimpleName();

    private GroupInfo mCurrentChatInfo;
    private List<GroupApplyInfo> mCurrentApplies = new ArrayList<>();
    private List<GroupMemberInfo> mCurrentGroupMembers = new ArrayList<>();
    private GroupNotifyHandler mGroupHandler;
    private GroupInfoProvider mGroupInfoProvider;
    private static GroupChatManagerKit mKit;

    private GroupChatManagerKit() {
        init();
    }

    public static GroupChatManagerKit getInstance() {
        if (mKit == null) {
            mKit = new GroupChatManagerKit();
        }
        return mKit;
    }

    protected void init() {
        super.init();
        mGroupInfoProvider = new GroupInfoProvider();
    }

    public GroupInfoProvider getProvider() {
        return mGroupInfoProvider;
    }

    public ChatInfo getCurrentChatInfo() {
        return mCurrentChatInfo;
    }

    private static void sendTipsMessage(TIMConversation conversation, TIMMessage message, final IUIKitCallBack callBack) {
        conversation.sendMessage(message, new TIMValueCallBack<TIMMessage>() {
            @Override
            public void onError(final int code, final String desc) {
                TUIKitLog.i(TAG, "sendTipsMessage fail:" + code + "=" + desc);
                if (callBack != null) {
                    callBack.onError(TAG, code, desc);
                }
            }

            @Override
            public void onSuccess(TIMMessage timMessage) {
                TUIKitLog.i(TAG, "sendTipsMessage onSuccess");
                if (callBack != null) {
                    callBack.onSuccess(timMessage);
                }
            }
        });
    }

    public static void createGroupChat(final GroupInfo chatInfo, final IUIKitCallBack callBack) {
        final TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam(chatInfo.getGroupType(), chatInfo.getGroupName());
        if (chatInfo.getJoinType() > -1) {
            param.setAddOption(TIMGroupAddOpt.values()[chatInfo.getJoinType()]);
        }
        param.setIntroduction(chatInfo.getNotice());
        List<TIMGroupMemberInfo> infos = new ArrayList<>();
        for (int i = 0; i < chatInfo.getMemberDetails().size(); i++) {
            TIMGroupMemberInfo memberInfo = new TIMGroupMemberInfo(chatInfo.getMemberDetails().get(i).getAccount());
            infos.add(memberInfo);
        }
        param.setMembers(infos);
        TIMGroupManager.getInstance().createGroup(param, new TIMValueCallBack<String>() {
            @Override
            public void onError(final int code, final String desc) {
                callBack.onError(TAG, code, desc);
                TUIKitLog.e(TAG, "createGroup failed, code: " + code + "|desc: " + desc);
            }

            @Override
            public void onSuccess(final String groupId) {
                chatInfo.setId(groupId);
                String message = TIMManager.getInstance().getLoginUser() + "创建群组";
                final MessageInfo createTips = MessageInfoUtil.buildGroupCustomMessage(MessageInfoUtil.GROUP_CREATE, message);
                TIMConversation conversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, groupId);
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                sendTipsMessage(conversation, createTips.getTIMMessage(), new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        callBack.onSuccess(groupId);
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
    protected void onReceiveSystemMessage(TIMMessage msg) {
        super.onReceiveSystemMessage(msg);
        TIMElem ele = msg.getElement(0);
        TIMElemType eleType = ele.getType();
        if (eleType == TIMElemType.GroupSystem) {
            TUIKitLog.i(TAG, "onReceiveSystemMessage msg = " + msg);
            TIMGroupSystemElem groupSysEle = (TIMGroupSystemElem) ele;
            groupSystMsgHandle(groupSysEle);
        }
    }

    @Override
    protected void addGroupMessage(MessageInfo msgInfo) {
        if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_JOIN) {
            for (int i = 0; i < msgInfo.getTIMMessage().getElementCount(); i++) {
                TIMGroupTipsElem groupTips = (TIMGroupTipsElem) msgInfo.getTIMMessage().getElement(i);
                Map<String, TIMGroupMemberInfo> changeInfos = groupTips.getChangedGroupMemberInfo();
                if (changeInfos.size() > 0) {
                    Iterator<String> keys = changeInfos.keySet().iterator();
                    while (keys.hasNext()) {
                        GroupMemberInfo member = new GroupMemberInfo();
                        member.covertTIMGroupMemberInfo(changeInfos.get(keys.next()));
                        mCurrentGroupMembers.add(member);
                    }
                } else {
                    GroupMemberInfo member = new GroupMemberInfo();
                    member.covertTIMGroupMemberInfo(groupTips.getOpGroupMemberInfo());
                    mCurrentGroupMembers.add(member);
                }
            }
            mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
        } else if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_QUITE || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_KICK) {
            for (int i = 0; i < msgInfo.getTIMMessage().getElementCount(); i++) {

                TIMGroupTipsElem groupTips = (TIMGroupTipsElem) msgInfo.getTIMMessage().getElement(i);
                Map<String, TIMGroupMemberInfo> changeInfos = groupTips.getChangedGroupMemberInfo();
                if (changeInfos.size() > 0) {
                    Iterator<String> keys = changeInfos.keySet().iterator();
                    while (keys.hasNext()) {
                        String id = keys.next();
                        for (int j = 0; j < mCurrentGroupMembers.size(); j++) {
                            if (mCurrentGroupMembers.get(i).getAccount().equals(id)) {
                                mCurrentGroupMembers.remove(i);
                                break;
                            }
                        }
                    }
                } else {
                    TIMGroupMemberInfo memberInfo = groupTips.getOpGroupMemberInfo();
                    for (int j = 0; j < mCurrentGroupMembers.size(); j++) {
                        if (mCurrentGroupMembers.get(i).getAccount().equals(memberInfo.getUser())) {
                            mCurrentGroupMembers.remove(i);
                            break;
                        }
                    }
                }
            }
            mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
        } else if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE) {
            TIMGroupTipsElem groupTips = (TIMGroupTipsElem) msgInfo.getTIMMessage().getElement(0);
            List<TIMGroupTipsElemGroupInfo> modifyList = groupTips.getGroupInfoList();
            if (modifyList.size() > 0) {
                TIMGroupTipsElemGroupInfo modifyInfo = modifyList.get(0);
                TIMGroupTipsGroupInfoType modifyType = modifyInfo.getType();
                if (modifyType == TIMGroupTipsGroupInfoType.ModifyName) {
                    mCurrentChatInfo.setGroupName(modifyInfo.getContent());
                    if (mGroupHandler != null) {
                        mGroupHandler.onGroupNameChanged(modifyInfo.getContent());
                    }
                } else if (modifyType == TIMGroupTipsGroupInfoType.ModifyNotification) {
                    mCurrentChatInfo.setNotice(modifyInfo.getContent());
                }
            }
        }
    }


    //群系统消息处理，不需要显示信息的
    private void groupSystMsgHandle(TIMGroupSystemElem groupSysEle) {
        TIMGroupSystemElemType type = groupSysEle.getSubtype();
        if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_ADD_GROUP_ACCEPT_TYPE) {
            ToastUtil.toastLongMessage("您已被同意加入群：" + groupSysEle.getGroupId());
        } else if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_ADD_GROUP_REFUSE_TYPE) {
            ToastUtil.toastLongMessage("您被拒绝加入群：" + groupSysEle.getGroupId());
        } else if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE) {
            ToastUtil.toastLongMessage("您已被踢出群：" + groupSysEle.getGroupId());
            ConversationManagerKit.getInstance().deleteConversation(groupSysEle.getGroupId(), true);
            if (mCurrentChatInfo != null && groupSysEle.getGroupId().equals(mCurrentChatInfo.getId())) {
                onGroupForceExit();
            }
        } else if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE) {
            ToastUtil.toastLongMessage("您所在的群" + groupSysEle.getGroupId() + "已解散");
            if (mCurrentChatInfo != null && groupSysEle.getGroupId().equals(mCurrentChatInfo.getId())) {
                onGroupForceExit();
            }
        }
    }

    public void onGroupForceExit() {
        if (mGroupHandler != null) {
            mGroupHandler.onGroupForceExit();
        }
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

    public interface GroupNotifyHandler {

        void onGroupForceExit();

        void onGroupNameChanged(String newName);

        void onApplied(int size);
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
        message.setFromUser(TIMManager.getInstance().getLoginUser());
    }
}
