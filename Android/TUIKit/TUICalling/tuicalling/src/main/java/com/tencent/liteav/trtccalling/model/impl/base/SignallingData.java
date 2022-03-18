package com.tencent.liteav.trtccalling.model.impl.base;

import java.util.List;

public class SignallingData {
    private int      version;
    private String   businessID;
    private String   platform;
    private String   extInfo;
    private DataInfo data;
    //多人通话custom message增加字段
    private int      call_action;
    private String   callid;
    private String   user;

    public int getCallAction() {
        return call_action;
    }

    public void setCallAction(int call_action) {
        this.call_action = call_action;
    }

    public String getCallid() {
        return callid;
    }

    public void setcallid(String callid) {
        this.callid = callid;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    //兼容老版本字段，待废弃字段
    private int    call_type;
    private int    room_id;
    private int    call_end;
    private String switch_to_audio_call;
    private String line_busy;

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public String getBusinessID() {
        return businessID;
    }

    public void setBusinessID(String businessID) {
        this.businessID = businessID;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public int getCallType() {
        return call_type;
    }

    public void setCallType(int callType) {
        this.call_type = callType;
    }

    public int getRoomId() {
        return room_id;
    }

    public void setRoomId(int roomId) {
        this.room_id = roomId;
    }

    public int getCallEnd() {
        return call_end;
    }

    public void setCallEnd(int callEnd) {
        this.call_end = callEnd;
    }

    public String getSwitchToAudioCall() {
        return switch_to_audio_call;
    }

    public void setSwitchToAudioCall(String switchToAudioCall) {
        this.switch_to_audio_call = switchToAudioCall;
    }

    public String getLineBusy() {
        return line_busy;
    }

    public void setLineBusy(String lineBusy) {
        this.line_busy = lineBusy;
    }

    public DataInfo getData() {
        return data;
    }

    public void setData(DataInfo data) {
        this.data = data;
    }

    public static class DataInfo {
        private int          room_id;
        private String       cmd;
        private String       cmdInfo;
        private String       message;
        private List<String> userIDs;

        public int getRoomID() {
            return room_id;
        }

        public void setRoomID(int roomID) {
            this.room_id = roomID;
        }

        public String getCmd() {
            return cmd;
        }

        public void setCmd(String cmd) {
            this.cmd = cmd;
        }

        public String getCmdInfo() {
            return cmdInfo;
        }

        public void setCmdInfo(String cmdInfo) {
            this.cmdInfo = cmdInfo;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public List<String> getUserIDs() {
            return userIDs;
        }

        public void setUserIDs(List<String> userIDs) {
            this.userIDs = userIDs;
        }
    }
}
