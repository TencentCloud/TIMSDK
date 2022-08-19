package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;

import java.util.List;

public abstract class ContactEventListener {
    /**
     * 好友申请新增通知，两种情况会收到这个回调：
     * 1. 自己申请加别人好友
     * 2. 别人申请加自己好友
     * 
     * New friend request notification. You will receive this callback in the following cases:
     * 1. You send a friend request to others.
     * 2. You receive a friend request from others.
     */
    public void onFriendApplicationListAdded(List<FriendApplicationBean> applicationList) {
    }

    /**
     * 好友申请删除通知，四种情况会收到这个回调
     * 1. 调用 deleteFriendApplication 主动删除好友申请
     * 2. 调用 refuseFriendApplication 拒绝好友申请
     * 3. 调用 acceptFriendApplication 同意好友申请且同意类型为 V2TIM_FRIEND_ACCEPT_AGREE 时
     * 4. 申请加别人好友被拒绝
     * 
     * 
     * Friend request deletion notification. You will receive this callback in the following cases:
     * 1. You call deleteFriendApplication to proactively delete a friend request.
     * 2. You call refuseFriendApplication to reject a friend request.
     * 3. You call acceptFriendApplication to accept a friend request and the acceptance type is V2TIM_FRIEND_ACCEPT_AGREE.
     * 4. Your friend request is rejected by others.
     */
    public void onFriendApplicationListDeleted(List<String> userIDList) {
    }

    /**
     * 好友申请已读通知，如果调用 setFriendApplicationRead 设置好友申请列表已读，会收到这个回调（主要用于多端同步）
     * 
     * Friend request read notification. When you call setFriendApplicationRead to set the friend request list as read, you will receive this callback (mainly used for multi-device synchronization).
     */
    public void onFriendApplicationListRead() {
    }

    /**
     * 好友新增通知
     * 
     * New friend notification
     */
    public void onFriendListAdded(List<ContactItemBean> users) {
    }

    /**
     * 好友删除通知，，两种情况会收到这个回调：
     * 1. 自己删除好友（单向和双向删除都会收到回调）
     * 2. 好友把自己删除（双向删除会收到）
     * 
     * Friend deletion notification. You will receive this callback in the following cases:
     * 1. You delete a friend (received for one-way or two-way friend deletion).
     * 2. You are deleted by a friend (received for two-way friend deletion).
     */
    public void onFriendListDeleted(List<String> userList) {
    }

    /**
     * 黑名单新增通知
     * 
     * New blocklist notification
     */
    public void onBlackListAdd(List<ContactItemBean> infoList) {
    }

    /**
     * 黑名单删除通知
     * 
     * Blocklist deletion notification
     */
    public void onBlackListDeleted(List<String> userList) {
    }

    /**
     * 好友资料更新通知
     * 
     * Friend profile update notification
     */
    public void onFriendInfoChanged(List<ContactItemBean> infoList) {
    }
    /**
     * 好友资料更新通知
     * 
     * Friend Remark update notification
     */
    public void onFriendRemarkChanged(String id, String remark) {
    }

    /**
     * 好友在线状态变更通知
     * 
     * User status update notification
     */
    public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList){
    }

    /**
     * 刷新界面在线状态显示隐藏
     */
    public void refreshUserStatusFragmentUI() {
    }
}
