package com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;

import java.io.Serializable;
import java.util.ArrayList;

public class ConferenceParticipants implements Serializable {
    public ArrayList<ConferenceDefine.User> selectedList     = new ArrayList<>();
    public ArrayList<ConferenceDefine.User> unSelectableList = new ArrayList<>();
}
