package com.tencent.qcloud.tim.tuikit.live;

import android.content.Context;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.AVCallManager;
import com.tencent.qcloud.tim.tuikit.live.base.Constants;
import com.tencent.qcloud.tim.tuikit.live.base.TUILiveRequestCallback;
import com.tencent.qcloud.tim.tuikit.live.component.floatwindow.FloatWindowLayout;
import com.tencent.qcloud.tim.tuikit.live.helper.TUIKitLiveChatController;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoom;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;
import com.tencent.qcloud.tim.uikit.base.TUIChatControllerListener;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.base.TUIConversationControllerListener;

import java.util.Arrays;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

public class TUIKitLive {

    private static final String TAG = "TUIKit";

    private static Context sAppContext;
    private static long sSdkAppId;
    private static V2TIMUserFullInfo sLoginUserInfo;
    private static boolean sIsAttachedTUIKit = false;

    private static TUIChatControllerListener sTUIChatControllerListener;
    private static TUIConversationControllerListener sTUIConversationControllerListener;

    /**
     * TUIKitLive的初始化函数
     *
     * @param context 应用的上下文，一般为对应应用的ApplicationContext
     */
    public static void init(Context context) {
        sAppContext = context;
        registerListeners();
    }

    private static void registerListeners() {
        sTUIChatControllerListener = new TUIKitLiveChatController();
        sTUIConversationControllerListener = new TUIKitLiveChatController.TUIKitLiveConversationController();
        TUIKitListenerManager.getInstance().addChatListener(sTUIChatControllerListener);
        TUIKitListenerManager.getInstance().addConversationListener(sTUIConversationControllerListener);
    }

    /**
     * 释放一些资源等，一般可以在退出登录时调用
     */
    public static void unInit() {
    }

    /**
     * 获取TUIKitLive保存的上下文Context，该Context会长期持有，所以应该为Application级别的上下文
     *
     * @return
     */
    public static Context getAppContext() {
        return sAppContext;
    }

    public static void login(final int appid, final String userId, final String userSig, final LoginCallback callback) {
        TUILiveLog.d(TAG, "sIsAttachedTUIKit: " + sIsAttachedTUIKit);
        sSdkAppId = appid;
        TRTCLiveRoomDef.TRTCLiveRoomConfig config = new TRTCLiveRoomDef.TRTCLiveRoomConfig();
        config.isAttachTuikit = sIsAttachedTUIKit;
        TRTCLiveRoom.sharedInstance(sAppContext).login(appid, userId, userSig, config, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (callback != null) {
                    callback.onCallback(code, msg);
                }
            }
        });
        refreshLoginUserInfo(null);
        AVCallManager.getInstance().init(appid, userId, userSig);
    }

    public static void refreshLoginUserInfo(final TUILiveRequestCallback callback) {
        String userId = V2TIMManager.getInstance().getLoginUser();
        V2TIMManager.getInstance().getUsersInfo(Arrays.asList(userId), new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null) {
                    return;
                }

                sLoginUserInfo = v2TIMUserFullInfos.get(0);

                if (callback != null) {
                    callback.onSuccess(v2TIMUserFullInfos);
                }
            }
        });
    }

    public static void logout() {
        TUILiveLog.d(TAG, "logout sIsAttachedTUIKit: " + sIsAttachedTUIKit);

        // 如果当前观众页悬浮窗，关闭并退房
        if (FloatWindowLayout.getInstance().mWindowMode == Constants.WINDOW_MODE_FLOAT) {
            FloatWindowLayout.getInstance().closeFloatWindow();
            TRTCLiveRoom.sharedInstance(sAppContext).exitRoom(null);
        }

        TRTCLiveRoom.sharedInstance(sAppContext).logout(new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
            }
        });
        AVCallManager.getInstance().unInit();
    }

    public static V2TIMUserFullInfo getLoginUserInfo() {
        return sLoginUserInfo;
    }

    public static long getSdkAppId() {
        return sSdkAppId;
    }

    public interface LoginCallback {
        void onCallback(int code, String msg);
    }

}
