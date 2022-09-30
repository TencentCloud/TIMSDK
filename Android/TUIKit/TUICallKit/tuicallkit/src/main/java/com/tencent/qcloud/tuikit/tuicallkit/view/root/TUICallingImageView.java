package com.tencent.qcloud.tuikit.tuicallkit.view.root;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuicallkit.R;

public class TUICallingImageView extends BaseCallView {
    private Context        mContext;
    private RelativeLayout mLayoutUserView;
    private LinearLayout   mLayoutOtherUserContainer;
    private RelativeLayout mLayoutFunction;
    private TextView       mTextTime;
    private TextView       mTextCallHint;
    private View           mRootView;
    private RelativeLayout mLayoutFloatView;
    private RelativeLayout mLayoutAddUserView;

    public TUICallingImageView(Context context) {
        super(context);
        mContext = context;
        initView();
    }

    public void initView() {
        mRootView = LayoutInflater.from(mContext).inflate(R.layout.tuicalling_background_image_view, this);
        mLayoutFloatView = findViewById(R.id.rl_float_view);
        mLayoutAddUserView = findViewById(R.id.rl_add_user_view);
        mLayoutUserView = findViewById(R.id.rl_single_audio_view);
        mTextCallHint = findViewById(R.id.tv_call_hint);
        mLayoutOtherUserContainer = findViewById(R.id.ll_other_user_container);
        mTextTime = findViewById(R.id.tv_image_time);
        mLayoutFunction = findViewById(R.id.rl_image_function);
    }

    @Override
    public void updateUserView(View view) {
        super.updateUserView(view);
        mLayoutUserView.removeAllViews();
        if (null != view) {
            mLayoutUserView.addView(view);
        }
    }

    @Override
    public void addOtherUserView(View view) {
        super.addOtherUserView(view);
        mLayoutOtherUserContainer.removeAllViews();
        if (null != view) {
            mLayoutOtherUserContainer.addView(view);
        }
    }

    @Override
    public void updateCallingHint(String hint) {
        super.updateCallingHint(hint);
        mTextCallHint.setText(hint);
        mTextCallHint.setVisibility(TextUtils.isEmpty(hint) ? GONE : VISIBLE);
    }

    @Override
    public void updateCallTimeView(String time) {
        mTextTime.setText(time);
        mTextTime.setVisibility(TextUtils.isEmpty(time) ? GONE : VISIBLE);
    }

    @Override
    public void updateFunctionView(View view) {
        mLayoutFunction.removeAllViews();
        if (null != view) {
            mLayoutFunction.addView(view);
        }
    }

    @Override
    public void updateBackgroundColor(int color) {
        mRootView.setBackgroundColor(color);
    }

    @Override
    public void updateTextColor(int color) {
        super.updateTextColor(color);
        mTextCallHint.setTextColor(color);
        mTextTime.setTextColor(color);
    }

    @Override
    public void enableFloatView(View view) {
        mLayoutFloatView.removeAllViews();
        if (null != view) {
            mLayoutFloatView.addView(view);
        }
    }

    @Override
    public void enableAddUserView(View view) {
        mLayoutAddUserView.removeAllViews();
        if (null != view) {
            mLayoutAddUserView.addView(view);
        }
    }
}
