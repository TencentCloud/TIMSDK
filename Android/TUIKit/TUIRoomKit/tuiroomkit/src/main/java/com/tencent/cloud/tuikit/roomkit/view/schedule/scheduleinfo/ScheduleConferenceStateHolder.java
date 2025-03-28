package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceListState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;
import java.util.TimeZone;

public class ScheduleConferenceStateHolder {
    public final LiveListData<UserState.UserInfo> mAttendeeData = new LiveListData<>();

    public final LiveData<SetConferenceDetailUiState>      mConferenceDetailData  = new LiveData<>(new SetConferenceDetailUiState());
    public final LiveData<SetConferenceDeviceUiState>      mConferenceDeviceData  = new LiveData<>(new SetConferenceDeviceUiState());
    public final LiveData<SetConferenceEncryptViewUiState> mConferenceEncryptData = new LiveData<>(new SetConferenceEncryptViewUiState());

    public LiveListData<UserState.UserInfo> mHadAttendeeData;

    private final LiveListObserver<UserState.UserInfo> mAttendeeObserver = new LiveListObserver<UserState.UserInfo>() {
        public void onDataChanged(List<UserState.UserInfo> list) {
            mAttendeeData.replaceAll(list);
        }

        public void onItemInserted(int position, UserState.UserInfo item) {
            mAttendeeData.add(item);
        }

        public void onItemRemoved(int position, UserState.UserInfo item) {
            mAttendeeData.remove(item);
        }
    };

    public void observeDetail(Observer<SetConferenceDetailUiState> observer, String conferenceId) {
        mConferenceDetailData.observe(observer);
        ConferenceListState.ConferenceInfo conferenceInfo = ScheduleController.sharedInstance().getConferenceListState().scheduledConferences.find(new ConferenceListState.ConferenceInfo(conferenceId));
        if (conferenceInfo == null) {
            return;
        }
        mHadAttendeeData = conferenceInfo.hadScheduledAttendees;
        initData(conferenceInfo);
        mHadAttendeeData.observe(mAttendeeObserver);
    }

    public void removeDetailObserver(Observer<SetConferenceDetailUiState> observer) {
        mConferenceDetailData.removeObserver(observer);
        if (mHadAttendeeData != null) {
            mHadAttendeeData.removeObserver(mAttendeeObserver);
        }
    }

    public void observeStartTime(Observer<SetConferenceDetailUiState> observer) {
        mConferenceDetailData.observe(observer);
    }

    public void removeStartTimeObserve(Observer<SetConferenceDetailUiState> observer) {
        mConferenceDetailData.removeObserver(observer);
    }

    public void observeDuration(Observer<SetConferenceDetailUiState> observer) {
        mConferenceDetailData.observe(observer);
    }

    public void removeDurationObserve(Observer<SetConferenceDetailUiState> observer) {
        mConferenceDetailData.removeObserver(observer);
    }

    public void observeMedia(Observer<SetConferenceDeviceUiState> observer) {
        mConferenceDeviceData.observe(observer);
    }

    public void removeMediaObserver(Observer<SetConferenceDeviceUiState> observer) {
        mConferenceDeviceData.removeObserver(observer);
    }

    public void observeEncrypt(Observer<SetConferenceEncryptViewUiState> observer) {
        mConferenceEncryptData.observe(observer);
    }

    public void removeEncryptObserver(Observer<SetConferenceEncryptViewUiState> observer) {
        mConferenceEncryptData.removeObserver(observer);
    }

    public void updateConferenceName(String conferenceName) {
        SetConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.conferenceName = conferenceName;
    }

    public void updateConferenceType(boolean isSeatEnabled) {
        SetConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.isSeatEnabled = isSeatEnabled;
        mConferenceDetailData.set(uiState);
    }

    public void updateScheduleStartTime(long scheduleStartTime) {
        SetConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.scheduleStartTime = scheduleStartTime;
        mConferenceDetailData.set(uiState);
    }

    public void updateScheduleDuration(int scheduleDuration) {
        SetConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.scheduleDuration = scheduleDuration;
        mConferenceDetailData.set(uiState);
    }

    public void updateScheduleTimeZone(TimeZone timeZone) {
        SetConferenceDetailUiState uiState = mConferenceDetailData.get();
        uiState.timeZone = timeZone;
        mConferenceDetailData.set(uiState);
    }

    public void updateMicrophoneDisableForAllUser(boolean isMicrophoneDisableForAllUser) {
        SetConferenceDeviceUiState uiState = mConferenceDeviceData.get();
        uiState.isMicrophoneDisableForAllUser = isMicrophoneDisableForAllUser;
        mConferenceDeviceData.set(uiState);
    }

    public void updateCameraDisableForAllUsers(boolean isCameraDisableForAllUsers) {
        SetConferenceDeviceUiState uiState = mConferenceDeviceData.get();
        uiState.isCameraDisableForAllUser = isCameraDisableForAllUsers;
        mConferenceDeviceData.set(uiState);
    }

    public void updateEnableEncrypt(boolean isEnableEncrypt) {
        SetConferenceEncryptViewUiState uiState = mConferenceEncryptData.get();
        uiState.isEnableEncrypt = isEnableEncrypt;
        mConferenceEncryptData.set(uiState);
    }

    public void updatePassword(String password) {
        SetConferenceEncryptViewUiState uiState = mConferenceEncryptData.get();
        uiState.password = password;
    }

    private void initData(ConferenceListState.ConferenceInfo conferenceInfo) {
        SetConferenceDetailUiState detailUiState = mConferenceDetailData.get();
        detailUiState.conferenceName = conferenceInfo.basicRoomInfo.name;
        detailUiState.isSeatEnabled = conferenceInfo.basicRoomInfo.isSeatEnabled;
        detailUiState.scheduleStartTime = conferenceInfo.scheduleStartTime;
        detailUiState.scheduleDuration = (int) (conferenceInfo.scheduleEndTime - conferenceInfo.scheduleStartTime);
        mConferenceDetailData.set(detailUiState);

        SetConferenceDeviceUiState deviceUiState = mConferenceDeviceData.get();
        deviceUiState.isCameraDisableForAllUser = conferenceInfo.basicRoomInfo.isCameraDisableForAllUser;
        deviceUiState.isMicrophoneDisableForAllUser = conferenceInfo.basicRoomInfo.isMicrophoneDisableForAllUser;
        mConferenceDeviceData.set(deviceUiState);

        SetConferenceEncryptViewUiState encryptViewUiState = mConferenceEncryptData.get();
        encryptViewUiState.isEnableEncrypt = !TextUtils.isEmpty(conferenceInfo.basicRoomInfo.password);
        encryptViewUiState.password = conferenceInfo.basicRoomInfo.password;
        mConferenceEncryptData.set(encryptViewUiState);
    }
}
