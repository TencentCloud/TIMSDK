package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data;

import android.graphics.Bitmap;
import com.google.gson.annotations.SerializedName;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;

public class PicturePasterItem {

    private final String TAG = PicturePasterItem.class.getSimpleName() + "_" + hashCode();

    @SerializedName("item_image_path")
    private String mImageFilePath;

    @SerializedName("item_icon_path")
    private String mIconFilePath;

    @SerializedName("item_is_file_selector")
    private boolean mIsFileSelector = false;

    transient private Bitmap mImage;
    transient private Bitmap mIcon;

    public PicturePasterItem(String imageFilePath, String iconFilePath) {
        mImageFilePath = imageFilePath;
        mIconFilePath = iconFilePath;
    }

    public PicturePasterItem(Bitmap pasterImage, Bitmap pasterIcon) {
        mImage = pasterImage;
        mIcon = pasterIcon;
    }

    public Bitmap getPasterImage() {
        if (mImage == null) {
            mImage = TUIMultimediaFileUtil.decodeBitmap(mImageFilePath);
        }
        return mImage;
    }

    public Bitmap getPasterIcon() {
        if (mIcon != null) {
            return mIcon;
        }

        mIcon = TUIMultimediaFileUtil.decodeBitmap(mIconFilePath);
        if (mIcon != null) {
            return mIcon;
        }

        return getPasterImage();
    }

    public boolean isFileSelector() {
        return mIsFileSelector;
    }


    public void recycleBitmap() {
        if (mImage != null) {
            mImage.recycle();
            mImage = null;
        }

        if (mIcon != null) {
            mIcon.recycle();
            mIcon = null;
        }
    }
}
