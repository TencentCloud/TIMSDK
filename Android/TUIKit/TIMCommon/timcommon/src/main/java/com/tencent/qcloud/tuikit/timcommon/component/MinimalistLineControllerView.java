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
import android.widget.TextView;
import androidx.appcompat.widget.SwitchCompat;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;

/**
 * Custom LineControllerView
 */
public class MinimalistLineControllerView extends RelativeLayout {
    private String mName;
    private boolean mIsBottom;
    private boolean mIsTop;
    private String mContent;
    private boolean mIsJump;
    private boolean mIsSwitch;

    protected TextView mNameText;
    protected TextView mContentText;
    private ImageView mNavArrowView;
    protected SwitchCompat mSwitchView;
    protected View bottomLine;
    private View mMask;
    private View container;

    public MinimalistLineControllerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.minimalist_line_controller_view, this);
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
        mContentText.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                MinimalistLineControllerView.this.performClick();
            }
        });
        bottomLine = findViewById(R.id.bottom_line);
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
        container = findViewById(R.id.view_container);
    }

    public void setBackground(Drawable drawable) {
        super.setBackground(drawable);
        if (container != null) {
            container.setBackground(drawable);
        }
    }

    public void setBackgroundColor(int color) {
        super.setBackgroundColor(color);
        if (container != null) {
            container.setBackgroundColor(color);
        }
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
        } else {
            ViewGroup.LayoutParams params = mContentText.getLayoutParams();
            params.width = ViewGroup.LayoutParams.WRAP_CONTENT;
            params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            mContentText.setLayoutParams(params);
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

    public void setNameColor(int color) {
        mNameText.setTextColor(color);
    }

    public void setName(String name) {
        this.mName = name;
        mNameText.setText(name);
    }
}
