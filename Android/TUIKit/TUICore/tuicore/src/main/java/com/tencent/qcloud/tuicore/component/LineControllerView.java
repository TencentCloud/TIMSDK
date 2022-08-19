package com.tencent.qcloud.tuicore.component;

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

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

/**
 * Custom LineControllerView
 */
public class LineControllerView extends LinearLayout {

    private String mName;
    private boolean mIsBottom;
    private boolean mIsTop;
    private String mContent;
    private boolean mIsJump;
    private boolean mIsSwitch;

    private TextView mNameText;
    private TextView mContentText;
    private ImageView mNavArrowView;
    private Switch mSwitchView;
    private View mMask;

    public LineControllerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.line_controller_view, this);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.LineControllerView, 0, 0);
        try {
            mName = ta.getString(R.styleable.LineControllerView_name);
            mContent = ta.getString(R.styleable.LineControllerView_subject);
            mIsBottom = ta.getBoolean(R.styleable.LineControllerView_isBottom, false);
            mIsTop = ta.getBoolean(R.styleable.LineControllerView_isTop, false);
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
        View bottomLine = findViewById(R.id.bottom_line);
        View topLine = findViewById(R.id.top_line);
        bottomLine.setVisibility(mIsBottom ? VISIBLE : GONE);
        topLine.setVisibility(mIsTop ? VISIBLE : GONE);
        mNavArrowView = findViewById(R.id.rightArrow);
        mNavArrowView.setVisibility(mIsJump ? VISIBLE : GONE);
        RelativeLayout contentLayout = findViewById(R.id.contentText);
        contentLayout.setVisibility(mIsSwitch ? GONE : VISIBLE);
        mSwitchView = findViewById(R.id.btnSwitch);
        mSwitchView.setVisibility(mIsSwitch ? VISIBLE : GONE);
        mMask = findViewById(R.id.disable_mask);
    }

    public String getContent() {
        return mContentText.getText().toString();
    }

    public void setContent(String content) {
        this.mContent = content;
        mContentText.setText(content);
    }

    public void setSingleLine(boolean singleLine) {
        mContentText.setSingleLine(singleLine);
    }

    /**
     * Set whether to jump
     *
     * @param canNav
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

    public boolean isChecked() {
        return mSwitchView.isChecked();
    }

    public void setChecked(boolean on) {
        mSwitchView.setChecked(on);
    }

    public void setCheckListener(CompoundButton.OnCheckedChangeListener listener) {
        mSwitchView.setOnCheckedChangeListener(listener);
    }

    public void setMask(boolean enableMask) {
        if (enableMask) {
            mMask.setVisibility(View.VISIBLE);
            mSwitchView.setEnabled(false);
        } else {
            mMask.setVisibility(View.GONE);
            mSwitchView.setEnabled(true);
        }
    }

}
