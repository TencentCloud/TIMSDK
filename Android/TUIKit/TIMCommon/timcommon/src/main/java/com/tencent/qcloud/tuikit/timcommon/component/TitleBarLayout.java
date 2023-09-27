package com.tencent.qcloud.tuikit.timcommon.component;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;

public class TitleBarLayout extends LinearLayout implements ITitleBarLayout {
    private LinearLayout mLeftGroup;
    private LinearLayout mRightGroup;
    private TextView mLeftTitle;
    private TextView mCenterTitle;
    private TextView mRightTitle;
    private ImageView mLeftIcon;
    private ImageView mRightIcon;
    private RelativeLayout mTitleLayout;
    private UnreadCountTextView unreadCountTextView;

    public TitleBarLayout(Context context) {
        super(context);
        init(context, null);
    }

    public TitleBarLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public TitleBarLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, @Nullable AttributeSet attrs) {
        String middleTitle = null;
        boolean canReturn = false;
        if (attrs != null) {
            TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.TitleBarLayout);
            middleTitle = array.getString(R.styleable.TitleBarLayout_title_bar_middle_title);
            canReturn = array.getBoolean(R.styleable.TitleBarLayout_title_bar_can_return, false);
            array.recycle();
        }
        inflate(context, R.layout.timcommon_title_bar_layout, this);
        mTitleLayout = findViewById(R.id.page_title_layout);
        mLeftGroup = findViewById(R.id.page_title_left_group);
        mRightGroup = findViewById(R.id.page_title_right_group);
        mLeftTitle = findViewById(R.id.page_title_left_text);
        mRightTitle = findViewById(R.id.page_title_right_text);
        mCenterTitle = findViewById(R.id.page_title);
        mLeftIcon = findViewById(R.id.page_title_left_icon);
        Drawable leftIconDrawable = mLeftIcon.getBackground();
        if (leftIconDrawable != null) {
            leftIconDrawable.setAutoMirrored(true);
        }
        mRightIcon = findViewById(R.id.page_title_right_icon);
        unreadCountTextView = findViewById(R.id.new_message_total_unread);

        LayoutParams params = (LayoutParams) mTitleLayout.getLayoutParams();
        params.height = ScreenUtil.getPxByDp(50);
        mTitleLayout.setLayoutParams(params);
        setBackgroundResource(TUIThemeManager.getAttrResId(getContext(), R.attr.core_title_bar_bg));

        int iconSize = ScreenUtil.dip2px(20);
        ViewGroup.LayoutParams iconParams = mLeftIcon.getLayoutParams();
        iconParams.width = iconSize;
        iconParams.height = iconSize;
        mLeftIcon.setLayoutParams(iconParams);
        iconParams = mRightIcon.getLayoutParams();
        iconParams.width = iconSize;
        iconParams.height = iconSize;

        mRightIcon.setLayoutParams(iconParams);

        if (canReturn) {
            setLeftReturnListener(context);
        }
        if (!TextUtils.isEmpty(middleTitle)) {
            mCenterTitle.setText(middleTitle);
        }
    }

    public void setLeftReturnListener(Context context) {
        mLeftGroup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (context instanceof Activity) {
                    InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(TitleBarLayout.this.getWindowToken(), 0);
                    ((Activity) context).finish();
                }
            }
        });
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
    public void setTitle(String title, Position position) {
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
            default:
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
    public void setLeftIcon(int resId) {
        mLeftIcon.setBackgroundResource(resId);
    }

    @Override
    public ImageView getRightIcon() {
        return mRightIcon;
    }

    @Override
    public void setRightIcon(int resId) {
        mRightIcon.setBackgroundResource(resId);
    }

    @Override
    public TextView getLeftTitle() {
        return mLeftTitle;
    }

    @Override
    public TextView getMiddleTitle() {
        return mCenterTitle;
    }

    @Override
    public TextView getRightTitle() {
        return mRightTitle;
    }

    public UnreadCountTextView getUnreadCountTextView() {
        return unreadCountTextView;
    }
}
