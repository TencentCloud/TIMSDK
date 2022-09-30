package com.tencent.qcloud.tuikit.tuicallkit;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallObserver;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallengine.utils.TUICallingConstants;
import com.tencent.qcloud.tuikit.tuicallengine.utils.TUICallingConstants.Scene;
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

    private List<String>            mUserIDs = new ArrayList<>();
    private TUICallDefine.MediaType mMediaType;
    private TUICallDefine.Role      mRole;

    private Runnable      mTimeRunnable;
    private int           mTimeCount;
    private Handler       mTimeHandler;
    private HandlerThread mTimeHandlerThread;

    private long mSelfLowQualityTime;
    private long mOtherUserLowQualityTime;

    private Scene                  mCallingScene;
    private List<CallingUserModel> mInviteeList = new ArrayList<>();
    private CallingUserModel       mInviter     = new CallingUserModel();
    private String                 mGroupId;

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
        if (TextUtils.isEmpty(userId)) {
            TUILog.i(TAG, "call, userId is empty ");
            return;
        }

        List<String> list = new ArrayList<>();
        list.add(userId);
        if (!checkCallingParams(list, "", "", callMediaType, TUICallDefine.Role.Caller)) {
            return;
        }
        checkCallingPermission(new TUICallback() {
            @Override
            public void onSuccess() {
                startCall();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                resetCall();
            }
        });
    }

    @Override
    public void groupCall(String groupId, List<String> userIdList, TUICallDefine.MediaType callMediaType) {
        if (!checkCallingParams(userIdList, "", groupId, callMediaType, TUICallDefine.Role.Caller)) {
            return;
        }
        checkCallingPermission(new TUICallback() {
            @Override
            public void onSuccess() {
                startCall();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                resetCall();
            }
        });
    }

    private boolean checkCallingParams(List<String> userIdList, String callerId, String groupId,
                                       TUICallDefine.MediaType type, TUICallDefine.Role role) {
        if (null == type || null == role) {
            TUILog.e(TAG, "checkCallingParams, param is error!!!");
            return false;
        }

        if (userIdList.size() > TUICallingConstants.MAX_USERS) {
            ToastUtil.toastLongMessage(mContext.getString(R.string.tuicalling_user_exceed_limit));
            TUILog.e(TAG, "checkCallingParams, exceeding max user number: 9");
            return false;
        }

        //when app comes back to foreground, start the call
        if (!DeviceUtils.isAppRunningForeground(mContext) && !PermissionUtils.hasPermission(mContext)) {
            TUILog.i(TAG, "isAppRunningForeground is false");
            mCallingBellFeature.startRing();
            return false;
        }

        mUserIDs = userIdList;
        mMediaType = type;
        mRole = role;
        mGroupId = groupId;

        for (String userId : mUserIDs) {
            if (!TextUtils.isEmpty(userId)) {
                CallingUserModel model = new CallingUserModel();
                model.userId = userId;
                mInviteeList.add(model);
            }
        }

        mInviter.userId = callerId;
        mCallingScene = initCallingScene(groupId);
        return true;
    }

    private void startCall() {
        TUILog.i(TAG, "startCall, mInviteeList: " + mInviteeList + " ,mInviter: " + mInviter
                + " ,groupId: " + mGroupId + " ,type: " + mMediaType + " ,role: " + mRole
                + " , mCallingScene: " + mCallingScene);

        if (Scene.GROUP_CALL.equals(mCallingScene) && mCallingViewManager != null) {
            mCallingViewManager.enableInviteUser(true);
        }

        if (TUICallDefine.Role.Caller.equals(mRole)) {
            TUICommonDefine.RoomId roomId = new TUICommonDefine.RoomId();
            roomId.intRoomId = generateRoomId();

            TUICallDefine.CallParams params = new TUICallDefine.CallParams();
            params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(mContext);

            if (!Scene.SINGLE_CALL.equals(mCallingScene)) {
                TUICallEngine.createInstance(mContext).groupCall(roomId, mGroupId, mUserIDs, mMediaType,
                        params, new TUICommonDefine.Callback() {
                            @Override
                            public void onSuccess() {
                                showCallingView();
                                mCallingBellFeature.startDialingMusic();
                            }

                            @Override
                            public void onError(int errCode, String errMsg) {
                                TUILog.i(TAG, " call error, errCode: " + errCode + " , errMsg: " + errMsg);
                                if (errCode == TUICallDefine.ERROR_PACKAGE_NOT_SUPPORTED) {
                                    String hint = mContext.getString(R.string.tuicalling_package_not_support);
                                    ToastUtil.toastLongMessage(hint);
                                }
                            }
                        });
            } else {
                if (mInviteeList.isEmpty()) {
                    return;
                }
                String userId = mInviteeList.get(0).userId;
                TUICallEngine.createInstance(mContext).call(roomId, userId, mMediaType, params,
                        new TUICommonDefine.Callback() {
                            @Override
                            public void onSuccess() {
                                showCallingView();
                                mCallingBellFeature.startDialingMusic();
                            }

                            @Override
                            public void onError(int errCode, String errMsg) {
                                TUILog.i(TAG, " call error, errCode: " + errCode + " , errMsg: " + errMsg);
                                if (errCode == TUICallDefine.ERROR_PACKAGE_NOT_PURCHASED) {
                                    String hint = mContext.getString(R.string.tuicalling_package_not_purchased);
                                    ToastUtil.toastLongMessage(hint);
                                }
                            }
                        });
            }
        } else {
            showCallingView();
            mCallingBellFeature.startRing();
        }
    }

    private void showCallingView() {
        mCallingViewManager.createCallingView(mInviteeList, mInviter, mMediaType, mRole, mCallingScene);
        TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Waiting);
        queryUserInfo();

        mCallingKeepAliveFeature.startKeepAlive();
        mCallingScreenSensorFeature.registerSensorEventListener();

        mCallingViewManager.setGroupId(mGroupId);
        mCallingViewManager.showCallingView();
    }

    @Override
    public void joinInGroupCall(TUICommonDefine.RoomId roomId, String groupId, TUICallDefine.MediaType mediaType) {
        mMediaType = mediaType;
        checkCallingPermission(new TUICallback() {
            @Override
            public void onSuccess() {

                TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Accept);

                mRole = TUICallDefine.Role.Called;
                mCallingScene = Scene.GROUP_CALL;

                TUICallEngine.createInstance(mContext).joinInGroupCall(roomId, groupId, mediaType,
                        new TUICommonDefine.Callback() {
                            @Override
                            public void onSuccess() {
                                mCallingViewManager.createGroupCallingAcceptView(mediaType, mCallingScene);

                                TUILog.i(TAG, "joinToCall, roomId: " + roomId + " ,groupId: " + groupId
                                        + " ,mediaType: " + mediaType);

                                mCallingViewManager.showCallingView();
                                showTimeCount();
                            }

                            @Override
                            public void onError(int errCode, String errMsg) {
                                resetCall();
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
            TUILog.i(TAG, "onCallReceived, callerId: " + callerId + " ,calleeIdList: " + calleeIdList
                    + " ,callMediaType: " + callMediaType + " ,groupId: " + groupId);

            if (!TUICallDefine.Status.None.equals(TUICallingStatusManager.sharedInstance(mContext).getCallStatus())
                    || TUICallDefine.MediaType.Unknown.equals(callMediaType)) {
                return;
            }

            if (!checkCallingParams(calleeIdList, callerId, groupId, callMediaType, TUICallDefine.Role.Called)) {
                return;
            }
            checkCallingPermission(new TUICallback() {
                @Override
                public void onSuccess() {
                    startCall();
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
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onCallCancelled");
                    resetCall();
                }
            });
        }

        @Override
        public void onCallBegin(TUICommonDefine.RoomId roomId, TUICallDefine.MediaType callMediaType,
                                TUICallDefine.Role callRole) {
            super.onCallBegin(roomId, callMediaType, callRole);
            TUILog.i(TAG, "onCallBegin, roomId: " + roomId + " , callMediaType: " + callMediaType
                    + " , callRole: " + callRole);

            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUICallDefine.Status status = TUICallingStatusManager.sharedInstance(mContext).getCallStatus();
                    if (TUICallDefine.Role.Caller.equals(mRole) && TUICallDefine.Status.Waiting.equals(status)) {
                        TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Accept);
                    } else if (TUICallDefine.Role.Called.equals(callRole)) {
                        mCallingBellFeature.stopMusic();
                        TUICallingStatusManager.sharedInstance(mContext).updateCallStatus(TUICallDefine.Status.Accept);
                    }
                    showTimeCount();
                }
            });
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
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onCallMediaTypeChanged, oldCallMediaType: "
                            + oldCallMediaType + " , newCallMediaType: " + newCallMediaType);
                    if (!oldCallMediaType.equals(newCallMediaType)) {
                        mCallingViewManager.updateCallType(newCallMediaType);
                    }
                }
            });
        }

        @Override
        public void onUserReject(String userId) {
            super.onUserReject(userId);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserReject, userId: " + userId);

                    CallingUserModel userModel = findCallingUserModel(userId);
                    mCallingViewManager.userLeave(userModel);
                    showUserToast(userModel, R.string.tuicalling_toast_user_reject_call);
                    mInviteeList.remove(userModel);
                }
            });
        }

        @Override
        public void onUserNoResponse(String userId) {
            super.onUserNoResponse(userId);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserNoResponse, userId: " + userId);

                    CallingUserModel userModel = findCallingUserModel(userId);
                    mCallingViewManager.userLeave(userModel);
                    showUserToast(userModel, R.string.tuicalling_toast_user_not_response);
                    mInviteeList.remove(userModel);
                }
            });
        }

        @Override
        public void onUserLineBusy(String userId) {
            super.onUserLineBusy(userId);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserLineBusy, userId: " + userId);

                    CallingUserModel userModel = findCallingUserModel(userId);
                    mCallingViewManager.userLeave(userModel);
                    showUserToast(userModel, R.string.tuicalling_toast_user_busy);
                    mInviteeList.remove(userModel);
                }
            });
        }

        @Override
        public void onUserJoin(String userId) {
            super.onUserJoin(userId);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserJoin, userId: " + userId);
                    mCallingBellFeature.stopMusic();

                    CallingUserModel userModel = findCallingUserModel(userId);
                    if (userModel == null) {
                        userModel = new CallingUserModel();
                        userModel.userId = userId;
                    }
                    mCallingViewManager.userEnter(userModel);
                }
            });
        }

        @Override
        public void onUserLeave(String userId) {
            super.onUserLeave(userId);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserLeave, userId: " + userId + " ,mInviteeList: " + mInviteeList);
                    CallingUserModel userModel = findCallingUserModel(userId);
                    mCallingViewManager.userLeave(userModel);
                    showUserToast(userModel, R.string.tuicalling_toast_user_end);
                    mInviteeList.remove(userModel);
                }
            });
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
            super.onUserVideoAvailable(userId, isVideoAvailable);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserVideoAvailable, userId: " + userId
                            + " ,isVideoAvailable: " + isVideoAvailable);

                    CallingUserModel model = findCallingUserModel(userId);
                    if (model != null && model.isVideoAvailable != isVideoAvailable) {
                        model.isVideoAvailable = isVideoAvailable;
                        mCallingViewManager.updateUser(model);
                    }
                }
            });
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isAudioAvailable) {
            super.onUserAudioAvailable(userId, isAudioAvailable);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    TUILog.i(TAG, "onUserAudioAvailable, userId: " + userId
                            + " ,isAudioAvailable: " + isAudioAvailable);

                    CallingUserModel model = findCallingUserModel(userId);
                    if (model != null && model.isAudioAvailable != isAudioAvailable) {
                        model.isAudioAvailable = isAudioAvailable;
                        mCallingViewManager.updateUser(model);
                    }
                }
            });
        }

        @Override
        public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
            super.onUserVoiceVolumeChanged(volumeMap);
            runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    if (Scene.SINGLE_CALL.equals(mCallingScene)) {
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
            });
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

                mCallingScene = null;
                mUserIDs.clear();
                mRole = TUICallDefine.Role.None;
                mMediaType = TUICallDefine.MediaType.Unknown;
                mGroupId = "";
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

    private Scene initCallingScene(String groupID) {
        if (!TextUtils.isEmpty(groupID)) {
            return Scene.GROUP_CALL;
        }
        if (TUICallDefine.Role.Caller == mRole) {
            return (mUserIDs.size() >= 2) ? Scene.MULTI_CALL : Scene.SINGLE_CALL;
        } else {
            return (mUserIDs.size() > 1) ? Scene.MULTI_CALL : Scene.SINGLE_CALL;
        }
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

    private void checkCallingPermission(TUICallback callback) {
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
                    callback.onError(-1, "permission refused");
                }
            }
        };
        if (TUICallDefine.MediaType.Video.equals(mMediaType)) {
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
}
