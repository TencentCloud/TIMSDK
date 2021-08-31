package com.tencent.liteav.model;

import android.Manifest;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.offlinePush.OfflinePushManager;
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
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.tuikit.live.helper.TUIKitLiveChatController;
import com.tencent.qcloud.tim.tuikit.live.utils.PermissionUtils;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;
import com.tencent.qcloud.tim.tuikit.live.utils.UIUtil;
import com.tencent.qcloud.tim.uikit.base.IBaseMessageSender;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.chat.base.OfflineMessageBean;
import com.tencent.qcloud.tim.uikit.modules.chat.base.OfflineMessageContainerBean;
import com.tencent.qcloud.tim.uikit.modules.message.MessageCustom;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * 音视频通话的具体实现
 * 本功能使用腾讯云实时音视频 / 腾讯云即时通信IM 组合实现
 * 1. 为了方便您接入，在login中调用了initIM进行IM系统的初始化，如果您的项目中已经使用了IM，可以删除这里的初始化
 */
public class TRTCAVCallImpl implements ITRTCAVCall {
    private static final String TAG = "TRTCAVCallImpl";
    /**
     * 超时时间，单位秒
     */
    public static final int TIME_OUT_COUNT = 30;

    /**
     * room id 的取值范围
     */
    private static final int ROOM_ID_MIN = 1;
    private static final int ROOM_ID_MAX = Integer.MAX_VALUE;

    private static ITRTCAVCall sITRTCAVCall;
    private final Context mContext;
    /**
     * 底层SDK调用实例
     */
    private TRTCCloud mTRTCCloud;
    private V2TIMManager mTIMManager;

    /**
     * 当前IM登录用户名
     */
    private String mCurUserId = "";
    private int mSdkAppId;
    private String mCurUserSig;
    /**
     * 是否首次邀请
     */
    private boolean isOnCalling = false;
    private String mCurCallID = "";
    private int mCurRoomID = 0;
    /**
     * 当前是否在TRTC房间中
     */
    private boolean mIsInRoom = false;
    private long mEnterRoomTime = 0;
    /**
     * 当前邀请列表
     * C2C通话时会记录自己邀请的用户
     * IM群组通话时会同步群组内邀请的用户
     * 当用户接听、拒绝、忙线、超时会从列表中移除该用户
     */
    private List<String> mCurInvitedList = new ArrayList<>();
    /**
     * 当前语音通话中的远端用户
     */
    private Set<String> mCurRoomRemoteUserSet = new HashSet<>();

    /**
     * C2C通话的邀请人
     * 例如A邀请B，B存储的mCurSponsorForMe为A
     */
    private String mCurSponsorForMe = "";
    /**
     * C2C通话是否回复过邀请人
     * 例如A邀请B，B回复接受/拒绝/忙线都置为true
     */
    private boolean mIsRespSponsor = false;
    /**
     * 当前通话的类型
     */
    private int mCurCallType = TYPE_UNKNOWN;
    /**
     * 当前群组通话的群组ID
     */
    private String mCurGroupId = "";
    /**
     * 最近使用的通话信令，用于快速处理
     */
    private CallModel mLastCallModel = new CallModel();
    /**
     * 上层传入回调
     */
    private TRTCInteralListenerManager mTRTCInteralListenerManager;

    private boolean mIsUseFrontCamera;

    private boolean mWaitingLastActivityFinished;

    public String c2cCallId = "";

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
        public void onReceiveNewInvitation(String inviteID, String inviter, String groupID, List<String> inviteeList, String data) {
            if (!isCallingData(data)) {
                return;
            }
            Context context = TUIKitLive.getAppContext();
            if (context == null) {
                TUILiveLog.e(TAG, "onReceiveNewInvitation context is null");
                return;
            }
            // 如果应用在前台运行，则直接拉起，否则要点通知才能拉起
            if (UIUtil.isAppRunningForeground(context)) {
                processInvite(inviteID, inviter, groupID, inviteeList, data);
            } else {
                c2cCallId = inviteID;
            }
        }

        @Override
        public void onInviteeAccepted(String inviteID, String invitee, String data) {
            TUILiveLog.d(TAG, "onInviteeAccepted inviteID:" + inviteID + ", invitee:" + invitee);
            if (!isCallingData(data)) {
                return;
            }

            mCurInvitedList.remove(invitee);
        }

        @Override
        public void onInviteeRejected(String inviteID, String invitee, String data) {
            if (!isCallingData(data)) {
                return;
            }

            if (mCurCallID.equals(inviteID)) {
                try {
                    Map rejectData = new Gson().fromJson(data, Map.class);
                    mCurInvitedList.remove(invitee);
                    if (rejectData != null && rejectData.containsKey(CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY)) {
                        if (mTRTCInteralListenerManager != null) {
                            mTRTCInteralListenerManager.onLineBusy(invitee);
                        }
                    } else {
                        if (mTRTCInteralListenerManager != null) {
                            mTRTCInteralListenerManager.onReject(invitee);
                        }
                    }
                    preExitRoom(null);
                } catch (JsonSyntaxException e) {
                    TUILiveLog.e(TAG, "onReceiveNewInvitation JsonSyntaxException:" + e);
                }
            }
        }

        @Override
        public void onInvitationCancelled(String inviteID, String inviter, String data) {
            if (!isCallingData(data)) {
                return;
            }

            if (mCurCallID.equals(inviteID)) {
                stopCall();
                if (mTRTCInteralListenerManager != null) {
                    mTRTCInteralListenerManager.onCallingCancel();
                }
            }
        }

        @Override
        public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
            if (inviteID != null && !inviteID.equals(mCurCallID)) {
                return;
            }

            if (TextUtils.isEmpty(mCurSponsorForMe)) {
                // 邀请者
                for (String userID : inviteeList) {
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onNoResp(userID);
                    }
                    mCurInvitedList.remove(userID);
                }
            } else {
                // 被邀请者
                if (inviteeList.contains(mCurUserId)) {
                    stopCall();
                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onCallingTimeout();
                    }
                }
                mCurInvitedList.removeAll(inviteeList);
            }
            // 每次超时都需要判断当前是否需要结束通话
            preExitRoom(null);
        }
    };

    private boolean isCallingData(String data){
        try{
            JSONObject jsonObject = new JSONObject(data);
            if (jsonObject.has(CallModel.SIGNALING_EXTRA_KEY_BUSINESS_ID)
                    && jsonObject.getString(CallModel.SIGNALING_EXTRA_KEY_BUSINESS_ID).equals(CallModel.SIGNALING_EXTRA_VALUE_BUSINESS_ID)) {
                return true;
            }
            if (jsonObject.has(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE)) {
                return true;
            }
        } catch (Exception e) {
            TUILiveLog.e(TAG, "isCallingData json parse error");
        }

        return false;
    }

    public void processInvite(String inviteID, String inviter, String groupID, List<String> inviteeList, String data) {
        // 重复进入同一通话
        if (mCurCallID.equals(inviteID) && isOnCalling) {
            return;
        }
        CallModel callModel = new CallModel();
        callModel.callId = inviteID;
        callModel.groupId = groupID;
        callModel.action = CallModel.VIDEO_CALL_ACTION_DIALING;
        callModel.invitedList = inviteeList;

        Map<String, Object> extraMap = null;
        try {
            extraMap = new Gson().fromJson(data, Map.class);
            if (extraMap == null) {
                TUILiveLog.e(TAG, "onReceiveNewInvitation extraMap is null, ignore");
                return;
            }
            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_VERSION)) {
                callModel.version = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_VERSION)).intValue();
            }
            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE)) {
                callModel.callType = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE)).intValue();
                mCurCallType = callModel.callType;
            }
            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_CALL_END)) {
                preExitRoom(null);
                return;
            }
            if (extraMap.containsKey(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID)) {
                callModel.roomId = ((Double)extraMap.get(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID)).intValue();
            }
        } catch (JsonSyntaxException e) {
            TUILiveLog.e(TAG, "onReceiveNewInvitation JsonSyntaxException:" + e);
        }
        handleDialing(callModel, inviter);

        if (mCurCallID.equals(callModel.callId)) {
            mLastCallModel = (CallModel) callModel.clone();
        }
    }

    /**
     * TRTC的监听器
     */
    private TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            TUILiveLog.e(TAG, "onError: " + errCode + " " + errMsg);
            stopCall();
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onError(errCode, errMsg);
            }
        }

        @Override
        public void onEnterRoom(long result) {
            TUILiveLog.d(TAG, "onEnterRoom result:" + result);
            if (result < 0) {
                stopCall();
            } else {
                mIsInRoom = true;
            }
        }

        @Override
        public void onExitRoom(int reason) {
            TUILiveLog.d(TAG, "onExitRoom reason:" + reason);
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            TUILiveLog.d(TAG, "onRemoteUserEnterRoom userId:" + userId);
            mCurRoomRemoteUserSet.add(userId);
            // 只有单聊这个时间才是正确的，因为单聊只会有一个用户进群，群聊这个时间会被后面的人重置
            mEnterRoomTime = V2TIMManager.getInstance().getServerTime();
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserEnter(userId);
            }
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            TUILiveLog.d(TAG, "onRemoteUserLeaveRoom userId:" + userId + ", reason:" + reason);
            mCurRoomRemoteUserSet.remove(userId);
            mCurInvitedList.remove(userId);
            // 远端用户退出房间，需要判断本次通话是否结束
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserLeave(userId);
            }
            preExitRoom(userId);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            TUILiveLog.d(TAG, "onUserVideoAvailable userId:" + userId + ", available:" + available);
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserVideoAvailable(userId, available);
            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean available) {
            TUILiveLog.d(TAG, "onUserAudioAvailable userId:" + userId + ", available:" + available);
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onUserAudioAvailable(userId, available);
            }
        }

        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            Map<String, Integer> volumeMaps = new HashMap<>();
            for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
                String userId = "";
                if (info.userId == null) {
                    userId = mCurUserId;
                } else {
                    userId = info.userId;
                }
                volumeMaps.put(userId, info.volume);
            }
            mTRTCInteralListenerManager.onUserVoiceVolume(volumeMaps);
        }
    };

    /**
     * 用于获取单例
     *
     * @param context
     * @return 单例
     */
    public static ITRTCAVCall sharedInstance(Context context) {
        synchronized (TRTCAVCallImpl.class) {
            if (sITRTCAVCall == null) {
                sITRTCAVCall = new TRTCAVCallImpl(context);
            }
            return sITRTCAVCall;
        }
    }

    /**
     * 销毁单例
     */
    public static void destroySharedInstance() {
        synchronized (TRTCAVCallImpl.class) {
            if (sITRTCAVCall != null) {
                sITRTCAVCall.destroy();
                sITRTCAVCall = null;
            }
        }
    }

    public TRTCAVCallImpl(Context context) {
        mContext = context;
        mTIMManager = V2TIMManager.getInstance();
        mTRTCCloud = TRTCCloud.sharedInstance(context);
        mTRTCInteralListenerManager = new TRTCInteralListenerManager();
        mLastCallModel.version = TUIKitConstants.version;
    }

    private void startCall() {
        isOnCalling = true;
    }

    /**
     * 停止此次通话，把所有的变量都会重置
     */
    public void stopCall() {
        isOnCalling = false;
        mIsInRoom = false;
        mEnterRoomTime = 0;
        mCurCallID = "";
        mCurRoomID = 0;
        mCurInvitedList.clear();
        mCurRoomRemoteUserSet.clear();
        mCurSponsorForMe = "";
        mLastCallModel = new CallModel();
        mLastCallModel.version = TUIKitConstants.version;
        mIsRespSponsor = false;
        mCurGroupId = "";
        mCurCallType = TYPE_UNKNOWN;
    }

    @Override
    public void init() {
    }

    public void handleDialing(CallModel callModel, String user) {
        if (!TextUtils.isEmpty(mCurCallID)) {
            // 正在通话时，收到了一个邀请我的通话请求,需要告诉对方忙线
            if (isOnCalling && callModel.invitedList.contains(mCurUserId)) {
                sendModel(user, CallModel.VIDEO_CALL_ACTION_LINE_BUSY, callModel);
                return;
            }
            // 与对方处在同一个群中，此时收到了邀请群中其他人通话的请求，界面上展示连接动画
            if (!TextUtils.isEmpty(mCurGroupId) && !TextUtils.isEmpty(callModel.groupId)) {
                if (mCurGroupId.equals(callModel.groupId)) {
                    mCurInvitedList.addAll(callModel.invitedList);
                    //群组邀请ID会有重复情况，需要去重下
                    Set<String> set = new HashSet<String>();
                    set.addAll(mCurInvitedList);
                    mCurInvitedList = new ArrayList<String>(set);

                    if (mTRTCInteralListenerManager != null) {
                        mTRTCInteralListenerManager.onGroupCallInviteeListUpdate(mCurInvitedList);
                    }
                    return;
                }
            }
        }
        // 虽然是群组聊天，但是对方并没有邀请我，我不做处理
        if (!TextUtils.isEmpty(callModel.groupId) && !callModel.invitedList.contains(mCurUserId)) {
            return;
        }
        // 开始接通电话
        startCall();
        mCurCallID = callModel.callId;
        mCurRoomID = callModel.roomId;
        mCurCallType = callModel.callType;
        mCurSponsorForMe = user;
        mCurGroupId = callModel.groupId;
        final String cid = mCurCallID;
        // 邀请列表中需要移除掉自己
        callModel.invitedList.remove(mCurUserId);
        List<String> onInvitedUserListParam = callModel.invitedList;
        if (!TextUtils.isEmpty(mCurGroupId)) {
            mCurInvitedList.addAll(callModel.invitedList);
        }
        if (mTRTCInteralListenerManager != null) {
            mTRTCInteralListenerManager.onInvited(user, onInvitedUserListParam, !TextUtils.isEmpty(mCurGroupId), mCurCallType);
        }
    }

    @Override
    public void destroy() {
        //必要的清除逻辑
        V2TIMManager.getSignalingManager().removeSignalingListener(mTIMSignallingListener);
        mTRTCCloud.stopLocalPreview();
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.exitRoom();
    }

    @Override
    public void addListener(TRTCAVCallListener listener) {
        mTRTCInteralListenerManager.addListenter(listener);
    }

    @Override
    public void removeListener(TRTCAVCallListener listener) {
        mTRTCInteralListenerManager.removeListenter(listener);
    }

    @Override
    public void login(int sdkAppId, final String userId, final String userSign, final ITRTCAVCall.ActionCallBack callback) {
       TUILiveLog.i(TAG, "startTUILiveLogin, sdkAppId:" + sdkAppId + " userId:" + userId + " sign is empty:" + TextUtils.isEmpty(userSign));
        if (sdkAppId == 0 || TextUtils.isEmpty(userId) || TextUtils.isEmpty(userSign)) {
           TUILiveLog.e(TAG, "startTUILiveLogin fail. params invalid.");
            if (callback != null) {
                callback.onError(-1, "login fail, params is invalid.");
            }
            return;
        }
        mSdkAppId = sdkAppId;
        // 需要将监听器添加到IM上
        V2TIMManager.getSignalingManager().addSignalingListener(mTIMSignallingListener);

        String loginUser = mTIMManager.getLoginUser();
        if (loginUser != null &&loginUser.equals(userId)) {
            TUILiveLog.d(TAG, TUIKitLive.getAppContext().getString(R.string.im_logined) +loginUser);
            List<String> userIdList = new ArrayList<String>();
            userIdList.add(loginUser);
            mTIMManager.getUsersInfo(userIdList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                @Override
                public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                    V2TIMUserFullInfo fullInfo = v2TIMUserFullInfos.get(0);
                    UserModel userModel = new UserModel();
                    userModel.userAvatar = fullInfo.getFaceUrl();
                    userModel.userName = fullInfo.getNickName();
                    userModel.userId = fullInfo.getUserID();
                    userModel.userSig = fullInfo.getSelfSignature();
                    ProfileManager.getInstance().setUserModel(userModel);
                }

                @Override
                public void onError(int code, String desc) {
                    TUILiveLog.e(TAG, "login get current userInfo failed. errorCode: " + code + " desc: " + desc);
                }
            });
            mCurUserId =loginUser;
            mCurUserSig = userSign;
            if (callback != null) {
                callback.onSuccess();
            }
        } else {
            if (callback != null) {
                callback.onError(BaseConstants.ERR_SDK_NOT_LOGGED_IN,"not login im");
            }
        }
    }

    @Override
    public void logout(final ITRTCAVCall.ActionCallBack callBack) {
        stopCall();
        exitRoom();
    }

    @Override
    public void call(final String userId, int type) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        List<String> list = new ArrayList<>();
        list.add(userId);
        internalCall(list, type, "");
    }

    @Override
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
            enterTRTCRoom();
            startCall();
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
        TUILiveLog.i(TAG, "groupCall: filter:" + filterInvitedList + " all:" + mCurInvitedList);
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
        TUILiveLog.i(TAG, "preExitRoom: " + mCurRoomRemoteUserSet + " " + mCurInvitedList);
        if (mCurRoomRemoteUserSet.isEmpty() && mCurInvitedList.isEmpty() && mIsInRoom) {
            // 当没有其他用户在房间里了，则结束通话。
            if (!TextUtils.isEmpty(leaveUser)) {
                if (TextUtils.isEmpty(mCurGroupId)) {
                    sendModel(leaveUser, CallModel.VIDEO_CALL_ACTION_HANGUP);
                } else {
                    sendModel("", CallModel.VIDEO_CALL_ACTION_HANGUP);
                }
            }
            exitRoom();
            stopCall();
            if (mTRTCInteralListenerManager != null) {
                mTRTCInteralListenerManager.onCallEnd();
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

    @Override
    public void accept() {
        mIsRespSponsor = true;
        sendModel(mCurSponsorForMe, CallModel.VIDEO_CALL_ACTION_ACCEPT);
        enterTRTCRoom();
    }

    /**
     * trtc 进房
     */
    private void enterTRTCRoom() {
        if (mCurCallType == ITRTCAVCall.TYPE_VIDEO_CALL) {
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
        TUILiveLog.i(TAG, "enterTRTCRoom: " + mCurUserId + " room:" + mCurRoomID);
        TRTCCloudDef.TRTCParams TRTCParams = new TRTCCloudDef.TRTCParams(mSdkAppId, mCurUserId, mCurUserSig, mCurRoomID, "", "");
        TRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;
        mTRTCCloud.enableAudioVolumeEvaluation(300);
        mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        mTRTCCloud.startLocalAudio();
        // 进房前，开始监听trtc的消息
        mTRTCCloud.setListener(mTRTCCloudListener);
        mTRTCCloud.enterRoom(TRTCParams, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
    }

    @Override
    public void reject() {
        mIsRespSponsor = true;
        sendModel(mCurSponsorForMe, CallModel.VIDEO_CALL_ACTION_REJECT);
        stopCall();
    }

    @Override
    public void hangup() {
        // 1. 如果还没有在通话中，说明还没有接通，所以直接拒绝了
        if (!isOnCalling) {
            reject();
            return;
        }
        boolean fromGroup = (!TextUtils.isEmpty(mCurGroupId));
        if (fromGroup) {
            groupHangup();
        } else {
            singleHangup();
        }
    }

    private void groupHangup() {
        if (isCollectionEmpty(mCurRoomRemoteUserSet)) {
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

    @Override
    public void openCamera(boolean isFrontCamera, TXCloudVideoView txCloudVideoView) {
        if (txCloudVideoView == null) {
            return;
        }
        mIsUseFrontCamera = isFrontCamera;
        mTRTCCloud.startLocalPreview(isFrontCamera, txCloudVideoView);
    }

    @Override
    public void closeCamera() {
        mTRTCCloud.stopLocalPreview();
    }

    @Override
    public void startRemoteView(String userId, TXCloudVideoView txCloudVideoView) {
        if (txCloudVideoView == null) {
            return;
        }
        mTRTCCloud.startRemoteView(userId, txCloudVideoView);
    }

    @Override
    public void stopRemoteView(String userId) {
        mTRTCCloud.stopRemoteView(userId);
    }

    @Override
    public void switchCamera(boolean isFrontCamera) {
        if (mIsUseFrontCamera == isFrontCamera) {
            return;
        }
        mIsUseFrontCamera = isFrontCamera;
        mTRTCCloud.switchCamera();
    }

    @Override
    public void setMicMute(boolean isMute) {
        mTRTCCloud.muteLocalAudio(isMute);
    }

    @Override
    public void setHandsFree(boolean isHandsFree) {
        if (isHandsFree) {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
        } else {
            mTRTCCloud.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
        }
    }

    private String sendModel(final String user, int action) {
        return sendModel(user, action, null);
    }

    private void sendOnlineMessageWithOfflinePushInfoForGroupCall(final CallModel model) {
        IBaseMessageSender messageSender = TUIKitListenerManager.getInstance().getMessageSender();
        if (messageSender == null) {
            TUILiveLog.e(TAG, "sendGroupCall error ,messageSender is null");
            return;
        }
        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = getOfflinePushInfo(model);

        MessageCustom custom = new MessageCustom();
        custom.businessID = TUIKitLiveChatController.BUSINESS_ID_AV_CALL;
        custom.version = TUIKitConstants.version;
        MessageInfo messageInfo = MessageInfoUtil.buildCustomMessage(new Gson().toJson(custom));
        messageInfo.setIgnoreShow(true);
        for (String receiver : model.invitedList) {
            TUILiveLog.i(TAG, "sendOnlineMessage to " + receiver);
            messageSender.sendMessage(messageInfo, v2TIMOfflinePushInfo, receiver, false, true, new IUIKitCallBack() {
                @Override
                public void onSuccess(Object data) {
                    if (data instanceof V2TIMMessage) {
                        TUILiveLog.i(TAG, "sendOnlineMessage msgId:" + ((V2TIMMessage) data).getMsgID());
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUILiveLog.e(TAG, "sendOnlineMessage failed, code:" + errCode + ", desc:" + errMsg);

                }
            });
        }
    }

    private V2TIMOfflinePushInfo getOfflinePushInfo(CallModel model) {
        OfflineMessageContainerBean containerBean = new OfflineMessageContainerBean();
        OfflineMessageBean entity = new OfflineMessageBean();
        entity.content = new Gson().toJson(model);
        entity.sender = V2TIMManager.getInstance().getLoginUser(); // 发送者肯定是登录账号
        entity.action = OfflineMessageBean.REDIRECT_ACTION_CALL;
        entity.sendTime = V2TIMManager.getInstance().getServerTime();
        entity.nickname = ProfileManager.getInstance().getUserModel().userName;
        entity.faceUrl = ProfileManager.getInstance().getUserModel().userAvatar;
        containerBean.entity = entity;
        entity.chatType = model.callType;

        V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
        v2TIMOfflinePushInfo.setExt(new Gson().toJson(containerBean).getBytes());
        // OPPO必须设置ChannelID才可以收到推送消息，这个channelID需要和控制台一致
        v2TIMOfflinePushInfo.setAndroidOPPOChannelID("tuikit");
        v2TIMOfflinePushInfo.setDesc(TUIKitLive.getAppContext().getString(R.string.offline_call_tip));

        return v2TIMOfflinePushInfo;
    }

    private String getCallId() {
        return mCurCallID;
    }

    /**
     * 信令发送函数，当CallModel 存在groupId时会向群组发送信令
     *
     * @param user
     * @param action
     * @param model
     */
    private String sendModel(final String user, int action, CallModel model) {
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
            realCallModel.duration = (int)(V2TIMManager.getInstance().getServerTime() - mEnterRoomTime);
            mEnterRoomTime = 0;
        }
        String receiver = "";
        String groupId = "";
        if (isGroup) {
            groupId = realCallModel.groupId;
        } else {
            receiver = user;
        }
        Map<String, Object> customMap = new HashMap();
        customMap.put(CallModel.SIGNALING_EXTRA_KEY_VERSION, TUIKitConstants.version);
        customMap.put(CallModel.SIGNALING_EXTRA_KEY_CALL_TYPE, realCallModel.callType);
        customMap.put(CallModel.SIGNALING_EXTRA_KEY_BUSINESS_ID, CallModel.SIGNALING_EXTRA_VALUE_BUSINESS_ID);
        // signalling
        switch (realCallModel.action) {
            case CallModel.VIDEO_CALL_ACTION_DIALING:
                customMap.put(CallModel.SIGNALING_EXTRA_KEY_ROOM_ID, realCallModel.roomId);
                String dialingDataStr = new Gson().toJson(customMap);
                if (isGroup) {
                    callID = V2TIMManager.getSignalingManager().inviteInGroup(groupId, realCallModel.invitedList, dialingDataStr, false, TIME_OUT_COUNT, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TUILiveLog.e(TAG, "inviteInGroup callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TUILiveLog.d(TAG, "inviteInGroup success:" + realCallModel);
                            realCallModel.callId = getCallId();
                            realCallModel.timeout = TIME_OUT_COUNT;
                            realCallModel.version = TUIKitConstants.version;
                            sendOnlineMessageWithOfflinePushInfoForGroupCall(realCallModel);
                        }
                    });
                } else {
                    realCallModel.callId = getCallId();
                    realCallModel.timeout = TIME_OUT_COUNT;
                    realCallModel.version = TUIKitConstants.version;
                    V2TIMOfflinePushInfo offlinePushInfo = getOfflinePushInfo(realCallModel);
                    callID = V2TIMManager.getSignalingManager().invite(receiver, dialingDataStr, false, offlinePushInfo, TIME_OUT_COUNT, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TUILiveLog.e(TAG, "invite  callID:" + realCallModel.callId + ",error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TUILiveLog.d(TAG, "invite success:" + realCallModel);
                        }
                    });
                }
                break;
            case CallModel.VIDEO_CALL_ACTION_ACCEPT:
                String acceptDataStr = new Gson().toJson(customMap);
                V2TIMManager.getSignalingManager().accept(realCallModel.callId, acceptDataStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TUILiveLog.e(TAG, "accept callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TUILiveLog.d(TAG, "accept success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_REJECT:
                String rejectDataStr = new Gson().toJson(customMap);
                V2TIMManager.getSignalingManager().reject(realCallModel.callId, rejectDataStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TUILiveLog.e(TAG, "reject callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TUILiveLog.d(TAG, "reject success callID:" + realCallModel.callId);
                    }
                });
                break;
            case CallModel.VIDEO_CALL_ACTION_LINE_BUSY:
                customMap.put(CallModel.SIGNALING_EXTRA_KEY_LINE_BUSY, "");
                String lineBusyMapStr = new Gson().toJson(customMap);

                V2TIMManager.getSignalingManager().reject(realCallModel.callId, lineBusyMapStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TUILiveLog.e(TAG, "reject  callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TUILiveLog.d(TAG, "reject success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                String cancelMapStr = new Gson().toJson(customMap);
                V2TIMManager.getSignalingManager().cancel(realCallModel.callId, cancelMapStr, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        TUILiveLog.e(TAG, "cancel callID:" + realCallModel.callId + ", error:" + code + " desc:" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        TUILiveLog.d(TAG, "cancel success callID:" + realCallModel.callId);
                    }
                });
                break;

            case CallModel.VIDEO_CALL_ACTION_HANGUP:
                customMap.put(CallModel.SIGNALING_EXTRA_KEY_CALL_END, realCallModel.duration);
                String hangupMapStr = new Gson().toJson(customMap);
                if (isGroup) {
                    V2TIMManager.getSignalingManager().inviteInGroup(groupId, realCallModel.invitedList, hangupMapStr, false, 0, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TUILiveLog.e(TAG, "inviteInGroup-->hangup callID: " + realCallModel.callId + ", error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TUILiveLog.d(TAG, "inviteInGroup-->hangup success callID:" + realCallModel.callId);
                        }
                    });
                } else {
                    V2TIMManager.getSignalingManager().invite(receiver, hangupMapStr, false, null, 0, new V2TIMCallback() {
                        @Override
                        public void onError(int code, String desc) {
                            TUILiveLog.e(TAG, "invite-->hangup callID: " + realCallModel.callId + ", error:" + code + " desc:" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            TUILiveLog.d(TAG, "invite-->hangup success callID:" + realCallModel.callId);
                        }
                    });
                }
                break;

            default:
                break;
        }

        // 最后需要重新赋值
        if (realCallModel.action != CallModel.VIDEO_CALL_ACTION_REJECT &&
                realCallModel.action != CallModel.VIDEO_CALL_ACTION_HANGUP &&
                realCallModel.action != CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL &&
                model == null) {
            mLastCallModel = (CallModel) realCallModel.clone();
        }
        return callID;
    }

    private CallModel generateModel(int action) {
        CallModel callModel = (CallModel) mLastCallModel.clone();
        callModel.action = action;
        callModel.callType = mCurCallType;
        return callModel;
    }

    private static boolean isCollectionEmpty(Collection coll) {
        return coll == null || coll.size() == 0;
    }

    private static String CallModel2Json(CallModel callModel) {
        if (callModel == null) {
            return null;
        }
        return new Gson().toJson(callModel);
    }

    private static int generateRoomID() {
        Random random = new Random();
        return random.nextInt(ROOM_ID_MAX - ROOM_ID_MIN + 1) + ROOM_ID_MIN;
    }

    private class TRTCInteralListenerManager implements TRTCAVCallListener {
        private List<WeakReference<TRTCAVCallListener>> mWeakReferenceList;

        public TRTCInteralListenerManager() {
            mWeakReferenceList = new ArrayList<>();
        }

        public void addListenter(TRTCAVCallListener listener) {
            WeakReference<TRTCAVCallListener> listenerWeakReference = new WeakReference<>(listener);
            mWeakReferenceList.add(listenerWeakReference);
        }

        public void removeListenter(TRTCAVCallListener listener) {
            Iterator iterator = mWeakReferenceList.iterator();
            while (iterator.hasNext()) {
                WeakReference<TRTCAVCallListener> reference = (WeakReference<TRTCAVCallListener>) iterator.next();
                if (reference.get() == null) {
                    iterator.remove();
                    continue;
                }
                if (reference.get() == listener) {
                    iterator.remove();
                }
            }
        }

        @Override
        public void onError(int code, String msg) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onError(code, msg);
                }
            }
        }

        @Override
        public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, int callType) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onInvited(sponsor, userIdList, isFromGroup, callType);
                }
            }
        }

        @Override
        public void onGroupCallInviteeListUpdate(List<String> userIdList) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onGroupCallInviteeListUpdate(userIdList);
                }
            }
        }

        @Override
        public void onUserEnter(String userId) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserEnter(userId);
                }
            }
        }

        @Override
        public void onUserLeave(String userId) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserLeave(userId);
                }
            }
        }

        @Override
        public void onReject(String userId) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onReject(userId);
                }
            }
        }

        @Override
        public void onNoResp(String userId) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onNoResp(userId);
                }
            }
        }

        @Override
        public void onLineBusy(String userId) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onLineBusy(userId);
                }
            }
        }

        @Override
        public void onCallingCancel() {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onCallingCancel();
                }
            }
        }

        @Override
        public void onCallingTimeout() {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onCallingTimeout();
                }
            }
        }

        @Override
        public void onCallEnd() {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onCallEnd();
                }
            }
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserVideoAvailable(userId, isVideoAvailable);
                }
            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserAudioAvailable(userId, isVideoAvailable);
                }
            }
        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
            for (WeakReference<TRTCAVCallListener> reference : mWeakReferenceList) {
                TRTCAVCallListener listener = reference.get();
                if (listener != null) {
                    listener.onUserVoiceVolume(volumeMap);
                }
            }
        }
    }
}
