package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import java.io.Serializable;
import java.util.ArrayList;

public class ConferenceParticipants implements Serializable {
    public ArrayList<User> selectedList     = new ArrayList<>();
    public ArrayList<User> unSelectableList = new ArrayList<>();
}
