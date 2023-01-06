package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.base.Constants;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingAction;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;

import java.util.Map;

public abstract class BaseFunctionView extends RelativeLayout {
    protected Context          mContext;
    protected TUICallingAction mCallingAction;
    protected UserLayout       mLocalUserLayout;

    public BaseFunctionView(Context context) {
        super(context);
        mContext = context.getApplicationContext();
        mCallingAction = new TUICallingAction(context);
        registerEvent();
    }

    private void registerEvent() {
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CAMERA_OPEN, mNotification);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_MIC_STATUS_CHANGED,
                mNotification);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_AUDIOPLAYDEVICE_CHANGED,
                mNotification);
    }

    private final ITUINotification mNotification = new ITUINotification() {
        @Override
        public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
            if (Constants.EVENT_TUICALLING_CHANGED.equals(key) && param != null) {
                switch (subKey) {
                    case Constants.EVENT_SUB_CAMERA_OPEN:
                        updateCameraOpenStatus((boolean) param.get(Constants.OPEN_CAMERA));
                        break;
                    case Constants.EVENT_SUB_MIC_STATUS_CHANGED:
                        updateMicMuteStatus((Boolean) param.get(Constants.MUTE_MIC));
                        break;
                    case Constants.EVENT_SUB_AUDIOPLAYDEVICE_CHANGED:
                        TUICommonDefine.AudioPlaybackDevice device =
                                (TUICommonDefine.AudioPlaybackDevice) param.get(Constants.HANDS_FREE);
                        updateAudioPlayDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone.equals(device));
                        break;
                    default:
                        break;
                }
            }
        }
    };

    public void updateCameraOpenStatus(boolean isOpen) {
    }

    public void updateMicMuteStatus(boolean isMicMute) {
    }

    public void updateAudioPlayDevice(boolean isSpeaker) {
    }

    public void updateTextColor(int color) {
    }

    public void setLocalUserLayout(UserLayout layout) {
        mLocalUserLayout = layout;
    }
}
