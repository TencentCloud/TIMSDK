package com.tencent.qcloud.tuikit.tuicallkit.internal;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.activity.result.ActivityResultCaller;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIConstants.TUICalling.ObjectFactory.RecentCalls;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.RecentCallsFragment;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * `TUICore` call (if the `TUICore` module is not imported, use `TUICallKitImpl` instead)
 */
final class TUICallingService implements ITUINotification, ITUIService, ITUIExtension, ITUIObjectFactory {
    private static final String TAG = "TUICallingService";

    private static final int CALL_MEMBER_LIMIT = 9;

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

        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIGroup.Extension.GroupProfileItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.MINIMALIST_EXTENSION_ID, this);

        TUICore.registerObjectFactory(TUIConstants.TUICalling.ObjectFactory.FACTORY_NAME, this);
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
    public Object onCreateObject(String objectName, Map<String, Object> param) {
        if (TextUtils.equals(objectName, RecentCalls.OBJECT_NAME)) {
            String style = RecentCalls.UI_STYLE_MINIMALIST;
            if (param != null && RecentCalls.UI_STYLE_CLASSIC.equals(param.get(RecentCalls.UI_STYLE))) {
                style = RecentCalls.UI_STYLE_CLASSIC;
            }
            return new RecentCallsFragment(style);
        }
        return null;
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        Log.i(TAG, "onGetExtension, extensionID: " + extensionID + " ,param: " + param);
        if (TextUtils.equals(extensionID,
                TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID)) {
            return getClassicChatInputMoreExtension(param);
        } else if (TextUtils.equals(extensionID,
                TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID)) {
            return getMinimalistGroupProfileExtension(param);
        } else if (TextUtils.equals(extensionID,
                TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID)) {
            return getClassicFriendProfileExtension(param);
        } else if (TextUtils.equals(extensionID,
                TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID)) {
            return getMinimalistFriendProfileExtension(param);
        } else if (TextUtils.equals(extensionID,
                TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.MINIMALIST_EXTENSION_ID)) {
            return getMinimalistChatNavigationMoreExtension(param);
        }
        return null;
    }

    private List<TUIExtensionInfo> getClassicChatInputMoreExtension(Map<String, Object> param) {
        TUIExtensionInfo voiceCallExtension = new TUIExtensionInfo();
        voiceCallExtension.setWeight(600);
        TUIExtensionInfo videoCallExtension = new TUIExtensionInfo();
        videoCallExtension.setWeight(500);

        String userID = getOrDefault(param, TUIConstants.TUIChat.Extension.InputMore.USER_ID, null);
        String groupID = getOrDefault(param, TUIConstants.TUIChat.Extension.InputMore.GROUP_ID, null);
        ResultTUIExtensionEventListener voiceListener = new ResultTUIExtensionEventListener();
        voiceListener.mediaType = TUICallDefine.MediaType.Audio;
        voiceListener.userID = userID;
        voiceListener.groupID = groupID;
        ResultTUIExtensionEventListener videoListener = new ResultTUIExtensionEventListener();
        videoListener.mediaType = TUICallDefine.MediaType.Video;
        videoListener.userID = userID;
        videoListener.groupID = groupID;

        voiceCallExtension.setText(appContext.getString(R.string.tuicalling_audio_call));
        voiceCallExtension.setIcon(R.drawable.tuicalling_ic_audio_call);
        voiceCallExtension.setExtensionListener(voiceListener);
        voiceListener.activityResultCaller = getOrDefault(param,
                TUIConstants.TUIChat.Extension.InputMore.CONTEXT, null);
        videoCallExtension.setText(appContext.getString(R.string.tuicalling_video_call));
        videoCallExtension.setIcon(R.drawable.tuicalling_ic_video_call);
        videoCallExtension.setExtensionListener(videoListener);
        videoListener.activityResultCaller = getOrDefault(param,
                TUIConstants.TUIChat.Extension.InputMore.CONTEXT, null);
        boolean filterVoice = getOrDefault(param, TUIConstants.TUIChat.Extension.InputMore.FILTER_VOICE_CALL, false);
        boolean filterVideo = getOrDefault(param, TUIConstants.TUIChat.Extension.InputMore.FILTER_VIDEO_CALL, false);
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        if (!filterVoice) {
            extensionInfoList.add(voiceCallExtension);
        }
        if (!filterVideo) {
            extensionInfoList.add(videoCallExtension);
        }
        return extensionInfoList;
    }

    private List<TUIExtensionInfo> getMinimalistGroupProfileExtension(Map<String, Object> param) {
        TUIExtensionInfo voiceCallExtension = new TUIExtensionInfo();
        voiceCallExtension.setWeight(200);
        TUIExtensionInfo videoCallExtension = new TUIExtensionInfo();
        videoCallExtension.setWeight(100);

        String groupID = getOrDefault(param, TUIConstants.TUIGroup.Extension.GroupProfileItem.GROUP_ID, null);
        ResultTUIExtensionEventListener voiceListener = new ResultTUIExtensionEventListener();
        voiceListener.mediaType = TUICallDefine.MediaType.Audio;
        voiceListener.groupID = groupID;
        voiceListener.isClassicUI = false;
        ResultTUIExtensionEventListener videoListener = new ResultTUIExtensionEventListener();
        videoListener.mediaType = TUICallDefine.MediaType.Video;
        videoListener.groupID = groupID;
        videoListener.isClassicUI = false;

        voiceCallExtension.setText(appContext.getString(R.string.tuicalling_audio_call));
        voiceCallExtension.setIcon(R.drawable.tuicallkit_profile_minimalist_audio_icon);
        voiceCallExtension.setExtensionListener(voiceListener);
        voiceListener.activityResultCaller = getOrDefault(param,
                TUIConstants.TUIGroup.Extension.GroupProfileItem.CONTEXT, null);
        voiceListener.isClassicUI = false;
        videoCallExtension.setText(appContext.getString(R.string.tuicalling_video_call));
        videoCallExtension.setIcon(R.drawable.tuicallkit_profile_minimalist_video_icon);
        videoCallExtension.setExtensionListener(videoListener);
        videoListener.isClassicUI = false;
        videoListener.activityResultCaller = getOrDefault(param,
                TUIConstants.TUIGroup.Extension.GroupProfileItem.CONTEXT, null);
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        extensionInfoList.add(videoCallExtension);
        extensionInfoList.add(voiceCallExtension);
        return extensionInfoList;
    }

    private List<TUIExtensionInfo> getClassicFriendProfileExtension(Map<String, Object> param) {
        TUIExtensionInfo voiceCallExtension = new TUIExtensionInfo();
        voiceCallExtension.setWeight(300);
        TUIExtensionInfo videoCallExtension = new TUIExtensionInfo();
        videoCallExtension.setWeight(200);

        String userID = getOrDefault(param, TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, null);
        ResultTUIExtensionEventListener voiceListener = new ResultTUIExtensionEventListener();
        voiceListener.mediaType = TUICallDefine.MediaType.Audio;
        voiceListener.userID = userID;
        ResultTUIExtensionEventListener videoListener = new ResultTUIExtensionEventListener();
        videoListener.mediaType = TUICallDefine.MediaType.Video;
        videoListener.userID = userID;

        voiceCallExtension.setText(appContext.getString(R.string.tuicalling_audio_call));
        voiceCallExtension.setExtensionListener(voiceListener);
        videoCallExtension.setText(appContext.getString(R.string.tuicalling_video_call));
        videoCallExtension.setExtensionListener(videoListener);
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        extensionInfoList.add(videoCallExtension);
        extensionInfoList.add(voiceCallExtension);
        return extensionInfoList;
    }

    private List<TUIExtensionInfo> getMinimalistFriendProfileExtension(Map<String, Object> param) {
        TUIExtensionInfo voiceCallExtension = new TUIExtensionInfo();
        voiceCallExtension.setWeight(300);
        TUIExtensionInfo videoCallExtension = new TUIExtensionInfo();
        videoCallExtension.setWeight(200);

        String userID = getOrDefault(param, TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, null);
        ResultTUIExtensionEventListener voiceListener = new ResultTUIExtensionEventListener();
        voiceListener.mediaType = TUICallDefine.MediaType.Audio;
        voiceListener.userID = userID;
        voiceListener.isClassicUI = false;
        ResultTUIExtensionEventListener videoListener = new ResultTUIExtensionEventListener();
        videoListener.mediaType = TUICallDefine.MediaType.Video;
        videoListener.userID = userID;
        videoListener.isClassicUI = false;

        voiceCallExtension.setIcon(R.drawable.tuicallkit_profile_minimalist_audio_icon);
        voiceCallExtension.setText(appContext.getString(R.string.tuicalling_audio_call));
        voiceCallExtension.setExtensionListener(voiceListener);
        videoCallExtension.setIcon(R.drawable.tuicallkit_profile_minimalist_video_icon);
        videoCallExtension.setText(appContext.getString(R.string.tuicalling_video_call));
        videoCallExtension.setExtensionListener(videoListener);
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        extensionInfoList.add(videoCallExtension);
        extensionInfoList.add(voiceCallExtension);
        return extensionInfoList;
    }

    private List<TUIExtensionInfo> getMinimalistChatNavigationMoreExtension(Map<String, Object> param) {
        String userID = getOrDefault(param, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID, null);
        String groupID = getOrDefault(param, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID, null);
        ResultTUIExtensionEventListener voiceListener = new ResultTUIExtensionEventListener();
        voiceListener.mediaType = TUICallDefine.MediaType.Audio;
        voiceListener.groupID = groupID;
        voiceListener.userID = userID;
        voiceListener.isClassicUI = false;
        voiceListener.activityResultCaller = getOrDefault(param,
                TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CONTEXT, null);
        ResultTUIExtensionEventListener videoListener = new ResultTUIExtensionEventListener();
        videoListener.mediaType = TUICallDefine.MediaType.Video;
        videoListener.groupID = groupID;
        videoListener.userID = userID;
        videoListener.isClassicUI = false;
        videoListener.activityResultCaller = getOrDefault(param,
                TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CONTEXT, null);

        TUIExtensionInfo voiceCallExtension = new TUIExtensionInfo();
        TUIExtensionInfo videoCallExtension = new TUIExtensionInfo();

        voiceCallExtension.setIcon(R.drawable.tuicallkit_chat_title_bar_minimalist_audio_call_icon);
        voiceCallExtension.setExtensionListener(voiceListener);
        videoCallExtension.setIcon(R.drawable.tuicallkit_chat_title_bar_minimalist_video_call_icon);
        videoCallExtension.setExtensionListener(videoListener);
        List<TUIExtensionInfo> extensionInfoList = new ArrayList<>();
        extensionInfoList.add(voiceCallExtension);
        extensionInfoList.add(videoCallExtension);
        return extensionInfoList;
    }

    private <T> T getOrDefault(Map map, Object key, T defaultValue) {
        if (map == null || map.isEmpty()) {
            return defaultValue;
        }
        Object object = map.get(key);
        try {
            if (object != null) {
                return (T) object;
            }
        } catch (ClassCastException e) {
            return defaultValue;
        }
        return defaultValue;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED.equals(key)
                && TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT.equals(subKey)) {
            TUICallKit.createInstance(appContext);
            adaptiveComponentReport();
            setExcludeFromHistoryMessage();
        }
    }

    private void adaptiveComponentReport() {
        ITUIService service = TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME);
        try {
            JSONObject params = new JSONObject();
            params.put("framework", 1);
            if (service == null) {
                params.put("component", 14);
            } else {
                params.put("component", 15);
            }
            params.put("language", 1);

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("api", "setFramework");
            jsonObject.put("params", params);
            TUICallEngine.createInstance(appContext).callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void setExcludeFromHistoryMessage() {
        if (TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME) == null) {
            return;
        }
        try {
            JSONObject params = new JSONObject();
            params.put("excludeFromHistoryMessage", false);

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("api", "setExcludeFromHistoryMessage");
            jsonObject.put("params", params);
            TUICallEngine.createInstance(appContext).callExperimentalAPI(jsonObject.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    class ResultTUIExtensionEventListener extends TUIExtensionEventListener {
        public ActivityResultCaller    activityResultCaller;
        public TUICallDefine.MediaType mediaType;
        public boolean                 isClassicUI = true;
        public String                  userID;
        public String                  groupID;

        @Override
        public void onClicked(Map<String, Object> param) {
            if (!TextUtils.isEmpty(groupID)) {
                String groupMemberSelectActivityName =
                        TUIConstants.TUIContact.StartActivity.GroupMemberSelect.CLASSIC_ACTIVITY_NAME;
                if (!isClassicUI) {
                    groupMemberSelectActivityName =
                            TUIConstants.TUIContact.StartActivity.GroupMemberSelect.MINIMALIST_ACTIVITY_NAME;
                }
                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, groupID);
                bundle.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FOR_CALL, true);
                bundle.putInt(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.MEMBER_LIMIT, CALL_MEMBER_LIMIT);
                TUICore.startActivityForResult(activityResultCaller, groupMemberSelectActivityName, bundle, result -> {
                    Intent data = result.getData();
                    if (data != null) {
                        List<String> stringList = data.getStringArrayListExtra(
                                TUIConstants.TUIContact.StartActivity.GroupMemberSelect.DATA_LIST);
                        TUICallKit.createInstance(appContext).groupCall(groupID, stringList, mediaType);
                    }
                });
            } else if (!TextUtils.isEmpty(userID)) {
                TUICallKit.createInstance(appContext).call(userID, mediaType);
            } else {
                Log.e(TAG, "onClicked event ignored, groupId is empty or userId is empty, cannot start call");
            }
        }
    }
}
