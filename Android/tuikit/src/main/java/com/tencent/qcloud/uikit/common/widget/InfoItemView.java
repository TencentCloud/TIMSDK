package com.tencent.qcloud.uikit.common.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;


public class InfoItemView extends LinearLayout {
    private TextView mLable, mValue;
    private ImageView mIcon;

    public InfoItemView(Context context) {
        super(context);
    }

    public InfoItemView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public InfoItemView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);

    }

    private void init(AttributeSet attrs) {
        inflate(getContext(), R.layout.layout_info_item, this);
        mLable = findViewById(R.id.info_item_lable);
        mValue = findViewById(R.id.info_item_value);
        mIcon = findViewById(R.id.info_item_icon);
        if (attrs != null) {
            TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.InfoItemView, 0, 0);
            int iconRes = a.getInt(R.styleable.InfoItemView_infoIcon, R.drawable.arrow_right);
            mIcon.setImageResource(iconRes);
            String label = a.getString(R.styleable.InfoItemView_infoLabel);
            mLable.setText(label);
            String value = a.getString(R.styleable.InfoItemView_infoValue);
            mValue.setText(value);
            int iconVisible = a.getInt(R.styleable.InfoItemView_iconVisible, VISIBLE);
            mIcon.setVisibility(iconVisible);
            mValue.setText(value);
            a.recycle();//回收内存
        }

    }

    public void setLable(String lable) {
        mLable.setText(lable);
    }

    public void setValue(String value) {
        mValue.setText(value);
    }

    public void setIcon(Drawable icon) {
        mIcon.setImageDrawable(icon);
    }

    public void setIconVisible(int visibility) {
        mIcon.setVisibility(visibility);
    }
}
