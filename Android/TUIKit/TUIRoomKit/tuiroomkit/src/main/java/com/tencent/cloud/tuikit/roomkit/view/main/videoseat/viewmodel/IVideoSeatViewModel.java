package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.viewmodel;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;

import java.util.List;

public interface IVideoSeatViewModel {
    void destroy();

    List<UserEntity> getData();

    void startPlayVideo(String userId, TUIVideoView videoView, boolean isSharingScreen);

    void stopPlayVideo(String userId, boolean isSharingScreen, boolean isStreamStop);

    void setLocalVideoView(UserEntity selfEntity);

    void toggleScreenSizeOnDoubleClick(int position);
}
