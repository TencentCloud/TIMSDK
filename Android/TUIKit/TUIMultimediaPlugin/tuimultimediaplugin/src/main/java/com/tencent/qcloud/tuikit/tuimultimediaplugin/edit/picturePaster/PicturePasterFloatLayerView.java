package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo.PasterType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerViewGroup;

@SuppressLint("ViewConstructor")
public class PicturePasterFloatLayerView extends FloatLayerView {

    private final static int MAX_BITMAP_SIDE_SIZE_DP = 150;
    private final String TAG = PicturePasterFloatLayerView.class + "_" + hashCode();
    private final Context mContext;
    private final FloatLayerViewGroup mFloatLayerViewGroup;

    private final TUIMultimediaDataObserver<Status> mOnStatusChanged = status -> {
        if (status == Status.STATUS_DELETE) {
            onDeleted();
        }
    };

    public PicturePasterFloatLayerView(Context context, FloatLayerViewGroup floatLayerViewGroup, Bitmap bitmap) {
        super(context);
        mContext = context;
        mFloatLayerViewGroup = floatLayerViewGroup;
        mFloatLayerViewGroup.addOperationView(this);
        setPasterType(PasterType.STATIC_PICTURE_PASTER);
        showDelete(true);
        showEdit(false);
        setImageBitmap(bitmap);
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        addObserve();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        removeObserve();
    }

    @Override
    public void setImageBitmap(Bitmap bitmap) {
        if (bitmap == null) {
            return;
        }
        int sideLength = Math.max(bitmap.getWidth(), bitmap.getHeight());
        float maxSideLength = TUIMultimediaResourceUtils.spToPx(mContext, MAX_BITMAP_SIDE_SIZE_DP);
        if (sideLength > maxSideLength) {
            setImageScale(maxSideLength / sideLength);
        }
        super.setImageBitmap(bitmap);
    }

    private void onDeleted() {
        mFloatLayerViewGroup.removeOperationView(this);
    }

    private void addObserve() {
        mTuiDataStatus.observe(mOnStatusChanged);
    }

    private void removeObserve() {
        mTuiDataStatus.removeObserver(mOnStatusChanged);
    }
}