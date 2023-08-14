package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;


import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.view.component.MoreFunctionView;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.util.HashMap;
import java.util.Map;

public class MoreFunctionViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "MoreFunctionViewModel";

    private Context          mContext;
    private TUIRoomEngine    mRoomEngine;
    private RoomStore        mRoomStore;
    private MoreFunctionView mMoreFunctionView;

    public MoreFunctionViewModel(Context context, MoreFunctionView moreFunctionView) {
        mContext = context;
        mMoreFunctionView = moreFunctionView;
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(mContext);
        mRoomEngine = engineManager.getRoomEngine();
        mRoomStore = engineManager.getRoomStore();
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public View getBeautyView() {
        Map<String, Object> map = new HashMap<>();
        map.put(TUIConstants.TUIBeauty.PARAM_NAME_CONTEXT, mContext);
        // map.put(TUIConstants.TUIBeauty.PARAM_NAME_LICENSE_URL, XMAGIC_LICENSE_URL);
        // map.put(TUIConstants.TUIBeauty.PARAM_NAME_LICENSE_KEY, XMAGIC_LICENSE_KEY);
        TUICore.callService(TUIConstants.TUIBeauty.SERVICE_NAME, TUIConstants.TUIBeauty.METHOD_INIT_XMAGIC, map);

        HashMap<String, Object> beautyParaMap = new HashMap<>();
        beautyParaMap.put("context", mContext);
        beautyParaMap.put("beautyManager", mRoomEngine.getBeautyManager());
        beautyParaMap.put("icon", R.drawable.tuiroomkit_ic_beauty);
        Map<String, Object> beautyRetMap = TUICore
                .getExtensionInfo("com.tencent.qcloud.tuikit.tuibeauty.view.TUIBeautyButton",
                        beautyParaMap);
        if (beautyRetMap != null && beautyRetMap.size() > 0) {
            Object beautyVIew = beautyRetMap.get("TUIBeauty");
            if (beautyVIew instanceof View) {
                Log.i(TAG, "TUIBeauty TUIExtensionView getExtensionInfo success");
                enableBeautyProcess();
                return (View) beautyVIew;
            } else {
                Log.e(TAG, "TUIBeauty TUIExtensionView getExtensionInfo not find");
                return null;
            }
        } else {
            Log.e(TAG, "TUIBeauty getExtensionInfo null");
            return null;
        }
    }

    private void enableBeautyProcess() {
        mRoomEngine.getTRTCCloud().setLocalVideoProcessListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D,
                TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, new TRTCCloudListener.TRTCVideoFrameListener() {
                    @Override
                    public void onGLContextCreated() {

                    }

                    @Override
                    public int onProcessVideoFrame(TRTCCloudDef.TRTCVideoFrame trtcVideoFrame,
                                                   TRTCCloudDef.TRTCVideoFrame trtcVideoFrame1) {
                        Map<String, Object> map = new HashMap<>();
                        map.put(TUIConstants.TUIBeauty.PARAM_NAME_SRC_TEXTURE_ID, trtcVideoFrame.texture.textureId);
                        map.put(TUIConstants.TUIBeauty.PARAM_NAME_FRAME_WIDTH, trtcVideoFrame.width);
                        map.put(TUIConstants.TUIBeauty.PARAM_NAME_FRAME_HEIGHT, trtcVideoFrame.height);
                        if (TUICore.callService(TUIConstants.TUIBeauty.SERVICE_NAME,
                                TUIConstants.TUIBeauty.METHOD_PROCESS_VIDEO_FRAME, map) != null) {
                            trtcVideoFrame1.texture.textureId = (int) TUICore
                                    .callService(TUIConstants.TUIBeauty.SERVICE_NAME,
                                            TUIConstants.TUIBeauty.METHOD_PROCESS_VIDEO_FRAME, map);
                        } else {
                            trtcVideoFrame1.texture.textureId = trtcVideoFrame.texture.textureId;
                        }
                        return 0;
                    }

                    @Override
                    public void onGLContextDestory() {
                        TUICore.callService(TUIConstants.TUIBeauty.SERVICE_NAME,
                                TUIConstants.TUIBeauty.METHOD_DESTROY_XMAGIC, null);
                    }
                });
    }

    public void showChatView() {
        Log.d(TAG, "showChatView");
        Intent intent = new Intent();
        intent.setClassName(mContext, "com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIGroupChatActivity");
        intent.putExtra(TUIConstants.TUIChat.CHAT_TYPE, V2TIMConversation.V2TIM_GROUP);
        intent.putExtra(TUIConstants.TUIChat.CHAT_ID, mRoomStore.roomInfo.roomId);
        intent.putExtra(TUIConstants.TUIChat.CHAT_NAME, mContext.getString(R.string.tuiroomkit_item_chat));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        Map<String, Object> params = new HashMap<>();
        params.put(TUIConstants.TUIChat.ENABLE_AUDIO_CALL, false);
        params.put(TUIConstants.TUIChat.ENABLE_VIDEO_CALL, false);
        params.put(TUIConstants.TUIChat.ENABLE_LINK, false);
        TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_SET_CHAT_EXTENSION, params);
        IntentUtils.safeStartActivity(mContext, intent);
    }

    public void showSettingView(DialogFragment dialogFragment, String tag) {
        if (dialogFragment != null) {
            if (dialogFragment.isVisible()) {
                try {
                    dialogFragment.dismissAllowingStateLoss();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            } else {
                if (!dialogFragment.isAdded() && mContext instanceof AppCompatActivity) {
                    dialogFragment.show(((AppCompatActivity) mContext).getSupportFragmentManager(), tag);
                }
            }

        }
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED.equals(event)) {
            clearHistoryMessage();
            Map<String, Object> serviceParams = new HashMap<>();
            serviceParams.put(TUIConstants.TUIChat.CHAT_ID, mRoomStore.roomInfo.roomId);
            serviceParams.put(TUIConstants.TUIChat.IS_GROUP_CHAT, true);
            TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME,
                    TUIConstants.TUIChat.METHOD_EXIT_CHAT, serviceParams);
        }
    }

    private void clearHistoryMessage() {
        V2TIMManager.getMessageManager().clearGroupHistoryMessage(mRoomStore.roomInfo.roomId, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "IM clearGroupHistoryMessage success");
            }

            @Override
            public void onError(int code, String desc) {
                Log.i(TAG, "IM clearGroupHistoryMessage error,code:" + code + ",desc:" + desc);
            }
        });
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case RoomEventCenter.RoomKitUIEvent.EXIT_MEETING:
                clearHistoryMessage();
                break;
            case RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE:
                if (params == null || !mMoreFunctionView.isShowing()) {
                    break;
                }
                Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
                mMoreFunctionView.changeConfiguration(configuration);
                break;
            default:
                break;
        }
    }
}
