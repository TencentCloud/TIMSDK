package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.ui.R;

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
        mLayoutHangup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallingAction.hangup(null);
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
                ToastUtil.toastShortMessage(mContext.getString(mIsHandsFree ? R.string.tuicalling_toast_speaker :
                        R.string.tuicalling_toast_use_handset));
            }
        });
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
