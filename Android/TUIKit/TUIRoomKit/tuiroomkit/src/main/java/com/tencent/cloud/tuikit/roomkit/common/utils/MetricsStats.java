package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;

import org.json.JSONException;
import org.json.JSONObject;

public class MetricsStats {
    private static final String TAG = "MetricsStats";

    public static final int T_METRICS_WATER_MARK_ENABLE              = 106054;
    public static final int T_METRICS_CHAT_PANEL_SHOW                = 106057;
    public static final int T_METRICS_WATER_MARK_CUSTOM_TEXT         = 106060;
    public static final int T_METRICS_BARRAGE_PANEL_SHOW             = 106061;
    public static final int T_METRICS_BARRAGE_SEND_MESSAGE           = 106062;
    public static final int T_METRICS_FLOAT_WINDOW_SHOW              = 106063;
    public static final int T_METRICS_USER_LIST_PANEL_SHOW           = 106064;
    public static final int T_METRICS_USER_LIST_SEARCH               = 106065;
    public static final int T_METRICS_SETTINGS_PANEL_SHOW            = 106066;
    public static final int T_METRICS_SHARE_ROOM_INFO_PANEL_SHOW     = 106067;
    public static final int T_METRICS_CONFERENCE_SCHEDULE_PANEL_SHOW = 106068;
    public static final int T_METRICS_CONFERENCE_MODIFY_PANEL_SHOW   = 106069;
    public static final int T_METRICS_CONFERENCE_INFO_PANEL_SHOW     = 106070;
    public static final int T_METRICS_CONFERENCE_ATTENDEE            = 106071;

    public static void submit(int eventKey) {
        try {
            JSONObject params = new JSONObject();
            params.put("key", eventKey);
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("api", "KeyMetricsStats");
            jsonObject.put("params", params);
            String json = jsonObject.toString();
            TUIRoomEngine.callExperimentalAPI(json);
            Log.i(TAG, "submit : " + json);
        } catch (JSONException e) {
            Log.e(TAG, "submit JSONException : " + e.getMessage());
        }
    }
}
