package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;

import java.io.Serializable;
import java.util.ArrayList;

public class ConferenceParticipants implements Serializable {
    public ArrayList<ConferenceDefine.User> selectedList     = new ArrayList<>();
    public ArrayList<ConferenceDefine.User> unSelectableList = new ArrayList<>();
}
