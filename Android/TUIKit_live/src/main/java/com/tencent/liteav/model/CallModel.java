package com.tencent.liteav.model;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 自定义消息的bean实体，用来与json的相互转化
 */
public class CallModel implements Cloneable, Serializable {

    private static final String TAG = CallModel.class.getSimpleName();

    /**
     * 系统错误
     */
    public static final int VIDEO_CALL_ACTION_ERROR           = -1;
    /**
     * 未知信令
     */
    public static final int VIDEO_CALL_ACTION_UNKNOWN         = 0;
    /**
     * 正在呼叫
     */
    public static final int VIDEO_CALL_ACTION_DIALING         = 1;
    /**
     * 发起人取消
     */
    public static final int VIDEO_CALL_ACTION_SPONSOR_CANCEL  = 2;
    /**
     * 拒接电话
     */
    public static final int VIDEO_CALL_ACTION_REJECT          = 3;
    /**
     * 无人接听
     */
    public static final int VIDEO_CALL_ACTION_SPONSOR_TIMEOUT = 4;
    /**
     * 挂断
     */
    public static final int VIDEO_CALL_ACTION_HANGUP          = 5;
    /**
     * 电话占线
     */
    public static final int VIDEO_CALL_ACTION_LINE_BUSY       = 6;
    /**
     * 接听电话
     */
    public static final int VIDEO_CALL_ACTION_ACCEPT          = 7;

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
     */
    @SerializedName("call_id")
    public String callId;

    /**
     * TRTC的房间号
     */
    @SerializedName("room_id")
    public int roomId  = 0;

    /**
     * IM的群组id，在群组内发起通话时使用
     */
    @SerializedName("group_id")
    public String groupId = "";

    /**
     * 信令动作
     */
    @SerializedName("action")
    public int action = VIDEO_CALL_ACTION_UNKNOWN;

    /**
     * 通话类型
     * 0-未知
     * 1-语音通话
     * 2-视频通话
     */
    @SerializedName("call_type")
    public int callType = 0;

    /**
     * 正在邀请的列表
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
    public int timeout;
    public String data;

    @Override
    public Object clone() {
        CallModel callModel = null;
        try {
            callModel = (CallModel) super.clone();
            if (invitedList != null) {
                callModel.invitedList = new ArrayList<>(invitedList);
            }
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
            TUIKitLog.w(TAG, "clone: " + e.getLocalizedMessage());
        }
        return callModel;
    }

    public static CallModel convert2VideoCallData(V2TIMMessage msg) {
        V2TIMSignalingInfo signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msg);
        if (signalingInfo == null) {
            return null;
        }
        CallModel callModel = new CallModel();
        try {
            Map<String, Object> extraMap = new Gson().fromJson(signalingInfo.getData(), Map.class);
            if (extraMap != null
                    && extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_VERSION)
                    && ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue() > TUIKitConstants.version) {
                callModel.action = CallModel.VIDEO_CALL_ACTION_UNKNOWN;
                return callModel;
            }
            callModel.data = signalingInfo.getData();
            if (extraMap != null) {
                callModel.bussinessID = (String) extraMap.get(CallModel.SIGNALING_EXTRA_KEY_BUSINESS_ID);
            }
            if (signalingInfo.getActionType() == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_INVITE && extraMap != null) {
                callModel.groupId = signalingInfo.getGroupID();
                callModel.timestamp = msg.getTimestamp();
                callModel.version = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
                if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_CALL_END)) {
                    callModel.action = CallModel.VIDEO_CALL_ACTION_HANGUP;
                    callModel.duration = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_END)).intValue();
                } else {
                    callModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
                    callModel.callId = signalingInfo.getInviteID();
                    callModel.sender = signalingInfo.getInviter();
                    callModel.invitedList = signalingInfo.getInviteeList();
                    callModel.callType = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE)).intValue();
                    callModel.roomId = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID)).intValue();
                }
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
                callModel.action = CallModel.VIDEO_CALL_ACTION_ACCEPT;
                callModel.groupId = signalingInfo.getGroupID();
                callModel.callId = signalingInfo.getInviteID();
                callModel.invitedList = signalingInfo.getInviteeList();
                callModel.version = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
            }
        } catch (Exception e) {
            TUIKitLog.e(TAG, "convert2VideoCallData exception:" + e);
        }
        return callModel;
    }

    @Override
    public String toString() {
        return "CallModel{" +
                "version=" + version +
                ", callId='" + callId + '\'' +
                ", roomId=" + roomId +
                ", groupId='" + groupId + '\'' +
                ", action=" + action +
                ", callType=" + callType +
                ", invitedList=" + invitedList +
                ", duration=" + duration +
                ", code=" + code +
                ", timestamp=" + timestamp +
                ", sender=" + sender +
                '}';
    }
}