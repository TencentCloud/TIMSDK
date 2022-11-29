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
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * `TUICore` call (if the `TUICore` module is not imported, use `TUICallKitImpl` instead)
 */
final class TUICallingService implements ITUINotification, ITUIService, ITUIExtension {

    private static final String TAG = "TUICallingService";

    private static final TUICallingService INSTANCE = new TUICallingService();

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
        Log.i(TAG, "onCall, method: " + method + " ,param: " + param);

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_FLOAT_WINDOW, method)) {
            boolean enableFloatWindow = (boolean) param.get(TUIConstants.TUICalling.PARAM_NAME_ENABLE_FLOAT_WINDOW);
            Log.i(TAG, "onCall, enableFloatWindow: " + enableFloatWindow);
            TUICallKit.createInstance(appContext).enableFloatWindow(enableFloatWindow);
            return null;
        }

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_MULTI_DEVICE, method)) {
            boolean enable = (boolean) param.get(TUIConstants.TUICalling.PARAM_NAME_ENABLE_MULTI_DEVICE);
            Log.i(TAG, "onCall, enableMultiDevice: " + enable);
            TUICallEngine.createInstance(appContext).enableMultiDeviceAbility(enable, new TUICommonDefine.Callback() {
                @Override
                public void onSuccess() {
                }

                @Override
                public void onError(int errCode, String errMsg) {
                }
            });
            return null;
        }

        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_CALL, method)) {
            String[] userIDs = (String[]) param.get(TUIConstants.TUICalling.PARAM_NAME_USERIDS);
            String typeString = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_TYPE);
            String groupID = (String) param.get(TUIConstants.TUICalling.PARAM_NAME_GROUPID);

            List<String> userIdList = new ArrayList<>(Arrays.asList(userIDs));
            TUICallDefine.MediaType mediaType = TUICallDefine.MediaType.Unknown;
            if (TUIConstants.TUICalling.TYPE_AUDIO.equals(typeString)) {
                mediaType = TUICallDefine.MediaType.Audio;
            } else if (TUIConstants.TUICalling.TYPE_VIDEO.equals(typeString)) {
                mediaType = TUICallDefine.MediaType.Video;
            }
            if (!TextUtils.isEmpty(groupID)) {
                TUICallKit.createInstance(appContext).groupCall(groupID, userIdList, mediaType);
            } else if (userIdList.size() == 1) {
                TUICallKit.createInstance(appContext).call(userIdList.get(0), mediaType);
            } else {
                Log.e(TAG, "onCall ignored, groupId is empty and userList is not 1, cannot start call or groupCall");
            }
        }
        return null;
    }

    @Override
    public Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param) {
        Log.i(TAG, "onGetExtensionInfo, key: " + key + " ,param: " + param);

        Context inflateContext = (Context) param.get(TUIConstants.TUIChat.CONTEXT);
        if (inflateContext == null) {
            inflateContext = appContext;
        }
        if (inflateContext == null) {
            return null;
        }
        HashMap<String, Object> extensionMap = new HashMap<>();
        View unitView = LayoutInflater.from(inflateContext).inflate(R.layout.chat_input_more_action, null);
        ImageView imageView = unitView.findViewById(R.id.imageView);
        TextView textView = unitView.findViewById(R.id.textView);
        int actionId = 0;
        if (TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL.equals(key)) {
            imageView.setImageResource(R.drawable.tuicalling_ic_audio_call);
            textView.setText(inflateContext.getString(R.string.tuicalling_audio_call));
            actionId = TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL;
        } else if (TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL.equals(key)) {
            imageView.setImageResource(R.drawable.tuicalling_ic_video_call);
            textView.setText(inflateContext.getString(R.string.tuicalling_video_call));
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
                    TUICallDefine.MediaType mediaType = TUICallDefine.MediaType.Unknown;
                    if (TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL.equals(key)) {
                        mediaType = TUICallDefine.MediaType.Audio;
                    } else if (TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL.equals(key)) {
                        mediaType = TUICallDefine.MediaType.Video;
                    }
                    Log.i(TAG, "onGetExtensionInfo, mediaType: " + mediaType + " ,chatId: " + chatId);
                    TUICallKit.createInstance(appContext).call(chatId, mediaType);
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
            TUICallKit.createInstance(appContext);
            adaptiveComponentReport();
        }
    }

    private void adaptiveComponentReport() {
        ITUIService service = TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME);
        if (service == null) {
            return;
        }

        try {
            JSONObject params = new JSONObject();
            params.put("framework", 1);
            params.put("component", 15);

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("api", "setFramework");
            jsonObject.put("params", params);
            TUICallEngine.createInstance(appContext).callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
