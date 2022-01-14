package com.tencent.liteav.trtccalling.model.impl;

import android.app.ActivityManager;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.text.TextUtils;

import com.google.gson.ExclusionStrategy;
import com.google.gson.FieldAttributes;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMSignalingListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.TRTCCallingCallback;
import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.liteav.trtccalling.model.impl.base.CallModel;
import com.tencent.liteav.trtccalling.model.impl.base.MessageCustom;
import com.tencent.liteav.trtccalling.model.impl.base.OfflineMessageBean;
import com.tencent.liteav.trtccalling.model.impl.base.OfflineMessageContainerBean;
import com.tencent.liteav.trtccalling.model.impl.base.SignallingData;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCInternalListenerManager;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.MediaPlayHelper;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.rtmp.TXLiveBase;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * 视频/语音通话的具体实现
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 */
public class TRTCCalling {
    private static final String TAG            = "TRTCCalling";
    /**
     * 超时时间，单位秒
     */
    public static final  int    TIME_OUT_COUNT = 30;

    /**
     * room id 的取值范围
     */
    private static final int     ROOM_ID_MIN = 1;
    private static final int     ROOM_ID_MAX = Integer.MAX_VALUE;
    private final        Context mContext;

    /**
     * 底层SDK调用实例
     */
    private TRTCCloud mTRTCCloud;

    /**
     * 是否首次邀请
     */
    private boolean      isOnCalling           = false;
    private String       mCurCallID            = "";
    private String       mSwitchToAudioCallID  = "";
    private int          mCurRoomID            = 0;
    /**
     * 当前是否在TRTC房间中
     */
    private boolean      mIsInRoom             = false;
    private long         mEnterRoomTime        = 0;
    /**
     * 当前邀请列表
     * C2C通话时会记录自己邀请的用户
     * IM群组通话时会同步群组内邀请的用户
     * 当用户接听、拒绝、忙线、超时会从列表中移除该用户
     */
    private List<String> mCurInvitedList       = new ArrayList<>();
    /**
     * 当前语音通话中的远端用户
     */
    private Set<String>  mCurRoomRemoteUserSet = new HashSet<>();

    private final Map<Integer, String> mInviteIdMap = new HashMap<>();

    /**
     * C2C通话的邀请人
     * 例如A邀请B，B存储的mCurSponsorForMe为A
     */
    private String mCurSponsorForMe = "";

    /**
     * 当前通话的类型
     */
    private int                         mCurCallType   = TYPE_UNKNOWN;
    /**
     * 当前群组通话的群组ID
     */
    private String                      mCurGroupId    = "";
    /**
     * 最近使用的通话信令，用于快速处理
     */
    private CallModel                   mLastCallModel = new CallModel();
    /**
     * 上层传入回调
     */
    private TRTCInternalListenerManager mTRTCInternalListenerManager;
    private String                      mNickName;
    private String                      mFaceUrl;

    private boolean mIsUseFrontCamera;

    private boolean mWaitingLastActivityFinished;

    private MediaPlayHelper mMediaPlayHelper;        // 音效

    private SensorManager       mSensorManager;
    private SensorEventListener mSensorEventListener;

    private boolean mIsBeingCalled   = true;   // 默认是被叫
    private boolean mEnableMuteMode  = false;  // 是否开启静音模式
    private String  mCallingBellPath = "";     // 被叫铃音路径

    private int mUserType = USER_TYPE_NONE;

    private static final int USER_TYPE_NONE    = 0;
    private static final int USER_TYPE_CALLING = 1;

    public static final int TYPE_UNKNOWN    = 0;
    public static final int TYPE_AUDIO_CALL = 1;
    public static final int TYPE_VIDEO_CALL = 2;

    private static TRTCCalling sInstance;

    public interface ActionCallBack {
        void onError(int code, String msg);

        void onSuccess();
    }

    /**
     * 用于获取单例
     *
     * @param context
     * @return 单例
     */
    public static TRTCCalling sharedInstance(Context context) {
        synchronized (TRTCCalling.class) {
            if (sInstance == null) {
                sInstance = new TRTCCalling(context);
            }
            return sInstance;
        }
    }

    /**
     * 销毁单例
     */
    public static void destroySharedInstance() {
        synchronized (TRTCCalling.class) {
            if (sInstance != null) {
                sInstance.destroy();
                sInstance = null;
            }
        }
    }

    public boolean isWaitingLastActivityFinished() {
        return mWaitingLastActivityFinished;
    }

    public void setWaitingLastActivityFinished(boolean waiting) {
        mWaitingLastActivityFinished = waiting;
    }

    /**
     * 信令监听器
     */
    private V2TIMSignalingListener mTIMSignallingListener = new V2TIMSignalingListener() {
        @Override
        public void onReceiveNewInvitation(String inviteID, String inviter, String groupID,
                                           List<String> inviteeList, String data) {
            TRTCLogger.d(TAG, "onReceiveNewInvitation inviteID:" + inviteID + ", inviter:" + inviter
                    + ", groupID:" + groupID + ", inviteeList:" + inviteeList + " data:" + data);
            handleRecvCallModel(inviteID, inviter, groupID, inviteeList, data);
        }

        @Override
        public void onInviteeAccepted(String inviteID, String invitee, String data) {
            TRTCLogger.d(TAG, "onInviteeAccepted inviteID:" + inviteID
                    + ", invitee:" + invitee + " data:" + data);
            SignallingData signallingData = convert2CallingData(data);
            if (!isCallingData(signallingData)) {
                TRTCLogger.d(TAG, "this is not the calling sense ");
                return;
            }
            if (isSwitchAudioData(signallingData)) {
                realSwitchToAudioCall();
                return;
            }
            mCurInvitedList.remove(invitee);
        }

        @Override
        public void onInviteeRejected(String inviteID, String invitee, String data) {
            TRTCLogger.d(TAG, "onInviteeRejected inviteID:" + inviteID
                    + ", invitee:" + invitee + " data:" + data);
            SignallingData signallingData = convert2CallingData(data);
            if (!isCallingData(signallingData)) {
                TRTCLogger.d(TAG, "this is not the calling sense ");
                return;
            }
            if (isSwitchAudioData(signallingData)) {
                String message = getSwitchAudioRejectMessage(signallingData);
                onSwitchToAudio(false, message);
                return;
            }
            if (TextUtils.isEmpty(mCurCallID) || !inviteID.equals(mCurCallID)) {
                return;
            }
            mCurInvitedList.remove(invitee);
            mCurRoomRemoteUserSet.remove(invitee);
            if (isLineBusy(signallingData)) {
                if (mTRTCInternalListenerManager != null) {
                    mTRTCInternalListenerManager.onLineBusy(invitee);
                }
            } else {
                if (mTRTCInternalListenerManager != null) {
                    mTRTCInternalListenerManager.onReject(invitee);
                }
            }
            TRTCLogger.d(TAG, "mIsInRoom=" + mIsInRoom);
            preExitRoom(null);
            stopDialingMusic();
            unregisterSensorEventListener();
        }

        @Override
        public void onInvitationCancelled(String inviteID, String inviter, String data) {
            TRTCLogger.d(TAG, "onInvitationCancelled inviteID:" + inviteID + " data:" + data);
            SignallingData signallingData = convert2CallingData(data);
            if (!isCallingData(signallingData)) {
                TRTCLogger.d(TAG, "this is not the calling sense ");
                return;
            }
            if (inviteID.equals(mCurCallID)) {
                playHangupMusic();
                stopCall();
                exitRoom();
                if (mTRTCInternalListenerManager != null) {
                    mTRTCInternalListenerManager.onCallingCancel();
                }
            }
        }

        @Override
        public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
            TRTCLogger.d(TAG, "onInvitationTimeout inviteID : " + inviteID + " , mCurCallID : " + mCurCallID);
            if (!inviteID.equals(mCurCallID) && !inviteID.equals(mSwitchToAudioCallID)) {
                return;
            }
            if (TextUtils.isEmpty(mCurSponsorForMe)) {
                // 邀请者
                for (String userID : inviteeList) {
                    if (mTRTCInternalListenerManager != null) {
                        mTRTCInternalListenerManager.onNoResp(userID);
                    }
                    mCurInvitedList.remove(userID);
                    mCurRoomRemoteUserSet.remove(userID);
                }
                stopDialingMusic();
            } else {
                // 被邀请者
                if (inviteeList.contains(TUILogin.getUserId())) {
                    stopCall();
                    if (mTRTCInternalListenerManager != null) {
                        mTRTCInternalListenerManager.onCallingTimeout();
                    }
                }
                mCurInvitedList.removeAll(inviteeList);
                mCurRoomRemoteUserSet.removeAll(inviteeList);
            }
            // 每次超时都需要判断当前是否需要结束通话
            preExitRoom(null);
            playHangupMusic();
            unregisterSensorEventListener();
        }
    };

    private void handleRecvCallModel(String inviteID, String inviter, String groupID,
                                     List<String> inviteeList, String data) {
        SignallingData signallingData = convert2CallingData(data);
        if (!isCallingData(signallingData)) {
            TRTCLogger.d(TAG, "this is not the calling sense ");
            return;
        }
        if (!TextUtils.isEmpty(inviteID)) {
            mInviteIdMap.put(signallingData.getRoomId(), inviteID);
        }
        if (!isAppRunningForeground(mContext)) {
            TRTCLogger.d(TAG, "isAppRunningForeground is false");
            return;
        }
        if (null != inviteeList && !inviteeList.contains(TUILogin.getUserId())) {
            TRTCLogger.d(TAG, "this invitation is not for me");
            return;
        }
        processInvite(TextUtils.isEmpty(inviteID) ? mInviteIdMap.get(signallingData.getRoomId()) : inviteID,
                inviter, groupID, inviteeList, signallingData);
    }

    private boolean isLineBusy(SignallingData signallingData) {
        if (isNewSignallingVersion(signallingData)) {
            SignallingData.DataInfo dataInfo = signallingData.getData();
            if (dataInfo == null) {
                return false;
            }
            return CallModel.VALUE_MSG_LINE_BUSY.equals(dataInfo.getMessage());
        }
        return CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY.equals(signallingData.getLineBusy());
    }

    //是否是6-30改造后的信令版本
    private boolean isNewSignallingVersion(SignallingData signallingData) {
        return !TextUtils.isEmpty(signallingData.getPlatform()) && !TextUtils.isEmpty(signallingData.getBusinessID());
    }

    private String getSwitchAudioRejectMessage(SignallingData signallingData) {
        if (isNewSignallingVersion(signallingData)) {
            SignallingData.DataInfo dataInfo = signallingData.getData();
            if (dataInfo == null) {
                return "";
            }
            return dataInfo.getMessage();
        }
        String message = signallingData.getSwitchToAudioCall();
        return TextUtils.isEmpty(message) ? "" : message;
    }

    private boolean isCallingData(SignallingData signallingData) {
        String businessId = signallingData.getBusinessID();
        // 判断新/旧版信令
        if (!isNewSignallingVersion(signallingData)) {
            if (!TextUtils.isEmpty(businessId)) {
                // 是旧版信令，但不是calling信令，则返回false。（备注：旧版calling信令不包括businessId字段）
                return false;
            }
            // 是旧版calling信令，则返回true
            return true;
        }
        return CallModel.VALUE_BUSINESS_ID.equals(businessId);
    }

    private boolean isSwitchAudioData(SignallingData signallingData) {
        if (!isNewSignallingVersion(signallingData)) {
            return !TextUtils.isEmpty(signallingData.getSwitchToAudioCall());
        }
        if (signallingData.getData() == null) {
            return false;
        }
        return CallModel.VALUE_CMD_SWITCH_TO_AUDIO.equals(signallingData.getData().getCmd());
    }

    private SignallingData convert2CallingData(String data) {
        SignallingData signallingData = new SignallingData();
        Map<String, Object> extraMap;
        try {
            extraMap = new Gson().fromJson(data, Map.class);
            if (extraMap == null) {
                TRTCLogger.e(TAG, "onReceiveNewInvitation extraMap is null, ignore");
                return signallingData;
            }
            if (extraMap.containsKey(CallModel.KEY_VERSION)) {
                Object version = extraMap.get(CallModel.KEY_VERSION);
                if (version instanceof Double) {
                    signallingData.setVersion(((Double) version).intValue());
                } else {
                    TRTCLogger.e(TAG, "version is not Double, value is :" + version);
                }
            }

            if (extraMap.containsKey(CallModel.KEY_PLATFORM)) {
                Object platform = extraMap.get(CallModel.KEY_PLATFORM);
                if (platform instanceof String) {
                    signallingData.setPlatform((String) platform);
                } else {
                    TRTCLogger.e(TAG, "platform is not string, value is :" + platform);
                }
            }

            if (extraMap.containsKey(CallModel.KEY_BUSINESS_ID)) {
                Object businessId = extraMap.get(CallModel.KEY_BUSINESS_ID);
                if (businessId instanceof String) {
                    signallingData.setBusinessID((String) businessId);
                } else {
                    TRTCLogger.e(TAG, "businessId is not string, value is :" + businessId);
                }
            }

            //兼容老版本某些字段
            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE)) {
                Object callType = extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE);
                if (callType instanceof Double) {
                    signallingData.setCallType(((Double) callType).intValue());
                } else {
                    TRTCLogger.e(TAG, "callType is not Double, value is :" + callType);
                }
            }

            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID)) {
                Object roomId = extraMap.get(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID);
                if (roomId instanceof Double) {
                    signallingData.setRoomId(((Double) roomId).intValue());
                } else {
                    TRTCLogger.e(TAG, "roomId is not Double, value is :" + roomId);
                }
            }

            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY)) {
                Object lineBusy = extraMap.get(CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY);
                if (lineBusy instanceof String) {
                    signallingData.setLineBusy((String) lineBusy);
                } else {
                    TRTCLogger.e(TAG, "lineBusy is not string, value is :" + lineBusy);
                }
            }

            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_CALL_END)) {
                Object callEnd = extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                if (callEnd instanceof Double) {
                    signallingData.setCallEnd(((Double) callEnd).intValue());
                } else {
                    TRTCLogger.e(TAG, "callEnd is not Double, value is :" + callEnd);
                }
            }

            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL)) {
                Object switchToAudioCall = extraMap.get(CallModel.SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL);
                if (switchToAudioCall instanceof String) {
                    signallingData.setSwitchToAudioCall((String) switchToAudioCall);
                } else {
                    TRTCLogger.e(TAG, "switchToAudioCall is not string, value is :" + switchToAudioCall);
                }
            }

            if (extraMap.containsKey(CallModel.KEY_DATA)) {
                Object dataMapObj = extraMap.get(CallModel.KEY_DATA);
                if (dataMapObj != null && dataMapObj instanceof Map) {
                    Map<String, Object> dataMap = (Map<String, Object>) dataMapObj;
                    SignallingData.DataInfo dataInfo = convert2DataInfo(dataMap);
                    signallingData.setData(dataInfo);
                } else {
                    TRTCLogger.e(TAG, "dataMapObj is not map, value is :" + dataMapObj);
                }
            }
        } catch (JsonSyntaxException e) {
            TRTCLogger.e(TAG, "convert2CallingDataBean json parse error");
        }
        return signallingData;
    }

    private void processInvite(String inviteID, String inviter, String groupID, List<String> inviteeList,
                               SignallingData signallingData) {
        CallModel callModel = new CallModel();
        callModel.callId = inviteID;
        callModel.groupId = groupID;
        callModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
        callModel.invitedList = inviteeList;
        if (isNewSignallingVersion(signallingData)) {
            handleNewSignallingInvite(signallingData, callModel, inviter);
        } else {
            handleOldSignallingInvite(signallingData, callModel, inviter);
        }
    }

    private void handleNewSignallingInvite(SignallingData signallingData, CallModel callModel, String inviter) {
        SignallingData.DataInfo dataInfo = signallingData.getData();
        if (dataInfo == null) {
            TRTCLogger.i(TAG, "signallingData dataInfo is null");
            return;
        }
        if (TextUtils.isEmpty(callModel.groupId)) {
            List list = signallingData.getData().getUserIDs();
            callModel.invitedList = null == list ? callModel.invitedList : list;
        }
        callModel.roomId = dataInfo.getRoomID();
        if (CallModel.VALUE_CMD_AUDIO_CALL.equals(dataInfo.getCmd())) {
            callModel.callType = TYPE_AUDIO_CALL;
            mCurCallType = callModel.callType;
        } else if (CallModel.VALUE_CMD_VIDEO_CALL.equals(dataInfo.getCmd())) {
            callModel.callType = TYPE_VIDEO_CALL;
            mCurCallType = callModel.callType;
        }
        if (CallModel.VALUE_CMD_HAND_UP.equals(dataInfo.getCmd())) {
            preExitRoom(null);
            return;
        }
        if (CallModel.VALUE_CMD_SWITCH_TO_AUDIO.equals(dataInfo.getCmd())) {
            handleSwitchToAudio(callModel, inviter);
            return;
        }
        handleDialing(callModel, inviter);
        if (mCurCallID.equals(callModel.callId)) {
            mLastCallModel = (CallModel) callModel.clone();
        }
    }

    private void handleOldSignallingInvite(SignallingData signallingData, CallModel callModel, String inviter) {
        callModel.callType = signallingData.getCallType();
        mCurCallType = callModel.callType;
        callModel.roomId = signallingData.getRoomId();
        if (signallingData.getCallEnd() != 0) {
            preExitRoom(null);
            return;
        }
        if (CallModel.SIGNALING_EXTRA_KEY_SWITCH_AUDIO_CALL.equals(signallingData.getSwitchToAudioCall())) {
            handleSwitchToAudio(callModel, inviter);
            return;
        }
        handleDialing(callModel, inviter);
        if (mCurCallID.equals(callModel.callId)) {
            mLastCallModel = (CallModel) callModel.clone();
        }
    }

    private SignallingData.DataInfo convert2DataInfo(Map<String, Object> dataMap) {
        SignallingData.DataInfo dataInfo = new SignallingData.DataInfo();
        try {
            if (dataMap.containsKey(CallModel.KEY_CMD)) {
                Object cmd = dataMap.get(CallModel.KEY_CMD);
                if (cmd instanceof String) {
                    dataInfo.setCmd((String) cmd);
                } else {
                    TRTCLogger.e(TAG, "cmd is not string, value is :" + cmd);
                }
            }
            if (dataMap.containsKey(CallModel.KEY_USERIDS)) {
                Object userIDs = dataMap.get(CallModel.KEY_USERIDS);
                if (userIDs instanceof List) {
                    dataInfo.setUserIDs((List<String>) userIDs);
                } else {
                    TRTCLogger.e(TAG, "userIDs is not List, value is :" + userIDs);
                }
            }
            if (dataMap.containsKey(CallModel.KEY_ROOM_ID)) {
                Object roomId = dataMap.get(CallModel.KEY_ROOM_ID);
                if (roomId instanceof Double) {
                    dataInfo.setRoomID(((Double) roomId).intValue());
                } else {
                    TRTCLogger.e(TAG, "roomId is not Double, value is :" + roomId);
                }
            }
            if (dataMap.containsKey(CallModel.KEY_MESSAGE)) {
                Object message = dataMap.get(CallModel.KEY_MESSAGE);
                if (message instanceof String) {
                    dataInfo.setMessage((String) message);
                } else {
                    TRTCLogger.e(TAG, "message is not string, value is :" + message);
                }
            }
        } catch (JsonSyntaxException e) {
            TRTCLogger.e(TAG, "onReceiveNewInvitation JsonSyntaxException:" + e);
        }
        return dataInfo;
    }

    /**
     * TRTC的监听器
     */
    private TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            TRTCLogger.e(TAG, "onError: " + errCode + " " + errMsg);
            stopCall();
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onError(errCode, errMsg);
            }
        }

        @Override
        public void onEnterRoom(long result) {
            TRTCLogger.d(TAG, "onEnterRoom result:" + result + " , mCurSponsorForMe = " + mCurSponsorForMe
                    + " , mIsBeingCalled = " + mIsBeingCalled);
            if (result < 0) {
                stopCall();
            } else {
                mIsInRoom = true;
                //如果自己是被叫,接收到通话请求后进房,进房成功后发送accept信令给主叫端;如果自己是主叫,不处理
                if (mIsBeingCalled) {
                    sendModel(mCurSponsorForMe, CallModel.VIDEO_CALL_ACTION_ACCEPT);
                }
            }
        }

        @Override
        public void onExitRoom(int reason) {
            TRTCLogger.d(TAG, "onExitRoom reason:" + reason);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            TRTCLogger.d(TAG, "onRemoteUserEnterRoom userId:" + userId);
            mCurRoomRemoteUserSet.add(userId);
            // 只有单聊这个时间才是正确的，因为单聊只会有一个用户进群，群聊这个时间会被后面的人重置
            mEnterRoomTime = System.currentTimeMillis();
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onUserEnter(userId);
            }
            if (!mIsBeingCalled) {
                stopDialingMusic();
            }
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            TRTCLogger.d(TAG, "onRemoteUserLeaveRoom userId:" + userId + ", reason:" + reason);
            mCurRoomRemoteUserSet.remove(userId);
            mCurInvitedList.remove(userId);
            // 远端用户退出房间，需要判断本次通话是否结束
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onUserLeave(userId);
            }
            preExitRoom(userId);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            TRTCLogger.d(TAG, "onUserVideoAvailable userId:" + userId + ", available:" + available);
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onUserVideoAvailable(userId, available);
            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean available) {
            TRTCLogger.d(TAG, "onUserAudioAvailable userId:" + userId + ", available:" + available);
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onUserAudioAvailable(userId, available);
            }
        }

        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            Map<String, Integer> volumeMaps = new HashMap<>();
            for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
                String userId = info.userId == null ? TUILogin.getUserId() : info.userId;
                volumeMaps.put(userId, info.volume);
            }
            if (null != mTRTCInternalListenerManager) {
                mTRTCInternalListenerManager.onUserVoiceVolume(volumeMaps);
            }
        }

        @Override
        public void onNetworkQuality(TRTCCloudDef.TRTCQuality quality, ArrayList<TRTCCloudDef.TRTCQuality> arrayList) {
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onNetworkQuality(quality, arrayList);
            }
        }
    };

    private TRTCCalling(Context context) {
        mContext = context;
        mTRTCCloud = TRTCCloud.sharedInstance(context);
        mTRTCInternalListenerManager = new TRTCInternalListenerManager();
        mLastCallModel.version = CallModel.VALUE_VERSION;
        V2TIMManager.getSignalingManager().addSignalingListener(mTIMSignallingListener);
    }

    private void printVersionLog() {
        TRTCLogger.d(TAG, String.format("==== TUICalling Version: %s =====", TXLiveBase.getSDKVersionStr()));
    }

    private void startCall() {
        mMediaPlayHelper = new MediaPlayHelper(mContext);
        isOnCalling = true;
        mUserType = USER_TYPE_CALLING;
        registerSensorEventListener();
    }

    /**
     * 停止此次通话，把所有的变量都会重置
     */
    public void stopCall() {
        TRTCLogger.d(TAG, "stopCall");
        isOnCalling = false;
        mIsInRoom = false;
        mIsBeingCalled = true;
        mEnterRoomTime = 0;
        mCurCallID = "";
        mCurRoomID = 0;
        mCurInvitedList.clear();
        mCurRoomRemoteUserSet.clear();
        mCurSponsorForMe = "";
        mLastCallModel = new CallModel();
        mLastCallModel.version = CallModel.VALUE_VERSION;
        mCurGroupId = "";
        mCurCallType = TYPE_UNKNOWN;
        mUserType = USER_TYPE_NONE;
        stopDialingMusic();
        stopRing();
        unregisterSensorEventListener();
    }

    private void realSwitchToAudioCall() {
        if (mCurCallType == TYPE_VIDEO_CALL) {
            closeCamera();
            onSwitchToAudio(true, "success");
            mCurCallType = TYPE_AUDIO_CALL;
        }
    }

    /**
     * 判断用户是否正忙
     *
     * @param userType
     * @return
     */
    private boolean isUserModelBusy(int userType) {
        return userType != USER_TYPE_NONE;
    }

    public void handleDialing(CallModel callModel, String user) {
        //正在体验视频互动、语聊房、语音沙龙模块时，收到一个邀请我的通话请求，告诉对方忙线
        if (isUserModelBusy(mUserType)) {
            if (TextUtils.equals(user, mCurSponsorForMe)) {
                return;
            }
            sendModel(user, CallModel.VIDEO_CALL_ACTION_LINE_BUSY, callModel, null);
            return;
        }

        if (!TextUtils.isEmpty(mCurCallID)) {
            // 正在通话时，收到了一个邀请我的通话请求,需要告诉对方忙线
            if (isOnCalling && callModel.invitedList.contains(TUILogin.getUserId())) {
                sendModel(user, CallModel.VIDEO_CALL_ACTION_LINE_BUSY, callModel, null);
                return;
            }
            // 与对方处在同一个群中，此时收到了邀请群中其他人通话的请求，界面上展示连接动画
            if (!TextUtils.isEmpty(mCurGroupId) && !TextUtils.isEmpty(callModel.groupId)) {
                if (mCurGroupId.equals(callModel.groupId)) {
                    mCurInvitedList.addAll(callModel.invitedList);
                    if (mTRTCInternalListenerManager != null) {
                        mTRTCInternalListenerManager.onGroupCallInviteeListUpdate(mCurInvitedList);
                    }
                    return;
                }
            }
        }

        // 虽然是群组聊天，但是对方并没有邀请我，我不做处理
        if (!TextUtils.isEmpty(callModel.groupId) && !callModel.invitedList.contains(TUILogin.getUserId())) {
            return;
        }

        // 开始接通电话
        startCall();
        mCurCallID = callModel.callId;
        mCurRoomID = callModel.roomId;
        mCurCallType = callModel.callType;
        mCurSponsorForMe = user;
        mCurGroupId = callModel.groupId;
        // 邀请列表中需要移除掉自己
        callModel.invitedList.remove(TUILogin.getUserId());
        List<String> onInvitedUserListParam = callModel.invitedList;
        mCurInvitedList.addAll(callModel.invitedList);
        if (mTRTCInternalListenerManager != null) {
            mTRTCInternalListenerManager.onInvited(user, onInvitedUserListParam,
                    !TextUtils.isEmpty(mCurGroupId), mCurCallType);
        }
        mCurRoomRemoteUserSet.add(user);
        startRing();
    }

    private void handleSwitchToAudio(CallModel callModel, String user) {
        if (mCurCallType != TYPE_VIDEO_CALL) {
            sendModel(user, CallModel.VIDEO_CALL_ACTION_REJECT_SWITCH_TO_AUDIO, callModel,
                    "reject, remote user call type is not video call");
            return;
        }
        sendModel(user, CallModel.VIDEO_CALL_ACTION_ACCEPT_SWITCH_TO_AUDIO, callModel, "");
    }

    public void destroy() {
        //必要的清除逻辑
        V2TIMManager.getSignalingManager().removeSignalingListener(mTIMSignallingListener);
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.exitRoom();
    }

    public void addDelegate(TRTCCallingDelegate delegate) {
        mTRTCInternalListenerManager.addDelegate(delegate);
    }

    public void removeDelegate(TRTCCallingDelegate delegate) {
        mTRTCInternalListenerManager.removeDelegate(delegate);
    }

    public void call(final List<String> userIdList, int type) {
        TRTCLogger.i(TAG, "start single call " + Arrays.toString(userIdList.toArray()) + ", type " + type);
        if (userIdList.isEmpty()) {
            return;
        }
        internalCall(userIdList, type, "");
    }

    public void groupCall(final List<String> userIdList, int type, String groupId) {
        if (isCollectionEmpty(userIdList)) {
            return;
        }
        internalCall(userIdList, type, groupId);
    }

    /**
     * 统一的拨打逻辑
     *
     * @param userIdList 需要邀请的用户列表
     * @param type       邀请类型
     * @param groupId    群组通话的group id，如果是C2C需要传 ""
     */
    private void internalCall(final List<String> userIdList, int type, String groupId) {
        final boolean isGroupCall = !TextUtils.isEmpty(groupId);
        if (!isOnCalling) {
            // 首次拨打电话，生成id，并进入trtc房间
            mCurRoomID = generateRoomID();
            mCurGroupId = groupId;
            mCurCallType = type;
            TRTCLogger.d(TAG, "First calling, generate room id " + mCurRoomID);
            enterTRTCRoom();
            startCall();
            mIsBeingCalled = false;
            startDialingMusic();
        }
        // 非首次拨打，不能发起新的groupId通话
        if (!TextUtils.equals(mCurGroupId, groupId)) {
            return;
        }

        // 过滤已经邀请的用户id
        List<String> filterInvitedList = new ArrayList<>();
        for (String id : userIdList) {
            if (!mCurInvitedList.contains(id)) {
                filterInvitedList.add(id);
            }
        }
        // 如果当前没有需要邀请的id则返回
        if (isCollectionEmpty(filterInvitedList)) {
            return;
        }

        mCurInvitedList.addAll(filterInvitedList);
        mCurRoomRemoteUserSet.addAll(filterInvitedList);
        TRTCLogger.i(TAG, "groupCall: filter:" + filterInvitedList + " all:" + mCurInvitedList
                + " , mCurGroupId : " + mCurGroupId);
        // 填充通话信令的model
        mLastCallModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
        mLastCallModel.invitedList = mCurInvitedList;
        mLastCallModel.roomId = mCurRoomID;
        mLastCallModel.groupId = mCurGroupId;
        mLastCallModel.callType = mCurCallType;

        // 首次拨打电话，生成id
        if (!TextUtils.isEmpty(mCurGroupId)) {
            // 群聊发送群消息
            mCurCallID = sendModel("", CallModel.VIDEO_CALL_ACTION_DIALING);
        } else {
            // 单聊发送C2C消息
            for (final String userId : filterInvitedList) {
                mCurCallID = sendModel(userId, CallModel.VIDEO_CALL_ACTION_DIALING);
            }
        }
        mLastCallModel.callId = mCurCallID;
    }

    /**
     * 重要：用于判断是否需要结束本次通话
     * 在用户超时、拒绝、忙线、有人退出房间时需要进行判断
     */
    private void preExitRoom(String leaveUser) {
        TRTCLogger.i(TAG, "preExitRoom: " + mCurRoomRemoteUserSet + " " + mCurInvitedList
                + " mIsInRoom=" + mIsInRoom + " leaveUser=" + leaveUser);
        if (mCurRoomRemoteUserSet.isEmpty() && mCurInvitedList.isEmpty()) {
            // 当没有其他用户在房间里了，则结束通话。
            if (!TextUtils.isEmpty(leaveUser) && mIsInRoom) {
                if (TextUtils.isEmpty(mCurGroupId)) {
                    sendModel(leaveUser, CallModel.VIDEO_CALL_ACTION_HANGUP);
                } else {
                    sendModel("", CallModel.VIDEO_CALL_ACTION_HANGUP);
                }
            }
            playHangupMusic();
            exitRoom();
            stopCall();
            if (mTRTCInternalListenerManager != null) {
                mTRTCInternalListenerManager.onCallEnd();
            }
        }
    }

    /**
     * trtc 退房
     */
    private void exitRoom() {
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.exitRoom();
    }

    public void accept() {
        enterTRTCRoom();
        stopRing();
    }

    /**
     * trtc 进房
     */
    private void enterTRTCRoom() {
        if (mCurCallType == TYPE_VIDEO_CALL) {
            // 开启基础美颜
            TXBeautyManager txBeautyManager = mTRTCCloud.getBeautyManager();
            // 自然美颜
            txBeautyManager.setBeautyStyle(1);
            txBeautyManager.setBeautyLevel(6);
            // 进房前需要设置一下关键参数
            TRTCCloudDef.TRTCVideoEncParam encParam = new TRTCCloudDef.TRTCVideoEncParam();
            encParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
            encParam.videoFps = 15;
            encParam.videoBitrate = 1000;
            encParam.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
            encParam.enableAdjustRes = true;
            mTRTCCloud.setVideoEncoderParam(encParam);
        }
        TRTCLogger.i(TAG, "enterTRTCRoom: " + TUILogin.getUserId() + " room:" + mCurRoomID);
        TRTCCloudDef.TRTCParams trtcParams = new TRTCCloudDef.TRTCParams(TUILogin.getSdkAppId(), TUILogin.getUserId(),
                TUILogin.getUserSig(), mCurRoomID, "", "");
        trtcParams.role = TRTCCloudDef.TRTCRoleAnchor;
        mTRTCCloud.enableAudioVolumeEvaluation(300);
        mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        mTRTCCloud.startLocalAudio();
        // 收到来电，开始监听 trtc 的消息
        setFramework(5);
        // 输出版本日志
        printVersionLog();
        mTRTCCloud.setListener(mTRTCCloudListener);
        mTRTCCloud.enterRoom(trtcParams, mCurCallType == TYPE_VIDEO_CALL
                ? TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL : TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
    }

    public void reject() {
        playHangupMusic();
        sendModel(mCurSponsorForMe, CallModel.VIDEO_CALL_ACTION_REJECT);
        stopCall();
    }

    public void hangup() {
        // 1. 如果还没有在通话中，说明还没有接通，所以直接拒绝了
        if (!isOnCalling) {
            reject();
            return;
        }
        playHangupMusic();
        boolean fromGroup = (!TextUtils.isEmpty(mCurGroupId));
        if (fromGroup) {
            TRTCLogger.d(TAG, "groupHangup");
            groupHangup();
        } else {
            TRTCLogger.d(TAG, "singleHangup");
            singleHangup();
        }
    }

    private void groupHangup() {
        boolean bHasCallUser = false;
        for (String user : mCurRoomRemoteUserSet) {
            if (!TextUtils.isEmpty(user) && !mCurInvitedList.contains(user)) {
                // 还有正在通话用户
                bHasCallUser = true;
                break;
            }
        }
        if (!bHasCallUser) {
            // 当前以及没有人在通话了，直接向群里发送一个取消消息
            sendModel("", CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL);
        }
        stopCall();
        exitRoom();
    }

    private void singleHangup() {
        for (String id : mCurInvitedList) {
            sendModel(id, CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL);
        }
        stopCall();
        exitRoom();
    }

    public void openCamera(boolean isFrontCamera, TXCloudVideoView txCloudVideoView) {
        if (txCloudVideoView == null) {
            return;
        }
        mIsUseFrontCamera = isFrontCamera;
        mTRTCCloud.startLocalPreview(isFrontCamera, txCloudVideoView);
    }

    public void closeCamera() {
        mTRTCCloud.stopLocalPreview();
    }

    public void startRemoteView(String userId, TXCloudVideoView txCloudVideoView) {
        if (txCloudVideoView == null) {
            return;
        }
        mTRTCCloud.startRemoteView(userId, txCloudVideoView);
    }

    public void stopRemoteView(String userId) {
        mTRTCCloud.stopRemoteView(userId);
    }

    public void switchCamera(boolean isFrontCamera) {
        if (mIsUseFrontCamera == isFrontCamera) {
            return;
        }
        mIsUseFrontCamera = isFrontCamera;
        mTRTCCloud.switchCamera();
    }

    public void setMicMute(boolean isMute) {
        mTRTCCloud.muteLocalAudio(isMute);
    }

    public void setHandsFree(boolean isHandsFree) {
        if (isHandsFree) {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        } else {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
        }
    }

    public void switchToAudioCall() {
        if (mCurCallType != TYPE_VIDEO_CALL) {
            onSwitchToAudio(false, "the call type of current user is not video call");
            return;
        }
        if (mCurRoomRemoteUserSet.isEmpty()) {
            onSwitchToAudio(false, "remote user is empty");
            return;
        }
        for (final String userId : mCurRoomRemoteUserSet) {
            mSwitchToAudioCallID = sendModel(userId, CallModel.VIDEO_CALL_SWITCH_TO_AUDIO_CALL);
        }
    }

    public void setSelfProfile(String userName, String avatarURL, final TRTCCallingCallback.ActionCallback callback) {
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        v2TIMUserFullInfo.setNickname(userName);
        v2TIMUserFullInfo.setFaceUrl(avatarURL);
        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "set profile code:" + code + " msg:" + desc);
                if (callback != null) {
                    callback.onCallback(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "set profile success.");
                if (callback != null) {
                    callback.onCallback(0, "set profile success.");
                }
            }
        });
    }

    public void receiveNewInvitation(String sender, String content) {
        if (TextUtils.isEmpty(sender) || TextUtils.isEmpty(content)) {
            return;
        }
        List<String> invitedList = new ArrayList<>();
        JsonObject contentJson = (JsonObject) new JsonParser().parse(content);
        if (!contentJson.has(TUICallingConstants.KEY_GROUP_ID)) {
            return;
        }
        String groupId = contentJson.get(TUICallingConstants.KEY_GROUP_ID).getAsString();
        if (!contentJson.has(TUICallingConstants.KEY_INVITED_LIST)) {
            return;
        }
        JsonArray invitedArray = contentJson.getAsJsonArray(TUICallingConstants.KEY_INVITED_LIST);
        if (null != invitedArray) {
            for (JsonElement element : invitedArray) {
                invitedList.add(element.getAsString());
            }
        }
        if (!contentJson.has(TUICallingConstants.KEY_CALL_ID)) {
            return;
        }
        String inviteID = contentJson.get(TUICallingConstants.KEY_CALL_ID).getAsString();
        if (!contentJson.has(TUICallingConstants.KEY_CALL_TYPE)) {
            return;
        }
        int callType = contentJson.get(TUICallingConstants.KEY_CALL_TYPE).getAsInt();
        if (!contentJson.has(TUICallingConstants.KEY_ROOM_ID)) {
            return;
        }
        int roomId = contentJson.get(TUICallingConstants.KEY_ROOM_ID).getAsInt();
        GsonBuilder gsonBuilder = new GsonBuilder();
        SignallingData data = createSignallingData();
        data.setCallType(callType);
        data.setRoomId(roomId);
        SignallingData.DataInfo callDataInfo = new SignallingData.DataInfo();
        if (callType == TYPE_AUDIO_CALL) {
            callDataInfo.setCmd(CallModel.VALUE_CMD_AUDIO_CALL);
        } else if (callType == TYPE_VIDEO_CALL) {
            callDataInfo.setCmd(CallModel.VALUE_CMD_VIDEO_CALL);
        } else {
            return;
        }
        callDataInfo.setRoomID(roomId);
        data.setData(callDataInfo);
        addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
        if (TextUtils.isEmpty(groupId)) {
            callDataInfo.setUserIDs(invitedList);
        }
        String json = gsonBuilder.create().toJson(data);
        mTIMSignallingListener.onReceiveNewInvitation(inviteID, sender, groupId, invitedList, json);
    }

    public void setCallingBell(String filePath) {
        mCallingBellPath = filePath;
    }

    public void enableMuteMode(boolean enable) {
        mEnableMuteMode = enable;
    }

    private String sendModel(final String user, int action) {
        return sendModel(user, action, null, null);
    }

    private void sendOnlineMessageWithOfflinePushInfo(final String user, final CallModel model) {
        List<String> users = new ArrayList<String>();
        users.add(V2TIMManager.getInstance().getLoginUser());
        if (!TextUtils.isEmpty(mNickName)) {
            sendOnlineMessageWithOfflinePushInfo(user, mNickName, model);
            return;
        }
        V2TIMManager.getInstance().getUsersInfo(users, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {

            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "getUsersInfo err code = " + code + ", desc = " + desc);
                sendOnlineMessageWithOfflinePushInfo(user, null, model);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.size() == 0) {
                    sendOnlineMessageWithOfflinePushInfo(user, null, model);
                    return;
                }
                mNickName = v2TIMUserFullInfos.get(0).getNickName();
                mFaceUrl = v2TIMUserFullInfos.get(0).getFaceUrl();
                sendOnlineMessageWithOfflinePushInfo(user, v2TIMUserFullInfos.get(0).getNickName(), model);
            }
        });
    }

    private String getCallId() {
        return mCurCallID;
    }

    private void sendOnlineMessageWithOfflinePushInfo(String userId, String nickname, CallModel model) {
        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = new Gson().toJson(model);
        entity.sender = V2TIMManager.getInstance().getLoginUser(); // 发送者肯定是登录账号
        entity.action = OfflineMessageBean.REDIRECT_ACTION_CALL;
        entity.sendTime = System.currentTimeMillis() / 1000;
        entity.nickname = nickname;
        entity.faceUrl = mFaceUrl;
        containerBean.entity = entity;
        List<String> invitedList = new ArrayList<>();
        final boolean isGroup = (!TextUtils.isEmpty(model.groupId));
        if (isGroup) {
            entity.chatType = V2TIMConversation.V2TIM_GROUP;
            invitedList.addAll(model.invitedList);
        } else {
            invitedList.add(userId);
        }

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");
        v2TIMOfflinePushInfo.setDesc(mContext.getString(R.string.trtccalling_title_have_a_call_invitation));
        v2TIMOfflinePushInfo.setTitle(nickname);
        MessageCustom custom = new MessageCustom();
        custom.businessID = MessageCustom.BUSINESS_ID_AV_CALL;
        V2TIMMessage message = V2TIMManager.getMessageManager().createCustomMessage(new Gson().toJson(custom).getBytes());

        for (String receiver : invitedList) {
            TRTCLogger.i(TAG, "sendOnlineMessage to " + receiver);
            V2TIMManager.getMessageManager().sendMessage(message, receiver, null, V2TIMMessage.V2TIM_PRIORITY_DEFAULT,
                    true, v2TIMOfflinePushInfo, new V2TIMSendCallback<V2TIMMessage>() {

                        @Override
                        public void onError(int code, String desc) {
                            TRTCLogger.e(TAG, "sendOnlineMessage failed, code:" + code + ", desc:" + desc);
                        }

                        @Override
                        public void onSuccess(V2TIMMessage v2TIMMessage) {
                            TRTCLogger.i(TAG, "sendOnlineMessage msgId:" + v2TIMMessage.getMsgID());
                        }

                        @Override
                        public void onProgress(int progress) {

                        }
                    });
        }
    }

    /**
     * 信令发送函数，当CallModel 存在groupId时会向群组发送信令
     *
     * @param user
     * @param action
     * @param model
     * @param message
     */
    private String sendModel(final String user, int action, CallModel model, String message) {
        String callID = null;
        final CallModel realCallModel;
        if (model != null) {
            realCallModel = (CallModel) model.clone();
            realCallModel.action = action;
        } else {
            realCallModel = generateModel(action);
        }
        final boolean isGroup = (!TextUtils.isEmpty(realCallModel.groupId));
        if (action == CallModel.VIDEO_CALL_ACTION_HANGUP && mEnterRoomTime != 0 && !isGroup) {
            realCallModel.duration = (int) (System.currentTimeMillis() - mEnterRoomTime) / 1000;
            mEnterRoomTime = 0;
        }
        String receiver = "";
        String groupId = "";
        if (isGroup) {
            groupId = realCallModel.groupId;
        } else {
            receiver = user;
        }
        final SignallingData signallingData = createSignallingData();
        signallingData.setCallType(realCallModel.callType);
        signallingData.setRoomId(realCallModel.roomId);
        GsonBuilder gsonBuilder = new GsonBuilder();
        // signalling
        switch (realCallModel.action) {
            case CallModel.VIDEO_CALL_ACTION_DIALING:
                signallingData.setRoomId(realCallModel.roomId);
                SignallingData.DataInfo callDataInfo = new SignallingData.DataInfo();
                if (realCallModel.callType == TYPE_AUDIO_CALL) {
                    callDataInfo.setCmd(CallModel.VALUE_CMD_AUDIO_CALL);
                } else if (realCallModel.callType == TYPE_VIDEO_CALL) {
                    callDataInfo.setCmd(CallModel.VALUE_CMD_VIDEO_CALL);
                } else {
                    break;
                }
                callDataInfo.setRoomID(realCallModel.roomId);
                signallingData.setData(callDataInfo);
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                if (isGroup) {
                    String dialingDataStr = gsonBuilder.create().toJson(signallingData);
                    callID = sendGroupInvite(groupId, realCallModel.invitedList, dialingDataStr, TIME_OUT_COUNT, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TRTCLogger.e(TAG, "inviteInGroup failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TRTCLogger.d(TAG, "inviteInGroup success:" + realCallModel);
                            realCallModel.callId = getCallId();
                            realCallModel.timeout = TIME_OUT_COUNT;
                            realCallModel.version = CallModel.VALUE_VERSION;
                            sendOnlineMessageWithOfflinePushInfo(user, realCallModel);
                        }
                    });
                } else {
                    callDataInfo.setUserIDs(realCallModel.invitedList);
                    String dialingDataStr = gsonBuilder.create().toJson(signallingData);
                    realCallModel.callId = getCallId();
                    realCallModel.timeout = TIME_OUT_COUNT;
                    realCallModel.version = CallModel.VALUE_VERSION;
                    V2TIMOfflinePushInfo pushInfo = createV2TIMOfflinePushInfo(realCallModel, user, user);
                    callID = sendInvite(receiver, dialingDataStr, pushInfo, TIME_OUT_COUNT, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TRTCLogger.e(TAG, "invite failed callID:" + realCallModel.callId + ",error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TRTCLogger.d(TAG, "invite success:" + realCallModel);
                            realCallModel.callId = getCallId();
                            realCallModel.timeout = TIME_OUT_COUNT;
                            realCallModel.version = CallModel.VALUE_VERSION;
//                            sendOnlineMessageWithOfflinePushInfo(user, realCallModel);
                        }
                    });
                }
                break;
            case CallModel.VIDEO_CALL_ACTION_ACCEPT:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                String acceptDataStr = gsonBuilder.create().toJson(signallingData);
                acceptInvite(realCallModel.callId, acceptDataStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "accept failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "accept success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_REJECT:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                String rejectDataStr = gsonBuilder.create().toJson(signallingData);
                rejectInvite(realCallModel.callId, rejectDataStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "reject failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "reject success callID:" + realCallModel.callId);
                    }
                });
                break;
            case CallModel.VIDEO_CALL_ACTION_LINE_BUSY:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                SignallingData.DataInfo lineBusyDataInfo = new SignallingData.DataInfo();
                signallingData.setLineBusy(CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY);
                lineBusyDataInfo.setMessage(CallModel.VALUE_MSG_LINE_BUSY);
                signallingData.setData(lineBusyDataInfo);
                String lineBusyMapStr = new Gson().toJson(signallingData);
                rejectInvite(realCallModel.callId, lineBusyMapStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "line_busy failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "line_busy success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                String cancelMapStr = gsonBuilder.create().toJson(signallingData);
                cancelInvite(realCallModel.callId, cancelMapStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "cancel failde callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "cancel success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_HANGUP:
                SignallingData.DataInfo hangupDataInfo = new SignallingData.DataInfo();
                signallingData.setCallEnd(realCallModel.duration);
                hangupDataInfo.setCmd(CallModel.VALUE_CMD_HAND_UP);
                signallingData.setData(hangupDataInfo);
                String hangupMapStr = gsonBuilder.create().toJson(signallingData);
                if (isGroup) {
                    sendGroupInvite(groupId, realCallModel.invitedList, hangupMapStr, 0, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TRTCLogger.e(TAG, "inviteInGroup-->hangup failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TRTCLogger.d(TAG, "inviteInGroup-->hangup success callID:" + realCallModel.callId);
                        }
                    });
                } else {
                    sendInvite(receiver, hangupMapStr, null, 0, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TRTCLogger.e(TAG, "invite-->hangup failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TRTCLogger.d(TAG, "invite-->hangup success callID:" + realCallModel.callId);
                        }
                    });
                }
                break;

            case CallModel.VIDEO_CALL_SWITCH_TO_AUDIO_CALL:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                SignallingData.DataInfo switchAudioCallDataInfo = new SignallingData.DataInfo();
                switchAudioCallDataInfo.setCmd(CallModel.VALUE_CMD_SWITCH_TO_AUDIO);
                signallingData.setSwitchToAudioCall(CallModel.VALUE_CMD_SWITCH_TO_AUDIO);
                signallingData.setData(switchAudioCallDataInfo);
                String switchAudioCall = gsonBuilder.create().toJson(signallingData);
                callID = sendInvite(receiver, switchAudioCall, null, TIME_OUT_COUNT, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "invite-->switchAudioCall failed callID: " + realCallModel.callId
                                + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "invite-->switchAudioCall success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_ACCEPT_SWITCH_TO_AUDIO:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                SignallingData.DataInfo acceptSwitchAudioCallData = new SignallingData.DataInfo();
                acceptSwitchAudioCallData.setCmd(CallModel.VALUE_CMD_SWITCH_TO_AUDIO);
                signallingData.setSwitchToAudioCall(CallModel.VALUE_CMD_SWITCH_TO_AUDIO);
                signallingData.setData(acceptSwitchAudioCallData);
                String acceptSwitchAudioDataStr = gsonBuilder.create().toJson(signallingData);
                acceptInvite(realCallModel.callId, acceptSwitchAudioDataStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "accept switch audio call failed callID:" + realCallModel.callId
                                + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "accept switch audio call success callID:" + realCallModel.callId);
                        realSwitchToAudioCall();
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_REJECT_SWITCH_TO_AUDIO:
                addFilterKey(gsonBuilder, CallModel.SIGNALING_EXTRA_KEY_CALL_END);
                SignallingData.DataInfo rejectSwitchAudioCallData = new SignallingData.DataInfo();
                rejectSwitchAudioCallData.setCmd(CallModel.VALUE_CMD_SWITCH_TO_AUDIO);
                signallingData.setSwitchToAudioCall(CallModel.VALUE_CMD_SWITCH_TO_AUDIO);
                rejectSwitchAudioCallData.setMessage(message);
                signallingData.setData(rejectSwitchAudioCallData);
                String rejectSwitchAudioMapStr = gsonBuilder.create().toJson(signallingData);
                rejectInvite(realCallModel.callId, rejectSwitchAudioMapStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TRTCLogger.e(TAG, "reject switch to audio failed callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "reject switch to audio success callID:" + realCallModel.callId);
                    }
                });
                break;
            default:
                break;
        }

        // 最后需要重新赋值
        updateLastCallModel(realCallModel, callID, model);
        TRTCLogger.d(TAG, "callID=" + callID + " , mCurCallID : " + mCurCallID);
        return callID;
    }

    private void updateLastCallModel(CallModel realCallModel, String callID, CallModel oldModel) {
        if (realCallModel.action != CallModel.VIDEO_CALL_ACTION_REJECT &&
                realCallModel.action != CallModel.VIDEO_CALL_ACTION_HANGUP &&
                realCallModel.action != CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL &&
                oldModel == null) {
            mLastCallModel = (CallModel) realCallModel.clone();
        }
    }

    private SignallingData createSignallingData() {
        SignallingData signallingData = new SignallingData();
        signallingData.setVersion(CallModel.VALUE_VERSION);
        signallingData.setBusinessID(CallModel.VALUE_BUSINESS_ID);
        signallingData.setPlatform(CallModel.VALUE_PLATFORM);
        return signallingData;
    }

    private void onSwitchToAudio(boolean success, String message) {
        if (mTRTCInternalListenerManager != null) {
            mTRTCInternalListenerManager.onSwitchToAudio(success, message);
        }
    }

    private CallModel generateModel(int action) {
        CallModel callModel = (CallModel) mLastCallModel.clone();
        callModel.action = action;
        return callModel;
    }

    private static boolean isCollectionEmpty(Collection coll) {
        return coll == null || coll.size() == 0;
    }

    private static int generateRoomID() {
        Random random = new Random();
        return random.nextInt(ROOM_ID_MAX - ROOM_ID_MIN + 1) + ROOM_ID_MIN;
    }

    private String sendInvite(String receiver, String data, V2TIMOfflinePushInfo info, int timeout, final V2TIMCallback callback) {
        TRTCLogger.d(TAG, String.format("sendInvite, receiver=%s, data=%s", receiver, data));
        return V2TIMManager.getSignalingManager().invite(receiver, data, false, info, timeout, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
            }
        });
    }

    private String sendGroupInvite(String groupId, List<String> inviteeList, String data, int timeout, final V2TIMCallback callback) {
        TRTCLogger.d(TAG, String.format("sendGroupInvite, groupId=%s, inviteeList=%s, data=%s", groupId, Arrays.toString(inviteeList.toArray()), data));
        return V2TIMManager.getSignalingManager().inviteInGroup(groupId, inviteeList, data, false, timeout, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
            }
        });
    }

    private void acceptInvite(String inviteId, String data, final V2TIMCallback callback) {
        TRTCLogger.d(TAG, String.format("acceptInvite, inviteId=%s, data=%s", inviteId, data));
        V2TIMManager.getSignalingManager().accept(inviteId, data, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
            }
        });
    }

    private void rejectInvite(String inviteId, String data, final V2TIMCallback callback) {
        TRTCLogger.d(TAG, String.format("rejectInvite, inviteId=%s, data=%s", inviteId, data));
        V2TIMManager.getSignalingManager().reject(inviteId, data, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
            }
        });
    }

    private void cancelInvite(String inviteId, String data, final V2TIMCallback callback) {
        TRTCLogger.d(TAG, String.format("cancelInvite, inviteId=%s, data=%s", inviteId, data));
        V2TIMManager.getSignalingManager().cancel(inviteId, data, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
            }
        });
    }

    //在json中过滤不需要的key
    private void addFilterKey(GsonBuilder builder, final String... keys) {
        for (final String key : keys) {
            builder.setExclusionStrategies(new ExclusionStrategy() {
                @Override
                public boolean shouldSkipField(FieldAttributes f) {
                    return f.getName().contains(key);
                }

                @Override
                public boolean shouldSkipClass(Class<?> clazz) {
                    return false;
                }
            });
        }
    }

    private void registerSensorEventListener() {
        if (null != mSensorManager) {
            return;
        }
        mSensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);
        Sensor sensor = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
        PowerManager pm = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
        final PowerManager.WakeLock wakeLock = pm.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, "TUICalling:TRTCAudioCallWakeLock");
        mSensorEventListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                switch (event.sensor.getType()) {
                    case Sensor.TYPE_PROXIMITY:
                        // 靠近手机
                        if (event.values[0] == 0.0) {
                            if (wakeLock.isHeld()) {
                                // 检查WakeLock是否被占用
                                return;
                            } else {
                                // 申请设备电源锁
                                wakeLock.acquire();
                            }
                        } else {
                            if (!wakeLock.isHeld()) {
                                return;
                            } else {
                                wakeLock.setReferenceCounted(false);
                                // 释放设备电源锁
                                wakeLock.release();
                            }
                            break;
                        }
                }
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {

            }
        };
        mSensorManager.registerListener(mSensorEventListener, sensor, SensorManager.SENSOR_DELAY_FASTEST);
    }

    private void unregisterSensorEventListener() {
        if (null != mSensorManager && null != mSensorEventListener) {
            Sensor sensor = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
            mSensorManager.unregisterListener(mSensorEventListener, sensor);
            mSensorManager = null;
        }
    }

    private void startDialingMusic() {
        if (null == mMediaPlayHelper) {
            return;
        }
        mMediaPlayHelper.start(R.raw.phone_dialing);
    }

    private void stopDialingMusic() {
        stopMusic();
    }

    private void startRing() {
        if (null == mMediaPlayHelper || mEnableMuteMode) {
            return;
        }
        if (TextUtils.isEmpty(mCallingBellPath)) {
            mMediaPlayHelper.start(R.raw.phone_ringing);
        } else {
            mMediaPlayHelper.start(mCallingBellPath);
        }
    }

    private void stopRing() {
        stopMusic();
    }

    private void playHangupMusic() {
        if (null == mMediaPlayHelper) {
            return;
        }
        mMediaPlayHelper.start(R.raw.phone_hangup, 2000);
    }

    private void stopMusic() {
        if (null == mMediaPlayHelper) {
            return;
        }
        final int resId = mMediaPlayHelper.getResId();
        // 挂断音效很短，播放完即可；主叫铃音和被叫铃音需主动stop
        if (resId != R.raw.phone_hangup) {
            mMediaPlayHelper.stop();
        }
    }

    private V2TIMOfflinePushInfo createV2TIMOfflinePushInfo(CallModel callModel, String userId, String nickname) {
        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = new Gson().toJson(callModel);
        entity.sender = V2TIMManager.getInstance().getLoginUser(); // 发送者肯定是登录账号
        entity.action = OfflineMessageBean.REDIRECT_ACTION_CALL;
        entity.sendTime = System.currentTimeMillis() / 1000;
        entity.nickname = nickname;
        entity.faceUrl = mFaceUrl;
        containerBean.entity = entity;
        List<String> invitedList = new ArrayList<>();
        invitedList.add(userId);
        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");
        v2TIMOfflinePushInfo.setDesc(mContext.getString(R.string.trtccalling_title_have_a_call_invitation));
        v2TIMOfflinePushInfo.setTitle(nickname);
        return v2TIMOfflinePushInfo;
    }

    public boolean isAppRunningForeground(Context context) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> runningAppProcessInfos = activityManager.getRunningAppProcesses();
        if (runningAppProcessInfos == null) {
            return false;
        }
        String packageName = context.getPackageName();
        for (ActivityManager.RunningAppProcessInfo appProcessInfo : runningAppProcessInfos) {
            if (appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                    && appProcessInfo.processName.equals(packageName)) {
                return true;
            }
        }
        return false;
    }

    private void setFramework(int framework) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "setFramework");
            JSONObject params = new JSONObject();
            params.put("framework", framework);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
