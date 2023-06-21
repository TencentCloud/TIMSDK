package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;
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
import java.util.List;

public class TipsMessageBean extends TUIMessageBean {
    /**
     * 群创建提示消息
     *
     * Create group
     */
    public static final int MSG_TYPE_GROUP_CREATE = 0x101;
    /**
     * 群解散提示消息
     *
     * Dismiss a group
     */
    public static final int MSG_TYPE_GROUP_DELETE = 0x102;
    /**
     * 群成员加入提示消息
     *
     * Proactively join a group (memberList joins a group; valid only for non-Work groups)
     */
    public static final int MSG_TYPE_GROUP_JOIN = 0x103;
    /**
     * 群成员退群提示消息
     *
     * Quit a group
     */
    public static final int MSG_TYPE_GROUP_QUITE = 0x104;
    /**
     * 群成员被踢出群提示消息
     *
     * Be kicked out of a group (opMember kicks memberList out of the group)
     */
    public static final int MSG_TYPE_GROUP_KICK = 0x105;
    /**
     * 群名称修改提示消息
     *
     * Group name change prompt message
     */
    public static final int MSG_TYPE_GROUP_MODIFY_NAME = 0x106;
    /**
     * 群通知更新提示消息
     *
     * Group notification update prompt message
     */
    public static final int MSG_TYPE_GROUP_MODIFY_NOTICE = 0x107;

    private String text;
    private int tipType;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        V2TIMGroupTipsElem groupTipElem = v2TIMMessage.getGroupTipsElem();
        if (groupTipElem == null) {
            return;
        }
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
                        targetUser = targetUser + TUIChatService.getAppContext().getString(R.string.etc);
                        break;
                    } else {
                        targetUser = targetUser + "，" + getDisplayName(v2TIMGroupMemberInfo);
                    }
                }
            }
        }

        operationUser = getDisplayName(groupTipElem.getOpMember());

        if (!TextUtils.isEmpty(targetUser)) {
            targetUser = TUIChatConstants.covert2HTMLString(targetUser);
        }

        if (!TextUtils.isEmpty(operationUser)) {
            operationUser = TUIChatConstants.covert2HTMLString(operationUser);
        }
        int tipsType = groupTipElem.getType();
        String tipsMessage = "";
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_JOIN) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_JOIN);
            tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.join_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_INVITE) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_JOIN);
            tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.invite_joined_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_QUIT) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_QUITE);
            tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.quit_group);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_KICKED) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_KICK);
            tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.kick_group_tip);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.be_group_manager);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN) {
            setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
            tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.cancle_group_manager);
        }
        if (tipsType == V2TIMGroupTipsElem.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE) {
            List<V2TIMGroupChangeInfo> modifyList = groupTipElem.getGroupChangeInfoList();
            for (int i = 0; i < modifyList.size(); i++) {
                V2TIMGroupChangeInfo modifyInfo = modifyList.get(i);
                int modifyType = modifyInfo.getType();
                if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NAME);
                    tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_group_name_is) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_notice) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    if (!TextUtils.isEmpty(targetUser)) {
                        tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.move_owner) + "\"" + targetUser + "\"";
                    } else {
                        tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.move_owner) + "\""
                            + TUIChatConstants.covert2HTMLString(modifyInfo.getValue()) + "\"";
                    }
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_group_avatar);
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_introduction) + "\"" + modifyInfo.getValue() + "\"";
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    boolean isShutUpAll = modifyInfo.getBoolValue();
                    if (isShutUpAll) {
                        tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_shut_up_all);
                    } else {
                        tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_cancel_shut_up_all);
                    }
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT) {
                    setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                    tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_group_add_opt);
                    int addOpt = modifyInfo.getIntValue();
                    if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_FORBID) {
                        tipsMessage = tipsMessage + "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_join_disable) + "\"";
                    } else if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_AUTH) {
                        tipsMessage = tipsMessage + "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_admin_approve) + "\"";
                    } else {
                        tipsMessage = tipsMessage + "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_auto_approval) + "\"";
                    }
                } else if (modifyType == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT) {
                    tipsMessage = operationUser + TUIChatService.getAppContext().getString(R.string.modify_group_invite_opt);
                    int addOpt = modifyInfo.getIntValue();
                    if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_FORBID) {
                        tipsMessage = tipsMessage + "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_invite_disable) + "\"";
                    } else if (addOpt == V2TIMGroupInfo.V2TIM_GROUP_ADD_AUTH) {
                        tipsMessage = tipsMessage + "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_admin_approve) + "\"";
                    } else {
                        tipsMessage = tipsMessage + "\"" + TUIChatService.getAppContext().getString(R.string.group_add_opt_auto_approval) + "\"";
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
                setTipType(TipsMessageBean.MSG_TYPE_GROUP_MODIFY_NOTICE);
                if (shutupTime > 0) {
                    tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.banned) + "\"" + DateTimeUtil.formatSeconds(shutupTime) + "\"";
                } else {
                    tipsMessage = targetUser + TUIChatService.getAppContext().getString(R.string.cancle_banned);
                }
            }
        }
        text = tipsMessage;
        setExtra(tipsMessage);
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
}
