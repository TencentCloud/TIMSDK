package com.tencent.qcloud.tuikit.tuicommunity.component.banner;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.Paint;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;

import java.util.ArrayList;
import java.util.List;

public class BannerIndicatorView extends LinearLayout {

    private static final int PLAY_TIME = 150;  // 300ms

    private final List<ViewWrapper> viewWrappers = new ArrayList<>();
    private AnimatorSet showAnimSet;
    private AnimatorSet resetAnimSet;

    private int normalWidth;
    private int selectedWidth;
    public BannerIndicatorView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setOrientation(HORIZONTAL);
        setGravity(Gravity.CENTER);
        normalWidth = ScreenUtil.dip2px(8);
        selectedWidth = ScreenUtil.dip2px(16);
    }

    public BannerIndicatorView(Context context) {
        this(context, null);
    }

    public void init(int count) {
        this.removeAllViews();
        for (int i = 0; i < count; i++) {
            ViewWrapper viewWrapper = new ViewWrapper(getContext());
            if (i == 0) {
                ViewGroup.LayoutParams layoutParams = viewWrapper.getView().getLayoutParams();
                layoutParams.width = selectedWidth;
                viewWrapper.getView().setLayoutParams(layoutParams);
                viewWrapper.setBackgroundColor(getContext().getResources().getColor(R.color.community_banner_selected_color));
            }
            this.addView(viewWrapper.getView(), viewWrapper.getView().getLayoutParams());
            viewWrappers.add(viewWrapper);
        }
    }

    public void playBy(int startPosition, int nextPosition) {
        boolean isShowInAnimOnly = false;
        if (startPosition < 0 || nextPosition < 0 || nextPosition == startPosition) {
            startPosition = nextPosition = 0;
        }

        if (startPosition < 0) {
            isShowInAnimOnly = true;
            startPosition = nextPosition = 0;
        }

        final ViewWrapper startView = viewWrappers.get(startPosition);
        final ViewWrapper nextView = viewWrappers.get(nextPosition);

        ObjectAnimator animReset = ObjectAnimator.ofInt(startView, "width", selectedWidth, normalWidth);

        if (resetAnimSet != null && resetAnimSet.isRunning()) {
            resetAnimSet.cancel();
            resetAnimSet = null;
        }
        resetAnimSet = new AnimatorSet();
        resetAnimSet.setDuration(PLAY_TIME);
        resetAnimSet.play(animReset);

        ObjectAnimator animShow = ObjectAnimator.ofInt(nextView, "width", normalWidth, selectedWidth);

        if (showAnimSet != null && showAnimSet.isRunning()) {
            showAnimSet.cancel();
            showAnimSet = null;
        }
        showAnimSet = new AnimatorSet();
        showAnimSet.setDuration(PLAY_TIME);
        showAnimSet.play(animShow);

        if (isShowInAnimOnly) {
            showAnimSet.start();
            return;
        }

        animReset.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                startView.setBackgroundColor(getResources().getColor(R.color.community_banner_normal_color));
                ObjectAnimator animFil1l = ObjectAnimator.ofInt(startView, "width", normalWidth);
                AnimatorSet mFillAnimatorSet = new AnimatorSet();
                mFillAnimatorSet.play(animFil1l);
                mFillAnimatorSet.start();
                nextView.setBackgroundColor(getResources().getColor(R.color.community_banner_selected_color));
                showAnimSet.start();
            }

            @Override
            public void onAnimationCancel(Animator animation) {
            }

            @Override
            public void onAnimationRepeat(Animator animation) {
            }
        });
        resetAnimSet.start();
    }

    private static class ViewWrapper {
        private final View view;
        private final ShapeDrawable drawable;
        public ViewWrapper(Context context) {
            view = new View(context);
            int viewRadius = ScreenUtil.dip2px(1.5f);
            float[] radius = {viewRadius, viewRadius, viewRadius, viewRadius, viewRadius, viewRadius, viewRadius, viewRadius};
            RoundRectShape shape = new RoundRectShape(radius, null, null);
            drawable = new ShapeDrawable(shape);
            drawable.getPaint().setStyle(Paint.Style.FILL_AND_STROKE);
            drawable.getPaint().setAntiAlias(true);
            drawable.getPaint().setColor(context.getResources().getColor(R.color.community_banner_normal_color));
            LayoutParams params = new LayoutParams(ScreenUtil.dip2px(8), ScreenUtil.dip2px(3));
            params.gravity = Gravity.CENTER;
            params.rightMargin = ScreenUtil.dip2px(3);
            view.setLayoutParams(params);
            view.setBackground(drawable);
        }

        public View getView() {
            return view;
        }

        public void setBackgroundColor(int color) {
            drawable.getPaint().setColor(color);
            drawable.invalidateSelf();
        }

        public void setWidth(int width) {
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            layoutParams.width = width;
            view.setLayoutParams(layoutParams);
            view.requestLayout();
        }

        public int getWidth() {
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            return layoutParams.width;
        }
    }
}
