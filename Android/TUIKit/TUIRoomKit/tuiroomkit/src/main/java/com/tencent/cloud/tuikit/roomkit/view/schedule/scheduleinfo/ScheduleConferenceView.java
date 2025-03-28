package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_ID;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_NAME;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_TIME;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_TYPE;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.common.utils.FetchRoomId;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceListState;
import com.tencent.qcloud.tuicore.TUILogin;

import java.nio.charset.StandardCharsets;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class ScheduleConferenceView extends FrameLayout {
    private static final int PASSWORD_LENGTH = 6;
    private static final int REMINDER_TIME   = 600;

    private Context                  mContext;
    private FrameLayout              mLayoutSetConferenceDetail;
    private FrameLayout              mLayoutSetConferenceEncrypt;
    private FrameLayout              mLayoutSetConferenceDevice;
    private LinearLayout             mLayoutStartScheduleConference;
    private LinearLayout             mLayoutClose;
    private SetConferenceDetailView  mConferenceDetailView;
    private SetConferenceEncryptView mConferenceEncryptView;
    private SetConferenceDeviceView  mConferenceDeviceView;
    private String                   mConferenceId = "";

    private final ScheduleConferenceStateHolder mStateHolder = new ScheduleConferenceStateHolder();

    public ScheduleConferenceView(Context context) {
        this(context, null);
    }

    public ScheduleConferenceView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        mConferenceDetailView = new SetConferenceDetailView(mContext);
        mConferenceEncryptView = new SetConferenceEncryptView(mContext);
        mConferenceDeviceView = new SetConferenceDeviceView(mContext);
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ScheduleController.sharedInstance().loginEngine(null);
        MetricsStats.submit(MetricsStats.T_METRICS_CONFERENCE_SCHEDULE_PANEL_SHOW);
    }

    private void initView() {
        addView(LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_schedule_conference, this, false));
        mLayoutClose = findViewById(R.id.ll_return);
        mLayoutClose.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) mContext).finish();
            }
        });
        mLayoutSetConferenceDetail = findViewById(R.id.fl_set_scheduled_conference_info);
        mLayoutSetConferenceEncrypt = findViewById(R.id.fl_set_conference_password);
        mLayoutSetConferenceDevice = findViewById(R.id.fl_set_conference_device);
        mLayoutStartScheduleConference = findViewById(R.id.tuiroomkit_ll_conference_edit_confirm);
        mLayoutStartScheduleConference.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutStartScheduleConference.setClickable(false);
                scheduleConference(new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        SetConferenceDetailUiState conferenceDetailUiState = mStateHolder.mConferenceDetailData.get();
                        Map<String, Object> roomInfo = new HashMap<>();
                        roomInfo.put(KEY_INVITE_ROOM_ID, mConferenceId);
                        roomInfo.put(KEY_INVITE_ROOM_TYPE, conferenceDetailUiState.isSeatEnabled ? mContext.getString(R.string.tuiroomkit_room_raise_hand) : mContext.getString(R.string.tuiroomkit_room_free_speech));
                        roomInfo.put(KEY_INVITE_ROOM_TIME, getRoomTimeString(conferenceDetailUiState.scheduleStartTime, conferenceDetailUiState.scheduleStartTime + conferenceDetailUiState.scheduleDuration));
                        roomInfo.put(KEY_INVITE_ROOM_NAME, conferenceDetailUiState.conferenceName);
                        ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SCHEDULED_CONFERENCE_SUCCESS, roomInfo);
                        ((Activity) mContext).finish();
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        mLayoutStartScheduleConference.setClickable(true);
                    }
                });
            }
        });
        mConferenceDetailView.setStateHolder(mStateHolder);
        mConferenceEncryptView.setStateHolder(mStateHolder);
        mConferenceDeviceView.setStateHolder(mStateHolder);
        mLayoutSetConferenceDetail.addView(mConferenceDetailView);
        mLayoutSetConferenceEncrypt.addView(mConferenceEncryptView);
        mLayoutSetConferenceDevice.addView(mConferenceDeviceView);
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
        String startTimeString = String.format(Locale.getDefault(), mContext.getString(R.string.tuiroomkit_format_conference_start_time), startYear, yearUnit, startMonth, monthUnit, startDay, dayUnit, startHour, startMinute);
        if (startYear == endYear && startMonth == endMonth && startDay == endDay) {
            return String.format(Locale.getDefault(), context.getString(R.string.tuiroomkit_format_conference_time), startTimeString, endHour, endMinute);
        }
        return String.format(Locale.getDefault(), context.getString(R.string.tuiroomkit_format_conference_next_day_time), startTimeString, endHour, endMinute);
    }

    private void scheduleConference(TUIRoomDefine.ActionCallback callback) {
        FetchRoomId.fetch(new FetchRoomId.GetRoomIdCallback() {
            @Override
            public void onGetRoomId(String roomId) {
                mConferenceId = roomId;
                ConferenceListState.ConferenceInfo conferenceInfo = new ConferenceListState.ConferenceInfo(roomId);

                SetConferenceDetailUiState conferenceDetailUiState = mStateHolder.mConferenceDetailData.get();
                conferenceInfo.basicRoomInfo.name = conferenceDetailUiState.conferenceName;
                conferenceInfo.basicRoomInfo.isSeatEnabled = conferenceDetailUiState.isSeatEnabled;
                conferenceInfo.scheduleStartTime = conferenceDetailUiState.scheduleStartTime;
                conferenceInfo.scheduleEndTime = conferenceDetailUiState.scheduleStartTime + conferenceDetailUiState.scheduleDuration;
                conferenceInfo.scheduleAttendees = mStateHolder.mAttendeeData.getList();

                SetConferenceDeviceUiState conferenceDeviceUiState = mStateHolder.mConferenceDeviceData.get();
                conferenceInfo.basicRoomInfo.isMicrophoneDisableForAllUser = conferenceDeviceUiState.isMicrophoneDisableForAllUser;
                conferenceInfo.basicRoomInfo.isCameraDisableForAllUser = conferenceDeviceUiState.isCameraDisableForAllUser;

                SetConferenceEncryptViewUiState conferenceEncryptViewUiState = mStateHolder.mConferenceEncryptData.get();
                if (conferenceEncryptViewUiState.isEnableEncrypt) {
                    if (conferenceEncryptViewUiState.password.length() != PASSWORD_LENGTH) {
                        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_room_password_format_error));
                        callback.onError(TUICommonDefine.Error.FAILED, mContext.getString(R.string.tuiroomkit_room_password_format_error));
                        return;
                    }
                    conferenceInfo.basicRoomInfo.password = conferenceEncryptViewUiState.password;
                }
                if (conferenceInfo.scheduleStartTime < System.currentTimeMillis()) {
                    RoomToast.toastLongMessageCenter(mContext.getString(R.string.tuiroomkit_start_time_earlier_than_current_time));
                    callback.onError(TUICommonDefine.Error.FAILED, null);
                    return;
                }
                String conferenceName = conferenceInfo.basicRoomInfo.name;
                if (TextUtils.isEmpty(conferenceName)) {
                    RoomToast.toastLongMessageCenter(mContext.getString(R.string.tuiroomkit_conference_name_empty));
                    callback.onError(TUICommonDefine.Error.FAILED, null);
                    return;
                }
                if (conferenceName.getBytes(StandardCharsets.UTF_8).length > 100) {
                    RoomToast.toastLongMessageCenter(mContext.getString(R.string.tuiroomkit_conference_name_exceeds_max_length));
                    callback.onError(TUICommonDefine.Error.FAILED, null);
                    return;
                }
                conferenceInfo.reminderSecondsBeforeStart = REMINDER_TIME;
                ScheduleController.sharedInstance().scheduleConference(conferenceInfo, callback);
            }
        });
    }
}
