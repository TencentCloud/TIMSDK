package com.tencent.cloud.tuikit.roomkit.view.main;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_LINE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.EXIT_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.START_LOGIN;
import static com.tencent.qcloud.tuicore.TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED;
import static com.tencent.qcloud.tuicore.TUIConstants.TUILogin.EVENT_SUB_KEY_START_UNINIT;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.common.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.view.main.floatwindow.videoplaying.RoomFloatViewService;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.Map;

public class RoomWindowManager
        implements ConferenceEventCenter.RoomKitUIEventResponder, ConferenceEventCenter.RoomEngineEventResponder, ITUINotification {
    private static final String TAG = "RoomFloatWindowManager";

    private static Context mAppContext;

    public RoomWindowManager(Context context) {
        mAppContext = context.getApplicationContext();
        registerKitEvent();
    }

    public void destroy() {
        Log.d(TAG, "destroy");
        unRegisterKitEvent();
        dismissFloatWindow();
    }

    private void enterFloatWindow() {
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            Log.d(TAG, "enter float window no float permission");
            return;
        }
        showFloatWindow();
    }

    private void exitFloatWindow() {
        dismissFloatWindow();
        showMainActivity();
    }

    private void registerKitEvent() {
        ConferenceEventCenter.getInstance().subscribeUIEvent(ENTER_FLOAT_WINDOW, this);
        ConferenceEventCenter.getInstance().subscribeUIEvent(EXIT_FLOAT_WINDOW, this);
        ConferenceEventCenter.getInstance().subscribeEngine(ROOM_DISMISSED, this);
        ConferenceEventCenter.getInstance().subscribeEngine(KICKED_OFF_LINE, this);
        ConferenceEventCenter.getInstance().subscribeEngine(KICKED_OUT_OF_ROOM, this);
        TUICore.registerEvent(EVENT_IMSDK_INIT_STATE_CHANGED, EVENT_SUB_KEY_START_UNINIT, this);
    }

    private void unRegisterKitEvent() {
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(ENTER_FLOAT_WINDOW, this);
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(EXIT_FLOAT_WINDOW, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(ROOM_DISMISSED, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(KICKED_OFF_LINE, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(KICKED_OUT_OF_ROOM, this);
        TUICore.unRegisterEvent(EVENT_IMSDK_INIT_STATE_CHANGED, EVENT_SUB_KEY_START_UNINIT, this);
    }

    public void showMainActivity() {
        Class activity = ConferenceController.sharedInstance().getConferenceState().getMainActivityClass();
        if (activity == null) {
            Log.e(TAG, "showMainActivity activity is null");
            return;
        }
        Intent intent = new Intent(mAppContext, activity);
        IntentUtils.safeStartActivity(mAppContext, intent);
    }

    public void showFloatWindow() {
        Log.d(TAG, "show float window");
        Intent intent = new Intent(mAppContext, RoomFloatViewService.class);
        mAppContext.startService(intent);
    }

    public void dismissFloatWindow() {
        Log.d(TAG, "dismiss float window");
        Intent intent = new Intent(mAppContext, RoomFloatViewService.class);
        mAppContext.stopService(intent);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        Log.d(TAG, "onNotifyUIEvent key=" + key);
        switch (key) {
            case ENTER_FLOAT_WINDOW:
                enterFloatWindow();
                break;

            case EXIT_FLOAT_WINDOW:
                exitFloatWindow();
                break;

            default:
                Log.e(TAG, "un handle event : " + key);
                break;
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        Log.d(TAG, "onEngineEvent event=" + event);
        switch (event) {
            case KICKED_OUT_OF_ROOM:
            case ROOM_DISMISSED:
                dismissFloatWindow();
                ConferenceController.sharedInstance().release();
                break;
            case KICKED_OFF_LINE:
                dismissFloatWindow();
                startLoginIfNeeded();
                ConferenceController.sharedInstance().release();
                break;
            default:
                Log.w(TAG, "un handle event : " + event);
                break;
        }
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        Log.d(TAG, "onNotifyEvent key=" + key + " subKey=" + subKey);
        if (TextUtils.equals(key, EVENT_IMSDK_INIT_STATE_CHANGED) && TextUtils.equals(subKey,
                EVENT_SUB_KEY_START_UNINIT)) {
            dismissFloatWindow();
            ConferenceController.sharedInstance().release();
        }
    }

    private void startLoginIfNeeded() {
        if (ConferenceController.sharedInstance().getConferenceState().isInFloatWindow()) {
            ConferenceEventCenter.getInstance().notifyUIEvent(START_LOGIN, null);
        }
    }
}
