package com.tencent.cloud.tuikit.roomkit.view.settingview;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

public class ShareSettingView extends CoordinatorLayout {

    private Button  mShare;
    private boolean mEnableShare = true;

    private OnShareButtonClickListener mListener;

    public ShareSettingView(@NonNull Context context) {
        super(context);
        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_fragment_share_setting, this);
        initView();
    }

    private void initView() {
        mShare = findViewById(R.id.tuiroomkit_btn_screen_share);
        mShare.setEnabled(mEnableShare);
        mShare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mListener != null) {
                    mListener.onClick();
                }
            }
        });
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        mShare.setText(RoomEngineManager.sharedInstance().getRoomStore().videoModel.isScreenSharing()
                ? R.string.tuiroomkit_tv_stop_screen_capture : R.string.tuiroomkit_title_sharing);
    }

    public void setShareButtonClickListener(OnShareButtonClickListener listener) {
        mListener = listener;
    }

    public void enableShareButton(boolean enable) {
        mEnableShare = enable;
        if (mShare != null) {
            mShare.setEnabled(enable);
        }
    }

    public interface OnShareButtonClickListener {
        void onClick();
    }
}
