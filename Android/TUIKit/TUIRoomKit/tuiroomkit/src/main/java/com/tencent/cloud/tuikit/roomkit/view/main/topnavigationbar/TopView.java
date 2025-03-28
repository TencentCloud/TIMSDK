package com.tencent.cloud.tuikit.roomkit.view.main.topnavigationbar;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.BAR_SHOW_TIME_RECOUNT;

import android.content.Context;
import android.view.View;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.main.roominfo.RoomInfoDialog;

public class TopView extends FrameLayout implements View.OnClickListener {
    private Context        mContext;
    private LinearLayout   mButtonExit;
    private RelativeLayout mLayoutMeetingInfo;

    public TopView(Context context) {
        super(context);
        mContext = context;
        initView(this);
    }

    private void initView(final View itemView) {
        inflate(mContext, R.layout.tuiroomkit_view_top, this);
        mLayoutMeetingInfo = findViewById(R.id.rl_meeting_info);
        mLayoutMeetingInfo.setOnClickListener(this);
        mButtonExit = itemView.findViewById(R.id.btn_exit_room);
        mButtonExit.setOnClickListener(this);
    }

    @Override
    public void setVisibility(int visibility) {
        int animResId = visibility == VISIBLE
                ? R.anim.tuiroomkit_anim_top_view_show
                : R.anim.tuiroomkit_anim_top_view_dismiss;
        startAnimation(AnimationUtils.loadAnimation(getContext(), animResId));
        super.setVisibility(visibility);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.rl_meeting_info) {
            RoomInfoDialog roomInfoView = new RoomInfoDialog(mContext);
            roomInfoView.show();
        } else if (v.getId() == R.id.btn_exit_room) {
            ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
        }
        ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
    }
}
