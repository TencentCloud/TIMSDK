package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.drawable.Drawable;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.liteav.base.util.Size;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaGraphComputerUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo.PasterType;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class FloatLayerView extends View {
    private final String TAG = FloatLayerView.class.getSimpleName() + "_" + hashCode();

    private static final int LEFT_TOP = 0;
    private static final int RIGHT_TOP = 1;
    private static final int RIGHT_BOTTOM = 2;
    private static final int LEFT_BOTTOM = 3;
    private static final int MIN_DISTANCE_TO_EDGE_DP = 10;
    private static final float MAX_SCALE = 10.0f;
    private static final float MIN_SCALE = 0.02f;
    private static final float DEFAULT_SCALE = 1.0f;
    private static final float DEFAULT_DEGREE = 0;
    private static final int DEFAULT_FRAME_PADDING = 3;
    private static final int DEFAULT_FRAME_WIDTH = 1;
    private static final int DEFAULT_FRAME_COLOR = Color.WHITE;
    private static final int DEFAULT_DELETE_DRAWABLE_ID = R.drawable.multimedia_plugin_edit_floatlayer_delete;
    private static final int DEFAULT_EDIT_DRAWABLE_ID = R.drawable.multimedia_plugin_edit_floatlayer_edit;
    private static final int DEFAULT_ROTATION_DRAWABLE_ID = R.drawable.multimedia_plugin_edit_floatlayer_rotation;
    private static final int DRAWABLE_SIZE_DP = 25;

    private final PointF mCenterPoint = new PointF();
    private final PointF mMoveSize = new PointF();
    private final Matrix mMatrix = new Matrix();
    private final int mControlLocation = RIGHT_BOTTOM;
    private final int mEditLocation = RIGHT_TOP;
    private final int mDeleteLocation = LEFT_TOP;
    private final Path mPath = new Path();
    @NonNull
    private final PointF mPreMovePointF = new PointF();
    @NonNull
    private final PointF mCurMovePointF = new PointF();
    protected TUIMultimediaData<Status> mTuiDataStatus = new TUIMultimediaData<>(Status.STATUS_INIT);
    private boolean mShowDelete = true;
    private boolean mShowEdit = true;
    private PasterType mPasterType;
    private boolean isMeasured = false;
    private Bitmap mBitmap;
    private int mViewWidth, mViewHeight;
    private float mDegree = DEFAULT_DEGREE;
    private float mScale = DEFAULT_SCALE;
    private int mViewPaddingLeft;
    private int mViewPaddingTop;
    private Point mLTPoint;
    private Point mRTPoint;
    private Point mRBPoint;
    private Point mLBPoint;
    private Point mEditPoint = new Point();
    private Point mDeletePoint = new Point();
    private Point mRotatePoint = new Point();
    private Drawable mEditDrawable;
    private Drawable mDeleteDrawable;
    private Drawable mRotateDrawable;
    private Paint mPaint;

    private int mFramePadding = DEFAULT_FRAME_PADDING;
    private int mFrameColor = DEFAULT_FRAME_COLOR;
    private int mFrameWidth = DEFAULT_FRAME_WIDTH;
    private int mOffsetX;
    private int mOffsetY;
    private int mImageLeft;
    private int mImageTop;
    private int mImageWidth;
    private int mOperationIconSize = DRAWABLE_SIZE_DP;
    private Zoom touchDownZoom = Zoom.IMAGE_ZOOM;
    private boolean mCanTouch = true;

    private Size mOriginParentSize;
    private Size mLastParentPosition;

    float mViewScaleX = 1.0f;
    float mViewScaleY = 1.0f;

    int mRotation = 0;

    public FloatLayerView(Context context) {
        super(context);
        init();
    }

    public void showDelete(boolean showDelete) {
        mShowDelete = showDelete;
    }

    public void showEdit(boolean showEdit) {
        mShowEdit = showEdit;
    }

    public void setCanTouch(boolean touch) {
        mCanTouch = touch;
    }

    public void setImageScale(float scale) {
        LiteavLog.i(TAG, "set image scale. scale = " + scale);
        if (this.mScale != scale) {
            this.mScale = scale;
            transformDraw();
        }
    }

    public void unSelect() {
        LiteavLog.i(TAG, "unSelect");
        if (mTuiDataStatus.get() == Status.STATUS_SELECTED) {
            mTuiDataStatus.set(Status.STATUS_INIT);
        }
        invalidate();
    }

    public TUIMultimediaData<Status> tuiDataGetStatus() {
        return mTuiDataStatus;
    }

    public void setImageBitmap(@Nullable Bitmap bitmap) {
        if (mBitmap != null && bitmap != null && !mBitmap.equals(bitmap)) {
            mBitmap.recycle();
        }
        mBitmap = bitmap;
        transformDraw();
    }

    public PasterType getPasterType() {
        return mPasterType;
    }

    public void setPasterType(PasterType type) {
        mPasterType = type;
    }

    public Bitmap getRotateBitmap() {
        if (mBitmap == null) {
            LiteavLog.e(TAG, "get rotate bitmap is null");
            return null;
        }
        return Bitmap.createBitmap(this.mBitmap, 0, 0, this.mBitmap.getWidth(),
                this.mBitmap.getHeight(), mMatrix, true);
    }

    public int getImageLeft() {
        return this.mImageLeft;
    }

    public int getImageTop() {
        return this.mImageTop;
    }

    public int getImageWidth() {
        return this.mImageWidth;
    }

    public void setPadding(int padding) {
        mFramePadding = padding;
    }

    public void setBorderWidth(int borderWidth) {
        mFrameWidth = borderWidth;
    }

    public void setBorderColor(int color) {
        mFrameColor = getResources().getColor(color);
    }

    public void setEditIconResource(int resId) {
        mEditDrawable = getResources().getDrawable(resId);
    }

    public void setRotateIconResource(int resId) {
        mRotateDrawable = getResources().getDrawable(resId);
    }

    private void init() {
        mOperationIconSize = TUIMultimediaResourceUtils.dip2px(getContext(), DRAWABLE_SIZE_DP);

        DisplayMetrics metrics = getContext().getResources().getDisplayMetrics();
        mFramePadding = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, DEFAULT_FRAME_PADDING, metrics);
        mFrameWidth = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, DEFAULT_FRAME_WIDTH, metrics);

        mFrameColor = DEFAULT_FRAME_COLOR;
        mScale = DEFAULT_SCALE;
        mDegree = DEFAULT_DEGREE;

        mRotateDrawable = TUIMultimediaResourceUtils.getDrawable(DEFAULT_ROTATION_DRAWABLE_ID);
        mEditDrawable = TUIMultimediaResourceUtils.getDrawable(DEFAULT_EDIT_DRAWABLE_ID);
        mDeleteDrawable = TUIMultimediaResourceUtils.getDrawable(DEFAULT_DELETE_DRAWABLE_ID);

        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setColor(mFrameColor);
        mPaint.setStrokeWidth(mFrameWidth);
        mPaint.setStyle(Paint.Style.STROKE);

        transformDraw();
    }

    public void onParentSizeChange(Size parentSize) {
        if (mOriginParentSize != null) {
            if (mOriginParentSize.getWidth() != 0) {
                mViewScaleX = parentSize.width * 1.0f / mOriginParentSize.getWidth();
            }

            if (mOriginParentSize.getHeight() != 0) {
                mViewScaleY = parentSize.height * 1.0f / mOriginParentSize.getHeight();
            }
        }

        float mViewScaleAddX = 1.0f;
        float mViewScaleAddY = 1.0f;
        if (mLastParentPosition != null) {
            mViewScaleAddX = parentSize.width * 1.0f / mLastParentPosition.width;
            mViewScaleAddY = parentSize.height * 1.0f / mLastParentPosition.height;
        }
        mLastParentPosition = new Size(parentSize.width, parentSize.height);

        mCenterPoint.x = mCenterPoint.x * mViewScaleAddX;
        mCenterPoint.y = mCenterPoint.y * mViewScaleAddY;
        transformDraw();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (!isMeasured) {
            ViewGroup viewGroup = (ViewGroup) getParent();
            if (null != viewGroup) {
                int parentWidth = viewGroup.getWidth();
                int parentHeight = viewGroup.getHeight();
                mCenterPoint.set(parentWidth * 1.0f / 2, parentHeight * 1.0f / 2);

                if (mOriginParentSize == null) {
                    mOriginParentSize = new Size(parentWidth, parentHeight);
                    mLastParentPosition = mOriginParentSize;
                    LiteavLog.i(TAG, "viewGroup = " + viewGroup);
                }
            }
            isMeasured = true;
            adjustLayout();
        }
    }

    private void adjustLayout() {
        int minDistanceToEdge = TUIMultimediaResourceUtils.dip2px(getContext(), MIN_DISTANCE_TO_EDGE_DP);
        int halfViewWidth = (int) (mViewWidth * 1.0f / 2);
        int halfViewHeight = (int) (mViewHeight * 1.0f / 2);

        if (mCenterPoint.x < minDistanceToEdge - halfViewWidth) {
            mCenterPoint.x = minDistanceToEdge - halfViewWidth;
        }

        if (mCenterPoint.y < minDistanceToEdge - halfViewHeight) {
            mCenterPoint.y = minDistanceToEdge - halfViewHeight;
        }

        ViewGroup mViewGroup = (ViewGroup) getParent();
        if (null != mViewGroup) {
            int parentWidth = mViewGroup.getWidth();
            if (mCenterPoint.x > parentWidth - minDistanceToEdge + halfViewWidth) {
                mCenterPoint.x = parentWidth - minDistanceToEdge + halfViewWidth;
            }

            int parentHeight = mViewGroup.getHeight();
            if (mCenterPoint.y > parentHeight - minDistanceToEdge + halfViewHeight) {
                mCenterPoint.y = parentHeight - minDistanceToEdge + halfViewHeight;
            }
        }

        int actualWidth = mViewWidth + mOperationIconSize;
        int actualHeight = mViewHeight + mOperationIconSize;
        int newPaddingLeft = (int) (mCenterPoint.x - actualWidth / 2.0);
        int newPaddingTop = (int) (mCenterPoint.y - actualHeight / 2.0);

        if (mViewPaddingLeft != newPaddingLeft || mViewPaddingTop != newPaddingTop) {
            mViewPaddingLeft = newPaddingLeft;
            mViewPaddingTop = newPaddingTop;
        }
        layout(newPaddingLeft, newPaddingTop, newPaddingLeft + actualWidth,
                newPaddingTop + actualHeight);
        mImageLeft = newPaddingLeft + mOperationIconSize / 2;
        mImageTop = newPaddingTop + mOperationIconSize / 2;
        mImageWidth = mViewWidth;
    }

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);

        if (mBitmap == null) {
            return;
        }

        transformDraw();
        canvas.drawBitmap(mBitmap, mMatrix, mPaint);
        if (mTuiDataStatus.get() == Status.STATUS_SELECTED) {
            drawOuterFrame(canvas);
            drawOperationIcon(canvas);
        }
        adjustLayout();
    }

    private void drawOuterFrame(@NonNull Canvas canvas) {
        mPath.reset();
        mPath.moveTo(mLTPoint.x, mLTPoint.y);
        mPath.lineTo(mRTPoint.x, mRTPoint.y);
        mPath.lineTo(mRBPoint.x, mRBPoint.y);
        mPath.lineTo(mLBPoint.x, mLBPoint.y);
        mPath.lineTo(mLTPoint.x, mLTPoint.y);
        canvas.drawPath(mPath, mPaint);
    }

    private void drawOperationIcon(@NonNull Canvas canvas) {
        if (mRotateDrawable != null) {
            mRotateDrawable.setBounds(mRotatePoint.x - mOperationIconSize / 2,
                    mRotatePoint.y - mOperationIconSize / 2,
                    mRotatePoint.x + mOperationIconSize / 2,
                    mRotatePoint.y + mOperationIconSize / 2);
            canvas.save();
            canvas.rotate(-45.0f, mRotatePoint.x, mRotatePoint.y);
            mRotateDrawable.draw(canvas);
            canvas.restore();
        }

        if (mEditDrawable != null && mShowEdit) {
            mEditDrawable.setBounds(mEditPoint.x - mOperationIconSize / 2,
                    mEditPoint.y - mOperationIconSize / 2,
                    mEditPoint.x + mOperationIconSize / 2,
                    mEditPoint.y + mOperationIconSize / 2);
            mEditDrawable.draw(canvas);
        }

        if (mDeleteDrawable != null && mShowDelete) {
            mDeleteDrawable.setBounds(mDeletePoint.x - mOperationIconSize / 2,
                    mDeletePoint.y - mOperationIconSize / 2,
                    mDeletePoint.x + mOperationIconSize / 2,
                    mDeletePoint.y + mOperationIconSize / 2);
            mDeleteDrawable.draw(canvas);
        }
    }

    public boolean onTouchEvent(@NonNull MotionEvent event) {
        if (!mCanTouch) {
            return false;
        }

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mPreMovePointF.set(event.getX() + mViewPaddingLeft, event.getY() + mViewPaddingTop);
                touchDownZoom = judgeZoom(event.getX(), event.getY());
                if (touchDownZoom != Zoom.ROTATE_ZOOM) {
                    mMoveSize.x = 0;
                    mMoveSize.y = 0;
                }
                break;
            case MotionEvent.ACTION_UP:
                if (touchDownZoom == Zoom.ROTATE_ZOOM) {
                    break;
                } else if (Math.abs(mMoveSize.x) > 3 || Math.abs(mMoveSize.y) > 3) {
                    break;
                }

                Zoom touchUpZoom = judgeZoom(event.getX(), event.getY());
                switch (touchUpZoom) {
                    case EDIT_ZOOM:
                        mTuiDataStatus.set(Status.STATUS_EDIT);
                        break;
                    case DELETE_ZOOM:
                        mTuiDataStatus.set(Status.STATUS_DELETE);
                        break;
                    case IMAGE_ZOOM:
                        if (mTuiDataStatus.get() == Status.STATUS_INIT) {
                            mTuiDataStatus.set(Status.STATUS_SELECTED);
                            break;
                        }

                        if (mShowEdit && mTuiDataStatus.get() == Status.STATUS_SELECTED) {
                            mTuiDataStatus.set(Status.STATUS_EDIT);
                            break;
                        }
                }
                invalidate();
            case MotionEvent.ACTION_MOVE:
                mCurMovePointF.set(event.getX() + mViewPaddingLeft, event.getY() + mViewPaddingTop);
                if (touchDownZoom == Zoom.ROTATE_ZOOM) {
                    rotateImage();
                } else {
                    moveImage();
                }
                mPreMovePointF.set(mCurMovePointF);
                break;
        }
        return true;
    }

    private void rotateImage() {
        if (mBitmap == null) {
            return;
        }

        int halfBitmapWidth = mBitmap.getWidth() / 2;
        int halfBitmapHeight = mBitmap.getHeight() / 2;

        float bitmapToCenterDistance = TUIMultimediaGraphComputerUtils.distance4PointF(new PointF(0, 0),
                new PointF(halfBitmapWidth * mViewScaleX, halfBitmapHeight * mViewScaleY));
        float moveToCenterDistance = TUIMultimediaGraphComputerUtils.distance4PointF(mCenterPoint, mCurMovePointF);
        float scale = moveToCenterDistance / bitmapToCenterDistance;

        if (scale <= MIN_SCALE) {
            scale = MIN_SCALE;
        } else if (scale >= MAX_SCALE) {
            scale = MAX_SCALE;
        }

        double a = TUIMultimediaGraphComputerUtils.distance4PointF(mCenterPoint, mPreMovePointF);
        double b = TUIMultimediaGraphComputerUtils.distance4PointF(mPreMovePointF, mCurMovePointF);
        double c = TUIMultimediaGraphComputerUtils.distance4PointF(mCenterPoint, mCurMovePointF);

        double cosb = (a * a + c * c - b * b) / (2 * a * c);

        if (cosb >= 1) {
            cosb = 1f;
        }

        double radian = Math.acos(cosb);
        float newDegree = (float) TUIMultimediaGraphComputerUtils.radianToDegree(radian);

        PointF centerToProMove = new PointF((mPreMovePointF.x - mCenterPoint.x),
                (mPreMovePointF.y - mCenterPoint.y));

        PointF centerToCurMove = new PointF((mCurMovePointF.x - mCenterPoint.x),
                (mCurMovePointF.y - mCenterPoint.y));

        float result = centerToProMove.x * centerToCurMove.y
                - centerToProMove.y * centerToCurMove.x;

        if (result < 0) {
            newDegree = -newDegree;
        }

        mDegree = mDegree + newDegree;
        mScale = scale;

        transformDraw();
    }

    private void moveImage() {
        mCenterPoint.x += mCurMovePointF.x - mPreMovePointF.x;
        mCenterPoint.y += mCurMovePointF.y - mPreMovePointF.y;

        mMoveSize.x += mCurMovePointF.x - mPreMovePointF.x;
        mMoveSize.y += mCurMovePointF.y - mPreMovePointF.y;

        adjustLayout();
    }

    private void transformDraw() {
        if (mBitmap == null) {
            return;
        }

        int bitmapWidth = (int) (mBitmap.getWidth() * mScale * mViewScaleX);
        int bitmapHeight = (int) (mBitmap.getHeight() * mScale * mViewScaleY);
        int framePadding = (int) (mFramePadding * Math.max(mViewScaleX, mViewScaleY));
        computeRect(-framePadding, -framePadding, bitmapWidth + framePadding,
                bitmapHeight + framePadding, mDegree);

        LiteavLog.i(TAG, "mScale = " + mScale + " mViewScaleX = " + mViewScaleX + " mViewScaleY= " + mViewScaleY);
        mMatrix.setScale(mScale * mViewScaleX, mScale * mViewScaleY);
        mMatrix.postRotate(mDegree % 360, bitmapWidth * 1.0f / 2, bitmapHeight * 1.0f / 2);
        mMatrix.postTranslate(
                mOffsetX + mOperationIconSize * 1.0f / 2, mOffsetY + mOperationIconSize * 1.0f / 2);

        adjustLayout();
    }

    private void computeRect(int left, int top, int right, int bottom, float degree) {
        Point lt = new Point(left, top);
        Point rt = new Point(right, top);
        Point rb = new Point(right, bottom);
        Point lb = new Point(left, bottom);
        Point cp = new Point((left + right) / 2, (top + bottom) / 2);
        mLTPoint = TUIMultimediaGraphComputerUtils.obtainRotationPoint(cp, lt, degree);
        mRTPoint = TUIMultimediaGraphComputerUtils.obtainRotationPoint(cp, rt, degree);
        mRBPoint = TUIMultimediaGraphComputerUtils.obtainRotationPoint(cp, rb, degree);
        mLBPoint = TUIMultimediaGraphComputerUtils.obtainRotationPoint(cp, lb, degree);

        int maxCoordinateX = getMaxValue(mLTPoint.x, mRTPoint.x, mRBPoint.x, mLBPoint.x);
        int minCoordinateX = getMinValue(mLTPoint.x, mRTPoint.x, mRBPoint.x, mLBPoint.x);

        mViewWidth = maxCoordinateX - minCoordinateX;

        int maxCoordinateY = getMaxValue(mLTPoint.y, mRTPoint.y, mRBPoint.y, mLBPoint.y);
        int minCoordinateY = getMinValue(mLTPoint.y, mRTPoint.y, mRBPoint.y, mLBPoint.y);

        mViewHeight = maxCoordinateY - minCoordinateY;

        Point viewCenterPoint = new Point(
                (maxCoordinateX + minCoordinateX) / 2, (maxCoordinateY + minCoordinateY) / 2);

        mOffsetX = mViewWidth / 2 - viewCenterPoint.x;
        mOffsetY = mViewHeight / 2 - viewCenterPoint.y;

        int halfDrawableWidth = mOperationIconSize / 2;
        int halfDrawableHeight = mOperationIconSize / 2;

        mLTPoint.x += (mOffsetX + halfDrawableWidth);
        mRTPoint.x += (mOffsetX + halfDrawableWidth);
        mRBPoint.x += (mOffsetX + halfDrawableWidth);
        mLBPoint.x += (mOffsetX + halfDrawableWidth);

        mLTPoint.y += (mOffsetY + halfDrawableHeight);
        mRTPoint.y += (mOffsetY + halfDrawableHeight);
        mRBPoint.y += (mOffsetY + halfDrawableHeight);
        mLBPoint.y += (mOffsetY + halfDrawableHeight);

        mRotatePoint = locatePoint(mControlLocation);
        mEditPoint = locatePoint(mEditLocation);
        mDeletePoint = locatePoint(mDeleteLocation);
    }

    private Point locatePoint(int location) {
        switch (location) {
            case LEFT_TOP:
                return mLTPoint;
            case RIGHT_TOP:
                return mRTPoint;
            case RIGHT_BOTTOM:
                return mRBPoint;
            case LEFT_BOTTOM:
                return mLBPoint;
        }
        return mLTPoint;
    }

    private Zoom judgeZoom(float x, float y) {
        PointF touchPoint = new PointF(x, y);
        PointF controlPointF = new PointF(mRotatePoint);

        float distanceToControl = TUIMultimediaGraphComputerUtils.distance4PointF(touchPoint, controlPointF);
        if (distanceToControl < mOperationIconSize / 2.0) {
            return Zoom.ROTATE_ZOOM;
        }

        if (mShowEdit) {
            float disToEdit = TUIMultimediaGraphComputerUtils.distance4PointF(touchPoint, new PointF(mEditPoint));
            if (disToEdit < mOperationIconSize / 2.0) {
                return Zoom.EDIT_ZOOM;
            }
        }

        if (mShowDelete) {
            float disToDelete = TUIMultimediaGraphComputerUtils.distance4PointF(touchPoint, new PointF(mDeletePoint));
            if (disToDelete < mOperationIconSize / 2.0) {
                return Zoom.DELETE_ZOOM;
            }
        }

        return Zoom.IMAGE_ZOOM;
    }

    private int getMaxValue(Integer... array) {
        List<Integer> list = Arrays.asList(array);
        Collections.sort(list);
        return list.get(list.size() - 1);
    }

    private int getMinValue(Integer... array) {
        List<Integer> list = Arrays.asList(array);
        Collections.sort(list);
        return list.get(0);
    }

    public enum Status {
        STATUS_INIT,
        STATUS_EDIT,
        STATUS_DELETE,
        STATUS_SELECTED
    }

    private enum Zoom {
        IMAGE_ZOOM,
        ROTATE_ZOOM,
        EDIT_ZOOM,
        DELETE_ZOOM
    }
}
