package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.crop;

import android.content.Context;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaTransformLayout;

public class PictureCropControlView extends RelativeLayout implements PictureCropView.CropListener {
    private final String TAG = PictureCropControlView.class + "_" + hashCode();

    private final Context mContext;
    private final TUIMultimediaTransformLayout mPreviewLayout;

    private int mRotation = 0;
    private PictureCropView mPictureCropView;
    private PictureCropControlViewListener mCropControlViewListener;
    private Button mRestoreCropButton;

    public interface PictureCropControlViewListener {
        void onCancelCrop();

        void onConfirmCrop(RectF rectF, int rotation);

        void onRotation(int rotation);
    }

    public PictureCropControlView(Context context, TUIMultimediaTransformLayout previewLayout) {
        super(context);
        mContext = context;
        mPreviewLayout = previewLayout;
    }

    public void setCropMainViewListener(PictureCropControlViewListener cropMainViewListener) {
        mCropControlViewListener = cropMainViewListener;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initView();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
    }

    private void initView() {
        View mRootView = LayoutInflater.from(mContext)
                .inflate(R.layout.multimedia_plugin_edit_picture_crop_view, this);
        mPictureCropView = new PictureCropView(mContext, mPreviewLayout.getInitContentLayout());
        mPictureCropView.setCropListener(this);
        ((RelativeLayout) mRootView).addView(mPictureCropView, 0);

        mRootView.setOnTouchListener((view, motionEvent) -> false);

        mRestoreCropButton = mRootView.findViewById(R.id.crop_restore);
        mRestoreCropButton.setOnClickListener(view -> onRestoreCrop());
        mRestoreCropButton.setEnabled(false);

        mRootView.findViewById(R.id.crop_ok).setOnClickListener(view -> onConfirmCrop());
        mRootView.findViewById(R.id.crop_cancel).setOnClickListener(view -> onCancelCrop());
        mRootView.findViewById(R.id.crop_rotation).setOnClickListener(view -> onRotation());
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
        if (!changed) {
            return;
        }
        updateCropMarkViewLayoutParams();
    }

    private void updateCropMarkViewLayoutParams() {
        if (mPictureCropView == null) {
            return;
        }

        RelativeLayout.LayoutParams layoutParams = (LayoutParams) mPictureCropView.getLayoutParams();
        layoutParams.topMargin = 0;
        layoutParams.leftMargin = 0;
        layoutParams.height = getHeight();
        layoutParams.width = getWidth();

        LiteavLog.i(TAG, " width = " + layoutParams.width + " height = " + layoutParams.height);
        mPictureCropView.setLayoutParams(layoutParams);
    }


    @Override
    public void onCrop(float scaleCenterX, float scaleCenterY, float scale, int moveX, int moveY) {
        if (mPreviewLayout != null) {
            mPreviewLayout.setLimitRect(mPictureCropView.getCropRect());
            mPreviewLayout.scaleContent(scale, new PointF(scaleCenterX, scaleCenterY));
            mPreviewLayout.moveContent(moveX, moveY);
        }
    }

    @Override
    public void onTouch() {
        mRestoreCropButton.setEnabled(isNeedCropOrRotation());
    }

    private void onRestoreCrop() {
        mPreviewLayout.reset();
        mPictureCropView.resetCropRect();
        if (mCropControlViewListener != null && mRotation != 0) {
            mCropControlViewListener.onRotation(0);
        }
        mRotation = 0;
        mRestoreCropButton.setEnabled(false);
    }

    private void onRotation() {
        Rect corpRectInMarkView = mPictureCropView.getCropRect();
        mPreviewLayout.rotation90Content(new Point(corpRectInMarkView.centerX(), corpRectInMarkView.centerY()));
        mPictureCropView.rotation90();
        mRotation = (mRotation + 90 + 360) % 360;
        if (mCropControlViewListener != null) {
            mCropControlViewListener.onRotation(mRotation);
        }
        mRestoreCropButton.setEnabled(isNeedCropOrRotation());
    }

    private void onCancelCrop() {
        if (mCropControlViewListener != null) {
            mCropControlViewListener.onCancelCrop();
        }
    }

    private void onConfirmCrop() {
        LiteavLog.i(TAG, "on confirm crop.");
        if (!isNeedCropOrRotation()) {
            LiteavLog.i(TAG,"do not need crop or rotation.");
            onCancelCrop();
        }

        RectF normalizedCropRect = getNormalizedCropRect();
        if (mCropControlViewListener != null) {
            mCropControlViewListener.onConfirmCrop(normalizedCropRect, mRotation);
        }
    }

    private RectF getNormalizedCropRect() {
        Rect corpRect = mPictureCropView.getCropRect();
        Rect previewRect = mPreviewLayout.getContentRect();

        Rect cropRectInMedia = new Rect(corpRect.left - previewRect.left,
                corpRect.top - previewRect.top,
                corpRect.right - previewRect.left,
                corpRect.bottom - previewRect.top);

        int mediaWidth = previewRect.right - previewRect.left;
        int mediaHeight = previewRect.bottom - previewRect.top;
        RectF cropRectF = new RectF();

        cropRectF.left = cropRectInMedia.left * 1.0f / mediaWidth;
        cropRectF.right = cropRectInMedia.right * 1.0f / mediaWidth;
        cropRectF.top = cropRectInMedia.top * 1.0f / mediaHeight;
        cropRectF.bottom = cropRectInMedia.bottom * 1.0f / mediaHeight;

        if (mRotation == 90) {
            float left = cropRectF.left;
            float right = cropRectF.right;
            cropRectF.left = cropRectF.top;
            cropRectF.right =  cropRectF.bottom;
            cropRectF.top = 1 - right;
            cropRectF.bottom = 1 - left;
        } else if (mRotation == 180) {
            cropRectF.top = 1 - cropRectF.bottom;
            cropRectF.bottom = 1 - cropRectF.top;
        } else if (mRotation == 270) {
            float left = cropRectF.left;
            float right = cropRectF.right;
            cropRectF.left = 1 - cropRectF.bottom;
            cropRectF.right = 1 - cropRectF.top;
            cropRectF.top =  left;
            cropRectF.bottom = right;
        }
        return cropRectF;
    }

    private boolean isNeedCropOrRotation() {
        if ((mRotation + 360) % 360 != 0) {
            return true;
        }

        Rect corpRect = mPictureCropView.getCropRect();
        Rect previewRect = mPreviewLayout.getContentRect();
        return !isApproximateRect(corpRect, previewRect);
    }

    private boolean isApproximateRect(Rect rect1, Rect rect2) {
        return Math.abs(rect1.left - rect2.left) < 2 && Math.abs(rect1.right - rect2.right) < 2 &&
                Math.abs(rect1.top - rect2.top) < 2 && Math.abs(rect1.bottom - rect2.bottom) < 2;
    }
}
