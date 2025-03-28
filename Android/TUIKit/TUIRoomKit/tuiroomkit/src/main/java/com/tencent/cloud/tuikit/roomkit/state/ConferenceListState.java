package com.tencent.cloud.tuikit.roomkit.state;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListData;

import java.util.ArrayList;
import java.util.List;

public class ConferenceListState {
    public LiveListData<ConferenceInfo> scheduledConferences            = new LiveListData<>();
    public String                       fetchScheduledConferencesCursor = FETCH_CURSOR_OF_INIT;

    public static final String FETCH_CURSOR_OF_INIT = "init";
    public static final String FETCH_CURSOR_OF_END  = "end";

    public static class ConferenceInfo {
        public long                                      scheduleStartTime             = 0L;
        public long                                      scheduleEndTime               = 0L;
        public List<UserState.UserInfo>                  scheduleAttendees             = new ArrayList<>();
        public LiveListData<UserState.UserInfo>          hadScheduledAttendees         = new LiveListData<>();
        public String                                    fetchScheduledAttendeesCursor = FETCH_CURSOR_OF_INIT;
        public LiveData<Integer>                         hadScheduledAttendeeCount     = new LiveData<>(0);
        public int                                       reminderSecondsBeforeStart    = 0;
        public TUIConferenceListManager.ConferenceStatus status                        = TUIConferenceListManager.ConferenceStatus.NONE;
        public TUIRoomDefine.RoomInfo                    basicRoomInfo                 = new TUIRoomDefine.RoomInfo();

        public ConferenceInfo(String conferenceId) {
            this.basicRoomInfo.roomId = conferenceId;
            this.basicRoomInfo.seatMode = TUIRoomDefine.SeatMode.APPLY_TO_TAKE;
        }

        public ConferenceInfo(TUIConferenceListManager.ConferenceInfo conferenceInfo) {
            this.status = conferenceInfo.status;
            update(conferenceInfo);
        }

        public void update(TUIConferenceListManager.ConferenceInfo conferenceInfo) {
            this.scheduleStartTime = conferenceInfo.scheduleStartTime;
            this.scheduleEndTime = conferenceInfo.scheduleEndTime;
            this.reminderSecondsBeforeStart = conferenceInfo.reminderSecondsBeforeStart;
            this.basicRoomInfo = conferenceInfo.basicRoomInfo;
        }

        public TUIConferenceListManager.ConferenceInfo transferToEngineData() {
            TUIConferenceListManager.ConferenceInfo info = new TUIConferenceListManager.ConferenceInfo();
            info.scheduleStartTime = this.scheduleStartTime;
            info.scheduleEndTime = this.scheduleEndTime;
            info.scheduleAttendees = new ArrayList<>(this.scheduleAttendees.size());
            for (UserState.UserInfo item : this.scheduleAttendees) {
                info.scheduleAttendees.add(item.userId);
            }
            info.reminderSecondsBeforeStart = this.reminderSecondsBeforeStart;
            info.status = this.status;
            info.basicRoomInfo = this.basicRoomInfo;
            return info;
        }

        @Override
        public boolean equals(@Nullable Object obj) {
            if (obj instanceof ConferenceInfo) {
                return TextUtils.equals(this.basicRoomInfo.roomId, ((ConferenceInfo) obj).basicRoomInfo.roomId);
            }
            return false;
        }
    }
}

