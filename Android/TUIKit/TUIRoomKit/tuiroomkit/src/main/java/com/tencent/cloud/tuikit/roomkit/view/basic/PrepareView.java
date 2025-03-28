package com.tencent.cloud.tuikit.roomkit.view.basic;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.SCHEDULED_CONFERENCE_SUCCESS;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.ConferenceListFragment;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.ScheduleConferenceActivity;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleInviteMemberView;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class PrepareView extends RelativeLayout implements View.OnClickListener,
        ConferenceEventCenter.RoomKitUIEventResponder {

    private Context          mContext;
    private TextView         mTextUserName;
    private ImageView        mImageBack;
    private CircleImageView  mImageHead;
    private LinearLayout     mLayoutEnterRoom;
    private LinearLayout     mLayoutCreateRoom;
    private LinearLayout     mLayoutScheduleRoom;
    private ConstraintLayout mLayoutRoot;
    private ConstraintSet    mPreSet;

    public PrepareView(Context context, boolean enablePreview) {
        super(context);
        mContext = context;
        subscribeEvent();
        initView();
        updatePreviewLayout(enablePreview);
    }

    private void subscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeUIEvent(SCHEDULED_CONFERENCE_SUCCESS, this);
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeUIEvent(SCHEDULED_CONFERENCE_SUCCESS, this);
    }

    private void initView() {
        View.inflate(mContext, R.layout.tuiroomkit_view_prepare, this);

        mLayoutRoot = findViewById(R.id.cl_root_prepare);
        mImageHead = findViewById(R.id.img_head_prepare);
        mTextUserName = findViewById(R.id.tv_name_prepare);
        mImageBack = findViewById(R.id.img_back);
        mLayoutEnterRoom = findViewById(R.id.ll_enter_room);
        mLayoutCreateRoom = findViewById(R.id.ll_create_room);
        mLayoutScheduleRoom = findViewById(R.id.ll_schedule_conference);

        mImageBack.setOnClickListener(this);
        mImageHead.setOnClickListener(this);
        mLayoutEnterRoom.setOnClickListener(this);
        mLayoutCreateRoom.setOnClickListener(this);
        mLayoutScheduleRoom.setOnClickListener(this);

        TUIRoomDefine.LoginUserInfo userInfo = TUIRoomEngine.getSelfInfo();
        ImageLoader.loadImage(mContext, mImageHead, userInfo.avatarUrl,
                R.drawable.tuiroomkit_ic_avatar);
        mTextUserName.setText(userInfo.userName);

        mPreSet = new ConstraintSet();
        mPreSet.clone(mLayoutRoot);

        if (mContext instanceof AppCompatActivity) {
            AppCompatActivity activity = (AppCompatActivity) mContext;
            ConferenceListFragment fragment = new ConferenceListFragment();
            FragmentTransaction transaction = activity.getSupportFragmentManager().beginTransaction();
            transaction.add(R.id.tuiroomkit_fl_conference_list_container, fragment);
            transaction.commitAllowingStateLoss();
        }
    }

    private void updatePreviewLayout(boolean enableVideoPreview) {
        if (enableVideoPreview) {
            mPreSet.applyTo(mLayoutRoot);
        } else {
            ConstraintSet set = new ConstraintSet();
            set.clone(mLayoutRoot);
            set.clear(mLayoutCreateRoom.getId());
            set.clear(mLayoutEnterRoom.getId());

            set.centerHorizontally(mLayoutCreateRoom.getId(), ConstraintSet.PARENT_ID);
            set.constrainHeight(mLayoutCreateRoom.getId(), ConstraintSet.WRAP_CONTENT);
            set.constrainPercentWidth(mLayoutCreateRoom.getId(), 0.5f);
            set.connect(mLayoutCreateRoom.getId(), ConstraintSet.BOTTOM, mLayoutRoot.getId(),
                    ConstraintSet.BOTTOM,
                    getResources().getDimensionPixelSize(R.dimen.tuiroomkit_create_room_margin_bottom));
            set.connect(mLayoutCreateRoom.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mLayoutCreateRoom.getId(), ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END);

            set.connect(mLayoutEnterRoom.getId(), ConstraintSet.BOTTOM, mLayoutCreateRoom.getId(), ConstraintSet.TOP,
                    getResources().getDimensionPixelSize(R.dimen.tuiroomkit_enter_room_margin_bottom));
            set.connect(mLayoutEnterRoom.getId(), ConstraintSet.LEFT, mLayoutCreateRoom.getId(), ConstraintSet.LEFT);
            set.connect(mLayoutEnterRoom.getId(), ConstraintSet.RIGHT, mLayoutCreateRoom.getId(), ConstraintSet.RIGHT);
            set.constrainWidth(mLayoutEnterRoom.getId(), ConstraintSet.MATCH_CONSTRAINT);
            set.constrainHeight(mLayoutEnterRoom.getId(), ConstraintSet.WRAP_CONTENT);
            set.setVerticalBias(mLayoutEnterRoom.getId(), 100f);

            set.applyTo(mLayoutRoot);
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.img_back) {
            finishActivity();
        } else if (v.getId() == R.id.ll_enter_room) {
            enterRoom();
        } else if (v.getId() == R.id.ll_create_room) {
            createRoom();
        } else if (v.getId() == R.id.ll_schedule_conference) {
            Intent intent = new Intent(this.getContext(), ScheduleConferenceActivity.class);
            this.getContext().startActivity(intent);
        }
    }

    private void finishActivity() {
        if (!(mContext instanceof Activity)) {
            return;
        }
        Activity activity = (Activity) mContext;
        activity.finish();
    }

    private void createRoom() {
        TUICore.startActivity("CreateConferenceActivity", null);
    }

    private void enterRoom() {
        TUICore.startActivity("EnterConferenceActivity", null);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        unSubscribeEvent();
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (TextUtils.equals(key, SCHEDULED_CONFERENCE_SUCCESS) && params != null) {
            ScheduleInviteMemberView scheduleSuccessView = new ScheduleInviteMemberView(mContext, params);
            scheduleSuccessView.show();
        }
    }

}
