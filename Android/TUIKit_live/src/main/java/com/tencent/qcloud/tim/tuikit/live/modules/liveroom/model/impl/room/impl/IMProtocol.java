package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl;

import android.text.TextUtils;
import android.util.Pair;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl.IMProtocol.Define.KEY_BUSINESS_ID;
import static com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl.IMProtocol.Define.VALUE_BUSINESS_ID;
import static com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl.IMProtocol.Define.VALUE_PROTOCOL_VERSION;

public class IMProtocol {

    public static class Define {
        public static final String KEY_VERSION            = "version";
        public static final String KEY_ACTION             = "action";
        public static final String KEY_BUSINESS_ID        = "businessID";
        public static final String VALUE_PROTOCOL_VERSION = "1.0.0";
        public static final String VALUE_BUSINESS_ID      = "av_live";

        public static final int CODE_UNKNOWN                       = 0;
        public static final int CODE_REQUEST_JOIN_ANCHOR           = 100;
        public static final int CODE_RESPONSE_JOIN_ANCHOR          = 101;
        public static final int CODE_KICK_OUT_JOIN_ANCHOR          = 102;
        public static final int CODE_RESPONSE_KICK_OUT_JOIN_ANCHOR = 103;
        public static final int CODE_CANCEL_REQUEST_JOIN_ANCHOR    = 104;
        public static final int CODE_NOTIFY_JOIN_ANCHOR_STREAM     = 105;

        public static final int CODE_REQUEST_ROOM_PK        = 200;
        public static final int CODE_RESPONSE_PK            = 201;
        public static final int CODE_QUIT_ROOM_PK           = 202;
        public static final int CODE_RESPONSE_QUIT_ROOM_PK  = 203;
        public static final int CODE_CANCEL_REQUEST_ROOM_PK = 204;


        public static final int CODE_ROOM_TEXT_MSG   = 300;
        public static final int CODE_ROOM_CUSTOM_MSG = 301;

        public static final int CODE_UPDATE_GROUP_INFO = 400;
    }

    public static boolean isLiveRoomSignal(String data) {
        try {
            JSONObject object     = new JSONObject(data);
            String     businessId = object.getString(KEY_BUSINESS_ID);
            return VALUE_BUSINESS_ID.equals(businessId);
        } catch (Exception e) {
        }
        return false;
    }

    public static String getJoinReqJsonStr(String reason) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_REQUEST_JOIN_ANCHOR);
            jsonObject.put("reason", reason);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getCancelReqJsonStr(String reason) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_CANCEL_REQUEST_JOIN_ANCHOR);
            jsonObject.put("reason", reason);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String parseJoinReqReason(JSONObject jsonStr) {
        String reason = jsonStr.optString("reason");
        return reason;
    }

    public static String getJoinRspJsonStr(String reason) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_RESPONSE_JOIN_ANCHOR);
            jsonObject.put("reason", reason);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    /**
     * 返回值：reason
     *
     * @param jsonObject
     * @return
     */
    public static String parseJoinRspResult(JSONObject jsonObject) {
        String reason = jsonObject.optString("reason");
        return reason;
    }

    public static String getKickOutJoinJsonStr() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_KICK_OUT_JOIN_ANCHOR);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getResponseKickOutJoinJsonStr() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_RESPONSE_KICK_OUT_JOIN_ANCHOR);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getPKReqJsonStr(String myRoomId, String myStreamId) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_REQUEST_ROOM_PK);
            jsonObject.put("from_room_id", myRoomId);
            jsonObject.put("from_stream_id", myStreamId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getPKCancelJsonStr(String myRoomId, String myStreamId) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_CANCEL_REQUEST_ROOM_PK);
            jsonObject.put("from_room_id", myRoomId);
            jsonObject.put("from_stream_id", myStreamId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    /**
     * 解析PK请求，返回值：from_room_id、from_stream_id
     *
     * @param jsonObject
     * @return
     */
    public static Pair<String, String> parsePKReq(JSONObject jsonObject) {
        String roomId   = jsonObject.optString("from_room_id");
        String streamId = jsonObject.optString("from_stream_id");
        return new Pair<>(roomId, streamId);
    }

    public static String getPKRspJsonStr(String reason, String myStreamId) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_RESPONSE_PK);
            jsonObject.put("reason", reason);
            jsonObject.put("stream_id", myStreamId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    /**
     * 返回值：accept、reason、streamId
     *
     * @param jsonObject
     * @return
     */
    public static Pair<String, String> parsePKRsp(JSONObject jsonObject) {
        try {
            String reason   = jsonObject.optString("reason");
            String streamId = jsonObject.optString("stream_id");
            return new Pair<String, String>(reason, streamId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String getQuitPKJsonStr() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_QUIT_ROOM_PK);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getRoomTextMsgHeadJsonStr() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_ROOM_TEXT_MSG);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getCusMsgJsonStr(String cmd, String msg) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_ROOM_CUSTOM_MSG);
            jsonObject.put("command", cmd);
            jsonObject.put("message", msg);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static Pair<String, String> parseCusMsg(JSONObject jsonObject) {
        String cmd     = jsonObject.optString("command");
        String message = jsonObject.optString("message");
        return new Pair<>(cmd, message);
    }

    public static String getNotifyStreamJsonStr(String streamId) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_NOTIFY_JOIN_ANCHOR_STREAM);
            jsonObject.put("stream_id", streamId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getCommonAccept(String reason) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put("reason", reason);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getUpdateGroupInfoJsonStr(int type, List<IMAnchorInfo> list) {
        try {
            JSONObject jsonObject = new JSONObject(getGroupInfoJsonStr(type, list));
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(KEY_BUSINESS_ID, VALUE_BUSINESS_ID);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_UPDATE_GROUP_INFO);
            return jsonObject.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String getGroupInfoJsonStr(int type, List<IMAnchorInfo> list) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("type", type);
            JSONArray jsonArray = new JSONArray();
            for (IMAnchorInfo info : list) {
                JSONObject jInfo = new JSONObject();
                jInfo.put("userId", info.userId);
                jInfo.put("streamId", info.streamId);
                jInfo.put("name", info.name);
                //                jInfo.put("avatar", info.avatar);
                jsonArray.put(jInfo);
            }
            jsonObject.put("list", jsonArray);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static Pair<Integer, List<IMAnchorInfo>> parseGroupInfo(String jsonStr) {
        if (TextUtils.isEmpty(jsonStr)) return null;
        try {
            JSONObject jsonObject = new JSONObject(jsonStr);
            int        type       = jsonObject.getInt("type");

            List<IMAnchorInfo> list      = new ArrayList<>();
            JSONArray          jsonArray = jsonObject.getJSONArray("list");
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jObj = jsonArray.getJSONObject(i);
                String     uid  = jObj.optString("userId");
                String     sid  = jObj.optString("streamId");
                String     name = jObj.optString("name");
                //                String avatar = jObj.optString("avatar");

                IMAnchorInfo info = new IMAnchorInfo();
                info.userId = uid;
                info.streamId = sid;
                info.name = name;
                //                info.avatar = avatar;

                list.add(info);
            }
            Pair<Integer, List<IMAnchorInfo>> pair = new Pair<>(type, list);
            return pair;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }
}
