package com.tencent.cloud.tuikit.roomkit.view.settingview;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SeekBarSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SwitchSettingItem;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class AudioSettingView extends CoordinatorLayout {
    public static final String AUDIO_EVALUATION_CHANGED = "AUDIO_EVALUATION_CHANGED";

    private String                  mRecordFilePath;
    private LinearLayout            mContentItem;
    private SwitchSettingItem       mAudioVolumeEvaluationItem;
    private SwitchSettingItem       mRecordItem;
    private SeekBarSettingItem      mCollectionVolumeItem;
    private SeekBarSettingItem      mPlayVolumeItem;
    private List<BaseSettingItem>   mSettingItemList;
    private OnItemChangeListener    mListener;

    private RoomStore mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();

    public AudioSettingView(@NonNull Context context, OnItemChangeListener listener) {
        super(context);
        mListener = listener;
        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_fragment_common_setting, this);
        initView();
    }

    private void initView() {
        mContentItem = findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mRecordFilePath = getRecordFilePath();

        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_collection_volume), "");

        mCollectionVolumeItem = new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                String volume = String.valueOf(progress);
                mCollectionVolumeItem.setTips(volume);
                mListener.onAudioCaptureVolumeChange(progress);
            }
        }).setProgress(mRoomStore.audioModel.captureVolume);
        mSettingItemList.add(mCollectionVolumeItem);

        itemText =
                new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_play_volume), "");
        mPlayVolumeItem = new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                String volume = String.valueOf(progress);
                mPlayVolumeItem.setTips(volume);
                mListener.onAudioPlayVolumeChange(progress);
            }
        }).setProgress(mRoomStore.audioModel.playVolume);
        mSettingItemList.add(mPlayVolumeItem);

        itemText =
                new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_volume_reminder), "");
        mAudioVolumeEvaluationItem = new SwitchSettingItem(getContext(), itemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                mListener.onAudioEvaluationEnableChange(isChecked);
                Intent intent = new Intent(AUDIO_EVALUATION_CHANGED);
                LocalBroadcastManager.getInstance(getContext()).sendBroadcast(intent);

            }
        }).setCheck(mRoomStore.audioModel.enableVolumeEvaluation);
        mSettingItemList.add(mAudioVolumeEvaluationItem);

        itemText =
                new BaseSettingItem.ItemText(getContext().getString(R.string.tuiroomkit_title_audio_recording), "");
        mRecordItem = new SwitchSettingItem(getContext(), itemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                if (isChecked) {
                    createFile(mRecordFilePath);
                    mListener.onStartFileDumping(mRecordFilePath);
                    ToastUtil.toastShortMessage(getContext().getString(R.string.tuiroomkit_btn_start_recording));
                } else {
                    mListener.onStopFileDumping();
                    ToastUtil.toastLongMessage(
                            getContext().getString(R.string.tuiroomkit_toast_recording_file_path_copied,
                                    mRecordFilePath));
                    ClipboardManager cm = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    ClipData mClipData = ClipData.newPlainText("path", mRecordFilePath);
                    if (cm != null) {
                        cm.setPrimaryClip(mClipData);
                    }
                }
            }
        }).setCheck(false);
        mSettingItemList.add(mRecordItem);

        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            int paddingVertical = getResources()
                    .getDimensionPixelSize(R.dimen.tuiroomkit_radio_button_padding_vertical);
            view.setPadding(0, paddingVertical, 0, paddingVertical);
            mContentItem.addView(view);
        }
    }

    private String getRecordFilePath() {
        File sdcardDir = getContext().getExternalFilesDir(null);
        if (sdcardDir == null) {
            return null;
        }

        String dirPath = sdcardDir.getAbsolutePath() + "/test/record/";
        File dir = new File(dirPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File file = new File(dir, "record.aac");

        return file.getAbsolutePath();
    }

    private void createFile(String path) {
        try {
            File file = new File(path);
            file.delete();
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    public interface OnItemChangeListener {
        void onAudioCaptureVolumeChange(int volume);

        void onAudioPlayVolumeChange(int volume);

        void onAudioEvaluationEnableChange(boolean enable);

        void onStartFileDumping(String path);

        void onStopFileDumping();
    }
}
