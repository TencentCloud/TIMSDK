package com.tencent.qcloud.tuikit.tuicontact.presenter;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuicontact.model.GroupInfoProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;

import java.util.ArrayList;
import java.util.List;

public class GroupInfoPresenter {
    public static final String TAG = GroupInfoPresenter.class.getSimpleName();

    private final IGroupMemberLayout layout;
    private final GroupInfoProvider provider;

    private GroupInfo groupInfo;
    private GroupMemberInfo selfGroupMemberInfo;

    public GroupInfoPresenter(IGroupMemberLayout layout) {
        this.layout = layout;
        provider = new GroupInfoProvider();
    }

    public void setGroupInfo(GroupInfo groupInfo) {
        this.groupInfo = groupInfo;
    }

    public void loadGroupInfo(String groupId) {
        loadGroupInfo(groupId, GroupInfo.GROUP_MEMBER_FILTER_ALL);
    }

    public void loadGroupInfo(String groupId, int filter) {
        provider.loadGroupInfo(groupId, filter, new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                groupInfo = data;
                layout.onGroupInfoChanged(data);

                String conversationId = ContactUtils.getConversationIdByUserId(groupId, true);
                V2TIMManager.getConversationManager().getConversation(conversationId, new V2TIMValueCallback<V2TIMConversation>() {
                    @Override
                    public void onSuccess(V2TIMConversation v2TIMConversation) {
                        boolean isTop = v2TIMConversation.isPinned();
                        groupInfo.setTopChat(isTop);

                        List<Long> markList = v2TIMConversation.getMarkList();
                        if (markList.contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD)) {
                            groupInfo.setFolded(true);
                        }

                        layout.onGroupInfoChanged(groupInfo);
                        loadGroupMemberList(groupInfo, filter);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        loadGroupMemberList(groupInfo, filter);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e("loadGroupInfo", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    private void loadGroupMemberList(GroupInfo groupInfo, int filter) {
        provider.loadGroupMembers(groupInfo, filter, 0, new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                layout.onGroupMemberListChanged(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e("loadGroupMembers", errCode + ":" + errMsg);
            }
        });
    }

    public void getGroupMembers(GroupInfo groupInfo, final IUIKitCallback<GroupInfo> callBack) {
        provider.loadGroupMembers(groupInfo, groupInfo.getNextSeq(), new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                if (layout != null) {
                    layout.onGroupMemberListChanged(data);
                }
                ContactUtils.callbackOnSuccess(callBack, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e("loadGroupInfo", errCode + ":" + errMsg);
                ContactUtils.callbackOnError(callBack, errCode, errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public String getNickName() {
        String nickName = "";
        GroupMemberInfo self = getSelfGroupMemberInfo();
        if (self != null) {
            nickName = self.getNameCard();
        }
        return nickName == null ? "" : nickName;
    }

    private void inviteGroupMembers(List<String> addMembers, IUIKitCallback<Object> callback) {
        provider.inviteGroupMembers(groupInfo, addMembers, new IUIKitCallback<Object>() {
            @Override
            public void onSuccess(Object data) {
                ContactUtils.callbackOnSuccess(callback, data);
                if (layout != null) {
                    layout.onGroupMemberListChanged(groupInfo);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void inviteGroupMembers(String groupId, List<String> addMembers, IUIKitCallback<Object> callback) {
        provider.loadGroupInfo(groupId, new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                groupInfo = data;
                inviteGroupMembers(addMembers, callback);
                loadGroupMemberList(groupInfo, GroupInfo.GROUP_MEMBER_FILTER_ALL);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void deleteGroupMembers(String groupId, List<String> members, IUIKitCallback<List<String>> callback) {
        provider.removeGroupMembers(groupId, members, callback);
    }

    public void removeGroupMembers(GroupInfo groupInfo, List<GroupMemberInfo> delMembers, IUIKitCallback callBack) {
        List<String> memberAccountList = new ArrayList<>();
        for (GroupMemberInfo memberInfo : delMembers) {
            memberAccountList.add(memberInfo.getUserId());
        }
        provider.removeGroupMembers(groupInfo.getId(), memberAccountList, new IUIKitCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> data) {
                List<GroupMemberInfo> memberInfoList = groupInfo.getMemberDetails();
                for (int i = 0; i < data.size(); i++) {
                    for (int j = memberInfoList.size() - 1; j >= 0; j--) {
                        if (memberInfoList.get(j).getUserId().equals(data.get(i))) {
                            memberInfoList.remove(j);
                            break;
                        }
                    }
                }
                ContactUtils.callbackOnSuccess(callBack, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callBack, errCode, errMsg);
            }
        });
    }

    public GroupMemberInfo getSelfGroupMemberInfo() {
        if (selfGroupMemberInfo != null) {
            return selfGroupMemberInfo;
        }
        if (groupInfo == null) {
            return null;
        }

        GroupMemberInfo groupMemberInfo = provider.getSelfGroupMemberInfo(groupInfo);
        selfGroupMemberInfo = groupMemberInfo;
        return selfGroupMemberInfo;
    }

    public boolean isAdmin(int memberType) {
        return provider.isAdmin(memberType);
    }

    public boolean isOwner(int memberType) {
        return provider.isOwner(memberType);
    }

    public boolean isSelf(String userId) {
        return provider.isSelf(userId);
    }

    public void setGroupManager(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.setGroupManagerRole(groupId, userId, callback);
    }

    public void setGroupMemberRole(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.setGroupMemberRole(groupId, userId, callback);
    }

    public void getFriendList(TUIValueCallback<List<UserBean>> callback) {
        provider.getFriendList(callback);
    }

    public void getGroupMembersInfo(String groupID, List<String> userIDs, TUIValueCallback<List<UserBean>> callback) {
        provider.getGroupMembersInfo(groupID, userIDs, callback);
    }

    public void getFriendListInGroup(String groupID, TUIValueCallback<List<UserBean>> callback) {
        getFriendList(new TUIValueCallback<List<UserBean>>() {
            @Override
            public void onSuccess(List<UserBean> userBeans) {
                List<String> userIDs = new ArrayList<>();
                for (UserBean userBean : userBeans) {
                    userIDs.add(userBean.getUserId());
                }
                getGroupMembersInfo(groupID, userIDs, new TUIValueCallback<List<UserBean>>() {
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
}
