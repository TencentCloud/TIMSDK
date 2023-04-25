package com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage;

import android.graphics.Bitmap;
import android.graphics.Color;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GridImageData implements Cloneable {
    private static final int MAX_SIZE = 9;

    protected List<Object>         imageUrlList;
    protected Map<Integer, Bitmap> bitmapMap;
    protected int                  defaultImageResId;
    protected int                  bgColor = Color.parseColor("#cfd3d8");

    protected int targetImageSize;
    protected int maxWidth;
    protected int maxHeight;
    protected int rowCount;
    protected int columnCount;
    protected int gap = 6;

    public GridImageData() {
    }

    public GridImageData(List<Object> imageUrlList, int defaultImageResId) {
        this.imageUrlList = imageUrlList;
        this.defaultImageResId = defaultImageResId;
    }

    public int getDefaultImageResId() {
        return defaultImageResId;
    }

    public void setDefaultImageResId(int defaultImageResId) {
        this.defaultImageResId = defaultImageResId;
    }

    public List<Object> getImageUrlList() {
        return imageUrlList;
    }

    public void setImageUrlList(List<Object> imageUrlList) {
        this.imageUrlList = imageUrlList;
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
        if (null != imageUrlList) {
            return Math.min(imageUrlList.size(), MAX_SIZE);
        } else {
            return 0;
        }
    }

    @Override
    protected GridImageData clone() throws CloneNotSupportedException {
        GridImageData gridImageData = (GridImageData) super.clone();
        if (imageUrlList != null) {
            gridImageData.imageUrlList = new ArrayList<>(imageUrlList.size());
            gridImageData.imageUrlList.addAll(imageUrlList);
        }
        if (bitmapMap != null) {
            gridImageData.bitmapMap = new HashMap<>();
            gridImageData.bitmapMap.putAll(bitmapMap);
        }
        return gridImageData;
    }
}
