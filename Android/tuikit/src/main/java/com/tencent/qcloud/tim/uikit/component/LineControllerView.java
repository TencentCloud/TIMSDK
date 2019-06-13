package com.tencent.qcloud.tim.uikit.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

/**
 * 设置等页面条状控制或显示信息的控件
 */
public class LineControllerView extends LinearLayout {

    private String mName;
    private boolean mIsBottom;
    private String mContent;
    private boolean mIsJump;
    private boolean mIsSwitch;

    private TextView mNameText;
    private TextView mContentText;
    private ImageView mNavArrowView;
    private Switch mSwitchView;

    public LineControllerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.line_controller_view, this);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.LineControllerView, 0, 0);
        try {
            mName = ta.getString(R.styleable.LineControllerView_name);
            mContent = ta.getString(R.styleable.LineControllerView_subject);
            mIsBottom = ta.getBoolean(R.styleable.LineControllerView_isBottom, false);
            mIsJump = ta.getBoolean(R.styleable.LineControllerView_canNav, false);
            mIsSwitch = ta.getBoolean(R.styleable.LineControllerView_isSwitch, false);
            setUpView();
        } finally {
            ta.recycle();
        }
    }

    private void setUpView() {
        mNameText = findViewById(R.id.name);
        mNameText.setText(mName);
        mContentText = findViewById(R.id.content);
        mContentText.setText(mContent);
        View bottomLine = findViewById(R.id.bottomLine);
        bottomLine.setVisibility(mIsBottom ? VISIBLE : GONE);
        mNavArrowView = findViewById(R.id.rightArrow);
        mNavArrowView.setVisibility(mIsJump ? VISIBLE : GONE);
        RelativeLayout contentLayout = findViewById(R.id.contentText);
        contentLayout.setVisibility(mIsSwitch ? GONE : VISIBLE);
        mSwitchView = findViewById(R.id.btnSwitch);
        mSwitchView.setVisibility(mIsSwitch ? VISIBLE : GONE);
    }


    /**
     * 设置文字内容
     *
     * @param content 内容
     */
    public void setContent(String content) {
        this.mContent = content;
        mContentText.setText(content);
    }

    /**
     * 获取内容
     */
    public String getContent() {
        return mContentText.getText().toString();
    }

    public void setSingleLine(boolean singleLine) {
        mContentText.setSingleLine(singleLine);
    }

    /**
     * 设置是否可以跳转
     *
     * @param canNav 是否可以跳转
     */
    public void setCanNav(boolean canNav) {
        this.mIsJump = canNav;
        mNavArrowView.setVisibility(canNav ? VISIBLE : GONE);
        if (canNav) {
            ViewGroup.LayoutParams params = mContentText.getLayoutParams();
            params.width = ScreenUtil.getPxByDp(120);
            params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            mContentText.setLayoutParams(params);
            mContentText.setTextIsSelectable(false);
        } else {
            ViewGroup.LayoutParams params = mContentText.getLayoutParams();
            params.width = ViewGroup.LayoutParams.WRAP_CONTENT;
            params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            mContentText.setLayoutParams(params);
            mContentText.setTextIsSelectable(true);
        }
    }


    /**
     * 设置开关状态
     *
     * @param on 开关
     */
    public void setChecked(boolean on) {
        mSwitchView.setChecked(on);
    }

    public boolean isChecked() {
        return mSwitchView.isChecked();
    }

    /**
     * 设置开关监听
     *
     * @param listener 监听
     */
    public void setCheckListener(CompoundButton.OnCheckedChangeListener listener) {
        mSwitchView.setOnCheckedChangeListener(listener);
    }


}
