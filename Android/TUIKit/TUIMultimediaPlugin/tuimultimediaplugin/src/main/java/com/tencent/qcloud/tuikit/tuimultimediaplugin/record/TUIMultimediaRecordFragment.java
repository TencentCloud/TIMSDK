package com.tencent.qcloud.tuikit.tuimultimediaplugin.record;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPictureEditFragment;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaVideoEditFragment;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo.RecordResult;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo.RecordStatus;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.RecordFunctionView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.RecordVideoView;
import com.tencent.ugc.TXRecordCommon;
import org.json.JSONObject;

public class TUIMultimediaRecordFragment extends Fragment {

    private final String TAG = TUIMultimediaRecordFragment.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaRecordCore mTUIMultimediaRecordCore;
    private final RecordInfo mRecordInfo;

    private RecordVideoView mRecordVideoView;
    private RecordFunctionView mRecordFunctionView;
    private RelativeLayout mVideoViewContainer;
    private RelativeLayout mRecordFunctionContainer;
    private boolean isFlashOnWhenPause;

    private final TUIMultimediaDataObserver<RecordStatus> mRecordStatusObserver = new TUIMultimediaDataObserver<RecordStatus>() {
        @Override
        public void onChanged(RecordStatus recordStatus) {
            LiteavLog.i(TAG, "record status onChanged. current status is " + recordStatus
                    + " record result : " + mRecordInfo.recordResult.isSuccess);
            if (recordStatus == RecordStatus.STOP && mRecordInfo.recordResult.isSuccess) {
                editRecordFile(mRecordInfo.recordResult);
            }
        }
    };

    public TUIMultimediaRecordFragment(Context context) {
        mContext = context;
        mRecordInfo = new RecordInfo();
        mTUIMultimediaRecordCore = new TUIMultimediaRecordCore(context, mRecordInfo);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initParameters();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View contentView = inflater.inflate(R.layout.multimedia_plugin_record_fragment, container, false);
        mVideoViewContainer = contentView.findViewById(R.id.rl_video_view_container);
        mRecordFunctionContainer = contentView.findViewById(R.id.rl_function_view_container);
        addObserver();
        addChildView();
        return contentView;
    }

    @Override
    public void onDestroyView() {
        LiteavLog.i(TAG, "onDestroyView");
        super.onDestroyView();
        removeChildView();
        removeObserver();
    }

    @Override
    public void onDestroy() {
        LiteavLog.i(TAG, "onDestroy");
        super.onDestroy();
        mTUIMultimediaRecordCore.release();
    }

    @Override
    public void onResume() {
        super.onResume();
        mTUIMultimediaRecordCore.toggleTorch(isFlashOnWhenPause);
    }

    @Override
    public void onPause() {
        super.onPause();
        isFlashOnWhenPause = mRecordInfo.tuiDataIsFlashOn.get();
        mTUIMultimediaRecordCore.toggleTorch(false);
    }

    private void addObserver() {
        mRecordInfo.tuiDataRecordStatus.observe(mRecordStatusObserver);
    }

    private void removeObserver() {
        mRecordInfo.tuiDataRecordStatus.removeObserver(mRecordStatusObserver);
    }

    private void initParameters() {
        Bundle arguments = getArguments();
        if (arguments != null) {
            mRecordInfo.recodeType = arguments.getInt(TUIMultimediaConstants.PARAM_NAME_RECORD_TYPE,
                    TUIMultimediaConstants.RECORD_TYPE_VIDEO);
        }
        mTUIMultimediaRecordCore.setMaxDuration(TUIMultimediaIConfig.getInstance().getMaxRecordDurationMs());
        mTUIMultimediaRecordCore.setMinDuration(TUIMultimediaIConfig.getInstance().getMinRecordDurationMs());
        mTUIMultimediaRecordCore.setVideoQuality(TUIMultimediaIConfig.getInstance().getVideoQuality());
        mTUIMultimediaRecordCore.setIsNeedEdit(true);
    }

    private void removeChildView() {
        mVideoViewContainer.removeAllViews();
        mRecordFunctionContainer.removeAllViews();
    }

    private void addChildView() {
        mVideoViewContainer.removeAllViews();
        if (mRecordVideoView == null) {
            mRecordVideoView = new RecordVideoView(mContext, mTUIMultimediaRecordCore, mRecordInfo);
        }
        mVideoViewContainer
                .addView(mRecordVideoView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));

        mRecordFunctionContainer.removeAllViews();
        if (mRecordFunctionView == null) {
            mRecordFunctionView = new RecordFunctionView(mContext, mTUIMultimediaRecordCore, mRecordInfo);
        }
        mRecordFunctionContainer
                .addView(mRecordFunctionView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
    }

    private void editRecordFile(RecordResult recordResult) {
        LiteavLog.i(TAG,"editRecordFile file path: " + recordResult.path);
        Fragment fragment;
        if (recordResult.type == TUIMultimediaConstants.RECORD_TYPE_PHOTO) {
            fragment = new TUIMultimediaPictureEditFragment(mContext);
        } else {
            fragment = new TUIMultimediaVideoEditFragment(mContext);
        }

        Bundle bundle = new Bundle();
        bundle.putString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH, recordResult.path);
        bundle.putFloat(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_RATIO,
                convertAspectRation(mRecordInfo.tuiDataAspectRatio.get()));
        bundle.putBoolean(TUIMultimediaConstants.PARAM_NAME_IS_RECODE_FILE, true);

        fragment.setArguments(bundle);
        ((AppCompatActivity) mContext).getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fl_record_fragment_container, fragment)
                .addToBackStack(null).commit();
    }

    private float convertAspectRation(int aspectRatio) {
        switch (aspectRatio) {
            case TXRecordCommon.VIDEO_ASPECT_RATIO_16_9:
                return 16.0f / 9.0f;
            case TXRecordCommon.VIDEO_ASPECT_RATIO_3_4:
                return 3.0f / 4.0f;
            case TXRecordCommon.VIDEO_ASPECT_RATIO_4_3:
                return 4.0f / 3.0f;
            case TXRecordCommon.VIDEO_ASPECT_RATIO_1_1:
                return 1.0f;
            case TXRecordCommon.VIDEO_ASPECT_RATIO_9_16:
            default:
                return 9.0f / 16.0f;
        }
    }
}