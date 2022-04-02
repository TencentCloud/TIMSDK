package com.tencent.liteav.trtccalling;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.liteav.trtccalling.model.impl.TRTCCallingCallback;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.audiocall.TUICallAudioView;
import com.tencent.liteav.trtccalling.ui.audiocall.TUIGroupCallAudioView;
import com.tencent.liteav.trtccalling.ui.base.BaseCallActivity;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.liteav.trtccalling.ui.base.Status;
import com.tencent.liteav.trtccalling.ui.service.TUICallService;
import com.tencent.liteav.trtccalling.ui.videocall.TUICallVideoView;
import com.tencent.liteav.trtccalling.ui.videocall.TUIGroupCallVideoView;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * TUICalling模块对外接口
 */
public final class TUICallingImpl implements TUICalling, TRTCCallingDelegate {
    private static final String TAG = "TUICallingImpl";

    private static final int MAX_USERS = 8; //最大通话数为9(需包含自己)

    private static TUICallingImpl sInstance;

    private         Context            mContext;
    private         TUICallingListener mTUICallingListener;
    protected final Handler            mMainHandler = new Handler(Looper.getMainLooper());

    private boolean  mEnableFloatWindow     = false;  // 是否开启悬浮窗,默认关闭,用户决定是否开启
    private boolean  mEnableCustomViewRoute = false;  // 是否开启自定义视图
    private String[] mUserIDs;
    private Type     mType;
    private Role     mRole;
    private long     mStartTime;
    private String   mGroupID;
    private boolean  mIsFromGroup;

    private BaseTUICallView mCallView;

    private CallingManagerListener mCallingManagerListener;

    public static final TUICalling sharedInstance(Context context) {
        if (null == sInstance) {
            synchronized (TUICallingImpl.class) {
                if (null == sInstance) {
                    sInstance = new TUICallingImpl(context);
                }
            }
        }
        return sInstance;
    }

    private TUICallingImpl(Context context) {
        mContext = context.getApplicationContext();
        TUICallService.start(context);
        TRTCCalling.sharedInstance(mContext).addDelegate(this);
        TRTCLogger.d(TAG, "TUICallingImpl init success.");
    }

    public void setCallingManagerListener(CallingManagerListener listener) {
        mCallingManagerListener = listener;
    }

    @Override
    public void setUserNickname(String nickname, TUICallingCallback callback) {
        TRTCCalling.sharedInstance(mContext).setUserNickname(nickname, new TRTCCallingCallback() {
            @Override
            public void onCallback(int code, String msg) {
                TRTCLogger.d(TAG, "setUserNickname code:" + code + " , msg:" + msg);
                if (null != callback) {
                    callback.onCallback(code, msg);
                }
            }
        });
    }

    @Override
    public void setUserAvatar(String avatar, TUICallingCallback callback) {
        TRTCCalling.sharedInstance(mContext).setUserAvatar(avatar, new TRTCCallingCallback() {
            @Override
            public void onCallback(int code, String msg) {
                TRTCLogger.d(TAG, "setUserAvatar code:" + code + " , msg:" + msg);
                if (null != callback) {
                    callback.onCallback(code, msg);
                }
            }
        });
    }

    @Override
    public void call(final String[] userIDs, final Type type) {
        internalCall(userIDs, "", "", false, type, Role.CALL);
    }

    public void internalCall(final String[] userIDs, String groupID, final Type type, final Role role) {
        internalCall(userIDs, "", groupID, !TextUtils.isEmpty(groupID), type, role);
    }

    void internalCall(final String[] userIDs, final String sponsorID, final String groupID, final boolean isFromGroup, final Type type, final Role role) {
        //当前悬浮窗显示,说明在通话流程中,不能再发起通话
        if (Status.mIsShowFloatWindow) {
            ToastUtils.showShort(mContext.getString(R.string.trtccalling_is_calling));
            return;
        }

        //最大支持9人,超过9人,不能发起通话
        if (userIDs.length > MAX_USERS) {
            ToastUtils.showShort(mContext.getString(R.string.trtccalling_user_exceed_limit));
            return;
        }

        if (null == type || null == role) {
            Log.e(TAG, "param is error!!!");
            return;
        }
        Log.d(TAG, String.format("internalCall, userIDs=%s, sponsorID=%s, groupID=%s, type=%s, role=%s", Arrays.toString(userIDs), sponsorID, groupID, type, role));
        mStartTime = System.currentTimeMillis();
        mUserIDs = null == userIDs ? new String[0] : userIDs;
        mGroupID = groupID;
        mIsFromGroup = isFromGroup;
        mType = type;
        mRole = role;
        if (mEnableCustomViewRoute) {
            if (Type.AUDIO == type) {
                if (isGroupCall(groupID, userIDs, role, isFromGroup)) {
                    mCallView = new TUIGroupCallAudioView(mContext, role, type, userIDs, sponsorID, groupID, isFromGroup);
                } else {
                    mCallView = new TUICallAudioView(mContext, role, type, userIDs, sponsorID, groupID, isFromGroup);
                }
            } else if (Type.VIDEO == type) {
                if (isGroupCall(groupID, userIDs, role, isFromGroup)) {
                    mCallView = new TUIGroupCallVideoView(mContext, role, type, userIDs, sponsorID, groupID, isFromGroup);
                } else {
                    mCallView = new TUICallVideoView(mContext, role, type, userIDs, sponsorID, groupID, isFromGroup, null);
                }
            }
            //用户自加载CallView时,不支持悬浮窗功能
            mCallView.enableFloatWindow(false);
            if (null != mTUICallingListener) {
                mTUICallingListener.onCallStart(userIDs, type, role, mCallView);
            }
        } else {
            Runnable task = new Runnable() {
                @Override
                public void run() {
                    Intent intent = new Intent(mContext, BaseCallActivity.class);
                    intent.putExtra(TUICallingConstants.PARAM_NAME_TYPE, type);
                    intent.putExtra(TUICallingConstants.PARAM_NAME_ROLE, role);
                    if (Role.CALLED == role) {
                        intent.putExtra(TUICallingConstants.PARAM_NAME_SPONSORID, sponsorID);
                        intent.putExtra(TUICallingConstants.PARAM_NAME_ISFROMGROUP, isFromGroup);
                    }
                    intent.putExtra(TUICallingConstants.PARAM_NAME_USERIDS, userIDs);
                    intent.putExtra(TUICallingConstants.PARAM_NAME_GROUPID, groupID);
                    intent.putExtra(TUICallingConstants.PARAM_NAME_FLOATWINDOW, mEnableFloatWindow);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    mContext.startActivity(intent);
                }
            };
            mMainHandler.post(task);
            if (null != mTUICallingListener) {
                mTUICallingListener.onCallStart(userIDs, type, role, null);
            }
        }
    }

    private boolean isGroupCall(String groupID, String[] userIDs, TUICalling.Role role, boolean isFromGroup) {
        if (!TextUtils.isEmpty(groupID)) {
            return true;
        }
        if (TUICalling.Role.CALL == role) {
            return userIDs.length >= 2;
        } else {
            return userIDs.length >= 1 || isFromGroup;
        }
    }

    @Override
    public void setCallingListener(TUICallingListener listener) {
        mTUICallingListener = listener;
    }

    @Override
    public void setCallingBell(String filePath) {
        TRTCCalling.sharedInstance(mContext).setCallingBell(filePath);
    }

    @Override
    public void enableMuteMode(boolean enable) {
        TRTCCalling.sharedInstance(mContext).enableMuteMode(enable);
    }

    @Override
    public void enableFloatWindow(boolean enable) {
        mEnableFloatWindow = enable;
    }

    @Override
    public void enableCustomViewRoute(boolean enable) {
        mEnableCustomViewRoute = enable;
    }

    @Override
    public void queryOfflineCalling() {
        TRTCCalling.sharedInstance(mContext).queryOfflineCallingInfo();
    }

    @Override
    public void onError(int code, String msg) {
        Log.d(TAG, "onError: code = " + code + " , msg = " + msg);
    }

    @Override
    public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, final int callType) {
        Log.d(TAG, String.format("onInvited enter, sponsor=%s, userIdList=%s, isFromGroup=%s, callType=%s", sponsor, Arrays.toString(userIdList.toArray()), isFromGroup, callType));
        if (TRTCCalling.TYPE_VIDEO_CALL != callType && TRTCCalling.TYPE_AUDIO_CALL != callType) {
            return;
        }
        final Type type = TRTCCalling.TYPE_AUDIO_CALL == callType ? Type.AUDIO : Type.VIDEO;
        String[] userIDs = userIdList.toArray(new String[userIdList.size()]);
        if (null != mTUICallingListener && !mTUICallingListener.shouldShowOnCallView()) {
            // 直接挂断
            TRTCCalling.sharedInstance(mContext).hangup();
            mTUICallingListener.onCallEnd(userIDs, type, Role.CALLED, 0);
        } else {
            internalCall(userIDs, sponsor, "", isFromGroup, type, Role.CALLED);
        }
    }

    @Override
    public void onGroupCallInviteeListUpdate(List<String> userIdList) {
        Log.d(TAG, "onGroupCallInviteeListUpdate enter");

    }

    @Override
    public void onUserEnter(String userId) {
        Log.d(TAG, "onUserEnter enter");
    }

    @Override
    public void onUserLeave(String userId) {
        Log.d(TAG, "onUserLeave enter");
        if (null == userId) {
            return;
        }
        //有用户退出时,根据单聊/群聊去做不同的处理
        if (isGroupCall(mGroupID, mUserIDs, mRole, mIsFromGroup)) {
            Log.d(TAG, "onUserLeave: userId = " + userId);
        } else {
            onCallEnd();
        }
    }

    @Override
    public void onReject(String userId) {
        Log.d(TAG, "onReject enter");
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mCallingManagerListener != null) {
                    mCallingManagerListener.onEvent(TUICallingConstants.EVENT_ACTIVE_HANGUP, new Bundle());
                }
                if (null != mTUICallingListener) {
                    mTUICallingListener.onCallEvent(Event.CALL_END, mType, mRole, TUICallingConstants.EVENT_CALL_HANG_UP);
                }
                onCallEnd();
            }
        });

    }

    @Override
    public void onNoResp(String userId) {
        Log.d(TAG, "onNoResp enter");
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mTUICallingListener) {
                    mTUICallingListener.onCallEvent(Event.CALL_FAILED, mType, mRole, TUICallingConstants.EVENT_CALL_NO_RESP);
                }
                onCallEnd();
            }
        });
    }

    @Override
    public void onLineBusy(String userId) {
        Log.d(TAG, "onLineBusy enter");
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mTUICallingListener) {
                    mTUICallingListener.onCallEvent(Event.CALL_FAILED, mType, mRole, TUICallingConstants.EVENT_CALL_LINE_BUSY);
                }
                onCallEnd();
            }
        });
    }

    @Override
    public void onCallingCancel() {
        Log.d(TAG, "onCallingCancel enter");
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mCallingManagerListener != null) {
                    mCallingManagerListener.onEvent(TUICallingConstants.EVENT_ACTIVE_HANGUP, new Bundle());
                }
                if (null != mTUICallingListener) {
                    mTUICallingListener.onCallEvent(Event.CALL_END, mType, mRole, TUICallingConstants.EVENT_CALL_CNACEL);
                }
                onCallEnd();
            }
        });
    }

    @Override
    public void onCallingTimeout() {
        Log.d(TAG, "onCallingTimeout enter");
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mTUICallingListener) {
                    mTUICallingListener.onCallEvent(Event.CALL_END, mType, mRole, TUICallingConstants.EVENT_CALL_TIMEOUT);
                }
                onCallEnd();
            }
        });
    }

    @Override
    public void onCallEnd() {
        Log.d(TAG, "onCallEnd enter");
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mTUICallingListener) {
                    mTUICallingListener.onCallEnd(mUserIDs, mType, mRole, System.currentTimeMillis() - mStartTime);
                }
            }
        });
    }

    @Override
    public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
        Log.d(TAG, "onUserVideoAvailable enter");
    }

    @Override
    public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {
        Log.d(TAG, "onUserAudioAvailable enter");
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
    }

    @Override
    public void onSwitchToAudio(boolean success, String message) {
        Log.d(TAG, "onSwitchToAudio enter");
    }

    public interface CallingManagerListener {
        void onEvent(String key, Bundle bundle);
    }
}
