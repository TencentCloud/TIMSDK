package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.graffiti;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PointF;
import android.view.MotionEvent;
import android.view.View;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaGraphComputerUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import java.util.Stack;

public class GraffitiDrawView extends View {

    private static final int DEFAULT_STROKE_WIDTH = 15;
    private static final int MIN_MOVE_DST_PX = 10;
    private final String TAG = GraffitiDrawView.class + "_" + hashCode();
    private final Stack<DrawPath> mPaths = new Stack<>();
    private final Stack<DrawPath> mErasePaths = new Stack<>();
    private final TUIMultimediaData<Integer> mTuiDataPaintColor;
    private final TUIMultimediaData<Boolean> mTuiDataIsDrawing;

    private Path mPath;
    private Paint mDrawPaint;
    private boolean mEnableGraffiti = true;
    private boolean mIsMotionActionMove = false;
    private PointF mActionDownPoint;

    public GraffitiDrawView(Context context, TUIMultimediaData<Integer> tuiDataPaintColor,
            TUIMultimediaData<Boolean> tuiDataIsDrawing) {
        super(context);
        mTuiDataPaintColor = tuiDataPaintColor;
        mTuiDataPaintColor.observe(color -> {
            if (mDrawPaint != null) {
                mDrawPaint.setColor(color);
            }
        });
        mTuiDataIsDrawing = tuiDataIsDrawing;
        setupDrawing();
    }

    public void enableGraffiti(boolean enable) {
        mEnableGraffiti = enable;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        mDrawPaint.setColor(mTuiDataPaintColor.get());
        canvas.drawPath(mPath, mDrawPaint);
        for (DrawPath drawPath : mPaths) {
            mDrawPaint.setColor(drawPath.color);
            canvas.drawPath(drawPath.path, mDrawPaint);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (!mEnableGraffiti) {
            performClick();
            return false;
        }

        float touchX = event.getX();
        float touchY = event.getY();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mPath.moveTo(touchX, touchY);
                mActionDownPoint = new PointF(touchX, touchY);
                mIsMotionActionMove = false;
                break;
            case MotionEvent.ACTION_MOVE:
                if (TUIMultimediaGraphComputerUtils.distance4PointF(mActionDownPoint, new PointF(touchX, touchY))
                        > MIN_MOVE_DST_PX) {
                    mTuiDataIsDrawing.set(true);
                    mIsMotionActionMove = true;
                    mPath.lineTo(touchX, touchY);
                }
                break;
            case MotionEvent.ACTION_UP:
                if (mIsMotionActionMove) {
                    mPaths.add(new DrawPath(mPath, mTuiDataPaintColor.get()));
                } else {
                    mTuiDataIsDrawing.set(!mTuiDataIsDrawing.get());
                }
                mPath = new Path();
                break;
        }

        invalidate();
        return true;
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    public Bitmap getDrawingBitmap() {
        if (mPaths.empty()) {
            return null;
        }

        Bitmap canvasBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        Canvas drawCanvas = new Canvas(canvasBitmap);

        for (DrawPath drawPath : mPaths) {
            mDrawPaint.setColor(drawPath.color);
            drawCanvas.drawPath(drawPath.path, mDrawPaint);
        }
        return canvasBitmap;
    }

    public void back() {
        if (mPaths.empty()) {
            return;
        }
        mErasePaths.push(mPaths.pop());
        invalidate();
    }

    public void front() {
        if (mErasePaths.empty()) {
            return;
        }
        mPaths.push(mErasePaths.pop());
        invalidate();
    }

    public boolean canBack() {
        return !mPaths.empty();
    }

    public boolean canForward() {
        return !mErasePaths.empty();
    }

    private void setupDrawing() {
        mPath = new Path();
        mDrawPaint = new Paint();
        mDrawPaint.setColor(mTuiDataPaintColor.get());
        mDrawPaint.setAntiAlias(true);
        mDrawPaint.setStrokeWidth(DEFAULT_STROKE_WIDTH);
        mDrawPaint.setStyle(Paint.Style.STROKE);
        mDrawPaint.setStrokeJoin(Paint.Join.ROUND);
        mDrawPaint.setStrokeCap(Paint.Cap.ROUND);
    }

    private static class DrawPath {

        Path path;
        int color;

        public DrawPath(Path path, int color) {
            this.path = path;
            this.color = color;
        }
    }

}