package com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayoutEntity;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;
import com.tencent.qcloud.tuikit.tuicallkit.view.UserLayoutFactory;

import java.util.Objects;

public class FloatCallView extends RelativeLayout {
    private static final int UPDATE_COUNT         = 3;
    private static final int UPDATE_INTERVAL      = 300;
    private static final int MESSAGE_LAYOUT_EMPTY = 1;
    private static final int MESSAGE_VIEW_EMPTY   = 2;
    private              int mCount               = 0;

    private final Context mContext;

    private RelativeLayout mLayoutVideoView;
    private ImageView      mImageAudio;
    private TextView       mTextHint;
    private TextView       mTextTime;
    private ImageView      mImageFloatAvatar;

    private OnClickListener   mOnClickListener;
    private UserLayoutFactory mUserLayoutFactory;
    private UserLayout        mVideoLayout;
    private String            mCurrentUser;
    private boolean           mIsVideoAvailable;

    public FloatCallView(Context context, UserLayoutFactory factory) {
        super(context);
        mContext = context;
        mUserLayoutFactory = factory;
        initView(context);
    }

    private void initView(Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuicalling_floatwindow_layout, this);
        mLayoutVideoView = findViewById(R.id.rl_video_view);
        mImageFloatAvatar = findViewById(R.id.img_float_avatar);
        mTextHint = findViewById(R.id.tv_float_hint);
        mImageAudio = findViewById(R.id.float_audioView);
        mTextTime = findViewById(R.id.tv_float_time);
        setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (null != mOnClickListener) {
                    mOnClickListener.onClick();
                }
            }
        });
    }

    public void updateView(boolean isVideoAvailable, String userId) {
        mIsVideoAvailable = isVideoAvailable;
        if (!isVideoAvailable) {
            mLayoutVideoView.setVisibility(GONE);
            mImageFloatAvatar.setVisibility(GONE);
            mImageAudio.setVisibility(VISIBLE);
            return;
        }

        if (null == mUserLayoutFactory || TextUtils.isEmpty(userId)) {
            return;
        }

        mCurrentUser = userId;
        mImageAudio.setVisibility(GONE);

        CallingUserModel model = new CallingUserModel();
        for (UserLayoutEntity entity : mUserLayoutFactory.mLayoutEntityList) {
            if (entity != null && Objects.equals(entity.userId, userId)) {
                model = entity.userModel;
                break;
            }
        }

        if (model != null && !model.isVideoAvailable) {
            mLayoutVideoView.removeAllViews();
            mLayoutVideoView.setVisibility(GONE);
            mImageFloatAvatar.setVisibility(VISIBLE);
            ImageLoader.loadImage(mContext, mImageFloatAvatar, model.userAvatar, R.drawable.tuicalling_ic_avatar);
            return;
        }
        mImageFloatAvatar.setVisibility(GONE);

        mVideoLayout = mUserLayoutFactory.findUserLayout(userId);
        if (null == mVideoLayout) {
            mViewHandler.sendEmptyMessageDelayed(MESSAGE_LAYOUT_EMPTY, UPDATE_INTERVAL);
            return;
        }
        reloadVideoView();
    }

    private void reloadVideoView() {
        if (null == mVideoLayout) {
            return;
        }

        TUIVideoView videoView = mVideoLayout.getVideoView();
        if (videoView == null) {
            mViewHandler.sendEmptyMessageDelayed(MESSAGE_VIEW_EMPTY, UPDATE_INTERVAL);
            return;
        }
        if (null != videoView.getParent()) {
            ((ViewGroup) videoView.getParent()).removeView(videoView);
        }
        mLayoutVideoView.removeAllViews();
        mLayoutVideoView.setVisibility(VISIBLE);
        mLayoutVideoView.addView(videoView);
    }

    private final Handler mViewHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (msg.what == MESSAGE_LAYOUT_EMPTY && null == mVideoLayout && mCount <= UPDATE_COUNT) {
                mVideoLayout = mUserLayoutFactory.findUserLayout(mCurrentUser);
                sendEmptyMessageDelayed(MESSAGE_LAYOUT_EMPTY, UPDATE_INTERVAL);
                mCount++;
            } else if (msg.what == MESSAGE_VIEW_EMPTY && mCount < UPDATE_COUNT) {
                sendEmptyMessageDelayed(MESSAGE_VIEW_EMPTY, UPDATE_INTERVAL);
                mCount++;
            } else {
                reloadVideoView();
                mCount = 0;
            }
        }
    };

    public void enableCallingHint(boolean enable) {
        mTextHint.setVisibility(enable ? VISIBLE : GONE);
    }

    public void updateCallTimeView(String time) {
        if (mIsVideoAvailable) {
            mTextTime.setVisibility(GONE);
            return;
        }
        mTextTime.setText(time);
        mTextTime.setVisibility(TextUtils.isEmpty(time) ? INVISIBLE : VISIBLE);
    }

    public void setOnClickListener(OnClickListener callback) {
        mOnClickListener = callback;
    }

    public String getCurrentUser() {
        return mCurrentUser;
    }

    public interface OnClickListener {
        void onClick();
    }
}
