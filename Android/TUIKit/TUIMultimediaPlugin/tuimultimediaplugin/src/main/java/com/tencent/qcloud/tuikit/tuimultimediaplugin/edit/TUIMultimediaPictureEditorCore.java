package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.RectF;
import androidx.core.math.MathUtils;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.liteav.base.util.Size;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker;
import com.tencent.ugc.TXPictureEditer;
import com.tencent.ugc.TXPictureEditer.PictureProcessListener;
import com.tencent.ugc.TXVideoEditConstants.TXPaster;
import java.util.List;

public class TUIMultimediaPictureEditorCore {
    private final String TAG = TUIMultimediaPictureEditorCore.class.getSimpleName() + "_" + hashCode();
    private static final int MAX_OUTPUT_SIDE_LENGTH = 1920;
    private static final int MIN_OUTPUT_SIDE_LENGTH = 1280;

    private final Context mContext;
    private TXPictureEditer mPictureEditer;
    private Bitmap mBitmap;
    private Rect mCropRect;
    private int mRotation;

    public TUIMultimediaPictureEditorCore(Context context) {
        LiteavLog.i(TAG,"TUIMultimedia Picture Editor Core Construct");
        mContext = context;
        TUIMultimediaSignatureChecker.getInstance().setSignature();
        mPictureEditer = TXPictureEditer.create(context);
    }

    public void release() {
        if (mPictureEditer != null) {
            TXPictureEditer.destroy(mPictureEditer);
        }
        mCropRect = null;
        mBitmap = null;
        mRotation = 0;
    }

    public void resetEditor() {
        LiteavLog.i(TAG,"reset editor");
        release();
        mPictureEditer = TXPictureEditer.create(mContext);
    }

    public void setSourcePicture(Bitmap bitmap) {
        LiteavLog.i(TAG,"set source picture. bitmap: " + bitmap);
        mPictureEditer.setPicture(bitmap);
        mBitmap = bitmap;
    }

    public Bitmap getSourcePicture() {
        return mBitmap;
    }

    public void setCropRectF(RectF rectf) {
        if (mBitmap == null) {
            LiteavLog.e(TAG,"set  crop rect. bitmap is null");
            return;
        }

        int bitmapWidth = mBitmap.getWidth();
        int bitmapHeight = mBitmap.getHeight();
        if (mCropRect == null) {
            mCropRect = new Rect();
        }

        mCropRect.left = MathUtils.clamp((int) (bitmapWidth * rectf.left), 0, bitmapWidth);
        mCropRect.right = MathUtils.clamp((int) (bitmapWidth * rectf.right), 0, bitmapWidth);
        mCropRect.top = MathUtils.clamp((int) (bitmapHeight * rectf.top), 0, bitmapHeight);
        mCropRect.bottom = MathUtils.clamp((int) (bitmapHeight * rectf.bottom), 0, bitmapHeight);
        mPictureEditer.setCropRect(mCropRect);
    }

    public void setPasterList(List<TXPaster> pasterList) {
        mPictureEditer.setPasterList(pasterList);
    }

    public void setOutputRotation(int rotation) {
        mRotation = rotation;
        mPictureEditer.setOutputRotation(rotation);
    }

    public void processPicture(PictureProcessListener pictureProcessListener) {
        LiteavLog.i(TAG,"process  picture");
        Size outputSize = adjustOutputSize(getOutputSize());
        if (outputSize != null) {
            mPictureEditer.setOutputSize(outputSize.getWidth(), outputSize.getHeight());
        }

        mPictureEditer.processPicture(pictureProcessListener);
    }

    private Size getOutputSize() {
        if (mBitmap == null) {
            return null;
        }

        int bitmapWidth = mBitmap.getWidth();
        int bitmapHeight = mBitmap.getHeight();
        if (mRotation % 360 == 90 || mRotation % 360== 270) {
            bitmapWidth = mBitmap.getHeight();
            bitmapHeight = mBitmap.getWidth() ;
        }

        if (mCropRect == null) {
            return new Size(bitmapWidth, bitmapHeight);
        }

        Size cropSize = new Size(mCropRect.width(), mCropRect.height());
        if (mRotation % 360 == 90 || mRotation % 360== 270) {
            cropSize = new Size(mCropRect.height(), mCropRect.width());
        }
        return cropSize;
    }

    private Size adjustOutputSize(Size size) {
        if (size == null) {
            return null;
        }

        int width = size.getWidth();
        int height = size.getHeight();

        int maxSide = Math.max(width, height);

        if (maxSide > MIN_OUTPUT_SIDE_LENGTH && maxSide <= MAX_OUTPUT_SIDE_LENGTH) {
            return new Size(width, height);
        }

        int outFrameWidth;
        int outFrameHeight;
        if (width >= height) {
            outFrameWidth = Math.min(MAX_OUTPUT_SIDE_LENGTH, Math.max(MIN_OUTPUT_SIDE_LENGTH, width));
            outFrameHeight = (int) (outFrameWidth * 1.0f / width * height);
        } else {
            outFrameHeight = Math.min(MAX_OUTPUT_SIDE_LENGTH, Math.max(MIN_OUTPUT_SIDE_LENGTH, height));
            outFrameWidth = (int) (outFrameHeight * 1.0f / height * width);
        }
        return new Size(outFrameWidth, outFrameHeight);
    }

}
