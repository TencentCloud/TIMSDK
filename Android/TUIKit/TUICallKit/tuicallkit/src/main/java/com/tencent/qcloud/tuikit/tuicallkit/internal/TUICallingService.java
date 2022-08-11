package com.tencent.qcloud.tuikit.tuicallkit.internal;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.utils.TUICallingConstants;
import com.tencent.qcloud.tuikit.tuicallkit.ui.R;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * `TUICore` call (if the `TUICore` module is not imported, use `TUICallingImpl` instead)
 */
final class TUICallingService implements ITUINotification, ITUIService, ITUIExtension {

    private static final String TAG = "TUICallingService";

    private static final TUICallingService INSTANCE = new TUICallingService();

    private TUICallKit mTUICallKit;

    static TUICallingService sharedInstance() {
        return INSTANCE;
    }

    private Context appContext;

    private TUICallingService() {

    }

    public void init(Context context) {
        appContext = context;
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        Log.d(TAG, String.format("onCall, method=%s, param=%s", method, null == param ? "" : param.toString()));
        TUICallingConstants.component = TUICallingConstants.TC_TIMCALLING_COMPONENT;
        if (param != null && param.containsKey("component")) {
            TUICallingConstants.component = (int) param.get("component");
        }
        if (null == mTUICallKit) {
            Log.e(TAG, "mTUICallKit is null!!!");
            return null;
        }

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_FLOAT_WINDOW, method)) {
            boolean enableFloatWindow = (boolean) param.get(TUIConstants.TUICalling.PARAM_NAME_ENABLE_FLOAT_WINDOW);
            Log.i(TAG, "onCall, enableFloatWindow: " + enableFloatWindow);
            mTUICallKit.enableFloatWindow(enableFloatWindow);
            return null;
        }

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_CALL, method)) {
            String[] userIDs = (String[]) param.get(TUIConstants.TUICalling.PARAM_NAME_USERIDS);
            String typeString = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_TYPE);
            String groupID = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_GROUPID);

            List<String> userIdList = new ArrayList<>(Arrays.asList(userIDs));
            if (TUIConstants.TUICalling.TYPE_AUDIO.equals(typeString)) {
                mTUICallKit.groupCall(groupID, userIdList, TUICallDefine.MediaType.Audio);
            } else if (TUIConstants.TUICalling.TYPE_VIDEO.equals(typeString)) {
                mTUICallKit.groupCall(groupID, userIdList, TUICallDefine.MediaType.Video);
            }
        }
        return null;
    }

    @Override
    public Map<String, Object> onGetExtensionInfo(final String key, Map<String, Object> param) {
        Log.d(TAG, String.format("onGetExtensionInfo, key=%s, param=%s", key, null == param ? "" : param.toString()));
        TUICallingConstants.component = TUICallingConstants.TC_TIMCALLING_COMPONENT;
        if (param != null && param.containsKey("component")) {
            TUICallingConstants.component = (int) param.get("component");
        }
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
            ((ImageView) unitView.findViewById(R.id.imageView)).setImageResource(R.drawable.tuicalling_ic_audio_call);
            ((TextView) unitView.findViewById(R.id.textView))
                    .setText(inflateContext.getString(R.string.tuicalling_audio_call));
            actionId = TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL;
        } else if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL)) {
            ((ImageView) unitView.findViewById(R.id.imageView)).setImageResource(R.drawable.tuicalling_ic_video_call);
            ((TextView) unitView.findViewById(R.id.textView))
                    .setText(inflateContext.getString(R.string.tuicalling_video_call));
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
                    if (null == mTUICallKit) {
                        Log.e(TAG, "mTUICallKit is null!!!");
                        return;
                    }

                    if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL)) {
                        mTUICallKit.call(chatId, TUICallDefine.MediaType.Audio);
                    } else if (key.equals(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL)) {
                        mTUICallKit.call(chatId, TUICallDefine.MediaType.Video);
                    }
                }
            });
        }
        extensionMap.put(TUIConstants.TUIChat.INPUT_MORE_VIEW, unitView);
        extensionMap.put(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, actionId);
        return extensionMap;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED.equals(key)
                && TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT.equals(subKey)) {
            mTUICallKit = TUICallKit.createInstance(appContext);
        }
    }
}
