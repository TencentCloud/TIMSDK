package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.crop;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.View;
import com.tencent.liteav.base.ThreadUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;

public class PictureCropView extends View {
    private final static int RECT_LINE_WIDTH = 3;
    private final static int GRID_LINE_WIDTH = 1;
    private final static int RECT_CORNER_LINE_WIDTH = 10;
    private final static int CORNER_LENGTH = 50;
    private final static int TOUCH_DISTANCE = 50;

    private final static int CANCEL_BACKGROUND_TRANSPARENT_DELAY_TIME = 2000;
    private final static int CANCEL_DRAW_GRID_DELAY_TIME = 4000;

    private final static int LIMIT_LEFT_DP = 30;
    private final static int LIMIT_BOTTOM_DP = 100;
    private final static int LIMIT_TOP_DP = 15;

    private final Rect mOriginPreviewRect;
    private final Rect mMaxCropRect = new Rect();
    private final Rect mCropRect = new Rect();

    boolean mIsMoveLeft = false;
    boolean mIsMoveRight = false;
    boolean mIsMoveTop = false;
    boolean mIsMoveBottom = false;

    private Paint mCropRectDrawPaint;
    private Paint mBackGroundDrawPaint;
    private Path mCropRectPath;
    private CropListener mCropListener;
    private Boolean mIsDrawGrid = false;

    Runnable mCancelBackGroundTransparentRunnable = () -> {
        mBackGroundDrawPaint.setColor(Color.argb(255, 0, 0, 0));
        invalidate();
    };

    Runnable mCancelDrawGridRunnable = () -> {
        mIsDrawGrid = false;
        invalidate();
    };

    public interface CropListener {
        void onTouch();
        void onCrop(float scaleCenterX, float scaleCenterY, float scale, int moveX, int moveY);
    }

    public PictureCropView(Context context, Rect originPreviewRect) {
        super(context);
        mOriginPreviewRect = originPreviewRect;
        setupDrawing();
    }

    public void setCropListener(CropListener cropListener) {
        mCropListener = cropListener;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
        if (!changed) {
            return;
        }
        initMaxCropRect();
        initCropRect();
        invalidate();
    }

    public void resetCropRect() {
        initCropRect();
        delayCancelBackGroundTransparent();
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        drawBackGround(canvas);
        drawCropRect(canvas);
        drawCorner(canvas);
        if (mIsDrawGrid) {
            drawGrid(canvas);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (mCropListener != null) {
            mCropListener.onTouch();
        }

        float touchX = event.getX();
        float touchY = event.getY();
        boolean isAdjustCropRect = true;
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mIsMoveLeft = Math.abs(touchX - mCropRect.left) < TOUCH_DISTANCE;
                mIsMoveRight = Math.abs(touchX - mCropRect.right) < TOUCH_DISTANCE;
                mIsMoveTop = Math.abs(touchY - mCropRect.top) < TOUCH_DISTANCE;
                mIsMoveBottom = Math.abs(touchY - mCropRect.bottom) < TOUCH_DISTANCE;
                setBackGroundTransparent();
                isAdjustCropRect = mIsMoveBottom || mIsMoveTop || mIsMoveLeft || mIsMoveRight;
                if (!isAdjustCropRect) {
                    delayCancelBackGroundTransparent();
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (mIsMoveLeft && touchX > mMaxCropRect.left && touchX < mCropRect.right) {
                    mCropRect.left = (int) touchX;
                }

                if (mIsMoveRight && touchX > mCropRect.left && touchX < mMaxCropRect.right) {
                    mCropRect.right = (int) touchX;
                }

                if (mIsMoveTop && touchY > mMaxCropRect.top && touchY < mCropRect.bottom) {
                    mCropRect.top = (int) touchY;
                }

                if (mIsMoveBottom && touchY > mCropRect.top && touchY < mMaxCropRect.bottom) {
                    mCropRect.bottom = (int) touchY;
                }
                break;
            case MotionEvent.ACTION_UP:
                delayCancelBackGroundTransparent();
                adjustCropRect();
                break;
        }
        invalidate();
        return isAdjustCropRect;
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    public Rect getCropRect() {
        return new Rect(mCropRect);
    }

    public void rotation90() {
        int centerX = mCropRect.centerX();
        int centerY = mCropRect.centerY();
        int width = mCropRect.width();
        int height = mCropRect.height();

        mCropRect.top = centerY - width / 2;
        mCropRect.bottom = mCropRect.top + width;
        mCropRect.left = centerX - height / 2;
        mCropRect.right = mCropRect.left + height;

        adjustCropRect();
        invalidate();
    }

    private void setupDrawing() {
        mCropRectPath = new Path();
        mCropRectDrawPaint = new Paint();
        mCropRectDrawPaint.setColor(Color.WHITE);
        mCropRectDrawPaint.setAntiAlias(true);
        mCropRectDrawPaint.setStyle(Paint.Style.STROKE);
        mCropRectDrawPaint.setStrokeJoin(Paint.Join.ROUND);
        mCropRectDrawPaint.setStrokeCap(Paint.Cap.ROUND);

        mBackGroundDrawPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mBackGroundDrawPaint.setColor(Color.argb(255, 0, 0, 0));
        mBackGroundDrawPaint.setStyle(Paint.Style.FILL);
    }
    
    private void drawGrid(Canvas canvas) {
        mCropRectDrawPaint.setStrokeWidth(GRID_LINE_WIDTH);
        
        mCropRectPath.reset();
        mCropRectPath.moveTo((float) (mCropRect.left + mCropRect.width() / 3.0), mCropRect.top);
        mCropRectPath.lineTo((float) (mCropRect.left + mCropRect.width() / 3.0), mCropRect.bottom);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);

        mCropRectPath.reset();
        mCropRectPath.moveTo((float) (mCropRect.left + mCropRect.width() * 2 / 3.0), mCropRect.top);
        mCropRectPath.lineTo((float) (mCropRect.left + mCropRect.width() * 2 / 3.0), mCropRect.bottom);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);

        mCropRectPath.reset();
        mCropRectPath.moveTo(mCropRect.left, (float)(mCropRect.top + mCropRect.height() / 3.0));
        mCropRectPath.lineTo(mCropRect.right, (float)(mCropRect.top + mCropRect.height() / 3.0));
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);

        mCropRectPath.reset();
        mCropRectPath.moveTo(mCropRect.left, (float)(mCropRect.top + mCropRect.height() * 2 / 3.0));
        mCropRectPath.lineTo(mCropRect.right, (float)(mCropRect.top + mCropRect.height() * 2 / 3.0));
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);
    }

    private void drawBackGround(Canvas canvas) {
        canvas.drawRect(0, 0, getWidth(), mCropRect.top, mBackGroundDrawPaint);
        canvas.drawRect(0, mCropRect.bottom, getWidth(), getHeight(), mBackGroundDrawPaint);
        canvas.drawRect(0, mCropRect.top, mCropRect.left, mCropRect.bottom, mBackGroundDrawPaint);
        canvas.drawRect(mCropRect.right, mCropRect.top, getWidth(), mCropRect.bottom, mBackGroundDrawPaint);
    }

    private void drawCropRect(Canvas canvas) {
        mCropRectDrawPaint.setStrokeWidth(RECT_LINE_WIDTH);
        mCropRectPath.reset();
        mCropRectPath.moveTo(mCropRect.left, mCropRect.top);
        mCropRectPath.lineTo(mCropRect.right, mCropRect.top);
        mCropRectPath.lineTo(mCropRect.right, mCropRect.bottom);
        mCropRectPath.lineTo(mCropRect.left, mCropRect.bottom);
        mCropRectPath.lineTo(mCropRect.left, mCropRect.top);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);
    }

    private void drawCorner(Canvas canvas) {
        mCropRectDrawPaint.setStrokeWidth(RECT_CORNER_LINE_WIDTH);
        mCropRectPath.reset();
        mCropRectPath.moveTo(mCropRect.left, mCropRect.top + CORNER_LENGTH);
        mCropRectPath.lineTo(mCropRect.left, mCropRect.top);
        mCropRectPath.lineTo(mCropRect.left + CORNER_LENGTH, mCropRect.top);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);

        mCropRectPath.reset();
        mCropRectPath.moveTo(mCropRect.right, mCropRect.top + CORNER_LENGTH);
        mCropRectPath.lineTo(mCropRect.right, mCropRect.top);
        mCropRectPath.lineTo(mCropRect.right - CORNER_LENGTH, mCropRect.top);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);

        mCropRectPath.reset();
        mCropRectPath.moveTo(mCropRect.right, mCropRect.bottom - CORNER_LENGTH);
        mCropRectPath.lineTo(mCropRect.right, mCropRect.bottom);
        mCropRectPath.lineTo(mCropRect.right - CORNER_LENGTH, mCropRect.bottom);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);

        mCropRectPath.moveTo(mCropRect.left, mCropRect.bottom - CORNER_LENGTH);
        mCropRectPath.lineTo(mCropRect.left, mCropRect.bottom);
        mCropRectPath.lineTo(mCropRect.left + CORNER_LENGTH, mCropRect.bottom);
        canvas.drawPath(mCropRectPath, mCropRectDrawPaint);
    }

    private void delayCancelBackGroundTransparent() {
        ThreadUtils.getUiThreadHandler().postDelayed(mCancelBackGroundTransparentRunnable,
                CANCEL_BACKGROUND_TRANSPARENT_DELAY_TIME);
        ThreadUtils.getUiThreadHandler().postDelayed(mCancelDrawGridRunnable, CANCEL_DRAW_GRID_DELAY_TIME);
    }

    private void setBackGroundTransparent() {
        mBackGroundDrawPaint.setColor(Color.argb(0, 0, 0, 0));
        mIsDrawGrid = true;
        ThreadUtils.getUiThreadHandler().removeCallbacks(mCancelBackGroundTransparentRunnable);
        ThreadUtils.getUiThreadHandler().removeCallbacks(mCancelDrawGridRunnable);
    }

    private void initMaxCropRect() {
        mMaxCropRect.left = TUIMultimediaResourceUtils.dip2px(getContext(), LIMIT_LEFT_DP);
        mMaxCropRect.right = getWidth() - mMaxCropRect.left;
        mMaxCropRect.top = TUIMultimediaResourceUtils.dip2px(getContext(), LIMIT_TOP_DP);
        mMaxCropRect.bottom = getHeight() - TUIMultimediaResourceUtils.dip2px(getContext(), LIMIT_BOTTOM_DP);
    }

    private void initCropRect() {
        if (mOriginPreviewRect == null) {
            return;
        }

        float previewAspect = mOriginPreviewRect.width() * 1.0f / mOriginPreviewRect.height();
        float maxCropAspect = mMaxCropRect.width() * 1.0f / mMaxCropRect.height();

        if (previewAspect > maxCropAspect) {
            mCropRect.left = mMaxCropRect.left;
            mCropRect.right = mMaxCropRect.right;
            int cropHeight = (int) (mCropRect.width() / previewAspect);
            mCropRect.top = (mMaxCropRect.height() - cropHeight) / 2;
            mCropRect.bottom = mCropRect.top + cropHeight;
        } else {
            mCropRect.top = mMaxCropRect.top;
            mCropRect.bottom = mMaxCropRect.bottom;
            int cropWidth = (int) (mCropRect.height() * previewAspect);
            mCropRect.left = (getWidth()- cropWidth) / 2;

            mCropRect.right = mCropRect.left + cropWidth;
        }

        float scale = mCropRect.width() * 1.0f / mOriginPreviewRect.width();
        int mediaAreaLeft = (int) (getWidth() / 2.0 - mOriginPreviewRect.width() / 2.0 * scale);
        int mediaAreaTop = (int) (getHeight() / 2.0 - mOriginPreviewRect.height() / 2.0 * scale);

        if (mCropListener != null) {
            mCropListener.onCrop(getWidth() / 2.0f, getHeight() / 2.0f, scale,
                    mediaAreaLeft - mCropRect.left, mediaAreaTop - mCropRect.top);
        }
    }

    private void adjustCropRect() {
        float maxCropAreaAspect = mMaxCropRect.width() * 1.0f / mMaxCropRect.height();
        float cropAspect = mCropRect.width() * 1.0f / mCropRect.height();

        int sourceLeft = mCropRect.left;
        int sourceTop = mCropRect.top;
        int sourceRight = mCropRect.right;

        if (cropAspect > maxCropAreaAspect) {
            mCropRect.left = mMaxCropRect.left;
            mCropRect.right = mMaxCropRect.right;
            int cropHeight = (int) (mCropRect.width() / cropAspect);
            mCropRect.top = (mMaxCropRect.bottom - cropHeight) / 2;
            mCropRect.bottom = mCropRect.top + cropHeight;
        } else {
            mCropRect.top = mMaxCropRect.top;
            mCropRect.bottom = mMaxCropRect.bottom;
            int cropWidth = (int) (mCropRect.height() * cropAspect);
            mCropRect.left = (getWidth() - cropWidth) / 2;
            mCropRect.right = mCropRect.left + cropWidth;
        }

        float scale = mCropRect.width() * 1.0f / (sourceRight - sourceLeft);
        int moveX = sourceLeft - mCropRect.left;
        int moveY = sourceTop - mCropRect.top;

        if (mCropListener != null) {
            mCropListener.onCrop(sourceLeft, sourceTop, scale, moveX, moveY);
        }
    }
}
