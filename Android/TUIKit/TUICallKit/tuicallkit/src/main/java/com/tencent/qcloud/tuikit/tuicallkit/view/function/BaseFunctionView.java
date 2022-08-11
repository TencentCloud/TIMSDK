package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingAction;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;

public abstract class BaseFunctionView extends RelativeLayout {
    protected Context                mContext;
    protected TUICallingAction       mCallingAction;
    protected boolean                mIsCameraOpen;
    protected TUICommonDefine.Camera mCamera;
    protected boolean                mIsMicMute;
    protected boolean                mIsHandsFree;
    protected UserLayout             mLocalUserLayout;

    public BaseFunctionView(Context context) {
        super(context);
        mContext = context.getApplicationContext();
        mCallingAction = new TUICallingAction(context);
    }

    public void updateCameraOpenStatus(boolean isOpen) {
        mIsCameraOpen = isOpen;
    }

    public void updateFrontCameraStatus(TUICommonDefine.Camera camera) {
        mCamera = camera;
    }

    public void updateMicMuteStatus(boolean isMicMute) {
        mIsMicMute = isMicMute;
    }

    public void updateHandsFreeStatus(boolean isHandsFree) {
        mIsHandsFree = isHandsFree;
    }

    public void updateTextColor(int color) {
    }

    public void setLocalUserLayout(UserLayout layout) {
        mLocalUserLayout = layout;
    }
}
