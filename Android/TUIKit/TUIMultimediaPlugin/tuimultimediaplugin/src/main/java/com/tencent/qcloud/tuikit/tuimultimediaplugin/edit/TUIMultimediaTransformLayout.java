package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import android.content.Context;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.GestureDetector.OnGestureListener;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.ScaleGestureDetector.OnScaleGestureListener;
import android.view.View;
import android.widget.RelativeLayout;
import androidx.annotation.NonNull;
import androidx.core.math.MathUtils;
import com.tencent.liteav.base.ThreadUtils;
import com.tencent.liteav.base.util.LiteavLog;

public class TUIMultimediaTransformLayout extends RelativeLayout implements View.OnTouchListener {

    private final String TAG = TUIMultimediaTransformLayout.class.getSimpleName() + "_" + hashCode();

    private GestureDetector mGestureDetector;
    private ScaleGestureDetector mScaleGestureDetector;

    private float mLastScaleFactor;
    private float mScaleFactor = 1.0f;
    private boolean isOnScaling = false;

    private Rect mInitContentLayout;
    private Rect mContentLayout;
    private Rect mLimitLayout;

    private final OnScaleGestureListener mOnScaleGestureListener = new OnScaleGestureListener() {
        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            float factorOffset = detector.getScaleFactor() - mLastScaleFactor;
            mLastScaleFactor = detector.getScaleFactor();
            mScaleFactor = MathUtils.clamp(mScaleFactor + factorOffset, 0.5f, 1.5f);
            scaleContent(factorOffset + 1, new PointF(detector.getFocusX(), detector.getFocusY()));
            return false;
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            mLastScaleFactor = detector.getScaleFactor();
            isOnScaling = true;
            return true;
        }

        @Override
        public void onScaleEnd(@NonNull ScaleGestureDetector detector) {
            ThreadUtils.getUiThreadHandler().postDelayed(() -> isOnScaling = false, 200);
        }
    };

    private final OnGestureListener mOnGestureListener = new OnGestureListener() {
        @Override
        public boolean onDown(@NonNull MotionEvent e) {
            return false;
        }

        @Override
        public boolean onSingleTapUp(@NonNull MotionEvent e) {
            return false;
        }

        @Override
        public boolean onScroll(@NonNull MotionEvent e1, @NonNull MotionEvent e2, float distanceX, float distanceY) {
            if (isOnScaling) {
                return true;
            }

            if (Math.abs(distanceX) > 300 || Math.abs(distanceY) > 300) {
                return true;
            }

            moveContent(distanceX, distanceY);
            return false;
        }

        @Override
        public void onShowPress(@NonNull MotionEvent e) {
        }

        @Override
        public void onLongPress(@NonNull MotionEvent e) {
        }

        @Override
        public boolean onFling(@NonNull MotionEvent e1, @NonNull MotionEvent e2, float velocityX, float velocityY) {
            return true;
        }
    };

    public TUIMultimediaTransformLayout(Context context) {
        super(context);
    }

    public TUIMultimediaTransformLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public void initContentLayout(Rect rect) {
        mInitContentLayout = rect;
        mLimitLayout = mInitContentLayout;
        setContentLayout(rect);
    }

    public Rect getInitContentLayout() {
        return mInitContentLayout;
    }

    public void moveContent(float x, float y) {
        if (mContentLayout == null || mLimitLayout == null) {
            return;
        }

        int left = (int) (mContentLayout.left - x);
        int top = (int) (mContentLayout.top - y);
        setContentLayout(new Rect(left, top, left + mContentLayout.width(), top + mContentLayout.height()));
        invalidate();
    }

    public void scaleContent(float scale, PointF center) {
        if (mContentLayout == null) {
            return;
        }
        int w = (int) (mContentLayout.width() * scale);
        int h = (int) (mContentLayout.height() * scale);
        int l = (int) (mContentLayout.left * scale + center.x - center.x * scale);
        int t = (int) (mContentLayout.top * scale + center.y - center.y * scale);
        setContentLayout(new Rect(l, t, w + l, h + t));
        invalidate();
    }

    public void rotation90Content(Point rotationCenter) {
        if (mContentLayout == null) {
            return;
        }
        int newTop = rotationCenter.y - rotationCenter.x + mContentLayout.left;
        int newLeft = rotationCenter.x + rotationCenter.y - mContentLayout.top - mContentLayout.height();
        setContentLayout(new Rect(newLeft, newTop, newLeft + mContentLayout.height(), newTop + mContentLayout.width()));
    }

    public void enableTransform(boolean enable) {
        LiteavLog.i(TAG, enable ? "enable " : "disable " + "transform.");
        setOnTouchListener(enable ? this : null);
    }

    public void reset() {
        mLastScaleFactor = 0.0f;
        mScaleFactor = 1.0f;
        mLimitLayout = mInitContentLayout;
        setContentLayout(mInitContentLayout);
    }

    public Rect getContentRect() {
        return mContentLayout;
    }

    @Override
    public void addView(View view, int index) {
        if (view.getParent() == this) {
            return;
        }

        if (index > getChildCount()) {
            index = getChildCount();
        }

        super.addView(view, index);

        if (mContentLayout != null) {
            view.layout(mContentLayout.left, mContentLayout.top, mContentLayout.right, mContentLayout.bottom);
        }
    }

    public void setLimitRect(Rect rect) {
        mLimitLayout = rect;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();

        mGestureDetector = new GestureDetector(getContext(), mOnGestureListener);
        mScaleGestureDetector = new ScaleGestureDetector(getContext(), mOnScaleGestureListener);
        setOnTouchListener(this);
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        removeAllViews();
        super.onDetachedFromWindow();
    }

    @Override
    public boolean onTouch(View v, @NonNull MotionEvent event) {
        if (v != this) {
            return false;
        }

        int pointerCount = event.getPointerCount();

        if (event.getAction() == MotionEvent.ACTION_UP) {
            adjustContentToLimitRect();
        }

        if (pointerCount >= 2) {
            mScaleGestureDetector.onTouchEvent(event);
            return true;
        } else if (pointerCount == 1) {
            mGestureDetector.onTouchEvent(event);
            super.performClick();
            return true;
        }
        return false;
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        if (!changed) {
            return;
        }

        mLastScaleFactor = 0.0f;
        mScaleFactor = 1.0f;
        setContentLayout(mInitContentLayout);
    }

    private void setContentLayout(Rect rect) {
        if (rect == null) {
            return;
        }
        for (int i = 0; i < getChildCount(); i++) {
            View child = getChildAt(i);
            child.layout(rect.left, rect.top, rect.right, rect.bottom);
        }
        mContentLayout = rect;
    }

    private void adjustContentToLimitRect() {
        LiteavLog.i(TAG,"adjust content to limit rect.");
        double scaleLimitX = mLimitLayout.width() * 1.0f / mContentLayout.width();
        double scaleLimitY = mLimitLayout.height() * 1.0f / mContentLayout.height();

        double scaleLimit = Math.max(scaleLimitX, scaleLimitY);
        Rect rect = new Rect(mContentLayout);
        Point center = new Point(rect.centerX(), rect.centerY());
        if (scaleLimit > 1.0f) {
            int w = (int) (mContentLayout.width() * scaleLimit);
            int h = (int) (mContentLayout.height() * scaleLimit);
            int l = (int) (mContentLayout.left * scaleLimit + center.x - center.x * scaleLimit);
            int t = (int) (mContentLayout.top * scaleLimit + center.y - center.y * scaleLimit);
            rect = new Rect(l, t, l + w, t + h);
        }

        int l = MathUtils.clamp(rect.left, mLimitLayout.right - rect.width(), mLimitLayout.left);
        int t = MathUtils.clamp(rect.top, mLimitLayout.bottom - rect.height(), mLimitLayout.top);
        rect = new Rect(l, t, l + rect.width(), t + rect.height());
        setContentLayout(rect);
    }
}