package com.tencent.cloud.tuikit.roomkit.view.schedule;


import com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant.ParticipantSelector;

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
