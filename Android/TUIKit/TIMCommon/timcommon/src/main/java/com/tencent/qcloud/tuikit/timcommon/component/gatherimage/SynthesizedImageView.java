package com.tencent.qcloud.tuikit.timcommon.component.gatherimage;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.R;

import java.util.List;

public class SynthesizedImageView extends ShadeImageView {
    /**
     *
     * Group Chat Avatar Synthesizer
     */
    TeamHeadSynthesizer teamHeadSynthesizer;
    int imageSize = 100;
    int synthesizedBg = Color.parseColor("#cfd3d8");
    int defaultImageResId = 0;
    int imageGap = 6;

    public SynthesizedImageView(Context context) {
        super(context);
        init(context);
    }

    public SynthesizedImageView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initAttrs(attrs);
        init(context);
    }

    public SynthesizedImageView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initAttrs(attrs);
        init(context);
    }

    private void initAttrs(AttributeSet attributeSet) {
        TypedArray ta = getContext().obtainStyledAttributes(attributeSet, R.styleable.SynthesizedImageView);
        if (null != ta) {
            synthesizedBg = ta.getColor(R.styleable.SynthesizedImageView_synthesized_image_bg, synthesizedBg);
            defaultImageResId = ta.getResourceId(R.styleable.SynthesizedImageView_synthesized_default_image, defaultImageResId);
            imageSize = ta.getDimensionPixelSize(R.styleable.SynthesizedImageView_synthesized_image_size, imageSize);
            imageGap = ta.getDimensionPixelSize(R.styleable.SynthesizedImageView_synthesized_image_gap, imageGap);
            ta.recycle();
        }
    }

    private void init(Context context) {
        teamHeadSynthesizer = new TeamHeadSynthesizer(context, this);
        teamHeadSynthesizer.setMaxWidthHeight(imageSize, imageSize);
        teamHeadSynthesizer.setDefaultImage(defaultImageResId);
        teamHeadSynthesizer.setBgColor(synthesizedBg);
        teamHeadSynthesizer.setGap(imageGap);
    }

    public SynthesizedImageView displayImage(List<Object> imageUrls) {
        teamHeadSynthesizer.getMultiImageData().setImageUrls(imageUrls);
        return this;
    }

    public SynthesizedImageView defaultImage(int defaultImage) {
        teamHeadSynthesizer.setDefaultImage(defaultImage);
        return this;
    }

    public SynthesizedImageView synthesizedWidthHeight(int maxWidth, int maxHeight) {
        teamHeadSynthesizer.setMaxWidthHeight(maxWidth, maxHeight);
        return this;
    }

    public void setImageId(String id) {
        teamHeadSynthesizer.setImageId(id);
    }

    public void load(String imageId) {
        teamHeadSynthesizer.load(imageId);
    }

    public void clear() {
        teamHeadSynthesizer.clearImage();
    }
}
