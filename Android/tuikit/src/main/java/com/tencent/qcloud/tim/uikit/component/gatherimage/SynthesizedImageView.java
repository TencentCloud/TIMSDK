package com.tencent.qcloud.tim.uikit.component.gatherimage;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

import com.tencent.qcloud.tim.uikit.R;

import java.util.List;

/**
 * 合成头像
 */
public class SynthesizedImageView extends ShadeImageView {
    /**
     * 群聊头像合成器
     */
    TeamHeadSynthesizer teamHeadSynthesizer;
    int imageSize = 100;
    int synthesizedBg = Color.parseColor("#cfd3d8");
    int defaultImageResId = R.drawable.default_user_icon;
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

    public SynthesizedImageView displayImage(List<String> imageUrls) {
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


    public void load() {
        teamHeadSynthesizer.load();
    }

}
