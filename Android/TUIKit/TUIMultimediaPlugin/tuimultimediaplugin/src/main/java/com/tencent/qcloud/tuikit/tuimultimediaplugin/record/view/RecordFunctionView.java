package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Point;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import androidx.annotation.NonNull;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo.RecordStatus;
import com.tencent.ugc.TXRecordCommon;

@SuppressLint("ViewConstructor")
public class RecordFunctionView extends LinearLayout {

    private final static int DEFAULT_OPERATION_VIEW_HEIGHT_DP = 215;
    private final static int MIN_OPERATION_VIEW_HEIGHT_DP = 140;
    private final static int DEFAULT_OPERATION_TIPS_VIEW_HEIGHT_DP = 40;
    private final Context mContext;
    private final TUIMultimediaRecordCore mRecordCore;
    private final RecordInfo mRecordInfo;

    private RecordSettingView mRecordSettingView;
    private RecordOperationView mRecordOperationView;

    private RelativeLayout mOperationViewContainer;
    private final TUIMultimediaDataObserver<Boolean> mIsShowBeautyView = new TUIMultimediaDataObserver<Boolean>() {
        @Override
        public void onChanged(Boolean isShowBeautyView) {
            if (mOperationViewContainer != null) {
                mOperationViewContainer.setVisibility(isShowBeautyView ? GONE : VISIBLE);
            }
        }
    };
    private RelativeLayout mSettingViewContainer;
    private final TUIMultimediaDataObserver<RecordStatus> mRecodeStatusOnChanged = new TUIMultimediaDataObserver<RecordStatus>() {
        @Override
        public void onChanged(RecordStatus recordStatus) {
            if (mSettingViewContainer != null) {
                mSettingViewContainer.setVisibility((recordStatus == RecordStatus.RECORDING
                        || recordStatus == RecordStatus.TAKE_PHOTOING) ? GONE : VISIBLE);
            }
        }
    };

    public RecordFunctionView(@NonNull Context context, TUIMultimediaRecordCore recordCore, RecordInfo recordInfo) {
        super(context);
        mContext = context;
        mRecordCore = recordCore;
        mRecordInfo = recordInfo;
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        initView();
        addObserver();
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeObserver();
        removeAllViews();
    }

    @Override
    public void removeAllViews() {
        if (mOperationViewContainer != null) {
            mOperationViewContainer.removeAllViews();
        }

        if (mSettingViewContainer != null) {
            mSettingViewContainer.removeAllViews();
        }
        super.removeAllViews();
    }

    public void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_function_view, this, true);

        initRecordOperationView();

        mSettingViewContainer = findViewById(R.id.rl_setting_view_container);
        mSettingViewContainer.removeAllViews();
        if (mRecordSettingView == null) {
            mRecordSettingView = new RecordSettingView(mContext, mRecordCore, mRecordInfo);
        }
        mSettingViewContainer.addView(mRecordSettingView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
    }

    private void initRecordOperationView() {
        mOperationViewContainer = findViewById(R.id.rl_operation_view_container);
        mOperationViewContainer.removeAllViews();
        if (mRecordOperationView == null) {
            mRecordOperationView = new RecordOperationView(mContext, mRecordCore, mRecordInfo);
        }
        adjustRecordOperationViewPosition(mRecordInfo.tuiDataAspectRatio.get());
    }

    private void adjustRecordOperationViewPosition(int aspectRation) {
        if (mOperationViewContainer == null || mRecordOperationView == null) {
            return;
        }

        mOperationViewContainer.removeAllViews();
        Point screenSize = TUIMultimediaResourceUtils.getScreenSize(mContext);
        int viewHeight = TUIMultimediaResourceUtils.dip2px(mContext, DEFAULT_OPERATION_VIEW_HEIGHT_DP);
        if (aspectRation == TXRecordCommon.VIDEO_ASPECT_RATIO_9_16) {
            viewHeight = screenSize.y - screenSize.x * 16 / 9 + TUIMultimediaResourceUtils
                    .dip2px(mContext, DEFAULT_OPERATION_TIPS_VIEW_HEIGHT_DP);
        } else if (aspectRation == TXRecordCommon.VIDEO_ASPECT_RATIO_3_4) {
            viewHeight = screenSize.y / 2 - (screenSize.x * 4 / 3) / 2 + TUIMultimediaResourceUtils
                    .dip2px(mContext, DEFAULT_OPERATION_TIPS_VIEW_HEIGHT_DP);
        }
        int minViewHeight = TUIMultimediaResourceUtils.dip2px(mContext, MIN_OPERATION_VIEW_HEIGHT_DP);
        viewHeight = Math.max(viewHeight, minViewHeight);
        LayoutParams linearLayoutCompat = new LayoutParams(MATCH_PARENT, viewHeight);
        mOperationViewContainer.addView(mRecordOperationView, linearLayoutCompat);
    }

    private void addObserver() {
        mRecordInfo.tuiDataShowBeautyView.observe(mIsShowBeautyView);
        mRecordInfo.tuiDataRecordStatus.observe(mRecodeStatusOnChanged);
        mRecordInfo.tuiDataAspectRatio.observe(this::adjustRecordOperationViewPosition);
    }

    private void removeObserver() {
        mRecordInfo.tuiDataShowBeautyView.removeObserver(mIsShowBeautyView);
        mRecordInfo.tuiDataRecordStatus.removeObserver(mRecodeStatusOnChanged);
        mRecordInfo.tuiDataAspectRatio.removeObserver(this::adjustRecordOperationViewPosition);
    }
}
