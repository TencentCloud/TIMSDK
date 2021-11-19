package com.tencent.qcloud.tuikit.tuigroup.model;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMGroupApplicationResult;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberOperationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupUtils;

import java.util.ArrayList;
import java.util.List;

public class GroupInfoProvider {

    private static final String TAG = GroupInfoProvider.class.getSimpleName();

    private static final int PAGE = 50;

    public void loadGroupInfo(final String groupId, final IUIKitCallback<GroupInfo> callBack) {
        // 串行异步加载群组信息
        loadGroupPublicInfo(groupId, new IUIKitCallback<V2TIMGroupInfoResult>() {
            @Override
            public void onSuccess(V2TIMGroupInfoResult data) {

                // 设置群的一般信息，比如名称、类型等
                GroupInfo groupInfo = new GroupInfo();
                groupInfo.covertTIMGroupDetailInfo(data);
                String conversationId = TUIGroupUtils.getConversationIdByUserId(groupId, true);
                V2TIMManager.getConversationManager().getConversation(conversationId, new V2TIMValueCallback<V2TIMConversation>() {
                    @Override
                    public void onSuccess(V2TIMConversation v2TIMConversation) {
                        boolean isTop = v2TIMConversation.isPinned();
                        groupInfo.setTopChat(isTop);
                        // 异步获取群成员
                        loadGroupMembers(groupInfo, 0, callBack);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        // 异步获取群成员
                        loadGroupMembers(groupInfo, 0, callBack);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e(TAG, "loadGroupPublicInfo failed, code: " + errCode + "|desc: " + errMsg);
                if (callBack != null) {
                    callBack.onError(module, errCode, errMsg);
                }
            }
        });
    }

    public void deleteGroup(String groupId, final IUIKitCallback<Void> callBack) {
        V2TIMManager.getInstance().dismissGroup(groupId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupUtils.callbackOnError(callBack, TAG, code, desc);
                TUIGroupLog.e(TAG, "deleteGroup failed, code: " + code + "|desc: " + desc);
            }

            @Override
            public void onSuccess() {
                TUIGroupUtils.callbackOnSuccess(callBack, null);
            }
        });
    }

    public void loadGroupPublicInfo(String groupId, final IUIKitCallback<V2TIMGroupInfoResult> callBack) {
        List<String> groupList = new ArrayList<>();
        groupList.add(groupId);

        V2TIMManager.getGroupManager().getGroupsInfo(groupList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "loadGroupPublicInfo failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults.size() > 0) {
                    V2TIMGroupInfoResult infoResult = v2TIMGroupInfoResults.get(0);
                    TUIGroupLog.i(TAG, infoResult.toString());

                    callBack.onSuccess(infoResult);
                }
            }
        });
    }

    public void loadGroupMembers(GroupInfo groupInfo, long nextSeq, final IUIKitCallback<GroupInfo> callBack) {
        V2TIMManager.getGroupManager().getGroupMemberList(groupInfo.getId(), V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL, nextSeq, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "loadGroupMembers failed, code: " + code + "|desc: " + desc);
                TUIGroupUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<GroupMemberInfo> members = new ArrayList<>();
                for (int i = 0; i < v2TIMGroupMemberInfoResult.getMemberInfoList().size(); i++) {
                    GroupMemberInfo member = new GroupMemberInfo();
                    members.add(member.covertTIMGroupMemberInfo(v2TIMGroupMemberInfoResult.getMemberInfoList().get(i)));
                }
                groupInfo.getMemberDetails().addAll(members);
                groupInfo.setNextSeq(v2TIMGroupMemberInfoResult.getNextSeq());
                TUIGroupUtils.callbackOnSuccess(callBack, groupInfo);
            }
        });
    }

    public void modifyGroupInfo(GroupInfo groupInfo, final Object value, final int type, final IUIKitCallback callBack) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupID(groupInfo.getId());
        if (type == TUIGroupConstants.Group.MODIFY_GROUP_NAME) {
            v2TIMGroupInfo.setGroupName(value.toString());
        } else if (type == TUIGroupConstants.Group.MODIFY_GROUP_NOTICE) {
            v2TIMGroupInfo.setNotification(value.toString());
        } else if (type == TUIGroupConstants.Group.MODIFY_GROUP_JOIN_TYPE) {
            v2TIMGroupInfo.setGroupAddOpt((Integer)value);
        }
        V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.i(TAG, "modifyGroupInfo faild tyep| value| code| desc " + value + ":" + type + ":" + code + ":" + desc);
                TUIGroupUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                if (type == TUIGroupConstants.Group.MODIFY_GROUP_NAME) {
                    groupInfo.setGroupName(value.toString());
                } else if (type == TUIGroupConstants.Group.MODIFY_GROUP_NOTICE) {
                    groupInfo.setNotice(value.toString());
                } else if (type == TUIGroupConstants.Group.MODIFY_GROUP_JOIN_TYPE) {
                    groupInfo.setJoinType((Integer) value);
                }
                TUIGroupUtils.callbackOnSuccess(callBack, value);
            }
        });
    }

    public void modifyMyGroupNickname(GroupInfo groupInfo, final String nickname, final IUIKitCallback callBack) {
        if (groupInfo == null) {
            ToastUtil.toastLongMessage("modifyMyGroupNickname fail: NO GROUP");
            return;
        }

        V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo = new V2TIMGroupMemberFullInfo();
        v2TIMGroupMemberFullInfo.setUserID(V2TIMManager.getInstance().getLoginUser());
        v2TIMGroupMemberFullInfo.setNameCard(nickname);
        V2TIMManager.getGroupManager().setGroupMemberInfo(groupInfo.getId(), v2TIMGroupMemberFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                callBack.onError(TAG, code, desc);
                ToastUtil.toastLongMessage("modifyMyGroupNickname fail: " + code + "=" + desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
            }
        });
    }

    public void setTopConversation(String conversationId, boolean isSetTop, IUIKitCallback<Void> callBack) {
        TUIGroupLog.i(TAG, "setConversationTop id:" + conversationId + "|isTop:" + isSetTop);
        V2TIMManager.getConversationManager().pinConversation(conversationId, isSetTop, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIGroupUtils.callbackOnSuccess(callBack, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "setConversationTop code:" + code + "|desc:" + desc);
                TUIGroupUtils.callbackOnError(callBack, code, desc);
            }
        });
    }

    public void quitGroup(String groupId, final IUIKitCallback<Void> callBack) {
        V2TIMManager.getInstance().quitGroup(groupId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "quitGroup failed, code: " + code + "|desc: " + desc);
                TUIGroupUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                TUIGroupUtils.callbackOnSuccess(callBack, null);
            }
        });
    }

    public void inviteGroupMembers(GroupInfo groupInfo, List<String> addMembers, final IUIKitCallback callBack) {
        if (addMembers == null || addMembers.size() == 0) {
            return;
        }

        V2TIMManager.getGroupManager().inviteUserToGroup(groupInfo.getId(), addMembers, new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "addGroupMembers failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                final List<String> adds = new ArrayList<>();
                if (v2TIMGroupMemberOperationResults.size() > 0) {
                    for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                        V2TIMGroupMemberOperationResult res = v2TIMGroupMemberOperationResults.get(i);
                        if (res.getResult() == V2TIMGroupMemberOperationResult.OPERATION_RESULT_PENDING) {
                            callBack.onSuccess(TUIGroupService.getAppContext().getString(R.string.request_wait));
                            return;
                        }
                        if (res.getResult() > 0) {
                            adds.add(res.getMemberID());
                        }
                    }
                }
                if (adds.size() > 0) {
                    groupInfo.getMemberDetails().clear();
                    loadGroupMembers(groupInfo, 0, callBack);
                }
            }
        });
    }

    public void removeGroupMembers(GroupInfo groupInfo, List<GroupMemberInfo> delMembers, final IUIKitCallback<List<String>> callBack) {
        if (delMembers == null || delMembers.size() == 0) {
            return;
        }
        List<String> members = new ArrayList<>();
        for (int i = 0; i < delMembers.size(); i++) {
            members.add(delMembers.get(i).getAccount());
        }

        V2TIMManager.getGroupManager().kickGroupMember(groupInfo.getId(), members, "", new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "removeGroupMembers failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                List<String> dels = new ArrayList<>();
                for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                    V2TIMGroupMemberOperationResult res = v2TIMGroupMemberOperationResults.get(i);
                    if (res.getResult() == V2TIMGroupMemberOperationResult.OPERATION_RESULT_SUCC) {
                        dels.add(res.getMemberID());
                    }
                }
                List<GroupMemberInfo> memberInfoList = groupInfo.getMemberDetails();
                for (int i = 0; i < dels.size(); i++) {
                    for (int j = memberInfoList.size() - 1; j >= 0; j--) {
                        if (memberInfoList.get(j).getAccount().equals(dels.get(i))) {
                            memberInfoList.remove(j);
                            break;
                        }
                    }
                }
                callBack.onSuccess(dels);
            }
        });
    }

//    public void loadGroupInfo(IBaseInfo baseInfo) {
//        if (baseInfo instanceof GroupInfo) {
//            loadGroupInfo(((GroupInfo) baseInfo).getId(), null);
//        }
//    }
//
//    public void acceptApply(IBaseInfo baseInfo, IUIKitCallback callBack) {
//        if (baseInfo instanceof GroupApplyInfo) {
//            acceptApply((GroupApplyInfo) baseInfo, callBack);
//        }
//    }
//
//    public void refuseApply(IBaseInfo baseInfo, IUIKitCallback callBack) {
//        if (baseInfo instanceof GroupApplyInfo) {
//            refuseApply((GroupApplyInfo) baseInfo, callBack);
//        }
//    }

    public void loadGroupApplies(IUIKitCallback callBack) {

    }

    public List<GroupApplyInfo> getApplyList() {
        return null;
    }

    public void loadGroupApplies(GroupInfo groupInfo, final IUIKitCallback<List<GroupApplyInfo>> callBack) {
        loadApplyInfo(new IUIKitCallback<List<GroupApplyInfo>>() {

            @Override
            public void onSuccess(List<GroupApplyInfo> data) {
                if (groupInfo == null) {
                    callBack.onError(TAG, 0, "no groupInfo");
                    return;
                }
                String groupId = groupInfo.getId();
                List<GroupApplyInfo> applyInfos = new ArrayList<>();
                for (int i = 0; i < data.size(); i++) {
                    GroupApplyInfo applyInfo = data.get(i);
                    if (groupId.equals(applyInfo.getGroupApplication().getGroupID())
                            && applyInfo.getGroupApplication().getHandleStatus() == V2TIMGroupApplication.V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED) {
                        applyInfos.add(applyInfo);
                    }
                }
                callBack.onSuccess(applyInfos);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e(TAG, "loadApplyInfo failed, code: " + errCode + "|desc: " + errMsg);
                callBack.onError(module, errCode, errMsg);
            }
        });
    }

    private void loadApplyInfo(final IUIKitCallback<List<GroupApplyInfo>> callBack) {
        final List<GroupApplyInfo> applies = new ArrayList<>();

        V2TIMManager.getGroupManager().getGroupApplicationList(new V2TIMValueCallback<V2TIMGroupApplicationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "getGroupPendencyList failed, code: " + code + "|desc: " + desc);
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

    public void acceptApply(final GroupApplyInfo item, final IUIKitCallback<Void> callBack) {
        V2TIMManager.getGroupManager().acceptGroupApplication(item.getGroupApplication(), "", new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "acceptApply failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
            }
        });
    }

    public void refuseApply(final GroupApplyInfo item, final IUIKitCallback<Void> callBack) {
        V2TIMManager.getGroupManager().refuseGroupApplication(item.getGroupApplication(), "", new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "refuseApply failed, code: " + code + "|desc: " + desc);
                TUIGroupUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                TUIGroupUtils.callbackOnSuccess(callBack, null);
            }
        });
    }

    public void setGroupReceiveMessageOpt(String groupId, boolean isReceive, IUIKitCallback callBack) {
        int option;
        if (!isReceive) {
            option = V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
        } else {
            option = V2TIMMessage.V2TIM_RECEIVE_MESSAGE;
        }
        V2TIMManager.getMessageManager().setGroupReceiveMessageOpt(groupId, option, new V2TIMCallback(){
            @Override
            public void onSuccess() {
                TUIGroupUtils.callbackOnSuccess(callBack, null);
                TUIGroupLog.d(TAG, "setReceiveMessageOpt onSuccess");
            }

            @Override
            public void onError(int code, String desc) {
                TUIGroupUtils.callbackOnError(callBack, code, desc);
                TUIGroupLog.d(TAG, "setReceiveMessageOpt onError code = " + code + ", desc = " + desc);
            }
        });
    }

    public void modifyGroupFaceUrl(String groupId, String faceUrl, IUIKitCallback<Void> callback) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupID(groupId);
        v2TIMGroupInfo.setFaceUrl(faceUrl);
        V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "modify group icon failed, code:" + code + "|desc:" + desc);
                TUIGroupUtils.callbackOnError(callback, code, desc);
            }

            @Override
            public void onSuccess() {
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }
        });
    }

    public GroupMemberInfo getSelfGroupMemberInfo(GroupInfo groupInfo) {
        for (int i = 0; i < groupInfo.getMemberDetails().size(); i++) {
            GroupMemberInfo memberInfo = groupInfo.getMemberDetails().get(i);
            if (TextUtils.equals(memberInfo.getAccount(), V2TIMManager.getInstance().getLoginUser())) {
                return memberInfo;
            }

        }
        return null;
    }

    public boolean isAdmin(int memberType) {
        return memberType == V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
    }

    public boolean isSelf(String userId) {
        return TextUtils.equals(userId, V2TIMManager.getInstance().getLoginUser());
    }
}
