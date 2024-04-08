package com.tencent.cloud.tuikit.roomkit;

import android.util.Log;

public class ConferenceObserver {
    private static final String TAG = "ConferenceObserver";

    public void onConferenceStarted(String conferenceId, ConferenceError error) {
        Log.i(TAG, "onConferenceStarted conferenceId=" + conferenceId + " error=" + error);
    }

    public void onConferenceJoined(String conferenceId, ConferenceError error) {
        Log.i(TAG, "onConferenceJoined conferenceId=" + conferenceId + " error=" + error);
    }

    public void onConferenceExisted(String conferenceId) {
        Log.i(TAG, "onConferenceExisted conferenceId=" + conferenceId);
    }

    public void onConferenceFinished(String conferenceId) {
        Log.i(TAG, "onConferenceFinished conferenceId=" + conferenceId);
    }
}
