package com.tencent.cloud.tuikit.roomkit.manager.observer;

import static com.tencent.cloud.tuikit.roomkit.state.ASRState.ASR_TYPE_TRANSCRIPTION;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.state.ASRState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.TRTCStatistics;
import com.trtc.tuikit.common.livedata.LiveListData;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class TRTCObserver extends TRTCCloudListener {
    private static final String TAG = "TRTCObserver";

    @Override
    public void onRecvCustomCmdMsg(String userId, int cmdID, int seq, byte[] message) {
        if (cmdID != 1 || message == null) {
            return;
        }
        JSONObject data;
        String type;
        try {
            data = new JSONObject(new String(message));
            type = data.getString("type");
        } catch (JSONException e) {
            Log.e(TAG, "onRecvCustomCmdMsg JSONException");
            return;
        }
        if (TextUtils.isEmpty(type)) {
            return;
        }
        ASRState.SpeechToText speechToText;
        if (TextUtils.equals("10000", type)) {
            speechToText = parseNumberTypeData(data);
        } else {
            speechToText = parseStringTypeData(data);
        }
        saveTextData(speechToText);
    }

    private ASRState.SpeechToText parseStringTypeData(JSONObject data) {
        ASRState.SpeechToText speechToText = new ASRState.SpeechToText();
        try {
            speechToText.roundId = data.getString("roundid");
            speechToText.userId = data.getString("userid");
            speechToText.text = data.getString("text");
            speechToText.startTimeMs = data.getLong("start_ms_ts");
            speechToText.endTimeMs = data.getLong("end_ms_ts");
            speechToText.isSpeechEnd = TextUtils.equals(ASR_TYPE_TRANSCRIPTION, data.getString("type"));
        } catch (JSONException e) {
            Log.w(TAG, "parseStringTypeData JSONException");
        }
        return speechToText;
    }

    private ASRState.SpeechToText parseNumberTypeData(JSONObject data) {
        ASRState.SpeechToText speechToText = new ASRState.SpeechToText();
        try {
            speechToText.userId = data.getString("sender");
            speechToText.startTimeMs = data.getLong("start_ms_ts");
            speechToText.endTimeMs = data.getLong("end_ms_ts");
            JSONObject payload = data.getJSONObject("payload");
            speechToText.roundId = payload.getString("roundid");
            speechToText.text = payload.getString("text");
            speechToText.isSpeechEnd = payload.getBoolean("end");
        } catch (JSONException e) {
            Log.w(TAG, "parseNumberTypeData JSONException");
        }
        return speechToText;
    }

    private void saveTextData(ASRState.SpeechToText speechToText) {
        if (speechToText == null || TextUtils.isEmpty(speechToText.roundId)) {
            return;
        }
        UserState.UserInfo userInfo = ConferenceController.sharedInstance().getUserState().allUsers.find(new UserState.UserInfo(speechToText.userId));
        if (userInfo != null && !TextUtils.isEmpty(userInfo.userName)) {
            speechToText.userName = userInfo.userName;
        }
        if (userInfo != null && !TextUtils.isEmpty(userInfo.avatarUrl)) {
            speechToText.avatarUrl = userInfo.avatarUrl;
        }
        LiveListData<ASRState.SpeechToText> speechToTexts = ConferenceController.sharedInstance().getASRState().speechToTexts;
        if (speechToTexts.contains(speechToText)) {
            speechToTexts.change(speechToText);
        } else {
            speechToTexts.add(speechToText);
        }
    }

    @Override
    public void onConnectionLost() {
        Log.d(TAG, "onConnectionLost");
    }

    @Override
    public void onTryToReconnect() {
        Log.d(TAG, "onTryToReconnect");
    }

    @Override
    public void onConnectionRecovery() {
        Log.d(TAG, "onConnectionRecovery");
    }

    @Override
    public void onStatistics(TRTCStatistics statistics) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ON_STATISTICS, statistics);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ON_STATISTICS, map);
    }

}
