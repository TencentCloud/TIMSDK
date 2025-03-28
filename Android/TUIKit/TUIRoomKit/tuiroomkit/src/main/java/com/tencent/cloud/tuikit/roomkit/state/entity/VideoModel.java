package com.tencent.cloud.tuikit.roomkit.state.entity;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoQuality.Q_1080P;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoQuality.Q_360P;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoQuality.Q_540P;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoQuality.Q_720P;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_VIDEO_FPS_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_VIDEO_RESOLUTION_CHANGED;

import android.content.Context;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.qcloud.tuicore.TUILogin;

public class VideoModel {
    Context mContext = TUILogin.getAppContext();
    public VideoResolutionMap[] mVideoResolutionMaps = {
            new VideoResolutionMap(mContext.getString(R.string.tuiroomkit_video_resolution_smooth), Q_360P, 550),
            new VideoResolutionMap(mContext.getString(R.string.tuiroomkit_video_resolution_sd), Q_540P, 850),
            new VideoResolutionMap(mContext.getString(R.string.tuiroomkit_video_resolution_hd), Q_720P, 1200),
            new VideoResolutionMap(mContext.getString(R.string.tuiroomkit_video_resolution_uhd), Q_1080P, 2000)};

    private int                        fps           = ConferenceConstant.DEFAULT_VIDEO_FPS;
    private int                        bitrate       = ConferenceConstant.DEFAULT_VIDEO_BITRATE;
    private TUIRoomDefine.VideoQuality resolution    = ConferenceConstant.DEFAULT_VIDEO_RESOLUTION;
    public  boolean                    isLocalMirror = ConferenceConstant.DEFAULT_VIDEO_LOCAL_MIRROR;
    public  boolean                    isFrontCamera = ConferenceConstant.DEFAULT_CAMERA_FRONT;

    private boolean isScreenSharing = false;
    private boolean isCameraOpened  = false;

    public int getFps() {
        return fps;
    }

    public void setFps(int fps) {
        this.fps = fps;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_VIDEO_FPS_CHANGED, null);
    }

    public int getBitrate() {
        return bitrate;
    }

    public TUIRoomDefine.VideoQuality getResolution() {
        return resolution;
    }

    public void setResolution(TUIRoomDefine.VideoQuality resolution) {
        this.resolution = resolution;
        this.bitrate = getBitrateByResolution(resolution);
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_VIDEO_RESOLUTION_CHANGED, null);
    }

    public boolean isScreenSharing() {
        return isScreenSharing;
    }

    public void setScreenSharing(boolean screenSharing) {
        isScreenSharing = screenSharing;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_SCREEN_STATE_CHANGED, null);
    }

    public boolean isCameraOpened() {
        return isCameraOpened;
    }

    public void setCameraOpened(boolean cameraOpened) {
        isCameraOpened = cameraOpened;
        ConferenceEventCenter.getInstance().notifyEngineEvent(LOCAL_CAMERA_STATE_CHANGED, null);
    }

    class VideoResolutionMap {
        public String                     name;
        public TUIRoomDefine.VideoQuality resolution;
        public int                        bitrate;

        public VideoResolutionMap(String name, TUIRoomDefine.VideoQuality resolution, int bitrate) {
            this.name = name;
            this.resolution = resolution;
            this.bitrate = bitrate;
        }
    }

    private int getBitrateByResolution(TUIRoomDefine.VideoQuality resolution) {
        int tmpBitrate = bitrate;
        for (int i = 0; i < mVideoResolutionMaps.length; i++) {
            if (resolution == mVideoResolutionMaps[i].resolution) {
                tmpBitrate = mVideoResolutionMaps[i].bitrate;
            }
        }
        return tmpBitrate;
    }

    public String getCurrentResolutionName() {
        String name = "";
        for (int i = 0; i < mVideoResolutionMaps.length; i++) {
            if (resolution == mVideoResolutionMaps[i].resolution) {
                name = mVideoResolutionMaps[i].name;
            }
        }
        return name;
    }
}
