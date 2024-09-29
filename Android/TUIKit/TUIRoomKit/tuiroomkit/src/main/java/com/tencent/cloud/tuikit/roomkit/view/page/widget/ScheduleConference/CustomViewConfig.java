package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference;

import com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant.ParticipantSelector;

import java.lang.ref.WeakReference;

public class CustomViewConfig {
    private WeakReference<ParticipantSelector.IParticipantSelection> mParticipantSelectionRef = new WeakReference<>(null);

    private CustomViewConfig() {}

    public static CustomViewConfig sharedInstance() {
        return InstanceHolder.sInstance;
    }

    public void setParticipantSelection(ParticipantSelector.IParticipantSelection participantSelection) {
        mParticipantSelectionRef = new WeakReference<>(participantSelection);
    }

    public ParticipantSelector.IParticipantSelection getParticipantSelection() {
        return mParticipantSelectionRef.get();
    }

    private static final class InstanceHolder {
        private static final CustomViewConfig sInstance = new CustomViewConfig();
    }
}
