package com.tencent.qcloud.tim.demo.helper;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.chat.ChatActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.modules.chat.ChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudListener;

import java.util.List;
import java.util.Random;

import static com.tencent.qcloud.tim.demo.helper.CustomMessage.JSON_VERSION_1_HELLOTIM;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.JSON_VERSION_3_ANDROID_IOS_TRTC;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_ACCEPTED;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_DIALING;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_HANGUP;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_LINE_BUSY;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_REJECT;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_SPONSOR_CANCEL;
import static com.tencent.qcloud.tim.demo.helper.CustomMessage.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT;

public class CustomAVCallUIController extends TRTCCloudListener {

    private static final String TAG = CustomAVCallUIController.class.getSimpleName();

    private static final int VIDEO_CALL_STATUS_FREE = 1;
    private static final int VIDEO_CALL_STATUS_BUSY = 2;
    private static final int VIDEO_CALL_STATUS_WAITING = 3;
    private int mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;

    private static CustomAVCallUIController mController;

    private long mEnterRoomTime;
    private CustomMessage mOnlineCall;
    private ChatLayout mUISender;
    private TRTCDialog mDialog;
    private TRTCCloud mTRTCCloud;

    private static final int VIDEO_CALL_OUT_GOING_TIME_OUT = 60 * 1000;
    private static final int VIDEO_CALL_OUT_INCOMING_TIME_OUT = 60 * 1000;
    private Handler mHandler = new Handler();
    private Runnable mVideoCallOutgoingTimeOut = new Runnable() {
        @Override
        public void run() {
            DemoLog.i(TAG, "time out, dismiss outgoing dialog");
            mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
            sendVideoCallAction(VIDEO_CALL_ACTION_SPONSOR_CANCEL, mOnlineCall);
            dismissDialog();
        }
    };

    private Runnable mVideoCallIncomingTimeOut = new Runnable() {
        @Override
        public void run() {
            DemoLog.i(TAG, "time out, dismiss incoming dialog");
            mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
            sendVideoCallAction(VIDEO_CALL_ACTION_SPONSOR_TIMEOUT, mOnlineCall);
            dismissDialog();
        }
    };

    private CustomAVCallUIController() {
        mTRTCCloud = TRTCCloud.sharedInstance(DemoApplication.instance());
        TRTCListener.getInstance().addTRTCCloudListener(this);
        mTRTCCloud.setListener(TRTCListener.getInstance());
    }

    public static CustomAVCallUIController getInstance() {
        if (mController == null) {
            mController = new CustomAVCallUIController();
        }
        return mController;
    }

    public void onCreate() {
        mTRTCCloud = TRTCCloud.sharedInstance(DemoApplication.instance());
        mTRTCCloud.setListener(this);
    }

    @Override
    public void onError(int errCode, String errMsg, Bundle extraInfo) {
        DemoLog.i(TAG, "trtc onError");
        mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
        sendVideoCallAction(VIDEO_CALL_ACTION_HANGUP, mOnlineCall);
        Toast.makeText(mUISender.getContext(), "通话异常: " + errMsg + "[" + errCode + "]", Toast.LENGTH_LONG).show();
        if (mTRTCCloud != null) {
            mTRTCCloud.exitRoom();
        }
    }

    @Override
    public void onEnterRoom(long elapsed) {
        DemoLog.i(TAG, "onEnterRoom " + elapsed);
        Toast.makeText(mUISender.getContext(), "开始通话", Toast.LENGTH_SHORT).show();
        mEnterRoomTime = System.currentTimeMillis();
    }

    @Override
    public void onExitRoom(int reason) {
        DemoLog.i(TAG, "onExitRoom " + reason);
        Toast.makeText(mUISender.getContext(), "结束通话", Toast.LENGTH_SHORT).show();
        mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
    }

    public void setUISender(ChatLayout layout) {
        DemoLog.i(TAG, "setUISender: " + layout);
        mUISender = layout;
        if (mCurrentVideoCallStatus == VIDEO_CALL_STATUS_WAITING) {
            boolean success = showIncomingDialingDialog();
            if (success) {
                mCurrentVideoCallStatus = VIDEO_CALL_STATUS_BUSY;
            } else {
                mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
                sendVideoCallAction(VIDEO_CALL_ACTION_REJECT, mOnlineCall);
                Toast.makeText(mUISender.getContext(), "发起通话失败，没有弹出对话框权限", Toast.LENGTH_SHORT).show();
            }
        }
    }

    public void onDraw(ICustomMessageViewGroup parent, CustomMessage data) {
        // 把自定义消息view添加到TUIKit内部的父容器里
        View view = LayoutInflater.from(DemoApplication.instance()).inflate(R.layout.test_custom_message_av_layout1, null, false);
        parent.addMessageContentView(view);

        if (data == null) {
            DemoLog.i(TAG, "onCalling null data");
            return;
        }
        TextView textView = view.findViewById(R.id.test_custom_message_tv);

        String callingAction = "";
        switch (data.action) {
            // 新接一个电话
            case VIDEO_CALL_ACTION_DIALING:
                callingAction = "[请求通话]";
                break;
            case VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                callingAction = "[取消通话]";
                break;
            case VIDEO_CALL_ACTION_REJECT:
                callingAction = "[拒绝通话]";
                break;
            case VIDEO_CALL_ACTION_SPONSOR_TIMEOUT:
                callingAction = "[无应答]";
                break;
            case VIDEO_CALL_ACTION_ACCEPTED:
                callingAction = "[开始通话]";
                break;
            case VIDEO_CALL_ACTION_HANGUP:
                callingAction = "[结束通话，通话时长：" + DateTimeUtil.formatSeconds(data.duration) + "]";
                break;
            case VIDEO_CALL_ACTION_LINE_BUSY:
                callingAction = "[正在通话中]";
                break;
            default:
                DemoLog.e(TAG, "unknown data.action: " + data.action);
                callingAction = "[不能识别的通话指令]";
                break;
        }
        textView.setText(callingAction);
    }

    public void createVideoCallRequest() {
        // 显示通话UI
        boolean success = showOutgoingDialingDialog();
        if (success) {
            mCurrentVideoCallStatus = VIDEO_CALL_STATUS_BUSY;
            assembleOnlineCall(null);
            sendVideoCallAction(VIDEO_CALL_ACTION_DIALING, mOnlineCall);
            mHandler.removeCallbacksAndMessages(null);
            mHandler.postDelayed(mVideoCallOutgoingTimeOut, VIDEO_CALL_OUT_GOING_TIME_OUT);
        } else {
            Toast.makeText(mUISender.getContext(), "发起通话失败，没有弹出对话框权限", Toast.LENGTH_SHORT).show();
        }
    }

    public void hangup() {
        DemoLog.i(TAG, "hangup");
        mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
        sendVideoCallAction(VIDEO_CALL_ACTION_HANGUP, mOnlineCall);
    }

    private void enterRoom() {
        final Intent intent = new Intent(mUISender.getContext(), TRTCActivity.class);
        intent.putExtra(TRTCActivity.KEY_ROOM_ID, mOnlineCall.room_id);
        mUISender.getContext().startActivity(intent);
    }

    public void sendVideoCallAction(int action, CustomMessage roomInfo) {
        DemoLog.i(TAG, "sendVideoCallAction action: " + action
                + " call_id: " + roomInfo.call_id
                + " room_id: " + roomInfo.room_id
                + " partner: " + roomInfo.getPartner());
        Gson gson = new Gson();
        CustomMessage message = new CustomMessage();
        message.version = JSON_VERSION_3_ANDROID_IOS_TRTC;
        message.call_id = roomInfo.call_id;
        message.room_id = roomInfo.room_id;
        message.action = action;
        message.invited_list = roomInfo.invited_list;
        if (action == VIDEO_CALL_ACTION_HANGUP) {
            message.duration = (int) (System.currentTimeMillis() - mEnterRoomTime + 500) / 1000;
        }
        String data = gson.toJson(message);
        MessageInfo info = MessageInfoUtil.buildCustomMessage(data);
        if (TextUtils.equals(mOnlineCall.getPartner(), roomInfo.getPartner())) {
            mUISender.sendMessage(info, false);
        } else {
            TIMConversation con = TIMManager.getInstance().getConversation(TIMConversationType.C2C, roomInfo.getPartner());
            con.sendMessage(info.getTIMMessage(), new TIMValueCallBack<TIMMessage>() {

                @Override
                public void onError(int code, String desc) {
                    DemoLog.i(TAG, "sendMessage fail:" + code + "=" + desc);
                }

                @Override
                public void onSuccess(TIMMessage timMessage) {
                    TUIKitLog.i(TAG, "sendMessage onSuccess");
                }
            });
        }
    }

    private String createCallID() {
        final String CHARS = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789";
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        sb.append(GenerateTestUserSig.SDKAPPID).append("-").append(TIMManager.getInstance().getLoginUser()).append("-");
        for (int i = 0; i < 32; i++) {
            int index = random.nextInt(CHARS.length());
            sb.append(CHARS.charAt(index));
        }
        return sb.toString();
    }

    private void assembleOnlineCall(CustomMessage roomInfo) {
        mOnlineCall = new CustomMessage();
        if (roomInfo == null) {
            mOnlineCall.call_id = createCallID();
            mOnlineCall.room_id = new Random().nextInt();
            mOnlineCall.invited_list = new String[] {mUISender.getChatInfo().getId()};
            mOnlineCall.setPartner(mUISender.getChatInfo().getId());
        } else {
            mOnlineCall.call_id = roomInfo.call_id;
            mOnlineCall.room_id = roomInfo.room_id;
            mOnlineCall.invited_list = roomInfo.invited_list;
            mOnlineCall.setPartner(roomInfo.getPartner());
        }
    }

    public void onNewMessage(List<TIMMessage> msgs) {
        CustomMessage data = CustomMessage.convert2VideoCallData(msgs);
        if (data != null) {
            onNewComingCall(data);
        }
    }

    private void onNewComingCall(CustomMessage message) {
        DemoLog.i(TAG, "onNewComingCall current state: " + mCurrentVideoCallStatus
                + " call_id action: " + message.action
                + " coming call_id: " + message.call_id
                + " coming room_id: " + message.room_id
                + " current room_id: " + (mOnlineCall == null ? null : mOnlineCall.room_id));
        switch (message.action) {
            case VIDEO_CALL_ACTION_DIALING:
                if (mCurrentVideoCallStatus == VIDEO_CALL_STATUS_FREE) {
                    mCurrentVideoCallStatus = VIDEO_CALL_STATUS_WAITING;
                    startC2CConversation(message);
                    assembleOnlineCall(message);
                } else {
                    sendVideoCallAction(VIDEO_CALL_ACTION_LINE_BUSY, message);
                }
                break;
            case VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                if (mCurrentVideoCallStatus != VIDEO_CALL_STATUS_FREE && TextUtils.equals(message.call_id, mOnlineCall.call_id)) {
                    dismissDialog();
                    mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
                }
                break;
            case VIDEO_CALL_ACTION_REJECT:
                if (mCurrentVideoCallStatus != VIDEO_CALL_STATUS_FREE && TextUtils.equals(message.call_id, mOnlineCall.call_id)) {
                    dismissDialog();
                    mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
                }
                break;
            case VIDEO_CALL_ACTION_SPONSOR_TIMEOUT:
                if (mCurrentVideoCallStatus != VIDEO_CALL_STATUS_FREE && TextUtils.equals(message.call_id, mOnlineCall.call_id)) {
                    dismissDialog();
                    mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
                }
                break;
            case VIDEO_CALL_ACTION_ACCEPTED:
                if (mCurrentVideoCallStatus != VIDEO_CALL_STATUS_FREE && TextUtils.equals(message.call_id, mOnlineCall.call_id)) {
                    dismissDialog();
                }
                assembleOnlineCall(message);
                enterRoom();
                break;
            case VIDEO_CALL_ACTION_HANGUP:
                dismissDialog();
                mTRTCCloud.exitRoom();
                mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
                break;
            case VIDEO_CALL_ACTION_LINE_BUSY:
                if (mCurrentVideoCallStatus == VIDEO_CALL_STATUS_BUSY && TextUtils.equals(message.call_id, mOnlineCall.call_id)) {
                    dismissDialog();
                }
                break;
            default:
                DemoLog.e(TAG, "unknown data.action: " + message.action);
                break;
        }
    }

    private void startC2CConversation(CustomMessage message) {
        // 小米手机需要在安全中心里面把demo的"后台弹出权限"打开，才能当应用退到后台时弹出通话请求对话框。
        DemoLog.i(TAG, "startC2CConversation " + message.getPartner());
        ChatInfo chatInfo = new ChatInfo();
        chatInfo.setType(TIMConversationType.C2C);
        chatInfo.setId(message.getPartner());
        chatInfo.setChatName(message.getPartner());
        Intent intent = new Intent(DemoApplication.instance(), ChatActivity.class);
        intent.putExtra(Constants.CHAT_INFO, chatInfo);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        DemoApplication.instance().startActivity(intent);
    }

    private boolean showIncomingDialingDialog() {
        dismissDialog();
        mHandler.removeCallbacksAndMessages(null);
        mHandler.postDelayed(mVideoCallIncomingTimeOut, VIDEO_CALL_OUT_INCOMING_TIME_OUT);
        mDialog = new TRTCDialog(mUISender.getContext());
        mDialog.setTitle("来电话了");
        mDialog.setPositiveButton("接听", new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DemoLog.i(TAG, "VIDEO_CALL_ACTION_ACCEPTED");
                mHandler.removeCallbacksAndMessages(null);
                sendVideoCallAction(VIDEO_CALL_ACTION_ACCEPTED, mOnlineCall);
                mCurrentVideoCallStatus = VIDEO_CALL_STATUS_BUSY;
                enterRoom();
            }
        });
        mDialog.setNegativeButton("拒绝", new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DemoLog.i(TAG, "VIDEO_CALL_ACTION_REJECT");
                mHandler.removeCallbacksAndMessages(null);
                mCurrentVideoCallStatus = VIDEO_CALL_STATUS_FREE;
                sendVideoCallAction(VIDEO_CALL_ACTION_REJECT, mOnlineCall);
            }
        });
        return mDialog.showSystemDialog();
    }

    private boolean showOutgoingDialingDialog() {
        dismissDialog();
        mDialog = new TRTCDialog(mUISender.getContext());
        mDialog.setTitle("等待对方接听");
        mDialog.setPositiveButton("取消", new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DemoLog.i(TAG, "VIDEO_CALL_ACTION_SPONSOR_CANCEL");
                mHandler.removeCallbacksAndMessages(null);
                sendVideoCallAction(VIDEO_CALL_ACTION_SPONSOR_CANCEL, mOnlineCall);
            }
        });
        return mDialog.showSystemDialog();
    }

    private void dismissDialog() {
        mHandler.removeCallbacksAndMessages(null);
        if (mDialog != null) {
            mDialog.dismiss();
        }
    }

}
