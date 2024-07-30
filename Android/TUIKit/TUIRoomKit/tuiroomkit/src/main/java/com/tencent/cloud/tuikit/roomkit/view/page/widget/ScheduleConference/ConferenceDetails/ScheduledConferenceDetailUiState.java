package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.ConferenceDetails;

import static com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager.ConferenceStatus.NONE;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;

import java.util.ArrayList;
import java.util.List;

public class ScheduledConferenceDetailUiState {
    public       String                                    conferenceName     = "";
    public       String                                    conferenceId       = "";
    public       String                                    scheduledStartTime = "";
    public       String                                    scheduledDuration  = "";
    public       String                                    conferenceType     = "";
    public       String                                    conferenceOwner    = "";
    public       String                                    conferenceOwnerId  = "";
    public       TUIConferenceListManager.ConferenceStatus conferenceStatus   = NONE;
    public final List<UserState.UserInfo>                  attendees          = new ArrayList<>();
}
