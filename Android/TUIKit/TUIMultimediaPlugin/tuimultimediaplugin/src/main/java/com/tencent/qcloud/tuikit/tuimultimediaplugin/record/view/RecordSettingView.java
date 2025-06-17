package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.beauty.BeautyFilterScrollView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.beauty.BeautyPanelView;

public class RecordSettingView extends RelativeLayout {

    private static final int SCROLL_FILTER_RIGHT_LEFT_MARGIN_SP = 15;
    private static final int SETTING_ITEM_VIEW_BOTTOM_MARGIN_SP = 24;
    private final String TAG = RecordSettingView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaRecordCore mRecordCore;

    private RecordInfo mRecordInfo;
    private BeautyPanelView mBeautyPanelView;
    private BeautyFilterScrollView mBeautyFilterScrollView;
    private SettingItemViewHolder mSettingItemTorch;
    private RecordAspectView mAspectView;
    private LinearLayout mLayoutSetting;
    private RelativeLayout mBeautyPanelViewContainer;
    private RelativeLayout mScrollFilterViewContainer;

    private final TUIMultimediaDataObserver<Boolean> mFlashStatusObserver = isOnAndFront -> {
        if (mSettingItemTorch == null) {
            return;
        }

        LiteavLog.i(TAG,"is front camera:" + mRecordInfo.tuiDataIsFontCamera.get()
                + " is flash on: " + mRecordInfo.tuiDataIsFlashOn.get());

        if (mRecordInfo.tuiDataIsFontCamera.get()) {
            mSettingItemTorch.setIconRes(R.drawable.multimedia_plugin_record_torch_close_disable);
            mSettingItemTorch.setClickable(false);
            return;
        }

        int resId = mRecordInfo.tuiDataIsFlashOn.get() ? R.drawable.multimedia_plugin_record_torch_open : R.drawable.multimedia_plugin_record_torch_close;
        mSettingItemTorch.setIconRes(resId);
        mSettingItemTorch.setClickable(true);
    };

    public RecordSettingView(@NonNull Context context, TUIMultimediaRecordCore recordCore, RecordInfo recordInfo) {
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
        removeAllViews();
        removeObserver();
    }

    @Override
    public void removeAllViews() {
        if (mBeautyPanelViewContainer != null) {
            mBeautyPanelViewContainer.removeAllViews();
        }

        if (mScrollFilterViewContainer != null) {
            mScrollFilterViewContainer.removeAllViews();
        }

        mLayoutSetting.removeAllViews();
        super.removeAllViews();
    }

    public void initView() {
        View rootView = LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_setting_view, this, true);
        rootView.setOnClickListener(v -> {
            if (mBeautyPanelView != null) {
                mBeautyPanelView.setVisibility(GONE);
            }
        });
        mLayoutSetting = findViewById(R.id.layout_setting_item);

        initTorchView();
        initBeautyView();
        initScrollBeautyFilterView();
        initAspectView();
    }

    private void initTorchView() {
        if (!TUIMultimediaIConfig.getInstance().isSupportRecordTorch()) {
            return;
        }

        mSettingItemTorch = addSettingItem(R.drawable.multimedia_plugin_record_torch_close, R.string.multimedia_plugin_torch);
        mSettingItemTorch.setOnClickListener(v -> {
            boolean isFlashOn = mRecordInfo.tuiDataIsFlashOn.get();
            mRecordCore.toggleTorch(!isFlashOn);
        });
    }

    private void initBeautyView() {
        if (!TUIMultimediaIConfig.getInstance().isSupportRecordBeauty()) {
            return;
        }

        SettingItemViewHolder mBeautyItemTorch = addSettingItem(R.drawable.multimedia_plugin_record_beauty, R.string.multimedia_plugin_beauty);
        mBeautyItemTorch.setOnClickListener(v ->
                mBeautyPanelView.setVisibility(!mRecordInfo.tuiDataShowBeautyView.get() ? VISIBLE : INVISIBLE));

        if (mRecordInfo.beautyInfo == null) {
            mRecordInfo.beautyInfo = BeautyInfo.CreateDefaultBeautyInfo();
        }

        if (mBeautyPanelView == null) {
            mBeautyPanelView = new BeautyPanelView(getContext(), mRecordCore, mRecordInfo);
            mBeautyPanelView.setVisibility(INVISIBLE);
        }

        mBeautyPanelViewContainer = findViewById(R.id.rl_beauty_panel_view_container);
        mBeautyPanelViewContainer.removeAllViews();
        mBeautyPanelViewContainer
                .addView(mBeautyPanelView, new RelativeLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT));
    }

    private void initScrollBeautyFilterView() {
        if (!TUIMultimediaIConfig.getInstance().isSupportRecordScrollFilter()) {
            return;
        }

        if (mRecordInfo.beautyInfo == null) {
            mRecordInfo.beautyInfo = BeautyInfo.CreateDefaultBeautyInfo();
        }

        if (mBeautyFilterScrollView == null) {
            mBeautyFilterScrollView = new BeautyFilterScrollView(mContext, mRecordCore, mRecordInfo.beautyInfo);
        }

        mScrollFilterViewContainer = findViewById(R.id.rl_beauty_filter_scroll_view_container);
        mScrollFilterViewContainer.removeAllViews();
        RelativeLayout.LayoutParams layoutParams =
                new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT);
        layoutParams.leftMargin = (int) TUIMultimediaResourceUtils.spToPx(mContext, SCROLL_FILTER_RIGHT_LEFT_MARGIN_SP);
        layoutParams.rightMargin = (int) TUIMultimediaResourceUtils.spToPx(mContext, SCROLL_FILTER_RIGHT_LEFT_MARGIN_SP);
        mScrollFilterViewContainer.addView(mBeautyFilterScrollView, layoutParams);
        mBeautyFilterScrollView.setOnClickListener(v -> {
            if (mBeautyPanelView != null) {
                mBeautyPanelView.setVisibility(GONE);
            }
        });
    }

    private void initAspectView() {
        if (!TUIMultimediaIConfig.getInstance().isSupportRecordAspect()) {
            return;
        }

        if (mAspectView == null) {
            mAspectView = new RecordAspectView(getContext(), mRecordCore, mRecordInfo);
        }

        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(WRAP_CONTENT, WRAP_CONTENT);
        layoutParams.bottomMargin = TUIMultimediaResourceUtils.dip2px(mContext, SETTING_ITEM_VIEW_BOTTOM_MARGIN_SP);
        layoutParams.gravity = Gravity.CENTER;
        mLayoutSetting.addView(mAspectView,layoutParams);
    }

    private SettingItemViewHolder addSettingItem(int iconResId, int titleResId) {
        View view = LayoutInflater.from(mContext)
                .inflate(R.layout.multimedia_plugin_record_setting_item_view, this, false);
        SettingItemViewHolder settingItemViewHolder = new SettingItemViewHolder(view);
        settingItemViewHolder.setIconRes(iconResId);
        settingItemViewHolder.setTitle(titleResId);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT);
        layoutParams.bottomMargin = TUIMultimediaResourceUtils.dip2px(mContext, SETTING_ITEM_VIEW_BOTTOM_MARGIN_SP);
        layoutParams.gravity = Gravity.CENTER;
        mLayoutSetting.addView(view,layoutParams);
        return settingItemViewHolder;
    }

    private void addObserver() {
        mRecordInfo.tuiDataIsFontCamera.observe(mFlashStatusObserver);
        mRecordInfo.tuiDataIsFlashOn.observe(mFlashStatusObserver);
    }

    private void removeObserver() {
        mRecordInfo.tuiDataIsFontCamera.removeObserver(mFlashStatusObserver);
        mRecordInfo.tuiDataIsFlashOn.removeObserver(mFlashStatusObserver);
    }

    static class SettingItemViewHolder{
        private final View mRootView;
        private final ImageView mIcon;
        private final TextView mTitle;

        public SettingItemViewHolder(View rootView) {
            mRootView = rootView;
            mIcon = mRootView.findViewById(R.id.icon);
            mTitle = mRootView.findViewById(R.id.title);
        }

        public void setIconRes(int iconResId) {
            mIcon.setBackgroundResource(iconResId);
        }

        public void setTitle(int titleResId) {
            mTitle.setText(TUIMultimediaResourceUtils.getString(titleResId));
        }

        public void setOnClickListener(OnClickListener onClickListener) {
            mRootView.setOnClickListener(onClickListener);
        }

        public void setClickable(boolean clickable) {
            mRootView.setClickable(clickable);
        }
    }
}
