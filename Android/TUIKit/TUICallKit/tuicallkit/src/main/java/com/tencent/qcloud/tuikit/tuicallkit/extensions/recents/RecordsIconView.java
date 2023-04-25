package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.view.common.RoundCornerImageView;
import com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage.GridImageSynthesizer;

import java.util.List;

public class RecordsIconView extends RoundCornerImageView {
    private int mImageSize         = 100;
    private int mBackground        = Color.parseColor("#cfd3d8");
    private int mDefaultImageResId = 0;
    private int mImageGap          = 6;

    private GridImageSynthesizer mGridImageSynthesizer;

    public RecordsIconView(Context context) {
        super(context);
        init(context);
    }

    public RecordsIconView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initAttrs(attrs);
        init(context);
    }

    public RecordsIconView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initAttrs(attrs);
        init(context);
    }

    private void initAttrs(AttributeSet attributeSet) {
        TypedArray ta = getContext().obtainStyledAttributes(attributeSet, R.styleable.SynthesizedImageView);
        if (null != ta) {
            mBackground = ta.getColor(R.styleable.SynthesizedImageView_image_background, mBackground);
            mDefaultImageResId = ta.getResourceId(R.styleable.SynthesizedImageView_default_image, mDefaultImageResId);
            mImageSize = ta.getDimensionPixelSize(R.styleable.SynthesizedImageView_image_size, mImageSize);
            mImageGap = ta.getDimensionPixelSize(R.styleable.SynthesizedImageView_image_gap, mImageGap);
            ta.recycle();
        }
    }

    private void init(Context context) {
        mGridImageSynthesizer = new GridImageSynthesizer(context, this);
        mGridImageSynthesizer.setMaxSize(mImageSize, mImageSize);
        mGridImageSynthesizer.setDefaultImage(mDefaultImageResId);
        mGridImageSynthesizer.setBgColor(mBackground);
        mGridImageSynthesizer.setGap(mImageGap);
    }

    public RecordsIconView displayImage(List<Object> imageUrls) {
        mGridImageSynthesizer.setImageUrls(imageUrls);
        return this;
    }

    public void setImageId(String id) {
        mGridImageSynthesizer.setImageId(id);
    }

    public void load(String imageId) {
        mGridImageSynthesizer.load(imageId);
    }

    public void clear() {
        mGridImageSynthesizer.clearImage();
    }
}
