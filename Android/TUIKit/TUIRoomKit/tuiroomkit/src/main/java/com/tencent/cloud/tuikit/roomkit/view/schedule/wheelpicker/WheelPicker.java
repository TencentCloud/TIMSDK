package com.tencent.cloud.tuikit.roomkit.view.schedule.wheelpicker;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Camera;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Region;
import android.os.Handler;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.widget.Scroller;

import com.tencent.cloud.tuikit.roomkit.R;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class WheelPicker extends View implements IWheelPicker, Runnable {
    private final Handler                mHandler;
    private       Paint                  mPaint;
    private       Scroller               mScroller;
    private       VelocityTracker        mTracker;
    private       OnItemSelectedListener mOnItemSelectedListener;
    private       OnWheelChangeListener  mOnWheelChangeListener;
    private       Rect                   mRectDrawn;
    private       Rect                   mRectIndicatorHead;
    private       Rect                   mRectIndicatorFoot;
    private       Rect                   mRectCurrentItem;
    private       Camera                 mCamera;
    private       Matrix                 mMatrixRotate;
    private       Matrix                 mMatrixDepth;
    private       List<String>           mData = new ArrayList<>();
    private       String                 mMaxWidthText;
    private       int                    mVisibleItemCount;
    private       int                    mDrawnItemCount;
    private       int                    mHalfDrawnItemCount;
    private       int                    mTextMaxWidth;
    private       int                    mTextMaxHeight;
    private       int                    mItemTextColor;
    private       int                    mSelectedItemTextColor;
    private       int                    mItemTextSize;
    private       int                    mIndicatorSize;
    private       int                    mIndicatorColor;
    private       int                    mCurtainColor;
    private       int                    mItemSpace;
    private       int                    mItemAlign;
    private       int                    mItemHeight;
    private       int                    mHalfItemHeight;
    private       int                    mHalfWheelHeight;
    private       int                    mSelectedItemPosition;
    private       int                    mCurrentItemPosition;
    private       int                    mMinFlingY;
    private       int                    mMaxFlingY;
    private       int                    mMinimumVelocity;
    private       int                    mMaximumVelocity;
    private       int                    mWheelCenterX;
    private       int                    mWheelCenterY;
    private       int                    mDrawnCenterX;
    private       int                    mDrawnCenterY;
    private       int                    mScrollOffsetY;
    private       int                    mTextMaxWidthPosition;
    private       int                    mLastPointY;
    private       int                    mDownPointY;
    private       int                    mTouchSlop;
    private       boolean                hasSameWidth;
    private       boolean                hasIndicator;
    private       boolean                hasCurtain;
    private       boolean                hasAtmospheric;
    private       boolean                isCyclic;
    private       boolean                isCurved;
    private       boolean                isClick;
    private       boolean                isForceFinishScroll;

    public WheelPicker(Context context) {
        this(context, (AttributeSet) null);
    }

    public WheelPicker(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mHandler = new Handler();
        this.mMinimumVelocity = 50;
        this.mMaximumVelocity = 8000;
        this.mTouchSlop = 8;
        TypedArray wheelFunction = context.obtainStyledAttributes(attrs, R.styleable.WheelPicker);
        this.mItemTextSize = wheelFunction.getDimensionPixelSize(R.styleable.WheelPicker_wheel_item_text_size, this.getResources().getDimensionPixelSize(R.dimen.tuiroomkit_wheel_text_size));
        this.mVisibleItemCount = wheelFunction.getInt(R.styleable.WheelPicker_wheel_visible_item_count, 7);
        this.mSelectedItemPosition = wheelFunction.getInt(R.styleable.WheelPicker_wheel_selected_item_position, 0);
        this.hasSameWidth = wheelFunction.getBoolean(R.styleable.WheelPicker_wheel_same_width, false);
        this.mTextMaxWidthPosition = wheelFunction.getInt(R.styleable.WheelPicker_wheel_maximum_width_text_position, -1);
        this.mMaxWidthText = wheelFunction.getString(R.styleable.WheelPicker_wheel_maximum_width_text);
        this.mSelectedItemTextColor = wheelFunction.getColor(R.styleable.WheelPicker_wheel_selected_item_text_color, -1);
        this.mItemTextColor = wheelFunction.getColor(R.styleable.WheelPicker_wheel_item_text_color, -7829368);
        this.mItemSpace = wheelFunction.getDimensionPixelSize(R.styleable.WheelPicker_wheel_item_space, this.getResources().getDimensionPixelSize(R.dimen.tuiroomkit_wheel_item_space));
        this.isCyclic = wheelFunction.getBoolean(R.styleable.WheelPicker_wheel_cyclic, false);
        this.hasIndicator = wheelFunction.getBoolean(R.styleable.WheelPicker_wheel_indicator, false);
        this.mIndicatorColor = wheelFunction.getColor(R.styleable.WheelPicker_wheel_indicator_color, -1166541);
        this.mIndicatorSize = wheelFunction.getDimensionPixelSize(R.styleable.WheelPicker_wheel_indicator_size, this.getResources().getDimensionPixelSize(R.dimen.tuiroomkit_wheel_indication_size));
        this.hasCurtain = wheelFunction.getBoolean(R.styleable.WheelPicker_wheel_curtain, false);
        this.mCurtainColor = wheelFunction.getColor(R.styleable.WheelPicker_wheel_curtain_color, -1996488705);
        this.hasAtmospheric = wheelFunction.getBoolean(R.styleable.WheelPicker_wheel_atmospheric, false);
        this.isCurved = wheelFunction.getBoolean(R.styleable.WheelPicker_wheel_curved, false);
        this.mItemAlign = wheelFunction.getInt(R.styleable.WheelPicker_wheel_item_align, 0);
        wheelFunction.recycle();
        this.updateVisibleItemCount();
        this.mPaint = new Paint(69);
        this.mPaint.setTextSize((float) this.mItemTextSize);
        this.updateItemTextAlign();
        this.computeTextSize();
        this.mScroller = new Scroller(this.getContext());
        ViewConfiguration conf = ViewConfiguration.get(this.getContext());
        this.mMinimumVelocity = conf.getScaledMinimumFlingVelocity();
        this.mMaximumVelocity = conf.getScaledMaximumFlingVelocity();
        this.mTouchSlop = conf.getScaledTouchSlop();

        this.mRectDrawn = new Rect();
        this.mRectIndicatorHead = new Rect();
        this.mRectIndicatorFoot = new Rect();
        this.mRectCurrentItem = new Rect();
        this.mCamera = new Camera();
        this.mMatrixRotate = new Matrix();
        this.mMatrixDepth = new Matrix();
    }

    private void updateVisibleItemCount() {
        if (this.mVisibleItemCount < 2) {
            throw new ArithmeticException("Wheel's visible item count can not be less than 2!");
        } else {
            if (this.mVisibleItemCount % 2 == 0) {
                ++this.mVisibleItemCount;
            }

            this.mDrawnItemCount = this.mVisibleItemCount + 2;
            this.mHalfDrawnItemCount = this.mDrawnItemCount / 2;
        }
    }

    private void computeTextSize() {
        this.mTextMaxWidth = this.mTextMaxHeight = 0;
        if (this.hasSameWidth) {
            this.mTextMaxWidth = (int) this.mPaint.measureText(String.valueOf(this.mData.get(0)));
        } else if (this.isPosInRang(this.mTextMaxWidthPosition)) {
            this.mTextMaxWidth = (int) this.mPaint.measureText(String.valueOf(this.mData.get(this.mTextMaxWidthPosition)));
        } else {
            int width;
            if (!TextUtils.isEmpty(this.mMaxWidthText)) {
                this.mTextMaxWidth = (int) this.mPaint.measureText(this.mMaxWidthText);
            } else {
                for (Iterator var1 = this.mData.iterator(); var1.hasNext(); this.mTextMaxWidth = Math.max(this.mTextMaxWidth, width)) {
                    Object obj = var1.next();
                    String text = String.valueOf(obj);
                    width = (int) this.mPaint.measureText(text);
                }
            }
        }

        Paint.FontMetrics metrics = this.mPaint.getFontMetrics();
        this.mTextMaxHeight = (int) (metrics.bottom - metrics.top);
    }

    private void updateItemTextAlign() {
        switch (this.mItemAlign) {
            case 1:
                this.mPaint.setTextAlign(Paint.Align.LEFT);
                break;
            case 2:
                this.mPaint.setTextAlign(Paint.Align.RIGHT);
                break;
            default:
                this.mPaint.setTextAlign(Paint.Align.CENTER);
        }

    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int modeWidth = MeasureSpec.getMode(widthMeasureSpec);
        int modeHeight = MeasureSpec.getMode(heightMeasureSpec);
        int sizeWidth = MeasureSpec.getSize(widthMeasureSpec);
        int sizeHeight = MeasureSpec.getSize(heightMeasureSpec);
        int resultWidth = this.mTextMaxWidth;
        int resultHeight = this.mTextMaxHeight * this.mVisibleItemCount + this.mItemSpace * (this.mVisibleItemCount - 1);
        if (this.isCurved) {
            resultHeight = (int) ((double) (2 * resultHeight) / Math.PI);
        }
        resultWidth += this.getPaddingLeft() + this.getPaddingRight();
        resultHeight += this.getPaddingTop() + this.getPaddingBottom();

        resultWidth = this.measureSize(modeWidth, sizeWidth, resultWidth);
        resultHeight = this.measureSize(modeHeight, sizeHeight, resultHeight);
        this.setMeasuredDimension(resultWidth, resultHeight);
    }

    private int measureSize(int mode, int sizeExpect, int sizeActual) {
        int realSize;
        if (mode == 1073741824) {
            realSize = sizeExpect;
        } else {
            realSize = sizeActual;
            if (mode == Integer.MIN_VALUE) {
                realSize = Math.min(sizeActual, sizeExpect);
            }
        }

        return realSize;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldW, int oldH) {
        this.mRectDrawn.set(this.getPaddingLeft(), this.getPaddingTop(), this.getWidth() - this.getPaddingRight(), this.getHeight() - this.getPaddingBottom());
        this.mWheelCenterX = this.mRectDrawn.centerX();
        this.mWheelCenterY = this.mRectDrawn.centerY();
        this.computeDrawnCenter();
        this.mHalfWheelHeight = this.mRectDrawn.height() / 2;
        this.mItemHeight = this.mRectDrawn.height() / this.mVisibleItemCount;
        this.mHalfItemHeight = this.mItemHeight / 2;
        this.computeFlingLimitY();
        this.computeIndicatorRect();
        this.computeCurrentItemRect();
    }

    private void computeDrawnCenter() {
        switch (this.mItemAlign) {
            case 1:
                this.mDrawnCenterX = this.mRectDrawn.left;
                break;
            case 2:
                this.mDrawnCenterX = this.mRectDrawn.right;
                break;
            default:
                this.mDrawnCenterX = this.mWheelCenterX;
        }

        this.mDrawnCenterY = (int) ((float) this.mWheelCenterY - (this.mPaint.ascent() + this.mPaint.descent()) / 2.0F);
    }

    private void computeFlingLimitY() {
        int currentItemOffset = this.mSelectedItemPosition * this.mItemHeight;
        this.mMinFlingY = this.isCyclic ? Integer.MIN_VALUE : -this.mItemHeight * (this.mData.size() - 1) + currentItemOffset;
        this.mMaxFlingY = this.isCyclic ? Integer.MAX_VALUE : currentItemOffset;
    }

    private void computeIndicatorRect() {
        if (this.hasIndicator) {
            int halfIndicatorSize = this.mIndicatorSize / 2;
            int indicatorHeadCenterY = this.mWheelCenterY + this.mHalfItemHeight;
            int indicatorFootCenterY = this.mWheelCenterY - this.mHalfItemHeight;
            this.mRectIndicatorHead.set(this.mRectDrawn.left, indicatorHeadCenterY - halfIndicatorSize, this.mRectDrawn.right, indicatorHeadCenterY + halfIndicatorSize);
            this.mRectIndicatorFoot.set(this.mRectDrawn.left, indicatorFootCenterY - halfIndicatorSize, this.mRectDrawn.right, indicatorFootCenterY + halfIndicatorSize);
        }
    }

    private void computeCurrentItemRect() {
        if (this.hasCurtain || this.mSelectedItemTextColor != -1) {
            this.mRectCurrentItem.set(this.mRectDrawn.left, this.mWheelCenterY - this.mHalfItemHeight, this.mRectDrawn.right, this.mWheelCenterY + this.mHalfItemHeight);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (null != this.mOnWheelChangeListener) {
            this.mOnWheelChangeListener.onWheelScrolled(this.mScrollOffsetY);
        }

        int drawnDataStartPos = -this.mScrollOffsetY / this.mItemHeight - this.mHalfDrawnItemCount;
        int drawnDataPos = drawnDataStartPos + this.mSelectedItemPosition;

        for (int drawnOffsetPos = -this.mHalfDrawnItemCount; drawnDataPos < drawnDataStartPos + this.mSelectedItemPosition + this.mDrawnItemCount; ++drawnOffsetPos) {
            String data = "";
            int mDrawnItemCenterY;
            if (this.isCyclic) {
                mDrawnItemCenterY = drawnDataPos % this.mData.size();
                mDrawnItemCenterY = mDrawnItemCenterY < 0 ? mDrawnItemCenterY + this.mData.size() : mDrawnItemCenterY;
                data = String.valueOf(this.mData.get(mDrawnItemCenterY));
            } else if (this.isPosInRang(drawnDataPos)) {
                data = String.valueOf(this.mData.get(drawnDataPos));
            }

            this.mPaint.setColor(this.mItemTextColor);
            this.mPaint.setStyle(Paint.Style.FILL);
            mDrawnItemCenterY = this.mDrawnCenterY + drawnOffsetPos * this.mItemHeight + this.mScrollOffsetY % this.mItemHeight;
            int distanceToCenter = 0;
            int lineCenterY;
            if (this.isCurved) {
                float ratio = (float) (this.mDrawnCenterY - Math.abs(this.mDrawnCenterY - mDrawnItemCenterY) - this.mRectDrawn.top) * 1.0F / (float) (this.mDrawnCenterY - this.mRectDrawn.top);
                lineCenterY = 0;
                if (mDrawnItemCenterY > this.mDrawnCenterY) {
                    lineCenterY = 1;
                } else if (mDrawnItemCenterY < this.mDrawnCenterY) {
                    lineCenterY = -1;
                }

                float degree = -(1.0F - ratio) * 90.0F * (float) lineCenterY;
                if (degree < -90.0F) {
                    degree = -90.0F;
                }

                if (degree > 90.0F) {
                    degree = 90.0F;
                }

                distanceToCenter = this.computeSpace((int) degree);
                int transX = this.mWheelCenterX;
                switch (this.mItemAlign) {
                    case 1:
                        transX = this.mRectDrawn.left;
                        break;
                    case 2:
                        transX = this.mRectDrawn.right;
                }

                int transY = this.mWheelCenterY - distanceToCenter;
                this.mCamera.save();
                this.mCamera.rotateX(degree);
                this.mCamera.getMatrix(this.mMatrixRotate);
                this.mCamera.restore();
                this.mMatrixRotate.preTranslate((float) (-transX), (float) (-transY));
                this.mMatrixRotate.postTranslate((float) transX, (float) transY);
                this.mCamera.save();
                this.mCamera.translate(0.0F, 0.0F, (float) this.computeDepth((int) degree));
                this.mCamera.getMatrix(this.mMatrixDepth);
                this.mCamera.restore();
                this.mMatrixDepth.preTranslate((float) (-transX), (float) (-transY));
                this.mMatrixDepth.postTranslate((float) transX, (float) transY);
                this.mMatrixRotate.postConcat(this.mMatrixDepth);
            }

            int drawnCenterY;
            if (this.hasAtmospheric) {
                drawnCenterY = (int) ((float) (this.mDrawnCenterY - Math.abs(this.mDrawnCenterY - mDrawnItemCenterY)) * 1.0F / (float) this.mDrawnCenterY * 255.0F);
                drawnCenterY = drawnCenterY < 0 ? 0 : drawnCenterY;
                this.mPaint.setAlpha(drawnCenterY);
            }

            drawnCenterY = this.isCurved ? this.mDrawnCenterY - distanceToCenter : mDrawnItemCenterY;
            if (this.mSelectedItemTextColor != -1) {
                canvas.save();
                if (this.isCurved) {
                    canvas.concat(this.mMatrixRotate);
                }

                canvas.clipRect(this.mRectCurrentItem, Region.Op.DIFFERENCE);
                canvas.drawText(data, (float) this.mDrawnCenterX, (float) drawnCenterY, this.mPaint);
                canvas.restore();
                this.mPaint.setColor(this.mSelectedItemTextColor);
                canvas.save();
                if (this.isCurved) {
                    canvas.concat(this.mMatrixRotate);
                }

                canvas.clipRect(this.mRectCurrentItem);
                canvas.drawText(data, (float) this.mDrawnCenterX, (float) drawnCenterY, this.mPaint);
                canvas.restore();
            } else {
                canvas.save();
                canvas.clipRect(this.mRectDrawn);
                if (this.isCurved) {
                    canvas.concat(this.mMatrixRotate);
                }

                canvas.drawText(data, (float) this.mDrawnCenterX, (float) drawnCenterY, this.mPaint);
                canvas.restore();
            }

            ++drawnDataPos;
        }

        if (this.hasCurtain) {
            this.mPaint.setColor(this.mCurtainColor);
            this.mPaint.setStyle(Paint.Style.FILL);
            canvas.drawRect(this.mRectCurrentItem, this.mPaint);
        }

        if (this.hasIndicator) {
            this.mPaint.setColor(this.mIndicatorColor);
            this.mPaint.setStyle(Paint.Style.FILL);
            canvas.drawRect(this.mRectIndicatorHead, this.mPaint);
            canvas.drawRect(this.mRectIndicatorFoot, this.mPaint);
        }

    }

    private boolean isPosInRang(int position) {
        return position >= 0 && position < this.mData.size();
    }

    private int computeSpace(int degree) {
        return (int) (Math.sin(Math.toRadians((double) degree)) * (double) this.mHalfWheelHeight);
    }

    private int computeDepth(int degree) {
        return (int) ((double) this.mHalfWheelHeight - Math.cos(Math.toRadians((double) degree)) * (double) this.mHalfWheelHeight);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (null != this.getParent()) {
                    this.getParent().requestDisallowInterceptTouchEvent(true);
                }

                if (null == this.mTracker) {
                    this.mTracker = VelocityTracker.obtain();
                } else {
                    this.mTracker.clear();
                }

                this.mTracker.addMovement(event);
                if (!this.mScroller.isFinished()) {
                    this.mScroller.abortAnimation();
                    this.isForceFinishScroll = true;
                }

                this.mDownPointY = this.mLastPointY = (int) event.getY();
                break;
            case MotionEvent.ACTION_UP:
                if (null != this.getParent()) {
                    this.getParent().requestDisallowInterceptTouchEvent(false);
                }

                if (!this.isClick) {
                    this.mTracker.addMovement(event);
                    this.mTracker.computeCurrentVelocity(1000, (float) this.mMaximumVelocity);
                    this.isForceFinishScroll = false;
                    int velocity = (int) this.mTracker.getYVelocity();
                    if (Math.abs(velocity) > this.mMinimumVelocity) {
                        this.mScroller.fling(0, this.mScrollOffsetY, 0, velocity, 0, 0, this.mMinFlingY, this.mMaxFlingY);
                        this.mScroller.setFinalY(this.mScroller.getFinalY() + this.computeDistanceToEndPoint(this.mScroller.getFinalY() % this.mItemHeight));
                    } else {
                        this.mScroller.startScroll(0, this.mScrollOffsetY, 0, this.computeDistanceToEndPoint(this.mScrollOffsetY % this.mItemHeight));
                    }

                    if (!this.isCyclic) {
                        if (this.mScroller.getFinalY() > this.mMaxFlingY) {
                            this.mScroller.setFinalY(this.mMaxFlingY);
                        } else if (this.mScroller.getFinalY() < this.mMinFlingY) {
                            this.mScroller.setFinalY(this.mMinFlingY);
                        }
                    }

                    this.mHandler.post(this);
                    if (null != this.mTracker) {
                        this.mTracker.recycle();
                        this.mTracker = null;
                    }
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (Math.abs((float) this.mDownPointY - event.getY()) < (float) this.mTouchSlop) {
                    this.isClick = true;
                } else {
                    this.isClick = false;
                    this.mTracker.addMovement(event);
                    if (null != this.mOnWheelChangeListener) {
                        this.mOnWheelChangeListener.onWheelScrollStateChanged(1);
                    }

                    float move = event.getY() - (float) this.mLastPointY;
                    if (!(Math.abs(move) < 1.0F)) {
                        this.mScrollOffsetY = (int) ((float) this.mScrollOffsetY + move);
                        this.mLastPointY = (int) event.getY();
                        this.invalidate();
                    }
                }
                break;
            case MotionEvent.ACTION_CANCEL:
                if (null != this.getParent()) {
                    this.getParent().requestDisallowInterceptTouchEvent(false);
                }

                if (null != this.mTracker) {
                    this.mTracker.recycle();
                    this.mTracker = null;
                }
        }

        return true;
    }

    private int computeDistanceToEndPoint(int remainder) {
        if (Math.abs(remainder) > this.mHalfItemHeight) {
            return this.mScrollOffsetY < 0 ? -this.mItemHeight - remainder : this.mItemHeight - remainder;
        } else {
            return -remainder;
        }
    }

    public void run() {
        if (null != this.mData && this.mData.size() != 0) {
            if (this.mScroller.isFinished() && !this.isForceFinishScroll) {
                if (this.mItemHeight == 0) {
                    return;
                }

                int position = (-this.mScrollOffsetY / this.mItemHeight + this.mSelectedItemPosition) % this.mData.size();
                position = position < 0 ? position + this.mData.size() : position;

                this.mCurrentItemPosition = position;
                if (null != this.mOnItemSelectedListener) {
                    this.mOnItemSelectedListener.onItemSelected(this, this.mData.get(position), position);
                }

                if (null != this.mOnWheelChangeListener) {
                    this.mOnWheelChangeListener.onWheelSelected(position);
                    this.mOnWheelChangeListener.onWheelScrollStateChanged(0);
                }
            }

            if (this.mScroller.computeScrollOffset()) {
                if (null != this.mOnWheelChangeListener) {
                    this.mOnWheelChangeListener.onWheelScrollStateChanged(2);
                }

                this.mScrollOffsetY = this.mScroller.getCurrY();
                this.postInvalidate();
                this.mHandler.postDelayed(this, 16L);
            }

        }
    }

    public void setVisibleItemCount(int count) {
        this.mVisibleItemCount = count;
        this.updateVisibleItemCount();
        this.requestLayout();
    }

    public void setOnItemSelectedListener(OnItemSelectedListener listener) {
        this.mOnItemSelectedListener = listener;
    }

    public int getSelectedItemPosition() {
        return this.mSelectedItemPosition;
    }

    public void setSelectedItemPosition(int position) {
        position = Math.min(position, this.mData.size() - 1);
        position = Math.max(position, 0);
        this.mSelectedItemPosition = position;
        this.mCurrentItemPosition = position;
        this.mScrollOffsetY = 0;
        this.computeFlingLimitY();
        this.requestLayout();
        this.invalidate();
    }

    public int getCurrentItemPosition() {
        return this.mCurrentItemPosition;
    }

    public void setData(List data) {
        if (null == data) {
            throw new NullPointerException("WheelPicker's data can not be null!");
        } else {
            this.mData = data;
            if (this.mSelectedItemPosition <= data.size() - 1 && this.mCurrentItemPosition <= data.size() - 1) {
                this.mSelectedItemPosition = this.mCurrentItemPosition;
            } else {
                this.mSelectedItemPosition = this.mCurrentItemPosition = data.size() - 1;
            }

            this.mScrollOffsetY = 0;
            this.computeTextSize();
            this.computeFlingLimitY();
            this.requestLayout();
            this.invalidate();
        }
    }

    public void setOnWheelChangeListener(OnWheelChangeListener listener) {
        this.mOnWheelChangeListener = listener;
    }

    public interface OnWheelChangeListener {
        void onWheelScrolled(int position);

        void onWheelSelected(int position);

        void onWheelScrollStateChanged(int position);
    }

    public interface OnItemSelectedListener {
        void onItemSelected(WheelPicker picker, Object item, int position);
    }
}
