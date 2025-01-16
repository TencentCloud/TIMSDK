package com.tencent.qcloud.tuikit.tuicontact.model;

import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberOperationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupMemberProvider {
    private static final String TAG = "GroupProvider";

    public void loadGroupMembers(String groupID, int filter, long nextSeq, final TUIValueCallback<Pair<List<GroupMemberInfo>, Long>> callBack) {
        V2TIMManager.getGroupManager().getGroupMemberList(groupID, filter, nextSeq, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<GroupMemberInfo> members = new ArrayList<>();
                for (V2TIMGroupMemberFullInfo fullInfo : v2TIMGroupMemberInfoResult.getMemberInfoList()) {
                    GroupMemberInfo member = new GroupMemberInfo();
                    member.setUserId(fullInfo.getUserID());
                    member.setNameCard(fullInfo.getNameCard());
                    member.setFriendRemark(fullInfo.getFriendRemark());
                    member.setNickName(fullInfo.getNickName());
                    member.setFaceUrl(fullInfo.getFaceUrl());
                    member.setMuteUtil(fullInfo.getMuteUntil());
                    member.setRole(fullInfo.getRole());
                    members.add(member);
                }
                Pair<List<GroupMemberInfo>, Long> result = new Pair<>(members, v2TIMGroupMemberInfoResult.getNextSeq());
                TUIValueCallback.onSuccess(callBack, result);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callBack, code, desc);
            }
        });
    }

    public void getFriendList(TUIValueCallback<List<UserBean>> callback) {
        V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                List<UserBean> userBeans = new ArrayList<>();
                for (V2TIMFriendInfo v2TIMFriendInfo : v2TIMFriendInfos) {
                    UserBean reactUserBean = new UserBean();
                    reactUserBean.setUserId(v2TIMFriendInfo.getUserID());
                    reactUserBean.setFriendRemark(v2TIMFriendInfo.getFriendRemark());
                    reactUserBean.setFaceUrl(v2TIMFriendInfo.getUserProfile().getFaceUrl());
                    if (v2TIMFriendInfo.getUserProfile() != null) {
                        reactUserBean.setNickName(v2TIMFriendInfo.getUserProfile().getNickName());
                    }
                    userBeans.add(reactUserBean);
                }
                TUIValueCallback.onSuccess(callback, userBeans);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void getGroupMembersInfo(String groupID, List<String> userIDs, TUIValueCallback<List<UserBean>> callback) {
        V2TIMManager.getGroupManager().getGroupMembersInfo(groupID, userIDs, new V2TIMValueCallback<List<V2TIMGroupMemberFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfos) {
                List<UserBean> userBeans = new ArrayList<>();
                for (V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo : v2TIMGroupMemberFullInfos) {
                    UserBean reactUserBean = new UserBean();
                    reactUserBean.setUserId(v2TIMGroupMemberFullInfo.getUserID());
                    reactUserBean.setFriendRemark(v2TIMGroupMemberFullInfo.getFriendRemark());
                    reactUserBean.setFaceUrl(v2TIMGroupMemberFullInfo.getFaceUrl());
                    if (v2TIMGroupMemberFullInfo.getNickName() != null) {
                        reactUserBean.setNickName(v2TIMGroupMemberFullInfo.getNickName());
                    }
                    userBeans.add(reactUserBean);
                }
                TUIValueCallback.onSuccess(callback, userBeans);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void inviteGroupMembers(String groupID, List<String> addMembers, final TUIValueCallback callBack) {
        if (addMembers == null || addMembers.size() == 0) {
            return;
        }

        V2TIMManager.getGroupManager().inviteUserToGroup(groupID, addMembers, new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {

            @Override
            public void onSuccess(List<V2TIMGroupMemberOperationResult> v2TIMGroupMemberOperationResults) {
                final List<String> adds = new ArrayList<>();
                if (v2TIMGroupMemberOperationResults.size() > 0) {
                    for (int i = 0; i < v2TIMGroupMemberOperationResults.size(); i++) {
                        V2TIMGroupMemberOperationResult res = v2TIMGroupMemberOperationResults.get(i);
                        if (res.getResult() == V2TIMGroupMemberOperationResult.OPERATION_RESULT_PENDING) {
                            callBack.onSuccess(TUIContactService.getAppContext().getString(R.string.request_wait));
                            return;
                        }
                        if (res.getResult() > 0) {
                            adds.add(res.getMemberID());
                        }
                    }
                }

            }

            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "addGroupMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                TUIValueCallback.onError(callBack, code, ErrorMessageConverter.convertIMError(code, desc));
            }

        });
    }


    public void removeGroupMembers(String groupId, List<String> members, final TUIValueCallback<List<String>> callBack) {
        if (members == null || members.size() == 0) {
            return;
        }

        V2TIMManager.getGroupManager().kickGroupMember(groupId, members, "", new V2TIMValueCallback<List<V2TIMGroupMemberOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "removeGroupMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
                TUIValueCallback.onError(callBack, code, ErrorMessageConverter.convertIMError(code, desc));
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
                TUIValueCallback.onSuccess(callBack, dels);
            }
        });
    }

    public void transferGroupOwner(String groupId, String userId, TUICallback callback) {
        V2TIMManager.getGroupManager().transferGroupOwner(groupId, userId, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

}
