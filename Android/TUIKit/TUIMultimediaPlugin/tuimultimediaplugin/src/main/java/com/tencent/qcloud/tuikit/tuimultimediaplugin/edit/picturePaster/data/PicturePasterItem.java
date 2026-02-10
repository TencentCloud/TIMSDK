package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data;

import android.graphics.Bitmap;
import android.net.Uri;
import com.bumptech.glide.Glide;
import com.google.gson.annotations.SerializedName;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
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
        if (mImage != null) {
            return mImage;
        }

        if (mImageFilePath == null) {
            return null;
        }

        if (TUIMultimediaFileUtil.isHttpPath(mImageFilePath)) {
            try {
                mImage = Glide.with(TUIMultimediaPlugin.getAppContext())
                        .asBitmap().load(mImageFilePath).submit().get();
            } catch (Exception e) {
                LiteavLog.i(TAG,"get paster image fail " + e);
                mImage = null;
            }
            return mImage;
        }
        mImage = TUIMultimediaFileUtil.decodeBitmap(mImageFilePath);
        return mImage;
    }

    public Object getPasterIcon() {
        if (mIcon != null) {
            return mIcon;
        }

        String path = mIconFilePath != null ? mIconFilePath : mImageFilePath;
        if (TUIMultimediaFileUtil.isHttpPath(path)) {
            return path;
        }
        mIcon = TUIMultimediaFileUtil.decodeBitmap(path);
        return mIcon;
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
