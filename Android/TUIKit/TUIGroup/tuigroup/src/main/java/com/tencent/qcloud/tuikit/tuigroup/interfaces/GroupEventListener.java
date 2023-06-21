package com.tencent.qcloud.tuikit.tuigroup.interfaces;

public abstract class GroupEventListener {
    public void onGroupInfoChanged(String groupID) {}
    
    public void onGroupMemberCountChanged(String groupID) {}
}
