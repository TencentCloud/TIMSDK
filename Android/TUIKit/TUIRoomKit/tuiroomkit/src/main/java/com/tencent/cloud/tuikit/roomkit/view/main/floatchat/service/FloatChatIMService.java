package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service;

import static com.tencent.imsdk.v2.V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.TUIFloatChat;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMFileElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.base.Log;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.trtc.tuikit.common.system.ContextProvider;

import java.util.List;

public class FloatChatIMService implements IFloatChatMessage {
    private static final String TAG = "FloatChatIMService";

    private       MessageListener        mMessageListener;
    private final String                 mRoomId;
    private       BarrageMessageDelegate mDelegate;

    public FloatChatIMService(String roomId) {
        mRoomId = roomId;
    }

    @Override
    public void setDelegate(BarrageMessageDelegate delegate) {
        mDelegate = delegate;
        if (delegate == null) {
            V2TIMManager.getInstance().setGroupListener(null);
            V2TIMManager.getMessageManager().addAdvancedMsgListener(mMessageListener);
        } else {
            if (mMessageListener == null) {
                mMessageListener = new MessageListener();
            }
            V2TIMManager.getMessageManager().addAdvancedMsgListener(mMessageListener);
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
                        RoomToast.toastLongMessageCenter(ErrorMessageConverter.convertIMError(i, s));
                        if (callback != null) {
                            callback.onFailed(i, s);
                        }
                    }
                });
    }

    private class MessageListener extends V2TIMAdvancedMsgListener {
        @Override
        public void onRecvNewMessage(V2TIMMessage msg) {
            String groupID = msg.getGroupID();
            if (!TextUtils.equals(mRoomId, groupID)) {
                return;
            }
            if (handleTextMessageIfNeeded(msg)) {
                return;
            }
            if (handleCustomMessageIfNeeded(msg)) {
                return;
            }
            if (handleImageMessageIfNeeded(msg)) {
                return;
            }
            if (handleVideoMessageIfNeeded(msg)) {
                return;
            }
            handleFileMessageIfNeeded(msg);
        }

        private boolean handleTextMessageIfNeeded(V2TIMMessage msg) {
            if (msg.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
                return false;
            }
            notifyBarrage(msg, msg.getTextElem().getText());
            return true;
        }

        private boolean handleCustomMessageIfNeeded(V2TIMMessage msg) {
            if (msg.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
                return false;
            }
            try {
                V2TIMCustomElem customElem = msg.getCustomElem();
                String info = new String(customElem.getData());
                Gson gson = new Gson();
                FloatChatJson barrageJson = gson.fromJson(info, FloatChatJson.class);
                TUIFloatChat barrage = new TUIFloatChat();
                if (barrageJson.data == null) {
                    return true;
                }
                barrage.content = barrageJson.data.content;
                if (barrageJson.data.user == null) {
                    return true;
                }
                barrage.user.userId = barrageJson.data.user.userId;
                barrage.user.userName = barrageJson.data.user.userName;
                barrage.user.avatarUrl = barrageJson.data.user.avatarUrl;
                barrage.user.level = barrageJson.data.user.level;
                if (mDelegate != null) {
                    mDelegate.onReceivedBarrage(barrage);
                }
            } catch (Exception e) {
                Log.e(TAG, "handleCustomMessageIfNeeded : " + e.toString());
            }
            return true;
        }

        private boolean handleImageMessageIfNeeded(V2TIMMessage msg) {
            if (msg.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
                return false;
            }
            V2TIMImageElem v2TIMImageElem = msg.getImageElem();
            List<V2TIMImageElem.V2TIMImage> imageList = v2TIMImageElem.getImageList();
            for (V2TIMImageElem.V2TIMImage v2TIMImage : imageList) {
                if (V2TIM_IMAGE_TYPE_THUMB != v2TIMImage.getType()) {
                    continue;
                }
                notifyBarrage(msg, ContextProvider.getApplicationContext().getString(R.string.tuiroomkit_sent_a_picture));
            }
            return true;
        }

        private boolean handleVideoMessageIfNeeded(V2TIMMessage msg) {
            if (msg.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
                return false;
            }
            notifyBarrage(msg, ContextProvider.getApplicationContext().getString(R.string.tuiroomkit_sent_a_video));
            return true;
        }

        private boolean handleFileMessageIfNeeded(V2TIMMessage msg) {
            if (msg.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
                return false;
            }
            V2TIMFileElem v2TIMFileElem = msg.getFileElem();
            String fileName = v2TIMFileElem.getFileName();
            notifyBarrage(msg, ContextProvider.getApplicationContext().getString(R.string.tuiroomkit_sent, fileName));
            return true;
        }

        private void notifyBarrage(V2TIMMessage msg, String content) {
            TUIFloatChat barrage = new TUIFloatChat();
            barrage.content = content;
            barrage.user.userId = msg.getSender();
            barrage.user.userName = msg.getNickName();
            barrage.user.avatarUrl = msg.getFaceUrl();
            barrage.user.level = "0";
            if (mDelegate != null) {
                mDelegate.onReceivedBarrage(barrage);
            }
        }
    }
}
