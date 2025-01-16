package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.FriendProfileBean;

public interface FriendProfileListener {
    void onFriendProfileLoaded(FriendProfileBean friendProfileBean);

    void onFriendCheckResult(boolean isFriend);

    void onBlackListCheckResult(boolean isInBlackList);

    void onConversationPinnedCheckResult(boolean isPinned);

    void onMessageHasNotificationCheckResult(boolean hasNotification);
}
