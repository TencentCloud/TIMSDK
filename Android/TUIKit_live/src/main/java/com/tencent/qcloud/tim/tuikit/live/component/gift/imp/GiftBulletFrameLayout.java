package com.tencent.qcloud.tim.tuikit.live.component.gift.imp;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.OvershootInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.utils.AnimationUtils;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;

public class GiftBulletFrameLayout extends FrameLayout implements Handler.Callback {

    private static final String TAG = "GiftBulletFrameLayout";

    private static final int MSG_START_ANIMATION = 1001;
    private static final int GIFT_DISMISS_TIME   = 3000; //礼物展示时间

    private Handler mHandler = new Handler(this);

    private Context        mContext;
    private LayoutInflater mInflater;
    private Runnable       mGiftEndAnimationRunnable; //当前动画结束runnable
    private RelativeLayout mGiftGroup;
    private ImageView      mImageGiftIcon;
    private ImageView      mImageSendUserIcon;
    private TextView       mTextSendUserName;
    private TextView       mTextGiftTitle;
    private View           mRootView;
    private GiftInfo       mGift;

    public GiftBulletFrameLayout(Context context) {
        this(context, null);
    }

    public GiftBulletFrameLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        mInflater = LayoutInflater.from(context);
        mContext = context;
        initView();
    }

    private void initView() {
        mRootView = mInflater.inflate(R.layout.live_layout_gift_bullet, null);
        mGiftGroup = (RelativeLayout) mRootView.findViewById(R.id.gift_group);
        mImageGiftIcon = (ImageView) mRootView.findViewById(R.id.iv_gift_icon);
        mImageSendUserIcon = (ImageView) mRootView.findViewById(R.id.iv_send_user_icon);
        mTextSendUserName = (TextView) mRootView.findViewById(R.id.tv_send_user_name);
        mTextGiftTitle = (TextView) mRootView.findViewById(R.id.tv_gift_title);
        this.addView(mRootView);
    }

    public void hideView() {
        mImageGiftIcon.setVisibility(INVISIBLE);
    }

    public boolean setGift(GiftInfo gift) {
        if (gift == null) {
            return false;
        }
        mGift = gift;
        if (!TextUtils.isEmpty(gift.sendUser)) {
            mTextSendUserName.setText(gift.sendUser);
        }
        if (!TextUtils.isEmpty(gift.title)) {
            String tip = String.format(mContext.getString(R.string.live_gift_send), gift.title);
            mTextGiftTitle.setText(tip);
        }
        return true;
    }

    public GiftInfo getGift() {
        return mGift;
    }

    @Override
    public boolean handleMessage(Message msg) {
        switch (msg.what) {
            case MSG_START_ANIMATION:
                startAnimationForMsg();
                break;
        }
        return true;
    }

    public void clearHandler() {
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            mHandler = null;
        }
        resetGift();
    }

    public void resetGift() {
        mGiftEndAnimationRunnable = null;
        mGift = null;
    }

    /**
     * 动画开始时回调
     */
    private void initLayoutState() {
        if (mGift == null) {
            return;
        }
        this.setVisibility(View.VISIBLE);
        if (!TextUtils.isEmpty(mGift.sendUserHeadIcon)) {
            GlideEngine.loadImage(mImageSendUserIcon, mGift.sendUserHeadIcon);
        } else {
            GlideEngine.loadImage(mImageSendUserIcon, R.drawable.live_default_head_img);
        }
        if (!TextUtils.isEmpty(mGift.giftPicUrl)) {
            GlideEngine.loadImage(mImageGiftIcon, mGift.giftPicUrl);
        }
    }

    private void startAnimationForMsg() {
        hideView();
        ObjectAnimator giftLayoutAnimator = AnimationUtils.createFadesInFromLtoR(
                mGiftGroup, -getWidth(), 0, 400, new OvershootInterpolator());
        giftLayoutAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                super.onAnimationStart(animation);
                initLayoutState();
            }
        });

        ObjectAnimator giftImageAnimator = AnimationUtils.createFadesInFromLtoR(
                mImageGiftIcon, -getWidth(), 0, 400, new DecelerateInterpolator());
        giftImageAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                mImageGiftIcon.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
            }
        });
        AnimationUtils.startAnimation(giftLayoutAnimator, giftImageAnimator);
        mGiftEndAnimationRunnable = new GiftEndAnimationRunnable();
        mHandler.postDelayed(mGiftEndAnimationRunnable, GIFT_DISMISS_TIME);
    }

    public void startAnimation() {
        mHandler.sendEmptyMessage(MSG_START_ANIMATION);
    }

    private class GiftEndAnimationRunnable implements Runnable {

        @Override
        public void run() {
            endAnimation();
        }
    }

    public AnimatorSet endAnimation() {
        //向上渐变消失
        ObjectAnimator fadeAnimator = AnimationUtils.createFadesOutAnimator(
                GiftBulletFrameLayout.this, 0, -100, 500, 0);
        fadeAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                //动画结束之后在父容器中移除自己
                ViewGroup viewGroup = (ViewGroup) getParent();
                if (viewGroup != null) {
                    viewGroup.removeView(GiftBulletFrameLayout.this);
                }
            }
        });
        ObjectAnimator fadeAnimator2 = AnimationUtils.createFadesOutAnimator(
                GiftBulletFrameLayout.this, 100, 0, 0, 0);
        AnimatorSet animatorSet = AnimationUtils.startAnimation(fadeAnimator, fadeAnimator2);
        return animatorSet;
    }
}
