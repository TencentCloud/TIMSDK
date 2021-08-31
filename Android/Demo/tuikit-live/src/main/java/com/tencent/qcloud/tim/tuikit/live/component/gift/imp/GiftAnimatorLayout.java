package com.tencent.qcloud.tim.tuikit.live.component.gift.imp;

import android.animation.ValueAnimator;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;

import com.airbnb.lottie.LottieAnimationView;
import com.tencent.qcloud.tim.tuikit.live.R;

import java.util.LinkedList;

public class GiftAnimatorLayout extends LinearLayout {

    private static final int MAX_SHOW_GIFT_BULLET_SIZE       = 3; //礼物弹幕最多展示的个数
    private static final int MSG_PLAY_SCREEN_LOTTIE_ANIMATOR = 101;

    private Context             mContext;
    private LottieAnimationView mLottieAnimationView;
    private LinearLayout        mGiftBulletGroup;
    private LinkedList<String>  mAnimationUrlList;
    private boolean             mIsPlaying;

    public GiftAnimatorLayout(Context context) {
        super(context);
    }

    public GiftAnimatorLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        mAnimationUrlList = new LinkedList<>();
        initView();
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.live_layout_lottie_animator, this, true);
        mLottieAnimationView = (LottieAnimationView) findViewById(R.id.lottie_view);
        mGiftBulletGroup = (LinearLayout) findViewById(R.id.gift_bullet_group);
    }

    public void show(GiftInfo info) {
        if (info == null) {
            return;
        }
        showGiftBullet(info);
        if (info.type == GiftInfo.GIFT_TYPE_SHOW_ANIMATION_PLAY) {
            showLottieAnimation(info.lottieUrl);
        }

    }

    public void hide() {
        mLottieAnimationView.clearAnimation();
        mLottieAnimationView.setVisibility(GONE);
    }

    private void showLottieAnimation(String lottieSource) {
        if (!TextUtils.isEmpty(lottieSource)) {
            Message message = Message.obtain();
            message.obj = lottieSource;
            message.what = MSG_PLAY_SCREEN_LOTTIE_ANIMATOR;
            mHandler.sendMessage(message);
        }
    }

    private void playLottieAnimation() {
        String lottieUrl = mAnimationUrlList.getFirst();
        if (!TextUtils.isEmpty(lottieUrl)) {
            mAnimationUrlList.removeFirst();
            mLottieAnimationView.setVisibility(VISIBLE);
            mLottieAnimationView.setAnimationFromUrl(lottieUrl);
            mLottieAnimationView.addAnimatorUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    // 判断动画加载结束
                    if (valueAnimator.getAnimatedFraction() == 1f) {
                        if (mAnimationUrlList.isEmpty()) {
                            mLottieAnimationView.clearAnimation();
                            mLottieAnimationView.setVisibility(GONE);
                            mIsPlaying = false;
                        } else {
                            playLottieAnimation();
                        }
                    }
                }
            });
            mLottieAnimationView.playAnimation();
            mIsPlaying = true;
        }
    }

    private void showGiftBullet(GiftInfo info) {
        if (mGiftBulletGroup.getChildCount() >= MAX_SHOW_GIFT_BULLET_SIZE) {
            //如果礼物超过3个，就将第一个出现的礼物弹幕从界面上移除
            View firstShowBulletView = mGiftBulletGroup.getChildAt(0);
            if (firstShowBulletView != null) {
                GiftBulletFrameLayout bulletView = (GiftBulletFrameLayout) firstShowBulletView;
                bulletView.clearHandler();
                mGiftBulletGroup.removeView(bulletView);
            }
        }
        GiftBulletFrameLayout giftFrameLayout = new GiftBulletFrameLayout(mContext);
        mGiftBulletGroup.addView(giftFrameLayout);
        RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) mGiftBulletGroup.getLayoutParams();
        lp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        if (giftFrameLayout.setGift(info)) {
            giftFrameLayout.startAnimation();
        }
    }

    private Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == MSG_PLAY_SCREEN_LOTTIE_ANIMATOR) {
                String animationUrl = (String) msg.obj;
                mAnimationUrlList.addLast(animationUrl);
                if (!mIsPlaying) {
                    playLottieAnimation();
                }
            }

        }
    };
}
