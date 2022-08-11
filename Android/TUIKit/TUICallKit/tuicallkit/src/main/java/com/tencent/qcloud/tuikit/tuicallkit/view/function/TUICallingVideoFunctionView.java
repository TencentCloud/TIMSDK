package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.ui.R;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

public class TUICallingVideoFunctionView extends BaseFunctionView {
    private static final String TAG = "TUICallingVideoFunctionView";

    private LinearLayout mLayoutOpenCamera;
    private LinearLayout mLayoutMute;
    private LinearLayout mLayoutHandsFree;
    private LinearLayout mLayoutHangup;
    private ImageView    mImageOpenCamera;
    private ImageView    mImageMute;
    private ImageView    mImageHandsFree;
    private ImageView    mImageSwitchCamera;

    public TUICallingVideoFunctionView(Context context) {
        super(context);
        initView();
        initClickListener();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_funcation_view_video, this);
        mLayoutMute = (LinearLayout) findViewById(R.id.ll_mute);
        mImageMute = (ImageView) findViewById(R.id.iv_mute);
        mLayoutHandsFree = (LinearLayout) findViewById(R.id.ll_handsfree);
        mImageHandsFree = (ImageView) findViewById(R.id.iv_handsfree);
        mLayoutOpenCamera = (LinearLayout) findViewById(R.id.ll_open_camera);
        mImageOpenCamera = (ImageView) findViewById(R.id.img_camera);
        mLayoutHangup = (LinearLayout) findViewById(R.id.ll_hangup);
        mImageSwitchCamera = (ImageView) findViewById(R.id.switch_camera);
    }

    private void initClickListener() {
        mLayoutMute.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsMicMute) {
                    mCallingAction.openMicrophone(new TUICommonDefine.Callback() {
                        @Override
                        public void onSuccess() {

                        }

                        @Override
                        public void onError(int errCode, String errMsg) {

                        }
                    });
                } else {
                    mCallingAction.closeMicrophone();
                }
                ToastUtil.toastShortMessage(mContext.getString(mIsMicMute ? R.string.tuicalling_toast_enable_mute :
                        R.string.tuicalling_toast_disable_mute));
            }
        });
        mLayoutHandsFree.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                TUICommonDefine.AudioPlaybackDevice device = TUICommonDefine.AudioPlaybackDevice.Speakerphone;
                if (mIsHandsFree) {
                    device = TUICommonDefine.AudioPlaybackDevice.Earpiece;
                }
                mCallingAction.selectAudioPlaybackDevice(device);
                ToastUtil.toastShortMessage(mContext.getString(!mIsHandsFree ? R.string.tuicalling_toast_speaker :
                        R.string.tuicalling_toast_use_handset));
            }
        });
        mLayoutOpenCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsCameraOpen) {
                    mCallingAction.closeCamera();
                    if (null != mLocalUserLayout) {
                        mLocalUserLayout.setVideoAvailable(false);
                        ImageLoader.loadImage(mContext, mLocalUserLayout.getAvatarImage(), TUILogin.getFaceUrl(),
                                R.drawable.tuicalling_ic_avatar);
                    }
                } else {
                    if (null != mLocalUserLayout) {
                        mCallingAction.openCamera(mCamera, mLocalUserLayout.getVideoView(), null);
                        mLocalUserLayout.setVideoAvailable(true);
                        ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_toast_enable_camera));
                    }
                }
            }
        });

        mImageSwitchCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallingAction.switchCamera(TUICommonDefine.Camera.Front.equals(mCamera)
                        ? TUICommonDefine.Camera.Back : TUICommonDefine.Camera.Front);
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_toast_switch_camera));
            }
        });

        mLayoutHangup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallingAction.hangup(null);
            }
        });
    }

    @Override
    public void updateCameraOpenStatus(boolean isOpen) {
        super.updateCameraOpenStatus(isOpen);
        mImageOpenCamera.setActivated(isOpen);
        if (null != mLocalUserLayout) {
            mLocalUserLayout.setVideoAvailable(isOpen);
        }
    }

    @Override
    public void updateMicMuteStatus(boolean isMicMute) {
        super.updateMicMuteStatus(isMicMute);
        mImageMute.setActivated(mIsMicMute);
    }

    @Override
    public void updateHandsFreeStatus(boolean isHandsFree) {
        super.updateHandsFreeStatus(isHandsFree);
        mImageHandsFree.setActivated(mIsHandsFree);
    }
}
