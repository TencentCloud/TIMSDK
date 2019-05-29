package com.tencent.qcloud.uikit.business.chat.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.common.widget.gatherimage.SynthesizedImageView;

import java.util.List;


public class ChatIconView extends RelativeLayout {

    private SynthesizedImageView mIconView;
    private DynamicChatUserIconView mDynamicView;
    private int mDefaultImageResId;
    private int mIconRadius;

    public ChatIconView(Context context) {
        super(context);
        init(null);
    }

    public ChatIconView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public ChatIconView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }

    public void setDynamicChatIconView(DynamicChatUserIconView dynamicView) {
        mDynamicView = dynamicView;
        mDynamicView.setLayoutContainer(this);
        mDynamicView.setMainViewId(R.id.profile_icon_group);
        if (mDynamicView.getIconRadius() >= 0)
            mIconView.setRadius(mDynamicView.getIconRadius());
    }


    public void invokeInformation(MessageInfo messageInfo) {
        mIconView.load();
        if (mDynamicView != null)
            mDynamicView.parseInformation(messageInfo);
    }

    private void init(AttributeSet attributeSet) {
        inflate(getContext(), R.layout.profile_icon_view, this);
        if (attributeSet != null) {
            TypedArray ta = getContext().obtainStyledAttributes(attributeSet, R.styleable.ChatIconView);
            if (null != ta) {
                mDefaultImageResId = ta.getResourceId(R.styleable.ChatIconView_default_image, mDefaultImageResId);
                mIconRadius = ta.getDimensionPixelSize(R.styleable.ChatIconView_image_radius, mIconRadius);
                ta.recycle();
            }
        }

        mIconView = findViewById(R.id.profile_icon);
        if (mDefaultImageResId > 0)
            mIconView.defaultImage(mDefaultImageResId);
        if (mIconRadius > 0)
            mIconView.setRadius(mIconRadius);

    }

    public void setDefaultImageResId(int resId) {
        mDefaultImageResId = resId;
        mIconView.defaultImage(resId);
    }


    public void setIconUrls(List<String> iconUrls) {
        mIconView.displayImage(iconUrls).load();

    }


}
