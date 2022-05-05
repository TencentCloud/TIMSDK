package com.tencent.qcloud.tuikit.tuisearch.util;

import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.GroupInfo;

import java.util.ArrayList;
import java.util.List;

public class GroupInfoUtils {
    public static GroupInfo convertTimGroupInfo2GroupInfo(V2TIMGroupInfo v2TIMGroupInfo) {
        if (v2TIMGroupInfo == null) {
            return null;
        }
        GroupInfo groupInfo = new GroupInfo();
        groupInfo.setId(v2TIMGroupInfo.getGroupID());
        groupInfo.setGroupName(v2TIMGroupInfo.getGroupName());
        groupInfo.setGroupType(v2TIMGroupInfo.getGroupType());
        groupInfo.setMemberCount(v2TIMGroupInfo.getMemberCount());
        groupInfo.setOwner(v2TIMGroupInfo.getOwner());
        groupInfo.setNotice(v2TIMGroupInfo.getNotification());
        groupInfo.setFaceUrl(v2TIMGroupInfo.getFaceUrl());
        return groupInfo;
    }
}