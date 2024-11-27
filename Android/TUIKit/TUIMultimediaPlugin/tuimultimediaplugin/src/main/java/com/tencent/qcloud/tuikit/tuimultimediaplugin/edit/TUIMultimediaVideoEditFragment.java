package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.DrawableCompat;
import androidx.fragment.app.Fragment;
import com.tencent.liteav.base.ThreadUtils;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil.MultimediaPluginFileType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.BGMManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.BGMPanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerViewGroup;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.graffiti.GraffitiPanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.PicturePasterFloatLayerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.PicturePasterManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.PicturePasterPanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster.SubtitlePanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster.SubtitlePasterFloatLayerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.ProgressRingView;
import com.tencent.ugc.TXVideoEditConstants.TXGenerateResult;
import com.tencent.ugc.TXVideoEditer.TXVideoGenerateListener;
import java.util.List;

public class TUIMultimediaVideoEditFragment extends Fragment {

    private final static int COMMON_FUNCTION_ICON_SIZE_DP = 28;
    private final static int BGM_FUNCTION_ICON_MARGIN_DP = 34;

    private final String TAG = TUIMultimediaVideoEditFragment.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaEditorCore mTUIMultimediaEditorCore;

    private ViewTreeObserver.OnGlobalLayoutListener mOnGlobalLayoutListener;
    private RelativeLayout mOperationLayout;
    private LinearLayout mFunctionButtonLayout;
    private ImageView mReturnBackView;
    private View mRootView;
    private FloatLayerViewGroup mFloatLayerViewGroup;
    private String mEditFilePath;
    private float mAspectRatio = 9.0f / 16.0f;

    private GraffitiPanelView mGraffitiPanelView;
    private ImageButton mGraffitiBtn;

    private PicturePasterPanelView mPicturePasterPanelView;
    private PicturePasterManager mPicturePasterManager;

    private SubtitlePanelView mSubtitlePanelView;

    private BGMPanelView mBGMPanelView;
    private BGMManager mBGMManager;
    private ImageButton mBGMBtn;
    private boolean isRecordFile = false;

    private final OnClickListener mOnRootViewOnClickListener = new OnClickListener() {
        @Override
        public void onClick(View v) {
            if (mPicturePasterPanelView != null) {
                mPicturePasterPanelView.setVisibility(View.GONE);
            }

            if (mBGMPanelView != null) {
                mBGMPanelView.setVisibility(View.GONE);
            }

            mOperationLayout.setVisibility(View.VISIBLE);
            mFloatLayerViewGroup.unSelectOperationView();
            showOperationView(true);
        }
    };

    public TUIMultimediaVideoEditFragment(Context context) {
        mContext = context;
        mTUIMultimediaEditorCore = new TUIMultimediaEditorCore(mContext);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreate");
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
        mTUIMultimediaEditorCore.release();
        if (mPicturePasterManager != null) {
            mPicturePasterManager.uninit();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        mTUIMultimediaEditorCore.resumePreview();
        if (mRootView != null) {
            mRootView.getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        mTUIMultimediaEditorCore.pausePreview();
        if (mRootView != null) {
            mRootView.getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);
        }
    }

    public void initView() {
        mRootView.setOnClickListener(mOnRootViewOnClickListener);
        mFloatLayerViewGroup = mRootView.findViewById(R.id.float_layer_view_group);
        mOperationLayout = mRootView.findViewById(R.id.operation_layout);
        mReturnBackView = mRootView.findViewById(R.id.edit_return_back);

        mRootView.findViewById(R.id.generate_video_cancel_btn).setOnClickListener(v -> cancelGenerateVideo());
        mReturnBackView.setOnClickListener(view -> doCancel());

        mFunctionButtonLayout = mRootView.findViewById(R.id.function_button_layout);

        initSendBtn();
        initGraffitiBtn();
        initPasterFunction();
        initSubtitleBtn();
        initBGMFunction();
        adjustVideoAreaLayout();
        mOnGlobalLayoutListener = this::adjustFunctionButtonPosition;
        mRootView.getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
        previewVideo(mEditFilePath);
    }

    private void initSendBtn() {
        Button button = mRootView.findViewById(R.id.send_btn);
        button.setBackground(TUIMultimediaResourceUtils
                .getDrawable(mContext, R.drawable.multimedia_plugin_edit_send_button, TUIMultimediaIConfig.getInstance().getThemeColor()));
        button.setGravity(Gravity.CENTER);
        if (isRecordFile) {
            button.setText(TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_send));
        } else {
            button.setText(TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_done));
        }
        button.setOnClickListener(v -> generateVideo());
    }

    private void initGraffitiBtn() {
        if (!TUIMultimediaIConfig.getInstance().isSupportEditGraffiti()) {
            return;
        }

        int[][] states = new int[][]{
                new int[]{android.R.attr.state_enabled, -android.R.attr.state_selected},
                new int[]{android.R.attr.state_enabled, android.R.attr.state_selected},
        };

        int[] colors = new int[]{
                Color.WHITE, TUIMultimediaIConfig.getInstance().getThemeColor()
        };

        mGraffitiBtn = addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_graffiti, new ColorStateList(states, colors), v -> switchEnableGraffiti());
    }

    private void initPasterFunction() {
        if (!TUIMultimediaIConfig.getInstance().isSupportEditPaster()) {
            return;
        }
        addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP, R.drawable.multimedia_plugin_edit_paster,
                null, v -> addPicturePaster());

        initPicturePasterSetManager();
    }

    private void initSubtitleBtn() {
        if (!TUIMultimediaIConfig.getInstance().isSupportEditSubtitle()) {
            return;
        }
        addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_subtitle, null, v -> addSubtitlePaster());
    }

    private void initBGMFunction() {
        if (!TUIMultimediaIConfig.getInstance().isSupportEditBGM()) {
            return;
        }

        int[][] states = new int[][]{
                new int[]{android.R.attr.state_enabled, -android.R.attr.state_selected},
                new int[]{android.R.attr.state_enabled, android.R.attr.state_selected},
        };

        int[] colors = new int[]{
                Color.WHITE, TUIMultimediaIConfig.getInstance().getThemeColor()
        };

        mBGMBtn = addFunctionButton(BGM_FUNCTION_ICON_MARGIN_DP, BGM_FUNCTION_ICON_MARGIN_DP,
                R.drawable.multimedia_plugin_edit_bgm, new ColorStateList(states, colors),
                v -> addBGMPanel());

        initBGMManager();
    }

    private ImageButton addFunctionButton(int widthDp, int heightDp, int drawableId, ColorStateList tint,
            OnClickListener onClickListener) {
        ImageButton imageButton = new ImageButton(mContext);
        Drawable drawable = ContextCompat.getDrawable(mContext, drawableId);
        if (tint != null) {
            DrawableCompat.setTintList(drawable, tint);
        } else {
            DrawableCompat.setTint(drawable, Color.WHITE);
        }
        imageButton.setBackground(drawable);
        imageButton.setScaleType(ScaleType.FIT_CENTER);

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
                TUIMultimediaResourceUtils.dip2px(mContext, widthDp),
                TUIMultimediaResourceUtils.dip2px(mContext, heightDp));
        mFunctionButtonLayout.addView(imageButton, layoutParams);
        imageButton.setOnClickListener(onClickListener);
        return imageButton;
    }

    private void previewVideo(String videoFilePath) {
        LiteavLog.i(TAG, "preview video. file path = " + videoFilePath);
        if (videoFilePath == null || videoFilePath.isEmpty()) {
            LiteavLog.e(TAG, "vide file path is null");
            return;
        }

        mTUIMultimediaEditorCore.setSource(videoFilePath);
        RelativeLayout videoPreviewContainer = mRootView.findViewById(R.id.rl_video_play_view_container);
        videoPreviewContainer.removeAllViews();
        TUIMultimediaVideoPreview editorVideoView = new TUIMultimediaVideoPreview(mContext, mTUIMultimediaEditorCore);
        videoPreviewContainer.addView(editorVideoView, new LayoutParams(MATCH_PARENT, MATCH_PARENT));
    }

    private void generateVideo() {
        mTUIMultimediaEditorCore.stopPreview();
        addPasterToVideo();

        if (!isRecordFile && !mTUIMultimediaEditorCore.isVideoEdited()) {
            finishEdit(null);
            return;
        }

        mRootView.findViewById(R.id.rl_generate_video_view).setVisibility(View.VISIBLE);
        showOperationView(false);
        mRootView.setOnClickListener(null);
        ProgressRingView circleProgressBar = mRootView.findViewById(R.id.generate_video_progressBar);
        circleProgressBar.setProgress(0);
        String outVideoPath = TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.EDIT_FILE);
        mTUIMultimediaEditorCore.generateVideo(outVideoPath, TUIMultimediaIConfig.getInstance().getVideoQuality(), new TXVideoGenerateListener() {
            @Override
            public void onGenerateProgress(float progress) {
                circleProgressBar.setProgress(progress);
                LiteavLog.i(TAG, "progress = " + progress);
            }

            @Override
            public void onGenerateComplete(TXGenerateResult txGenerateResult) {
                LiteavLog.i(TAG, "onGenerateComplete = " + txGenerateResult.retCode);
                finishEdit(outVideoPath);
                mRootView.findViewById(R.id.rl_generate_video_view).setVisibility(View.GONE);
            }
        });
    }

    private void cancelGenerateVideo() {
        ((ProgressRingView) mRootView.findViewById(R.id.generate_video_progressBar)).setProgress(0);
        mRootView.findViewById(R.id.rl_generate_video_view).setVisibility(View.GONE);
        showOperationView(true);
        mRootView.setOnClickListener(mOnRootViewOnClickListener);
        mTUIMultimediaEditorCore.cancelGenerateVideo();
        mTUIMultimediaEditorCore.reStartPreview();
        mTUIMultimediaEditorCore.clearPaster();
    }

    private void doCancel() {
        if (isRecordFile) {
            ((AppCompatActivity) mContext).getSupportFragmentManager().popBackStack();
        } else {
            finishEdit(null);
        }
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

    private void addPasterToVideo() {
        List<TUIMultimediaPasterInfo> pasterInfoList = mFloatLayerViewGroup.getAllPaster();
        TUIMultimediaPasterInfo graffitiPaster = null;
        if (mGraffitiPanelView != null) {
            graffitiPaster = mGraffitiPanelView.getGraffitiPaster();
        }

        if (graffitiPaster != null) {
            pasterInfoList.add(0, graffitiPaster);
        }

        mTUIMultimediaEditorCore.setPasterList(pasterInfoList);
    }

    private void addSubtitlePaster() {
        if (mSubtitlePanelView == null) {
            mSubtitlePanelView = new SubtitlePanelView(mContext);
            RelativeLayout subtitlePasterInputViewContainer = mRootView
                    .findViewById(R.id.rl_subtitle_paster_input_view_container);
            subtitlePasterInputViewContainer.removeAllViews();
            subtitlePasterInputViewContainer.addView(mSubtitlePanelView,
                    new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        }

        mSubtitlePanelView.inputText(null, subtitleInfo -> {
            if (subtitleInfo != null && !subtitleInfo.getText().isEmpty()) {
                new SubtitlePasterFloatLayerView(getContext(),
                        mFloatLayerViewGroup, subtitleInfo, mSubtitlePanelView);
            }
            showOperationView(true);
            mFloatLayerViewGroup.setCanTouch(true);
        });
        disableGraffiti();
        showOperationView(false);
        mFloatLayerViewGroup.setCanTouch(false);
        mFloatLayerViewGroup.unSelectOperationView();
    }

    private void addPicturePaster() {
        if (mPicturePasterPanelView == null) {
            RelativeLayout picturePasterPanelViewContainer = mRootView
                    .findViewById(R.id.rl_picture_paster_panel_view_container);
            picturePasterPanelViewContainer.removeAllViews();
            picturePasterPanelViewContainer.setVisibility(View.VISIBLE);
            mPicturePasterPanelView = new PicturePasterPanelView(mContext, mPicturePasterManager);
            picturePasterPanelViewContainer
                    .addView(mPicturePasterPanelView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        }
        mPicturePasterPanelView.setVisibility(View.VISIBLE);
        mPicturePasterPanelView.selectPaster(bitmap -> {
            if (bitmap != null) {
                new PicturePasterFloatLayerView(getContext(), mFloatLayerViewGroup, bitmap);
            }
            mPicturePasterPanelView.setVisibility(View.GONE);
            showOperationView(true);
        });
        disableGraffiti();
        showOperationView(false);
        mFloatLayerViewGroup.unSelectOperationView();
    }

    private void addBGMPanel() {
        if (mBGMPanelView == null) {
            mBGMPanelView = new BGMPanelView(mContext, mTUIMultimediaEditorCore, mBGMManager);
            RelativeLayout bgmPanelViewContainer = mRootView.findViewById(R.id.rl_bgm_panel_view_container);
            bgmPanelViewContainer.setVisibility(View.VISIBLE);
            bgmPanelViewContainer.addView(mBGMPanelView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        }
        mBGMPanelView.setVisibility(View.VISIBLE);
        mBGMPanelView.selectBGM(enable -> {
            if (mBGMBtn != null) {
                LiteavLog.i(TAG, "mAddBgmBtn.setSelected enable=  " + enable);
                mBGMBtn.setSelected(enable);
            }
        });
        mFloatLayerViewGroup.unSelectOperationView();
        disableGraffiti();
        showOperationView(false);
    }

    private void initPicturePasterSetManager() {
        if (mPicturePasterManager != null) {
            return;
        }

        mPicturePasterManager = new PicturePasterManager(TUIMultimediaIConfig.getInstance().getPicturePasterConfigFilePath());
        mPicturePasterManager.init();
    }

    private void initBGMManager() {
        if (mBGMManager != null) {
            return;
        }

        mBGMManager = new BGMManager(TUIMultimediaIConfig.getInstance().getBGMConfigFilePath());
        mBGMManager.init();
    }

    private void switchEnableGraffiti() {
        boolean enableGraffiti =
                mGraffitiPanelView != null && mGraffitiPanelView.isEnableGraffiti();
        if (enableGraffiti) {
            disableGraffiti();
        } else {
            enableGraffiti();
        }
        mFloatLayerViewGroup.unSelectOperationView();
    }

    private void enableGraffiti() {
        if (mGraffitiPanelView == null) {
            mGraffitiPanelView = new GraffitiPanelView(mContext,
                    mRootView.findViewById(R.id.rl_graffiti_drawing_view_container),
                    mRootView.findViewById(R.id.rl_graffiti_operation_view_container));
            mGraffitiPanelView.tuiDataIsDrawing.observe(isDrawing -> showOperationView(!isDrawing));
        }
        mGraffitiPanelView.showOperationView(true);
        mGraffitiPanelView.enableGraffiti(true);
        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.setCanTouch(false);
        }

        if (mGraffitiBtn != null) {
            mGraffitiBtn.setSelected(true);
        }
        mOperationLayout.setBackgroundColor(
                TUIMultimediaResourceUtils.getColor(R.color.multimedia_plugin_edit_function_button_view_background));
    }

    private void disableGraffiti() {
        if (mGraffitiPanelView != null) {
            mGraffitiPanelView.showOperationView(false);
            mGraffitiPanelView.enableGraffiti(false);
        }

        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.setCanTouch(true);
        }

        if (mGraffitiBtn != null) {
            mGraffitiBtn.setSelected(false);
        }

        mOperationLayout.setBackgroundColor(
                TUIMultimediaResourceUtils.getColor(R.color.multimedia_plugin_edit_function_view_background));
    }

    private void showOperationView(boolean show) {
        LiteavLog.i(TAG, show ? "show " : "hide" + " operation view");
        int visible = show ? View.VISIBLE : View.GONE;
        mReturnBackView.setVisibility(visible);
        mOperationLayout.setVisibility(visible);
        if (mGraffitiPanelView != null) {
            mGraffitiPanelView.showOperationView(show && mGraffitiPanelView.isEnableGraffiti());
        }
    }

    private void adjustVideoAreaLayout() {
        View videoAreaView = mRootView.findViewById(R.id.rl_video_area);
        Point screenSize = TUIMultimediaResourceUtils.getScreenSize(mContext);
        LiteavLog.i(TAG, "screen size = " + screenSize);
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) videoAreaView.getLayoutParams();
        layoutParams.width = screenSize.x;
        layoutParams.height = (int) (screenSize.x / mAspectRatio);
        layoutParams.topMargin = (screenSize.y - layoutParams.height) / 2;
        videoAreaView.setLayoutParams(layoutParams);
    }

    private void adjustFunctionButtonPosition() {
        int width = mFunctionButtonLayout.getWidth();
        int count = mFunctionButtonLayout.getChildCount();
        int viewWidth = count * TUIMultimediaResourceUtils.dip2px(mContext,COMMON_FUNCTION_ICON_SIZE_DP);
        int margin = (width - viewWidth) / (count + 1);
        for (int i = 0;i < count;i++) {
            View child = mFunctionButtonLayout.getChildAt(i);
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) child.getLayoutParams();
            layoutParams.setMarginStart(margin);
            layoutParams.setMarginEnd(0);
            child.setLayoutParams(layoutParams);
        }
    }

    private void initExternalParameters() {
        Bundle bundle = getArguments();
        if (bundle == null) {
            return;
        }
        mEditFilePath = bundle.getString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH, "");
        mAspectRatio = bundle.getFloat(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_RATIO, 9.0f / 16.0f);
        isRecordFile = bundle.getBoolean(TUIMultimediaConstants.PARAM_NAME_IS_RECODE_FILE, false);
        LiteavLog.i(TAG, "init external parameters mEditFilePath = " + mEditFilePath
                + " video quality = " + TUIMultimediaIConfig.getInstance().getVideoQuality()
                + ", video ratio = " + mAspectRatio);
    }
}