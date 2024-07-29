package com.tencent.qcloud.tuikit.tuichat.bean;

import android.content.Context;
import android.text.TextUtils;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CallModel implements Cloneable, Serializable {
    private static final String TAG = CallModel.class.getSimpleName();

    /**
     *
     * The protocol type of calls
     */
    public static final int CALL_PROTOCOL_TYPE_UNKNOWN = 0;
    public static final int CALL_PROTOCOL_TYPE_SEND = 1;
    public static final int CALL_PROTOCOL_TYPE_ACCEPT = 2;
    public static final int CALL_PROTOCOL_TYPE_REJECT = 3;
    public static final int CALL_PROTOCOL_TYPE_CANCEL = 4;
    public static final int CALL_PROTOCOL_TYPE_HANGUP = 5;
    public static final int CALL_PROTOCOL_TYPE_TIMEOUT = 6;
    public static final int CALL_PROTOCOL_TYPE_LINE_BUSY = 7;
    public static final int CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO = 8;
    public static final int CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO_COMFIRM = 9;

    /**
     *
     * The stream media type of calls
     */
    public static final int CALL_STREAM_MEDIA_TYPE_UNKNOWN = 0;
    public static final int CALL_STREAM_MEDIA_TYPE_VOICE = 1;
    public static final int CALL_STREAM_MEDIA_TYPE_VIDEO = 2;

    /**
     *
     * The participant style of calls
     */
    public static final int CALL_PARTICIPANT_TYPE_UNKNOWN = 0;
    public static final int CALL_PARTICIPANT_TYPE_C2C = 1;
    public static final int CALL_PARTICIPANT_TYPE_GROUP = 2;

    /**
     *
     * The role of participant
     */
    public static final int CALL_PARTICIPANT_ROLE_UNKNOWN = 0;
    public static final int CALL_PARTICIPANT_ROLE_CALLER = 1;
    public static final int CALL_PARTICIPANT_ROLE_CALLEE = 2;

    /**
     * The direction of voice-video-call message
     */
    public static final int CALL_MESSAGE_DIRECTION_INCOMING = 0;
    public static final int CALL_MESSAGE_DIRECTION_OUTGOING = 1;

    /**
     * The style of voice-video-call message in TUIChat
     */
    public static final int CHAT_CALLING_MESSAGE_APPEARANCE_DETAILS = 0;
    public static final int CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY = 1;
    public int style = CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY;

    private Map jsonData;

    public void setJsonData(Map jsonData) {
        this.jsonData = jsonData;
    }

    private V2TIMSignalingInfo signalingInfo;

    public void setSignalingInfo(V2TIMSignalingInfo signalingInfo) {
        this.signalingInfo = signalingInfo;
    }

    private V2TIMMessage innerMessage;

    public void setInnerMessage(V2TIMMessage innerMessage) {
        this.innerMessage = innerMessage;
    }

    private int protocolType = CALL_PROTOCOL_TYPE_UNKNOWN;

    private int streamMediaType = CALL_STREAM_MEDIA_TYPE_UNKNOWN;
    private int participantType = CALL_PARTICIPANT_TYPE_UNKNOWN;
    private int participantRole = CALL_PARTICIPANT_ROLE_UNKNOWN;
    private String caller = "";
    private Map<String, UserBean> participantsMap = new LinkedHashMap<>();
    private int duration = 0;

    public int getParticipantRole() {
        return participantRole;
    }

    public int getParticipantType() {
        return participantType;
    }

    public int getStreamMediaType() {
        return streamMediaType;
    }

    public int getProtocolType() {
        return protocolType;
    }

    public String getCaller() {
        return caller;
    }

    public void setParticipant(String userId, UserBean userBean) {
        if (participantsMap.containsKey(userId)) {
            participantsMap.put(userId, userBean);
        }
    }

    public static CallModel convert2VideoCallData(V2TIMMessage msg) {
        V2TIMSignalingInfo signalingInfo = V2TIMManager.getSignalingManager().getSignalingInfo(msg);
        if (signalingInfo == null) {
            return null;
        }
        String businessId = null;
        Double businessIdForTimeout = 0.0;
        Object businessIdObj = null;
        Gson gson = new Gson();
        HashMap signalDataMap = null;
        try {
            signalDataMap = gson.fromJson(signalingInfo.getData(), HashMap.class);
            if (signalDataMap != null) {
                businessIdObj = signalDataMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
            }
        } catch (JsonSyntaxException e) {
            TUIChatLog.e(TAG, " get signalingInfoCustomJsonMap error ");
        }
        if (businessIdObj instanceof String) {
            businessId = (String) businessIdObj;
        } else if (businessIdObj instanceof Double) {
            businessIdForTimeout = (Double) businessIdObj;
        }

        if (!TextUtils.equals(businessId, TUIConstants.TUICalling.CUSTOM_MESSAGE_BUSINESS_ID)
            && Math.abs(businessIdForTimeout - TUIConstants.TUICalling.CALL_TIMEOUT_BUSINESS_ID) >= 0.000001) {
            return null;
        }

        CallModel callModel = new CallModel();
        callModel.jsonData = signalDataMap;
        callModel.signalingInfo = signalingInfo;
        callModel.innerMessage = msg;
        callModel.style = CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY;
        callModel.caller = callModel.parseCaller();
        callModel.protocolType = callModel.parseProtocolType();
        callModel.streamMediaType = callModel.parseStreamMediaType();
        callModel.participantType = callModel.parseParticipantType();
        callModel.participantRole = callModel.parseParticipantRole();
        callModel.duration = callModel.parseDuration();
        for (String invitee : signalingInfo.getInviteeList()) {
            callModel.participantsMap.put(invitee, null);
        }
        return callModel;
    }

    // ************** Parser for content ****************
    private int parseProtocolType() {
        if (this.jsonData == null || this.signalingInfo == null || this.innerMessage == null) {
            return CALL_PROTOCOL_TYPE_UNKNOWN;
        }

        int type = CALL_PROTOCOL_TYPE_UNKNOWN;
        switch (this.signalingInfo.getActionType()) {
            case V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_INVITE: {
                Map data = (Map) this.jsonData.get("data");
                if (data != null && data instanceof Map) {
                    // New version for calling
                    String cmd = (String) data.get("cmd");
                    if (cmd != null && cmd instanceof String) {
                        if (TextUtils.equals(cmd, "switchToAudio")) {
                            type = CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO;
                        } else if (TextUtils.equals(cmd, "hangup")) {
                            type = CALL_PROTOCOL_TYPE_HANGUP;
                        } else if (TextUtils.equals(cmd, "videoCall")) {
                            type = CALL_PROTOCOL_TYPE_SEND;
                        } else if (TextUtils.equals(cmd, "audioCall")) {
                            type = CALL_PROTOCOL_TYPE_SEND;
                        } else {
                            type = CALL_PROTOCOL_TYPE_UNKNOWN;
                        }
                    } else {
                        TUIChatLog.e(TAG, "calling protocol error, invalid cmd");
                        type = CALL_PROTOCOL_TYPE_UNKNOWN;
                    }

                } else {
                    // Compatiable
                    if (this.jsonData.containsKey("call_end")) {
                        type = CALL_PROTOCOL_TYPE_HANGUP;
                    } else {
                        type = CALL_PROTOCOL_TYPE_SEND;
                    }
                }
            } break;
            case V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_CANCEL_INVITE: {
                type = CALL_PROTOCOL_TYPE_CANCEL;
            } break;
            case V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_ACCEPT_INVITE: {
                Map data = (Map) this.jsonData.get("data");
                if (data != null && data instanceof Map) {
                    // New version for calling
                    String cmd = (String) data.get("cmd");
                    if (cmd != null && cmd instanceof String) {
                        if (TextUtils.equals(cmd, "switchToAudio")) {
                            type = CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO_COMFIRM;
                        } else {
                            type = CALL_PROTOCOL_TYPE_ACCEPT;
                        }
                    } else {
                        TUIChatLog.e(TAG, "calling protocol error, invalid cmd");
                        type = CALL_PROTOCOL_TYPE_ACCEPT;
                    }
                } else {
                    // Compatiable
                    type = CALL_PROTOCOL_TYPE_ACCEPT;
                }
            } break;
            case V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_REJECT_INVITE: {
                if (this.jsonData.containsKey("line_busy")) {
                    type = CALL_PROTOCOL_TYPE_LINE_BUSY;
                } else {
                    type = CALL_PROTOCOL_TYPE_REJECT;
                }
            } break;
            case V2TIMSignalingInfo.SIGNALING_ACTION_TYPE_INVITE_TIMEOUT: {
                type = CALL_PROTOCOL_TYPE_TIMEOUT;
            } break;
            default:
                type = CALL_PROTOCOL_TYPE_UNKNOWN;
                break;
        }
        return type;
    }

    private int parseStreamMediaType() {
        if (protocolType == CALL_PROTOCOL_TYPE_UNKNOWN) {
            return CALL_STREAM_MEDIA_TYPE_UNKNOWN;
        }

        // Default type
        int type = CALL_STREAM_MEDIA_TYPE_UNKNOWN;
        if (jsonData.containsKey("call_type")) {
            double callType = (double) jsonData.get("call_type");
            if (callType == 1) {
                type = CALL_STREAM_MEDIA_TYPE_VOICE;
            } else if (callType == 2) {
                type = CALL_STREAM_MEDIA_TYPE_VIDEO;
            }
        }

        // Read from special protocol
        if (protocolType == CALL_PROTOCOL_TYPE_SEND) {
            Map data = (Map) this.jsonData.get("data");
            if (data != null && data instanceof Map) {
                String cmd = (String) data.get("cmd");
                if (cmd != null && cmd instanceof String) {
                    if (TextUtils.equals(cmd, "audioCall")) {
                        type = CALL_STREAM_MEDIA_TYPE_VOICE;
                    } else if (TextUtils.equals(cmd, "videoCall")) {
                        type = CALL_STREAM_MEDIA_TYPE_VIDEO;
                    }
                }
            }
        } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO || protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO_COMFIRM) {
            type = CALL_STREAM_MEDIA_TYPE_VIDEO;
        }

        return type;
    }

    private int parseParticipantType() {
        if (this.protocolType == CALL_PROTOCOL_TYPE_UNKNOWN) {
            return CALL_PARTICIPANT_TYPE_UNKNOWN;
        }

        if (this.signalingInfo.getGroupID().length() > 0) {
            return CALL_PARTICIPANT_TYPE_GROUP;
        } else {
            return CALL_PARTICIPANT_TYPE_C2C;
        }
    }

    private String parseCaller() {
        String callerID = null;
        Map data = (Map) this.jsonData.get("data");
        if (data != null && data instanceof Map) {
            String inviter = (String) data.get("inviter");
            if (!TextUtils.isEmpty(inviter) && inviter instanceof String) {
                callerID = inviter;
            }
        }
        if (callerID == null) {
            callerID = TUILogin.getLoginUser();
        }
        return callerID;
    }

    private int parseParticipantRole() {
        if (TextUtils.equals(caller, TUILogin.getLoginUser())) {
            return CALL_PARTICIPANT_ROLE_CALLER;
        } else {
            return CALL_PARTICIPANT_ROLE_CALLEE;
        }
    }

    public boolean isExcludeFromHistory() {
        if (style == CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY) {
            return protocolType != CALL_PROTOCOL_TYPE_UNKNOWN && innerMessage.isExcludedFromLastMessage() && innerMessage.isExcludedFromUnreadCount();
        } else {
            return false;
        }
    }

    public String getContent() {
        if (style == CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY) {
            return getContentForSimplifyAppearance();
        } else {
            return getContentForDetailsAppearance();
        }
    }

    public int getDirection() {
        if (style == CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY) {
            return getDirectionForSimplifyAppearance();
        } else {
            return getDirectionForDetailsAppearance();
        }
    }

    public boolean isUseReceiverAvatar() {
        if (style == CHAT_CALLING_MESSAGE_APPEARANCE_SIMPLIFY) {
            return isUseReceiverAvatarForSimplifyAppearance();
        } else {
            return isUseReceiverAvatarForDetailsAppearance();
        }
    }

    public boolean isShowUnreadPoint() {
        if (isExcludeFromHistory()) {
            return false;
        }
        return (innerMessage.getLocalCustomInt() == 0) && (participantRole == CALL_PARTICIPANT_ROLE_CALLEE)
            && (participantType == CALL_PARTICIPANT_TYPE_C2C)
            && (protocolType == CALL_PROTOCOL_TYPE_CANCEL || protocolType == CALL_PROTOCOL_TYPE_TIMEOUT
                || protocolType == CALL_PROTOCOL_TYPE_LINE_BUSY);
    }

    public String getDisplayName() {
        String displayName;
        if (innerMessage == null) {
            return null;
        }
        if (!TextUtils.isEmpty(innerMessage.getNameCard())) {
            displayName = innerMessage.getNameCard();
        } else if (!TextUtils.isEmpty(innerMessage.getFriendRemark())) {
            displayName = innerMessage.getFriendRemark();
        } else if (!TextUtils.isEmpty(innerMessage.getNickName())) {
            displayName = innerMessage.getNickName();
        } else {
            displayName = innerMessage.getSender();
        }
        return displayName;
    }

    // ******* Details style ********
    public String getContentForDetailsAppearance() {
        Context context = TUIChatService.getAppContext();
        boolean isGroup = (participantType == CALL_PARTICIPANT_TYPE_GROUP);

        if (protocolType == CALL_PROTOCOL_TYPE_UNKNOWN) {
            return context.getString(R.string.invalid_command);
        }

        String content = context.getString(R.string.invalid_command);
        String senderShowName = getDisplayName();
        if (protocolType == CALL_PROTOCOL_TYPE_SEND) {
            // Launch call
            content = isGroup ? ("\"" + senderShowName + "\"" + context.getString(R.string.start_group_call)) : (context.getString(R.string.start_call));
        } else if (protocolType == CALL_PROTOCOL_TYPE_ACCEPT) {
            // Accept call
            content = isGroup ? ("\"" + senderShowName + "\"" + context.getString(R.string.accept_call)) : context.getString(R.string.accept_call);
        } else if (protocolType == CALL_PROTOCOL_TYPE_REJECT) {
            // Reject call
            content = isGroup ? ("\"" + senderShowName + "\"" + context.getString(R.string.reject_group_calls)) : context.getString(R.string.reject_calls);
        } else if (protocolType == CALL_PROTOCOL_TYPE_CANCEL) {
            // Cancel pending call
            content = isGroup ? context.getString(R.string.cancle_group_call) : context.getString(R.string.cancle_call);
        } else if (protocolType == CALL_PROTOCOL_TYPE_HANGUP) {
            content =
                isGroup ? context.getString(R.string.stop_group_call) : context.getString(R.string.stop_call_tip) + DateTimeUtil.formatSecondsTo00(duration);
        } else if (protocolType == CALL_PROTOCOL_TYPE_TIMEOUT) {
            // Call timeout
            StringBuilder mutableContent = new StringBuilder();
            if (isGroup) {
                for (String invitee : getParticipants()) {
                    mutableContent.append("\"");
                    mutableContent.append(invitee);
                    mutableContent.append("\"、");
                }
                if (mutableContent.length() > 0) {
                    mutableContent.delete(mutableContent.length() - 1, mutableContent.length());
                }
            }
            mutableContent.append(context.getString(R.string.no_response_call));
            content = mutableContent.toString();
        } else if (protocolType == CALL_PROTOCOL_TYPE_LINE_BUSY) {
            // Hang up with line busy
            content = isGroup ? ("\"" + senderShowName + "\"" + context.getString(R.string.line_busy)) : context.getString(R.string.other_line_busy);
        } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO) {
            // Change video-call to voice-call
            content = context.getString(R.string.chat_calling_switch_to_audio);
        } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO_COMFIRM) {
            // Confirm the change of video-voice-call
            content = context.getString(R.string.chat_calling_switch_to_audio_accept);
        }
        return content;
    }

    public List<String> getParticipants() {
        List<String> participants = new ArrayList<>();
        for (Map.Entry<String, UserBean> entry : participantsMap.entrySet()) {
            UserBean userBean = entry.getValue();
            if (userBean != null) {
                participants.add(userBean.getDisplayString());
            } else {
                participants.add(entry.getKey());
            }
        }
        return participants;
    }

    public List<String> getParticipantIDs() {
        return signalingInfo.getInviteeList();
    }

    private int parseDuration() {
        if (protocolType == CALL_PROTOCOL_TYPE_HANGUP) {
            // Hang up
            return (int) Double.parseDouble(String.valueOf(jsonData.get("call_end")));
        }
        return 0;
    }

    public int getDirectionForDetailsAppearance() {
        if (innerMessage.isSelf()) {
            return CALL_MESSAGE_DIRECTION_OUTGOING;
        } else {
            return CALL_MESSAGE_DIRECTION_INCOMING;
        }
    }

    public boolean isUseReceiverAvatarForDetailsAppearance() {
        return false;
    }

    // ******* Simplify style ********
    public String getContentForSimplifyAppearance() {
        if (isExcludeFromHistory()) {
            return null;
        }

        boolean isCaller = (participantRole == CALL_PARTICIPANT_ROLE_CALLER);

        Context context = TUIChatService.getAppContext();
        String display = null;
        String showName = getDisplayName();
        if (participantType == CALL_PARTICIPANT_TYPE_C2C) {
            // C2C shown: reject、cancel、hangup、timeout、line_busy
            if (protocolType == CALL_PROTOCOL_TYPE_REJECT) {
                display = isCaller ? context.getString(R.string.chat_call_reject_caller) : context.getString(R.string.chat_call_reject_callee);
            } else if (protocolType == CALL_PROTOCOL_TYPE_CANCEL) {
                display = isCaller ? context.getString(R.string.chat_call_cancel_caller) : context.getString(R.string.chat_call_cancel_callee);
            } else if (protocolType == CALL_PROTOCOL_TYPE_HANGUP) {
                display = context.getString(R.string.stop_call_tip) + DateTimeUtil.formatSecondsTo00(duration);
            } else if (protocolType == CALL_PROTOCOL_TYPE_TIMEOUT) {
                display = isCaller ? context.getString(R.string.chat_call_timeout_caller) : context.getString(R.string.chat_call_timeout_callee);
            } else if (protocolType == CALL_PROTOCOL_TYPE_LINE_BUSY) {
                display = isCaller ? context.getString(R.string.chat_call_line_busy_caller) : context.getString(R.string.chat_call_line_busy_callee);
            }
            // C2C compatiable
            else if (protocolType == CALL_PROTOCOL_TYPE_SEND) {
                display = context.getString(R.string.start_call);
            } else if (protocolType == CALL_PROTOCOL_TYPE_ACCEPT) {
                display = context.getString(R.string.accept_call);
            } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO) {
                display = context.getString(R.string.chat_calling_switch_to_audio);
            } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO_COMFIRM) {
                display = context.getString(R.string.chat_calling_switch_to_audio_accept);
            } else {
                display = context.getString(R.string.invalid_command);
            }
        } else if (participantType == CALL_PARTICIPANT_TYPE_GROUP) {
            // Group shown: invite、cancel、hangup、timeout、line_busy
            if (protocolType == CALL_PROTOCOL_TYPE_SEND) {
                display = ("\"" + showName + "\"" + context.getString(R.string.chat_group_call_send));
            } else if (protocolType == CALL_PROTOCOL_TYPE_CANCEL) {
                display = context.getString(R.string.chat_group_call_end);
            } else if (protocolType == CALL_PROTOCOL_TYPE_HANGUP) {
                display = context.getString(R.string.chat_group_call_end);
            } else if (protocolType == CALL_PROTOCOL_TYPE_TIMEOUT || protocolType == CALL_PROTOCOL_TYPE_LINE_BUSY) {
                StringBuilder mutableContent = new StringBuilder();
                if (participantType == CALL_PARTICIPANT_TYPE_GROUP) {
                    for (String invitee : getParticipants()) {
                        mutableContent.append("\"");
                        mutableContent.append(invitee);
                        mutableContent.append("\"、");
                    }
                    if (mutableContent.length() > 0) {
                        mutableContent.delete(mutableContent.length() - 1, mutableContent.length());
                    }
                }
                mutableContent.append(context.getString(R.string.chat_group_call_no_answer));
                display = mutableContent.toString();
            }
            // Group compatiable
            else if (protocolType == CALL_PROTOCOL_TYPE_REJECT) {
                display = context.getString(R.string.chat_group_call_reject_format, showName);
            } else if (protocolType == CALL_PROTOCOL_TYPE_ACCEPT) {
                display = context.getString(R.string.chat_group_call_accept_format, showName);
            } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO) {
                display = context.getString(R.string.chat_group_call_switch_to_audio_format, showName);
            } else if (protocolType == CALL_PROTOCOL_TYPE_SWITCH_TO_AUDIO_COMFIRM) {
                display = context.getString(R.string.chat_group_call_confirm_switch_to_audio_format, showName);
            } else {
                display = context.getString(R.string.invalid_command);
            }
        } else {
            display = context.getString(R.string.invalid_command);
        }
        return display;
    }

    public int getDirectionForSimplifyAppearance() {
        if (participantRole == CALL_PARTICIPANT_ROLE_CALLER) {
            return CALL_MESSAGE_DIRECTION_OUTGOING;
        } else {
            return CALL_MESSAGE_DIRECTION_INCOMING;
        }
    }

    public boolean isUseReceiverAvatarForSimplifyAppearance() {
        if (getDirection() == CallModel.CALL_MESSAGE_DIRECTION_OUTGOING) {
            return !innerMessage.isSelf();
        } else {
            return innerMessage.isSelf();
        }
    }
}