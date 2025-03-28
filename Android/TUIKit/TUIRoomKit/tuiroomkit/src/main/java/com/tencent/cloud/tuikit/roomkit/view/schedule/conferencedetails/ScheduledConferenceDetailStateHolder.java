package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencedetails;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceListState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Calendar;
import java.util.List;
import java.util.Locale;

public class ScheduledConferenceDetailStateHolder {
    private       String                                     mCurrentConferenceId  = "";
    public        LiveData<Boolean>                          mConferenceCanceled   = new LiveData<>(false);
    private final LiveData<ScheduledConferenceDetailUiState> mConferenceDetailData = new LiveData<>(new ScheduledConferenceDetailUiState());
    public        LiveListData<UserState.UserInfo>           hadScheduledAttendees = new LiveListData<>();
    public        LiveListObserver<UserState.UserInfo>       mAttendeesObserver    = new LiveListObserver<UserState.UserInfo>() {
        public void onDataChanged(List<UserState.UserInfo> list) {
            ScheduledConferenceDetailUiState uiState = mConferenceDetailData.get();
            uiState.attendees.clear();
            uiState.attendees.addAll(list);
            mConferenceDetailData.set(uiState);
        }

        public void onItemInserted(int position, UserState.UserInfo item) {
            ScheduledConferenceDetailUiState uiState = mConferenceDetailData.get();
            uiState.attendees.add(item);
            mConferenceDetailData.set(uiState);
        }

        public void onItemRemoved(int position, UserState.UserInfo item) {
            ScheduledConferenceDetailUiState uiState = mConferenceDetailData.get();
            uiState.attendees.remove(item);
            mConferenceDetailData.set(uiState);
        }
    };

    private final LiveListObserver<ConferenceListState.ConferenceInfo> mConferencesObserver = new LiveListObserver<ConferenceListState.ConferenceInfo>() {
        @Override
        public void onItemChanged(int position, ConferenceListState.ConferenceInfo item) {
            if (!TextUtils.equals(mCurrentConferenceId, item.basicRoomInfo.roomId)) {
                return;
            }
            updateView(item);
        }

        @Override
        public void onItemRemoved(int position, ConferenceListState.ConferenceInfo item) {
            if (!TextUtils.equals(mCurrentConferenceId, item.basicRoomInfo.roomId)) {
                return;
            }
            mConferenceCanceled.set(true);
        }
    };

    public void observer(Observer<ScheduledConferenceDetailUiState> observer, String conferenceId) {
        mCurrentConferenceId = conferenceId;
        mConferenceDetailData.observe(observer);
        ConferenceListState.ConferenceInfo conferenceInfo = ScheduleController.sharedInstance().getConferenceListState().scheduledConferences.find(new ConferenceListState.ConferenceInfo(conferenceId));
        if (conferenceInfo == null) {
            return;
        }
        initData(conferenceInfo);


        hadScheduledAttendees = conferenceInfo.hadScheduledAttendees;
        hadScheduledAttendees.observe(mAttendeesObserver);
        ScheduleController.sharedInstance().fetchAttendeeList(conferenceId, null);
        ScheduleController.sharedInstance().getConferenceListState().scheduledConferences.observe(mConferencesObserver);
    }

    public void removeObserver(Observer<ScheduledConferenceDetailUiState> observer) {
        mConferenceDetailData.removeObserver(observer);
        hadScheduledAttendees.removeObserver(mAttendeesObserver);
        ScheduleController.sharedInstance().getConferenceListState().scheduledConferences.removeObserver(mConferencesObserver);
    }

    private void initData(ConferenceListState.ConferenceInfo conferenceInfo) {
        ScheduledConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.conferenceName = conferenceInfo.basicRoomInfo.name;
        uiState.conferenceId = conferenceInfo.basicRoomInfo.roomId;
        uiState.scheduledStartTime = toDateFormat(conferenceInfo.scheduleStartTime);
        uiState.scheduledDuration = millisToMinute((conferenceInfo.scheduleEndTime - conferenceInfo.scheduleStartTime));
        uiState.conferenceType = parseConferenceType(conferenceInfo.basicRoomInfo.isSeatEnabled);
        uiState.conferenceOwner = conferenceInfo.basicRoomInfo.ownerName;
        uiState.attendees.clear();
        uiState.attendees.addAll(conferenceInfo.hadScheduledAttendees.getList());
        uiState.conferenceOwnerId = conferenceInfo.basicRoomInfo.ownerId;
        uiState.conferenceStatus = conferenceInfo.status;
        uiState.conferenceTime = getRoomTimeString(conferenceInfo.scheduleStartTime, conferenceInfo.scheduleEndTime);
        mConferenceDetailData.set(uiState);
    }

    private void updateView(ConferenceListState.ConferenceInfo newInfo) {
        ScheduledConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.conferenceName = newInfo.basicRoomInfo.name;
        uiState.scheduledStartTime = toDateFormat(newInfo.scheduleStartTime);
        uiState.scheduledDuration = millisToMinute((newInfo.scheduleEndTime - newInfo.scheduleStartTime));
        uiState.conferenceStatus = newInfo.status;
        uiState.conferenceTime = getRoomTimeString(newInfo.scheduleStartTime, newInfo.scheduleEndTime);
        mConferenceDetailData.set(uiState);
    }

    private String getRoomTimeString(long startTimestamp, long endTimestamp) {
        Context context = TUILogin.getAppContext();
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(startTimestamp);
        int startYear = calendar.get(Calendar.YEAR);
        int startMonth = calendar.get(Calendar.MONTH) + 1;
        int startDay = calendar.get(Calendar.DAY_OF_MONTH);
        int startHour = calendar.get(Calendar.HOUR_OF_DAY);
        int startMinute = calendar.get(Calendar.MINUTE);

        calendar.setTimeInMillis(endTimestamp);
        int endYear = calendar.get(Calendar.YEAR);
        int endMonth = calendar.get(Calendar.MONTH) + 1;
        int endDay = calendar.get(Calendar.DAY_OF_MONTH);
        int endHour = calendar.get(Calendar.HOUR_OF_DAY);
        int endMinute = calendar.get(Calendar.MINUTE);

        String yearUnit = context.getString(R.string.tuiroomkit_year_text);
        String monthUnit = context.getString(R.string.tuiroomkit_month_text);
        String dayUnit = context.getString(R.string.tuiroomkit_day_text);
        String startTimeString = String.format(Locale.getDefault(), context.getString(R.string.tuiroomkit_format_conference_start_time), startYear, yearUnit, startMonth, monthUnit, startDay, dayUnit, startHour, startMinute);
        if (startYear == endYear && startMonth == endMonth && startDay == endDay) {
            return String.format(Locale.getDefault(), context.getString(R.string.tuiroomkit_format_conference_time), startTimeString, endHour, endMinute);
        }
        return String.format(Locale.getDefault(), context.getString(R.string.tuiroomkit_format_conference_next_day_time), startTimeString, endHour, endMinute);
    }

    private String toDateFormat(long time) {
        Context context = TUILogin.getAppContext();
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(time);
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day = calendar.get(Calendar.DAY_OF_MONTH);
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        String yearUnit = context.getString(R.string.tuiroomkit_year_text);
        String monthUnit = context.getString(R.string.tuiroomkit_month_text);
        String dayUnit = context.getString(R.string.tuiroomkit_day_text);
        return String.format(Locale.getDefault(), context.getString(R.string.tuiroomkit_format_conference_start_time), year, yearUnit, month, monthUnit, day, dayUnit, hour, minute);
    }

    private String millisToMinute(long duration) {
        return TUILogin.getAppContext().getString(R.string.tuiroomkit_minute_text, (duration / 1000 / 60));
    }

    private String parseConferenceType(boolean isSeatEnabled) {
        int id = isSeatEnabled ? R.string.tuiroomkit_room_raise_hand : R.string.tuiroomkit_room_free_speech;
        return TUILogin.getAppContext().getString(id);
    }
}
