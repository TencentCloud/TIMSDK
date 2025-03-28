package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.presenter;

import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

public class RoomTaskStoreHouse {
    private static final String TAG = "RoomTaskStoreHouse";

    private Handler mWorkHandler;

    public RoomTaskStoreHouse() {
        Log.d(TAG, "new");
        HandlerThread handlerThread = new HandlerThread("RoomTaskStoreHouse-Thread");
        handlerThread.start();
        mWorkHandler = new Handler(handlerThread.getLooper());
    }

    public void postTask(Runnable task) {
        if (mWorkHandler == null) {
            Log.w(TAG, "postTask mWorkHandler is null");
            return;
        }
        mWorkHandler.removeCallbacksAndMessages(null);
        mWorkHandler.post(task);
    }

    public void destroyRoomTaskStoreHouse() {
        Log.d(TAG, "destroyRoomTaskStoreHouse : " + mWorkHandler);
        if (mWorkHandler != null) {
            mWorkHandler.removeCallbacksAndMessages(null);
            mWorkHandler.getLooper().quitSafely();
            mWorkHandler = null;
        }
    }
}
