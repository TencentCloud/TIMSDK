package com.tencent.qcloud.tim.uikit.component;

import android.content.Context;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.ITitleBarLayout;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;


public class TitleBarLayout extends LinearLayout implements ITitleBarLayout {

    private LinearLayout mLeftGroup;
    private LinearLayout mRightGroup;
    private TextView mLeftTitle;
    private TextView mCenterTitle;
    private TextView mRightTitle;
    private ImageView mLeftIcon;
    private ImageView mRightIcon;
    private RelativeLayout mTitleLayout;


    public TitleBarLayout(Context context) {
        super(context);
        init();
    }

    public TitleBarLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public TitleBarLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.title_bar_layout, this);
        mTitleLayout = findViewById(R.id.page_title_layout);
        mLeftGroup = findViewById(R.id.page_title_left_group);
        mRightGroup = findViewById(R.id.page_title_right_group);
        mLeftTitle = findViewById(R.id.page_title_left_text);
        mRightTitle = findViewById(R.id.page_title_right_text);
        mCenterTitle = findViewById(R.id.page_title);
        mLeftIcon = findViewById(R.id.page_title_left_icon);
        mRightIcon = findViewById(R.id.page_title_right_icon);
        LinearLayout.LayoutParams  params = (LinearLayout.LayoutParams) mTitleLayout.getLayoutParams();
        params.height = ScreenUtil.getPxByDp(45);
        mTitleLayout.setLayoutParams(params);
        setBackgroundColor(getResources().getColor(R.color.main_bg_color));
    }

    @Override
    public void setLeftIcon(int resId) {
        mLeftIcon.setImageResource(resId);
    }

    @Override
    public void setRightIcon(int resId) {
        mRightIcon.setImageResource(resId);
    }

    @Override
    public void setOnLeftClickListener(OnClickListener listener) {
        mLeftGroup.setOnClickListener(listener);
    }

    @Override
    public void setOnRightClickListener(OnClickListener listener) {
        mRightGroup.setOnClickListener(listener);
    }

    @Override
    public void setTitle(String title, POSITION position) {
        switch (position) {
            case LEFT:
                mLeftTitle.setText(title);
                break;
            case RIGHT:
                mRightTitle.setText(title);
                break;
            case MIDDLE:
                mCenterTitle.setText(title);
                break;
        }
    }

    @Override
    public LinearLayout getLeftGroup() {
        return mLeftGroup;
    }

    @Override
    public LinearLayout getRightGroup() {
        return mRightGroup;
    }

    @Override
    public ImageView getLeftIcon() {
        return mLeftIcon;
    }

    @Override
    public ImageView getRightIcon() {
        return mRightIcon;
    }

    @Override
    public TextView getLeftTitle() {
        return mCenterTitle;
    }

    @Override
    public TextView getMiddleTitle() {
        return null;
    }

    @Override
    public TextView getRightTitle() {
        return mRightTitle;
    }
}
