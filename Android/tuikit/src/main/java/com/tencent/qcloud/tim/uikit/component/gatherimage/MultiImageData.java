package com.tencent.qcloud.tim.uikit.component.gatherimage;

import android.graphics.Bitmap;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 多张图片数据
 */

public class MultiImageData {
    //图片地址链接
    List<String> imageUrls;
    //默认的图片ID
    int defaultImageResId;
    //下载下来的图片地址
    Map<Integer, Bitmap> bitmapMap;

    final static int maxSize = 9;

    public MultiImageData() {
    }

    public MultiImageData(int defaultImageResId) {
        this.defaultImageResId = defaultImageResId;
    }

    public MultiImageData(List<String> imageUrls, int defaultImageResId) {
        this.imageUrls = imageUrls;
        this.defaultImageResId = defaultImageResId;
    }

    public void setDefaultImageResId(int defaultImageResId) {
        this.defaultImageResId = defaultImageResId;
    }

    public int getDefaultImageResId() {
        return defaultImageResId;
    }

    public List<String> getImageUrls() {
        return imageUrls;
    }

    public void setImageUrls(List<String> imageUrls) {
        this.imageUrls = imageUrls;
    }

    public void putBitmap(Bitmap bitmap, int position) {
        if (null != bitmapMap) {
            synchronized (bitmapMap) {
                bitmapMap.put(position, bitmap);
            }
        } else {
            bitmapMap = new HashMap<>();
            synchronized (bitmapMap) {
                bitmapMap.put(position, bitmap);
            }
        }
    }

    public Bitmap getBitmap(int position) {
        if (null != bitmapMap) {
            synchronized (bitmapMap) {
                return bitmapMap.get(position);
            }
        }
        return null;
    }

    public int size() {
        if (null != imageUrls) {
            return imageUrls.size() > maxSize ? maxSize : imageUrls.size();
        } else {
            return 0;
        }
    }

}
