package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupMessageReadMemberList;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;

import java.util.ArrayList;
import java.util.List;

public class GroupMessageReadMembersInfo {
    private List<GroupMemberInfo> groupMemberInfoList;
    private V2TIMGroupMessageReadMemberList readMembers;

    public void setReadMembers(V2TIMGroupMessageReadMemberList readMembers) {
        this.readMembers = readMembers;
        groupMemberInfoList = new ArrayList<>();
        List<V2TIMGroupMemberInfo> readMemberList = readMembers.getMemberInfoList();
        for (V2TIMGroupMemberInfo v2TIMGroupMemberInfo : readMemberList) {
            GroupMemberInfo memberInfo = new GroupMemberInfo();
            memberInfo.covertTIMGroupMemberInfo(v2TIMGroupMemberInfo);
            groupMemberInfoList.add(memberInfo);
        }
    }

    public boolean isFinished() {
        return readMembers.isFinished();
    }

    public long getNextSeq() {
        readMembers.getMemberInfoList();
        return readMembers.getNextSeq();
    }

    public List<GroupMemberInfo> getGroupMemberInfoList() {
        return groupMemberInfoList;
    }
}
