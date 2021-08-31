package com.tencent.qcloud.tim.demo.scenes.net;

import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;

public class HeartbeatManager implements Runnable {

    private static final String TAG = "HeartbeatManager";
    private static final String HEARTBEAT_THREAD_NAME = "heartbeat_thread";

    // 心跳上报时间间隔
    private static final long HEARTBEAT_INTERVAL = 10 * 1000;

    private String mType = null;
    private int mRoomId;

    private HandlerThread mHandlerThread = null;
    private Handler mHeartbeatHandler = null;

    private static class SingletonHolder {
        static HeartbeatManager sInstance = new HeartbeatManager();
    }

    public static HeartbeatManager getInstance() {
        return SingletonHolder.sInstance;
    }

    private HeartbeatManager() {
    }

    public void start(@NonNull String type, int roomId) {
        Log.i(TAG, "start heartbeat: appId -> " + TUIKitLive.getSdkAppId() + ", type -> " + type + ", roomId -> " + roomId);
        mType = type;
        mRoomId = roomId;
        mHandlerThread = new HandlerThread(HEARTBEAT_THREAD_NAME);
        mHeartbeatHandler = new Handler();
        mHandlerThread.start();
        postHeartbeat();
        sendHeartbeatMessage();
    }

    public void stop() {
        Log.i(TAG, "stop heartbeat: appId -> " + TUIKitLive.getSdkAppId() + ", type -> " + mType + ", roomId -> " + mRoomId);
        if (mHeartbeatHandler != null) {
            mHeartbeatHandler.removeCallbacks(this);
        }
        mHeartbeatHandler = null;
        if (mHandlerThread != null) {
            mHandlerThread.quit();
        }
        mHandlerThread = null;
    }

    @Override
    public void run() {
        postHeartbeat();
        sendHeartbeatMessage();
    }

    private void sendHeartbeatMessage() {
        mHeartbeatHandler.postDelayed(this, HEARTBEAT_INTERVAL);
    }

    private void postHeartbeat() {
        RoomManager.getInstance().updateRoom(mRoomId, mType, null);
    }
}
