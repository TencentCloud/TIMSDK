package com.tencent.cloud.tuikit.roomkit.view.settingview;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.ExtensionSettingEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.ExtensionSettingManager;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SeekBarSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SelectionSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SwitchSettingItem;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;

public class VideoSettingView extends CoordinatorLayout {
    private static final String TAG = VideoSettingView.class.getName();

    private LinearLayout         mContentItem;
    private SeekBarSettingItem   mBitrateItem;
    private SwitchSettingItem    mMirrorTypeItem;
    private SelectionSettingItem mResolutionItem;
    private SelectionSettingItem mVideoFpsItem;

    private List<BaseSettingItem>              mSettingItemList;
    private ArrayList<TRTCSettingBitrateTable> mParamArray;

    private int mCurRes;
    private int mAppScene = TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;

    private ExtensionSettingManager mExtensionSettingManager;
    private OnItemChangeListener    mListener;

    public VideoSettingView(@NonNull Context context) {
        super(context);
        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_fragment_common_setting, this);
        initData();
        initView();
    }

    private void initData() {
        boolean isVideoCall = mAppScene == TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;
        mParamArray = new ArrayList<>();
        mParamArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180, isVideoCall ? 350 :
                350, 80, 350, 10));
        mParamArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270, isVideoCall ? 500 :
                750, 200, 1000, 10));
        mParamArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360, isVideoCall ? 600 :
                900, 200, 1000, 10));
        mParamArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540, isVideoCall ? 900 :
                1350, 400, 1600, 50));
        mParamArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720, isVideoCall ? 1250 :
                1850, 500, 2000, 50));
    }

    private void initView() {
        mContentItem = findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mExtensionSettingManager = ExtensionSettingManager.getInstance();

        BaseSettingItem.ItemText itemText = new BaseSettingItem
                .ItemText(getContext().getString(R.string.tuiroomkit_title_bitrate), "");
        mBitrateItem = new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                int bitrate = getBitrate(progress, mCurRes);
                mBitrateItem.setTips(bitrate + "kbps");
                if (bitrate != mExtensionSettingManager.getExtensionSetting().videoBitrate) {
                    mExtensionSettingManager.getExtensionSetting().videoBitrate = (bitrate);
                    if (mListener != null) {
                        mListener.onVideoBitrateChange(bitrate);
                    }
                }
            }
        });

        mCurRes = getResolutionPos(mExtensionSettingManager.getExtensionSetting().videoResolution);
        itemText = new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_resolution),
                getResources().getStringArray(R.array.solution));
        mResolutionItem = new SelectionSettingItem(getContext(), itemText,
                new SelectionSettingItem.Listener() {
                    @Override
                    public void onItemSelected(int position, String text) {
                        mCurRes = position;
                        updateSolution(mCurRes);
                        int resolution = getResolution(position);
                        if (resolution != mExtensionSettingManager.getExtensionSetting().videoResolution) {
                            ExtensionSettingEntity entity = mExtensionSettingManager.getExtensionSetting();
                            entity.videoResolution = resolution;
                            mExtensionSettingManager.setExtensionSetting(entity);
                            if (mListener != null) {
                                mListener.onVideoResolutionChange(resolution);
                            }
                        }
                    }
                }
        ).setSelect(mCurRes);
        if (mListener != null) {
            mListener.onVideoResolutionChange(getResolution(mCurRes));
        }
        mSettingItemList.add(mResolutionItem);

        itemText = new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_frame_rate),
                getResources().getStringArray(R.array.video_fps));
        mVideoFpsItem = new SelectionSettingItem(getContext(), itemText,
                new SelectionSettingItem.Listener() {
                    @Override
                    public void onItemSelected(int position, String text) {
                        int fps = getFps(position);
                        if (fps != mExtensionSettingManager.getExtensionSetting().videoFps) {
                            ExtensionSettingEntity entity = mExtensionSettingManager.getExtensionSetting();
                            entity.videoFps = fps;
                            mExtensionSettingManager.setExtensionSetting(entity);
                            if (mListener != null) {
                                mListener.onVideoFpsChange(fps);
                            }
                        }
                    }
                }
        ).setSelect(getFpsPos(mExtensionSettingManager.getExtensionSetting().videoFps));
        if (mListener != null) {
            mListener.onVideoFpsChange(getFps(mVideoFpsItem.getSelected()));
        }
        mSettingItemList.add(mVideoFpsItem);

        updateSolution(mCurRes);
        mBitrateItem.setProgress(getBitrateProgress(mExtensionSettingManager
                .getExtensionSetting().videoBitrate, mCurRes));
        mBitrateItem.setTips(getBitrate(mExtensionSettingManager
                .getExtensionSetting().videoBitrate, mCurRes) + "kbps");
        if (mListener != null) {
            mListener.onVideoBitrateChange(getBitrate(mExtensionSettingManager
                    .getExtensionSetting().videoBitrate, mCurRes));
        }
        mSettingItemList.add(mBitrateItem);

        itemText =
                new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_local_mirror),
                        getContext().getString(R.string.tuiroomkit_title_enable),
                        getContext().getString(R.string.tuiroomkit_title_disable));
        mMirrorTypeItem = new SwitchSettingItem(getContext(), itemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                ExtensionSettingEntity entity = mExtensionSettingManager.getExtensionSetting();
                entity.isMirror = isChecked;
                mExtensionSettingManager.setExtensionSetting(entity);
                if (mListener != null) {
                    mListener.onVideoMirrorChange(isChecked);
                }
            }
        }).setCheck(mExtensionSettingManager.getExtensionSetting().isMirror);
        mSettingItemList.add(mMirrorTypeItem);

        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            int paddingVertical = getResources()
                    .getDimensionPixelSize(R.dimen.tuiroomkit_radio_button_padding_vertical);
            view.setPadding(0, paddingVertical, 0, paddingVertical);
            mContentItem.addView(view);
        }
    }

    private void updateSolution(int pos) {
        int minBitrate = getMinBitrate(pos);
        int maxBitrate = getMaxBitrate(pos);

        int stepBitrate = getStepBitrate(pos);
        int max = (maxBitrate - minBitrate) / stepBitrate;
        if (mBitrateItem.getMax() != max) {
            mBitrateItem.setMax(max);
            int defBitrate = getDefBitrate(pos);
            mBitrateItem.setProgress(getBitrateProgress(defBitrate, pos));
        } else {
            mBitrateItem.setMax(max);
        }
    }

    private int getResolutionPos(int resolution) {
        for (int i = 0; i < mParamArray.size(); i++) {
            if (resolution == (mParamArray.get(i).resolution)) {
                return i;
            }
        }
        return 4;
    }

    private int getResolution(int pos) {
        if (pos >= 0 && pos < mParamArray.size()) {
            return mParamArray.get(pos).resolution;
        }
        return TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    }

    private int getFpsPos(int fps) {
        return fps == 20 ? 1 : 0;
    }

    private int getFps(int pos) {
        return pos == 1 ? 20 : 15;
    }

    private int getMinBitrate(int pos) {
        if (pos >= 0 && pos < mParamArray.size()) {
            return mParamArray.get(pos).minBitrate;
        }
        return 300;
    }

    private int getMaxBitrate(int pos) {
        if (pos >= 0 && pos < mParamArray.size()) {
            return mParamArray.get(pos).maxBitrate;
        }
        return 1000;
    }

    private int getDefBitrate(int pos) {
        if (pos >= 0 && pos < mParamArray.size()) {
            return mParamArray.get(pos).defaultBitrate;
        }
        return 400;
    }

    private int getStepBitrate(int pos) {
        if (pos >= 0 && pos < mParamArray.size()) {
            return mParamArray.get(pos).step;
        }
        return 10;
    }

    private int getBitrateProgress(int bitrate, int pos) {
        int minBitrate = getMinBitrate(pos);
        int stepBitrate = getStepBitrate(pos);

        int progress = (bitrate - minBitrate) / stepBitrate;
        Log.i(TAG,
                "getBitrateProgress->progress: " + progress + ", min: " + minBitrate + ", stepBitrate: "
                        + stepBitrate + "/" + bitrate);
        return progress;
    }

    private int getBitrate(int progress, int pos) {
        int minBitrate = getMinBitrate(pos);
        int maxBitrate = getMaxBitrate(pos);
        int stepBitrate = getStepBitrate(pos);
        int bit = (progress * stepBitrate) + minBitrate;
        Log.i(TAG, "getBitrate->bit: " + bit + ", min: " + minBitrate + ", max: " + maxBitrate);
        return bit;
    }

    static class TRTCSettingBitrateTable {
        public int resolution;
        public int defaultBitrate;
        public int minBitrate;
        public int maxBitrate;
        public int step;

        public TRTCSettingBitrateTable(int resolution, int defaultBitrate, int minBitrate, int maxBitrate, int step) {
            this.resolution = resolution;
            this.defaultBitrate = defaultBitrate;
            this.minBitrate = minBitrate;
            this.maxBitrate = maxBitrate;
            this.step = step;
        }
    }

    public void setListener(OnItemChangeListener listener) {
        this.mListener = listener;
    }

    public interface OnItemChangeListener {
        void onVideoBitrateChange(int bitrate);

        void onVideoResolutionChange(int resolution);

        void onVideoFpsChange(int fps);

        void onVideoMirrorChange(boolean mirror);
    }
}
