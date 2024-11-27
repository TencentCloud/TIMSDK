package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import android.content.Context;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants.VideoQuality;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo.PasterType;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.ugc.TXRecordCommon;
import com.tencent.ugc.TXVideoEditConstants;
import com.tencent.ugc.TXVideoEditConstants.TXPaster;
import com.tencent.ugc.TXVideoEditConstants.TXPreviewParam;
import com.tencent.ugc.TXVideoEditConstants.TXSubtitle;
import com.tencent.ugc.TXVideoEditConstants.TXVideoInfo;
import com.tencent.ugc.TXVideoEditer;
import com.tencent.ugc.TXVideoEditer.TXThumbnailListener;
import com.tencent.ugc.TXVideoEditer.TXVideoPreviewListener;
import com.tencent.ugc.TXVideoInfoReader;
import java.util.LinkedList;
import java.util.List;

public class TUIMultimediaEditorCore {

    private static final int LOW_QUALITY_BITRATE = 1000;
    private static final int MEDIUM_QUALITY_BITRATE = 3000;
    private static final int HIGH_QUALITY_BITRATE = 5000;

    private final String TAG = TUIMultimediaEditorCore.class.getSimpleName() + "_" + hashCode();
    private final TXVideoEditer mEditorSDK;

    private boolean mIsLoopPlay = false;
    private TXCloudVideoView mVideoView;
    private String mPath;
    private boolean mIsAddBgm = false;
    private boolean mIsAddPaster = false;
    private boolean mIsMute = false;

    public TUIMultimediaEditorCore(Context context) {
        LiteavLog.i(TAG, "TUIMultimediaEditorCore construct.");
        mEditorSDK = new TXVideoEditer(context);
    }

    public void setSource(String path) {
        LiteavLog.i(TAG, "set source path is " + path);
        mPath = path;
        mEditorSDK.setVideoPath(path);
    }

    public void startPreview(TXCloudVideoView videoView, boolean isLoopPlay) {
        LiteavLog.i(TAG, "start preview videoView is " + videoView + " loop play flag is " + isLoopPlay);
        mIsLoopPlay = isLoopPlay;
        mVideoView = videoView;
        TXPreviewParam previewParam = new TXPreviewParam();
        previewParam.videoView = videoView;
        previewParam.renderMode = TXVideoEditConstants.PREVIEW_RENDER_MODE_FILL_EDGE;
        mEditorSDK.initWithPreview(previewParam);
        mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
        mEditorSDK.setTXVideoPreviewListener(new TXVideoPreviewListener() {
            @Override
            public void onPreviewProgress(int i) {
            }

            @Override
            public void onPreviewFinished() {
                LiteavLog.i(TAG, "on preview finished.");
                if (mIsLoopPlay) {
                    mEditorSDK.stopPlay();
                    mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
                }
            }
        });
    }

    public void muteSourceAudio(boolean isMute) {
        mIsMute = isMute;
        mEditorSDK.setVideoVolume(isMute ? 0f : 1.0f);
    }

    public void stopPreview() {
        LiteavLog.i(TAG, "stop preview");
        mEditorSDK.stopPlay();
        mEditorSDK.setTXVideoPreviewListener(null);
    }

    public void pausePreview() {
        mEditorSDK.pausePlay();
    }

    public void resumePreview() {
        mEditorSDK.resumePlay();
    }

    public void reStartPreview() {
        startPreview(mVideoView, mIsLoopPlay);
    }

    public void generateVideo(String videoOutputPath, VideoQuality videoQuality,
            TXVideoEditer.TXVideoGenerateListener listener) {
        LiteavLog.i(TAG, "generate video.videoOutputPath = " + videoOutputPath + " VideoQuality = " + videoQuality);
        mEditorSDK.setVideoGenerateListener(listener);
        mEditorSDK.setVideoBitrate(getBitrateAccordQuality(videoQuality));
        mEditorSDK.generateVideo(getCompressLeveAccordQuality(videoQuality), videoOutputPath);
    }

    public void getThumbnail(List<Long> thumbnailList, int width, int height, boolean fast,
            TXThumbnailListener listener) {
        mEditorSDK.getThumbnail(thumbnailList, width, height, fast, listener);
    }

    public void cancelGenerateVideo() {
        LiteavLog.i(TAG, "cancel generate video");
        mEditorSDK.cancel();
    }

    public void setPasterList(@NonNull List<TUIMultimediaPasterInfo> pasterInfoList) {
        LiteavLog.i(TAG,"set Paster List. size = " + pasterInfoList.size());
        List<TXSubtitle> subtitleList = new LinkedList<>();
        List<TXPaster> pasterList = new LinkedList<>();
        for (TUIMultimediaPasterInfo pasterInfo : pasterInfoList) {
            if (pasterInfo.pasterType == PasterType.SUBTITLE_PASTER) {
                TXSubtitle subtitle = new TXSubtitle();
                subtitle.frame = pasterInfo.frame;
                subtitle.titleImage = pasterInfo.image;
                subtitle.startTime = 0;
                subtitle.endTime = Integer.MAX_VALUE;
                subtitleList.add(subtitle);
            } else if (pasterInfo.pasterType == PasterType.STATIC_PICTURE_PASTER) {
                TXPaster staticPaster = new TXPaster();
                staticPaster.frame = pasterInfo.frame;
                staticPaster.pasterImage = pasterInfo.image;
                staticPaster.startTime = 0;
                staticPaster.endTime = Integer.MAX_VALUE;
                pasterList.add(staticPaster);
            }
            mIsAddPaster = true;
        }

        if (!subtitleList.isEmpty()) {
            mEditorSDK.setSubtitleList(subtitleList);
        }

        if (!pasterList.isEmpty()) {
            mEditorSDK.setPasterList(pasterList);
        }
    }

    public void clearPaster() {
        LiteavLog.i(TAG, "clear Paster");
        mEditorSDK.setSubtitleList(null);
        mEditorSDK.setPasterList(null);
        mIsAddPaster = false;
    }

    public void setBGMPath(String path) {
        LiteavLog.i(TAG, "set bgm path. path is " + path);
        mEditorSDK.setBGM(path);
        mEditorSDK.setBGMLoop(true);
        mEditorSDK.setBGMVolume(1.0f);
        mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
        mIsAddBgm = (path != null && !path.isEmpty());
    }

    public void setBGMStartTime(long startTime, long endTime) {
        LiteavLog.i(TAG, "set BGM start time. " + " start time :" + startTime + " end time : " + endTime);
        if (startTime >= 0 && endTime > startTime) {
            mEditorSDK.setBGMStartTime(startTime, endTime);
        }
    }

    public void setBGMVolume(float volume) {
        LiteavLog.i(TAG,"set BGM Volume:" + volume);
        mIsAddBgm = !(volume == 0);
        mEditorSDK.setBGMVolume(volume);
    }

    public boolean isVideoEdited() {
        LiteavLog.i(TAG,"is add paster:[%s],is add bgm:[%s],",mIsAddPaster, mIsAddBgm);
        return mIsAddPaster || mIsAddBgm || mIsMute;
    }

    public void release() {
        LiteavLog.i(TAG, "stop preview");
        mEditorSDK.release();
    }

    public static int getCompressLeveAccordQuality(VideoQuality videoQuality) {
        switch (videoQuality) {
            case HIGH:
                return TXRecordCommon.VIDEO_RESOLUTION_1080_1920;
            case LOW:
            case MEDIUM:
            default:
                return TXRecordCommon.VIDEO_RESOLUTION_720_1280;
        }
    }

    public static int getBitrateAccordQuality(VideoQuality videoQuality) {
        switch (videoQuality) {
            case LOW:
                return LOW_QUALITY_BITRATE;
            case HIGH:
                return HIGH_QUALITY_BITRATE;
            case MEDIUM:
            default:
                return MEDIUM_QUALITY_BITRATE;
        }
    }

    public static TXVideoInfo getVideoFileInfo(Context context, String filePath) {
        try {
            return TXVideoInfoReader.getInstance(context).getVideoFileInfo(filePath);
        } catch (Exception e) {
            LiteavLog.i(TUIMultimediaEditorCore.class.getSimpleName(),"getVideoFileInfo  Exception e = ",e);
            return null;
        }
    }

    public static boolean isValidVideo(TXVideoInfo videoInfo) {
        if (videoInfo == null) {
            return false;
        }

        return videoInfo.duration != 0 || videoInfo.width != 0 || videoInfo.height != 0
                || videoInfo.bitrate != 0 || videoInfo.fps != 0;
    }

    public static float getVideoAspect(TXVideoInfo videoInfo) {
        float aspect = 9.0f / 16.0f;
        if (videoInfo == null) {
            return aspect;
        }

        if (videoInfo.width != 0 && videoInfo.height != 0) {
            aspect = videoInfo.width * 1.0f / videoInfo.height;
        }
        return aspect;
    }
}
