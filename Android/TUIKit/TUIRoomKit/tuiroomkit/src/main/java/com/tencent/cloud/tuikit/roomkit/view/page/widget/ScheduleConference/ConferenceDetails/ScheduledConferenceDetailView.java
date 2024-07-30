package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.ConferenceDetails;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.FAILED;
import static com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager.ConferenceStatus.RUNNING;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
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
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceConstant;
import com.tencent.cloud.tuikit.roomkit.model.controller.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.view.activity.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.view.AttendeesDisplayView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.view.ScheduleInviteMemberView;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;
import java.util.Locale;

public class ScheduledConferenceDetailView extends FrameLayout {
    private static final String               LABEL                  = "Label";
    private static final String               FORMAT_ATTENDEES_COUNT = "%d/300 %s";
    private              Context              mContext;
    private              TextView             mTvModifyRoomInfo;
    private              TextView             mTvRoomName;
    private              TextView             mTvRoomId;
    private              TextView             mTvRoomStartTime;
    private              TextView             mTvRoomDuration;
    private              TextView             mTvConferenceType;
    private              TextView             mTvConferenceHost;
    private              TextView             mTvRoomMembers;
    private              ImageFilterView      mImgFirstUserAvatar;
    private              ImageFilterView      mImgSecondUserAvatar;
    private              ImageFilterView      mImgThirdUserAvatar;
    private              ImageView            mCopyRoomIdImg;
    private              ImageView            mReturnArrowsImg;
    private              ImageView            mAttendeeArrowsImg;
    private              ConstraintLayout     mLayoutAttendee;
    private              AttendeesDisplayView mAttendeesDisplayView;
    private              ConstraintLayout     mLayoutEnterRoom;
    private              ConstraintLayout     mLayoutInviteMembers;
    private              ConstraintLayout     mLayoutCancelRoom;
    private              String               mRoomId;

    private final ScheduledConferenceDetailStateHolder       mStateHolder = new ScheduledConferenceDetailStateHolder();
    private final Observer<ScheduledConferenceDetailUiState> mObserver    = this::updateView;

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
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }

    private void updateView(ScheduledConferenceDetailUiState uiState) {
        if (uiState.conferenceStatus == RUNNING || !TextUtils.equals(uiState.conferenceOwnerId, TUILogin.getUserId())) {
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
            copyContentToClipboard();
        } else if (view.getId() == R.id.cl_enter_scheduled_room) {
            enterConference();
        } else if (view.getId() == R.id.cl_invite_members) {
            ScheduleInviteMemberView inviteMemberView = new ScheduleInviteMemberView(mContext, mTvRoomId.getText().toString(), "");
            inviteMemberView.setTitleText(mContext.getString(R.string.tuiroomkit_scheduled_invite_members));
            inviteMemberView.show();
        } else if (view.getId() == R.id.cl_cancel_room) {
            cancelScheduledConference();
        } else if (view.getId() == R.id.img_arrows_return) {
            finishActivity();
        } else if (view.getId() == R.id.ll_members_of_conference) {
            mAttendeesDisplayView.show();
        }
    }

    private void enterConference() {
        Intent intent = new Intent(mContext, ConferenceMainActivity.class);
        intent.putExtra("id", mRoomId);
        intent.putExtra("muteMicrophone", false);
        intent.putExtra("openCamera", false);
        intent.putExtra("soundOnSpeaker", true);
        intent.putExtra("isCreate", false);
        mContext.startActivity(intent);
        finishActivity();
    }

    private void copyContentToClipboard() {
        ClipboardManager cm = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData mClipData = ClipData.newPlainText(LABEL, mRoomId);
        cm.setPrimaryClip(mClipData);
        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_copy_room_id_success));
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
