package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service;

import static com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatConstants.VALUE_BUSINESS_ID;
import static com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatConstants.VALUE_PLATFORM;
import static com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatConstants.VALUE_VERSION;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.base.Log;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;


public class FloatChatIMService implements IFloatChatMessage {
    private static final String TAG = "FloatChatIMService";

    private SimpleListener          mSimpleListener;
    private final String            mRoomId;
    private BarrageMessageDelegate  mDelegate;

    public FloatChatIMService(String roomId) {
        mRoomId = roomId;
    }

    @Override
    public void setDelegate(BarrageMessageDelegate delegate) {
        mDelegate = delegate;
        if (delegate == null) {
            V2TIMManager.getInstance().setGroupListener(null);
            V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
        } else {
            if (mSimpleListener == null) {
                mSimpleListener = new SimpleListener();
            }
            V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
        }
    }

    @Override
    public void sendBarrage(TUIFloatChat barrage, final BarrageSendCallBack callback) {
        if (TextUtils.isEmpty(barrage.content)) {
            Log.i(TAG, " sendBarrage data is empty");
            return;
        }
        String text = barrage.content;
        Log.i(TAG, " sendBarrage:" + text);
        V2TIMManager.getInstance().sendGroupTextMessage(text, mRoomId, V2TIMMessage.V2TIM_PRIORITY_HIGH,
                new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        if (callback != null) {
                            callback.onSuccess(barrage);
                            Log.i(TAG, " sendGroupCustomMessage success");
                        }
                    }

                    @Override
                    public void onError(int i, String s) {
                        Log.e(TAG, " sendGroupCustomMessage error " + i + " errorMessage:" + s);
                        ToastUtil.toastLongMessageCenter(ErrorMessageConverter.convertIMError(i, s));
                        if (callback != null) {
                            callback.onFailed(i, s);
                        }
                    }
                });
    }

    private class SimpleListener extends V2TIMSimpleMsgListener {
        @Override
        public void onRecvGroupTextMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, String text) {
            Log.i(TAG, " onRecvGroupCustomMessage: msgID = " + msgID + " , groupID = " + groupID
                    + " , mGroupId = " + mRoomId + " , sender = " + sender + " , text = " + text);
            if (groupID == null || !groupID.equals(mRoomId)) {
                return;
            }
            if (TextUtils.isEmpty(text)) {
                Log.i(TAG, " onRecvGroupCustomMessage customData is empty");
                return;
            }
            TUIFloatChat barrage = new TUIFloatChat();
            barrage.content = text;
            barrage.user.userId = sender.getUserID();
            barrage.user.userName = sender.getNickName();
            barrage.user.avatarUrl = sender.getFaceUrl();
            barrage.user.level = "0";

            if (mDelegate != null) {
                mDelegate.onReceivedBarrage(barrage);
            }
        }

        @Override
        public void onRecvGroupCustomMessage(String msgID, String groupID,
                                             V2TIMGroupMemberInfo sender, byte[] customData) {
            Log.i(TAG, " onRecvGroupCustomMessage: msgID = " + msgID + " , groupID = " + groupID
                    + " , mGroupId = " + mRoomId + " , sender = " + sender);
            if (groupID == null || !groupID.equals(mRoomId)) {
                return;
            }
            if (customData == null) {
                Log.e(TAG, " onRecvGroupCustomMessage customData is empty");
                return;
            }
            try {
                String info = new String(customData);
                Gson gson = new Gson();
                FloatChatJson barrageJson = gson.fromJson(info, FloatChatJson.class);
                Log.i(TAG, " " + barrageJson);
                TUIFloatChat barrage = new TUIFloatChat();
                if (barrageJson.data != null) {
                    barrage.content = barrageJson.data.content;
                    if (barrageJson.data.user != null) {
                        barrage.user.userId = barrageJson.data.user.userId;
                        barrage.user.userName = barrageJson.data.user.userName;
                        barrage.user.avatarUrl = barrageJson.data.user.avatarUrl;
                        barrage.user.level = barrageJson.data.user.level;
                    }
                }
                if (mDelegate != null) {
                    mDelegate.onReceivedBarrage(barrage);
                }
            } catch (Exception e) {
                Log.e(TAG, " " + e.getLocalizedMessage());
            }
        }
    }

    public static String getTextMsgJsonStr(TUIFloatChat barrage) {
        if (barrage == null) {
            return null;
        }
        FloatChatJson sendJson = new FloatChatJson();
        sendJson.businessID = VALUE_BUSINESS_ID;
        sendJson.platform = VALUE_PLATFORM;
        sendJson.version = VALUE_VERSION;

        FloatChatJson.Data data = new FloatChatJson.Data();
        data.content = barrage.content;
        sendJson.data = data;

        FloatChatJson.Data.User user = new FloatChatJson.Data.User();
        user.userName = barrage.user.userName;
        user.userId = barrage.user.userId;
        user.avatarUrl = barrage.user.avatarUrl;
        user.level = barrage.user.level;
        sendJson.data.user = user;

        Gson gson = new Gson();
        return gson.toJson(sendJson);
    }
}
