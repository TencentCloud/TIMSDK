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

/**
 * 支持左滑删除的RecyclerView
 */
public class SlideRecyclerView extends RecyclerView {
    private static final String TAG                 = "SlideRecyclerView";
    private static final int    INVALID_POSITION    = -1;  // 触摸到的点不在子View范围内
    private static final int    INVALID_CHILD_WIDTH = -1;  // 子ItemView不含两个子View
    private static final int    SNAP_VELOCITY       = 600; // 最小滑动速度

    private VelocityTracker mVelocityTracker;   // 速度追踪器
    private ViewGroup       mFlingView;         // 触碰的子View
    private Scroller        mScroller;          // 触碰动画
    private Rect            mTouchFrame;        // 子View所在的矩形范围
    private float           mLastX;             // 滑动过程中记录上次触碰点X
    private float           mFirstX;
    private float           mFirstY;   // 首次触碰范围

    private int     mTouchSlop;      // 认为是滑动的最小距离（一般由系统提供）
    private boolean mIsSlide;        // 是否滑动子View
    private int     mPosition;       // 触碰的view的位置
    private int     mMenuViewWidth;  // 菜单按钮宽度
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
                // 获取触碰点所在的position
                mPosition = pointToPosition(x, y);
                if (mPosition != INVALID_POSITION) {
                    View view = mFlingView;
                    // 获取触碰点所在的view
                    mFlingView = (ViewGroup) getChildAt(mPosition - ((LinearLayoutManager) getLayoutManager())
                            .findFirstVisibleItemPosition());
                    // 如果之前触碰的view已经打开，而当前碰到的view不是那个view则立即关闭之前的view
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
                // 此处有俩判断，满足其一则认为是侧滑：
                // 1.如果x方向速度大于y方向速度，且大于最小速度限制；
                // 2.如果x方向的侧滑距离大于y方向滑动距离，且x方向达到最小滑动距离；
                float xVelocity = mVelocityTracker.getXVelocity();
                float yVelocity = mVelocityTracker.getYVelocity();

                //找到最上面第一个view，不处理滑动事件但是也不拦截后续事件
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
                    // 随手指滑动
                    if (mMenuViewWidth != INVALID_CHILD_WIDTH) {
                        float dx = Math.abs(mFlingView.getScrollX() + (mLastX - x));
                        if (dx <= mMenuViewWidth && dx > 0) {
                            if (mMenuViewWidth != INVALID_CHILD_WIDTH) {
                                int scrollX = mFlingView.getScrollX();
                                mVelocityTracker.computeCurrentVelocity(1000);
                                // 此处有两个原因决定是否打开菜单：
                                // 1.菜单被拉出宽度大于菜单宽度一半；
                                // 2.横向滑动速度大于最小滑动速度；
                                // 注意:向左滑则速度为负值

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
            // 防止RecyclerView正常滑动时，还有菜单未关闭
            closeMenu();
            releaseVelocity();
        }
        return super.onTouchEvent(e);
    }

    private void openRightExtendView(int scrollX) {
        if (mVelocityTracker.getXVelocity() >= SNAP_VELOCITY) { //向右滑的速度大于600,则打开
            startScroll(scrollX, scrollX - mMenuViewWidth);
        } else if (mVelocityTracker.getXVelocity() < -SNAP_VELOCITY) { //向左滑的速度达到最低速度,则关闭
            startScroll(scrollX, -scrollX);
        } else if (scrollX >= mMenuViewWidth / 2) {
            startScroll(scrollX, scrollX - mMenuViewWidth);
        } else {
            startScroll(scrollX, -scrollX);
        }
    }

    private void openLeftExtendView(int scrollX) {
        if (mVelocityTracker.getXVelocity() < -SNAP_VELOCITY) {    //向左侧滑达到侧滑最低速度，则打开
            startScroll(scrollX, mMenuViewWidth - scrollX);
        } else if (mVelocityTracker.getXVelocity() >= SNAP_VELOCITY) {  //向右侧滑达到侧滑最低速度，则关闭
            startScroll(scrollX, -scrollX);
        } else if (scrollX >= mMenuViewWidth / 2) { // 如果超过删除按钮一半，则打开
            startScroll(scrollX, mMenuViewWidth - scrollX);
        } else {    // 其他情况则关闭
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
