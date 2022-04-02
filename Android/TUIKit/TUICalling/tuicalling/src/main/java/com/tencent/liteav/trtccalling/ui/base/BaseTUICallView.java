package com.tencent.liteav.trtccalling.ui.base;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.liteav.trtccalling.model.impl.UserModel;
import com.tencent.liteav.trtccalling.model.impl.base.CallingInfoManager;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.ui.floatwindow.FloatWindowService;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class BaseTUICallView extends FrameLayout implements TRTCCallingDelegate {
    private static final String TAG = "BaseTUICallView";

    private static final int MIN_DURATION_SHOW_LOW_QUALITY = 5000; //显示网络不佳最小间隔时间

    //音视频通话基础信息
    protected Context         mContext;
    protected TRTCCalling     mTRTCCalling;
    protected UserModel       mSelfModel;
    protected TUICalling.Role mRole;
    protected TUICalling.Type mCallType;
    protected String[]        mUserIDs;
    protected String          mSponsorID;
    protected String          mGroupID;
    protected boolean         mIsFromGroup;
    protected Handler         mMainHandler = new Handler(Looper.getMainLooper());

    private long mSelfLowQualityTime;
    private long mOtherPartyLowQualityTime;

    //通话时长相关
    protected Runnable      mTimeRunnable;
    protected int           mTimeCount;
    protected Handler       mTimeHandler;
    protected HandlerThread mTimeHandlerThread;

    //音视频通用字段
    protected List<UserModel>        mCallUserInfoList = new ArrayList<>(); // 主叫方保存的被叫信息
    protected Map<String, UserModel> mCallUserModelMap = new HashMap<>();
    protected UserModel              mSponsorUserInfo;                      // 被叫方保存的主叫方的信息
    protected List<UserModel>        mOtherInviteeList = new ArrayList<>(); // 被叫方保存的其他被叫的信息
    protected boolean                mIsHandsFree      = true;              // 默认开启扬声器
    protected boolean                mIsMuteMic        = false;
    protected boolean                mIsInRoom         = false;             // 被叫是否已接听进房(true:已接听进房 false:未接听)
    private   UserModel              mRemovedUserModel;                     // 被删除的用户(该用户拒接,无响应或者超时了)

    //视频相关字段
    protected boolean mIsFrontCamera = true;
    protected boolean mIsCameraOpen  = true;
    protected boolean mIsCalledClick = false; // 被叫方点击转换语音
    protected boolean mIsCalling     = false; // 正在通话中

    //公共视图
    private ImageView mImageBack;          // 返回按钮,展示悬浮窗

    public BaseTUICallView(Context context, TUICalling.Role role, TUICalling.Type type, String[] userIDs,
                           String sponsorID, String groupID, boolean isFromGroup) {
        super(context);
        mContext = context;
        mTRTCCalling = TRTCCalling.sharedInstance(context);
        mSelfModel = new UserModel();
        mSelfModel.userId = TUILogin.getUserId();
        mSelfModel.userName = TUILogin.getLoginUser();
        mRole = role;
        mCallType = type;
        mUserIDs = userIDs;
        mSponsorID = sponsorID;
        mGroupID = groupID;
        mIsFromGroup = isFromGroup;
        initTimeHandler();
        initView();
        initData();
        initListener();
    }

    //用户是否支持显示悬浮窗:
    public void enableFloatWindow(boolean enable) {
        mImageBack.setVisibility(enable ? VISIBLE : GONE);
    }

    private void initTimeHandler() {
        // 初始化计时线程
        mTimeHandlerThread = new HandlerThread("time-count-thread");
        mTimeHandlerThread.start();
        mTimeHandler = new Handler(mTimeHandlerThread.getLooper());
    }

    protected void runOnUiThread(Runnable task) {
        if (null != task) {
            mMainHandler.post(task);
        }
    }

    private void initData() {
        if (mRole == TUICalling.Role.CALLED) {
            // 被叫方
            if (!TextUtils.isEmpty(mSponsorID)) {
                mSponsorUserInfo = new UserModel();
                mSponsorUserInfo.userId = mSponsorID;
            }
            if (null != mUserIDs) {
                for (String userId : mUserIDs) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userId;
                    mOtherInviteeList.add(userModel);
                    mCallUserModelMap.put(userModel.userId, userModel);
                }
            }
        } else {
            // 主叫方
            if (null != mSelfModel) {
                for (String userId : mUserIDs) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userId;
                    mCallUserInfoList.add(userModel);
                    mCallUserModelMap.put(userModel.userId, userModel);
                }
            }
        }
    }

    protected void startInviting(int type) {
        if (TRTCCalling.TYPE_UNKNOWN == type) {
            TRTCLogger.d(TAG, "unknown callType");
            return;
        }

        List<String> userIds = new ArrayList<>();
        for (UserModel userInfo : mCallUserInfoList) {
            userIds.add(userInfo.userId);
        }
        if (TextUtils.isEmpty(mGroupID)) {
            mTRTCCalling.call(userIds, type);
        } else {
            mTRTCCalling.groupCall(userIds, type, mGroupID);
        }
        mTRTCCalling.setHandsFree(mIsHandsFree);
    }

    //判断是否是群聊,群聊有两种情况:
    //1.引入群组概念,多人加入群组,主叫是群主 ---IM即时通信使用该方法
    //2.主叫同时向多个用户发起单聊,本质还是C2C单人通话 ----组件多人通话使用该方法
    protected boolean isGroupCall() {
        if (!TextUtils.isEmpty(mGroupID)) {
            return true;
        }
        if (TUICalling.Role.CALL == mRole) {
            return mUserIDs.length >= 2;
        } else {
            return mUserIDs.length >= 1 || mIsFromGroup;
        }
    }

    protected UserModel getRemovedUserModel() {
        return mRemovedUserModel;
    }

    protected void setImageBackView(ImageView imageView) {
        mImageBack = imageView;
    }

    protected ImageView getImageBackView() {
        return mImageBack;
    }

    protected TUICalling.Type getCallType() {
        return mCallType;
    }

    protected abstract void initView();

    //主叫端:展示邀请列表
    protected void showInvitingView() {
        Status.mCallStatus = Status.CALL_STATUS.WAITING;
    }

    //主叫端/被叫端: 展示通话中的界面
    protected void showCallingView() {
        Status.mCallStatus = Status.CALL_STATUS.ACCEPT;
    }

    //被叫端: 等待接听界面
    protected void showWaitingResponseView() {
        Status.mCallStatus = Status.CALL_STATUS.WAITING;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mTRTCCalling.addDelegate(this);
        //开启界面后,清除通知栏消息
        NotificationManager notificationManager =
                (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancelAll();
    }

    @Override
    protected void onDetachedFromWindow() {
        TRTCLogger.d(TAG, "==== onDetachedFromWindow ====");
        super.onDetachedFromWindow();
        stopTimeCount();
        mTRTCCalling.removeDelegate(this);
        if (Status.mIsShowFloatWindow) {
            FloatWindowService.stopService(mContext);
        }
    }

    protected void finish() {
        mOtherInviteeList.clear();
        mCallUserInfoList.clear();
        mCallUserModelMap.clear();
        mIsInRoom = false;
        mIsCalling = false;
        Status.mCallStatus = Status.CALL_STATUS.NONE;
    }

    @Override
    public void onGroupCallInviteeListUpdate(List<String> userIdList) {
    }

    @Override
    public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, int callType) {
    }

    @Override
    public void onError(int code, String msg) {
        //发生了错误，报错并退出该页面
        ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_call_error_msg, code, msg));
        finish();
    }

    @Override
    public void onUserEnter(final String userId) {
        Status.mCallStatus = Status.CALL_STATUS.ACCEPT;
    }

    @Override
    public void onUserLeave(final String userId) {
        //删除用户model
        UserModel userInfo = mCallUserModelMap.remove(userId);
        if (userInfo != null) {
            mCallUserInfoList.remove(userInfo);
        }
        //有用户退出时,需提示"**结束通话";
        if (null != userInfo && !TextUtils.isEmpty(userInfo.userName)) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_end, userInfo.userName));
        } else {
            showUserToast(userId, R.string.trtccalling_toast_user_end);
        }
    }

    @Override
    public void onReject(final String userId) {
        //删除用户model
        UserModel userInfo = mCallUserModelMap.remove(userId);
        if (userInfo != null) {
            mCallUserInfoList.remove(userInfo);
            mRemovedUserModel = userInfo;
        }
        //用户拒接时,需提示"**拒绝通话"
        if (null != userInfo && !TextUtils.isEmpty(userInfo.userName)) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_reject_call, userInfo.userName));
        } else {
            showUserToast(userId, R.string.trtccalling_toast_user_reject_call);
        }
    }

    @Override
    public void onNoResp(final String userId) {
        //删除用户model
        UserModel userInfo = mCallUserModelMap.remove(userId);
        if (userInfo != null) {
            mCallUserInfoList.remove(userInfo);
            mRemovedUserModel = userInfo;
        }
        //用户无响应时,需提示"**无响应"
        if (null != userInfo && !TextUtils.isEmpty(userInfo.userName)) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_not_response, userInfo.userName));
        } else {
            showUserToast(userId, R.string.trtccalling_toast_user_not_response);
        }
    }

    @Override
    public void onLineBusy(String userId) {
        //删除用户model
        UserModel userInfo = mCallUserModelMap.remove(userId);
        if (userInfo != null) {
            mCallUserInfoList.remove(userInfo);
            mRemovedUserModel = userInfo;
        }
        //用户忙线时,需提示"**忙线"
        if (null != userInfo && !TextUtils.isEmpty(userInfo.userName)) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_busy, userInfo.userName));
        } else {
            showUserToast(userId, R.string.trtccalling_toast_user_busy);
        }
    }

    @Override
    public void onCallingCancel() {
        //主叫取消了通话,被叫提示"主叫取消通话"
        if (mSponsorUserInfo != null) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_cancel_call, mSponsorUserInfo.userName));
        }
        finish();
    }

    @Override
    public void onCallingTimeout() {
        //被叫超时,主叫/被叫都提示"通话超时",群聊不提示.
        if (!isGroupCall()) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_timeout, ""));
        }
        finish();
    }

    @Override
    public void onCallEnd() {
        //通话结束退房,被叫提示"主叫结束通话"
        if (mSponsorUserInfo != null) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_end, mSponsorUserInfo.userName));
        }
        finish();
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {

    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality,
                                 ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
        updateNetworkQuality(localQuality, remoteQuality);
    }

    @Override
    public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {

    }

    @Override
    public void onUserAudioAvailable(String userId, boolean isAudioAvailable) {

    }

    @Override
    public void onSwitchToAudio(boolean success, String message) {

    }

    //通话时长,注意UI更新需要在主线程中进行
    protected void showTimeCount(TextView view) {
        if (mTimeRunnable != null) {
            return;
        }
        mTimeCount = Status.mBeginTime;
        if (null != view) {
            view.setText(getShowTime(mTimeCount));
        }
        mTimeRunnable = new Runnable() {
            @Override
            public void run() {
                mTimeCount++;
                Status.mBeginTime = mTimeCount;
                if (null != view) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (!isDestroyed()) {
                                view.setText(getShowTime(mTimeCount));
                            }
                        }
                    });
                }
                mTimeHandler.postDelayed(mTimeRunnable, 1000);
            }
        };
        mTimeHandler.postDelayed(mTimeRunnable, 1000);
    }

    protected String getShowTime(int count) {
        return mContext.getString(R.string.trtccalling_called_time_format, count / 60, count % 60);
    }

    private void stopTimeCount() {
        mTimeHandler.removeCallbacks(mTimeRunnable);
        mTimeRunnable = null;
        mTimeHandlerThread.quit();
        mTimeCount = 0;
    }

    //localQuality 己方网络状态， remoteQualityList对方网络状态列表，取第一个为1v1通话的网络状态
    protected void updateNetworkQuality(TRTCCloudDef.TRTCQuality localQuality,
                                        List<TRTCCloudDef.TRTCQuality> remoteQualityList) {
        //如果己方网络和对方网络都很差，优先显示己方网络差
        boolean isLocalLowQuality = isLowQuality(localQuality);
        if (isLocalLowQuality) {
            updateLowQualityTip(true);
        } else {
            if (!remoteQualityList.isEmpty()) {
                TRTCCloudDef.TRTCQuality remoteQuality = remoteQualityList.get(0);
                if (isLowQuality(remoteQuality)) {
                    updateLowQualityTip(false);
                }
            }
        }
    }

    private boolean isLowQuality(TRTCCloudDef.TRTCQuality qualityInfo) {
        if (qualityInfo == null) {
            return false;
        }
        int quality = qualityInfo.quality;
        boolean lowQuality;
        switch (quality) {
            case TRTCCloudDef.TRTC_QUALITY_Vbad:
            case TRTCCloudDef.TRTC_QUALITY_Down:
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
            if (currentTime - mSelfLowQualityTime > MIN_DURATION_SHOW_LOW_QUALITY) {
                Toast.makeText(mContext, R.string.trtccalling_self_network_low_quality, Toast.LENGTH_SHORT).show();
                mSelfLowQualityTime = currentTime;
            }
        } else {
            if (currentTime - mOtherPartyLowQualityTime > MIN_DURATION_SHOW_LOW_QUALITY) {
                Toast.makeText(mContext, R.string.trtccalling_other_party_network_low_quality,
                        Toast.LENGTH_SHORT).show();
                mOtherPartyLowQualityTime = currentTime;
            }
        }
    }

    protected boolean isDestroyed() {
        boolean isDestroyed = false;
        if (mContext instanceof Activity && ((Activity) mContext).isDestroyed()) {
            isDestroyed = true;
        }
        return isDestroyed;
    }

    private void initListener() {
        ITUINotification notification = new ITUINotification() {
            @Override
            public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)
                        && TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE.equals(subKey)) {
                    ToastUtils.showShort(mContext.getString(R.string.trtccalling_user_kicked_offline));
                    mTRTCCalling.hangup();
                    finish();
                }
                if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)
                        && TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED.equals(subKey)) {
                    ToastUtils.showShort(mContext.getString(R.string.trtccalling_user_sig_expired));
                    mTRTCCalling.hangup();
                    finish();
                }
            }
        };
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE,
                notification);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED,
                notification);
    }

    public void showUserToast(String userId, int msgId) {
        if (TextUtils.isEmpty(userId)) {
            TRTCLogger.d(TAG, "showUserToast userId is empty");
            return;
        }

        CallingInfoManager.getInstance().getUserInfoByUserId(userId,
                new CallingInfoManager.UserCallback() {
                    @Override
                    public void onSuccess(UserModel model) {
                        if (null == model || TextUtils.isEmpty(model.userName)) {
                            ToastUtils.showLong(mContext.getString(msgId, userId));
                        } else {
                            ToastUtils.showLong(mContext.getString(msgId, model.userName));
                        }
                    }

                    @Override
                    public void onFailed(int code, String msg) {
                        ToastUtils.showLong(mContext.getString(msgId, userId));
                    }
                });
    }
}
