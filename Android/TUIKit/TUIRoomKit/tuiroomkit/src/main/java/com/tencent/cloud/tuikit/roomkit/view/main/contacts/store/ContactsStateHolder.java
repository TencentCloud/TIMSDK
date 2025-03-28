package com.tencent.cloud.tuikit.roomkit.view.main.contacts.store;

import android.text.TextUtils;

import com.trtc.tuikit.common.livedata.LiveListData;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.List;

public class ContactsStateHolder {
    public LiveListData<Participants> mParticipants = new LiveListData<>();

    public void observe(LiveListObserver<Participants> observer) {
        mParticipants.observe(observer);
    }

    public void removeObserve(LiveListObserver<Participants> observer) {
        mParticipants.removeObserver(observer);
    }

    public void initAttendees(List<Participants> attendees) {
        mParticipants.replaceAll(attendees);
    }

    public void changeParticipant(Participants user) {
        for (Participants participants : mParticipants.getList()) {
            if (TextUtils.equals(user.userInfo.id, participants.userInfo.id)) {
                participants.isSelected = user.isSelected;
                mParticipants.change(participants);
                break;
            }
        }
    }
}
