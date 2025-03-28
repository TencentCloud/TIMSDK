package com.tencent.cloud.tuikit.roomkit.view.main.videodisplay;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.UserVolumePromptView;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class VolumeIndicatorEnergyBar extends UserVolumePromptView {
    private String mUserId;

    private final Observer<UserState.UserVolumeInfo> mVolumeObserver      = this::onVolumeChanged;
    private final LiveListObserver<String>           mAudioStreamObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            boolean hasAudioStream = list.contains(mUserId);
            enableVolumeEffect(hasAudioStream);
        }

        @Override
        public void onItemInserted(int position, String item) {
            if (!TextUtils.equals(item, mUserId)) {
                return;
            }
            enableVolumeEffect(true);
        }

        @Override
        public void onItemRemoved(int position, String item) {
            if (!TextUtils.equals(item, mUserId)) {
                return;
            }
            enableVolumeEffect(false);
        }
    };

    private final UserState mUserState = ConferenceController.sharedInstance().getUserState();

    public VolumeIndicatorEnergyBar(Context context) {
        super(context);
    }

    public VolumeIndicatorEnergyBar(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public void onBindToRecyclerView(String userId) {
        mUserId = userId;
        mUserState.userVolumeInfo.observe(mVolumeObserver);
        mUserState.hasAudioStreamUsers.observe(mAudioStreamObserver);
    }

    public void onRecycledByRecyclerView() {
        mUserState.userVolumeInfo.removeObserver(mVolumeObserver);
        mUserState.hasAudioStreamUsers.removeObserver(mAudioStreamObserver);
    }

    private void onVolumeChanged(UserState.UserVolumeInfo volumeInfo) {
        if (!TextUtils.equals(volumeInfo.userId, mUserId)) {
            return;
        }
        updateVolumeEffect(volumeInfo.volume);
    }
}
