package com.tencent.cloud.tuikit.roomkit.manager.observer;

import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;

import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;


import java.util.Map;

public class TUILoginStateObserver implements ITUINotification {
    private static final String TAG = "TUILoginStateObserver";

    private ConferenceState mConferenceState;

    public TUILoginStateObserver(ConferenceState conferenceState) {
        mConferenceState = conferenceState;
    }

    public void registerObserver() {
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
    }

    public void unregisterObserver() {
        TUICore.unRegisterEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        Log.i(TAG, "onNotifyEvent key = " + key + "subKey = " + subKey);
        if (!TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key) || !TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS.equals(subKey)) {
            return;
        }
        mConferenceState.userModel.userId = TUILogin.getUserId();
        UserState.UserInfo userInfo = mConferenceState.userState.selfInfo.get();
        userInfo.userId = TUILogin.getUserId();
        mConferenceState.userState.selfInfo.set(userInfo);
    }
}
