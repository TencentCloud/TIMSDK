package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PointF;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.liteav.base.util.Size;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaGraphComputerUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush.BrushControlView.BrushMode;
import java.util.LinkedList;
import java.util.List;
import java.util.Stack;

public class BrushDrawView extends View {

    private final String TAG = BrushDrawView.class + "_" + hashCode();

    private static final int GRAFFITI_STROKE_WIDTH = 16;
    private static final int MOSAIC_STROKE_WIDTH = 40;
    private static final int MIN_MOVE_DST_PX = 10;

    private BrushMode mBrushMode = BrushMode.GRAFFITI;
    private final Stack<DrawPath> mGraffitiPaths = new Stack<>();
    private final Stack<DrawPath> mEraseGraffitiPaths = new Stack<>();
    private final Stack<DrawPath> mMosaicPaths = new Stack<>();
    private final Stack<DrawPath> mEraseMosaicPaths = new Stack<>();
    private final TUIMultimediaData<Integer> mTuiDataPaintColor;
    private final TUIMultimediaData<Boolean> mTuiDataIsDrawing;

    private Paint mPathPaint;
    private Paint mMosaicImagePaint;
    private Bitmap mMosaicImage;

    private List<PointF> mCurrentPointList;
    private boolean mEnableDraw = true;
    private boolean mIsMotionActionMove = false;
    private PointF mActionDownPoint;

    public BrushDrawView(Context context, TUIMultimediaData<Integer> tuiDataPaintColor,
            TUIMultimediaData<Boolean> tuiDataIsDrawing) {
        super(context);
        mTuiDataPaintColor = tuiDataPaintColor;
        mTuiDataPaintColor.observe(color -> {
            if (mPathPaint != null) {
                mPathPaint.setColor(color);
            }
        });
        mTuiDataIsDrawing = tuiDataIsDrawing;
        setupPathPaint();
    }

    public void enableDraw(boolean enable) {
        mEnableDraw = enable;
    }

    public void clean() {
        mGraffitiPaths.clear();
        mEraseGraffitiPaths.clear();

        mMosaicPaths.clear();
        mEraseMosaicPaths.clear();

        if (mCurrentPointList != null) {
            mCurrentPointList.clear();
        }
    }

    public void setMosaicImage(Bitmap bitmap) {
        if (bitmap == null) {
            LiteavLog.i(TAG,"source picture is null");
            return;
        }

        if (mMosaicImage != null) {
            mMosaicImage.recycle();
        }

        int w = Math.max(Math.round(bitmap.getWidth() / 40f), 8);
        int h = Math.max(Math.round(bitmap.getHeight() / 40f), 8);
        mMosaicImage = Bitmap.createScaledBitmap(bitmap, w, h, false);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        drawMosaic(canvas);
        drawGraffiti(canvas);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        LiteavLog.i(TAG, "onTouchEvent");
        if (!mEnableDraw) {
            performClick();
            return false;
        }

        float touchX = event.getX();
        float touchY = event.getY();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mCurrentPointList = new LinkedList<>();
                mCurrentPointList.add(new PointF(touchX, touchY));
                mActionDownPoint = new PointF(touchX, touchY);
                mIsMotionActionMove = false;
                break;
            case MotionEvent.ACTION_MOVE:
                if (TUIMultimediaGraphComputerUtils.distance4PointF(mActionDownPoint, new PointF(touchX, touchY))
                        > MIN_MOVE_DST_PX) {
                    mTuiDataIsDrawing.set(true);
                    mIsMotionActionMove = true;
                    mCurrentPointList.add(new PointF(touchX, touchY));
                }
                break;
            case MotionEvent.ACTION_UP:
                if (mIsMotionActionMove) {
                    if (mBrushMode == BrushMode.MOSAIC) {
                        mMosaicPaths.add(new DrawPath(
                                mCurrentPointList, mTuiDataPaintColor.get(), new Size(getWidth(), getHeight())));
                        mEraseMosaicPaths.clear();
                    } else {
                        mGraffitiPaths.add(new DrawPath(
                                mCurrentPointList, mTuiDataPaintColor.get(), new Size(getWidth(), getHeight())));
                        mEraseGraffitiPaths.clear();
                    }
                } else {
                    mTuiDataIsDrawing.set(!mTuiDataIsDrawing.get());
                }
                mCurrentPointList = null;
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
        if (mGraffitiPaths.empty() && mMosaicPaths.empty()) {
            return null;
        }

        RectF rect = new RectF(0, 0, getWidth(), getHeight());
        Bitmap canvasBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(canvasBitmap);

        if (!mMosaicPaths.empty() && mMosaicImage != null) {
            int layerCount = canvas.saveLayer(rect, null, Canvas.ALL_SAVE_FLAG);
            drawPathList(canvas, mPathPaint, mMosaicPaths, MOSAIC_STROKE_WIDTH);
            mMosaicImagePaint.setFilterBitmap(false);
            canvas.drawBitmap(mMosaicImage, null, rect, mMosaicImagePaint);
            canvas.restoreToCount(layerCount);
        }

        if (!mGraffitiPaths.empty()) {
            drawPathList(canvas, mPathPaint, mGraffitiPaths, GRAFFITI_STROKE_WIDTH);
        }
        return canvasBitmap;
    }

    public void setBrushMode(BrushMode brushMode) {
        mBrushMode = brushMode;
    }

    public void undo() {
        if (mBrushMode == BrushMode.GRAFFITI && !mGraffitiPaths.empty()) {
            mEraseGraffitiPaths.push(mGraffitiPaths.pop());
        } else if (mBrushMode == BrushMode.MOSAIC && !mMosaicPaths.empty()) {
            mEraseMosaicPaths.push(mMosaicPaths.pop());
        } else {
            return;
        }
        invalidate();
    }

    public void redo() {
        if (mBrushMode == BrushMode.GRAFFITI && !mEraseGraffitiPaths.empty()) {
            mGraffitiPaths.push(mEraseGraffitiPaths.pop());
        } else if (mBrushMode == BrushMode.MOSAIC && !mEraseMosaicPaths.empty()) {
            mMosaicPaths.push(mEraseMosaicPaths.pop());
        } else {
            return;
        }
        invalidate();

        if (mEraseGraffitiPaths.empty()) {
            return;
        }
        mGraffitiPaths.push(mEraseGraffitiPaths.pop());
        invalidate();
    }

    public boolean canUndo() {
        return mBrushMode == BrushMode.GRAFFITI ? !mGraffitiPaths.empty() : !mMosaicPaths.empty();
    }

    public boolean canRedo() {
        return mBrushMode == BrushMode.GRAFFITI ? !mEraseGraffitiPaths.empty() : !mEraseMosaicPaths.empty();
    }

    private void setupPathPaint() {
        if (mPathPaint != null) {
            return;
        }

        mPathPaint = new Paint();
        mPathPaint.setColor(mTuiDataPaintColor.get());
        mPathPaint.setAntiAlias(true);
        mPathPaint.setStrokeWidth(GRAFFITI_STROKE_WIDTH);
        mPathPaint.setStyle(Paint.Style.STROKE);
        mPathPaint.setStrokeJoin(Paint.Join.ROUND);
        mPathPaint.setStrokeCap(Paint.Cap.ROUND);
    }

    private void setupMosaicImagePaint() {
        if (mMosaicImagePaint != null) {
            return;
        }

        mMosaicImagePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mMosaicImagePaint.setFilterBitmap(false);
        mMosaicImagePaint.setStrokeWidth(MOSAIC_STROKE_WIDTH);
        mMosaicImagePaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
    }

    private void drawGraffiti(Canvas canvas) {
        if (mBrushMode != BrushMode.GRAFFITI && mGraffitiPaths.empty()) {
            return;
        }

        RectF rect = new RectF(0, 0, getWidth(), getHeight());
        int layerCount = canvas.saveLayer(rect, null, Canvas.ALL_SAVE_FLAG);
        drawPathList(canvas, mPathPaint, mGraffitiPaths, GRAFFITI_STROKE_WIDTH);
        if (mBrushMode == BrushMode.GRAFFITI) {
            mPathPaint.setColor(mTuiDataPaintColor.get());
            drawCurrentPoint(canvas, mPathPaint, GRAFFITI_STROKE_WIDTH);
        }
        canvas.restoreToCount(layerCount);
    }

    private void drawMosaic(Canvas canvas) {
        if (mBrushMode != BrushMode.MOSAIC && mMosaicPaths.empty()) {
            return;
        }

        setupMosaicImagePaint();
        RectF rect = new RectF(0, 0, getWidth(), getHeight());
        int layerCount = canvas.saveLayer(rect, null, Canvas.ALL_SAVE_FLAG);
        if (mBrushMode == BrushMode.MOSAIC) {
            drawCurrentPoint(canvas, mPathPaint, MOSAIC_STROKE_WIDTH);
        }
        drawPathList(canvas, mPathPaint, mMosaicPaths, MOSAIC_STROKE_WIDTH);
        if (mMosaicImage != null) {
            mMosaicImagePaint.setFilterBitmap(false);
            canvas.drawBitmap(mMosaicImage, null, rect, mMosaicImagePaint);
        }
        canvas.restoreToCount(layerCount);
    }

    private void drawCurrentPoint(Canvas canvas, Paint paint, int strokeWidth) {
        if (mCurrentPointList != null) {
            paint.setStrokeWidth(strokeWidth);
            canvas.drawPath(getPathFromPoints(mCurrentPointList, 1.0f), paint);
        }
    }

    private void drawPathList(Canvas canvas, Paint paint, Stack<DrawPath> paths, int paintWidth) {
        for (DrawPath drawPath : paths) {
            double originSize = Math.sqrt(drawPath.originViewSize.width * drawPath.originViewSize.width +
                    drawPath.originViewSize.height * drawPath.originViewSize.height);
            double size = Math.sqrt(getWidth() * getWidth() + getHeight() * getHeight());
            float scale = (float) (size / originSize);
            paint.setStrokeWidth((int) (paintWidth * scale));
            paint.setColor(drawPath.color);
            canvas.drawPath(getPathFromPoints(drawPath.pathPoints, scale), paint);
        }
    }

    private Path getPathFromPoints(List<PointF> pathPoints, float scale) {
        Path path = new Path();
        for (int i = 0; i < pathPoints.size(); i++) {
            if (i == 0) {
                path.moveTo(pathPoints.get(i).x * scale, pathPoints.get(i).y * scale);
            }
            path.lineTo(pathPoints.get(i).x * scale, pathPoints.get(i).y * scale);
        }
        return path;
    }

    private static class DrawPath {

        private final List<PointF> pathPoints;
        int color;
        Size originViewSize;

        public DrawPath(List<PointF> pathPoints, int color, Size size) {
            this.pathPoints = pathPoints;
            this.color = color;
            this.originViewSize = size;
        }
    }
}