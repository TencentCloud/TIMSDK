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

public class TUICallingAudioFunctionView extends BaseFunctionView {
    private LinearLayout mLayoutMute;
    private LinearLayout mLayoutHangup;
    private LinearLayout mLayoutHandsFree;
    private ImageView    mImageMute;
    private ImageView    mImageHandsFree;

    public TUICallingAudioFunctionView(Context context) {
        super(context);
        initView();
        initListener();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_funcation_view_audio, this);
        mLayoutMute = findViewById(R.id.ll_mute);
        mImageMute = findViewById(R.id.img_mute);
        mLayoutHangup = findViewById(R.id.ll_hangup);
        mLayoutHandsFree = findViewById(R.id.ll_handsfree);
        mImageHandsFree = findViewById(R.id.img_handsfree);
    }

    private void initListener() {
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
        mLayoutHangup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallingAction.hangup(null);
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
