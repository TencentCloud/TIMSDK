package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.TypedValue;
import com.google.gson.annotations.SerializedName;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;


public class BeautyItem {

    @SerializedName("item_type")
    private int mItemType;
    @SerializedName("item_level")
    private int mItemLevel = 5;
    @SerializedName("item_name")
    private String mItemName;
    @SerializedName("item_icon_normal")
    private String mItemIconResName;
    @SerializedName("item_filter_bitmap")
    private String mFilterBitmapResource;

    private Bitmap mFilterBitmap;

    public Bitmap getFilterBitmap() {
        if (mFilterBitmapResource == null || mFilterBitmapResource.isEmpty() || !mFilterBitmapResource
                .startsWith("@")) {
            return null;
        }

        if (mFilterBitmap != null) {
            return mFilterBitmap;
        }

        TypedValue value = new TypedValue();
        int resId = TUIMultimediaResourceUtils.getDrawableId(mFilterBitmapResource);
        TUIMultimediaResourceUtils.getResources().openRawResource(resId, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        mFilterBitmap = BitmapFactory.decodeResource(TUIMultimediaResourceUtils.getResources(), resId, opts);
        return mFilterBitmap;
    }

    public int getLevel() {
        return mItemLevel;
    }

    public void setLevel(int level) {
        mItemLevel = level;
    }

    public String getName() {
        if (mItemName.startsWith(TUIMultimediaResourceUtils.STRING_RESOURCE_PREFIX)) {
            return TUIMultimediaResourceUtils.getString(mItemName);
        }
        return mItemName;
    }

    public BeautyInnerType getInnerType() {
        return BeautyInnerType.fromInteger(mItemType);
    }

    public String getIconResName() {
        return mItemIconResName;
    }
}
