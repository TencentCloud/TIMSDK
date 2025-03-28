package com.tencent.cloud.tuikit.roomkit.view.main.bottomnavigationbar;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.KEY_ROOM_RAISE_HAND_TIP_SHOWED;

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
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.util.SPUtils;

public class BottomLayout extends LinearLayout {

    private Context        mContext;
    private RelativeLayout mExtensionButton;
    private RelativeLayout mExtensionLayout;
    private RelativeLayout mBottomRootLayout;
    private LinearLayout   mMainLayout;
    private BottomView     mBottomMainView;
    private BottomView     mBottomExtensionView;
    private LinearLayout   mLayoutRaiseHandTip;

    private ExpandStateListener mExpandStateListener;

    public interface ExpandStateListener {
        void onExpandStateChanged(boolean isExpanded);
    }

    public void setExpandStateListener(ExpandStateListener expandStateListener) {
        mExpandStateListener = expandStateListener;
    }

    public void expandView() {
        expandAnimator();
        changeItemClose();
    }

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
            mLayoutRaiseHandTip.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    mLayoutRaiseHandTip.setVisibility(GONE);
                    SPUtils.getInstance().put(KEY_ROOM_RAISE_HAND_TIP_SHOWED, true);
                }
            });
        }
    }

    private boolean shouldShowRaiseHandTip() {
        boolean shouldShow = ConferenceController.sharedInstance().getConferenceState().roomInfo.isSeatEnabled
                && !TUIRoomDefine.Role.ROOM_OWNER.equals(
                ConferenceController.sharedInstance().getConferenceState().userModel.getRole());
        boolean isShowedBefore = SPUtils.getInstance().getBoolean(KEY_ROOM_RAISE_HAND_TIP_SHOWED, false);
        return shouldShow && !isShowedBefore;
    }

    private void onClickExtension() {
        boolean isExpand = mExtensionLayout.getVisibility() == View.VISIBLE;
        if (mExpandStateListener != null) {
            mExpandStateListener.onExpandStateChanged(!isExpand);
        }
        if (!isExpand) {
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
        final int bottom = (int) mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_view_height);
        Drawable drawable = view.getBackground();
        ValueAnimator animator = ValueAnimator.ofInt(initHeight, targetHeight);
        animator.setDuration(duration);
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(@NonNull ValueAnimator valueAnimator) {
                int top = (int) animator.getAnimatedValue();
                drawable.setBounds(0, top, view.getWidth(), bottom);
            }
        });
        return animator;
    }

    private void expandAnimator() {
        mExtensionButton.setClickable(false);

        ObjectAnimator riseBtnAnimator = verticalMoveAnimator(mMainLayout,
                mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_list_view_height), 0f, 250);
        ObjectAnimator riseTipAnimator = verticalMoveAnimator(mLayoutRaiseHandTip,
                mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_list_view_height), 0f, 250);
        ValueAnimator alphaBtnAnimator = alphaAnimator(mExtensionLayout, 0f, 1f, 300);
        int initHeight =
                (int) mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_extension_view_margin_top);
        int targetHeight = 0;

        ValueAnimator heightAnimator = backgroundScaleAnimator(mBottomRootLayout, initHeight, targetHeight, 250);
        Drawable background = mBottomRootLayout.getBackground();
        ValueAnimator alphaBgAnimator = alphaAnimator(mBottomRootLayout, 0, 255, 250);
        alphaBgAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                super.onAnimationStart(animation);
                mExtensionLayout.setVisibility(View.VISIBLE);
                mMainLayout.setVisibility(View.VISIBLE);
                int width = (int) mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_view_width);
                int height = (int) mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_view_height);
                Rect rect = new Rect(0, height / 2, width, height);
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
                0f, -mMainLayout.getHeight(), 250);
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
