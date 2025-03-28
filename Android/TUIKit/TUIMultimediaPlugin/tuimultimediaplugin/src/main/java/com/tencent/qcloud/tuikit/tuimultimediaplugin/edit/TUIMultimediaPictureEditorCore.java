package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.RectF;
import androidx.core.math.MathUtils;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.ugc.TXPictureEditer;
import com.tencent.ugc.TXPictureEditer.PictureProcessListener;
import com.tencent.ugc.TXVideoEditConstants.TXPaster;
import java.util.List;

public class TUIMultimediaPictureEditorCore {
    private final String TAG = TUIMultimediaPictureEditorCore.class.getSimpleName() + "_" + hashCode();

    private final Context mContext;
    private TXPictureEditer mPictureEditer;
    private Bitmap mBitmap;

    public TUIMultimediaPictureEditorCore(Context context) {
        LiteavLog.i(TAG,"TUIMultimedia Picture Editor Core Construct");
        mContext = context;
        mPictureEditer = TXPictureEditer.create(context);
    }

    public void release() {
        if (mPictureEditer != null) {
            TXPictureEditer.destroy(mPictureEditer);
        }
    }

    public void resetEditor() {
        LiteavLog.i(TAG,"reset editor");
        if (mPictureEditer != null) {
            TXPictureEditer.destroy(mPictureEditer);
            mPictureEditer = TXPictureEditer.create(mContext);
        }
        mBitmap = null;
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

        int width = mBitmap.getWidth();
        int height = mBitmap.getHeight();

        Rect rect = new Rect();
        rect.left = MathUtils.clamp((int) (width * rectf.left), 0, width);
        rect.right = MathUtils.clamp((int) (width * rectf.right), 0, width);
        rect.top = MathUtils.clamp((int) (height * rectf.top), 0, height);
        rect.bottom = MathUtils.clamp((int) (height * rectf.bottom), 0, height);
        mPictureEditer.setCropRect(rect);
    }

    public void setPasterList(List<TXPaster> pasterList) {
        mPictureEditer.setPasterList(pasterList);
    }

    public void setOutputRotation(int rotation) {
        mPictureEditer.setOutputRotation(rotation);
    }

    public void processPicture(PictureProcessListener pictureProcessListener) {
        LiteavLog.i(TAG,"process  picture");
        mPictureEditer.processPicture(pictureProcessListener);
    }
}
