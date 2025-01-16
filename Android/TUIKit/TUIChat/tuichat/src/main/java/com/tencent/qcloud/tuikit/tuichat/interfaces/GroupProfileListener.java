package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberBean;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;

public interface GroupProfileListener {
    void onGroupProfileLoaded(GroupProfileBean groupProfileBean);

    void onSelfInfoLoaded(GroupMemberBean groupMemberBean);

    void onConversationCheckResult(boolean isPinned, boolean isFolded);

    void onGroupProfileChanged(V2TIMGroupChangeInfo changeInfo);

    void onGroupMemberCountChanged(int count);
}
