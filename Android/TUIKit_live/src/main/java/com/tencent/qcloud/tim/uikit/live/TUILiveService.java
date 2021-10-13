package com.tencent.qcloud.tim.uikit.live;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.live.base.Constants;
import com.tencent.qcloud.tim.uikit.live.base.LiveMessageInfo;
import com.tencent.qcloud.tim.uikit.live.base.TUILiveRequestCallback;
import com.tencent.qcloud.tim.uikit.live.component.floatwindow.FloatWindowLayout;
import com.tencent.qcloud.tim.uikit.live.livemsg.LiveGroupMessageClickListener;
import com.tencent.qcloud.tim.uikit.live.livemsg.TUILiveOnClickListenerManager;
import com.tencent.qcloud.tim.uikit.live.modules.liveroom.model.TRTCLiveRoom;
import com.tencent.qcloud.tim.uikit.live.modules.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.qcloud.tim.uikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.uikit.live.utils.TUILiveLog;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.util.ThreadHelper;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;


public class TUILiveService extends ServiceInitializer implements ITUILiveService {

    private static final String TAG = "TUILive";

    private static Context sAppContext;
    private static long sSdkAppId;
    private static V2TIMUserFullInfo sLoginUserInfo;
    private static boolean sIsAttachedTUIKit = false;

    // enableGroupLiveEntry	true：开启；false：关闭	默认：true
    private boolean enableGroupLiveEntry = true;

    @Override
    public void init(Context context) {
        sAppContext = context;
        TUICore.registerService(TUIConstants.TUILive.SERVICE_NAME, this);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_LIVE, this);
        TUICore.registerEvent(TUIConstants.TUIChat.EVENT_KEY_INPUT_MORE, TUIConstants.TUIChat.EVENT_SUB_KEY_ON_CLICK, this);

        initIMSDKListener();
    }

    private void initIMSDKListener() {
        V2TIMManager.getInstance().addIMSDKListener(new V2TIMSDKListener() {
            @Override
            public void onKickedOffline() {
                ThreadHelper.INST.execute(TUILiveService::logout);
            }

            @Override
            public void onUserSigExpired() {
                ThreadHelper.INST.execute(TUILiveService::logout);
            }
        });
    }

    /**
     * 释放一些资源等，一般可以在退出登录时调用
     */
    public static void unInit() {}

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
        Handler handler = new Handler(Looper.getMainLooper());
        CountDownLatch latch = new CountDownLatch(1);
        handler.post(() -> {
            // 如果当前观众页悬浮窗，关闭并退房
            if (FloatWindowLayout.getInstance().mWindowMode == Constants.WINDOW_MODE_FLOAT) {
                FloatWindowLayout.getInstance().closeFloatWindow();
            }
            latch.countDown();
        });

        try {
            latch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        TRTCLiveRoom.sharedInstance(sAppContext).logout(new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
            }
        });
    }

    public static V2TIMUserFullInfo getLoginUserInfo() {
        return sLoginUserInfo;
    }

    public static long getSdkAppId() {
        return sSdkAppId;
    }

    @Override
    public Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param) {
        if (!enableGroupLiveEntry) {
            return null;
        }
        if (param == null || ((int) param.get(TUIConstants.TUIChat.CHAT_TYPE)) == V2TIMConversation.V2TIM_C2C) {
            return null;
        }
        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put(TUIConstants.TUIChat.INPUT_MORE_ICON, R.drawable.ic_more_group_live);
        hashMap.put(TUIConstants.TUIChat.INPUT_MORE_TITLE, R.string.live_group_live);
        hashMap.put(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, TUIConstants.TUILive.ACTION_ID_LIVE);
        return hashMap;
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        if (TextUtils.equals(method, TUIConstants.TUILive.METHOD_LOGIN)) {
            int sdkAppId = (int) param.get(TUIConstants.TUILive.SDK_APP_ID);
            String userId = (String) param.get(TUIConstants.TUILive.USER_ID);
            String userSig = (String) param.get(TUIConstants.TUILive.USER_SIG);
            login(sdkAppId, userId, userSig, null);
        } else if (TextUtils.equals(method, TUIConstants.TUILive.METHOD_LOGOUT)) {
            logout();
        } else if (TextUtils.equals(method, TUIConstants.TUILive.METHOD_START_ANCHOR)) {
            startAnchor(param);
        } else if (TextUtils.equals(method, TUIConstants.TUILive.METHOD_START_AUDIENCE)) {
            startAudience(param);
        } else {
            TUILiveLog.e(TAG, "unknown method");
        }
        return null;
    }

    private void startAudience(Map<String, Object> map) {
        LiveMessageInfo info = new LiveMessageInfo();
        info.anchorId = (String) getOrDefault(map.get(TUIConstants.TUILive.ANCHOR_ID), "");
        info.anchorName = (String) map.get(TUIConstants.TUILive.ANCHOR_NAME);
        info.roomId = (int) getOrDefault(map.get(TUIConstants.TUILive.ROOM_ID), 0);
        info.roomCover = (String) map.get(TUIConstants.TUILive.ROOM_COVER);
        info.roomName = (String) map.get(TUIConstants.TUILive.ROOM_NAME);
        String groupId = (String) getOrDefault(map.get(TUIConstants.TUILive.GROUP_ID), "");
        LiveGroupMessageClickListener listener = TUILiveOnClickListenerManager.getLiveGroupMessageClickListener();
        if (listener != null) {
            boolean isHandleByUser = listener.handleLiveMessage(info, groupId);
            if (isHandleByUser) {
                return;
            }
        } else {
            return;
        }
        Intent intent = new Intent();
        intent.setAction("com.tencent.qcloud.tim.tuikit.live.grouplive.audience");
        intent.addCategory("android.intent.category.DEFAULT");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUILive.ANCHOR_ID, info.anchorId);
        bundle.putString(TUIConstants.TUILive.ANCHOR_NAME, info.anchorName);
        bundle.putInt(TUIConstants.TUILive.ROOM_ID, info.roomId);
        bundle.putString(TUIConstants.TUILive.ROOM_COVER, info.roomCover);
        bundle.putString(TUIConstants.TUILive.ROOM_NAME, info.roomName);
        bundle.putString(TUIConstants.TUILive.GROUP_ID, groupId);
        intent.putExtras(bundle);
        getAppContext().startActivity(intent);
    }

    private void startAnchor(Map<String, Object> bundle) {
        String groupId = (String) bundle.get(TUIConstants.TUIChat.CHAT_ID);
        if (TextUtils.isEmpty(groupId)) {
            return;
        }

        TUILiveOnClickListenerManager.GroupLiveHandler groupLiveHandler = TUILiveOnClickListenerManager.getGroupLiveHandler();
        if (groupLiveHandler != null) {
            if (groupLiveHandler.startGroupLive(groupId)) {
                return;
            }
        }
        Intent intent = new Intent();
        intent.setAction("com.tencent.qcloud.tim.tuikit.live.grouplive.anchor");
        intent.addCategory("android.intent.category.DEFAULT");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(TUIConstants.TUILive.GROUP_ID, groupId);
        getAppContext().startActivity(intent);
    }

    @Override
    public void onNotifyEvent(String key, String subKey,  Map<String, Object> param) {
        if (param == null) {
            return;
        }
        int actionId = (int) getOrDefault(param.get(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID), -1);
        if (actionId != TUIConstants.TUILive.ACTION_ID_LIVE) {
            return;
        }
        startAnchor(param);
    }

    private Object getOrDefault(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }

    public interface LoginCallback {
        void onCallback(int code, String msg);
    }

}
