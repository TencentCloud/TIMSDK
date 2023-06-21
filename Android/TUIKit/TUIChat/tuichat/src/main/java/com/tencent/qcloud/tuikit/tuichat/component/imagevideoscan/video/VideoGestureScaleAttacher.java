package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.video;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.TextureView;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewParent;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.Interpolator;
import android.widget.ImageView;
import android.widget.OverScroller;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;

public class VideoGestureScaleAttacher {
    private static final float EDGE_DRAG_EVENT_INTERCEPT_THRESHOLD = 50f;
    private static final int EDGE_NONE = -1;
    private static final int EDGE_LEFT = 0;
    private static final int EDGE_RIGHT = 1;
    private static final int EDGE_BOTH = 2;
    private static final float DEFAULT_MAX_SCALE = 3.0f;
    private static final float DEFAULT_MID_SCALE = 1.75f;
    private static final float DEFAULT_MIN_SCALE = 1.0f;
    private static final int DEFAULT_ZOOM_DURATION = 200;
    private ScaleGestureDetector scaleGestureDetector;
    private float mTouchSlop;
    private float mMinimumVelocity;
    private VelocityTracker mVelocityTracker;
    private boolean mIsDragging;
    private float mLastTouchX;
    private float mLastTouchY;
    private OnScaleListener internalScaleListener;
    private VideoView view;
    private float minScale = DEFAULT_MIN_SCALE;
    private float middleScale = DEFAULT_MID_SCALE;
    private float maxScale = DEFAULT_MAX_SCALE;
    private int scrollEdge;
    private final Matrix transferMatrix = new Matrix();
    private final RectF rectF = new RectF();
    private final float[] mMatrixValues = new float[9];
    private ImageView.ScaleType scaleType = ImageView.ScaleType.FIT_CENTER;
    private final Interpolator interpolator = new AccelerateDecelerateInterpolator();

    private int zoomDuration = DEFAULT_ZOOM_DURATION;

    private FlingRunnable currentFlingRunnable;

    private VideoGestureScaleAttacher() {}

    public static void attach(VideoView view) {
        VideoGestureScaleAttacher attacher = new VideoGestureScaleAttacher();
        attacher.view = view;
        if (view == null || view.getContext() == null) {
            return;
        }
        Context context = view.getContext();
        final ViewConfiguration configuration = ViewConfiguration.get(context);
        attacher.mMinimumVelocity = configuration.getScaledMinimumFlingVelocity();
        attacher.mTouchSlop = configuration.getScaledTouchSlop();
        attacher.internalScaleListener = new OnScaleListener() {
            @Override
            public boolean onScale(ScaleGestureDetector detector) {
                float scaleFactor = detector.getScaleFactor();
                if (Float.isNaN(scaleFactor) || Float.isInfinite(scaleFactor)) {
                    return false;
                }
                float focusX = detector.getFocusX();
                float focusY = detector.getFocusY();
                return attacher.scale(scaleFactor, focusX, focusY);
            }

            @Override
            public void onFling(float startX, float startY, float velocityX, float velocityY) {
                if (attacher.scaleGestureDetector.isInProgress()) {
                    return;
                }
                attacher.currentFlingRunnable = attacher.new FlingRunnable(attacher.view);
                attacher.currentFlingRunnable.fling(attacher.getViewWidth(), attacher.getViewHeight(), (int) velocityX, (int) velocityY);
                ThreadUtils.runOnUiThread(attacher.currentFlingRunnable);
            }

            @Override
            public void onDrag(float dx, float dy) {
                if (attacher.scaleGestureDetector.isInProgress()) {
                    return;
                }
                attacher.transferMatrix.postTranslate(dx, dy);
                attacher.invalidateView();
                attacher.checkMatrixBounds();
                if (attacher.scrollEdge == EDGE_BOTH && Math.abs(dx) >= EDGE_DRAG_EVENT_INTERCEPT_THRESHOLD
                    || (attacher.scrollEdge == EDGE_LEFT && dx >= EDGE_DRAG_EVENT_INTERCEPT_THRESHOLD)
                    || (attacher.scrollEdge == EDGE_RIGHT && dx <= -EDGE_DRAG_EVENT_INTERCEPT_THRESHOLD)) {
                    ViewParent viewParent = view.getParent();
                    if (viewParent != null) {
                        viewParent.requestDisallowInterceptTouchEvent(false);
                    }
                } else {
                    ViewParent viewParent = view.getParent();
                    if (viewParent != null) {
                        viewParent.requestDisallowInterceptTouchEvent(true);
                    }
                }
            }
        };
        attacher.scaleGestureDetector = new ScaleGestureDetector(context, attacher.internalScaleListener);

        view.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                attacher.scaleGestureDetector.onTouchEvent(event);
                attacher.processTouchEvent(event);
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN: {
                        attacher.cancelFling();
                        ViewParent viewParent = view.getParent();
                        if (viewParent != null) {
                            viewParent.requestDisallowInterceptTouchEvent(true);
                        }
                        break;
                    }
                    case MotionEvent.ACTION_CANCEL:
                        onActionCancel();
                        break;
                    case MotionEvent.ACTION_UP: {
                        onActionCancel();
                        break;
                    }
                    default:
                        break;
                }
                return true;
            }

            private void onActionCancel() {
                if (attacher.getScale() < attacher.minScale) {
                    RectF rect = attacher.getDisplayRect();
                    view.post(attacher.new AnimatedZoomRunnable(attacher.getScale(), attacher.minScale, rect.centerX(), rect.centerY()));
                } else if (attacher.getScale() > attacher.maxScale) {
                    RectF rect = attacher.getDisplayRect();
                    view.post(attacher.new AnimatedZoomRunnable(attacher.getScale(), attacher.maxScale, rect.centerX(), rect.centerY()));
                }
            }
        });
    }

    public void cancelFling() {
        if (currentFlingRunnable != null) {
            currentFlingRunnable.cancelFling();
            currentFlingRunnable = null;
        }
    }

    private boolean scale(float scaleFactor, float focusX, float focusY) {
        if ((getScale() <= maxScale || scaleFactor < 1f) && (getScale() >= minScale || scaleFactor > 1f)) {
            transferMatrix.postScale(scaleFactor, scaleFactor, focusX, focusY);
            invalidateView();
            checkMatrixBounds();
            return true;
        }
        return false;
    }

    private void invalidateView() {
        Matrix baseMatrix = view.getBaseMatrix();
        Matrix matrix = new Matrix();
        matrix.setConcat(baseMatrix, transferMatrix);
        view.setTransform(matrix);
        view.invalidate();
    }

    private boolean processTouchEvent(MotionEvent ev) {
        final int action = ev.getAction();
        switch (action & MotionEvent.ACTION_MASK) {
            case MotionEvent.ACTION_DOWN:

                mVelocityTracker = VelocityTracker.obtain();
                if (null != mVelocityTracker) {
                    mVelocityTracker.addMovement(ev);
                }

                mLastTouchX = ev.getX();
                mLastTouchY = ev.getY();
                mIsDragging = false;

                break;
            case MotionEvent.ACTION_MOVE:
                final float x = ev.getX();
                final float y = ev.getY();
                final float dx = x - mLastTouchX;
                final float dy = y - mLastTouchY;

                if (!mIsDragging) {
                    // Use Pythagoras to see if drag length is larger than
                    // touch slop
                    mIsDragging = Math.sqrt((dx * dx) + (dy * dy)) >= mTouchSlop;
                }

                if (mIsDragging) {
                    internalScaleListener.onDrag(dx, dy);
                    mLastTouchX = x;
                    mLastTouchY = y;

                    if (null != mVelocityTracker) {
                        mVelocityTracker.addMovement(ev);
                    }
                }
                break;
            case MotionEvent.ACTION_CANCEL:
                // Recycle Velocity Tracker
                if (null != mVelocityTracker) {
                    mVelocityTracker.recycle();
                    mVelocityTracker = null;
                }
                break;
            case MotionEvent.ACTION_UP:
                if (mIsDragging) {
                    if (null != mVelocityTracker) {
                        mLastTouchX = ev.getX();
                        mLastTouchY = ev.getY();

                        // Compute velocity within the last 1000ms
                        mVelocityTracker.addMovement(ev);
                        mVelocityTracker.computeCurrentVelocity(1000);

                        final float vX = mVelocityTracker.getXVelocity();
                        final float vY = mVelocityTracker.getYVelocity();

                        // If the velocity is greater than minVelocity, call
                        // listener
                        if (Math.max(Math.abs(vX), Math.abs(vY)) >= mMinimumVelocity) {
                            internalScaleListener.onFling(mLastTouchX, mLastTouchY, -vX, -vY);
                        }
                    }
                }

                // Recycle Velocity Tracker
                if (null != mVelocityTracker) {
                    mVelocityTracker.recycle();
                    mVelocityTracker = null;
                }
                break;
            default:
                break;
        }
        return true;
    }

    private RectF getDisplayRect() {
        rectF.set(0, 0, view.getWidth(), view.getHeight());
        Matrix matrix = new Matrix();
        view.getTransform(matrix);
        matrix.mapRect(rectF);
        return rectF;
    }

    public float getScale() {
        return (float) Math.sqrt((Math.pow(getValue(transferMatrix, Matrix.MSCALE_X), 2) + Math.pow(getValue(transferMatrix, Matrix.MSCALE_Y), 2)) / 2);
    }

    private void checkMatrixBounds() {
        final RectF rect = getDisplayRect();
        final float height = rect.height();
        final float width = rect.width();
        float deltaX = 0;
        float deltaY = 0;
        final int viewHeight = getViewHeight();
        if (height <= viewHeight) {
            switch (scaleType) {
                case FIT_START:
                    deltaY = -rect.top;
                    break;
                case FIT_END:
                    deltaY = viewHeight - height - rect.top;
                    break;
                default:
                    deltaY = (viewHeight - height) / 2 - rect.top;
                    break;
            }
        } else if (rect.top > 0) {
            deltaY = -rect.top;
        } else if (rect.bottom < viewHeight) {
            deltaY = viewHeight - rect.bottom;
        }
        final int viewWidth = getViewWidth();
        if (width <= viewWidth) {
            switch (scaleType) {
                case FIT_START:
                    deltaX = -rect.left;
                    break;
                case FIT_END:
                    deltaX = viewWidth - width - rect.left;
                    break;
                default:
                    deltaX = (viewWidth - width) / 2 - rect.left;
                    break;
            }
            scrollEdge = EDGE_BOTH;
        } else if (rect.left > 0) {
            scrollEdge = EDGE_LEFT;
            deltaX = -rect.left;
        } else if (rect.right < viewWidth) {
            deltaX = viewWidth - rect.right;
            scrollEdge = EDGE_RIGHT;
        } else {
            scrollEdge = EDGE_NONE;
        }
        // Finally actually translate the matrix
        transferMatrix.postTranslate(deltaX, deltaY);
        invalidateView();
    }

    private int getViewWidth() {
        return view.getWidth() - view.getPaddingLeft() - view.getPaddingRight();
    }

    private int getViewHeight() {
        return view.getHeight() - view.getPaddingTop() - view.getPaddingBottom();
    }

    /**
     * Helper method that 'unpacks' a Matrix and returns the required value
     *
     * @param matrix     Matrix to unpack
     * @param whichValue Which value from Matrix.M* to return
     * @return returned value
     */
    private float getValue(Matrix matrix, int whichValue) {
        matrix.getValues(mMatrixValues);
        return mMatrixValues[whichValue];
    }

    private class AnimatedZoomRunnable implements Runnable {
        private final float focalX;
        private final float focalY;
        private final long startTime;
        private final float zoomStart;
        private final float zoomEnd;

        public AnimatedZoomRunnable(final float currentZoom, final float targetZoom, final float focalX, final float focalY) {
            this.focalX = focalX;
            this.focalY = focalY;
            startTime = System.currentTimeMillis();
            zoomStart = currentZoom;
            zoomEnd = targetZoom;
        }

        @Override
        public void run() {
            float t = interpolate();
            float scale = zoomStart + t * (zoomEnd - zoomStart);
            float deltaScale = scale / getScale();
            scale(deltaScale, focalX, focalY);
            // We haven't hit our target scale yet, so post ourselves again
            if (t < 1f) {
                view.postOnAnimation(this);
            }
        }

        private float interpolate() {
            float t = 1f * (System.currentTimeMillis() - startTime) / zoomDuration;
            t = Math.min(1f, t);
            t = interpolator.getInterpolation(t);
            return t;
        }
    }

    public class FlingRunnable implements Runnable {
        private final OverScroller mScroller;
        private int mCurrentX;
        private int mCurrentY;
        private TextureView view;

        public FlingRunnable(TextureView view) {
            mScroller = new OverScroller(view.getContext());
            this.view = view;
        }

        public void cancelFling() {
            mScroller.forceFinished(true);
        }

        public void fling(int viewWidth, int viewHeight, int velocityX, int velocityY) {
            final RectF rect = getDisplayRect();
            if (rect == null) {
                return;
            }
            final int startX = Math.round(-rect.left);
            final int minX;
            final int maxX;
            final int minY;
            final int maxY;
            if (viewWidth < rect.width()) {
                minX = 0;
                maxX = Math.round(rect.width() - viewWidth);
            } else {
                minX = maxX = startX;
            }
            final int startY = Math.round(-rect.top);
            if (viewHeight < rect.height()) {
                minY = 0;
                maxY = Math.round(rect.height() - viewHeight);
            } else {
                minY = maxY = startY;
            }
            mCurrentX = startX;
            mCurrentY = startY;
            // If we actually can move, fling the scroller
            if (startX != maxX || startY != maxY) {
                mScroller.fling(startX, startY, velocityX, velocityY, minX, maxX, minY, maxY, 0, 0);
            }
        }

        @Override
        public void run() {
            if (mScroller.isFinished()) {
                return; // remaining post that should not be handled
            }
            if (mScroller.computeScrollOffset()) {
                final int newX = mScroller.getCurrX();
                final int newY = mScroller.getCurrY();
                transferMatrix.postTranslate(mCurrentX - newX, mCurrentY - newY);
                invalidateView();
                checkMatrixBounds();
                mCurrentX = newX;
                mCurrentY = newY;
                // Post On animation
                view.postOnAnimation(this);
            }
        }
    }

    public static class OnScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {
        public void onFling(float startX, float startY, float velocityX, float velocityY) {}

        public void onDrag(float dx, float dy) {}
    }
}
