package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import android.content.Context;

import com.tencent.cloud.tuikit.roomkit.model.ConferenceSessionImpl;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Contacts.DefaultContactsActivity;

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
