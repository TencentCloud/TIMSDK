package com.tencent.qcloud.tuikit.tuichat.bean;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CallModel implements Cloneable, Serializable {

    private static final String TAG = CallModel.class.getSimpleName();

    /**
     * 系统错误
     * 
     * system error
     */
    public static final int VIDEO_CALL_ACTION_ERROR           = -1;
    /**
     * 未知信令
     * 
     * unknown signaling
     */
    public static final int VIDEO_CALL_ACTION_UNKNOWN         = 0;
    /**
     * 正在呼叫
     * 
     * calling
     */
    public static final int VIDEO_CALL_ACTION_DIALING         = 1;
    /**
     * 发起人取消
     * 
     * initiator cancellation
     */
    public static final int VIDEO_CALL_ACTION_SPONSOR_CANCEL  = 2;
    /**
     * 拒接电话
     * 
     * reject the call
     */
    public static final int VIDEO_CALL_ACTION_REJECT          = 3;
    /**
     * 无人接听
     * 
     * no one heard
     */
    public static final int VIDEO_CALL_ACTION_SPONSOR_TIMEOUT = 4;
    /**
     * 挂断
     * 
     * hang up
     */
    public static final int VIDEO_CALL_ACTION_HANGUP          = 5;
    /**
     * 电话占线
     * 
     * phone busy
     */
    public static final int VIDEO_CALL_ACTION_LINE_BUSY       = 6;
    /**
     * 接听电话
     * 
     * answer the phone
     */
    public static final int VIDEO_CALL_ACTION_ACCEPT          = 7;

    public static final int VIDEO_CALL_ACTION_SWITCH_TO_AUDIO = 8;

    public static final int VIDEO_CALL_ACTION_SWITCH_TO_AUDIO_ACCEPT = 9;

    public static final int VIDEO_CALL_ACTION_UNKNOWN_INVITE = 10;

    public static String SIGNALING_EXTRA_VALUE_BUSINESS_ID = "av_call";

    public static String SIGNALING_EXTRA_KEY_BUSINESS_ID = "businessID";
    public static String SIGNALING_EXTRA_KEY_CALL_TYPE   = "call_type";
    public static String SIGNALING_EXTRA_KEY_ROOM_ID     = "room_id";
    public static String SIGNALING_EXTRA_KEY_LINE_BUSY   = "line_busy";
    public static String SIGNALING_EXTRA_KEY_CALL_END    = "call_end";
    public static String SIGNALING_EXTRA_KEY_VERSION     = "version";

    @SerializedName("businessID")
    public String bussinessID;

    @SerializedName("version")
    public int version = 0;

    /**
     * 表示一次通话的唯一ID
     * 
     * call ID
     */
    @SerializedName("call_id")
    public String callId;

    /**
     * TRTC的房间号
     * 
     * room ID
     */
    @SerializedName("room_id")
    public int roomId  = 0;

    /**
     * IM的群组id，在群组内发起通话时使用
     * 
     * group ID
     */
    @SerializedName("group_id")
    public String groupId = "";

    /**
     * 信令动作
     * 
     * signaling action
     */
    @SerializedName("action")
    public int action = VIDEO_CALL_ACTION_UNKNOWN;

    /**
     * 通话类型
     * 0-未知
     * 1-语音通话
     * 2-视频通话
     * 
     * call type
     * 0-unkown
     * 1-audio call
     * 2-video call
     */
    @SerializedName("call_type")
    public int callType = 0;

    /**
     * 正在邀请的列表
     * 
     * Inviting list
     */
    @SerializedName("invited_list")
    public List<String> invitedList;

    @SerializedName("duration")
    public int duration = 0;

    @SerializedName("code")
    public int code = 0;

    public long timestamp;
    public String sender;
    // 超时时间，单位秒
    // seconds
    public int timeout;
    public String data;

    public static CallModel convert2VideoCallData(V2TIMMessage msg) {
        V2TIMSignalingInfo signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msg);
        if (signalingInfo == null) {
            return null;
        }
        Gson gson = new Gson();
        CallModel callModel = new CallModel();
        try {
            Map extraMap = gson.fromJson(signalingInfo.getData(), Map.class);
            if (extraMap != null
                    && extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_VERSION)
                    && ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue() > TUIChatConstants.version) {
                callModel.action = CallModel.VIDEO_CALL_ACTION_UNKNOWN;
                return callModel;
            }
            callModel.data = signalingInfo.getData();
            if (extraMap != null) {
                callModel.callType = ((Double)extraMap.get(TUIConstants.Message.CALLING_TYPE_KEY)).intValue();
                callModel.bussinessID = (String) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_BUSINESS_ID);
            }
            if (signalingInfo.getActionType() == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_INVITE && extraMap != null) {
                handleInvite(msg, signalingInfo, gson, callModel, extraMap);
            } else if (signalingInfo.getActionType() == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_CANCEL_INVITE) {
                callModel.action = CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL;
                callModel.groupId = signalingInfo.getGroupID();
                callModel.callId = signalingInfo.getInviteID();
                callModel.version = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
            } else if (signalingInfo.getActionType() == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_REJECT_INVITE && extraMap != null) {
                callModel.groupId = signalingInfo.getGroupID();
                callModel.callId = signalingInfo.getInviteID();
                callModel.invitedList = signalingInfo.getInviteeList();
                callModel.version = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
                if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY)) {
                    callModel.action = CallModel.VIDEO_CALL_ACTION_LINE_BUSY;
                } else {
                    callModel.action = CallModel.VIDEO_CALL_ACTION_REJECT;
                }
            } else if (signalingInfo.getActionType() == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_INVITE_TIMEOUT) {
                callModel.action = CallModel.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT;
                callModel.groupId = signalingInfo.getGroupID();
                callModel.callId = signalingInfo.getInviteID();
                callModel.invitedList = signalingInfo.getInviteeList();
            } else if (signalingInfo.getActionType() == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_ACCEPT_INVITE) {
                handleAccept(signalingInfo, callModel, extraMap);
            }

        } catch (Exception e) {
            TUIChatLog.e(TAG, "convert2VideoCallData exception:" + e);
        }
        return callModel;
    }

    private static void handleAccept(V2TIMSignalingInfo signalingInfo, CallModel callModel, Map extraMap) {
        callModel.groupId = signalingInfo.getGroupID();
        callModel.callId = signalingInfo.getInviteID();
        callModel.invitedList = signalingInfo.getInviteeList();
        callModel.version = ((Double) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
        callModel.callType = ((Double)extraMap.get(TUIConstants.Message.CALLING_TYPE_KEY)).intValue();

        Map contentDataMap = (Map) extraMap.get("data");
        if (contentDataMap != null) {
            // new version
            if (!contentDataMap.containsKey("cmd")) {
                callModel.action = VIDEO_CALL_ACTION_UNKNOWN_INVITE;
            } else {
                String cmd = (String) contentDataMap.get("cmd");
                if (TextUtils.equals(cmd, "switchToAudio")) {
                    callModel.action = VIDEO_CALL_ACTION_SWITCH_TO_AUDIO_ACCEPT;
                    callModel.callType = CallingMessageBean.ACTION_ID_VIDEO_CALL;
                } else {
                    callModel.action = VIDEO_CALL_ACTION_ACCEPT;
                }
            }
        } else {
            // old version
            callModel.action = CallModel.VIDEO_CALL_ACTION_ACCEPT;
        }
    }

    private static void handleInvite(V2TIMMessage msg, V2TIMSignalingInfo signalingInfo, Gson gson, CallModel callModel, Map extraMap) {
        callModel.groupId = signalingInfo.getGroupID();
        callModel.timestamp = msg.getTimestamp();
        callModel.version = ((Double) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
        Map contentDataMap = (Map) extraMap.get("data");
        if (contentDataMap != null) {
            // new version
            if (!contentDataMap.containsKey("cmd")) {
                callModel.action = VIDEO_CALL_ACTION_UNKNOWN_INVITE;
            } else {
                String cmd = (String) contentDataMap.get("cmd");
                if (TextUtils.equals(cmd, "switchToAudio")) {
                    callModel.action = VIDEO_CALL_ACTION_SWITCH_TO_AUDIO;
                } else if (TextUtils.equals(cmd, "hangup")) {
                    callModel.action = CallModel.VIDEO_CALL_ACTION_HANGUP;
                    callModel.duration = Double.valueOf(String.valueOf(extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_END))).intValue();
                } else if (TextUtils.equals(cmd, "videoCall") || TextUtils.equals(cmd, "audioCall")) {
                    callModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
                    callModel.callId = signalingInfo.getInviteID();
                    callModel.sender = signalingInfo.getInviter();
                    callModel.invitedList = signalingInfo.getInviteeList();
                    callModel.callType = TextUtils.equals(cmd, "audioCall") ? 1 : 2;
                    callModel.roomId = ((Double) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID)).intValue();
                } else {
                    callModel.action = VIDEO_CALL_ACTION_UNKNOWN_INVITE;
                }
            }
        } else {
            // old version
            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_CALL_END)) {
                callModel.action = CallModel.VIDEO_CALL_ACTION_HANGUP;
                callModel.duration = Double.valueOf(String.valueOf(extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_END))).intValue();
            } else {
                callModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
                callModel.callId = signalingInfo.getInviteID();
                callModel.sender = signalingInfo.getInviter();
                callModel.invitedList = signalingInfo.getInviteeList();
                callModel.callType = ((Double) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE)).intValue();
                callModel.roomId = ((Double) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID)).intValue();
            }
        }
    }
}