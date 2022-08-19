package com.tencent.qcloud.tuikit.tuigroup.presenter;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.model.GroupInfoProvider;

import java.util.List;

public class GroupManagerPresenter {
    private final GroupInfoProvider provider;

    public GroupManagerPresenter() {
        provider = new GroupInfoProvider();
    }

    public void muteAll(String groupId, boolean isAllMute, IUIKitCallback<Void> callback) {
        provider.muteAll(groupId, isAllMute, callback);
    }

    public void loadGroupManager(String groupId, IUIKitCallback<List<GroupMemberInfo>> callback) {
        provider.loadGroupManagers(groupId, callback);
    }

    public void loadGroupOwner(String groupId, IUIKitCallback<GroupMemberInfo> callback) {
        provider.loadGroupOwner(groupId, callback);
    }

    public void loadMutedMembers(String groupId, IUIKitCallback<List<GroupMemberInfo>> callback) {
        provider.loadMutedMembers(groupId, callback);
    }

    public void muteGroupMember(String groupId, String userId, IUIKitCallback<Void> callback) {
        int muteTime = 365 * 24 * 3600; // 365 days
        provider.muteGroupMember(groupId, userId, muteTime, callback);
    }

    public void setGroupManager(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.setGroupManager(groupId, userId, callback);
    }

    public void clearGroupManager(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.clearGroupManager(groupId, userId, callback);
    }

    public void cancelMuteGroupMember(String groupId, String userId, IUIKitCallback<Void> callback) {
        provider.cancelMuteGroupMember(groupId, userId, callback);
    }

    public void modifyGroupNotification(String groupId, String value, IUIKitCallback<Void> callback) {
        provider.modifyGroupNotification(groupId, value, callback);
    }
}
