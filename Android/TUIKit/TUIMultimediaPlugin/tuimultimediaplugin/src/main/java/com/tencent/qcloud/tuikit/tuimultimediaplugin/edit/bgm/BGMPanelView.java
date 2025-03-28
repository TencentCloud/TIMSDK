package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.DrawableCompat;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener;
import com.google.android.material.tabs.TabLayout.Tab;
import com.google.android.material.tabs.TabLayoutMediator;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo.ItemPosition;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMType;

@SuppressLint("ViewConstructor")
public class BGMPanelView extends RelativeLayout {

    private final String TAG = BGMPanelView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final BGMInfo mBGMInfo;
    private final BGMManager mBGMManager;
    private final TUIMultimediaData<Boolean> mTuiDataBGMEnable = new TUIMultimediaData<>(null);
    private final TUIMultimediaData<ItemPosition> mTuiDataSelectedPosition = new TUIMultimediaData<>(null);

    private TabLayout mBGMTypeTabLayout;
    private BGMTypeAdapter mBGMTypeAdapter;
    private CheckBox mBGMEnableCheckBox;
    private ItemPosition mLastSelectedItemPosition;
    private BGMEnableListener mBgmEnableListener;
    private BGMEditListener mBGMEditListener;

    private final OnTabSelectedListener onTabSelectedListener = new OnTabSelectedListener() {
        @Override
        public void onTabSelected(Tab tab) {
            if (mBGMTypeAdapter != null) {
                mBGMTypeAdapter.setSelectedBGMItemView(mTuiDataSelectedPosition.get());
            }
            changeTabSelectedStatus(tab, true);
        }

        @Override
        public void onTabUnselected(Tab tab) {
            changeTabSelectedStatus(tab, false);
        }

        @Override
        public void onTabReselected(Tab tab) {
        }
    };

    public BGMPanelView(Context context, BGMManager bgmManager) {
        super(context);
        mContext = context;
        mBGMManager = bgmManager;
        mBGMInfo = mBGMManager.getBGMInfo();
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        addObserver();
        initView();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        removeObserver();
        super.onDetachedFromWindow();
    }

    public void setBGMEditListener(BGMEditListener bgmEditListener) {
        mBGMEditListener = bgmEditListener;
    }

    public void showBGMPanel() {
        setVisibility(View.VISIBLE);
        ItemPosition itemPosition = mTuiDataSelectedPosition.get();
        if (itemPosition == null) {
            return;
        }

        if (itemPosition.bgmTypeIndex != mBGMTypeTabLayout.getSelectedTabPosition()) {
            Tab tab = mBGMTypeTabLayout.getTabAt(itemPosition.bgmTypeIndex);
            if (tab != null) {
                tab.select();
                return;
            }
        }

        if (mBGMTypeAdapter != null) {
            mBGMTypeAdapter.setSelectedBGMItemView(itemPosition);
        }
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_bgm_panel_view, this, true);
        initBgmListView();
        intBGMEnableView();
    }

    private void intBGMEnableView() {
        mBGMEnableCheckBox = findViewById(R.id.bgm_enable);
        mBGMEnableCheckBox.setButtonDrawable(getCheckBoxButtonDrawable());
        mBGMEnableCheckBox.setEnabled(false);
        mBGMEnableCheckBox.setChecked(false);
        mBGMEnableCheckBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (mBGMEditListener != null) {
                mBGMEditListener.onMuteBGM(!isChecked);
            }
            mTuiDataBGMEnable.set(isChecked);
        });

        CheckBox sourceAudioEnableCheckBox = findViewById(R.id.source_sound_enable);
        sourceAudioEnableCheckBox.setOnCheckedChangeListener(
                (buttonView, isChecked) -> {
                    if (mBGMEditListener != null) {
                        mBGMEditListener.onMuteSourceAudio(!isChecked);
                    }
                });
        sourceAudioEnableCheckBox.setButtonDrawable(getCheckBoxButtonDrawable());
    }

    private Drawable getCheckBoxButtonDrawable() {
        StateListDrawable stateListDrawable = new StateListDrawable();

        Drawable selectedDrawable = ContextCompat
                .getDrawable(mContext, R.drawable.multimedia_plugin_edit_bgm_checkbox_selected);
        DrawableCompat.setTint(selectedDrawable, TUIMultimediaIConfig.getInstance().getThemeColor());

        Drawable unSelectedDrawable = ContextCompat
                .getDrawable(mContext, R.drawable.multimedia_plugin_edit_bgm_checkbox_unselected);
        DrawableCompat.setTint(unSelectedDrawable, TUIMultimediaIConfig.getInstance().getThemeColor());

        stateListDrawable.addState(new int[]{android.R.attr.state_checked}, selectedDrawable);
        stateListDrawable.addState(new int[]{-android.R.attr.state_checked}, unSelectedDrawable);
        return stateListDrawable;
    }

    private void initBgmListView() {
        ViewPager2 beautyPager = findViewById(R.id.bgm_panel_view_pager);
        mBGMTypeAdapter = new BGMTypeAdapter(mContext, mBGMInfo, mTuiDataSelectedPosition, mTuiDataBGMEnable);
        beautyPager.setAdapter(mBGMTypeAdapter);

        mBGMTypeTabLayout = findViewById(R.id.bgm_panel_tab_layout);
        mBGMTypeTabLayout.setTabMode(TabLayout.MODE_SCROLLABLE);
        mBGMTypeTabLayout.addOnTabSelectedListener(onTabSelectedListener);
        new TabLayoutMediator(mBGMTypeTabLayout, beautyPager, this::configTab).attach();
    }

    private void configTab(@NonNull Tab tab, int position) {
        if (mBGMInfo == null) {
            return;
        }

        BGMType typeInfo = mBGMInfo.getBGMType(position);
        String text = typeInfo != null ? typeInfo.getTypeName()
                : TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_bgm_type_name_default);

        TextView customTextView = new TextView(getContext());
        customTextView.setGravity(Gravity.CENTER);

        customTextView.setText(text);
        customTextView.setMaxLines(1);
        customTextView.setTextColor(
                TUIMultimediaResourceUtils.getResources()
                        .getColor(R.color.multimedia_plugin_bgm_type_text_color_normal));

        float textSize = TUIMultimediaResourceUtils.getResources()
                .getDimension(R.dimen.multimedia_plugin_common_tab_text_size);
        customTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, textSize);

        String fontName = TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_common_font);
        customTextView.setTypeface(Typeface.create(fontName, Typeface.NORMAL));
        tab.setCustomView(customTextView);
    }

    private void changeTabSelectedStatus(Tab tab, boolean isSelected) {
        TextView tabTextView = (TextView) tab.getCustomView();
        if (tabTextView == null) {
            return;
        }

        int textColorResourceId = R.color.multimedia_plugin_bgm_type_text_color_normal;
        int textColorFontStyle = Typeface.NORMAL;
        if (isSelected) {
            textColorResourceId = R.color.multimedia_plugin_bgm_type_text_color_selected;
            textColorFontStyle = Typeface.BOLD;
        }

        tabTextView.setTextColor(
                TUIMultimediaResourceUtils.getResources().getColor(textColorResourceId));
        String fontName = TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_common_font);
        tabTextView.setTypeface(Typeface.create(fontName, textColorFontStyle));
    }

    private void onBGMItemSelectedChanged(ItemPosition bgmItemPosition) {
        if (bgmItemPosition == mLastSelectedItemPosition) {
            return;
        }
        setBGM(mBGMInfo.getBGMItem(bgmItemPosition));
        if (mBGMEnableCheckBox != null) {
            mBGMEnableCheckBox.setChecked(true);
        }
        mTuiDataBGMEnable.set(true);
        mLastSelectedItemPosition = bgmItemPosition;
    }

    private void setBGM(BGMItem bgmItem) {
        if (bgmItem == null) {
            return;
        }
        mBGMEnableCheckBox.setEnabled(true);
        TUIMultimediaData<String> tuiDataBGMFilePath = new TUIMultimediaData<>("");
        tuiDataBGMFilePath.observe(path -> {
            if (mBGMEditListener != null) {
                mBGMEditListener.onAddBGM(path);
            }
        });
        bgmItem.getBGMFilePath(tuiDataBGMFilePath);

        long bgmStatTime = bgmItem.startTime > 0 ? bgmItem.startTime : 0;
        long bgmEndTime = bgmItem.endTime > bgmStatTime ? bgmItem.endTime : Integer.MAX_VALUE;
        if (mBGMEditListener != null) {
            mBGMEditListener.onCutBGM(bgmStatTime, bgmEndTime);
        }
    }

    private void addObserver() {
        mTuiDataSelectedPosition.observe(this::onBGMItemSelectedChanged);
        mTuiDataBGMEnable.observe(this::notifyBGMEnable);
    }

    private void removeObserver() {
        mBGMTypeTabLayout.removeOnTabSelectedListener(onTabSelectedListener);
        mTuiDataSelectedPosition.removeObserver(this::onBGMItemSelectedChanged);
        mTuiDataBGMEnable.removeObserver(this::notifyBGMEnable);
    }

    private void notifyBGMEnable(boolean enable) {
        if (mBgmEnableListener != null) {
            mBgmEnableListener.onBGMEnable(enable);
        }
    }

    public interface BGMEnableListener {

        void onBGMEnable(boolean enable);
    }
}