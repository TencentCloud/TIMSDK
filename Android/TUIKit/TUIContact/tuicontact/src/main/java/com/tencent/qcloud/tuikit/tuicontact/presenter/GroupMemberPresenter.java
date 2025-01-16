package com.tencent.qcloud.tuikit.tuicontact.presenter;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.GroupMemberListener;
import com.tencent.qcloud.tuikit.tuicontact.model.GroupMemberProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class GroupMemberPresenter {

    private static final String TAG = "GroupMemberPresenter";

    private GroupMemberProvider provider = new GroupMemberProvider();
    private List<GroupMemberInfo> groupMemberBeanList = new ArrayList<>();
    private GroupMemberListener groupMemberListener;
    private long nextSeq = 0;
    private String groupID;
    private int loadGroupMemberFilter = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL;
    private V2TIMGroupListener groupListener;

    public void setGroupMemberListener(GroupMemberListener groupMemberListener) {
        this.groupMemberListener = groupMemberListener;
    }

    public void setGroupID(String groupID) {
        this.groupID = groupID;
    }

    public void registerListener() {
        groupListener = new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                if (!TextUtils.equals(groupID, GroupMemberPresenter.this.groupID)) {
                    return;
                }
                GroupMemberPresenter.this.onMemberAdded(parseGroupMemberInfo(memberList));
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                if (!TextUtils.equals(groupID, GroupMemberPresenter.this.groupID)) {
                    return;
                }
                GroupMemberPresenter.this.onMemberRemoved(parseGroupMemberInfo(Collections.singletonList(member)));
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                if (!TextUtils.equals(groupID, GroupMemberPresenter.this.groupID)) {
                    return;
                }
                GroupMemberPresenter.this.onMemberAdded(parseGroupMemberInfo(memberList));
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                if (!TextUtils.equals(groupID, GroupMemberPresenter.this.groupID)) {
                    return;
                }
                GroupMemberPresenter.this.onMemberRemoved(parseGroupMemberInfo(memberList));

            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                GroupMemberPresenter.this.onGroupInfoChanged(groupID, changeInfos);
            }

            @Override
            public void onAllGroupMembersMuted(String groupID, boolean isMute) {
                super.onAllGroupMembersMuted(groupID, isMute);
            }
        };
        V2TIMManager.getInstance().addGroupListener(groupListener);
    }

    public void unregisterListener() {
        V2TIMManager.getInstance().removeGroupListener(groupListener);
    }

    private void onMemberAdded(List<GroupMemberInfo> addList) {
        Map<String, GroupMemberInfo> addMap = new LinkedHashMap<>(addList.size());
        for (GroupMemberInfo info : addList) {
            addMap.put(info.getUserId(), info);
        }
        for (GroupMemberInfo exists : groupMemberBeanList) {
            addMap.remove(exists.getUserId());
        }
        if (addMap.isEmpty()) {
            return;
        }
        groupMemberBeanList.addAll(addMap.values());
        if (groupMemberListener != null) {
            groupMemberListener.onGroupMemberLoaded(groupMemberBeanList);
        }
    }

    private void onMemberRemoved(List<GroupMemberInfo> removeList) {
        Map<String, GroupMemberInfo> removeMap = new HashMap<>(removeList.size());
        for (GroupMemberInfo info : removeList) {
            removeMap.put(info.getUserId(), info);
        }
        int oldSize = groupMemberBeanList.size();
        Iterator<GroupMemberInfo> iterator = groupMemberBeanList.listIterator();
        while (iterator.hasNext()) {
            GroupMemberInfo info = iterator.next();
            if (removeMap.containsKey(info.getUserId())) {
                iterator.remove();
            }
        }
        int newSize = groupMemberBeanList.size();
        if (oldSize == newSize) {
            return;
        }
        if (groupMemberListener != null) {
            groupMemberListener.onGroupMemberLoaded(groupMemberBeanList);
        }
    }

    private void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
        if (!TextUtils.equals(groupID, this.groupID)) {
            return;
        }
        for (V2TIMGroupChangeInfo changeInfo : changeInfos) {
            if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT) {
                if (groupMemberListener != null) {
                    groupMemberListener.onGroupMemberLoaded(groupMemberBeanList);
                }
            }
        }
    }

    public void loadGroupMemberList() {
        loadGroupMemberList(0);
    }

    public void loadGroupMemberList(long nextSeq) {
        provider.loadGroupMembers(groupID, loadGroupMemberFilter, nextSeq, new TUIValueCallback<Pair<List<GroupMemberInfo>, Long>>() {
            @Override
            public void onSuccess(Pair<List<GroupMemberInfo>, Long> object) {
                groupMemberBeanList.addAll(object.first);
                GroupMemberPresenter.this.nextSeq = object.second;
                if (groupMemberListener != null) {
                    groupMemberListener.onGroupMemberLoaded(groupMemberBeanList);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIContactLog.e(TAG, "load group member list error, errorCode: " + errorCode + ", errorMessage: " + errorMessage);
            }
        });
    }

    public void getFriendListInGroup(String groupID, TUIValueCallback<List<UserBean>> callback) {
        provider.getFriendList(new TUIValueCallback<List<UserBean>>() {
            @Override
            public void onSuccess(List<UserBean> userBeans) {
                List<String> userIDs = new ArrayList<>();
                for (UserBean userBean : userBeans) {
                    userIDs.add(userBean.getUserId());
                }
                provider.getGroupMembersInfo(groupID, userIDs, new TUIValueCallback<List<UserBean>>() {
                    @Override
                    public void onSuccess(List<UserBean> groupMembers) {
                        TUIValueCallback.onSuccess(callback, groupMembers);
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        TUIValueCallback.onError(callback, errorCode, errorMessage);
                    }
                });
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public void inviteGroupMembers(String groupId, List<String> addMembers) {
        provider.inviteGroupMembers(groupId, addMembers, new TUIValueCallback() {
            @Override
            public void onSuccess(Object object) {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void removeGroupMembers(String groupId, List<String> members) {
        provider.removeGroupMembers(groupId, members, new TUIValueCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> object) {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void transferGroupOwner(String groupId, String userId) {
        provider.transferGroupOwner(groupId, userId, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    private List<GroupMemberInfo> parseGroupMemberInfo(List<V2TIMGroupMemberInfo> v2TIMGroupMemberInfos) {
        List<GroupMemberInfo> members = new ArrayList<>();
        for (V2TIMGroupMemberInfo info : v2TIMGroupMemberInfos) {
            GroupMemberInfo member = new GroupMemberInfo();
            member.setUserId(info.getUserID());
            member.setNameCard(info.getNameCard());
            member.setFriendRemark(info.getFriendRemark());
            member.setNickName(info.getNickName());
            member.setFaceUrl(info.getFaceUrl());
            members.add(member);
        }
        return members;
    }
}