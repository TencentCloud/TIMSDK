package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencedetails;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.FAILED;
import static com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager.ConferenceStatus.RUNNING;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_ID;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_NAME;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_TIME;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView.KEY_INVITE_ROOM_TYPE;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.CommonUtils;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.AttendeesDisplayView;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ScheduledConferenceDetailView extends FrameLayout {
    private static final String FORMAT_ATTENDEES_COUNT = "%d/300 %s";

    private Context                  mContext;
    private TextView                 mTvModifyRoomInfo;
    private TextView                 mTvRoomName;
    private TextView                 mTvRoomId;
    private TextView                 mTvRoomStartTime;
    private TextView                 mTvRoomDuration;
    private TextView                 mTvConferenceType;
    private TextView                 mTvConferenceHost;
    private TextView                 mTvRoomMembers;
    private TextView                 mTvPassword;
    private TextView                 mTvPasswordTitle;
    private ImageFilterView          mImgFirstUserAvatar;
    private ImageFilterView          mImgSecondUserAvatar;
    private ImageFilterView          mImgThirdUserAvatar;
    private ImageView                mCopyRoomIdImg;
    private ImageView                mReturnArrowsImg;
    private ImageView                mAttendeeArrowsImg;
    private ConstraintLayout         mLayoutAttendee;
    private AttendeesDisplayView     mAttendeesDisplayView;
    private ConstraintLayout         mLayoutEnterRoom;
    private ConstraintLayout         mLayoutInviteMembers;
    private ConstraintLayout         mLayoutCancelRoom;
    private String                   mRoomId;
    private ScheduleInviteMemberView mInviteMemberView;

    private final ScheduledConferenceDetailStateHolder       mStateHolder                = new ScheduledConferenceDetailStateHolder();
    private final Observer<ScheduledConferenceDetailUiState> mObserver                   = this::updateView;
    private final Observer<Boolean>                          mConferenceCanceledObserver = this::dismissView;

    public ScheduledConferenceDetailView(Context context, String roomId) {
        super(context);
        mContext = context;
        mRoomId = roomId;
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observer(mObserver, mRoomId);
        mStateHolder.mConferenceCanceled.observe(mConferenceCanceledObserver);
        MetricsStats.submit(MetricsStats.T_METRICS_CONFERENCE_INFO_PANEL_SHOW);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
        mStateHolder.mConferenceCanceled.removeObserver(mConferenceCanceledObserver);
    }

    private void updateView(ScheduledConferenceDetailUiState uiState) {
        boolean isMyConference = TextUtils.equals(uiState.conferenceOwnerId, TUILogin.getUserId());
        if (uiState.conferenceStatus == RUNNING || !isMyConference) {
            mTvModifyRoomInfo.setVisibility(GONE);
            mLayoutCancelRoom.setVisibility(GONE);
        } else {
            mTvModifyRoomInfo.setVisibility(VISIBLE);
            mLayoutCancelRoom.setVisibility(VISIBLE);
        }
        mTvRoomName.setText(uiState.conferenceName);
        mTvRoomId.setText(uiState.conferenceId);
        mTvRoomStartTime.setText(uiState.scheduledStartTime);
        mTvRoomDuration.setText(uiState.scheduledDuration);
        mTvConferenceType.setText(uiState.conferenceType);
        mTvConferenceHost.setText(uiState.conferenceOwner);
        initRoomPasswordView(uiState.conferenceId);
        List<UserState.UserInfo> attendeeList = uiState.attendees;
        updateUserAvatar(attendeeList);
        int attendeesCount = attendeeList.size();
        String attendeeDisplayUnit;
        if (attendeesCount == 0) {
            mLayoutAttendee.setClickable(false);
            attendeeDisplayUnit = mContext.getString(R.string.tuiroomkit_no_participants_yet);
            mAttendeeArrowsImg.setVisibility(GONE);
        } else {
            mLayoutAttendee.setClickable(true);
            attendeeDisplayUnit = String.format(Locale.getDefault(), FORMAT_ATTENDEES_COUNT, attendeesCount, mContext.getString(R.string.tuiroomkit_attendees_avatar_display_unit));
            mAttendeeArrowsImg.setVisibility(VISIBLE);
        }
        mTvRoomMembers.setText(attendeeDisplayUnit);
        mAttendeesDisplayView.setAttendees(uiState.attendees);

        Map<String, Object> roomInfo = new HashMap<>();
        roomInfo.put(KEY_INVITE_ROOM_NAME, mTvRoomName.getText().toString());
        roomInfo.put(KEY_INVITE_ROOM_TYPE, mTvConferenceType.getText().toString());
        roomInfo.put(KEY_INVITE_ROOM_TIME, uiState.conferenceTime);
        roomInfo.put(KEY_INVITE_ROOM_ID, mTvRoomId.getText().toString());
        mInviteMemberView = new ScheduleInviteMemberView(mContext, roomInfo);
    }

    private void dismissView(boolean dismiss) {
        if (dismiss) {
            RoomToast.toastLongMessageCenter(mContext.getString(R.string.tuiroomkit_conference_canceled));
            finishActivity();
        }
    }


    private void initRoomPasswordView(String roomId) {
        ScheduleController.sharedInstance().fetchRoomInfo(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                updatePassword(roomInfo.password);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                updatePassword("");
            }
        });
    }

    private void updatePassword(String password) {
        boolean isEnablePassword = (!TextUtils.isEmpty(password));
        mTvPasswordTitle.setVisibility(isEnablePassword ? VISIBLE : GONE);
        mTvPassword.setVisibility(isEnablePassword ? VISIBLE : GONE);
        mTvPassword.setText(isEnablePassword ? password : "");
    }

    private void updateUserAvatar(List<UserState.UserInfo> attendeeList) {
        int size = attendeeList.size();
        switch (size) {
            case 0:
                mImgFirstUserAvatar.setVisibility(GONE);
                mImgSecondUserAvatar.setVisibility(GONE);
                mImgThirdUserAvatar.setVisibility(GONE);
                return;
            case 1:
                mImgFirstUserAvatar.setVisibility(VISIBLE);
                ImageLoader.loadImage(mContext, mImgFirstUserAvatar, attendeeList.get(0).avatarUrl, R.drawable.tuiroomkit_ic_avatar);
                mImgSecondUserAvatar.setVisibility(GONE);
                mImgThirdUserAvatar.setVisibility(GONE);
                return;
            case 2:
                mImgFirstUserAvatar.setVisibility(VISIBLE);
                ImageLoader.loadImage(mContext, mImgFirstUserAvatar, attendeeList.get(0).avatarUrl, R.drawable.tuiroomkit_ic_avatar);
                mImgSecondUserAvatar.setVisibility(VISIBLE);
                ImageLoader.loadImage(mContext, mImgSecondUserAvatar, attendeeList.get(1).avatarUrl, R.drawable.tuiroomkit_ic_avatar);
                mImgThirdUserAvatar.setVisibility(GONE);
                return;
            default:
                mImgFirstUserAvatar.setVisibility(VISIBLE);
                ImageLoader.loadImage(mContext, mImgFirstUserAvatar, attendeeList.get(0).avatarUrl, R.drawable.tuiroomkit_ic_avatar);
                mImgSecondUserAvatar.setVisibility(VISIBLE);
                ImageLoader.loadImage(mContext, mImgSecondUserAvatar, attendeeList.get(1).avatarUrl, R.drawable.tuiroomkit_ic_avatar);
                mImgThirdUserAvatar.setVisibility(VISIBLE);
                ImageLoader.loadImage(mContext, mImgThirdUserAvatar, attendeeList.get(2).avatarUrl, R.drawable.tuiroomkit_ic_avatar);
        }
    }

    private void initView() {
        inflate(mContext, R.layout.tuiroomkit_view_schduled_conference_detail, this);
        mTvRoomName = findViewById(R.id.tv_scheduled_room_name);
        mTvRoomId = findViewById(R.id.tv_scheduled_room_id);
        mTvRoomStartTime = findViewById(R.id.tv_scheduled_start_time);
        mTvRoomDuration = findViewById(R.id.tv_scheduled_room_duration);
        mTvConferenceType = findViewById(R.id.tv_scheduled_room_type);
        mTvConferenceHost = findViewById(R.id.tv_room_initiator);
        mTvRoomMembers = findViewById(R.id.tv_members_count);
        mTvPassword = findViewById(R.id.tv_scheduled_room_password);
        mTvPasswordTitle = findViewById(R.id.tv_scheduled_room_password_title);

        mTvModifyRoomInfo = findViewById(R.id.tv_modify_room_info);
        mCopyRoomIdImg = findViewById(R.id.img_copy_room_id_icon);
        mReturnArrowsImg = findViewById(R.id.img_arrows_return);
        mLayoutEnterRoom = findViewById(R.id.cl_enter_scheduled_room);
        mLayoutInviteMembers = findViewById(R.id.cl_invite_members);
        mLayoutCancelRoom = findViewById(R.id.cl_cancel_room);
        mLayoutAttendee = findViewById(R.id.ll_members_of_conference);
        mAttendeeArrowsImg = findViewById(R.id.img_arrows_right);
        mAttendeesDisplayView = new AttendeesDisplayView(mContext);

        mImgFirstUserAvatar = findViewById(R.id.img_first_attendee_avatar);
        mImgSecondUserAvatar = findViewById(R.id.img_second_attendee_avatar);
        mImgThirdUserAvatar = findViewById(R.id.img_third_attendee_avatar);

        mTvModifyRoomInfo.setOnClickListener(this::onClick);
        mCopyRoomIdImg.setOnClickListener(this::onClick);
        mLayoutEnterRoom.setOnClickListener(this::onClick);
        mLayoutInviteMembers.setOnClickListener(this::onClick);
        mLayoutCancelRoom.setOnClickListener(this::onClick);
        mReturnArrowsImg.setOnClickListener(this::onClick);
        mLayoutAttendee.setOnClickListener(this::onClick);
    }

    public void onClick(View view) {
        if (view.getId() == R.id.tv_modify_room_info) {
            Bundle param = new Bundle();
            param.putString(ConferenceConstant.KEY_CONFERENCE_ID, mRoomId);
            TUICore.startActivity("ModifyConferenceActivity", param);
        } else if (view.getId() == R.id.img_copy_room_id_icon) {
            CommonUtils.copyToClipboard(mRoomId, mContext.getString(R.string.tuiroomkit_copy_room_id_success));
        } else if (view.getId() == R.id.cl_enter_scheduled_room) {
            enterConference();
        } else if (view.getId() == R.id.cl_invite_members) {
            showInviteMemberView();
        } else if (view.getId() == R.id.cl_cancel_room) {
            cancelScheduledConference();
        } else if (view.getId() == R.id.img_arrows_return) {
            finishActivity();
        } else if (view.getId() == R.id.ll_members_of_conference) {
            mAttendeesDisplayView.show();
        }
    }

    private void showInviteMemberView() {
        ScheduleController.sharedInstance().fetchRoomInfo(mTvRoomId.getText().toString(), new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                if (mInviteMemberView != null) {
                    mInviteMemberView.setTitleText(mContext.getString(R.string.tuiroomkit_scheduled_invite_members));
                    mInviteMemberView.show();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
            }
        });
    }

    private void enterConference() {
        ConferenceDefine.JoinConferenceParams params = new ConferenceDefine.JoinConferenceParams(mRoomId);
        params.isOpenMicrophone = true;
        params.isOpenCamera = false;
        params.isOpenSpeaker = true;
        Intent intent = new Intent(mContext, ConferenceMainActivity.class);
        intent.putExtra(KEY_JOIN_CONFERENCE_PARAMS, params);
        mContext.startActivity(intent);
        finishActivity();
    }

    private void finishActivity() {
        if (!(mContext instanceof Activity)) {
            return;
        }
        Activity activity = (Activity) mContext;
        activity.finish();
    }

    private void cancelScheduledConference() {
        int positiveButtonTextColor = ContextCompat.getColor(mContext, R.color.tuiroomkit_color_dialog_cancel_scheduled_room);
        TUIRoomDefine.ActionCallback cancelCallback = new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                finishActivity();
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                if (error == FAILED) {
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_conference_already_started_and_cannot_be_cancel));
                    finishActivity();
                }
            }
        };
        BaseDialogFragment.build().setTitle(mContext.getString(R.string.tuiroomkit_scheduled_hint_cancel_room_title)).setContent(mContext.getString(R.string.tuiroomkit_scheduled_hint_cancel_message)).setNegativeName(mContext.getString(R.string.tuiroomkit_scheduled_hint_not_cancel)).setPositiveName(mContext.getString(R.string.tuiroomkit_scheduled_hint_cancel_room)).setPositiveButtonColor(positiveButtonTextColor).setPositiveListener(() -> ScheduleController.sharedInstance().cancelConference(mRoomId, cancelCallback)).showDialog(mContext, null);
    }
}
