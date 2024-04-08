package com.tencent.qcloud.tuikit.tuicallkit.view.common;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.Scroller;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class SlideRecyclerView extends RecyclerView {
    private static final String TAG                 = "SlideRecyclerView";
    private static final int    INVALID_POSITION    = -1;
    private static final int    INVALID_CHILD_WIDTH = -1;
    private static final int    SNAP_VELOCITY       = 600;

    private VelocityTracker mVelocityTracker;
    private ViewGroup       mFlingView;         // touch view
    private Scroller        mScroller;
    private Rect            mTouchFrame;        // the frame of the subview
    private float           mLastX;
    private float           mFirstX;
    private float           mFirstY;

    private int     mTouchSlop;      // the minimum slide distance of system
    private boolean mIsSlide;
    private int     mPosition;       // the touch view's position
    private int     mMenuViewWidth;
    private boolean mDisableRecyclerViewSlide;

    public SlideRecyclerView(Context context) {
        this(context, null);
    }

    public SlideRecyclerView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SlideRecyclerView(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        mTouchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
        mScroller = new Scroller(context);
    }

    public void disableRecyclerViewSlide(boolean disable) {
        mDisableRecyclerViewSlide = disable;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent e) {
        int x = (int) e.getX();
        int y = (int) e.getY();
        obtainVelocity(e);
        switch (e.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (!mScroller.isFinished()) {
                    mScroller.abortAnimation();
                }
                mFirstX = mLastX = x;
                mFirstY = y;

                mPosition = pointToPosition(x, y);
                if (mPosition != INVALID_POSITION) {
                    View view = mFlingView;

                    mFlingView = (ViewGroup) getChildAt(mPosition - ((LinearLayoutManager) getLayoutManager())
                            .findFirstVisibleItemPosition());
                    // if touching view is not same as the open view, close the open view
                    if (view != null && mFlingView != view && view.getScrollX() != 0) {
                        view.scrollTo(0, 0);
                    }

                    if (mFlingView.getChildCount() == 2) {
                        mMenuViewWidth = mFlingView.getChildAt(1).getWidth();
                    } else {
                        mMenuViewWidth = INVALID_CHILD_WIDTH;
                    }
                }
                break;
            case MotionEvent.ACTION_MOVE:
                mVelocityTracker.computeCurrentVelocity(1000);

                float xVelocity = mVelocityTracker.getXVelocity();
                float yVelocity = mVelocityTracker.getYVelocity();

                View topView = ((LinearLayoutManager) getLayoutManager()).findViewByPosition(0);
                if (topView == mFlingView) {
                    mIsSlide = false;
                } else if (Math.abs(xVelocity) > SNAP_VELOCITY && Math.abs(xVelocity) > Math.abs(yVelocity)
                        || Math.abs(x - mFirstX) >= mTouchSlop
                        && Math.abs(x - mFirstX) > Math.abs(y - mFirstY)) {
                    mIsSlide = true;
                    return true;
                }
                break;
            case MotionEvent.ACTION_UP:
                releaseVelocity();
                break;
            default:
                break;
        }
        return super.onInterceptTouchEvent(e);
    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {
        if (mIsSlide && mPosition != INVALID_POSITION) {
            float x = e.getX();
            obtainVelocity(e);
            switch (e.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    break;
                case MotionEvent.ACTION_MOVE:

                    if (mMenuViewWidth != INVALID_CHILD_WIDTH) {
                        float dx = Math.abs(mFlingView.getScrollX() + (mLastX - x));
                        if (dx <= mMenuViewWidth && dx > 0) {
                            if (mMenuViewWidth != INVALID_CHILD_WIDTH) {
                                int scrollX = mFlingView.getScrollX();
                                mVelocityTracker.computeCurrentVelocity(1000);

                                if (isRTL()) {
                                    openRightExtendView(scrollX);
                                } else {
                                    openLeftExtendView(scrollX);
                                }
                                invalidate();
                            }
                            mMenuViewWidth = INVALID_CHILD_WIDTH;
                            mIsSlide = false;
                            mPosition = INVALID_POSITION;
                        }
                        mLastX = x;
                    }
                    break;
                case MotionEvent.ACTION_UP:
                    releaseVelocity();
                    break;
                default:
                    break;
            }
            return true;
        } else {
            closeMenu();
            releaseVelocity();
        }
        return super.onTouchEvent(e);
    }

    private void openRightExtendView(int scrollX) {
        if (mVelocityTracker.getXVelocity() >= SNAP_VELOCITY) {
            startScroll(scrollX, scrollX - mMenuViewWidth);
        } else if (mVelocityTracker.getXVelocity() < -SNAP_VELOCITY) {
            startScroll(scrollX, -scrollX);
        } else if (scrollX >= mMenuViewWidth / 2) {
            startScroll(scrollX, scrollX - mMenuViewWidth);
        } else {
            startScroll(scrollX, -scrollX);
        }
    }

    private void openLeftExtendView(int scrollX) {
        if (mVelocityTracker.getXVelocity() < -SNAP_VELOCITY) {
            startScroll(scrollX, mMenuViewWidth - scrollX);
        } else if (mVelocityTracker.getXVelocity() >= SNAP_VELOCITY) {
            startScroll(scrollX, -scrollX);
        } else if (scrollX >= mMenuViewWidth / 2) {
            startScroll(scrollX, mMenuViewWidth - scrollX);
        } else {
            startScroll(scrollX, -scrollX);
        }
    }

    private void startScroll(int startX, int dx) {
        mScroller.startScroll(startX, 0, dx, 0);
    }

    private void releaseVelocity() {
        if (mVelocityTracker != null) {
            mVelocityTracker.clear();
            mVelocityTracker.recycle();
            mVelocityTracker = null;
        }
    }

    private void obtainVelocity(MotionEvent event) {
        if (mVelocityTracker == null) {
            mVelocityTracker = VelocityTracker.obtain();
        }
        mVelocityTracker.addMovement(event);
    }

    public int pointToPosition(int x, int y) {
        int firstPosition = ((LinearLayoutManager) getLayoutManager()).findFirstVisibleItemPosition();
        Rect frame = mTouchFrame;
        if (frame == null) {
            mTouchFrame = new Rect();
            frame = mTouchFrame;
        }

        final int count = getChildCount();
        for (int i = count - 1; i >= 0; i--) {
            final View child = getChildAt(i);
            if (child.getVisibility() == View.VISIBLE) {
                child.getHitRect(frame);
                if (frame.contains(x, y)) {
                    return firstPosition + i;
                }
            }
        }
        return INVALID_POSITION;
    }

    @Override
    public void computeScroll() {
        if (mScroller.computeScrollOffset()) {
            if (mDisableRecyclerViewSlide) {
                mFlingView.scrollTo(0, 0);
            } else {
                mFlingView.scrollTo(mScroller.getCurrX(), mScroller.getCurrY());
            }
            invalidate();
        }
    }

    public void closeMenu() {
        if (mFlingView != null && mFlingView.getScrollX() != 0) {
            mFlingView.scrollTo(0, 0);
        }
    }

    private boolean isRTL() {
        Configuration configuration = getContext().getResources().getConfiguration();
        int layoutDirection = configuration.getLayoutDirection();
        return layoutDirection == View.LAYOUT_DIRECTION_RTL;
    }
}
