package com.tencent.qcloud.tuikit.tuicallkit;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.Scene;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.Status;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallObserver;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.Constants;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;
import com.tencent.qcloud.tuikit.tuicallkit.config.OfflinePushInfoConfig;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingKeepAliveFeature;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingScreenSensorFeature;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils;
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest;
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils;
import com.tencent.qcloud.tuikit.tuicallkit.view.TUICallingViewManager;
import com.tencent.trtc.TRTCCloud;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;

public final class TUICallKitImpl extends TUICallKit implements ITUINotification {
    private static final String TAG = "TUICallKit";

    private static TUICallKitImpl sInstance;
    private final  Context        mContext;
    private final  UserInfoUtils  mUserInfoUtils;

    private final CallingKeepAliveFeature    mCallingKeepAliveFeature;
    private final CallingScreenSensorFeature mCallingScreenSensorFeature;
    private final CallingBellFeature         mCallingBellFeature;
    private final TUICallingViewManager      mCallingViewManager;
    private final Handler                    mMainHandler = new Handler(Looper.getMainLooper());

    private Runnable      mTimeRunnable;
    private int           mTimeCount;
    private Handler       mTimeHandler;
    private HandlerThread mTimeHandlerThread;

    private long mSelfLowQualityTime;
    private long mOtherUserLowQualityTime;

    private List<CallingUserModel> mInviteeList = new ArrayList<>();
    private CallingUserModel       mInviter     = new CallingUserModel();

    public static TUICallKitImpl createInstance(Context context) {
        if (null == sInstance) {
            synchronized (TUICallKitImpl.class) {
                if (null == sInstance) {
                    sInstance = new TUICallKitImpl(context);
                }
            }
        }
        return sInstance;
    }

    private TUICallKitImpl(Context context) {
        mContext = context.getApplicationContext();
        TUICallEngine.createInstance(mContext).addObserver(mTUICallObserver);
        mCallingKeepAliveFeature = new CallingKeepAliveFeature(mContext);
        mCallingScreenSensorFeature = new CallingScreenSensorFeature(mContext);
        mCallingBellFeature = new CallingBellFeature(mContext);
        mCallingViewManager = new TUICallingViewManager(mContext);
        mUserInfoUtils = new UserInfoUtils();
        createTimeHandler();
        TUILog.i(TAG, "TUICallKitImpl init success.");
        registerCallingEvent();
    }

    private void registerCallingEvent() {
        //Login Event
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this);

        //TUICallkit Event
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CALL_STATUS_CHANGED, this);
    }

    @Override
    public void setSelfInfo(String nickname, String avatar, TUICommonDefine.Callback callback) {
        TUICallEngine.createInstance(mContext).setSelfInfo(nickname, avatar, callback);
    }

    @Override
    public void call(String userId, TUICallDefine.MediaType callMediaType) {
        TUICallDefine.CallParams params = new TUICallDefine.CallParams();
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(mContext);
        call(userId, callMediaType, params, null);
    }

    @Override
    public void call(String userId, TUICallDefine.MediaType callMediaType, TUICallDefine.CallParams params,
                     TUICommonDefine.Callback callback) {
        if (TextUtils.isEmpty(userId)) {
            TUILog.e(TAG, "call failed, userId is empty");
            callbackError(callback, TUICallDefine.ERROR_PARAM_INVALID, "call failed, userId is empty");
            return;
        }
        if (TUICallDefine.MediaType.Unknown.equals(callMediaType)) {
            TUILog.e(TAG, "call failed, callMediaType is Unknown");
            callbackError(callback, TUICallDefine.ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown");
            return;
        }

        checkCallingPermission(callMediaType, new TUICallback() {
            @Override
            public void onSuccess() {
                TUICommonDefine.RoomId roomId = new TUICommonDefine.RoomId();
                roomId.intRoomId = generateRoomId();

                TUICallEngine.createInstance(mContext).call(roomId, userId, callMediaType, params,
                        new TUICommonDefine.Callback() {
                            @Override
                            public void onSuccess() {
                                CallingUserModel model = new CallingUserModel();
                                model.userId = userId;
                                mInviteeList.add(model);
                                TUICallingStatusManager.sharedInstance(mContext).setMediaType(callMediaType);
                                TUICallingStatusManager.sharedInstance(mContext).setCallRole(TUICallDefine.Role.Caller);
                                TUICallingStatusManager.sharedInstance(mContext).setCallScene(Scene.SINGLE_CALL);

                                showCallingView();
                                mCallingBellFeature.startDialingMusic();
                                callbackSuccess(callback);
                            }

                            @Override
                            public void onError(int errCode, String errMsg) {
                                TUILog.e(TAG, "call failed, errCode: " + errCode + " ,errMsg: " + errMsg);
                                if (errCode == TUICallDefine.ERROR_PACKAGE_NOT_PURCHASED) {
                                    String hint = mContext.getString(R.string.tuicalling_package_not_purchased);
                                    ToastUtil.toastLongMessage(hint);
                                }
                                callbackError(callback, errCode, errMsg);
                            }
                        });
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                callbackError(callback, errorCode, errorMessage);
                resetCall();
            }
        });
    }

    @Override
    public void groupCall(String groupId, List<String> userIdList, TUICallDefine.MediaType callMediaType) {
        TUICallDefine.CallParams params = new TUICallDefine.CallParams();
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(mContext);
        groupCall(groupId, userIdList, callMediaType, params, null);
    }

    @Override
    public void groupCall(String groupId, List<String> userIdList, TUICallDefine.MediaType callMediaType,
                          TUICallDefine.CallParams params, TUICommonDefine.Callback callback) {
        if (TextUtils.isEmpty(groupId)) {
            TUILog.e(TAG, "groupCall failed, groupId is empty");
            callbackError(callback, TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, groupId is empty");
            return;
        }

        if (TUICallDefine.MediaType.Unknown.equals(callMediaType)) {
            TUILog.e(TAG, "groupCall failed, callMediaType is Unknown");
            callbackError(callback, TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, callMediaType is Unknown");
            return;
        }

        if (userIdList == null || userIdList.isEmpty()) {
            TUILog.e(TAG, "groupCall failed, userIdList is empty");
            callbackError(callback, TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, userIdList is empty");
            return;
        }

        if (userIdList.size() >= Constants.MAX_USER) {
            ToastUtil.toastLongMessage(mContext.getString(R.string.tuicalling_user_exceed_limit));
            TUILog.e(TAG, "groupCall failed, exceeding max user number: 9");
            callbackError(callback, TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, exceeding max user number");
            return;
        }

        checkCallingPermission(callMediaType, new TUICallback() {
            @Override
            public void onSuccess() {
                TUICommonDefine.RoomId roomId = new TUICommonDefine.RoomId();
                roomId.intRoomId = generateRoomId();

                TUICallEngine.createInstance(mContext).groupCall(roomId, groupId, userIdList, callMediaType,
                        params, new TUICommonDefine.Callback() {
                            @Override
                            public void onSuccess() {
                                for (String userId : userIdList) {
                                    if (!TextUtils.isEmpty(userId)) {
                                        CallingUserModel model = new CallingUserModel();
                                        model.userId = userId;
                                        mInviteeList.add(model);
                                    }
                                }
                                TUICallingStatusManager.sharedInstance(mContext).setMediaType(callMediaType);
                                TUICallingStatusManager.sharedInstance(mContext).setCallRole(TUICallDefine.Role.Caller);
                                TUICallingStatusManager.sharedInstance(mContext).setCallScene(Scene.GROUP_CALL);
                                TUICallingStatusManager.sharedInstance(mContext).setGroupId(groupId);

                                showCallingView();
                                mCallingBellFeature.startDialingMusic();
                                callbackSuccess(callback);
                            }

                            @Override
                            public void onError(int errCode, String errMsg) {
                                TUILog.e(TAG, "groupCall failed, errCode: " + errCode + " ,errMsg: " + errMsg);
                                if (errCode == TUICallDefine.ERROR_PACKAGE_NOT_SUPPORTED) {
                                    String hint = mContext.getString(R.string.tuicalling_package_not_support);
                                    ToastUtil.toastLongMessage(hint);
                                }
                                callbackError(callback, errCode, errMsg);
                            }
                        });
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                callbackError(callback, errorCode, errorMessage);
                resetCall();
            }
        });
    }

    private void showCallingView() {
        mCallingViewManager.createCallingView(mInviteeList, mInviter);
        TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Waiting);
        queryUserInfo();

        mCallingKeepAliveFeature.startKeepAlive();
        mCallingScreenSensorFeature.registerSensorEventListener();

        mCallingViewManager.showCallingView();
    }

    @Override
    public void joinInGroupCall(TUICommonDefine.RoomId roomId, String groupId, TUICallDefine.MediaType mediaType) {
        int intRoomId = (roomId != null) ? roomId.intRoomId : 0;
        if (intRoomId <= 0 || intRoomId >= Constants.ROOM_ID_MAX) {
            TUILog.e(TAG, "joinInGroupCall failed, roomId is invalid");
            return;
        }
        if (TextUtils.isEmpty(groupId)) {
            TUILog.e(TAG, "joinInGroupCall failed, groupId is empty");
            return;
        }
        if (TUICallDefine.MediaType.Unknown.equals(mediaType)) {
            TUILog.e(TAG, "joinInGroupCall failed, mediaType is unknown");
            return;
        }

        checkCallingPermission(mediaType, new TUICallback() {
            @Override
            public void onSuccess() {
                TUICallEngine.createInstance(mContext).joinInGroupCall(roomId, groupId, mediaType,
                        new TUICommonDefine.Callback() {
                            @Override
                            public void onSuccess() {
                                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(Status.Accept);
                                TUICallingStatusManager.sharedInstance(mContext).setMediaType(mediaType);
                                TUICallingStatusManager.sharedInstance(mContext).setCallScene(Scene.GROUP_CALL);
                                TUICallingStatusManager.sharedInstance(mContext).setCallRole(TUICallDefine.Role.Called);
                                TUICallingStatusManager.sharedInstance(mContext).setGroupId(groupId);
                                TUILog.i(TAG, "joinInGroupCall, roomId: " + roomId + " ,groupId: " + groupId
                                        + " ,mediaType: " + mediaType);

                                mCallingViewManager.createGroupCallingAcceptView();
                                mCallingViewManager.showCallingView();
                                showTimeCount();
                            }

                            @Override
                            public void onError(int errCode, String errMsg) {
                                if (errCode == TUICallDefine.ERROR_PACKAGE_NOT_SUPPORTED) {
                                    String hint = mContext.getString(R.string.tuicalling_package_not_support);
                                    ToastUtil.toastLongMessage(hint);
                                }
                            }
                        });
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                resetCall();
            }
        });
    }

    @Override
    public void setCallingBell(String filePath) {
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLING).put(CallingBellFeature.PROFILE_CALL_BELL, filePath);
    }

    @Override
    public void enableMuteMode(boolean enable) {
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLING).put(CallingBellFeature.PROFILE_MUTE_MODE, enable);
    }

    @Override
    public void enableFloatWindow(boolean enable) {
        mCallingViewManager.enableFloatWindow(enable);
    }

    public void queryOfflineCall() {
        TUICallEngine.createInstance(mContext).queryOfflineCall();
    }

    private final TUICallObserver mTUICallObserver = new TUICallObserver() {
        @Override
        public void onError(int code, String msg) {
            super.onError(code, msg);
            TUILog.e(TAG, "onError: code = " + code + " , msg = " + msg);
            ToastUtil.toastLongMessage(mContext.getString(R.string.tuicalling_toast_call_error_msg, code, msg));
        }

        @Override
        public void onCallReceived(String callerId, List<String> calleeIdList, String groupId,
                                   TUICallDefine.MediaType callMediaType) {
            super.onCallReceived(callerId, calleeIdList, groupId, callMediaType);

            if (TUICallDefine.MediaType.Unknown.equals(callMediaType)) {
                TUILog.e(TAG, "onCallReceived, callMediaType is Unknown");
                return;
            }

            if (calleeIdList == null || calleeIdList.isEmpty()) {
                TUILog.e(TAG, "onCallReceived, calleeIdList is empty");
                return;
            }

            if (calleeIdList.size() >= Constants.MAX_USER) {
                ToastUtil.toastLongMessage(mContext.getString(R.string.tuicalling_user_exceed_limit));
                TUILog.e(TAG, "onCallReceived, exceeding max user number: 9");
                return;
            }

            TUILog.i(TAG, "onCallReceived, callerId: " + callerId + " ,calleeIdList: " + calleeIdList
                    + " ,callMediaType: " + callMediaType + " ,groupId: " + groupId);

            //when app comes back to foreground, start the call
            if (!DeviceUtils.isAppRunningForeground(mContext) && !PermissionUtils.hasPermission(mContext)) {
                TUILog.i(TAG, "isAppRunningForeground is false");
                mCallingBellFeature.startRing();
                return;
            }

            checkCallingPermission(callMediaType, new TUICallback() {
                @Override
                public void onSuccess() {
                    for (String userId : calleeIdList) {
                        if (!TextUtils.isEmpty(userId)) {
                            CallingUserModel model = new CallingUserModel();
                            model.userId = userId;
                            mInviteeList.add(model);
                        }
                    }

                    mInviter.userId = callerId;
                    Scene scene;
                    if (!TextUtils.isEmpty(groupId)) {
                        scene = Scene.GROUP_CALL;
                    } else {
                        scene = (calleeIdList.size() > 1) ? Scene.MULTI_CALL : Scene.SINGLE_CALL;
                    }
                    TUICallingStatusManager.sharedInstance(mContext).setMediaType(callMediaType);
                    TUICallingStatusManager.sharedInstance(mContext).setCallRole(TUICallDefine.Role.Called);
                    TUICallingStatusManager.sharedInstance(mContext).setCallScene(scene);
                    TUICallingStatusManager.sharedInstance(mContext).setGroupId(groupId);

                    showCallingView();
                    mCallingBellFeature.startRing();
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    TUICallEngine.createInstance(mContext).reject(null);
                    resetCall();
                }
            });
        }

        @Override
        public void onCallCancelled(String callerId) {
            super.onCallCancelled(callerId);
            TUILog.i(TAG, "onCallCancelled");
            resetCall();
        }

        @Override
        public void onCallBegin(TUICommonDefine.RoomId roomId, TUICallDefine.MediaType callMediaType,
                                TUICallDefine.Role callRole) {
            super.onCallBegin(roomId, callMediaType, callRole);
            TUILog.i(TAG, "onCallBegin, roomId: " + roomId + " , callMediaType: " + callMediaType
                    + " , callRole: " + callRole);

            mCallingBellFeature.stopMusic();
            TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Accept);
            showTimeCount();
        }

        @Override
        public void onCallEnd(TUICommonDefine.RoomId roomId, TUICallDefine.MediaType callMediaType,
                              TUICallDefine.Role callRole, long totalTime) {
            super.onCallEnd(roomId, callMediaType, callRole, totalTime);
            resetCall();
        }

        @Override
        public void onCallMediaTypeChanged(TUICallDefine.MediaType oldCallMediaType,
                                           TUICallDefine.MediaType newCallMediaType) {
            super.onCallMediaTypeChanged(oldCallMediaType, newCallMediaType);
            TUILog.i(TAG, "onCallMediaTypeChanged, oldCallMediaType: "
                    + oldCallMediaType + " , newCallMediaType: " + newCallMediaType);
            if (!oldCallMediaType.equals(newCallMediaType)) {
                TUICallingStatusManager.sharedInstance(mContext).setMediaType(newCallMediaType);
            }
        }

        @Override
        public void onUserReject(String userId) {
            super.onUserReject(userId);
            TUILog.i(TAG, "onUserReject, userId: " + userId);

            CallingUserModel userModel = findCallingUserModel(userId);
            mCallingViewManager.userLeave(userModel);
            showUserToast(userModel, R.string.tuicalling_toast_user_reject_call);
            mInviteeList.remove(userModel);
        }

        @Override
        public void onUserNoResponse(String userId) {
            super.onUserNoResponse(userId);
            TUILog.i(TAG, "onUserNoResponse, userId: " + userId);

            CallingUserModel userModel = findCallingUserModel(userId);
            mCallingViewManager.userLeave(userModel);
            showUserToast(userModel, R.string.tuicalling_toast_user_not_response);
            mInviteeList.remove(userModel);
        }

        @Override
        public void onUserLineBusy(String userId) {
            super.onUserLineBusy(userId);
            TUILog.i(TAG, "onUserLineBusy, userId: " + userId);

            CallingUserModel userModel = findCallingUserModel(userId);
            mCallingViewManager.userLeave(userModel);
            showUserToast(userModel, R.string.tuicalling_toast_user_busy);
            mInviteeList.remove(userModel);
        }

        @Override
        public void onUserJoin(String userId) {
            super.onUserJoin(userId);
            TUILog.i(TAG, "onUserJoin, userId: " + userId);

            CallingUserModel userModel = findCallingUserModel(userId);
            if (userModel == null) {
                userModel = new CallingUserModel();
                userModel.userId = userId;
            }
            mCallingViewManager.userEnter(userModel);
        }

        @Override
        public void onUserLeave(String userId) {
            super.onUserLeave(userId);
            TUILog.i(TAG, "onUserLeave, userId: " + userId + " ,mInviteeList: " + mInviteeList);
            CallingUserModel userModel = findCallingUserModel(userId);
            mCallingViewManager.userLeave(userModel);
            showUserToast(userModel, R.string.tuicalling_toast_user_end);
            mInviteeList.remove(userModel);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
            super.onUserVideoAvailable(userId, isVideoAvailable);
            TUILog.i(TAG, "onUserVideoAvailable, userId: " + userId + " ,isVideoAvailable: " + isVideoAvailable);

            CallingUserModel model = findCallingUserModel(userId);
            if (model != null && model.isVideoAvailable != isVideoAvailable) {
                model.isVideoAvailable = isVideoAvailable;
                mCallingViewManager.updateUser(model);
            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isAudioAvailable) {
            super.onUserAudioAvailable(userId, isAudioAvailable);
            TUILog.i(TAG, "onUserAudioAvailable, userId: " + userId + " ,isAudioAvailable: " + isAudioAvailable);

            CallingUserModel model = findCallingUserModel(userId);
            if (model != null && model.isAudioAvailable != isAudioAvailable) {
                model.isAudioAvailable = isAudioAvailable;
                mCallingViewManager.updateUser(model);
            }
        }

        @Override
        public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
            super.onUserVoiceVolumeChanged(volumeMap);
            if (Scene.SINGLE_CALL.equals(TUICallingStatusManager.sharedInstance(mContext).getCallScene())) {
                return;
            }
            for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
                if (null != entry && !TextUtils.isEmpty(entry.getKey())) {
                    CallingUserModel userModel = findCallingUserModel(entry.getKey());
                    if (userModel != null && userModel.volume != entry.getValue()) {
                        userModel.volume = entry.getValue();
                        mCallingViewManager.updateUser(userModel);
                    }
                }
            }
        }

        @Override
        public void onUserNetworkQualityChanged(List<TUICommonDefine.NetworkQualityInfo> networkQualityList) {
            super.onUserNetworkQualityChanged(networkQualityList);
            updateNetworkQuality(networkQualityList);
        }

        @Override
        public void onKickedOffline() {
            super.onKickedOffline();
            TUICallEngine.createInstance(mContext).hangup(null);
            resetCall();
        }

        @Override
        public void onUserSigExpired() {
            super.onUserSigExpired();
            TUICallEngine.createInstance(mContext).hangup(null);
            resetCall();
        }
    };

    private void resetCall() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TUILog.i(TAG, "resetCall");

                stopTimeCount();
                mCallingBellFeature.stopMusic();
                mCallingKeepAliveFeature.stopKeepAlive();
                mCallingScreenSensorFeature.unregisterSensorEventListener();

                mCallingViewManager.closeCallingView();
                mInviter = new CallingUserModel();
                mInviteeList.clear();
                TUICallingStatusManager.sharedInstance(mContext).clear();
            }
        });
    }

    private void runOnMainThread(Runnable task) {
        if (null != task) {
            mMainHandler.post(task);
        }
    }

    private void queryUserInfo() {
        ArrayList<CallingUserModel> list = new ArrayList<>();
        list.add(mInviter);
        list.addAll(mInviteeList);
        mUserInfoUtils.getUserInfo(list, new UserInfoUtils.UserCallback() {
            @Override
            public void onSuccess(List<CallingUserModel> list) {
                if (null == list || list.isEmpty()) {
                    return;
                }
                for (CallingUserModel model : list) {
                    if (null != model && !TextUtils.isEmpty(model.userId)) {
                        CallingUserModel userModel = findCallingUserModel(model.userId);
                        if (null != userModel) {
                            userModel.userName = model.userName;
                            userModel.userAvatar = model.userAvatar;
                        }
                    }
                }
                TUILog.i(TAG, "queryUserInfo, mInviteeList: " + mInviteeList);
                mCallingViewManager.updateCallingUserView(mInviteeList, mInviter);
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                TUILog.i(TAG, "queryUserInfo failed, errorCode: " + errorCode + " ,errorMsg: " + errorMsg);
            }
        });
    }

    private void showUserToast(CallingUserModel model, int msgId) {
        if (null == model || TextUtils.isEmpty(model.userId)) {
            TUILog.w(TAG, "showUserToast, model or userId is empty, model: " + model);
            return;
        }
        if (!TextUtils.isEmpty(model.userName)) {
            ToastUtil.toastLongMessage(mContext.getString(msgId, model.userName));
            return;
        }
        UserInfoUtils userInfoUtils = new UserInfoUtils();
        userInfoUtils.getUserInfo(model.userId, new UserInfoUtils.UserCallback() {
            @Override
            public void onSuccess(List<CallingUserModel> list) {
                if (null == list || list.isEmpty() || null == list.get(0) || TextUtils.isEmpty(list.get(0).userId)) {
                    ToastUtil.toastLongMessage(mContext.getString(msgId, model.userId));
                    return;
                }

                model.userName = list.get(0).userName;
                model.userAvatar = list.get(0).userAvatar;
                ToastUtil.toastLongMessage(mContext.getString(msgId, model.userName));
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                ToastUtil.toastLongMessage(mContext.getString(msgId, model.userId));
            }
        });
    }

    private CallingUserModel findCallingUserModel(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        if (userId.equals(mInviter.userId)) {
            return mInviter;
        } else {
            for (CallingUserModel model : mInviteeList) {
                if (null != model && !TextUtils.isEmpty(model.userId) && userId.equals(model.userId)) {
                    return model;
                }
            }
        }
        return null;
    }

    private void createTimeHandler() {
        mTimeHandlerThread = new HandlerThread("time-count-thread");
        mTimeHandlerThread.start();
        mTimeHandler = new Handler(mTimeHandlerThread.getLooper());
    }

    private void showTimeCount() {
        if (mTimeRunnable != null) {
            return;
        }
        TUILog.i(TAG, "showTimeCount");
        mTimeCount = 0;
        mTimeRunnable = new Runnable() {
            @Override
            public void run() {
                mTimeCount++;
                mCallingViewManager.userCallingTimeStr(getShowTime(mTimeCount));
                mTimeHandler.postDelayed(mTimeRunnable, 1000);
            }
        };
        boolean isOk = mTimeHandler.postDelayed(mTimeRunnable, 1000);
        if (!isOk) {
            createTimeHandler();
            mTimeHandler.postDelayed(mTimeRunnable, 1000);
        }
    }

    private String getShowTime(int count) {
        return mContext.getString(R.string.tuicalling_called_time_format, count / 60, count % 60);
    }

    private void stopTimeCount() {
        TUILog.i(TAG, "stopTimeCount");
        mTimeHandler.removeCallbacks(mTimeRunnable);
        mTimeRunnable = null;
        mTimeHandlerThread.quit();
        mTimeCount = 0;
    }

    private void updateNetworkQuality(List<TUICommonDefine.NetworkQualityInfo> networkQualityList) {
        if (networkQualityList.isEmpty()) {
            return;
        }
        TUICommonDefine.NetworkQualityInfo localInfo = null;
        Iterator<TUICommonDefine.NetworkQualityInfo> iterator = networkQualityList.iterator();
        while (iterator.hasNext()) {
            TUICommonDefine.NetworkQualityInfo tempInfo = iterator.next();
            if (TUILogin.getLoginUser().equals(tempInfo.userId)) {
                localInfo = tempInfo;
                break;
            }
        }
        boolean isLocalLowQuality = false;
        if (localInfo != null) {
            isLocalLowQuality = isLowQuality(localInfo.quality);
        }
        if (isLocalLowQuality) {
            updateLowQualityTip(true);
        } else if (iterator.hasNext()) {
            TUICommonDefine.NetworkQualityInfo remoteInfo = iterator.next();
            if (isLowQuality(remoteInfo.quality)) {
                updateLowQualityTip(false);
            }
        }
    }

    private boolean isLowQuality(TUICommonDefine.NetworkQuality quality) {
        if (null == quality) {
            return false;
        }
        boolean lowQuality;
        switch (quality) {
            case Vbad:
            case Down:
                lowQuality = true;
                break;
            default:
                lowQuality = false;
        }
        return lowQuality;
    }

    private void updateLowQualityTip(boolean isSelf) {
        long currentTime = System.currentTimeMillis();
        if (isSelf) {
            if (currentTime - mSelfLowQualityTime > Constants.MIN_DURATION_SHOW_LOW_QUALITY) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_self_network_low_quality));
                mSelfLowQualityTime = currentTime;
            }
        } else {
            if (currentTime - mOtherUserLowQualityTime > Constants.MIN_DURATION_SHOW_LOW_QUALITY) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_other_party_network_low_quality));
                mOtherUserLowQualityTime = currentTime;
            }
        }
    }

    private void checkCallingPermission(TUICallDefine.MediaType mediaType, TUICallback callback) {
        PermissionRequest.PermissionCallback permissionCallback = new PermissionRequest.PermissionCallback() {
            @Override
            public void onGranted() {
                super.onGranted();
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onDialogRefused() {
                super.onDialogRefused();
                if (callback != null) {
                    callback.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "permission denied");
                }
            }
        };
        if (TUICallDefine.MediaType.Video.equals(mediaType)) {
            PermissionRequest.requestPermission(mContext, PermissionRequest.PERMISSION_MICROPHONE,
                    PermissionRequest.PERMISSION_CAMERA, permissionCallback);
        } else {
            PermissionRequest.requestPermission(mContext, PermissionRequest.PERMISSION_MICROPHONE, permissionCallback);
        }
    }

    private int generateRoomId() {
        return new Random().nextInt(Constants.ROOM_ID_MAX - Constants.ROOM_ID_MIN + 1) + Constants.ROOM_ID_MIN;
    }

    private void initCallEngine() {
        TUICallEngine.createInstance(mContext).init(TUILogin.getSdkAppId(), TUILogin.getLoginUser(),
                TUILogin.getUserSig(), new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(int errCode, String errMsg) {
                    }
                });
        initCallVideoParams();
        initCallBeautyParams();
    }

    private void initCallVideoParams() {
        //set video render params of loginUser
        TUICommonDefine.VideoRenderParams renderParams = new TUICommonDefine.VideoRenderParams();
        renderParams.fillMode = TUICommonDefine.VideoRenderParams.FillMode.Fill;
        renderParams.rotation = TUICommonDefine.VideoRenderParams.Rotation.Rotation_0;
        String user = TUILogin.getLoginUser();
        TUICallEngine.createInstance(mContext).setVideoRenderParams(user, renderParams, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onError(int errCode, String errMsg) {
            }
        });

        //set video encoder params
        TUICommonDefine.VideoEncoderParams encoderParams = new TUICommonDefine.VideoEncoderParams();
        encoderParams.resolution = TUICommonDefine.VideoEncoderParams.Resolution.Resolution_640_360;
        encoderParams.resolutionMode = TUICommonDefine.VideoEncoderParams.ResolutionMode.Portrait;
        TUICallEngine.createInstance(mContext).setVideoEncoderParams(encoderParams, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onError(int errCode, String errMsg) {
            }
        });
    }

    private void initCallBeautyParams() {
        TRTCCloud trtcCloud = TUICallEngine.createInstance(mContext).getTRTCCloudInstance();
        TXBeautyManager txBeautyManager = trtcCloud.getBeautyManager();
        txBeautyManager.setBeautyStyle(TXBeautyManager.TXBeautyStyleNature);
        txBeautyManager.setBeautyLevel(6);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        //Login Event
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS.equals(subKey)) {
                //logout succeed: if user is in the call, end the call first and then clean data
                TUICallEngine.createInstance(mContext).hangup(null);
                TUICallEngine.destroyInstance();
                resetCall();
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS.equals(subKey)) {
                //login succeed: add "TUICallObserver" again
                TUICallEngine.createInstance(mContext).addObserver(mTUICallObserver);
                //login succeed: initialize "TUICallEngine"
                initCallEngine();
            }
        }

        //TUICallkit Event
        if (Constants.EVENT_TUICALLING_CHANGED.equals(key)
                && Constants.EVENT_SUB_CALL_STATUS_CHANGED.equals(subKey) && param != null) {
            if (TUICallDefine.Status.None.equals(param.get(Constants.CALL_STATUS))) {
                resetCall();
            }
        }
    }

    public void callbackSuccess(TUICommonDefine.Callback callback) {
        if (callback != null) {
            callback.onSuccess();
        }
    }

    public void callbackError(TUICommonDefine.Callback callback, int errCode, String errMsg) {
        if (callback != null) {
            callback.onError(errCode, errMsg);
        }
    }
}
