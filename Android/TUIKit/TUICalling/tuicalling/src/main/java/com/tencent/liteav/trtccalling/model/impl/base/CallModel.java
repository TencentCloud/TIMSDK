package com.tencent.liteav.trtccalling.model.impl.base;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 自定义消息的bean实体，用来与json的相互转化
 */
public class CallModel implements Cloneable, Serializable {

    private static final String TAG = CallModel.class.getSimpleName();

    public static String KEY_VERSION     = "version";
    public static String KEY_PLATFORM    = "platform";
    public static String KEY_BUSINESS_ID = "businessID";
    public static String KEY_DATA        = "data";
    public static String KEY_ROOM_ID     = "room_id";
    public static String KEY_CMD         = "cmd";
    public static String KEY_USERIDS     = "userIDs";
    public static String KEY_MESSAGE     = "message";
    public static String KEY_CALLACTION  = "call_action";
    public static String KEY_CALLID      = "callid";
    public static String KEY_USER        = "user";

    public static final int    VALUE_VERSION             = 4;
    public static final String VALUE_BUSINESS_ID         = "av_call";           //calling场景
    public static final String VALUE_PLATFORM            = "Android";           //当前平台
    public static final String VALUE_CMD_VIDEO_CALL      = "videoCall";         //视频电话呼叫
    public static final String VALUE_CMD_AUDIO_CALL      = "audioCall";         //语音电话呼叫
    public static final String VALUE_CMD_HAND_UP         = "hangup";            //挂断
    public static final String VALUE_CMD_SWITCH_TO_AUDIO = "switchToAudio";     //切换为语音通话
    public static final String VALUE_MSG_LINE_BUSY       = "lineBusy";          //忙线
    public static final String VALUE_MSG_SYNC_INFO       = "sync_info";          //C2C多人通话,主叫向其他人同步信息

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

    /**
     * 切换语音通话
     */
    public static final int VIDEO_CALL_SWITCH_TO_AUDIO_CALL = 8;

    /**
     * 接受切换为语音通话
     */
    public static final int VIDEO_CALL_ACTION_ACCEPT_SWITCH_TO_AUDIO = 9;

    /**
     * 拒绝切换为语音通话
     */
    public static final int VIDEO_CALL_ACTION_REJECT_SWITCH_TO_AUDIO = 10;

    //兼容老版本字段，待废弃字段
    public static String SIGNALING_EXTRA_KEY_CALL_TYPE         = "call_type";
    public static String SIGNALING_EXTRA_KEY_ROOM_ID           = "room_id";
    public static String SIGNALING_EXTRA_KEY_LINE_BUSY         = "line_busy";
    public static String SIGNALING_EXTRA_KEY_CALL_END          = "call_end";
    public static String SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL = "switch_to_audio_call";

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
    public int roomId = 0;

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

    public long   timestamp;
    public String sender;
    // 超时时间，单位秒
    public int    timeout;
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
            TRTCLogger.w(TAG, "clone: " + e.getLocalizedMessage());
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