package com.tencent.liteav.model;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import org.json.JSONObject;

import java.io.Serializable;
import java.util.Map;

/**
 * 自定义直播消息的bean实体，用来与json的相互转化
 */
public class LiveModel implements Cloneable, Serializable {
    private static final String TAG = LiveModel.class.getSimpleName();

    public static final String KEY_VERSION = "version";
    public static final String KEY_ACTION = "action";
    public static final String KEY_BUSINESS_ID = "businessID";
    public static final String VALUE_PROTOCOL_VERSION = "1.0.0";
    public static final String VALUE_BUSINESS_ID = "liveRoom";

    public static final int CODE_UNKNOWN = 0;
    public static final int CODE_REQUEST_JOIN_ANCHOR = 100;
    public static final int CODE_RESPONSE_JOIN_ANCHOR = 101;
    public static final int CODE_KICK_OUT_JOIN_ANCHOR = 102;
    public static final int CODE_RESPONSE_KICK_OUT_JOIN_ANCHOR = 103;
    public static final int CODE_CANCEL_REQUEST_JOIN_ANCHOR = 104;
    public static final int CODE_NOTIFY_JOIN_ANCHOR_STREAM = 105;

    public static final int CODE_REQUEST_ROOM_PK = 200;
    public static final int CODE_RESPONSE_PK = 201;
    public static final int CODE_QUIT_ROOM_PK = 202;
    public static final int CODE_RESPONSE_QUIT_ROOM_PK = 203;
    public static final int CODE_CANCEL_REQUEST_ROOM_PK = 204;


    public static final int CODE_ROOM_TEXT_MSG = 300;
    public static final int CODE_ROOM_CUSTOM_MSG = 301;

    public static final int CODE_UPDATE_GROUP_INFO = 400;

    public int actionType;
    public String message;
    public String data;
    public String version;

    public static LiveModel convert2LiveData(V2TIMMessage msg) {
        V2TIMSignalingInfo signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msg);
        if (signalingInfo == null) {
            return null;
        }
        LiveModel liveModel = new LiveModel();
        liveModel.message = TUIKit.getAppContext().getString(R.string.invalid_command);
        try {
            Map<String, Object> extraMap = new Gson().fromJson(signalingInfo.getData(), Map.class);
            liveModel.data = signalingInfo.getData();
            liveModel.version = ((String) extraMap.get(LiveModel.KEY_VERSION));
            int code = (((Double) extraMap.get(LiveModel.KEY_ACTION)).intValue());
            int actionType = signalingInfo.getActionType();
            liveModel.actionType = actionType;
            switch (code) {
                case CODE_REQUEST_JOIN_ANCHOR:
                    liveModel.message = TUIKit.getAppContext().getString(R.string.request_online);
                    break;
                case CODE_RESPONSE_JOIN_ANCHOR:
                    if (actionType == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_REJECT_INVITE) {
                        liveModel.message = TUIKit.getAppContext().getString(R.string.reject_request_online);
                    } else if (actionType == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_ACCEPT_INVITE) {
                        liveModel.message = TUIKit.getAppContext().getString(R.string.agree_request_online);
                    }
                    break;
                case CODE_KICK_OUT_JOIN_ANCHOR:
                    liveModel.message = TUIKit.getAppContext().getString(R.string.request_close_online);
                    break;
                case CODE_RESPONSE_KICK_OUT_JOIN_ANCHOR:
                    liveModel.message = TUIKit.getAppContext().getString(R.string.close_online);
                    break;
                case CODE_REQUEST_ROOM_PK:
                    if (actionType == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_INVITE) {
                        liveModel.message = TUIKit.getAppContext().getString(R.string.request_pk);
                    }
                    break;
                case CODE_RESPONSE_PK:
                    if (actionType == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_REJECT_INVITE) {
                        liveModel.message = TUIKit.getAppContext().getString(R.string.reject_request_pk);
                    } else if (actionType == V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_ACCEPT_INVITE) {
                        liveModel.message = TUIKit.getAppContext().getString(R.string.agree_request_pk);
                    }
                    break;
                case CODE_QUIT_ROOM_PK:
                    liveModel.message = TUIKit.getAppContext().getString(R.string.exit_pk);
                    break;
            }
        } catch (Exception e) {
            TUIKitLog.e(TAG, "convert2LiveData exception:" + e);
        }
        return liveModel;
    }

    public static boolean isLiveRoomSignal(String data) {
        if (TextUtils.isEmpty(data)) {
            return false;
        }
        try {
            JSONObject object = new JSONObject(data);
            String businessId = object.getString(KEY_BUSINESS_ID);
            return VALUE_BUSINESS_ID.equals(businessId);
        } catch (Exception e) {
            TUIKitLog.e(TAG, "isLiveRoomSignal exception:" + e);
        }
        return false;
    }

}