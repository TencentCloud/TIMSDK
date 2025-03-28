package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.DrawableCompat;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.BGMEditListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.BGMManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.BGMPanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.crop.PictureCropControlView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.crop.PictureCropControlView.PictureCropControlViewListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerViewGroup;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush.BrushControlView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush.BrushControlView.BrushMode;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.PicturePasterFloatLayerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.PicturePasterManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.PicturePasterPanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster.SubtitlePanelView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster.SubtitlePasterFloatLayerView;
import com.tencent.ugc.TXVideoEditConstants.TXPaster;
import com.tencent.ugc.TXVideoEditConstants.TXRect;
import java.util.LinkedList;
import java.util.List;

public class TUIMultiMediaEditCommonCtrlView extends RelativeLayout {

    private final static int COMMON_FUNCTION_ICON_SIZE_DP = 28;
    private final static int BGM_FUNCTION_ICON_MARGIN_DP = 34;

    private final String TAG = TUIMultiMediaEditCommonCtrlView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final EditType mEditType;
    private final Boolean mIsRecordFile;

    private ViewTreeObserver.OnGlobalLayoutListener mOnGlobalLayoutListener;
    private RelativeLayout mOperationLayout;
    private LinearLayout mFunctionButtonLayout;
    private ImageView mReturnBackView;
    private View mRootView;
    private FloatLayerViewGroup mFloatLayerViewGroup;
    private float mAspectRatio = 9.0f / 16.0f;
    private View mMediaView;

    private TUIMultimediaTransformLayout mPreviewContainer;
    private PictureCropControlView mPictureCropControlView;


    private BrushControlView mBrushControlView;
    private ImageButton mGraffitiBrushBtn;
    private ImageButton mMosaicBrushBtn;

    private PicturePasterPanelView mPicturePasterPanelView;
    private PicturePasterManager mPicturePasterManager;

    private SubtitlePanelView mSubtitlePanelView;

    private BGMPanelView mBGMPanelView;
    private BGMManager mBGMManager;
    private ImageButton mBGMBtn;
    private Rect mPreviewRect;

    private PictureCropListener mPictureCropListener;
    private BGMEditListener mVideoFragmentBgmEditListener;
    private CommonMediaEditListener mCommonMediaEditListener;

    private Bitmap mPicture;

    public enum EditType {
        VIDEO,
        PHOTO
    }

    public interface PictureCropListener {

        void onConfirmCrop(RectF rectF, int rotation);

        void onRotation(int rotation);

        void onStartCrop();

        void onCancelCrop();
    }

    public interface CommonMediaEditListener {

        void onGenerateMedia();

        void onCancelEdit();
    }

    private final OnClickListener mOnPreviewClickListener = new OnClickListener() {
        @Override
        public void onClick(View v) {
            if (mPictureCropControlView != null) {
                return;
            }

            if (mPicturePasterPanelView != null) {
                mPicturePasterPanelView.setVisibility(View.GONE);
            }

            if (mBGMPanelView != null) {
                mBGMPanelView.setVisibility(View.GONE);
            }

            if (mFloatLayerViewGroup != null) {
                mFloatLayerViewGroup.unSelectOperationView();
            }

            showOperationView(true);
        }
    };

    private final BGMEditListener mBgmEditListener = new BGMEditListener() {
        @Override
        public void onAddBGM(String bgmPath) {
            if (mVideoFragmentBgmEditListener != null) {
                mVideoFragmentBgmEditListener.onAddBGM(bgmPath);
            }
        }

        @Override
        public void onCutBGM(long startTime, long endTime) {
            if (mVideoFragmentBgmEditListener != null) {
                mVideoFragmentBgmEditListener.onCutBGM(startTime, endTime);
            }
        }

        @Override
        public void onMuteSourceAudio(boolean isMute) {
            if (mVideoFragmentBgmEditListener != null) {
                mVideoFragmentBgmEditListener.onMuteSourceAudio(isMute);
            }
        }

        @Override
        public void onMuteBGM(boolean isMute) {
            if (mVideoFragmentBgmEditListener != null) {
                mVideoFragmentBgmEditListener.onMuteBGM(isMute);
            }

            if (mBGMBtn != null) {
                mBGMBtn.setSelected(!isMute);
            }
        }
    };

    public TUIMultiMediaEditCommonCtrlView(Context context, EditType editType, boolean isRecordFile) {
        super(context);
        mContext = context;
        mEditType = editType;
        mIsRecordFile = isRecordFile;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initView();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        if (mPicturePasterManager != null) {
            mPicturePasterManager.uninit();
        }
        mRootView.getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);
        removeAllViews();
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
        if (!changed) {
            return;
        }

        adjustFunctionButtonLayout();
        adjustPreviewLayout();
    }

    public void initView() {
        mRootView = LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_common_view, this);
        
        mOperationLayout = mRootView.findViewById(R.id.operation_layout);
        mReturnBackView = mRootView.findViewById(R.id.edit_return_back);
        mPreviewContainer = mRootView.findViewById(R.id.rl_preview);
        mFunctionButtonLayout = mRootView.findViewById(R.id.function_button_layout);
        mPreviewContainer.enableTransform(mEditType == EditType.PHOTO);
        mPreviewContainer.setOnClickListener(mOnPreviewClickListener);

        mReturnBackView.setOnClickListener(view -> {
            if (mCommonMediaEditListener != null) {
                mCommonMediaEditListener.onCancelEdit();
            }
        });

        initSendBtn();
        initGraffitiBrushBtn();
        initMosaicBrushBtn();
        initPasterFunction();
        initSubtitleBtn();
        initBGMFunction();
        initCropFunction();

        adjustPreviewLayout();
        setMediaView(mMediaView);
        mOnGlobalLayoutListener = this::adjustFunctionButtonLayout;
        mRootView.getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    public void setMediaView(View view) {
        if (view == null) {
            return;
        }

        adjustPreviewLayout();
        if (mPreviewContainer != null) {
            RelativeLayout.LayoutParams layoutParams = new LayoutParams(mPreviewRect.width(), mPreviewRect.height());
            layoutParams.leftMargin = mPreviewRect.left;
            layoutParams.topMargin = mPreviewRect.top;
            mPreviewContainer.addView(view, 0, layoutParams);
        }
        mMediaView = view;
    }

    public void setMediaAspectRatio(float aspectRatio) {
        LiteavLog.i(TAG, "set media aspect ratio. aspect ratio:" + aspectRatio);
        mAspectRatio = aspectRatio;
        adjustPreviewLayout();
    }

    public void setPicture(Bitmap bitmap) {
        mPicture = bitmap;
        if (mBrushControlView != null) {
            mBrushControlView.setMosaicImage(bitmap);
        }
    }

    public void setBGMListener(BGMEditListener listener) {
        mVideoFragmentBgmEditListener = listener;
    }

    private void initSendBtn() {
        Button button = mRootView.findViewById(R.id.send_btn);
        button.setBackground(TUIMultimediaResourceUtils
                .getDrawable(mContext, R.drawable.multimedia_plugin_edit_send_button,
                        TUIMultimediaIConfig.getInstance().getThemeColor()));
        button.setGravity(Gravity.CENTER);
        if (mIsRecordFile) {
            button.setText(TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_send));
        } else {
            button.setText(TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_done));
        }

        button.setOnClickListener(view -> {
            showOperationView(false);
            if (mCommonMediaEditListener != null) {
                mCommonMediaEditListener.onGenerateMedia();
            }
        });
    }

    private void initGraffitiBrushBtn() {
        if (!isSupportEditGraffiti()) {
            return;
        }

        int[][] states = new int[][]{
                new int[]{android.R.attr.state_enabled, -android.R.attr.state_selected},
                new int[]{android.R.attr.state_enabled, android.R.attr.state_selected},
        };

        int[] colors = new int[]{
                Color.WHITE, TUIMultimediaIConfig.getInstance().getThemeColor()
        };

        mGraffitiBrushBtn = addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_graffiti, new ColorStateList(states, colors),
                v -> switchEnableBrush(BrushMode.GRAFFITI));
    }

    private void initMosaicBrushBtn() {
        if (!isSupportEditMosaic()) {
            return;
        }

        int[][] states = new int[][]{
                new int[]{android.R.attr.state_enabled, -android.R.attr.state_selected},
                new int[]{android.R.attr.state_enabled, android.R.attr.state_selected},
        };

        int[] colors = new int[]{
                Color.WHITE, TUIMultimediaIConfig.getInstance().getThemeColor()
        };

        mMosaicBrushBtn = addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_mosaic, new ColorStateList(states, colors),
                v -> switchEnableBrush(BrushMode.MOSAIC));
    }

    private void initPasterFunction() {
        if (!isSupportEditPaster()) {
            return;
        }
        addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_paster,
                null, v -> addPicturePaster());

        initPicturePasterSetManager();
    }

    private void initSubtitleBtn() {
        if (!isSupportEditSubtitle()) {
            return;
        }

        addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_subtitle, null, v -> addSubtitlePaster());
    }

    private void initBGMFunction() {
        if (!isSupportEditBGM()) {
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

    private void initCropFunction() {
        if (!isSupportEditCrop()) {
            return;
        }
        addFunctionButton(COMMON_FUNCTION_ICON_SIZE_DP, COMMON_FUNCTION_ICON_SIZE_DP,
                R.drawable.multimedia_plugin_edit_crop, null, v -> startCrop());
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

    private void addSubtitlePaster() {
        initFloatLayerViewGroup();

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
            mPreviewContainer.enableTransform(mEditType == EditType.PHOTO);
        });
        disableBrush();
        showOperationView(false);
        mPreviewContainer.enableTransform(false);
        mFloatLayerViewGroup.setCanTouch(false);
        mFloatLayerViewGroup.unSelectOperationView();
    }

    private void addPicturePaster() {
        initFloatLayerViewGroup();

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
            mPreviewContainer.enableTransform(mEditType == EditType.PHOTO);
        });
        disableBrush();
        showOperationView(false);
        mFloatLayerViewGroup.unSelectOperationView();
        mPreviewContainer.enableTransform(false);
    }

    private void addBGMPanel() {
        if (mBGMPanelView == null) {
            mBGMPanelView = new BGMPanelView(mContext, mBGMManager);
            RelativeLayout bgmPanelViewContainer = mRootView.findViewById(R.id.rl_bgm_panel_view_container);
            bgmPanelViewContainer.setVisibility(View.VISIBLE);
            bgmPanelViewContainer.addView(mBGMPanelView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
            mBGMPanelView.setBGMEditListener(mBgmEditListener);
        }
        mBGMPanelView.showBGMPanel();

        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.unSelectOperationView();
        }

        disableBrush();
        showOperationView(false);
    }

    private void initPicturePasterSetManager() {
        if (mPicturePasterManager != null) {
            return;
        }

        mPicturePasterManager = new PicturePasterManager(
                TUIMultimediaIConfig.getInstance().getPicturePasterConfigFilePath());
        mPicturePasterManager.init();
    }

    private void initFloatLayerViewGroup() {
        if (mFloatLayerViewGroup == null) {
            mFloatLayerViewGroup = new FloatLayerViewGroup(mContext);
            mPreviewContainer.addView(mFloatLayerViewGroup, 2);
        }
    }

    private void initBGMManager() {
        if (mBGMManager != null) {
            return;
        }

        mBGMManager = new BGMManager(TUIMultimediaIConfig.getInstance().getBGMConfigFilePath());
        mBGMManager.init();
    }

    private void switchEnableBrush(BrushMode brushMode) {
        boolean enableBrush =
                mBrushControlView == null || !mBrushControlView.isEnableDraw();

        if (!enableBrush && mBrushControlView != null) {
            enableBrush = (brushMode != mBrushControlView.getBrushMode());
        }

        if (enableBrush) {
            enableBrush(brushMode);
        } else {
            disableBrush();
        }

        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.unSelectOperationView();
        }
    }

    private void enableBrush(BrushMode brushMode) {
        if (mBrushControlView == null) {
            mBrushControlView = new BrushControlView(mContext,
                    mRootView.findViewById(R.id.rl_brush_tool_view_container));
            mPreviewContainer.addView(mBrushControlView.getBrushDrawView(), 1);
            mBrushControlView.tuiDataIsDrawing.observe(isDrawing -> showOperationView(!isDrawing));
            mBrushControlView.setMosaicImage(mPicture);
        }
        mBrushControlView.showToolView(true);
        mBrushControlView.enableDraw(true);
        mBrushControlView.setBrushMode(brushMode);
        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.setCanTouch(false);
        }

        mPreviewContainer.enableTransform(false);
        if (mGraffitiBrushBtn != null) {
            mGraffitiBrushBtn.setSelected(mBrushControlView.getBrushMode() == BrushMode.GRAFFITI);
        }

        if (mMosaicBrushBtn != null) {
            mMosaicBrushBtn.setSelected(mBrushControlView.getBrushMode() == BrushMode.MOSAIC);
        }

        mOperationLayout.setBackgroundColor(
                TUIMultimediaResourceUtils.getColor(R.color.multimedia_plugin_edit_function_button_view_background));
    }

    private void disableBrush() {
        if (mBrushControlView != null) {
            mBrushControlView.showToolView(false);
            mBrushControlView.enableDraw(false);
        }

        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.setCanTouch(true);
        }

        if (mGraffitiBrushBtn != null) {
            mGraffitiBrushBtn.setSelected(false);
        }

        if (mMosaicBrushBtn != null) {
            mMosaicBrushBtn.setSelected(false);
        }

        mPreviewContainer.enableTransform(mEditType == EditType.PHOTO);
        mOperationLayout.setBackgroundColor(
                TUIMultimediaResourceUtils.getColor(R.color.multimedia_plugin_edit_function_view_background));
    }

    public void setPictureCropListener(PictureCropListener pictureCropListener) {
        mPictureCropListener = pictureCropListener;
    }

    public void setCommonMediaEditListener(CommonMediaEditListener commonMediaEditListener) {
        mCommonMediaEditListener = commonMediaEditListener;
    }

    private void startCrop() {
        showOperationView(false);
        mPreviewContainer.reset();
        mPictureCropControlView = new PictureCropControlView(mContext, mPreviewContainer);
        ((RelativeLayout) mRootView).addView(mPictureCropControlView);
        mPictureCropControlView.layout(0, 0, mRootView.getWidth(), mRootView.getHeight());
        mPictureCropControlView.setCropMainViewListener(new PictureCropControlViewListener() {
            @Override
            public void onCancelCrop() {
                showOperationView(true);
                ((RelativeLayout) mRootView).removeView(mPictureCropControlView);
                mPictureCropControlView = null;

                if (mBrushControlView != null) {
                    mBrushControlView.showDrawView(true);
                }

                if (mFloatLayerViewGroup != null) {
                    mFloatLayerViewGroup.setVisibility(VISIBLE);
                }

                if (mPictureCropListener != null) {
                    mPictureCropListener.onCancelCrop();
                }

                mPreviewContainer.reset();
            }

            @Override
            public void onConfirmCrop(RectF rectF, int rotation) {
                if (mPictureCropListener != null) {
                    mPictureCropListener.onConfirmCrop(rectF, rotation);
                }

                showOperationView(true);

                ((RelativeLayout) mRootView).removeView(mPictureCropControlView);
                mPictureCropControlView = null;

                mPreviewContainer.reset();

                if (mFloatLayerViewGroup != null) {
                    mFloatLayerViewGroup.removeAllFloatLayerView();
                    mFloatLayerViewGroup.setVisibility(VISIBLE);
                }

                if (mBrushControlView != null) {
                    mBrushControlView.clean();
                    mBrushControlView.showDrawView(true);
                }
            }

            @Override
            public void onRotation(int rotation) {
                if (mPictureCropListener != null) {
                    mPictureCropListener.onRotation(rotation);
                }
            }
        });

        if (mPictureCropListener != null) {
            mPictureCropListener.onStartCrop();
        }

        if (mBrushControlView != null) {
            mBrushControlView.showDrawView(false);
            disableBrush();
        }

        if (mFloatLayerViewGroup != null) {
            mFloatLayerViewGroup.setVisibility(INVISIBLE);
        }
    }

    public List<TUIMultimediaPasterInfo> getPaster() {
        List<TUIMultimediaPasterInfo> pasterInfoList = mFloatLayerViewGroup == null ? new LinkedList<>() : mFloatLayerViewGroup.getAllPaster();
        TUIMultimediaPasterInfo paster = null;
        if (mBrushControlView != null) {
            paster = mBrushControlView.getPaster();
        }

        if (paster != null) {
            pasterInfoList.add(0, paster);
        }

        return pasterInfoList;
    }

    public List<TXPaster> getNormalizedPaster() {
        List<TUIMultimediaPasterInfo> pasterInfoList = getPaster();

        Rect previewLayout = mPreviewContainer.getContentRect();
        int mPreviewWidth = previewLayout != null ? previewLayout.width() : getWidth();
        int mPreviewHeight = previewLayout != null ? previewLayout.height() : getHeight();

        List<TXPaster> pasterList = new LinkedList<>();
        for (TUIMultimediaPasterInfo pasterInfo : pasterInfoList) {
            TXPaster txPaster = new TXPaster();
            txPaster.frame = new TXRect();
            txPaster.frame.x = pasterInfo.frame.x / mPreviewWidth;
            txPaster.frame.y = pasterInfo.frame.y / mPreviewHeight;
            txPaster.frame.width = pasterInfo.frame.width / mPreviewWidth;
            txPaster.pasterImage = pasterInfo.image;
            pasterList.add(txPaster);
        }
        return pasterList;
    }

    public void showOperationView(boolean show) {
        int visible = show ? View.VISIBLE : View.GONE;
        mReturnBackView.setVisibility(visible);
        mOperationLayout.setVisibility(visible);
        if (mBrushControlView != null) {
            mBrushControlView.showToolView(show && mBrushControlView.isEnableDraw());
        }
        mPreviewContainer.enableTransform(mEditType == EditType.PHOTO);
    }

    private void adjustPreviewLayout() {
        if (mPreviewContainer == null) {
            return;
        }

        int previewContainerWidth = mPreviewContainer.getWidth();
        int previewContainerHeight = mPreviewContainer.getHeight();

        if (previewContainerWidth == 0 || previewContainerHeight == 0) {
            Point screenSize = TUIMultimediaResourceUtils.getScreenSize(mContext);
            previewContainerWidth = screenSize.x;
            previewContainerHeight = screenSize.y;
        }

        int previewHeight = (int) (previewContainerWidth / mAspectRatio);
        int previewTop = (previewContainerHeight - previewHeight) / 2;
        Rect previewRect = new Rect(0, previewTop, previewContainerWidth, previewTop + previewHeight);

        if (previewRect.equals(mPreviewRect)) {
            return;
        }
        mPreviewRect = previewRect;
        mPreviewContainer.initContentLayout(mPreviewRect);
    }

    private void adjustFunctionButtonLayout() {
        int width = mFunctionButtonLayout.getWidth();
        int count = mFunctionButtonLayout.getChildCount();
        int viewWidth = count * TUIMultimediaResourceUtils.dip2px(mContext, COMMON_FUNCTION_ICON_SIZE_DP);
        int margin = (width - viewWidth) / (count + 1);
        for (int i = 0; i < count; i++) {
            View child = mFunctionButtonLayout.getChildAt(i);
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) child.getLayoutParams();
            layoutParams.setMarginStart(margin);
            layoutParams.setMarginEnd(0);
            child.setLayoutParams(layoutParams);
        }
    }

    public boolean isSupportEditGraffiti() {
        return mEditType == EditType.VIDEO ? TUIMultimediaIConfig.getInstance().isSupportVideoEditGraffiti()
                : TUIMultimediaIConfig.getInstance().isSupportPictureEditGraffiti();
    }

    public boolean isSupportEditMosaic() {
        return mEditType == EditType.PHOTO && TUIMultimediaIConfig.getInstance().isSupportPictureEditMosaic();
    }

    public boolean isSupportEditPaster() {
        return mEditType == EditType.VIDEO ? TUIMultimediaIConfig.getInstance().isSupportVideoEditPaster()
                : TUIMultimediaIConfig.getInstance().isSupportPictureEditPaster();
    }

    public boolean isSupportEditSubtitle() {
        return mEditType == EditType.VIDEO ? TUIMultimediaIConfig.getInstance().isSupportVideoEditSubtitle()
                : TUIMultimediaIConfig.getInstance().isSupportPictureEditSubtitle();
    }

    public boolean isSupportEditBGM() {
        return mEditType == EditType.VIDEO && TUIMultimediaIConfig.getInstance().isSupportVideoEditBGM();
    }

    public boolean isSupportEditCrop() {
        return mEditType == EditType.PHOTO && TUIMultimediaIConfig.getInstance().isSupportPictureEditCrop();
    }
}