package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import android.content.Context;
import android.os.Bundle;

import androidx.activity.result.ActivityResultCaller;

import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.ArrayList;
import java.util.List;

public class CustomSelector implements ParticipantSelector.IParticipantSelection {
    public static final String CONFERENCE_PARTICIPANTS = "CONFERENCE_PARTICIPANTS";
    public static final String SELECTED_PARTICIPANTS   = "SELECTED_PARTICIPANTS";

    private String mSelectActivityName = "";

    public CustomSelector(String activityName) {
        mSelectActivityName = activityName;
    }

    @Override
    public void startParticipantSelect(Context context, ConferenceParticipants participants, ParticipantSelector.ParticipantSelectCallback participantSelectCallback) {
        if (!(context instanceof ActivityResultCaller)) {
            return;
        }
        ActivityResultCaller caller = (ActivityResultCaller) context;
        Bundle param = new Bundle();
        param.putSerializable(CONFERENCE_PARTICIPANTS, participants);
        TUICore.startActivityForResult(caller, mSelectActivityName, param, result -> {
            if (result.getData() == null) {
                return;
            }
            List<User> selectedParticipants = (List<User>) result.getData().getSerializableExtra(SELECTED_PARTICIPANTS);
            if (selectedParticipants != null) {
                List<UserState.UserInfo> attendees = new ArrayList<>();
                for (User participant : selectedParticipants) {
                    UserState.UserInfo userInfo = new UserState.UserInfo(participant.userId);
                    userInfo.userName = participant.userName;
                    userInfo.avatarUrl = participant.avatarUrl;
                    attendees.add(userInfo);
                }
                participantSelectCallback.onParticipantSelected(attendees);
            }
        });
    }


}
