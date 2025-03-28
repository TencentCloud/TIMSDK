package com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant;

import android.content.Context;

import com.tencent.cloud.tuikit.roomkit.impl.ConferenceSessionImpl;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.DefaultContactsActivity;

import java.util.List;

public class ParticipantSelector {
    public interface ParticipantSelectCallback {
        void onParticipantSelected(List<UserState.UserInfo> participants);
    }

    public interface IParticipantSelection {
        void startParticipantSelect(Context context, ConferenceParticipants participants, ParticipantSelectCallback participantSelectCallback);
    }

    public void startParticipantSelect(Context context, ConferenceParticipants participants, ParticipantSelectCallback callback) {
        IParticipantSelection selection = getParticipantSelection();
        if (selection == null) {
            return;
        }
        selection.startParticipantSelect(context, participants, callback);
    }

    private IParticipantSelection getParticipantSelection() {
        Class<?> activity = ConferenceSessionImpl.sharedInstance().mContactsActivity;
        String simpleName = DefaultContactsActivity.class.getSimpleName();
        if (activity != null) {
            simpleName = activity.getSimpleName();
        }
        return new CustomSelector(simpleName);
    }
}
