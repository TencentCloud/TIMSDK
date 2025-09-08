package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaAuthorizationPrompter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil.MultimediaPluginFileType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultiMediaEditCommonCtrlView.CommonMediaEditListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultiMediaEditCommonCtrlView.EditType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.BGMEditListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.ProgressRingView;
import com.tencent.ugc.TXVideoEditConstants.TXGenerateResult;
import com.tencent.ugc.TXVideoEditer.TXVideoGenerateListener;
import com.tencent.ugc.UGCLicenseChecker;

public class TUIMultimediaVideoEditFragment extends Fragment {

    private final String TAG = TUIMultimediaVideoEditFragment.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;

    private TUIMultiMediaEditCommonCtrlView mTuiMultiMediaEditCommonCtrlView;
    private TUIMultimediaVideoEditorCore mTUIMultimediaVideoEditorCore;
    private View mRootView;
    private View mGenerateVideoView;
    private ProgressRingView mCircleProgressBar;
    private String mEditFilePath;
    private float mAspectRatio = 9.0f / 16.0f;

    private boolean mIsRecordFile = false;
    private String mSourceFilePath;

    public TUIMultimediaVideoEditFragment(Context context) {
        mContext = context;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreate");
        mTUIMultimediaVideoEditorCore = new TUIMultimediaVideoEditorCore(mContext);
        initExternalParameters();
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreateView");
        mRootView = inflater.inflate(R.layout.multimedia_plugin_edit_video_fragment, container, false);
        initView();
        return mRootView;
    }

    @Override
    public void onDestroyView() {
        LiteavLog.i(TAG, "onDestroyView");
        super.onDestroyView();
    }

    @Override
    public void onDestroy() {
        LiteavLog.i(TAG, "onDestroy");
        super.onDestroy();
        mTUIMultimediaVideoEditorCore.release();
    }

    @Override
    public void onResume() {
        super.onResume();
        mTUIMultimediaVideoEditorCore.resumePreview();
    }

    @Override
    public void onPause() {
        super.onPause();
        mTUIMultimediaVideoEditorCore.pausePreview();
    }

    public void initView() {
        mTuiMultiMediaEditCommonCtrlView = new TUIMultiMediaEditCommonCtrlView(mContext, EditType.VIDEO, mIsRecordFile);
        mTuiMultiMediaEditCommonCtrlView.setMediaAspectRatio(mAspectRatio);
        ((RelativeLayout) mRootView.findViewById(R.id.edit_common_ctrl_view_container))
                .addView(mTuiMultiMediaEditCommonCtrlView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        mGenerateVideoView = mRootView.findViewById(R.id.rl_generate_video_view);
        mCircleProgressBar = mRootView.findViewById(R.id.generate_video_progressBar);

        mRootView.findViewById(R.id.generate_video_cancel_btn).setOnClickListener(view -> cancelGenerateVideo());

        previewVideo(mEditFilePath);

        mTuiMultiMediaEditCommonCtrlView.setBGMListener(new BGMEditListener() {
            @Override
            public void onAddBGM(String bgmPath) {
                mTUIMultimediaVideoEditorCore.setBGMPath(bgmPath);
            }

            @Override
            public void onCutBGM(long startTime, long endTime) {
                mTUIMultimediaVideoEditorCore.setBGMStartTime(startTime, endTime);
            }

            @Override
            public void onMuteSourceAudio(boolean isMute) {
                mTUIMultimediaVideoEditorCore.muteSourceAudio(isMute);
            }

            @Override
            public void onMuteBGM(boolean isMute) {
                mTUIMultimediaVideoEditorCore.muteBGM(isMute);
            }
        });

        mTuiMultiMediaEditCommonCtrlView.setCommonMediaEditListener(new CommonMediaEditListener() {
            @Override
            public void onGenerateMedia() {
                generateVideo();
            }

            @Override
            public void onCancelEdit() {
                if (mIsRecordFile) {
                    ((AppCompatActivity) mContext).getSupportFragmentManager().popBackStack();
                } else {
                    finishEdit(null);
                }
            }
        });
    }

    private void previewVideo(String videoFilePath) {
        LiteavLog.i(TAG, "preview video. file path = " + videoFilePath);
        mSourceFilePath = videoFilePath;
        if (videoFilePath == null || videoFilePath.isEmpty()) {
            LiteavLog.e(TAG, "vide file path is null");
            return;
        }

        mTUIMultimediaVideoEditorCore.setSource(videoFilePath);
        TUIMultimediaVideoPreview editorVideoView = new TUIMultimediaVideoPreview(mContext,
                mTUIMultimediaVideoEditorCore);
        mTuiMultiMediaEditCommonCtrlView.setMediaView(editorVideoView);
    }

    private void generateVideo() {
        mTUIMultimediaVideoEditorCore.stopPreview();
        mTUIMultimediaVideoEditorCore.setPasterList(mTuiMultiMediaEditCommonCtrlView.getPaster());

        if (!mIsRecordFile && !mTUIMultimediaVideoEditorCore.isVideoEdited()) {
            finishEdit(null);
            return;
        }

        if (!TUIMultimediaSignatureChecker.getInstance().isSupportFunction()) {
            if (mTUIMultimediaVideoEditorCore.isVideoEdited()) {
                TUIMultimediaAuthorizationPrompter.showPermissionPrompterDialog(getContext());
                mTuiMultiMediaEditCommonCtrlView.showOperationView(true);
                mTUIMultimediaVideoEditorCore.reStartPreview();
            } else {
                finishEdit(mSourceFilePath);
            }
            return;
        }

        if (!mIsRecordFile && !mTUIMultimediaVideoEditorCore.isVideoEdited()) {
            finishEdit(null);
            return;
        }

        mGenerateVideoView.setVisibility(View.VISIBLE);
        mCircleProgressBar.setProgress(0);
        String outVideoPath = TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.EDIT_FILE);
        mTUIMultimediaVideoEditorCore.generateVideo(outVideoPath, TUIMultimediaIConfig.getInstance().getVideoQuality(),
                new TXVideoGenerateListener() {
                    @Override
                    public void onGenerateProgress(float progress) {
                        mCircleProgressBar.setProgress(progress);
                    }

                    @Override
                    public void onGenerateComplete(TXGenerateResult txGenerateResult) {
                        LiteavLog.i(TAG, "onGenerateComplete = " + txGenerateResult.retCode);
                        finishEdit(outVideoPath);
                        mGenerateVideoView.setVisibility(View.GONE);
                    }
                });
    }

    private void cancelGenerateVideo() {
        ((ProgressRingView) mRootView.findViewById(R.id.generate_video_progressBar)).setProgress(0);
        mGenerateVideoView.setVisibility(View.GONE);

        mTuiMultiMediaEditCommonCtrlView.bringToFront();
        mTuiMultiMediaEditCommonCtrlView.showOperationView(true);

        mTUIMultimediaVideoEditorCore.cancelGenerateVideo();
        mTUIMultimediaVideoEditorCore.reStartPreview();
        mTUIMultimediaVideoEditorCore.clearPaster();
    }

    private void finishEdit(String editedFilePath) {
        LiteavLog.i(TAG, "finish edit. path = " + editedFilePath);
        Intent resultIntent = new Intent();
        if (editedFilePath != null) {
            resultIntent.putExtra(TUIMultimediaConstants.PARAM_NAME_EDITED_FILE_PATH, editedFilePath);
            resultIntent.putExtra(TUIMultimediaConstants.RECORD_TYPE_KEY, TUIMultimediaConstants.RECORD_TYPE_VIDEO);
        }
        ((Activity) mContext).setResult(Activity.RESULT_OK, resultIntent);
        ((Activity) mContext).finish();
    }

    private void initExternalParameters() {
        Bundle bundle = getArguments();
        if (bundle == null) {
            return;
        }
        mEditFilePath = bundle.getString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH, "");
        mAspectRatio = bundle.getFloat(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_RATIO, 9.0f / 16.0f);
        mIsRecordFile = bundle.getBoolean(TUIMultimediaConstants.PARAM_NAME_IS_RECODE_FILE, false);
        LiteavLog.i(TAG, "init external parameters mEditFilePath = " + mEditFilePath
                + " video quality = " + TUIMultimediaIConfig.getInstance().getVideoQuality()
                + ", video ratio = " + mAspectRatio);
    }
}