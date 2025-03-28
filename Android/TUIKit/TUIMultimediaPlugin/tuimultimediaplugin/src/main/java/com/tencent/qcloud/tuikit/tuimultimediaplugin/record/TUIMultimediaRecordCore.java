package com.tencent.qcloud.tuikit.tuimultimediaplugin.record;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants.VideoQuality;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo.RecordStatus;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.ugc.TXRecordCommon;
import com.tencent.ugc.TXRecordCommon.ITXVideoRecordListener;
import com.tencent.ugc.TXRecordCommon.TXRecordResult;
import com.tencent.ugc.TXUGCRecord;
import java.io.FileOutputStream;
import java.util.Timer;
import java.util.TimerTask;

public class TUIMultimediaRecordCore {

    private final static int PROCESS_TIME_INTERVAL_MS = 40;
    private final static float DEFAULT_VOLUME = 0.5f;
    private final static int DEFAULT_VIDEO_GOP = 3;
    private final static int LOW_QUALITY_BITRATE = 1000;
    private final static int MEDIUM_QUALITY_BITRATE = 3000;
    private final static int HIGH_QUALITY_BITRATE = 5000;
    private final static int EDIT_BITRATE = 12000;
    private final static int LOW_QUALITY_FPS = 25;
    private final static int MEDIUM_QUALITY_FPS = 25;
    private final static int HIGH_QUALITY_FPS = 30;
    private final static int LOW_QUALITY_RESOLUTION = TXRecordCommon.VIDEO_RESOLUTION_720_1280;
    private final static int MEDIUM_QUALITY_RESOLUTION = TXRecordCommon.VIDEO_RESOLUTION_720_1280;
    private final static int HIGH_QUALITY_RESOLUTION = TXRecordCommon.VIDEO_RESOLUTION_1080_1920;
    private final static int DEFAULT_MAX_RECORD_DURATION_MS = 15000;
    private final static int DEFAULT_MIN_RECORD_DURATION_MS = 2000;

    private final String TAG = TUIMultimediaRecordCore.class.getSimpleName() + "_" + hashCode();
    private final TXUGCRecord mRecordSDK;
    private final RecordInfo mRecordInfo;

    private TXBeautyManager mBeautyManager;
    private Bitmap mFilterBitmap;
    private VideoQuality mVideoQuality = VideoQuality.LOW;
    private Boolean mIsNeedEdit = true;
    private int mMaxDuration = DEFAULT_MAX_RECORD_DURATION_MS;
    private int mMinDuration = DEFAULT_MIN_RECORD_DURATION_MS;

    private Timer mRecordProcessTimer;
    private long mRecordProgress;

    private final ITXVideoRecordListener mVideoRecordListener = new ITXVideoRecordListener() {
        @Override
        public void onRecordEvent(int eventCode, Bundle bundle) {
            LiteavLog.i(TAG, "onRecordEvent code = " + eventCode);
        }

        @Override
        public void onRecordProgress(long progress) {
            LiteavLog.i(TAG, "onRecordProgress progress = " + progress);
            if (progress > 0) {
                startProcessTimer(progress);
            }
        }

        @Override
        public void onRecordComplete(TXRecordResult txRecordResult) {
            LiteavLog.i(TAG, "onRecordComplete retCode = " + txRecordResult);
            stopProcessTimer();
            if (txRecordResult.retCode == TXRecordCommon.RECORD_RESULT_OK ||
                    txRecordResult.retCode == TXRecordCommon.RECORD_RESULT_OK_REACHED_MAXDURATION) {
                mRecordInfo.recordResult.isSuccess = true;
                mRecordInfo.recordResult.type = TUIMultimediaConstants.RECORD_TYPE_VIDEO;
                mRecordInfo.recordResult.path = txRecordResult.videoPath;
            } else {
                mRecordInfo.recordResult.isSuccess = false;
            }
            mRecordInfo.recordResult.code = txRecordResult.retCode;
            mRecordInfo.tuiDataRecordStatus.set(RecordStatus.STOP);
            mRecordSDK.getPartsManager().deleteAllParts();
            LiteavLog.i(TAG, "onRecordComplete finish");
        }
    };

    public TUIMultimediaRecordCore(Context context, RecordInfo recordInfo) {
        mRecordSDK = TXUGCRecord.getInstance(context);
        mRecordInfo = recordInfo;
    }

    public void release() {
        LiteavLog.i(TAG, "release");
        mRecordSDK.setVideoRecordListener(null);
        mRecordSDK.getPartsManager().deleteAllParts();
        setFilterAndStrength(null, 0);
        setBeautyStyleAndLevel(0, 0);
        setWhitenessLevel(0);
        setRuddyLevel(0);
        mRecordSDK.release();
        mRecordInfo.tuiDataRecordStatus.set(RecordStatus.IDLE);
        stopProcessTimer();
        mBeautyManager = null;
    }

    public void startCameraPreview(TXCloudVideoView videoView) {
        Log.i(TAG, "start camera preview. videoView " + videoView);
        TXRecordCommon.TXUGCCustomConfig customConfig = new TXRecordCommon.TXUGCCustomConfig();
        initRecordConfig(customConfig);

        mRecordSDK.startCameraCustomPreview(customConfig, videoView);
        mRecordSDK.setRecordSpeed(TXRecordCommon.RECORD_SPEED_NORMAL);
        mRecordSDK.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
        mRecordSDK.setRenderRotation(TXLiveConstants.RENDER_ROTATION_PORTRAIT);
        mRecordSDK.setAspectRatio(TXRecordCommon.VIDEO_ASPECT_RATIO_9_16);
        mRecordSDK.setVideoRenderMode(TXRecordCommon.VIDEO_RENDER_MODE_ADJUST_RESOLUTION);
        mRecordSDK.setMicVolume(DEFAULT_VOLUME);
    }

    public void stopCameraPreview() {
        LiteavLog.i(TAG, "stop camera preview");
        mRecordSDK.stopCameraPreview();
    }

    public void startRecord(String videoFilePath) {
        if (mRecordInfo.tuiDataRecordStatus.get() == RecordStatus.RECORDING) {
            LiteavLog.e(TAG, "start record, but current status is recording.");
            return;
        }
        LiteavLog.i(TAG, "start record. vide file Path is " + videoFilePath);
        mRecordInfo.tuiDataRecordStatus.set(RecordStatus.RECORDING);
        mRecordSDK.setVideoRecordListener(mVideoRecordListener);
        mRecordSDK.startRecord(videoFilePath, null);
    }

    public void stopRecord() {
        LiteavLog.i(TAG, "stop record.current stats is " + mRecordInfo.tuiDataRecordStatus.get());
        if (mRecordInfo.tuiDataRecordStatus.get() != RecordStatus.RECORDING) {
            return;
        }
        mRecordSDK.stopRecord();
        stopProcessTimer();
    }

    public void setAspectRatio(int aspectRatio) {
        LiteavLog.i(TAG, "set aspect ration is " + aspectRatio);
        mRecordInfo.tuiDataAspectRatio.set(aspectRatio);
        mRecordSDK.setAspectRatio(aspectRatio);
    }

    public void takePhoto(String photoFilePath) {
        LiteavLog.i(TAG, "take photo.current status is " + mRecordInfo.tuiDataRecordStatus.get());
        if (mRecordInfo.tuiDataRecordStatus.get() == RecordStatus.RECORDING) {
            return;
        }
        mRecordInfo.tuiDataRecordStatus.set(RecordStatus.TAKE_PHOTOING);
        mRecordSDK.snapshot(bitmap -> {
            LiteavLog.i(TAG, "onSnapshot. snap file Path is " + photoFilePath);

            FileOutputStream outputStream = null;
            try {
                outputStream = new FileOutputStream(photoFilePath);
                bitmap.compress(Bitmap.CompressFormat.JPEG, 90, outputStream);
                mRecordInfo.recordResult.type = TUIMultimediaConstants.RECORD_TYPE_PHOTO;
                mRecordInfo.recordResult.path = photoFilePath;
                mRecordInfo.recordResult.isSuccess = true;
                mRecordInfo.tuiDataRecordStatus.set(RecordStatus.STOP);
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (outputStream != null) {
                    try {
                        outputStream.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }

    public void switchCamera(boolean isFront) {
        LiteavLog.i(TAG, "switch camera. is front " + isFront);
        if (isFront) {
            toggleTorch(false);
        }
        mRecordInfo.tuiDataIsFontCamera.set(isFront);
        mRecordSDK.switchCamera(isFront);
    }

    public boolean toggleTorch(boolean enable) {
        LiteavLog.i(TAG, "toggleTorch enable is " + enable);
        mRecordInfo.tuiDataIsFlashOn.set(enable);
        return mRecordSDK.toggleTorch(enable);
    }

    public int getMaxZoom() {
        return mRecordSDK.getMaxZoom();
    }

    public boolean setZoom(int value) {
        LiteavLog.i(TAG, "set zoom value = " + value);
        return mRecordSDK.setZoom(value);
    }

    public void setFocusPosition(float eventX, float eventY) {
        LiteavLog.i(TAG, "set focus position [" + eventX + "," + eventY + "]");
        mRecordSDK.setFocusPosition(eventX, eventY);
    }

    public void setBeautyStyleAndLevel(int style, float level) {
        LiteavLog.i(TAG, "set beauty style:" + style + " level:" + level);
        TXBeautyManager beautyManager = getBeautyManager();
        if (beautyManager == null) {
            return;
        }

        if (style >= 3 || style < 0) {
            return;
        }
        beautyManager.setBeautyStyle(style);
        beautyManager.setBeautyLevel(level);
    }

    public void setWhitenessLevel(float whitenessLevel) {
        LiteavLog.i(TAG, "set whiteness level:" + whitenessLevel);
        TXBeautyManager beautyManager = getBeautyManager();
        if (beautyManager != null) {
            beautyManager.setWhitenessLevel(whitenessLevel);
        }
    }

    public void setRuddyLevel(float ruddyLevel) {
        LiteavLog.i(TAG, "set ruddy level:" + ruddyLevel);
        TXBeautyManager beautyManager = getBeautyManager();
        if (beautyManager != null) {
            beautyManager.setRuddyLevel(ruddyLevel);
        }
    }

    public void setFilterAndStrength(Bitmap bitmap, int strength) {
        LiteavLog.i(TAG, "set filter bitmap:" + bitmap + " strength:" + strength);
        TXBeautyManager beautyManager = getBeautyManager();
        if (beautyManager == null) {
            return;
        }

        if (mFilterBitmap != bitmap) {
            beautyManager.setFilter(bitmap);
            mFilterBitmap = bitmap;
        }

        beautyManager.setFilterStrength(strength / 10.0f);
    }

    public void setFilter(Bitmap leftBitmap, float leftIntensity, Bitmap rightBitmap,
            float rightIntensity, float leftRatio) {
        LiteavLog.i(TAG, "set filter. left intensity is " + leftIntensity
                + "  right intensity is " + " left ration is " + leftRatio);
        mRecordSDK.setFilter(leftBitmap, leftIntensity, rightBitmap, rightIntensity, leftRatio);
        mFilterBitmap = null;
    }

    public void setMinDuration(int duration) {
        mMinDuration = duration;
    }

    public int getMaxDuration() {
        return mMaxDuration;
    }

    public void setMaxDuration(int duration) {
        mMaxDuration = duration;
    }

    public void setVideoQuality(VideoQuality videoQuality) {
        LiteavLog.i(TAG, "set video quality " + videoQuality);
        mVideoQuality = videoQuality;
    }

    public void setIsNeedEdit(Boolean isNeedEdit) {
        mIsNeedEdit = isNeedEdit;
    }

    private void initRecordConfig(TXRecordCommon.TXUGCCustomConfig customConfig) {
        setBaseVideoEncodeParamWithQuality(mVideoQuality, customConfig);

        customConfig.videoGop = DEFAULT_VIDEO_GOP;
        customConfig.profile = TXRecordCommon.RECORD_PROFILE_HIGH;

        customConfig.maxDuration = mMaxDuration;
        customConfig.minDuration = mMinDuration;
        customConfig.touchFocus = false;
        customConfig.needEdit = false;
        customConfig.isFront = mRecordInfo.tuiDataIsFontCamera.get();
    }

    private void setBaseVideoEncodeParamWithQuality(VideoQuality quality,
            TXRecordCommon.TXUGCCustomConfig customConfig) {
        switch (quality) {
            case HIGH:
                customConfig.videoFps = HIGH_QUALITY_FPS;
                customConfig.videoResolution = HIGH_QUALITY_RESOLUTION;
                customConfig.videoBitrate = mIsNeedEdit ? EDIT_BITRATE : HIGH_QUALITY_BITRATE;
                break;
            case MEDIUM:
                customConfig.videoFps = MEDIUM_QUALITY_FPS;
                customConfig.videoResolution = MEDIUM_QUALITY_RESOLUTION;
                customConfig.videoBitrate = mIsNeedEdit ? EDIT_BITRATE : MEDIUM_QUALITY_BITRATE;
                break;
            case LOW:
            default:
                customConfig.videoFps = LOW_QUALITY_FPS;
                customConfig.videoResolution = LOW_QUALITY_RESOLUTION;
                customConfig.videoBitrate = mIsNeedEdit ? EDIT_BITRATE : LOW_QUALITY_BITRATE;
                break;
        }
    }

    private void startProcessTimer(long progress) {
        if (mRecordProcessTimer != null) {
            return;
        }
        mRecordProgress = progress;
        mRecordProcessTimer = new Timer();
        mRecordProcessTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                mRecordProgress += PROCESS_TIME_INTERVAL_MS;
                mRecordInfo.tuiDataRecordProcess.set(mRecordProgress * 1.0f / mMaxDuration);
            }
        }, PROCESS_TIME_INTERVAL_MS, PROCESS_TIME_INTERVAL_MS);
    }

    private void stopProcessTimer() {
        if (mRecordProcessTimer != null) {
            mRecordProcessTimer.cancel();
            mRecordProcessTimer = null;
        }
    }

    private TXBeautyManager getBeautyManager() {
        if (mBeautyManager != null) {
            return mBeautyManager;
        }

        if (mRecordSDK == null) {
            return null;
        }

        mBeautyManager = mRecordSDK.getBeautyManager();
        if (mBeautyManager != null) {
            mBeautyManager.setBeautyStyle(TXBeautyManager.TXBeautyStyleSmooth);
        }
        return mBeautyManager;
    }
}