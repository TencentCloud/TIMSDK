package com.tencent.cloud.tuikit.roomkit.view.component;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;


import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

public class BottomLayout extends LinearLayout {

    private Context          mContext;
    private RelativeLayout   mExtensionButton;
    private RelativeLayout   mExtensionLayout;
    private RelativeLayout   mBottomRootLayout;
    private LinearLayout     mMainLayout;
    private BottomView       mBottomMainView;
    private BottomView       mBottomExtensionView;
    private LinearLayout     mLayoutRaiseHandTip;
    
    public BottomLayout(Context context) {
        super(context);
        inflate(context, R.layout.tuiroomkit_view_bottom, this);
        mContext = context;
        mBottomRootLayout = findViewById(R.id.ll_root);
        mMainLayout = findViewById(R.id.bottom_main);
        mLayoutRaiseHandTip = findViewById(R.id.ll_raise_hand_tip);
        mBottomMainView = new BottomView(mContext, BottomView.MAINVIEW);
        ViewGroup bottomLayout = findViewById(R.id.bottom_main_view);
        bottomLayout.addView(mBottomMainView);

        mBottomExtensionView = new BottomView(mContext, BottomView.EXTENSIONVIEW);
        mExtensionLayout = findViewById(R.id.bottom_extension_view);
        mExtensionLayout.addView(mBottomExtensionView);

        mBottomRootLayout.getBackground().setAlpha(0);

        mExtensionButton = findViewById(R.id.ll_item_expand);
        mExtensionButton.setOnClickListener(view -> {
            onClickExtension();
        });

        if (shouldShowRaiseHandTip()) {
            mLayoutRaiseHandTip.setVisibility(VISIBLE);
        }
        mLayoutRaiseHandTip.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutRaiseHandTip.setVisibility(GONE);
            }
        });
    }

    private boolean shouldShowRaiseHandTip() {
        return TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT.equals(
                RoomEngineManager.sharedInstance().getRoomStore().roomInfo.speechMode)
                && !TUIRoomDefine.Role.ROOM_OWNER.equals(
                RoomEngineManager.sharedInstance().getRoomStore().userModel.role);
    }

    private void onClickExtension() {
        if (mExtensionLayout.getVisibility() != View.VISIBLE) {
            expandAnimator();
            changeItemClose();
        } else {
            closeAnimator();
            changeItemExpand();
        }
    }

    private ObjectAnimator verticalMoveAnimator(View view, float initHeight, float targetHeight, int duration) {
        ObjectAnimator animator = ObjectAnimator.ofFloat(view, "translationY", targetHeight, -initHeight);
        animator.setDuration(duration);
        return animator;
    }

    private ValueAnimator alphaAnimator(View view, float initAlpha, float targetAlpha, int duration) {
        ValueAnimator animator = ObjectAnimator.ofFloat(view, "alpha", initAlpha, targetAlpha);
        animator.setDuration(duration);
        return animator;
    }

    private ValueAnimator alphaAnimator(View view, int initAlpha, int targetAlpha, int duration) {
        Drawable drawable = view.getBackground();
        ValueAnimator animator = ObjectAnimator.ofInt(drawable, "alpha", initAlpha, targetAlpha);
        animator.setDuration(duration);
        return animator;
    }

    private ValueAnimator backgroundScaleAnimator(View view, int initHeight, int targetHeight, int duration) {
        int[] location = new int[2];
        view.getLocationOnScreen(location);
        final int bottom = location[1];
        Drawable drawable = view.getBackground();
        ValueAnimator animator = ValueAnimator.ofInt(initHeight, targetHeight);
        animator.setDuration(duration);
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(@NonNull ValueAnimator valueAnimator) {
                int top = (int)animator.getAnimatedValue();
                drawable.setBounds(0, top, view.getWidth(), bottom);
            }
        });
        return animator;
    }

    private void expandAnimator() {
        mExtensionButton.setClickable(false);

        ObjectAnimator riseBtnAnimator = verticalMoveAnimator(mMainLayout,
                mMainLayout.getHeight(), 0f, 250);
        ObjectAnimator riseTipAnimator = verticalMoveAnimator(mLayoutRaiseHandTip,
                mMainLayout.getHeight(), 0f, 250);
        ValueAnimator alphaBtnAnimator = alphaAnimator(mExtensionLayout,
                0f, 1f, 300);
        int initHeight = mExtensionLayout.getTop();
        int targetHeight = 0;
        ValueAnimator heightAnimator = backgroundScaleAnimator(mBottomRootLayout,
                initHeight, targetHeight, 250);
        Drawable background = mBottomRootLayout.getBackground();
        ValueAnimator alphaBgAnimator = alphaAnimator(mBottomRootLayout,
                0, 255, 250);
        alphaBgAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                super.onAnimationStart(animation);
                mExtensionLayout.setVisibility(View.VISIBLE);
                mMainLayout.setVisibility(View.VISIBLE);
                Rect rect = new Rect(0, mBottomRootLayout.getHeight() / 2,
                        mBottomRootLayout.getWidth(), mBottomRootLayout.getHeight());
                background.setBounds(rect);
            }
        });

        AnimatorSet set = new AnimatorSet();
        set.playTogether(riseBtnAnimator, alphaBtnAnimator, heightAnimator, riseTipAnimator);
        set.play(riseBtnAnimator).after(alphaBgAnimator);

        set.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                mExtensionButton.setClickable(true);
            }
        });

        set.start();
    }

    private void closeAnimator() {
        mExtensionButton.setClickable(false);

        ObjectAnimator riseBtnAnimator = verticalMoveAnimator(mMainLayout,
                0f, -mMainLayout.getHeight(), 250);
        ObjectAnimator riseTipAnimator = verticalMoveAnimator(mLayoutRaiseHandTip,
                 0f, -mMainLayout.getHeight(),250);
        ValueAnimator alphaBtnAnimator = alphaAnimator(mExtensionLayout,
                1f, 0f, 300);
        int initHeight = 0;
        int targetHeight = mExtensionLayout.getTop();
        ValueAnimator heightAnimator = backgroundScaleAnimator(mBottomRootLayout,
                initHeight, targetHeight, 250);
        Drawable background = mBottomRootLayout.getBackground();
        ValueAnimator alphaBgAnimator = alphaAnimator(mBottomRootLayout,
                255, 0, 250);

        alphaBgAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                super.onAnimationStart(animation);
                background.setBounds(0, mBottomRootLayout.getHeight() / 2,
                        mBottomRootLayout.getWidth(), mBottomRootLayout.getHeight());
                mExtensionLayout.setVisibility(View.VISIBLE);
            }
        });

        AnimatorSet set = new AnimatorSet();
        set.playTogether(riseBtnAnimator, alphaBtnAnimator, heightAnimator, riseTipAnimator);
        set.play(alphaBgAnimator).after(riseBtnAnimator);

        set.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                mExtensionLayout.setVisibility(View.INVISIBLE);
                mExtensionButton.setClickable(true);
            }
        });

        set.start();
    }

    private void changeItemExpand() {
        ImageView imageView = findViewById(R.id.image_expand);
        TextView textView = findViewById(R.id.expand_text);
        imageView.setImageResource(R.drawable.tuiroomkit_ic_expand);
        textView.setText(R.string.tuiroomkit_item_expand);
    }

    private void changeItemClose() {
        ImageView imageView = findViewById(R.id.image_expand);
        TextView textView = findViewById(R.id.expand_text);
        imageView.setImageResource(R.drawable.tuiroomkit_ic_close);
        textView.setText(R.string.tuiroomkit_item_close);
    }

    public void stopScreenShare() {
        mBottomMainView.stopScreenShareDialog();
    }
}
