package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.LocalAudioIndicator.LocalAudioToggleViewAction;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.LocalAudioIndicator.LocalAudioToggleViewResponder;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.Map;

public class LocalAudioToggleViewModel implements LocalAudioToggleViewAction, RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "LocalAudioToggleVM";

    private LocalAudioToggleViewResponder mViewResponder;

    public LocalAudioToggleViewModel(LocalAudioToggleViewResponder viewResponder) {
        mViewResponder = viewResponder;
        updateLocalAudioState();
        subscribeEvent();
    }

    @Override
    public void destroy() {
        unSubscribeEvent();
    }

    @Override
    public void enableLocalAudio() {
        if (!isAllowToOperateAudio()) {
            return;
        }
        if (RoomEngineManager.sharedInstance().getRoomStore().audioModel.isMicOpen()) {
            RoomEngineManager.sharedInstance().unMuteLocalAudio(null);
        } else {
            RoomEngineManager.sharedInstance().openLocalMicrophone(null);
        }
    }

    @Override
    public void disableLocalAudio() {
        if (!isAllowToOperateAudio()) {
            return;
        }
        if (RoomEngineManager.sharedInstance().getRoomStore().audioModel.isMicOpen()) {
            RoomEngineManager.sharedInstance().muteLocalAudio();
        }
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case LOCAL_AUDIO_STATE_CHANGED:
                updateLocalAudioState();
                break;

            case USER_VOICE_VOLUME_CHANGED:
                handleLocalAudioVolumeChanged(params);
                break;

            default:
                Log.w(TAG, "un handle event : " + event);
                break;
        }
    }

    private void updateLocalAudioState() {
        if (RoomEngineManager.sharedInstance().getRoomStore().audioModel.isHasAudioStream()) {
            mViewResponder.onLocalAudioEnabled();
        } else {
            mViewResponder.onLocalAudioDisabled();
        }
    }

    private void handleLocalAudioVolumeChanged(Map<String, Object> params) {
        if (!RoomEngineManager.sharedInstance().getRoomStore().audioModel.isHasAudioStream()) {
            return;
        }
        if (params == null) {
            return;
        }
        Map<String, Integer> map = (Map<String, Integer>) params.get(RoomEventConstant.KEY_VOLUME_MAP);
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (!TextUtils.equals(entry.getKey(), TUILogin.getUserId())) {
                continue;
            }
            int volume = entry.getValue();
            mViewResponder.onLocalAudioVolumedChanged(volume);
            break;
        }
    }

    private void subscribeEvent() {
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        RoomEventCenter.getInstance().subscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
    }

    private void unSubscribeEvent() {
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        RoomEventCenter.getInstance().unsubscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
    }

    private boolean isAllowToOperateAudio() {
        RoomStore store = RoomEngineManager.sharedInstance().getRoomStore();
        Context context = TUILogin.getAppContext();
        if (TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT == store.roomInfo.speechMode
                && !store.userModel.isOnSeat()) {
            ToastUtil.toastShortMessageCenter(context.getString(R.string.tuiroomkit_please_raise_hand));
            return false;
        }
        if (store.roomInfo.isMicrophoneDisableForAllUser && store.userModel.role != TUIRoomDefine.Role.ROOM_OWNER) {
            ToastUtil.toastShortMessageCenter(context.getString(R.string.tuiroomkit_can_not_open_mic));
            return false;
        }
        return true;
    }
}
