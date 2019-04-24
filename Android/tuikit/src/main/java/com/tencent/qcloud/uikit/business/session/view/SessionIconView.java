package com.tencent.qcloud.uikit.business.session.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.common.widget.gatherimage.SynthesizedImageView;

import java.util.List;

public class SessionIconView extends RelativeLayout {
    private ImageView mIconView;

    private static final int icon_size = UIUtils.getPxByDp(50);


    public SessionIconView(Context context) {
        super(context);
        init();
    }

    public SessionIconView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public SessionIconView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }


    public void invokeInformation(SessionInfo sessionInfo, DynamicSessionIconView infoView) {
        infoView.setLayoutContainer(this);
        infoView.setMainViewId(R.id.profile_icon_group);
        infoView.parseInformation(sessionInfo);
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
        ((SynthesizedImageView) mIconView).defaultImage(resId);
    }
}

