package com.tencent.liteav.trtccalling.model.impl;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.TUICalling;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.HashMap;
import java.util.Map;

/**
 * TUICore来调用（如果未引入TUICore模块，请使用TUICallingManager）
 */
final class TUICallingService implements ITUIService, ITUIExtension, TUICallingManager.CallingManagerListener {

    private static final String TAG = "TUICallingService";

    private static final TUICallingService INSTANCE = new TUICallingService();

    private final TUICallingManager mCallingManager = TUICallingManager.sharedInstance();

    static final TUICallingService sharedInstance() {
        return INSTANCE;
    }

    private Context appContext;

    private TUICallingService() {

    }

    public void init(Context context) {
        appContext = context;
        mCallingManager.setCallingManagerListener(this);
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, this);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL, this);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        Log.d(TAG, String.format("onCall, method=%s, param=%s", method, null == param ? "" : param.toString()));
        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_CALL, method)) {
            String[] userIDs = (String[]) param.get(TUIConstants.TUICalling.PARAM_NAME_USERIDS);
            String typeString = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_TYPE);
            String groupID = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_GROUPID);
            if (TUIConstants.TUICalling.TYPE_AUDIO.equals(typeString)) {
                mCallingManager.internalCall(userIDs, groupID, TUICalling.Type.AUDIO, TUICalling.Role.CALL);
            } else if (TUIConstants.TUICalling.TYPE_VIDEO.equals(typeString)) {
                mCallingManager.internalCall(userIDs, groupID, TUICalling.Type.VIDEO, TUICalling.Role.CALL);
            }
        } else if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_START_CALL, method)) {
            if (!param.containsKey(TUIConstants.TUICalling.SENDER) || !param.containsKey(TUIConstants.TUICalling.PARAM_NAME_CALLMODEL)) {
                return null;
            }
            String sender = (String) param.get(TUIConstants.TUICalling.SENDER);
            String content = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_CALLMODEL);
            if (TextUtils.isEmpty(sender) || TextUtils.isEmpty(content)) {
                return null;
            }
            mCallingManager.receiveOfflineCalled(sender, content);
        }
        return null;
    }

    @Override
    public Map<String, Object> onGetExtensionInfo(final String key, Map<String, Object> param) {
        Log.d(TAG, String.format("onGetExtensionInfo, key=%s, param=%s", key, null == param ? "" : param.toString()));
        Context inflateContext = (Context) param.get(TUIConstants.TUIChat.CONTEXT);
        if (inflateContext == null) {
            inflateContext = appContext;
        }
        if (inflateContext == null) {
            return null;
        }
        HashMap<String, Object> extensionMap = new HashMap<>();
        View unitView = LayoutInflater.from(inflateContext).inflate(R.layout.chat_input_more_actoin, null);
        int actionId = 0;
        if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL)) {
            ((ImageView) unitView.findViewById(R.id.imageView)).setImageResource(R.drawable.trtccalling_ic_audio_call);
            ((TextView) unitView.findViewById(R.id.textView)).setText(inflateContext.getString(R.string.trtccalling_audio_call));
            actionId = TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL;
        } else if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL)) {
            ((ImageView) unitView.findViewById(R.id.imageView)).setImageResource(R.drawable.trtccalling_ic_video_call);
            ((TextView) unitView.findViewById(R.id.textView)).setText(inflateContext.getString(R.string.trtccalling_video_call));
            actionId = TUIConstants.TUICalling.ACTION_ID_VIDEO_CALL;
        }
        final String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
        int chatType = (int) param.get(TUIConstants.TUIChat.CHAT_TYPE);
        if (chatType == V2TIMConversation.V2TIM_GROUP) {
            unitView.setClickable(false);
        } else {
            unitView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL)) {
                        mCallingManager.internalCall(new String[]{chatId}, null, TUICalling.Type.AUDIO, TUICalling.Role.CALL);
                    } else if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL)) {
                        mCallingManager.internalCall(new String[]{chatId}, null, TUICalling.Type.VIDEO, TUICalling.Role.CALL);
                    }
                }
            });
        }
        extensionMap.put(TUIConstants.TUIChat.INPUT_MORE_VIEW, unitView);
        extensionMap.put(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, actionId);
        return extensionMap;
    }

    @Override
    public void onEvent(String key, Bundle bundle) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUICalling.EVENT_KEY_NAME, key);
        TUICore.notifyEvent(TUIConstants.TUICalling.EVENT_KEY_CALLING, TUIConstants.TUICalling.EVENT_KEY_CALLING, param);
    }
}
