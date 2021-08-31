package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;

public class LiveAnchorOfflineView extends RelativeLayout {
    private ImageView             mAudienceBackground;
    private TextView              mTvAnchorLeave;
    private Button                mBtnClose;
    private AnchorOfflineCallback mAnchorOfflineCallback;

    public LiveAnchorOfflineView(Context context) {
        this(context, null);
    }

    public LiveAnchorOfflineView(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.live_layout_anchor_offline, this);
        initView();
    }

    private void initView() {
        mAudienceBackground = (ImageView) findViewById(R.id.audience_background);
        mTvAnchorLeave = (TextView) findViewById(R.id.tv_anchor_leave);
        mBtnClose = (Button) findViewById(R.id.btn_close);
        mBtnClose.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mAnchorOfflineCallback != null) {
                    mAnchorOfflineCallback.onClose();
                }
            }
        });
    }

    public void setAnchorOfflineCallback(AnchorOfflineCallback anchorOfflineCallback) {
        mAnchorOfflineCallback = anchorOfflineCallback;
    }

    public void setImageBackground(String coverUrl) {
        GlideEngine.loadImage(mAudienceBackground, coverUrl, R.drawable.live_bg_cover);
    }

    public void setCloseBtnVisibility(int visibility) {
        if (mBtnClose != null) {
            mBtnClose.setVisibility(visibility);
        }
    }

    public interface AnchorOfflineCallback {
        void onClose();
    }
}
