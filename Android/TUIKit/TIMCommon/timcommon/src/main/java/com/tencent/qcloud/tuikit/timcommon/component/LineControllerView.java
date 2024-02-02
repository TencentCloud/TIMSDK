package com.tencent.qcloud.tuikit.timcommon.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import androidx.core.graphics.drawable.DrawableCompat;

import com.tencent.qcloud.tuikit.timcommon.R;

/**
 * Custom LineControllerView
 */
public class LineControllerView extends RelativeLayout {
    private String mName;
    private boolean mIsBottom;
    private boolean mIsTop;
    private String mContent;
    private boolean mIsJump;
    private boolean mIsSwitch;

    protected TextView mNameText;
    protected TextView mContentText;
    private ImageView mNavArrowView;
    protected Switch mSwitchView;
    protected View bottomLine;
    private View mMask;
    private View container;

    public LineControllerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.timcommon_line_controller_view, this);
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
        bottomLine = findViewById(R.id.bottom_line);
        View topLine = findViewById(R.id.top_line);
        bottomLine.setVisibility(mIsBottom ? VISIBLE : GONE);
        topLine.setVisibility(mIsTop ? VISIBLE : GONE);
        mNavArrowView = findViewById(R.id.rightArrow);
        Drawable arrowDrawable = mNavArrowView.getDrawable();
        if (arrowDrawable != null) {
            DrawableCompat.setAutoMirrored(arrowDrawable, true);
        }
        mNavArrowView.setVisibility(mIsJump ? VISIBLE : GONE);
        ViewGroup contentLayout = findViewById(R.id.content_view);
        contentLayout.setVisibility(mIsSwitch ? GONE : VISIBLE);
        mSwitchView = findViewById(R.id.btnSwitch);
        mSwitchView.setVisibility(mIsSwitch ? VISIBLE : GONE);
        mMask = findViewById(R.id.disable_mask);
        container = findViewById(R.id.view_container);
    }

    public void setBackground(Drawable drawable) {
        super.setBackground(drawable);
        container.setBackground(drawable);
    }

    public String getContent() {
        return mContentText.getText().toString();
    }

    public void setContent(String content) {
        this.mContent = content;
        mContentText.setText(content);
        mContentText.requestLayout();
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
            mContentText.setTextIsSelectable(false);
        } else {
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
            mNameText.setEnabled(false);
            mContentText.setEnabled(false);
            mNameText.setTextColor(getResources().getColor(R.color.text_color_gray));
            mContentText.setTextColor(getResources().getColor(R.color.text_color_gray));
            mSwitchView.setEnabled(false);
        } else {
            mNameText.setEnabled(true);
            mContentText.setEnabled(true);
            mNameText.setTextColor(getResources().getColor(R.color.core_line_controller_title_color));
            mContentText.setTextColor(getResources().getColor(R.color.core_line_controller_content_color));
            mSwitchView.setEnabled(true);
        }
    }
}
