package com.tencent.cloud.tuikit.roomkit.view.main.floatwindow.videoplaying;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.UserVolumePromptView;

import de.hdodenhof.circleimageview.CircleImageView;

public class RoomVideoFloatView extends FrameLayout {
    private OnTouchListener mTouchListener;

    private Context              mContext;
    private TUIVideoView         mVideoView;
    private ImageFilterView      mUserAvatarIv;
    private CircleImageView      mRoomOwnerView;
    private UserVolumePromptView mUserVolumePromptView;
    private TextView             mUserNameTv;

    private RoomVideoFloatViewModel mFloatViewModel;

    public RoomVideoFloatView(@NonNull Context context) {
        super(context);
        mContext = context;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();

        LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_room_video_float_layout, this);
        mVideoView = findViewById(R.id.tuiroomkit_room_float_video_view);
        mRoomOwnerView = findViewById(R.id.tuiroomkit_master_avatar_iv);
        mUserAvatarIv = findViewById(R.id.tuiroomkit_room_float_avatar_view);
        mUserVolumePromptView = findViewById(R.id.tuiroomkit_user_mic);
        mUserNameTv = findViewById(R.id.tuiroomkit_user_name_tv);

        mFloatViewModel = new RoomVideoFloatViewModel(this, mVideoView);
        MetricsStats.submit(MetricsStats.T_METRICS_FLOAT_WINDOW_SHOW);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        mFloatViewModel.destroy();
    }

    public void setTouchListener(OnTouchListener touchListener) {
        mTouchListener = touchListener;
    }

    public void onNotifyVideoPlayStateChanged(boolean isPlaying) {
        mVideoView.setVisibility(isPlaying ? VISIBLE : GONE);
        mUserAvatarIv.setVisibility(isPlaying ? GONE : VISIBLE);
    }

    public void onNotifyAudioStreamStateChanged(boolean hasAudioStream) {
        mUserVolumePromptView.enableVolumeEffect(hasAudioStream);
    }

    public void onNotifyAudioVolumeChanged(int volume) {
        mUserVolumePromptView.updateVolumeEffect(volume);
    }

    public void onNotifyUserInfoChanged(UserEntity userInfo) {
        mRoomOwnerView.setVisibility(TextUtils.equals(userInfo.getUserId(),
                ConferenceController.sharedInstance().getConferenceState().roomInfo.ownerId) ? VISIBLE : GONE);
        String name = TextUtils.isEmpty(userInfo.getNameCard()) ? userInfo.getUserName() : userInfo.getNameCard();
        mUserNameTv.setText(TextUtils.isEmpty(name) ? userInfo.getUserId() : name);
        ImageLoader.loadImage(mContext, mUserAvatarIv, userInfo.getAvatarUrl(), R.drawable.tuivideoseat_head);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        if (mTouchListener != null) {
            mTouchListener.onTouch(this, event);
        }
        return true;
    }

    public void updateUserName(String nameCard) {
        mUserNameTv.setText(nameCard);
    }
}
