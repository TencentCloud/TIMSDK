package com.tencent.cloud.tuikit.roomkit.view.main.localaudioindicator;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Map;

public class LocalAudioToggleViewModel implements LocalAudioToggleViewAction, ConferenceEventCenter.RoomEngineEventResponder {
    private static final String TAG = "LocalAudioToggleVM";

    private LocalAudioToggleViewResponder mViewResponder;

    private final Observer<Boolean> mSeatEnableStateObserver = this::handleSeatEnableStateChanged;

    public LocalAudioToggleViewModel(LocalAudioToggleViewResponder viewResponder) {
        mViewResponder = viewResponder;
        updateLocalAudioState();
        updateLocalAudioVisibility();
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
        if (ConferenceController.sharedInstance().getConferenceState().audioModel.isMicOpen()) {
            ConferenceController.sharedInstance().unMuteLocalAudio(null);
        } else {
            ConferenceController.sharedInstance().openLocalMicrophone(null);
        }
    }

    @Override
    public void disableLocalAudio() {
        if (!isAllowToOperateAudio()) {
            return;
        }
        if (ConferenceController.sharedInstance().getConferenceState().audioModel.isMicOpen()) {
            ConferenceController.sharedInstance().muteLocalAudio();
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case LOCAL_AUDIO_STATE_CHANGED:
                updateLocalAudioState();
                break;

            case USER_VOICE_VOLUME_CHANGED:
                handleLocalAudioVolumeChanged(params);
                break;

            case USER_ROLE_CHANGED:
            case REMOTE_USER_TAKE_SEAT:
            case REMOTE_USER_LEAVE_SEAT:
                handleLocalAudioVisibility(params);
                break;

            default:
                Log.w(TAG, "un handle event : " + event);
                break;
        }
    }

    private void updateLocalAudioState() {
        if (ConferenceController.sharedInstance().getConferenceState().audioModel.isHasAudioStream()) {
            mViewResponder.onLocalAudioEnabled();
        } else {
            mViewResponder.onLocalAudioDisabled();
        }
    }

    private void handleLocalAudioVolumeChanged(Map<String, Object> params) {
        if (!ConferenceController.sharedInstance().getConferenceState().audioModel.isHasAudioStream()) {
            return;
        }
        if (params == null) {
            return;
        }
        Map<String, Integer> map = (Map<String, Integer>) params.get(ConferenceEventConstant.KEY_VOLUME_MAP);
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (!TextUtils.equals(entry.getKey(), TUILogin.getUserId())) {
                continue;
            }
            int volume = entry.getValue();
            mViewResponder.onLocalAudioVolumedChanged(volume);
            break;
        }
    }

    private void handleLocalAudioVisibility(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        ConferenceState store = ConferenceController.sharedInstance().getConferenceState();
        UserEntity user = store.allUserList.get(position);
        if (!TextUtils.equals(user.getUserId(), store.userModel.userId)) {
            return;
        }
        updateLocalAudioVisibility();
    }

    private void updateLocalAudioVisibility() {
        ConferenceState store = ConferenceController.sharedInstance().getConferenceState();
        if (!store.roomInfo.isSeatEnabled) {
            return;
        }
        boolean visible = store.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER || store.userModel.isOnSeat();
        mViewResponder.onLocalAudioVisibilityChanged(visible);
    }

    private void subscribeEvent() {
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        ConferenceEventCenter.getInstance().subscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
        ConferenceEventCenter.getInstance().subscribeEngine(USER_ROLE_CHANGED, this);
        ConferenceEventCenter.getInstance().subscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        ConferenceEventCenter.getInstance().subscribeEngine(REMOTE_USER_LEAVE_SEAT, this);

        ConferenceController.sharedInstance().getRoomState().isSeatEnabled.observe(mSeatEnableStateObserver);
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(USER_ROLE_CHANGED, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(REMOTE_USER_LEAVE_SEAT, this);

        ConferenceController.sharedInstance().getRoomState().isSeatEnabled.removeObserver(mSeatEnableStateObserver);
    }

    private boolean isAllowToOperateAudio() {
        ConferenceState store = ConferenceController.sharedInstance().getConferenceState();
        Context context = TUILogin.getAppContext();
        if (store.roomInfo.isSeatEnabled && !store.userModel.isOnSeat()) {
            RoomToast.toastShortMessageCenter(context.getString(R.string.tuiroomkit_please_raise_hand));
            return false;
        }
        if (store.roomInfo.isMicrophoneDisableForAllUser
                && store.userModel.getRole() != TUIRoomDefine.Role.ROOM_OWNER) {
            RoomToast.toastShortMessageCenter(context.getString(R.string.tuiroomkit_can_not_open_mic));
            return false;
        }
        return true;
    }

    private void handleSeatEnableStateChanged(boolean enable) {
        updateLocalAudioVisibility();
    }
}
