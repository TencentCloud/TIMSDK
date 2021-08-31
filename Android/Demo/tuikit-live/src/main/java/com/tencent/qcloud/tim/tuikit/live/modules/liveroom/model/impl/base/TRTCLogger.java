package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;

import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDelegate;

import java.lang.ref.WeakReference;

public class TRTCLogger {
    private static WeakReference<TRTCLiveRoomDelegate> sDelegate;

    public static void setDelegate(TRTCLiveRoomDelegate delegate) {
        if (delegate != null) {
            sDelegate = new WeakReference<>(delegate);
        } else {
            sDelegate = null;
        }
    }

    public static void e(String tag, String message) {
        TXCLog.e(tag, message);
        callback("e", tag, message);
    }

    public static void w(String tag, String message) {
        TXCLog.w(tag, message);
        callback("w", tag, message);
    }

    public static void i(String tag, String message) {
        TXCLog.i(tag, message);
        callback("i", tag, message);
    }

    public static void d(String tag, String message) {
        TXCLog.d(tag, message);
        callback("d", tag, message);
    }

    private static void callback(String level, String tag, String message) {
        WeakReference<TRTCLiveRoomDelegate> wefDelegate = sDelegate;
        if (wefDelegate != null) {
            TRTCLiveRoomDelegate delegate = wefDelegate.get();
            if (delegate != null) {
                delegate.onDebugLog("[" + level + "][" + tag + " ] " + message);
            }
        }
    }
}
