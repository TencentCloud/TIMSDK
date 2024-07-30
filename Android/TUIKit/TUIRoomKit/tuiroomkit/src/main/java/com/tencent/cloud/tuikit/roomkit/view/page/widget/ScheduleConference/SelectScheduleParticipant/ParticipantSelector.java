package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import android.content.Context;

import com.tencent.cloud.tuikit.roomkit.CustomViewConfig;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.List;

public class ParticipantSelector {
    public interface ParticipantSelectCallback {
        void onParticipantSelected(List<UserState.UserInfo> participants);
    }
    public interface IParticipantSelection {
        void startParticipantSelect(Context context, List<UserState.UserInfo> participants, ParticipantSelectCallback participantSelectCallback);
    }

    public void startParticipantSelect(Context context, List<UserState.UserInfo> participants, ParticipantSelectCallback callback) {
        IParticipantSelection selection = getParticipantSelection();
        if (selection == null) {
            return;
        }
        selection.startParticipantSelect(context, participants, callback);
    }

    private IParticipantSelection getParticipantSelection() {
        IParticipantSelection selection = CustomViewConfig.sharedInstance().getParticipantSelection();
        if (selection != null) {
            return selection;
        }
        ITUIService service = TUICore.getService(TUIConstants.TUIContact.SERVICE_NAME);
        if (service != null) {
            return new IMContactSelector();
        }
        return null;
    }
}
