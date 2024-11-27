package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.beauty;

import android.animation.ValueAnimator;
import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.OnGestureListener;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.ScaleGestureDetector.OnScaleGestureListener;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecordCore;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInnerType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyType;

@SuppressLint("ViewConstructor")
public class BeautyFilterScrollView extends RelativeLayout implements View.OnTouchListener {

    private final String TAG = BeautyFilterScrollView.class + "_" + hashCode();

    private final TUIMultimediaRecordCore mRecordCore;
    private final BeautyInfo mBeautyInfo;
    private final int mFilterIndex;
    private final BeautyType mBeautyFilterType;

    private TextView mFilterNameTextView;
    private FrameLayout mMaskLayout;
    private GestureDetector mGestureDetector;
    private ScaleGestureDetector mScaleGestureDetector;

    private int mLeftIndex = 0;
    private int mRightIndex = 1;
    private int mLastLeftIndex = -1;
    private int mLastRightIndex = -1;
    private float mLeftBitmapRatio;
    private float mMoveRatio;
    private boolean mStartScroll;
    private boolean mMoveRight;
    private boolean mIsNeedChange;
    private boolean mIsDoingAnimator;
    private float mLastScaleFactor;
    private float mScaleFactor;
    private final OnScaleGestureListener mOnScaleGestureListener = new OnScaleGestureListener() {
        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            return BeautyFilterScrollView.this.onScale(detector);
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            mLastScaleFactor = detector.getScaleFactor();
            return true;
        }

        @Override
        public void onScaleEnd(ScaleGestureDetector detector) {
        }
    };
    private Bitmap mLeftBitmap;
    private Bitmap mRightBitmap;
    private final OnGestureListener mOnGestureListener = new OnGestureListener() {
        @Override
        public boolean onDown(MotionEvent e) {
            mStartScroll = false;
            return false;
        }

        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            BeautyFilterScrollView.this.performClick();
            mRecordCore.setFocusPosition(e.getX(), e.getY());
            return false;
        }

        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
            return BeautyFilterScrollView.this.onScroll(e1, e2);
        }

        @Override
        public void onShowPress(MotionEvent e) {
        }

        @Override
        public void onLongPress(MotionEvent e) {
        }

        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
            return true;
        }
    };
    @NonNull
    private final ValueAnimator.AnimatorUpdateListener mAnimatorUpdateListener =
            new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(@NonNull ValueAnimator valueAnimator) {
                    mIsDoingAnimator = true;

                    float leftRatio = (float) valueAnimator.getAnimatedValue();
                    mFilterNameTextView.setVisibility(View.INVISIBLE);

                    BeautyItem leftFilterItem = mBeautyFilterType.getItem(mLeftIndex);
                    BeautyItem rightFilterItem = mBeautyFilterType.getItem(mRightIndex);
                    float leftSpecialRatio = (leftFilterItem != null ? leftFilterItem.getLevel() : 0) / 10.f;
                    float rightSpecialRatio = (rightFilterItem != null ? rightFilterItem.getLevel() : 0) / 10.f;
                    mRecordCore.setFilter(mLeftBitmap, leftSpecialRatio, mRightBitmap, rightSpecialRatio, leftRatio);

                    if (leftRatio == 0 || leftRatio == 1) {
                        mLeftBitmapRatio = leftRatio;
                        mIsDoingAnimator = false;
                        if (mIsNeedChange) {
                            mIsNeedChange = false;
                            mBeautyInfo.setSelectedItemIndex(mFilterIndex, (leftRatio == 0 ? mRightIndex : mLeftIndex));
                            doTextAnimator();
                        }
                    }
                }
            };

    public BeautyFilterScrollView(@NonNull Context context, TUIMultimediaRecordCore recordCore, BeautyInfo beautyInfo) {
        super(context);
        mRecordCore = recordCore;
        mBeautyInfo = beautyInfo;
        mFilterIndex = mBeautyInfo.getTypeIndexWithType(BeautyInnerType.BEAUTY_FILTER);
        mBeautyFilterType = mBeautyInfo.getBeautyType(mFilterIndex);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initViews() {
        inflate(getContext(), R.layout.multimedia_plugin_record_scroll_filter_view, this);

        mMaskLayout = findViewById(R.id.fl_filter_mask);
        mMaskLayout.setOnTouchListener(this);
        mFilterNameTextView = findViewById(R.id.tv_filter_name);
        mFilterNameTextView.setVisibility(INVISIBLE);
        mGestureDetector = new GestureDetector(getContext(), mOnGestureListener);
        mScaleGestureDetector = new ScaleGestureDetector(getContext(), mOnScaleGestureListener);
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initViews();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
    }

    @Override
    public boolean onTouch(View v, @NonNull MotionEvent event) {
        LiteavLog.i(TAG, "onTouch");
        if (v != mMaskLayout) {
            return false;
        }

        int pointerCount = event.getPointerCount();
        if (pointerCount >= 2) {
            mScaleGestureDetector.onTouchEvent(event);
            return true;
        } else if (pointerCount == 1) {
            mGestureDetector.onTouchEvent(event);
            if (mStartScroll && event.getAction() == MotionEvent.ACTION_UP) {
                doFilterAnimator();
            }
            return true;
        }
        return false;
    }

    private void doFilterAnimator() {
        LiteavLog.i(TAG, "doFilterAnimator");
        int filterSelectIndex = mBeautyFilterType.getSelectedItemIndex();
        ValueAnimator mFilterAnimator;
        if (mMoveRatio >= 0.2f) {
            mIsNeedChange = true;
            if (mMoveRight) {
                mFilterAnimator = generateValueAnimator(mLeftBitmapRatio, 1);
            } else {
                mFilterAnimator = generateValueAnimator(mLeftBitmapRatio, 0);
            }
        } else {
            if (filterSelectIndex == mLeftIndex) {
                mFilterAnimator = generateValueAnimator(mLeftBitmapRatio, 1);
            } else {
                mFilterAnimator = generateValueAnimator(mLeftBitmapRatio, 0);
            }
        }
        mFilterAnimator.addUpdateListener(mAnimatorUpdateListener);
        mFilterAnimator.start();
    }

    private ValueAnimator generateValueAnimator(float start, float end) {
        ValueAnimator animator = ValueAnimator.ofFloat(start, end);
        animator.setInterpolator(new LinearInterpolator());
        animator.setDuration(400);
        return animator;
    }

    public void doTextAnimator() {
        LiteavLog.i(TAG, "doTextAnimator");
        BeautyItem beautyItem = mBeautyFilterType.getSelectedItem();
        if (beautyItem == null) {
            return;
        }
        LiteavLog.i(TAG, "doTextAnimator text = " + beautyItem.getName());
        mFilterNameTextView.setText(beautyItem.getName());
        AlphaAnimation alphaAnimation = new AlphaAnimation(1, 0.3f);
        alphaAnimation.setDuration(1500);
        alphaAnimation.setInterpolator(new LinearInterpolator());
        alphaAnimation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                mFilterNameTextView.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                mFilterNameTextView.setVisibility(View.INVISIBLE);
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }
        });
        mFilterNameTextView.startAnimation(alphaAnimation);
    }

    public boolean onScroll(@NonNull MotionEvent downEvent, @NonNull MotionEvent moveEvent) {
        if (mIsDoingAnimator) {
            return true;
        }

        int filterSelectIndex = mBeautyFilterType.getSelectedItemIndex();
        boolean moveRight = moveEvent.getX() > downEvent.getX();
        if (moveRight && filterSelectIndex == 0) {
            return true;
        } else if (!moveRight && filterSelectIndex == mBeautyInfo.getItemSize(mFilterIndex) - 1) {
            return true;
        } else {
            mStartScroll = true;
            if (moveRight) {
                mLeftIndex = filterSelectIndex - 1;
                mRightIndex = filterSelectIndex;
            } else {
                mLeftIndex = filterSelectIndex;
                mRightIndex = filterSelectIndex + 1;
            }

            if (mLastLeftIndex != mLeftIndex) {
                BeautyItem beautyItem = mBeautyFilterType.getItem(mLeftIndex);
                mLeftBitmap = beautyItem != null ? beautyItem.getFilterBitmap() : null;
                mLastLeftIndex = mLeftIndex;
            }

            if (mLastRightIndex != mRightIndex) {
                BeautyItem beautyItem = mBeautyFilterType.getItem(mRightIndex);
                mRightBitmap = beautyItem != null ? beautyItem.getFilterBitmap() : null;
                mLastRightIndex = mRightIndex;
            }

            int width = mMaskLayout.getWidth();
            float dis = moveEvent.getX() - downEvent.getX();
            float leftBitmapRatio = Math.abs(dis) / (width * 1.0f);
            mMoveRatio = leftBitmapRatio;
            if (!moveRight) {
                leftBitmapRatio = 1 - leftBitmapRatio;
            }
            mMoveRight = moveRight;
            mLeftBitmapRatio = leftBitmapRatio;

            BeautyItem leftFilterItem = mBeautyFilterType.getItem(mLeftIndex);
            BeautyItem rightFilterItem = mBeautyFilterType.getItem(mRightIndex);
            float leftSpecialRatio = (leftFilterItem != null ? leftFilterItem.getLevel() : 0) / 10.f;
            float rightSpecialRatio = (rightFilterItem != null ? rightFilterItem.getLevel() : 0) / 10.f;
            mRecordCore.setFilter(mLeftBitmap, leftSpecialRatio, mRightBitmap, rightSpecialRatio, leftBitmapRatio);
            return true;
        }
    }


    public boolean onScale(@NonNull ScaleGestureDetector detector) {
        LiteavLog.i(TAG, "onScale");
        int maxZoom = mRecordCore.getMaxZoom();
        if (maxZoom == 0) {
            Log.i(TAG, "camera not support zoom");
            return false;
        }

        float factorOffset = detector.getScaleFactor() - mLastScaleFactor;

        mScaleFactor += factorOffset;
        mLastScaleFactor = detector.getScaleFactor();
        if (mScaleFactor < 0) {
            mScaleFactor = 0;
        }
        if (mScaleFactor > 1) {
            mScaleFactor = 1;
        }

        int zoomValue = Math.round(mScaleFactor * maxZoom);
        mRecordCore.setZoom(zoomValue);
        return false;
    }
}
