package com.tencent.cloud.tuikit.roomkit.view.component;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.viewmodel.RoomVideoFloatViewModel;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.view.UserVolumePromptView;

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

        mFloatViewModel = new RoomVideoFloatViewModel(mContext, this, mVideoView);
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

    public void onNotifyUserInfoChanged(TUIRoomDefine.UserInfo userInfo) {
        mRoomOwnerView.setVisibility(userInfo.userRole == ROOM_OWNER ? VISIBLE : GONE);
        mUserNameTv.setText(TextUtils.isEmpty(userInfo.userName) ? userInfo.userId : userInfo.userName);
        ImageLoader.loadImage(mContext, mUserAvatarIv, userInfo.avatarUrl, R.drawable.tuivideoseat_head);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        if (mTouchListener != null) {
            mTouchListener.onTouch(this, event);
        }
        return true;
    }
}
