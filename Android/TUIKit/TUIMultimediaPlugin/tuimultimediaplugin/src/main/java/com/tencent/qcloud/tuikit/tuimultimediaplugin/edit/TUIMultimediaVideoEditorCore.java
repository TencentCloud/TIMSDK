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
import com.tencent.ugc.TXVideoEditer.TXVideoPreviewListener;
import com.tencent.ugc.TXVideoInfoReader;
import java.util.LinkedList;
import java.util.List;

public class TUIMultimediaVideoEditorCore {

    private static final int LOW_QUALITY_BITRATE = 1000;
    private static final int MEDIUM_QUALITY_BITRATE = 3000;
    private static final int HIGH_QUALITY_BITRATE = 5000;

    private final String TAG = TUIMultimediaVideoEditorCore.class.getSimpleName() + "_" + hashCode();

    private TXVideoEditer mEditorSDK;
    private boolean mIsLoopPlay = false;
    private boolean mIsAddBgm = false;
    private boolean mIsAddPaster = false;
    private boolean mIsMute = false;

    private final TXVideoPreviewListener mTXVideoPreviewListener = new TXVideoPreviewListener() {
        @Override
        public void onPreviewProgress(int i) {}

        @Override
        public void onPreviewFinished() {
            LiteavLog.i(TAG, "on preview finished.");
            if (mIsLoopPlay && mEditorSDK != null) {
                mEditorSDK.stopPlay();
                mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
            }
        }
    };

    public TUIMultimediaVideoEditorCore(Context context) {
        LiteavLog.i(TAG, "TUIMultimediaEditorCore construct.");
        mEditorSDK = new TXVideoEditer(context);
    }

    public void setSource(String path) {
        LiteavLog.i(TAG, "set source path is " + path);
        if (mEditorSDK != null) {
            mEditorSDK.setVideoPath(path);
        }
    }

    public void startPreview(TXCloudVideoView videoView, boolean isLoopPlay) {
        if (mEditorSDK == null) {
            LiteavLog.e(TAG,"start preview. editor SDK has release.");
            return;
        }

        LiteavLog.i(TAG, "start preview videoView is " + videoView + " loop play flag is " + isLoopPlay);
        mIsLoopPlay = isLoopPlay;
        TXPreviewParam previewParam = new TXPreviewParam();
        previewParam.videoView = videoView;
        previewParam.renderMode = TXVideoEditConstants.PREVIEW_RENDER_MODE_FILL_EDGE;
        mEditorSDK.initWithPreview(previewParam);
        mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
        mEditorSDK.setTXVideoPreviewListener(mTXVideoPreviewListener);
    }

    public void muteBGM(boolean isMute) {
        LiteavLog.i(TAG," mute bgm. is mute:" + isMute);
        mIsAddBgm = !isMute;
        if (mEditorSDK != null) {
            mEditorSDK.setBGMVolume(isMute ? 0f : 1.0f);
        }
    }

    public void muteSourceAudio(boolean isMute) {
        LiteavLog.i(TAG," mute source audio. is mute:" + isMute);
        mIsMute = isMute;
        if (mEditorSDK != null) {
            mEditorSDK.setVideoVolume(isMute ? 0f : 1.0f);
        }
    }

    public void stopPreview() {
        LiteavLog.i(TAG, "stop preview");
        if (mEditorSDK != null) {
            mEditorSDK.stopPlay();
            mEditorSDK.setTXVideoPreviewListener(null);
        }
    }

    public void pausePreview() {
        LiteavLog.i(TAG,"pause preview");
        if (mEditorSDK != null) {
            mEditorSDK.pausePlay();
        }
    }

    public void resumePreview() {
        LiteavLog.i(TAG,"resume preview");
        if (mEditorSDK != null) {
            mEditorSDK.resumePlay();
        }
    }

    public void reStartPreview() {
        LiteavLog.i(TAG,"restart preview");
        if (mEditorSDK != null) {
            mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
            mEditorSDK.setTXVideoPreviewListener(mTXVideoPreviewListener);
        }
    }

    public void generateVideo(String videoOutputPath, VideoQuality videoQuality,
            TXVideoEditer.TXVideoGenerateListener listener) {
        if (mEditorSDK == null) {
            LiteavLog.e(TAG,"generate video. editor SDK has release.");
            return;
        }
        LiteavLog.i(TAG, "generate video.videoOutputPath = " + videoOutputPath + " VideoQuality = " + videoQuality);
        mEditorSDK.setVideoGenerateListener(listener);
        mEditorSDK.setVideoBitrate(getBitrateAccordQuality(videoQuality));
        mEditorSDK.generateVideo(getCompressLeveAccordQuality(videoQuality), videoOutputPath);
    }

    public void cancelGenerateVideo() {
        LiteavLog.i(TAG, "cancel generate video");
        if (mEditorSDK != null) {
            mEditorSDK.cancel();
            mEditorSDK.processVideo();
        }
    }

    public void setPasterList(@NonNull List<TUIMultimediaPasterInfo> pasterInfoList) {
        if (mEditorSDK == null) {
            return;
        }

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
        if (mEditorSDK != null) {
            mEditorSDK.setSubtitleList(null);
            mEditorSDK.setPasterList(null);
        }
        mIsAddPaster = false;
    }

    public void setBGMPath(String path) {
        LiteavLog.i(TAG, "set bgm path. path is " + path);
        if (mEditorSDK != null) {
            mEditorSDK.setBGM(path);
            mEditorSDK.setBGMLoop(true);
            mEditorSDK.setBGMVolume(1.0f);
            mEditorSDK.startPlayFromTime(0, Long.MAX_VALUE);
        }
        mIsAddBgm = (path != null && !path.isEmpty());
    }

    public void setBGMStartTime(long startTime, long endTime) {
        LiteavLog.i(TAG, "set BGM start time. " + " start time :" + startTime + " end time : " + endTime);
        if (startTime >= 0 && endTime > startTime && mEditorSDK != null) {
            mEditorSDK.setBGMStartTime(startTime, endTime);
        }
    }

    public boolean isVideoEdited() {
        LiteavLog.i(TAG,"is add paster:[%s],is add bgm:[%s],",mIsAddPaster, mIsAddBgm);
        return mIsAddPaster || mIsAddBgm || mIsMute;
    }

    public void release() {
        LiteavLog.i(TAG, "stop preview");
        if (mEditorSDK != null) {
            mEditorSDK.release();
            mEditorSDK = null;
        }
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
            LiteavLog.i(TUIMultimediaVideoEditorCore.class.getSimpleName(),"getVideoFileInfo  Exception e = ",e);
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
