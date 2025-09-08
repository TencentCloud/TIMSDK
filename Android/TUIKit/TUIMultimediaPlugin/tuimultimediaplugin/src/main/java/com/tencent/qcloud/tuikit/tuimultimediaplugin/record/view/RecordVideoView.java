package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Point;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.ugc.TXRecordCommon;

@SuppressLint("ViewConstructor")
public class RecordVideoView extends FrameLayout {

    private final String TAG = RecordVideoView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaRecordCore mRecordCore;
    private final RecordInfo mRecordInfo;

    private TXCloudVideoView mVideoView;

    //private final TUIMultimediaDataObserver<Integer> mAspectRatioObserver = this::setVideoViewSize;

    public RecordVideoView(@NonNull Context context, TUIMultimediaRecordCore recordCore, RecordInfo recordInfo) {
        super(context);
        mContext = context;
        mRecordCore = recordCore;
        mRecordInfo = recordInfo;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initView();
        addObserver();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        mRecordCore.stopCameraPreview();
        removeObserver();
        removeAllViews();
    }

    public void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_video_play_view, this, true);
        mVideoView = findViewById(R.id.record_video_view);
        setVideoViewSize(TXRecordCommon.VIDEO_ASPECT_RATIO_9_16);
        mRecordCore.startCameraPreview(mVideoView);
    }

    public void addObserver() {
        //mRecordInfo.tuiDataAspectRatio.observe(mAspectRatioObserver);
    }

    public void removeObserver() {
        //mRecordInfo.tuiDataAspectRatio.removeObserver(mAspectRatioObserver);
    }

    private void setVideoViewSize(int aspectRatio) {
        Point screenSize = TUIMultimediaResourceUtils.getScreenSize(mContext);
        LiteavLog.i(TAG, "screenSize = " + screenSize);
        switch (aspectRatio) {
            case TXRecordCommon.VIDEO_ASPECT_RATIO_9_16:
                mVideoView.setLayoutParams(new FrameLayout.LayoutParams(screenSize.x, screenSize.x * 16 / 9));
                break;
            case TXRecordCommon.VIDEO_ASPECT_RATIO_3_4:
                FrameLayout.LayoutParams layoutParams = (LayoutParams) mVideoView.getLayoutParams();
                layoutParams.width = screenSize.x;
                layoutParams.height = screenSize.x * 4 / 3;
                layoutParams.topMargin = (screenSize.y - layoutParams.height) / 2;
                mVideoView.setLayoutParams(layoutParams);
                break;
//            case TXRecordCommon.VIDEO_ASPECT_RATIO_FULL_SRCREEN:
//                mVideoView.setLayoutParams(new FrameLayout.LayoutParams(screenSize.x, screenSize.y));
//                break;
            default:
                break;
        }
    }
}