package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;

public class ConferenceVideoView extends TUIVideoView {
    private final Context mContext;

    private ClickListener mClickListener = null;
    private boolean       mIsEnableScale = false;

    private ScaleListener   mScaleListener;
    private GestureDetector mClickGestureDetector;

    public ConferenceVideoView(Context context) {
        this(context, null);
    }

    public ConferenceVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (mClickListener != null) {
                    mClickGestureDetector.onTouchEvent(event);
                }
                if (mIsEnableScale) {
                    mScaleListener.handleScaleEvent(v, event);
                }
                return true;
            }
        });
    }

    public interface ClickListener {
        void onSingleClick(View view);

        void onDoubleClick(View view);
    }

    public void setClickListener(ClickListener clickListener) {
        mClickListener = clickListener;
        mClickGestureDetector = new GestureDetector(mContext, new ClickGestureListener());
    }

    public void enableScale(boolean enable) {
        mIsEnableScale = enable;
        if (enable) {
            mScaleListener = new ScaleListener();
        }
    }

    private class ClickGestureListener extends GestureDetector.SimpleOnGestureListener {
        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            if (mClickListener != null) {
                mClickListener.onSingleClick(ConferenceVideoView.this);
            }
            return true;
        }

        @Override
        public boolean onDoubleTap(MotionEvent e) {
            if (mClickListener != null) {
                mClickListener.onDoubleClick(ConferenceVideoView.this);
            }
            return true;
        }

        @Override
        public boolean onDown(MotionEvent e) {
            return true;
        }
    }

    private class ScaleListener {
        private static final float MAX_SCALE = 5.0f;
        private static final float MIN_SCALE = 1.0f;

        private float  mPressedPoint1X = 0;
        private float  mPressedPoint2X = 0;
        private float  mPressedPoint1Y = 0;
        private float  mPressedPoint2Y = 0;
        private double mDistBeforeMove = 0;

        public boolean handleScaleEvent(View v, MotionEvent event) {
            int pointerCount = event.getPointerCount();
            switch (event.getAction() & MotionEvent.ACTION_MASK) {
                case MotionEvent.ACTION_UP:
                    if (pointerCount == 2) {
                        mPressedPoint1X = 0;
                        mPressedPoint1Y = 0;
                        mPressedPoint2X = 0;
                        mPressedPoint2Y = 0;
                    }
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (pointerCount == 2) {
                        float firstPointX = event.getX(0);
                        float secondPointX = event.getX(1);
                        float firstPointY = event.getY(0);
                        float secondPointY = event.getY(1);

                        double changeX1 = firstPointX - mPressedPoint1X;
                        double changeX2 = secondPointX - mPressedPoint2X;
                        double changeY1 = firstPointY - mPressedPoint1Y;
                        double changeY2 = secondPointY - mPressedPoint2Y;

                        if (getScaleX() > 1) {
                            float lessX = (float) ((changeX1) / 2 + (changeX2) / 2);
                            float lessY = (float) ((changeY1) / 2 + (changeY2) / 2);
                            setSelfPivot(-lessX, -lessY);
                        }

                        double mDistAfterMove = spacing(event);
                        double space = mDistAfterMove - mDistBeforeMove;
                        float scale = (float) (getScaleX() + space / v.getWidth());
                        if (scale < MIN_SCALE) {
                            setScale(MIN_SCALE);
                        } else if (scale > MAX_SCALE) {
                            setScale(MAX_SCALE);
                        } else {
                            setScale(scale);
                        }
                    }
                    break;
                case MotionEvent.ACTION_POINTER_DOWN:
                    if (pointerCount == 2) {
                        mPressedPoint1X = event.getX(0);
                        mPressedPoint2X = event.getX(1);
                        mPressedPoint1Y = event.getY(0);
                        mPressedPoint2Y = event.getY(1);
                        mDistBeforeMove = spacing(event);
                    }
                    break;
                case MotionEvent.ACTION_POINTER_UP:
                    break;
                default:
                    break;
            }
            return true;
        }

        private void setSelfPivot(float lessX, float lessY) {
            float setPivotX;
            float setPivotY;
            setPivotX = getPivotX() + lessX;
            setPivotY = getPivotY() + lessY;
            if (setPivotX < 0 && setPivotY < 0) {
                setPivotX = 0;
                setPivotY = 0;
            } else if (setPivotX > 0 && setPivotY < 0) {
                setPivotY = 0;
                if (setPivotX > getWidth()) {
                    setPivotX = getWidth();
                }
            } else if (setPivotX < 0 && setPivotY > 0) {
                setPivotX = 0;
                if (setPivotY > getHeight()) {
                    setPivotY = getHeight();
                }
            } else {
                if (setPivotX > getWidth()) {
                    setPivotX = getWidth();
                }
                if (setPivotY > getHeight()) {
                    setPivotY = getHeight();
                }
            }
            setPivot(setPivotX, setPivotY);
        }

        private double spacing(MotionEvent event) {
            if (event.getPointerCount() == 2) {
                float x = event.getX(0) - event.getX(1);
                float y = event.getY(0) - event.getY(1);
                return Math.sqrt(x * x + y * y);
            } else {
                return 0;
            }
        }

        private void setPivot(float x, float y) {
            setPivotX(x);
            setPivotY(y);
        }

        private void setScale(float scale) {
            setScaleX(scale);
            setScaleY(scale);
        }
    }
}
