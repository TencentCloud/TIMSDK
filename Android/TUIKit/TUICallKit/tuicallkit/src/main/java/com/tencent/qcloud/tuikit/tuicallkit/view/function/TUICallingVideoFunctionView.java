package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;

public class TUICallingVideoFunctionView extends BaseFunctionView {
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
                boolean isMicMute = TUICallingStatusManager.sharedInstance(mContext).isMicMute();
                if (isMicMute) {
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
                int resId = isMicMute ? R.string.tuicalling_toast_disable_mute : R.string.tuicalling_toast_enable_mute;
                ToastUtil.toastShortMessage(mContext.getString(resId));
            }
        });
        mLayoutHandsFree.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean isSpeaker = TUICommonDefine.AudioPlaybackDevice.Speakerphone
                        .equals(TUICallingStatusManager.sharedInstance(mContext).getAudioPlaybackDevice());
                if (isSpeaker) {
                    mCallingAction.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece);
                } else {
                    mCallingAction.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone);
                }
                int resId = isSpeaker ? R.string.tuicalling_toast_use_handset : R.string.tuicalling_toast_speaker;
                ToastUtil.toastShortMessage(mContext.getString(resId));
            }
        });
        mLayoutOpenCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (TUICallingStatusManager.sharedInstance(mContext).isCameraOpen()) {
                    mCallingAction.closeCamera();
                    ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_toast_disable_camera));
                } else {
                    if (null != mLocalUserLayout) {
                        mCallingAction.openCamera(TUICallingStatusManager.sharedInstance(mContext).getFrontCamera(),
                                mLocalUserLayout.getVideoView(), null);
                        ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_toast_enable_camera));
                    }
                }
            }
        });

        mImageSwitchCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                TUICommonDefine.Camera camera = TUICallingStatusManager.sharedInstance(mContext).getFrontCamera();
                mCallingAction.switchCamera(TUICommonDefine.Camera.Front.equals(camera)
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
    }

    @Override
    public void updateMicMuteStatus(boolean isMicMute) {
        super.updateMicMuteStatus(isMicMute);
        mImageMute.setActivated(isMicMute);
    }

    @Override
    public void updateAudioPlayDevice(boolean isSpeaker) {
        super.updateAudioPlayDevice(isSpeaker);
        mImageHandsFree.setActivated(isSpeaker);
    }
}
