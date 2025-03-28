package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;
import android.util.Pair;

import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupTipsElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.CustomHelloMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.LocalTipsMessage;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class TipsMessageBean extends TUIMessageBean {
    private static final String TAG = "TipsMessageBean";
    /**
     *
     * Create group
     */
    public static final int MSG_TYPE_GROUP_CREATE = 0x101;
    /**
     *
     * Dismiss a group
     */
    public static final int MSG_TYPE_GROUP_DELETE = 0x102;
    /**
     *
     * Proactively join a group (memberList joins a group; valid only for non-Work groups)
     */
    public static final int MSG_TYPE_GROUP_JOIN = 0x103;
    /**
     *
     * Quit a group
     */
    public static final int MSG_TYPE_GROUP_QUITE = 0x104;
    /**
     *
     * Be kicked out of a group (opMember kicks memberList out of the group)
     */
    public static final int MSG_TYPE_GROUP_KICK = 0x105;
    /**
     *
     * Group name change prompt message
     */
    public static final int MSG_TYPE_GROUP_MODIFY_NAME = 0x106;
    /**
     *
     * Group notification update prompt message
     */
    public static final int MSG_TYPE_GROUP_MODIFY_NOTICE = 0x107;

    private String text;
    private final Map<String, String> targetUserMap = new LinkedHashMap<>();
    private transient Pair<String, String> operationUserPair;
    private int tipType;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        if (v2TIMMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            parseCustomTips(v2TIMMessage);
        } else {
            parseGroupTips(v2TIMMessage);
        }
    }

    private void parseCustomTips(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null) {
            return;
        }
        String data = new String(customElem.getData());
        LocalTipsMessage localTipsMessage = null;
        if (!TextUtils.isEmpty(data)) {
            try {
                localTipsMessage = new Gson().fromJson(data, LocalTipsMessage.class);
            } catch (Exception e) {
                TUIChatLog.e(TAG, e.getLocalizedMessage());
            }
        }
        if (localTipsMessage != null && TextUtils.equals(localTipsMessage.businessID, TUIChatConstants.BUSINESS_ID_LOCAL_TIPS)) {
            text =  localTipsMessage.tips;
            setExtra(localTipsMessage.tips);
        }
    }

    private void parseGroupTips(V2TIMMessage v2TIMMessage) {
        V2TIMGroupTipsElem groupTipElem = v2TIMMessage.getGroupTipsElem();
        if (groupTipElem == null) {
            return;
        }
        String targetUsers = getTargetUsers(groupTipElem);
        String operationUserName = getOperationUserName(groupTipElem);

        int tipsType = groupTipElem.getType();
        CharSequence tipsMessage = "";
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_JOIN) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_JOIN);
            tipsMessage = TUIChatService.getAppContext().getString(R.string.join_group, targetUsers);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_INVITE) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_JOIN);
            tipsMessage = TUIChatService.getAppContext().getString(R.string.invite_joined_group, operationUserName, targetUsers);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_QUIT) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_QUITE);
            tipsMessage = TUIChatService.getAppContext().getString(R.string.quit_group, operationUserName);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_KICKED) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_KICK);
            tipsMessage = TUIChatService.getAppContext().getString(R.string.kick_group_tip, operationUserName, targetUsers);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = TUIChatService.getAppContext().getString(R.string.be_group_manager, targetUsers);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = TUIChatService.getAppContext().getString(R.string.cancle_group_manager, targetUsers);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_TOPIC_INFO_CHANGE) {
            tipsMessage = getGroupInfoChangeTips(groupTipElem, operationUserName, targetUsers);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE) {
            List<V2TIMGroupMemberChangeInfo> modifyList = groupTipElem.getMemberChangeInfoList();
            if (!modifyList.isEmpty()) {
                long shutupTime = modifyList.get(0).getMuteTime();
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (shutupTime > 0) {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.banned, targetUsers, "\"" + DateTimeUtil.formatSeconds(shutupTime) + "\"");
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.cancle_banned, targetUsers);
                }
            }
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED) {
            tipsMessage = TUIChatService.getAppContext().getString(R.string.chat_group_message_pinned, operationUserName);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED) {
            tipsMessage = TUIChatService.getAppContext().getString(R.string.chat_group_message_unpinned, operationUserName);
        }

        text = tipsMessage.toString();
        setExtra(tipsMessage.toString());
    }

    private String getOperationUserName(V2TIMGroupTipsElem groupTipElem) {
        String operationUserName = "";
        V2TIMGroupMemberInfo opMember = groupTipElem.getOpMember();
        if (opMember != null) {
            operationUserName = getDisplayName(opMember);
            operationUserPair = new Pair<>(opMember.getUserID(), operationUserName);
        }

        if (!TextUtils.isEmpty(operationUserName)) {
            operationUserName = "\"" + operationUserName + "\"";
        }
        return operationUserName;
    }

    private @Nullable String getTargetUsers(V2TIMGroupTipsElem groupTipElem) {
        String targetUsers = "";
        List<V2TIMGroupMemberInfo> v2TIMGroupMemberInfoList = groupTipElem.getMemberList();
        if (!v2TIMGroupMemberInfoList.isEmpty()) {
            for (int i = 0; i < v2TIMGroupMemberInfoList.size(); i++) {
                V2TIMGroupMemberInfo v2TIMGroupMemberInfo = v2TIMGroupMemberInfoList.get(i);
                String memberID = getMemberID(v2TIMGroupMemberInfo);
                String memberName = getDisplayName(v2TIMGroupMemberInfo);
                targetUserMap.put(memberID, memberName);
                targetUsers = targetUsers + memberName;
                if (i == 2) {
                    break;
                }
                if (i < v2TIMGroupMemberInfoList.size() - 1) {
                    targetUsers += ",";
                }
            }
        }

        if (!TextUtils.isEmpty(targetUsers)) {
            targetUsers = "\"" + targetUsers + "\"";
        }
        if (v2TIMGroupMemberInfoList.size() > 3) {
            targetUsers = targetUsers + TUIChatService.getAppContext().getString(R.string.etc);
        }
        return targetUsers;
    }

    private String getGroupInfoChangeTips(V2TIMGroupTipsElem groupTipElem, String operationUser, String targetUser) {
        String tipsMessage = "";
        List<V2TIMGroupChangeInfo> modifyList = groupTipElem.getGroupChangeInfoList();
        String groupID = groupTipElem.getGroupID();
        for (int i = 0; i < modifyList.size(); i++) {
            V2TIMGroupChangeInfo modifyInfo = modifyList.get(i);
            int modifyType = modifyInfo.getType();
            if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME);
                if (TUIChatUtils.isTopicGroup(groupID)) {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_topic_name_is, operationUser, "\"" + modifyInfo.getValue() + "\"");
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_group_name_is, operationUser, "\"" + modifyInfo.getValue() + "\"");
                }
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (TUIChatUtils.isTopicGroup(groupID)) {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_topic_notice, operationUser, "\"" + modifyInfo.getValue() + "\"");
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_notice, operationUser, "\"" + modifyInfo.getValue() + "\"");
                }
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (!TextUtils.isEmpty(targetUser)) {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.move_owner, operationUser, "\"" + targetUser + "\"");
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(
                        R.string.move_owner, operationUser, modifyInfo.getValue());
                }
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (TUIChatUtils.isTopicGroup(groupID)) {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_topic_avatar, operationUser);
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_group_avatar, operationUser);
                }
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (TUIChatUtils.isTopicGroup(groupID)) {
                    tipsMessage =
                        TUIChatService.getAppContext().getString(R.string.modify_topic_introduction, operationUser, "\"" + modifyInfo.getValue() + "\"");
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_introduction, operationUser, "\"" + modifyInfo.getValue() + "\"");
                }
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                boolean isShutUpAll = modifyInfo.getBoolValue();
                if (isShutUpAll) {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_shut_up_all, operationUser);
                } else {
                    tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_cancel_shut_up_all, operationUser);
                }
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT) {
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                int addOpt = modifyInfo.getIntValue();
                String addOptStr;
                if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_FORBID) {
                    addOptStr = "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_join_disable) + "\"";
                } else if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_AUTH) {
                    addOptStr = "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_admin_approve) + "\"";
                } else {
                    addOptStr = "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_auto_approval) + "\"";
                }
                tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_group_add_opt, operationUser, addOptStr);
            } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT) {
                int addOpt = modifyInfo.getIntValue();
                String addOptStr;
                if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_FORBID) {
                    addOptStr = "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_invite_disable) + "\"";
                } else if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_AUTH) {
                    addOptStr = "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_admin_approve) + "\"";
                } else {
                    addOptStr = "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_auto_approval) + "\"";
                }
                tipsMessage = TUIChatService.getAppContext().getString(R.string.modify_group_invite_opt, operationUser, addOptStr);
            }

            if (i < modifyList.size() - 1) {
                tipsMessage = tipsMessage + "、";
            }
        }
        return tipsMessage;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getText() {
        return text;
    }

    public void setTipType(int tipType) {
        this.tipType = tipType;
    }

    public int getTipType() {
        return tipType;
    }

    public Map<String, String> getTargetUserMap() {
        return targetUserMap;
    }

    public void setOperationUserPair(Pair<String, String> operationUserPair) {
        this.operationUserPair = operationUserPair;
    }

    public Pair<String, String> getOperationUserPair() {
        return operationUserPair;
    }

    private static String getDisplayName(V2TIMGroupMemberInfo groupMemberInfo) {
        String displayName;
        if (groupMemberInfo == null) {
            return null;
        }

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

    private static String getMemberID(V2TIMGroupMemberInfo groupMemberInfo) {
        if (groupMemberInfo == null) {
            return null;
        }
        return groupMemberInfo.getUserID();
    }
}
