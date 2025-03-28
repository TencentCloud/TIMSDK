package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.MSG_MAX_SHOW_MEMBER_COUNT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.SEND_IM_MSG_COMPLETE;

import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view.RoomMessageBean;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.imsdk.v2.V2TIMCompleteCallback;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;

import java.lang.ref.WeakReference;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class RoomMsgManager {
    private static final String TAG = "RoomMsgManager";

    private static final long WAIT_TIME_S = 10L;

    private V2TIMMessage mIMMsg;
    private Handler      mWorkHandler;
    private Handler      mMainHandler;

    private CountDownLatch mSendMsgLatch;
    private CountDownLatch mModifyMsgLatch;
    private CountDownLatch mFindMsgLatch;

    private static WeakReference<ChatInputMoreListener> mChatInputMoreListenerRef;

    public static void setChatInputMoreListenerRef(WeakReference<ChatInputMoreListener> ref) {
        mChatInputMoreListenerRef = ref;
    }

    public RoomMsgManager() {
        Log.d(TAG, "new");
        HandlerThread handlerThread = new HandlerThread("RoomMsgManager-Thread");
        handlerThread.start();
        mWorkHandler = new Handler(handlerThread.getLooper());
        mMainHandler = new Handler(Looper.getMainLooper());
    }

    public void destroyRoomMsgManager() {
        if (mWorkHandler != null) {
            Log.d(TAG, "destroy");
            mWorkHandler.getLooper().quitSafely();
            mWorkHandler = null;
        }
    }

    public void sendGroupRoomMessage(RoomMsgData roomMsgData) {
        if (mWorkHandler == null) {
            Log.w(TAG, "sendGroupRoomMessage mWorkHandler is null");
            return;
        }
        mWorkHandler.post(new Runnable() {
            @Override
            public void run() {
                sendGroupRoomMessageInternal(roomMsgData);
            }
        });
    }

    private void sendGroupRoomMessageInternal(RoomMsgData roomMsgData) {
        Log.d(TAG,
                "sendGroupRoomMessage roomId=" + roomMsgData.getRoomId() + " messageId=" + roomMsgData.getMessageId());
        if (mChatInputMoreListenerRef == null) {
            Log.e(TAG, "");
            return;
        }
        final ChatInputMoreListener chatInputMoreListener = mChatInputMoreListenerRef.get();
        if (chatInputMoreListener == null) {
            return;
        }

        mIMMsg = V2TIMManager.getMessageManager().createCustomMessage(codeRoomMsgData(roomMsgData));
        mIMMsg.setNeedReadReceipt(true);

        RoomMessageBean roomMessageBean = new RoomMessageBean();
        roomMessageBean.setV2TIMMessage(mIMMsg);
        Log.d(TAG, "sendMessage thread=" + Thread.currentThread().getName());
        mSendMsgLatch = new CountDownLatch(1);
        chatInputMoreListener.sendMessage(roomMessageBean, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                Log.d(TAG, "sendMessage onSuccess thread=" + Thread.currentThread().getName());
                roomMsgData.setGroupId(data.getGroupId());
                roomMsgData.setMessageId(data.getV2TIMMessage().getMsgID());
                mSendMsgLatch.countDown();
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        ConferenceEventCenter.getInstance().notifyUIEvent(SEND_IM_MSG_COMPLETE, null);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                Log.e(TAG, "sendMessage onError module=" + module + " errCode=" + errCode + " errMsg=" + errMsg);
                mSendMsgLatch.countDown();
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        ConferenceEventCenter.getInstance().notifyUIEvent(SEND_IM_MSG_COMPLETE, null);
                    }
                });
            }

            @Override
            public void onError(int errCode, String errMsg, TUIMessageBean data) {
                Log.e(TAG, "sendMessage onError errCode=" + errCode + " errMsg=" + errMsg + " data=" + data);
                mSendMsgLatch.countDown();
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        ConferenceEventCenter.getInstance().notifyUIEvent(SEND_IM_MSG_COMPLETE, null);
                    }
                });
            }
        });
        try {
            mSendMsgLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void updateGroupRoomMessage(RoomMsgData msgData) {
        updateGroupRoomMessage(msgData, false);
    }

    public void updateGroupRoomMessage(RoomMsgData msgData, boolean isForceUpdate) {
        if (mWorkHandler == null) {
            Log.w(TAG, "updateGroupRoomMessage mWorkHandler is null");
            return;
        }
        if (isNeedIgnoreMessage(msgData) && !isForceUpdate) {
            Log.e(TAG, "updateGroupRoomMessageInternal needIgnoreMessage");
            return;
        }
        Log.d(TAG, "updateGroupRoomMessage roomId=" + msgData.getRoomId() + " messageId=" + msgData.getMessageId());
        final RoomMsgData data = msgData.copy();
        mWorkHandler.post(new Runnable() {
            @Override
            public void run() {
                updateGroupRoomMessageInternal(data);
            }
        });
    }

    private void waitUntilFindMessage(String messageId) {
        List<String> list = new ArrayList<>(1);
        list.add(messageId);
        mFindMsgLatch = new CountDownLatch(1);
        V2TIMManager.getMessageManager().findMessages(list, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                Log.d(TAG, "findMessages onSuccess");
                if (v2TIMMessages != null && !v2TIMMessages.isEmpty()) {
                    mIMMsg = v2TIMMessages.get(0);
                }
                mFindMsgLatch.countDown();
            }

            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "findMessages onError i=" + i + " s=" + s);
                mFindMsgLatch.countDown();
            }
        });
        try {
            mFindMsgLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void updateGroupRoomMessageInternal(RoomMsgData data) {
        Log.d(TAG, "updateGroupRoomMessageInternal roomId=" + data.getRoomId() + " messageId=" + data.getMessageId());
        if (mIMMsg == null) {
            waitUntilFindMessage(data.getMessageId());
        }
        final V2TIMMessage imMsg = mIMMsg;
        if (imMsg == null) {
            Log.e(TAG, "updateGroupRoomMessageInternal imMsg is null");
            return;
        }
        V2TIMCustomElem customElem = imMsg.getCustomElem();
        customElem.setData(codeRoomMsgData(data));

        mModifyMsgLatch = new CountDownLatch(1);
        V2TIMManager.getMessageManager().modifyMessage(imMsg, new V2TIMCompleteCallback<V2TIMMessage>() {
            @Override
            public void onComplete(int i, String s, V2TIMMessage v2TIMMessage) {
                Log.d(TAG, "updateGroupRoomMessageInternal modifyMessage onComplete i=" + i + " s=" + s);
                mIMMsg = v2TIMMessage;
                mModifyMsgLatch.countDown();
            }
        });

        try {
            mModifyMsgLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private byte[] codeRoomMsgData(RoomMsgData data) {
        Gson gson = new Gson();
        final RoomMsgData tmpData;
        if (data.getUserList().size() > MSG_MAX_SHOW_MEMBER_COUNT) {
            tmpData = data.copy();
            tmpData.getUserList().clear();
            for (int i = 0; i < MSG_MAX_SHOW_MEMBER_COUNT; i++) {
                tmpData.getUserList().add(data.getUserList().get(i));
            }
        } else {
            tmpData = data;
        }
        tmpData.setMemberCount(data.getUserList().size());
        String content = gson.toJson(data);
        byte[] codeData = content.getBytes(StandardCharsets.UTF_8);
        return codeData;
    }

    private boolean isNeedIgnoreMessage(RoomMsgData data) {
        return !TextUtils.equals(TUILogin.getUserId(), data.getRoomManagerId());
    }
}
