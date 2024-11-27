package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.beauty;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener;
import com.google.android.material.tabs.TabLayout.Tab;
import com.google.android.material.tabs.TabLayoutMediator;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInnerType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.RecordInfo;

@SuppressLint("ViewConstructor")
public class BeautyPanelView extends RelativeLayout {

    private final String TAG = BeautyPanelView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaRecordCore mRecordCore;
    private final BeautyInfo mBeautyInfo;
    private final RecordInfo mRecordInfo;
    private final SeekBar.OnSeekBarChangeListener mSeekBarChangeListener = new OnSeekBarChangeListener() {
        @Override
        public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            int beautyLevel = progress * 10 / seekBar.getMax();
            BeautyItem beautyItem = mBeautyInfo.tuiDataSelectedBeautyItem.get();
            if (beautyItem != null) {
                beautyItem.setLevel(beautyLevel);
                setBeauty(beautyItem);
            }
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
        }
    };
    private final OnTabSelectedListener onTabSelectedListener = new OnTabSelectedListener() {
        @Override
        public void onTabSelected(Tab tab) {
            changeTabSelectedStatus(tab, true);
            BeautyType beautyType = mBeautyInfo.getBeautyType(tab.getPosition());
            if (beautyType == null) {
                return;
            }
            mBeautyInfo.setSelectedItemIndex(tab.getPosition(), beautyType.getSelectedItemIndex());
        }

        @Override
        public void onTabUnselected(Tab tab) {
            changeTabSelectedStatus(tab, false);
        }

        @Override
        public void onTabReselected(Tab tab) {
        }
    };
    private TabLayout mBeautyTypeTabView;
    private SeekBar mStrengthSettingSeekBar;
    private View mLayoutStrengthSetting;
    TUIMultimediaDataObserver<BeautyItem> mOnSelectedBeautyItemChanged = beautyItem -> {
        updateBeautyTab(beautyItem);
        updateSeekBar(beautyItem);
        setBeauty(beautyItem);
    };

    public BeautyPanelView(Context context, TUIMultimediaRecordCore recordCore, RecordInfo recordInfo) {
        super(context);
        mContext = context;
        mRecordCore = recordCore;
        mRecordInfo = recordInfo;
        mBeautyInfo = recordInfo.beautyInfo;
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        mRecordInfo.tuiDataShowBeautyView.set(visibility == VISIBLE);
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        mBeautyInfo.tuiDataSelectedBeautyItem.observe(mOnSelectedBeautyItemChanged);
        initView();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        mStrengthSettingSeekBar.setOnSeekBarChangeListener(null);
        mBeautyTypeTabView.removeOnTabSelectedListener(onTabSelectedListener);
        mBeautyInfo.tuiDataSelectedBeautyItem.removeObserver(mOnSelectedBeautyItemChanged);
        removeAllViews();
        super.onDetachedFromWindow();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_beauty_panel_view, this);
        initBeautySettingView();
    }

    private void initBeautySettingView() {
        mStrengthSettingSeekBar = findViewById(R.id.beauty_strength_seek_bar);
        mStrengthSettingSeekBar.setOnSeekBarChangeListener(mSeekBarChangeListener);
        mLayoutStrengthSetting = findViewById(R.id.rl_beauty_strength_setting);

        ViewPager2 beautyPager = findViewById(R.id.record_view_pager);
        BeautyTypeAdapter adapter = new BeautyTypeAdapter(mContext, mBeautyInfo);
        beautyPager.setAdapter(adapter);
        beautyPager.setUserInputEnabled(false);

        mBeautyTypeTabView = findViewById(R.id.beauty_type_tab_view);
        mBeautyTypeTabView.addOnTabSelectedListener(onTabSelectedListener);
        mBeautyTypeTabView.setTabMode(TabLayout.MODE_SCROLLABLE);
        new TabLayoutMediator(mBeautyTypeTabView, beautyPager, this::setTabText).attach();
    }

    private void setTabText(@NonNull Tab tab, int position) {
        BeautyType beautyType = mBeautyInfo.getBeautyType(position);
        TextView customTextView = new TextView(getContext());
        customTextView.setGravity(Gravity.CENTER);
        String text = beautyType != null ? beautyType.getName() + "   " : "";
        customTextView.setText(text);
        customTextView.setMaxLines(1);
        customTextView.setTextColor(
                TUIMultimediaResourceUtils.getResources().getColor(R.color.multimedia_plugin_record_beauty_type_text_color_normal));

        float textSize = TUIMultimediaResourceUtils.getResources().getDimension(R.dimen.multimedia_plugin_common_tab_text_size);
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

        int textColorResourceId = R.color.multimedia_plugin_record_beauty_type_text_color_normal;
        int textColorFontStyle = Typeface.NORMAL;
        if (isSelected) {
            textColorResourceId = R.color.multimedia_plugin_record_beauty_type_text_color_selected;
            textColorFontStyle = Typeface.BOLD;
        }

        tabTextView.setTextColor(
                TUIMultimediaResourceUtils.getResources().getColor(textColorResourceId));
        String fontName = TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_common_font);
        tabTextView.setTypeface(Typeface.create(fontName, textColorFontStyle));
    }

    private void updateBeautyTab(BeautyItem beautyItem) {
        if (beautyItem == null) {
            return;
        }

        int beautyTypeIndex = mBeautyInfo.getItemTypeIndex(beautyItem);
        if (mBeautyTypeTabView.getSelectedTabPosition() == beautyTypeIndex) {
            return;
        }

        Tab tab = mBeautyTypeTabView.getTabAt(beautyTypeIndex);
        if (tab != null) {
            tab.select();
        }
    }

    private void updateSeekBar(BeautyItem beautyItem) {
        if (beautyItem == null) {
            return;
        }

        int level = beautyItem.getLevel();
        if (level < 0) {
            mLayoutStrengthSetting.setVisibility(INVISIBLE);
        } else {
            mLayoutStrengthSetting.setVisibility(VISIBLE);
            mStrengthSettingSeekBar.setProgress(level * mStrengthSettingSeekBar.getMax() / 10);
        }

    }

    private void setBeauty(BeautyItem beautyItem) {
        if (beautyItem == null) {
            return;
        }

        BeautyInnerType beautyType = beautyItem.getInnerType();
        int level = beautyItem.getLevel();
        LiteavLog.i(TAG, "set Beauty. beautyType " + beautyType
                + " beautyName " + beautyItem.getName() + " level " + level);
        switch (beautyType) {
            case BEAUTY_SMOOTH:
                mRecordCore.setBeautyStyleAndLevel(0, level);
                break;
            case BEAUTY_NATURAL:
                mRecordCore.setBeautyStyleAndLevel(1, level);
                break;
            case BEAUTY_PITU:
                mRecordCore.setBeautyStyleAndLevel(2, level);
                break;
            case BEAUTY_WHITE:
                mRecordCore.setWhitenessLevel(level);
                break;
            case BEAUTY_RUDDY:
                mRecordCore.setRuddyLevel(level);
                break;
            case BEAUTY_FILTER:
                mRecordCore.setFilterAndStrength(beautyItem.getFilterBitmap(), level);
                break;
            case BEAUTY_NONE:
                mRecordCore.setWhitenessLevel(0);
                mRecordCore.setRuddyLevel(0);
                mRecordCore.setBeautyStyleAndLevel(1, 0);
                mRecordCore.setBeautyStyleAndLevel(2, 0);
                mRecordCore.setBeautyStyleAndLevel(3, 0);
                break;
        }
    }
}
