package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.view.View;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.viewmodel.TopViewModel;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;

public class TopView extends FrameLayout implements View.OnClickListener {
    private Context         mContext;
    private ImageView       mImgHeadset;
    private ImageView       mImageSwitchCamera;
    private ImageView       mImgReport;
    private LinearLayout    mButtonExit;
    private TextView        mTextTitle;
    private TextView        mTexTime;
    private RelativeLayout  mLayoutMeetingInfo;
    private TopViewModel    mViewModel;

    public TopView(Context context) {
        super(context);
        inflate(context, R.layout.tuiroomkit_view_top, this);
        mContext = context;
        initView(this);
        mViewModel = new TopViewModel(mContext, this);
        mViewModel.startTimeCount();
    }

    private void initView(final View itemView) {
        mImgHeadset = itemView.findViewById(R.id.img_headset);
        mImageSwitchCamera = itemView.findViewById(R.id.img_camera_switch);
        mTextTitle = itemView.findViewById(R.id.tv_title);
        mLayoutMeetingInfo = findViewById(R.id.rl_meeting_info);
        mImgReport = itemView.findViewById(R.id.btn_report);
        mButtonExit = itemView.findViewById(R.id.btn_exit_room);

        mTexTime = itemView.findViewById(R.id.tv_broadcast_time);
        mImgHeadset.setOnClickListener(this);
        mImageSwitchCamera.setOnClickListener(this);
        mLayoutMeetingInfo.setOnClickListener(this);
        mImgReport.setOnClickListener(this);
        mButtonExit.setOnClickListener(this);
    }

    public void showReportView(boolean isShow) {
        mImgReport.setVisibility(isShow ? VISIBLE : GONE);
    }

    public void setTitle(String text) {
        if (mTextTitle != null) {
            mTextTitle.setText(text);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        mViewModel.stopTimeCount();
        super.onDetachedFromWindow();
        mViewModel.destroy();
    }

    @Override
    public void setVisibility(int visibility) {
        int animResId = visibility == VISIBLE
                ? R.anim.tuiroomkit_anim_top_view_show
                : R.anim.tuiroomkit_anim_top_view_dismiss;
        startAnimation(AnimationUtils.loadAnimation(getContext(), animResId));
        super.setVisibility(visibility);
    }

    public void updateTimeCount(int second) {
        mTexTime.setText(DateTimeUtil.formatSecondsTo00(second));
    }

    public void setHeadsetImg(boolean isUseSpeaker) {
        if (mImgHeadset != null) {
            mImgHeadset.setImageResource(isUseSpeaker ? R.drawable.tuiroomkit_ic_speaker :
                    R.drawable.tuiroomkit_ic_headset);
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.img_headset) {
            mViewModel.switchAudioRoute();
        } else if (v.getId() == R.id.img_camera_switch) {
            mViewModel.switchCamera();
        } else if (v.getId() == R.id.rl_meeting_info) {
            mViewModel.showMeetingInfo();
        } else if (v.getId() == R.id.btn_report) {
            mViewModel.report();
        } else if (v.getId() == R.id.btn_exit_room) {
            RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
        }
    }
}
