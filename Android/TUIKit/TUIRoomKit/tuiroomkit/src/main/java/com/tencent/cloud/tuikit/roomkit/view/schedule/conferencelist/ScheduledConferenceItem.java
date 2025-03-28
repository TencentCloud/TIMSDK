package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencelist;


import android.text.TextUtils;

import androidx.annotation.Nullable;

public class ScheduledConferenceItem {
    public static final int TYPE_CONFERENCE_HEADER = 0;
    public static final int TYPE_CONFERENCE_INFO   = 1;

    private int    mType;
    private Object mData;

    public ScheduledConferenceItem(int type, Object data) {
        mType = type;
        mData = data;
    }

    public int getType() {
        return mType;
    }

    public Object getData() {
        return mData;
    }

    @Override
    public boolean equals(@Nullable Object obj) {
        if (!(obj instanceof ScheduledConferenceItem)) {
            return false;
        }
        ScheduledConferenceItem scheduledConferenceItem = (ScheduledConferenceItem) obj;

        if (scheduledConferenceItem.getType() != TYPE_CONFERENCE_INFO || mType != TYPE_CONFERENCE_INFO) {
            return super.equals(obj);
        }
        ScheduledConferenceItemInfo thisInfo = (ScheduledConferenceItemInfo) mData;
        ScheduledConferenceItemInfo compareInfo = (ScheduledConferenceItemInfo) scheduledConferenceItem.getData();
        return TextUtils.equals(thisInfo.id, compareInfo.id);
    }
}
