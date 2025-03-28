package com.tencent.cloud.tuikit.roomkit.view.main.conferenceinvitation;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.customview.widget.ViewDragHelper;

import com.tencent.cloud.tuikit.roomkit.R;

public class SlideToAcceptView extends FrameLayout {

    private final int SLIDE_SPEED = 1000;

    private ViewGroup      mRootView;
    private ImageView      mImageSlideIcon;
    private ViewDragHelper mViewDragHelper;
    private AcceptListener mListener;
    private boolean        isAccepted = false;

    public SlideToAcceptView(@NonNull Context context) {
        this(context, null);
    }

    public SlideToAcceptView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SlideToAcceptView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        View.inflate(context, R.layout.tuiroomkit_view_slide_to_accept, this);
        mRootView = findViewById(R.id.view_slide_to_accept_root);
        mImageSlideIcon = findViewById(R.id.img_slide);
        createViewDragHelper();
    }

    private void createViewDragHelper() {
        mViewDragHelper = ViewDragHelper.create(mRootView, 0.3f, new ViewDragHelper.Callback() {
            private int capturedChildTop;

            @Override
            public boolean tryCaptureView(@NonNull View child, int pointerId) {
                return child == mImageSlideIcon;
            }

            @Override
            public int clampViewPositionHorizontal(@NonNull View child, int left, int dx) {
                int slideIconWidth = mImageSlideIcon.getWidth();
                int rootViewWidth = mRootView.getWidth();
                int paddingStart = getPaddingStart();
                int maxDistance = rootViewWidth - getPaddingEnd() - slideIconWidth;

                if (left < paddingStart) {
                    return paddingStart;
                } else if (left > maxDistance) {
                    return maxDistance;
                }
                return left;
            }

            @Override
            public int clampViewPositionVertical(@NonNull View child, int top, int dy) {
                return mRootView.getHeight() / 2 - child.getHeight() / 2;
            }

            @Override
            public void onViewCaptured(@NonNull View capturedChild, int activePointerId) {
                super.onViewCaptured(capturedChild, activePointerId);
                capturedChildTop = capturedChild.getTop();
            }

            @Override
            public void onViewReleased(@NonNull View releasedChild, float xVel, float yVel) {
                super.onViewReleased(releasedChild, xVel, yVel);
                int currentLeft = releasedChild.getLeft();
                int slideImageWidth = mImageSlideIcon.getWidth();
                int rootViewWidth = mRootView.getWidth();
                int halfWidth = rootViewWidth / 2;
                if (currentLeft <= halfWidth && xVel < SLIDE_SPEED) {
                    mViewDragHelper.settleCapturedViewAt(getPaddingStart(), capturedChildTop);
                } else {
                    mViewDragHelper.settleCapturedViewAt(rootViewWidth - getPaddingEnd() - slideImageWidth, capturedChildTop);
                }
                invalidate();
            }

            @Override
            public void onViewDragStateChanged(int state) {
                super.onViewDragStateChanged(state);
                int maxDistance = mRootView.getWidth() - getPaddingEnd() - mImageSlideIcon.getWidth();
                int slideImageLeft = mImageSlideIcon.getLeft();
                if (state == ViewDragHelper.STATE_IDLE) {
                    if (slideImageLeft == maxDistance) {
                        if (!isAccepted) {
                            isAccepted = true;
                            if (mListener != null) {
                                mListener.onAccept();
                            }
                        }
                    }
                }
            }
        });
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return mViewDragHelper.shouldInterceptTouchEvent(ev);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        mViewDragHelper.processTouchEvent(event);
        return true;
    }

    @Override
    public void computeScroll() {
        super.computeScroll();
        if (mViewDragHelper != null) {
            if (mViewDragHelper.continueSettling(true)) {
                invalidate();
            }
        }
    }

    public interface AcceptListener {
        void onAccept();
    }

    public void setListener(AcceptListener listener) {
        mListener = listener;
    }
}

