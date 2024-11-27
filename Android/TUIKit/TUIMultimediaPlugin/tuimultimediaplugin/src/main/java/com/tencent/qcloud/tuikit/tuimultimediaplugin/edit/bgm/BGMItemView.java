package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMItem;

@SuppressLint("ViewConstructor")
public class BGMItemView extends RelativeLayout {

    private final String TAG = BGMItemView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;

    private TextView mBGMNameTextView;
    private TextView mBGMAuthorTextView;
    private TextView mBGMDurationTextView;
    private BGMSpectrumView mSpectrumView;
    private BGMItem mBgmItem;

    public BGMItemView(Context context) {
        super(context);
        mContext = context;
    }

    public void bindBGMItem(@NonNull BGMItem bgmItem) {
        mBgmItem = bgmItem;
        initData();
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
        mSpectrumView.stop();
        removeAllViews();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_bgm_item_view, this, true);

        mBGMNameTextView = findViewById(R.id.bgm_name);
        mBGMAuthorTextView = findViewById(R.id.bgm_author_name);
        mBGMDurationTextView = findViewById(R.id.bgm_duration);
        mSpectrumView = findViewById(R.id.bgm_spectrum_view);
        initData();
        setViewStatus();
    }

    private void initData() {
        if (!isAttachedToWindow()) {
            return;
        }

        String bgmName = mBgmItem.getBgmName();
        if (bgmName != null) {
            mBGMNameTextView.setText(bgmName);
        }

        String bgmAuthorName = mBgmItem.getBGMAuthorName();
        if (bgmAuthorName != null && !bgmAuthorName.isEmpty()) {
            mBGMAuthorTextView.setText(bgmAuthorName);
        }

        TUIMultimediaData<Long> tuiDataBGMDuration = new TUIMultimediaData<>(0L);
        tuiDataBGMDuration.observe(
                duration -> mBGMDurationTextView.setText(TUIMultimediaResourceUtils.secondsToTimeString(duration)));
        mBgmItem.getBGMDuration(tuiDataBGMDuration);
    }

    @Override
    public void setSelected(boolean selected) {
        super.setSelected(selected);
        setViewStatus();
    }

    @Override
    public void setEnabled(boolean enabled) {
        super.setEnabled(enabled);
        setViewStatus();
    }

    private void setViewStatus() {
        if (!isAttachedToWindow()) {
            return;
        }

        boolean isSelected = isSelected();
        boolean isEnable = isEnabled();

        if (isSelected) {
            mSpectrumView.setVisibility(VISIBLE);
            mSpectrumView.setEnabled(isEnable);
        } else {
            mSpectrumView.setVisibility(GONE);
            mSpectrumView.stop();
        }

        @ColorInt int bgmNameTextColor = TUIMultimediaResourceUtils.getColor(R.color.multimedia_plugin_bgm_item_name_text_color_normal);
        if (isSelected && isEnable) {
            bgmNameTextColor = TUIMultimediaIConfig.getInstance().getThemeColor();
        }
        mBGMNameTextView.setTextColor(bgmNameTextColor);
    }
}
