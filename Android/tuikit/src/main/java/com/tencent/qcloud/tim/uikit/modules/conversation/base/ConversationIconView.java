package com.tencent.qcloud.tim.uikit.modules.conversation.base;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.gatherimage.SynthesizedImageView;
import com.tencent.qcloud.tim.uikit.utils.ImageUtil;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

import java.util.List;

/**
 * 会话列表头像View
 */
public class ConversationIconView extends RelativeLayout {

    private ImageView mIconView;

    private static final int icon_size = ScreenUtil.getPxByDp(50);


    public ConversationIconView(Context context) {
        super(context);
        init();
    }

    public ConversationIconView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ConversationIconView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }


    public void invokeInformation(ConversationInfo conversationInfo, DynamicConversationIconView infoView) {
        infoView.setLayout(this);
        infoView.setMainViewId(R.id.profile_icon_group);
        infoView.parseInformation(conversationInfo);
    }

    private void init() {
        inflate(getContext(), R.layout.profile_icon_view, this);
        mIconView = findViewById(R.id.profile_icon);
        ((SynthesizedImageView) mIconView).defaultImage(R.drawable.default_user_icon);
    }

    public void setProfileImageView(ImageView iconView) {
        mIconView = iconView;
        LayoutParams params = new LayoutParams(icon_size, icon_size);
        params.addRule(RelativeLayout.CENTER_IN_PARENT);
        addView(mIconView, params);

    }

    /**
     * 设置会话头像的url
     *
     * @param iconUrls 头像url,最多只取前9个
     */
    public void setIconUrls(List<String> iconUrls) {
        if (mIconView instanceof SynthesizedImageView) {
            ((SynthesizedImageView) (mIconView)).displayImage(iconUrls).load();
        }
    }


    public void setDefaultImageResId(int resId) {
        BitmapDrawable bd = (BitmapDrawable) getContext().getResources().getDrawable(resId);
        mIconView.setImageBitmap(bd.getBitmap());
    }

    public void setBitmapResId(int resId) {
        BitmapDrawable bd = (BitmapDrawable) getContext().getResources().getDrawable(resId);
        Bitmap bitmap = ImageUtil.toRoundBitmap(bd.getBitmap());
        mIconView.setImageBitmap(bitmap);
    }
}

