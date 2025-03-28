package com.tencent.cloud.tuikit.roomkit.view.schedule.modifyconference;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.FAILED;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.PERMISSION_DENIED;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceListState;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleConferenceStateHolder;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.SetConferenceDetailUiState;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.SetConferenceDetailView;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.SetConferenceDeviceView;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.SetConferenceEncryptView;

import java.nio.charset.StandardCharsets;

public class ModifyConferenceView extends FrameLayout {
    private Context                  mContext;
    private FrameLayout              mLayoutSetConferenceDetail;
    private FrameLayout              mLayoutSetConferenceEncrypt;
    private FrameLayout              mLayoutSetConferenceDevice;
    private LinearLayout             mLayoutModifyConference;
    private LinearLayout             mLayoutClose;
    private SetConferenceDetailView  mConferenceDetailView;
    private SetConferenceEncryptView mConferenceEncryptView;
    private SetConferenceDeviceView  mConferenceDeviceView;
    private TextView                 mTvSaveConference;

    private String mConferenceId;

    private final ScheduleConferenceStateHolder mStateHolder = new ScheduleConferenceStateHolder();

    public ModifyConferenceView(Context context) {
        this(context, null);
    }

    public ModifyConferenceView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        initView();
    }

    public void setConferenceId(String conferenceId) {
        mConferenceId = conferenceId;
        mConferenceDetailView.setConferenceId(mConferenceId);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        MetricsStats.submit(MetricsStats.T_METRICS_CONFERENCE_MODIFY_PANEL_SHOW);
    }

    private void initView() {
        View parent = inflate(mContext, R.layout.tuiroomkit_view_schedule_conference, this);
        mLayoutClose = parent.findViewById(R.id.ll_return);
        mLayoutClose.setOnClickListener(view -> finishActivity());
        mLayoutSetConferenceDetail = parent.findViewById(R.id.fl_set_scheduled_conference_info);
        mLayoutSetConferenceEncrypt = parent.findViewById(R.id.fl_set_conference_password);
        mLayoutSetConferenceEncrypt.setVisibility(GONE);
        mLayoutSetConferenceDevice = parent.findViewById(R.id.fl_set_conference_device);
        mTvSaveConference = parent.findViewById(R.id.tv_save_conference_text);
        mTvSaveConference.setText(mContext.getString(R.string.tuiroomkit_save_conference));
        mLayoutModifyConference = parent.findViewById(R.id.tuiroomkit_ll_conference_edit_confirm);
        mLayoutModifyConference.setOnClickListener(v -> modifyConference(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_conference_modify_success));
                finishActivity();
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                if (error == PERMISSION_DENIED) {
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_conference_already_started_and_cannot_be_modified));
                }
                mLayoutModifyConference.setClickable(true);
                finishActivity();
            }
        }));
        TextView view = parent.findViewById(R.id.tv_conference_info);
        view.setText(R.string.tuiroomkit_amend_conference_text);

        mConferenceDetailView = new SetConferenceDetailView(mContext);
        mConferenceEncryptView = new SetConferenceEncryptView(mContext);
        mConferenceDeviceView = new SetConferenceDeviceView(mContext);
        mConferenceDeviceView.setVisibility(GONE);
        mConferenceDetailView.disableSetConferenceType();
        mConferenceEncryptView.disableSetEncrypt();
        mConferenceDeviceView.disableSetDevice();
        mConferenceDetailView.setStateHolder(mStateHolder);
        mConferenceEncryptView.setStateHolder(mStateHolder);
        mConferenceDeviceView.setStateHolder(mStateHolder);
        mLayoutSetConferenceDetail.addView(mConferenceDetailView);
        mLayoutSetConferenceEncrypt.addView(mConferenceEncryptView);
        mLayoutSetConferenceDevice.addView(mConferenceDeviceView);
    }

    private void finishActivity() {
        if (!(mContext instanceof Activity)) {
            return;
        }
        Activity activity = (Activity) mContext;
        activity.finish();
    }

    private void modifyConference(TUIRoomDefine.ActionCallback callback) {
        mLayoutModifyConference.setClickable(false);
        ConferenceListState.ConferenceInfo conferenceInfo = new ConferenceListState.ConferenceInfo(mConferenceId);
        SetConferenceDetailUiState conferenceDetailUiState = mStateHolder.mConferenceDetailData.get();
        conferenceInfo.basicRoomInfo.name = conferenceDetailUiState.conferenceName;
        conferenceInfo.scheduleStartTime = conferenceDetailUiState.scheduleStartTime;
        conferenceInfo.scheduleEndTime = conferenceDetailUiState.scheduleStartTime + conferenceDetailUiState.scheduleDuration;
        conferenceInfo.hadScheduledAttendees.redirect(mStateHolder.mAttendeeData.getList());
        String conferenceName = conferenceInfo.basicRoomInfo.name;
        if (TextUtils.isEmpty(conferenceName)) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_conference_name_empty));
            callback.onError(FAILED, null);
            return;
        }
        if (conferenceName.getBytes(StandardCharsets.UTF_8).length > 100) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_conference_name_exceeds_max_length));
            callback.onError(FAILED, null);
            return;
        }
        if (conferenceInfo.status == TUIConferenceListManager.ConferenceStatus.RUNNING) {
            callback.onError(PERMISSION_DENIED, null);
            return;
        }
        ScheduleController.sharedInstance().updateConferenceInfo(conferenceInfo, callback);
    }
}
