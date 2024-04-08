package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import java.util.List;

public abstract class ContactEventListener {
    /**
     * New friend request notification. You will receive this callback in the following cases:
     * 1. You send a friend request to others.
     * 2. You receive a friend request from others.
     */
    public void onFriendApplicationListAdded(List<FriendApplicationBean> applicationList) {}

    /**
     * Friend request deletion notification. You will receive this callback in the following cases:
     * 1. You call deleteFriendApplication to proactively delete a friend request.
     * 2. You call refuseFriendApplication to reject a friend request.
     * 3. You call acceptFriendApplication to accept a friend request and the acceptance type is V2TIM_FRIEND_ACCEPT_AGREE.
     * 4. Your friend request is rejected by others.
     */
    public void onFriendApplicationListDeleted(List<String> userIDList) {}

    /**
     * Friend request read notification. When you call setFriendApplicationRead to set the friend request list as read, you will receive this callback (mainly
     * used for multi-device synchronization).
     */
    public void onFriendApplicationListRead() {}

    /**
     * New friend notification
     */
    public void onFriendListAdded(List<ContactItemBean> users) {}

    /**
     * Friend deletion notification. You will receive this callback in the following cases:
     * 1. You delete a friend (received for one-way or two-way friend deletion).
     * 2. You are deleted by a friend (received for two-way friend deletion).
     */
    public void onFriendListDeleted(List<String> userList) {}

    /**
     * New blocklist notification
     */
    public void onBlackListAdd(List<ContactItemBean> infoList) {}

    /**
     * Blocklist deletion notification
     */
    public void onBlackListDeleted(List<String> userList) {}

    /**
     * Friend profile update notification
     */
    public void onFriendInfoChanged(List<ContactItemBean> infoList) {}

    /**
     * Friend Remark update notification
     */
    public void onFriendRemarkChanged(String id, String remark) {}

    /**
     * User status update notification
     */
    public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList){}

    public void refreshUserStatusFragmentUI() {}
}
