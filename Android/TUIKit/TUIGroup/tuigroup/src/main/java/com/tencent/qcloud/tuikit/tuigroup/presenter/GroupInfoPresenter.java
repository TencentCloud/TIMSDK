package com.tencent.qcloud.tuikit.tuigroup.presenter;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.GroupEventListener;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.model.GroupInfoProvider;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupUtils;
import java.util.ArrayList;
import java.util.List;

public class GroupInfoPresenter {
    public static final String TAG = GroupInfoPresenter.class.getSimpleName();

    private final IGroupMemberLayout layout;
    private final GroupInfoProvider provider;

    private GroupInfo groupInfo;
    private GroupMemberInfo selfGroupMemberInfo;

    private GroupEventListener groupEventListener;

    public GroupInfoPresenter(IGroupMemberLayout layout) {
        this.layout = layout;
        provider = new GroupInfoProvider();
    }

    public void setGroupEventListener() {
        groupEventListener = new GroupEventListener() {
            @Override
            public void onGroupInfoChanged(String groupID) {
                GroupInfoPresenter.this.onGroupInfoChanged(groupID);
            }

            @Override
            public void onGroupMemberCountChanged(String groupID) {
                GroupInfoPresenter.this.onGroupCountChanged(groupID);
            }
        };
        TUIGroupService.getInstance().addGroupEventListener(groupEventListener);
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
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e("loadGroupInfo", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    private void onGroupInfoChanged(String groupID) {
        if (groupInfo != null && TextUtils.equals(groupID, groupInfo.getId())) {
            loadGroupInfo(groupID);
        }
    }

    private void onGroupCountChanged(String groupID) {
        if (groupInfo != null && TextUtils.equals(groupID, groupInfo.getId())) {
            loadGroupInfo(groupID);
        }
    }

    public void getGroupMembers(GroupInfo groupInfo, final IUIKitCallback<GroupInfo> callBack) {
        provider.loadGroupMembers(groupInfo, groupInfo.getNextSeq(), new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                if (layout != null) {
                    layout.onGroupInfoChanged(data);
                }
                TUIGroupUtils.callbackOnSuccess(callBack, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e("loadGroupInfo", errCode + ":" + errMsg);
                TUIGroupUtils.callbackOnError(callBack, errCode, errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void modifyGroupName(final String name) {
        if (groupInfo == null) {
            return;
        }
        provider.modifyGroupInfo(groupInfo, name, TUIGroupConstants.Group.MODIFY_GROUP_NAME, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                layout.onGroupInfoModified(name, TUIGroupConstants.Group.MODIFY_GROUP_NAME);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e("modifyGroupName", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void modifyGroupNotice(final String notice) {
        if (groupInfo == null) {
            return;
        }
        provider.modifyGroupInfo(groupInfo, notice, TUIGroupConstants.Group.MODIFY_GROUP_NOTICE, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                layout.onGroupInfoModified(notice, TUIGroupConstants.Group.MODIFY_GROUP_NOTICE);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e("modifyGroupNotice", errCode + ":" + errMsg);
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

    public void modifyMyGroupNickname(final String nickname) {
        provider.modifyMyGroupNickname(groupInfo, nickname, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                layout.onGroupInfoModified(nickname, TUIGroupConstants.Group.MODIFY_MEMBER_NAME);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e("modifyMyGroupNickname", errCode + ":" + errMsg);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void deleteGroup(IUIKitCallback<Void> callback) {
        if (groupInfo == null) {
            return;
        }
        String groupId = groupInfo.getId();
        provider.deleteGroup(groupId, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupLog.e("deleteGroup", errCode + ":" + errMsg);
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void setTopConversation(String groupId, boolean isSetTop, IUIKitCallback<Void> callback) {
        String conversationId = TUIGroupUtils.getConversationIdByUserId(groupId, true);
        provider.setTopConversation(conversationId, isSetTop, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                groupInfo.setTopChat(isSetTop);
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void quitGroup(IUIKitCallback<Void> callback) {
        if (groupInfo == null) {
            return;
        }
        String groupId = groupInfo.getId();
        provider.quitGroup(groupId, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
                TUIGroupLog.e("quitGroup", errCode + ":" + errMsg);
            }
        });
    }

    public void modifyGroupInfo(int value, int type) {
        if (groupInfo == null) {
            return;
        }
        provider.modifyGroupInfo(groupInfo, value, type, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                layout.onGroupInfoModified(data, TUIGroupConstants.Group.MODIFY_GROUP_JOIN_TYPE);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage("modifyGroupInfo fail :" + errCode + "=" + errMsg);
            }
        });
    }

    private void inviteGroupMembers(List<String> addMembers, IUIKitCallback<Object> callback) {
        provider.inviteGroupMembers(groupInfo, addMembers, new IUIKitCallback<Object>() {
            @Override
            public void onSuccess(Object data) {
                TUIGroupUtils.callbackOnSuccess(callback, data);
                if (layout != null) {
                    layout.onGroupInfoChanged(groupInfo);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void inviteGroupMembers(String groupId, List<String> addMembers, IUIKitCallback<Object> callback) {
        provider.loadGroupInfo(groupId, new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                groupInfo = data;
                inviteGroupMembers(addMembers, callback);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void deleteGroupMembers(String groupId, List<String> members, IUIKitCallback<List<String>> callback) {
        provider.removeGroupMembers(groupId, members, callback);
    }

    public void removeGroupMembers(GroupInfo groupInfo, List<GroupMemberInfo> delMembers, IUIKitCallback callBack) {
        List<String> memberAccountList = new ArrayList<>();
        for (GroupMemberInfo memberInfo : delMembers) {
            memberAccountList.add(memberInfo.getAccount());
        }
        provider.removeGroupMembers(groupInfo.getId(), memberAccountList, new IUIKitCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> data) {
                List<GroupMemberInfo> memberInfoList = groupInfo.getMemberDetails();
                for (int i = 0; i < data.size(); i++) {
                    for (int j = memberInfoList.size() - 1; j >= 0; j--) {
                        if (memberInfoList.get(j).getAccount().equals(data.get(i))) {
                            memberInfoList.remove(j);
                            break;
                        }
                    }
                }
                TUIGroupUtils.callbackOnSuccess(callBack, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callBack, errCode, errMsg);
            }
        });
    }

    public void setGroupNotDisturb(GroupInfo groupInfo, boolean isChecked, IUIKitCallback<Void> callback) {
        if (groupInfo == null) {
            TUIGroupLog.e(TAG, "mGroupInfo is NULL");
            return;
        }

        provider.setGroupReceiveMessageOpt(groupInfo.getId(), !isChecked, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                groupInfo.setMessageReceiveOption(!isChecked);
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void setGroupFold(GroupInfo groupInfo, boolean isChecked, IUIKitCallback<Void> callback) {
        if (groupInfo == null) {
            TUIGroupLog.e(TAG, "mGroupInfo is NULL");
            return;
        }

        provider.setGroupFold(groupInfo.getId(), isChecked, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                groupInfo.setFolded(isChecked);
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void modifyGroupFaceUrl(String groupId, String faceUrl, IUIKitCallback<Void> callback) {
        provider.modifyGroupFaceUrl(groupId, faceUrl, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUIGroupUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIGroupUtils.callbackOnError(callback, module, errCode, errMsg);
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

    public void transferGroupOwner(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.transferGroupOwner(groupId, userId, callback);
    }

    public void setGroupManager(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.setGroupManagerRole(groupId, userId, callback);
    }

    public void setGroupMemberRole(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.setGroupMemberRole(groupId, userId, callback);
    }
}
