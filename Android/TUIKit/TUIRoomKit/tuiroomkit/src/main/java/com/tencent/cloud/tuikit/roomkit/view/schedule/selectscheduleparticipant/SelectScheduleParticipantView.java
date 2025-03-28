package com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleConferenceStateHolder;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.ArrayList;
import java.util.List;

public class SelectScheduleParticipantView extends FrameLayout implements ParticipantSelector.ParticipantSelectCallback {

    private LinearLayout    mLayoutSelectAttendee;
    private TextView        mTvAttendeeCount;
    private ImageFilterView mIvFirstAttendee;
    private ImageFilterView mIvSecondAttendee;
    private ImageFilterView mIvThirdAttendee;

    private final Context             mContext;
    private final ParticipantSelector mParticipantSelector = new ParticipantSelector();

    private ScheduleConferenceStateHolder mStateHolder;

    private final LiveListObserver<UserState.UserInfo> mObserver = new LiveListObserver<UserState.UserInfo>() {
        public void onDataChanged(List<UserState.UserInfo> list) {
            updateView();
        }

        public void onItemInserted(int position, UserState.UserInfo item) {
            updateView();
        }

        public void onItemRemoved(int position, UserState.UserInfo item) {
            updateView();
        }
    };

    public SelectScheduleParticipantView(@NonNull Context context) {
        this(context, null);
    }

    public SelectScheduleParticipantView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        initView(context);
    }

    public void setStateHolder(ScheduleConferenceStateHolder stateHolder) {
        mStateHolder = stateHolder;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.mAttendeeData.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.mAttendeeData.removeObserver(mObserver);
    }

    private void initView(@NonNull Context context) {
        View parent = inflate(context, R.layout.tuiroomkit_view_select_schedule_participant, this);
        mLayoutSelectAttendee = parent.findViewById(R.id.tuiroomkit_ll_select_attendees);
        mTvAttendeeCount = parent.findViewById(R.id.tuiroomkit_tv_attendee_count);
        mIvFirstAttendee = parent.findViewById(R.id.tuiroomkit_iv_first_attendee);
        mIvSecondAttendee = parent.findViewById(R.id.tuiroomkit_iv_second_attendee);
        mIvThirdAttendee = parent.findViewById(R.id.tuiroomkit_iv_third_attendee);

        mLayoutSelectAttendee.setOnClickListener(v -> {
            mParticipantSelector.startParticipantSelect(mContext, getAttendees(), SelectScheduleParticipantView.this);
            MetricsStats.submit(MetricsStats.T_METRICS_CONFERENCE_ATTENDEE);
        });
    }

    public ConferenceParticipants getAttendees() {
        ConferenceParticipants participants = new ConferenceParticipants();
        if (mStateHolder == null || mStateHolder.mAttendeeData.isEmpty()) {
            return participants;
        }
        for (UserState.UserInfo userInfo : mStateHolder.mAttendeeData.getList()) {
            ConferenceDefine.User user = new ConferenceDefine.User();
            user.id = userInfo.userId;
            user.name = userInfo.userName;
            user.avatarUrl = userInfo.avatarUrl;
            participants.selectedList.add(user);
        }
        return participants;
    }

    @Override
    public void onParticipantSelected(List<UserState.UserInfo> participants) {
        mStateHolder.mAttendeeData.replaceAll(new ArrayList<>(participants));
    }

    public void updateView() {
        List<UserState.UserInfo> participants = mStateHolder.mAttendeeData.getList();
        int size = participants.size();
        String attendeesText = size == 0 ? mContext.getString(R.string.tuiroomkit_add) : mContext.getString(R.string.tuiroomkit_format_add_attendee, size);
        mTvAttendeeCount.setText(attendeesText);
        mIvFirstAttendee.setVisibility(size > 0 ? VISIBLE : GONE);
        mIvSecondAttendee.setVisibility(size > 1 ? VISIBLE : GONE);
        mIvThirdAttendee.setVisibility(size > 2 ? VISIBLE : GONE);
        if (size > 0) {
            ImageLoader.loadImage(mContext, mIvFirstAttendee, participants.get(0).avatarUrl, R.drawable.tuivideoseat_head);
        }
        if (size > 1) {
            ImageLoader.loadImage(mContext, mIvSecondAttendee, participants.get(1).avatarUrl, R.drawable.tuivideoseat_head);
        }
        if (size > 2) {
            ImageLoader.loadImage(mContext, mIvThirdAttendee, participants.get(2).avatarUrl, R.drawable.tuivideoseat_head);
        }
    }
}
