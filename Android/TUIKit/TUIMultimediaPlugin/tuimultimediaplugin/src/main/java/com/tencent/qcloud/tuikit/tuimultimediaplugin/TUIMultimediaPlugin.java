package com.tencent.qcloud.tuikit.tuimultimediaplugin;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import com.google.auto.service.AutoService;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.tuichat.component.album.VideoRecorder;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker.SignatureCheckListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecorder;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency({"TUIChat"})
@TUIInitializerID("TUIMultimediaRecordService")
public class TUIMultimediaPlugin implements TUIInitializer, ITUINotification {
    public static final String TAG = TUIMultimediaPlugin.class.getSimpleName();

    private static final int LOGIN_POLL_INTERVAL_MS = 500;
    private static final int LOGIN_POLL_MAX_TIMES = 20;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private int loginPollCount = 0;

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }

    @Override
    public void init(Context context) {
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(
            TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED,
            TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECT_SUCCESS, this);
        VideoRecorder.registerAdvancedVideoRecorder(new TUIMultimediaRecorder());
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED)) {
            if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS)) {
                updateSignature();
            }
        } else if (TextUtils.equals(key, TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED)) {
            if (TextUtils.equals(subKey, TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECT_SUCCESS)) {
                pollLoginStatusAndUpdateSignature();
            }
        }
    }

    private void pollLoginStatusAndUpdateSignature() {
        loginPollCount = 0;
        handler.removeCallbacksAndMessages(null);
        checkLoginStatusAndUpdate();
    }

    private void checkLoginStatusAndUpdate() {
        int loginStatus = V2TIMManager.getInstance().getLoginStatus();
        if (loginStatus == V2TIMManager.V2TIM_STATUS_LOGINED) {
            Log.i(TAG, "connect success and login completed, updating signature");
            updateSignature();
            return;
        }
        loginPollCount++;
        if (loginPollCount < LOGIN_POLL_MAX_TIMES) {
            Log.d(TAG, "connect success but loginStatus=" + loginStatus
                + ", poll " + loginPollCount + "/" + LOGIN_POLL_MAX_TIMES);
            handler.postDelayed(this::checkLoginStatusAndUpdate, LOGIN_POLL_INTERVAL_MS);
        } else {
            Log.w(TAG, "connect success but login not completed after polling "
                + LOGIN_POLL_MAX_TIMES + " times, skip updateSignature");
        }
    }

    private void updateSignature() {
        TUIMultimediaSignatureChecker.getInstance().startUpdateSignature(() -> {

        });
    }
}
