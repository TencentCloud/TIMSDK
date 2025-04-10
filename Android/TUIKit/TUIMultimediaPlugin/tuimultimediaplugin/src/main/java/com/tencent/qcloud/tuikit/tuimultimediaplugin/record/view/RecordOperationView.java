package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.tencent.imsdk.BuildConfig;
import com.tencent.imsdk.base.ThreadUtils;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaAuthorizationPrompter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil.MultimediaPluginFileType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo.RecordStatus;
import com.tencent.ugc.TXRecordCommon;

@SuppressLint("ViewConstructor")
public class RecordOperationView extends LinearLayout {

    private final String TAG = RecordOperationView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaRecordCore mRecordCore;
    private final RecordInfo mRecordInfo;

    private RecordButtonView mRecordButtonView;
    private TextView mRecordOperationTipsView;
    private TextView mRecordTimeTextView;
    private Float mLastRecordProcess = 0.0f;
    private String mLastRecordTime;

    private final TUIMultimediaDataObserver<RecordStatus> mRecordStatusObserver = new TUIMultimediaDataObserver<RecordStatus>() {
        @Override
        public void onChanged(RecordStatus recordStatus) {
            if (recordStatus == RecordStatus.RECORDING || recordStatus == RecordStatus.TAKE_PHOTOING) {
                findViewById(R.id.cancel_record_button).setVisibility(INVISIBLE);
                findViewById(R.id.record_switch_camera).setVisibility(INVISIBLE);
                hideRecordOperationTips();
            } else {
                mRecordButtonView.setProcess(0);
                mLastRecordProcess = 0.0f;
                mLastRecordTime = null;
                if (recordStatus == RecordStatus.STOP && !mRecordInfo.recordResult.isSuccess
                        && mRecordInfo.recordResult.code == TXRecordCommon.RECORD_RESULT_OK_LESS_THAN_MINDURATION) {
                    mRecordCore.takePhoto(
                            TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.PICTURE_FILE));
                } else {
                    findViewById(R.id.cancel_record_button).setVisibility(VISIBLE);
                    findViewById(R.id.record_switch_camera).setVisibility(VISIBLE);
                }
            }
        }
    };
    private final TUIMultimediaDataObserver<Float> mRecordProcessObserver = new TUIMultimediaDataObserver<Float>() {
        @Override
        public void onChanged(Float process) {
            LiteavLog.i(TAG, "record process is " + process);
            if (process > mLastRecordProcess) {
                mLastRecordProcess = process;
                mRecordButtonView.setProcess(process);
                setRecordTime(process);
            }
        }
    };
    private boolean isNeedShowOperationTipsView = true;

    public RecordOperationView(@NonNull Context context, TUIMultimediaRecordCore recordCore, RecordInfo recordInfo) {
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

    public void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_operation_view, this, true);

        findViewById(R.id.record_switch_camera).setOnClickListener(v -> {
            boolean is_front_camera = mRecordInfo.tuiDataIsFontCamera.get();
            mRecordCore.switchCamera(!is_front_camera);
        });

        findViewById(R.id.cancel_record_button).setOnClickListener(v -> {
            ((Activity) mContext).setResult(Activity.RESULT_CANCELED, null);
            ((Activity) mContext).finish();
        });

        mRecordTimeTextView = findViewById(R.id.record_time);
        mRecordOperationTipsView = findViewById(R.id.record_operation_tips);
        mRecordOperationTipsView.setVisibility(isNeedShowOperationTipsView ? VISIBLE : INVISIBLE);
        mRecordButtonView = findViewById(R.id.start_record_button);
        if (mRecordInfo.recodeType == TUIMultimediaConstants.RECORD_TYPE_VIDEO) {
            initRecordButtonForVideoRecode();
        } else {
            initRecordButtonForTakePhoto();
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initRecordButtonForVideoRecode() {
        mRecordButtonView.setOnLongClickListener(v -> {
            if (!TUIMultimediaAuthorizationPrompter.verifyPermissionGranted(mContext)) {
                return false;
            }

            mRecordCore.startRecord(TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.RECODE_FILE));
            return false;
        });

        mRecordButtonView.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                mRecordCore.stopRecord();
                mRecordTimeTextView.setVisibility(INVISIBLE);
            }
            return false;
        });

        mRecordButtonView.setOnClickListener(
                v -> {
                    if (!TUIMultimediaAuthorizationPrompter.verifyPermissionGranted(mContext)) {
                        return;
                    }

                    mRecordCore.takePhoto(
                            TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.PICTURE_FILE));
                });
        mRecordOperationTipsView.setText(R.string.multimedia_plugin_record_operation_tips);
        mRecordButtonView.setIsOnlySupportTakePhoto(false);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initRecordButtonForTakePhoto() {
        mRecordButtonView.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_DOWN) {
                mRecordInfo.tuiDataRecordStatus.set(RecordStatus.TAKE_PHOTOING);
            }
            return false;
        });

        mRecordButtonView.setOnClickListener(
                v -> {
                    if (!TUIMultimediaAuthorizationPrompter.verifyPermissionGranted(mContext)) {
                        mRecordInfo.tuiDataRecordStatus.set(RecordStatus.IDLE);
                        return;
                    }
                    mRecordCore.takePhoto(
                            TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.PICTURE_FILE));
                });

        mRecordOperationTipsView.setText(R.string.multimedia_plugin_record_take_phone_operation_tips);
        mRecordButtonView.setIsOnlySupportTakePhoto(true);
    }

    private void setRecordTime(float process) {
        int maxDuration = mRecordCore.getMaxDuration();
        String recordTime = TUIMultimediaResourceUtils.secondsToTimeString((long) (process * maxDuration));
        if (recordTime.equals(mLastRecordTime)) {
            return;
        }
        mLastRecordTime = recordTime;
        ThreadUtils.getUiThreadHandler().post(() -> {
            mRecordTimeTextView.setText(mLastRecordTime);
        });
    }

    private void addObserver() {
        mRecordInfo.tuiDataRecordStatus.observe(mRecordStatusObserver);
        mRecordInfo.tuiDataRecordProcess.observe(mRecordProcessObserver);
    }

    private void removeObserver() {
        mRecordInfo.tuiDataRecordStatus.removeObserver(mRecordStatusObserver);
        mRecordInfo.tuiDataRecordProcess.removeObserver(mRecordProcessObserver);
    }

    private void hideRecordOperationTips() {
        if (mRecordOperationTipsView != null) {
            mRecordOperationTipsView.setVisibility(INVISIBLE);
        }
        isNeedShowOperationTipsView = false;
    }
}
