package com.tencent.qcloud.uikit.common.widget;

import android.animation.Animator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Checkable;

import com.tencent.qcloud.uikit.R;


/**
 * @author rjlee detail 自定义swith控件
 * @class Switch
 * @brief Application
 */

public class UIKitSwitch extends View implements Checkable {

    private boolean mChecked = false;

    private Drawable mDrawableButton;

    private Drawable mDrawableTrackOn;
    private Drawable mDrawableTrackOff;
    private Drawable mDrawableTrackMoving;

    private int mAnimationX = -1;

    public UIKitSwitch(Context context, AttributeSet attrs) {
        super(context, attrs);
        mChecked = attrs.getAttributeBooleanValue(android.R.attr.state_checked, false);
        mDrawableButton = getResources().getDrawable(R.drawable.switch_button);
        mDrawableTrackOn = getResources().getDrawable(R.drawable.switch_track_on);
        mDrawableTrackOff = getResources().getDrawable(R.drawable.switch_track_off);
        mDrawableTrackMoving = getResources().getDrawable(R.drawable.switch_track_moving);
        setClickable(true);
    }

    @Override
    public boolean performClick() {
        toggleAnim();
        return super.performClick();
    }

    private void toggleAnim() {

        final int width = getWidth();
        final int trackWidth = mDrawableTrackOn.getIntrinsicWidth();
        final int buttonWidth = mDrawableButton.getIntrinsicWidth();

        final int leftX = 0;
        final int rightX = (width - trackWidth) / 2 + trackWidth - buttonWidth;

        ValueAnimator anim;
        if (mChecked) {
            anim = ValueAnimator.ofInt(rightX, leftX);
        } else {
            anim = ValueAnimator.ofInt(leftX, rightX);
        }
        anim.setDuration(30);
        anim.addListener(new Animator.AnimatorListener() {

            @Override
            public void onAnimationStart(Animator animation) {
            }

            @Override
            public void onAnimationRepeat(Animator animation) {
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                mAnimationX = -1;
                invalidate();
            }

            @Override
            public void onAnimationCancel(Animator animation) {
                mAnimationX = -1;
                invalidate();
            }
        });
        anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator anim) {
                mAnimationX = ((Integer) anim.getAnimatedValue()).intValue();
                invalidate();
            }
        });
        anim.start();
        mChecked = !mChecked;
        if (mOnCheckedChangeListener != null)
            mOnCheckedChangeListener.onCheckedChanged(this, mChecked);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        setMeasuredDimension(
                resolveAdjustedSize(mDrawableTrackOn.getIntrinsicWidth(), heightMeasureSpec),
                resolveAdjustedSize(mDrawableTrackOn.getIntrinsicHeight(), heightMeasureSpec));
    }

    private int resolveAdjustedSize(int desiredSize, int measureSpec) {
        final int mode = MeasureSpec.getMode(measureSpec);
        final int size = MeasureSpec.getMode(measureSpec);
        if (mode == MeasureSpec.EXACTLY) {
            return size;
        }
        return desiredSize;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        Drawable drawable;
        if (mChecked) {
            drawable = mDrawableTrackOn;
        } else {
            drawable = mDrawableTrackOff;
        }

        final int width = getWidth();
        final int height = getHeight();

        int x, y, cx, cy;
        cx = drawable.getIntrinsicWidth();
        cy = drawable.getIntrinsicHeight();

        x = (width - cx) / 2;
        y = (height - cy) / 2;
        if (mAnimationX != -1) {
            int split = mAnimationX + mDrawableButton.getIntrinsicWidth() / 2;

            canvas.save();
            canvas.clipRect(0, 0, split, y + cy);
            mDrawableTrackMoving.setBounds(x, y, x + cx, y + cy);
            mDrawableTrackMoving.draw(canvas);
            canvas.restore();

            canvas.save();
            canvas.clipRect(split, 0, x + cx, y + cy);
            mDrawableTrackOff.setBounds(x, y, x + cx, y + cy);
            mDrawableTrackOff.draw(canvas);
            canvas.restore();

        } else {
            drawable.setBounds(x, y, x + cx, y + cy);
            drawable.mutate().setAlpha(isEnabled() ? 255 : 153);
            drawable.draw(canvas);
        }

        cx = mDrawableButton.getIntrinsicWidth();
        cy = mDrawableButton.getIntrinsicHeight();
        y = (height - cy) / 2;
        if (mAnimationX != -1) {
            x = mAnimationX;
        } else if (mChecked) {
            int trackWidth = drawable.getIntrinsicWidth();
            int buttonWidth = mDrawableButton.getIntrinsicWidth();
            x = (width - trackWidth) / 2 + trackWidth - buttonWidth;
        } else {
            x = 0;
        }
        mDrawableButton.setBounds(x, y, x + cx, y + cy);
        mDrawableButton.mutate().setAlpha(isEnabled() ? 255 : 153);
        mDrawableButton.draw(canvas);
    }

    public void setChecked(boolean checked) {
        if (mChecked == checked)
            return;

        mChecked = checked;
        invalidate();
        if (mOnCheckedChangeListener != null) {
            mOnCheckedChangeListener.onCheckedChanged((View) this, checked);
        }
    }

    public boolean isChecked() {
        return mChecked;
    }

    public void toggle() {
        setChecked(!mChecked);
    }

    /**
     * Interface definition for a callback to be invoked when the checked state
     * of a compound button changed.
     */
    public static interface OnCheckedChangeListener {
        /**
         * Called when the checked state of a compound button has changed.
         *
         * @param buttonView The compound button view whose state has changed.
         * @param isChecked  The new checked state of buttonView.
         */
        void onCheckedChanged(View buttonView, boolean isChecked);
    }

    protected OnCheckedChangeListener mOnCheckedChangeListener;

    /**
     * Register a callback to be invoked when the checked state of this button
     * changes.
     *
     * @param listener the callback to call on checked state change
     */
    public void setOnCheckedChangeListener(OnCheckedChangeListener listener) {
        mOnCheckedChangeListener = listener;
    }
}
