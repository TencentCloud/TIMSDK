package com.tencent.liteav.trtccalling.ui.audiocall;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.constraintlayout.widget.Group;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.model.impl.UserModel;
import com.tencent.liteav.trtccalling.model.impl.base.CallingInfoManager;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.ImageLoader;
import com.tencent.liteav.trtccalling.ui.audiocall.audiolayout.TRTCGroupAudioLayout;
import com.tencent.liteav.trtccalling.ui.audiocall.audiolayout.TRTCGroupAudioLayoutManager;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIGroupCallAudioView extends BaseTUICallView {
    private static final String TAG = "TUIGroupCallAudioView";

    private ImageView                   mImageMute;
    private ImageView                   mImageHangup;
    private LinearLayout                mLayoutMute;
    private LinearLayout                mLayoutHangup;
    private ImageView                   mImageHandsFree;
    private LinearLayout                mLayoutHandsFree;
    private ImageView                   mImageDialing;
    private LinearLayout                mLayoutDialing;
    private TRTCGroupAudioLayoutManager mLayoutManagerTRTC;
    private Group                       mGroupInviting;
    private LinearLayout                mLayoutImgContainer;
    private TextView                    mTextTime;
    private TextView                    mInvitedTag;
    private TextView                    mTvHangup;

    private Runnable      mTimeRunnable;
    private int           mTimeCount;
    private Handler       mTimeHandler;
    private HandlerThread mTimeHandlerThread;

    private final List<UserModel>        mCallUserInfoList          = new ArrayList<>(); // 呼叫方
    private final Map<String, UserModel> mCallUserModelMap          = new HashMap<>();
    private final List<UserModel>        mOtherInvitingUserInfoList = new ArrayList<>(); // 被叫方存储的其他被叫的列表
    private       UserModel              mSponsorUserInfo;                               // 被叫方
    private       boolean                mIsHandsFree               = true;              // 语音通话默认开启扬声器
    private       boolean                mIsMuteMic                 = false;
    private       boolean                mIsInRoom                  = false;             //被叫是否已接听进房(true:已接听进房 false:未接听)

    public TUIGroupCallAudioView(Context context, TUICalling.Role role, String[] userIDs, String sponsorID, String groupID, boolean isFromGroup) {
        super(context, role, userIDs, sponsorID, groupID, isFromGroup);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        initData();
        initListener();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopTimeCount();
        mTimeHandlerThread.quit();
    }

    @Override
    protected void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.trtccalling_group_audiocall_activity_call_main, this);
        mImageMute = (ImageView) findViewById(R.id.img_mute);
        mLayoutMute = (LinearLayout) findViewById(R.id.ll_mute);
        mImageHangup = (ImageView) findViewById(R.id.img_hangup);
        mLayoutHangup = (LinearLayout) findViewById(R.id.ll_hangup);
        mImageHandsFree = (ImageView) findViewById(R.id.img_handsfree);
        mLayoutHandsFree = (LinearLayout) findViewById(R.id.ll_handsfree);
        mImageDialing = (ImageView) findViewById(R.id.img_dialing);
        mLayoutDialing = (LinearLayout) findViewById(R.id.ll_dialing);
        mLayoutManagerTRTC = (TRTCGroupAudioLayoutManager) findViewById(R.id.trtc_layout_manager);
        mGroupInviting = (Group) findViewById(R.id.group_inviting);
        mLayoutImgContainer = (LinearLayout) findViewById(R.id.ll_img_container);
        mTextTime = (TextView) findViewById(R.id.tv_time);
        mInvitedTag = (TextView) findViewById(R.id.tv_inviting_tag);
        mTvHangup = (TextView) findViewById(R.id.tv_hangup);
    }

    private void initData() {
        // 初始化成员变量
        mTimeHandlerThread = new HandlerThread("time-count-thread");
        mTimeHandlerThread.start();
        mTimeHandler = new Handler(mTimeHandlerThread.getLooper());

        if (mRole == TUICalling.Role.CALLED) {
            // 作为被叫
            if (!TextUtils.isEmpty(mSponsorID)) {
                mSponsorUserInfo = new UserModel();
                mSponsorUserInfo.userId = mSponsorID;
            }
            if (null != mUserIDs) {
                for (String userId : mUserIDs) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userId;
                    mOtherInvitingUserInfoList.add(userModel);
                    mCallUserModelMap.put(userModel.userId, userModel);
                }
            }
            PermissionUtils.permission(PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(List<String> permissionsGranted) {
                    showWaitingResponseView();
                }

                @Override
                public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                    mTRTCCalling.reject();
                    ToastUtils.showShort(R.string.trtccalling_tips_start_audio);
                    finish();
                }
            }).request();
        } else {
            // 主叫方
            if (mSelfModel != null) {
                for (String userId : mUserIDs) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userId;
                    mCallUserInfoList.add(userModel);
                    mCallUserModelMap.put(userModel.userId, userModel);
                }
                showInvitingView();
                PermissionUtils.permission(PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
                    @Override
                    public void onGranted(List<String> permissionsGranted) {
                        startInviting();
                    }

                    @Override
                    public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                        ToastUtils.showShort(R.string.trtccalling_tips_start_audio);
                        finish();
                    }
                }).request();
            }
        }
    }

    private void initListener() {
        mLayoutMute.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mIsMuteMic = !mIsMuteMic;
                mTRTCCalling.setMicMute(mIsMuteMic);
                mImageMute.setActivated(mIsMuteMic);
                ToastUtils.showLong(mIsMuteMic ? R.string.trtccalling_toast_enable_mute : R.string.trtccalling_toast_disable_mute);
                TRTCGroupAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(mSelfModel.userId);
                if (null != layout) {
                    layout.muteMic(mIsMuteMic);
                }
            }
        });
        mLayoutHandsFree.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mIsHandsFree = !mIsHandsFree;
                mTRTCCalling.setHandsFree(mIsHandsFree);
                mImageHandsFree.setActivated(mIsHandsFree);
                ToastUtils.showLong(mIsHandsFree ? R.string.trtccalling_toast_use_speaker : R.string.trtccalling_toast_use_handset);
            }
        });
        mImageMute.setActivated(mIsMuteMic);
        mImageHandsFree.setActivated(mIsHandsFree);
        mTRTCCalling.setHandsFree(mIsHandsFree);
    }

    @Override
    public void onError(int code, String msg) {
        //发生了错误，报错并退出该页面
        ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_call_error_msg, code, msg));
        finish();
    }

    @Override
    public void onUserEnter(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showCallingView();
                UserModel userModel = mCallUserModelMap.get(userId);
                TRTCGroupAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(userId);
                TRTCLogger.d(TAG, "onUserEnter, userId=" + userId + " ,layout=" + layout);
                if (layout == null) {
                    layout = addUserToManager(userModel);
                }
                layout.stopLoading();
                loadUserInfo(userModel, layout);
                //C2C多人通话:有被叫用户接听了通话,从被叫列表中移除
                if (null != userModel && mOtherInvitingUserInfoList.contains(userModel)) {
                    mOtherInvitingUserInfoList.remove(userModel);
                }
            }
        });
    }

    @Override
    public void onUserLeave(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //1. 回收界面元素
                mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
                //2. 删除用户model
                UserModel userInfo = mCallUserModelMap.remove(userId);
                if (userInfo != null) {
                    mCallUserInfoList.remove(userInfo);
                }
                //C2C多人通话:被叫方:如果是主叫"取消"了电话,更新已接听用户的UI显示
                if (null != mSponsorUserInfo && userId.equals(mSponsorUserInfo.userId)) {
                    for (UserModel model : mOtherInvitingUserInfoList) {
                        if (null != model && !TextUtils.isEmpty(model.userId)) {
                            //回收所有未接通用户的界面
                            mLayoutManagerTRTC.recyclerAudioCallLayout(model.userId);
                        }
                    }
                }
            }
        });
    }

    @Override
    public void onReject(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.d(TAG, "onReject: userId = " + userId + ",mCallUserModelMap " + mCallUserModelMap);
                if (mCallUserModelMap.containsKey(userId)) {
                    // 进入拒绝环节
                    //1. 回收界面元素
                    mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
                    //2. 删除用户model
                    UserModel userInfo = mCallUserModelMap.remove(userId);
                    if (userInfo != null) {
                        mCallUserInfoList.remove(userInfo);
                        //主叫提示"***拒绝通话",其他被叫不提示
                        if (null == mSponsorUserInfo) {
                            showUserToast(userId, R.string.trtccalling_toast_user_reject_call);
                        }
                    }
                    //C2C多人通话:有被叫用户拒绝了通话,从被叫列表中移除
                    if (null != userInfo && mOtherInvitingUserInfoList.contains(userInfo)) {
                        mOtherInvitingUserInfoList.remove(userInfo);
                        showOtherInvitingUserView();
                    }
                }
            }
        });
    }

    @Override
    public void onNoResp(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.d(TAG, "onNoResp: userId = " + userId + ",mCallUserModelMap: " + mCallUserModelMap);
                if (mCallUserModelMap.containsKey(userId)) {
                    // 进入无响应环节
                    //1. 回收界面元素
                    mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
                    //2. 删除用户model
                    UserModel userInfo = mCallUserModelMap.remove(userId);
                    if (userInfo != null) {
                        mCallUserInfoList.remove(userInfo);
                        //用户超时,所有人提示"***无响应"
                        showUserToast(userId, R.string.trtccalling_toast_user_not_response);
                    }
                    //C2C多人通话:有被叫用户超时未接听,从被叫列表中移除
                    if (null != userInfo && mOtherInvitingUserInfoList.contains(userInfo)) {
                        mOtherInvitingUserInfoList.remove(userInfo);
                        showOtherInvitingUserView();
                    }
                }
            }
        });
    }

    @Override
    public void onLineBusy(String userId) {
        TRTCLogger.d(TAG, "onLineBusy: userId = " + userId + ",mCallUserModelMap " + mCallUserModelMap);
        if (mCallUserModelMap.containsKey(userId)) {
            // 进入无响应环节
            //1. 回收界面元素
            mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
            //2. 删除用户model
            UserModel userInfo = mCallUserModelMap.remove(userId);
            if (userInfo != null) {
                mCallUserInfoList.remove(userInfo);
                //用户忙线,所有人提示"***忙线"
                showUserToast(userId, R.string.trtccalling_toast_user_busy);
            }
            //C2C多人通话:有被叫用户忙线中,从被叫列表中移除
            if (null != userInfo && mOtherInvitingUserInfoList.contains(userInfo)) {
                mOtherInvitingUserInfoList.remove(userInfo);
                showOtherInvitingUserView();
            }
        }
    }

    @Override
    public void onCallingCancel() {
        if (mSponsorUserInfo != null) {
            showUserToast(mSponsorUserInfo.userId, R.string.trtccalling_toast_user_cancel_call);
        }
        finish();
    }

    @Override
    public void onCallingTimeout() {
        finish();
    }

    @Override
    public void onCallEnd() {
        //最后一个用户退出时,onReject回调比onCallEnd慢，因此,主叫端判断是最后一个用户提示"***结束通话"
        if (null == mSponsorUserInfo && mCallUserModelMap.size() == 1) {
            for (Map.Entry<String, UserModel> entry : mCallUserModelMap.entrySet()) {
                UserModel model = mCallUserModelMap.get(entry.getKey());
                if (null != model) {
                    showUserToast(model.userId, R.string.trtccalling_toast_user_end);
                }
            }
        }
        finish();
    }

    @Override
    public void onUserAudioAvailable(String userId, boolean isAudioAvailable) {
        TRTCLogger.d(TAG, "onUserAudioAvailable, userId=" + userId + ", isAudioAvailable=" + isAudioAvailable);
        TRTCGroupAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(userId);
        if (null != layout) {
            layout.muteMic(!isAudioAvailable);
        }
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            TRTCGroupAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(userId);
            if (layout != null) {
                layout.setAudioVolume(entry.getValue());
            }
        }
    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
        updateNetworkQuality(localQuality, remoteQuality);
    }

    private void startInviting() {
        List<String> userIds = new ArrayList<>(mCallUserInfoList.size());
        for (UserModel userModel : mCallUserInfoList) {
            userIds.add(userModel.userId);
        }
        if (TextUtils.isEmpty(mGroupID)) {
            mTRTCCalling.call(userIds, TRTCCalling.TYPE_AUDIO_CALL);
        } else {
            mTRTCCalling.groupCall(userIds, TRTCCalling.TYPE_AUDIO_CALL, mGroupID);
        }
        mTRTCCalling.setHandsFree(mIsHandsFree);
    }

    /**
     * 等待接听界面
     */
    public void showWaitingResponseView() {
        //1. 展示对方的画面
        if (null == mSponsorUserInfo) {
            for (UserModel userModel : mOtherInvitingUserInfoList) {
                loadUserInfo(userModel, addUserToManager(userModel));
            }
        } else {
            loadUserInfo(mSponsorUserInfo, addUserToManager(mSponsorUserInfo));
        }

        //2. 展示电话对应界面
        mLayoutHangup.setVisibility(View.VISIBLE);
        mLayoutDialing.setVisibility(View.VISIBLE);
        mLayoutHandsFree.setVisibility(View.GONE);
        mLayoutMute.setVisibility(View.GONE);
        //3. 设置对应的listener
        mLayoutHangup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.reject();
                finish();
            }
        });
        mLayoutDialing.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                //2.接听电话
                mTRTCCalling.accept();
                mTRTCCalling.setHandsFree(mIsHandsFree);
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        if (null != mSponsorUserInfo) {
            showOtherInvitingUserView();
        }
        mInvitedTag.setText(mContext.getString(R.string.trtccalling_invite_audio_call));
        mTvHangup.setText(R.string.trtccalling_text_reject);
    }

    /**
     * 展示邀请列表
     */
    public void showInvitingView() {
        //1. 展示自己的界面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        loadUserInfo(mSelfModel, addUserToManager(mSelfModel));
        //2. 展示对方的画面
        for (UserModel userInfo : mCallUserInfoList) {
            TRTCGroupAudioLayout layout = addUserToManager(userInfo);
            layout.startLoading();
            loadUserInfo(userInfo, layout);
        }
        //3. 设置底部栏
        mLayoutHangup.setVisibility(View.VISIBLE);
        mLayoutHangup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                finish();
            }
        });
        mLayoutDialing.setVisibility(View.GONE);
        mLayoutHandsFree.setVisibility(View.VISIBLE);
        mLayoutMute.setVisibility(View.VISIBLE);
        //4. 隐藏中间他们也在界面
//        hideOtherInvitingUserView();
        mGroupInviting.setVisibility(View.VISIBLE);
        mInvitedTag.setText(mContext.getString(R.string.trtccalling_waiting_be_accepted));
        mTvHangup.setText(R.string.trtccalling_text_hangup);
    }

    /**
     * 展示通话中的界面
     */
    public void showCallingView() {
        //1. 增加自己的画面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        TRTCGroupAudioLayout audioLayout = mLayoutManagerTRTC.findAudioCallLayout(mSelfModel.userId);
        if (null == audioLayout) {
            audioLayout = addUserToManager(mSelfModel);
            loadUserInfo(mSelfModel, audioLayout);
        }
        //2. 底部状态栏
        mLayoutHangup.setVisibility(View.VISIBLE);
        mLayoutDialing.setVisibility(View.GONE);
        mLayoutHandsFree.setVisibility(View.VISIBLE);
        mLayoutMute.setVisibility(View.VISIBLE);
        mTvHangup.setText(R.string.trtccalling_text_hangup);
        mLayoutHangup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                finish();
            }
        });
        showTimeCount();
        //3. 隐藏其他未接听用户的小窗
        hideOtherInvitingUserView();
        //mSponsorUserInfo不为空,说明是被叫;
        //C2C多人通话增加:自己接通后,其他用户大窗显示,未接听用户显示loading
        if (null != mSponsorUserInfo) {
            //被叫已接听
            mIsInRoom = true;
            TRTCLogger.d(TAG, "showCallingView: mCallUserModelMap = " + mCallUserModelMap);
            for (Map.Entry<String, UserModel> entry : mCallUserModelMap.entrySet()) {
                UserModel model = mCallUserModelMap.get(entry.getKey());
                if (null != model && !TextUtils.isEmpty(model.userId)) {
                    TRTCGroupAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(model.userId);
                    TRTCLogger.d(TAG, "showCallingView model=" + model.userId + " ,layout=" + layout);
                    if (layout == null) {
                        layout = addUserToManager(model);
                        layout.startLoading();
                    }
                    loadUserInfo(model, layout);
                }
            }
        }
    }

    private void showTimeCount() {
        if (mTimeRunnable != null) {
            return;
        }
        mTimeCount = 0;
        mTextTime.setText(getShowTime(mTimeCount));
        if (mTimeRunnable == null) {
            mTimeRunnable = new Runnable() {
                @Override
                public void run() {
                    mTimeCount++;
                    if (mTextTime != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTextTime.setText(getShowTime(mTimeCount));
                            }
                        });
                    }
                    mTimeHandler.postDelayed(mTimeRunnable, 1000);
                }
            };
        }
        mTimeHandler.postDelayed(mTimeRunnable, 1000);
    }

    private void stopTimeCount() {
        mTimeHandler.removeCallbacks(mTimeRunnable);
        mTimeRunnable = null;
    }

    private String getShowTime(int count) {
        return mContext.getString(R.string.trtccalling_called_time_format, count / 60, count % 60);
    }

    //未接通的用户在被叫端的显示
    private void showOtherInvitingUserView() {
        if (CollectionUtils.isEmpty(mOtherInvitingUserInfoList)) {
            mLayoutImgContainer.removeAllViews();
            mGroupInviting.setVisibility(mIsInRoom ? GONE : VISIBLE);
            return;
        }
        mGroupInviting.setVisibility(View.VISIBLE);
        mLayoutImgContainer.removeAllViews();
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_size);
        int leftMargin = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_left_margin);
        for (int index = 0; index < mOtherInvitingUserInfoList.size(); index++) {
            final UserModel userModel = mOtherInvitingUserInfoList.get(index);
            final ImageView imageView = new ImageView(mContext);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            ImageLoader.loadImage(mContext, imageView, userModel.userAvatar, R.drawable.trtccalling_ic_avatar);
            mLayoutImgContainer.addView(imageView);

            CallingInfoManager.getInstance().getUserInfoByUserId(userModel.userId, new CallingInfoManager.UserCallback() {
                @Override
                public void onSuccess(UserModel model) {
                    userModel.userName = model.userName;
                    userModel.userAvatar = model.userAvatar;
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ImageLoader.loadImage(mContext, imageView, userModel.userAvatar, R.drawable.trtccalling_ic_avatar);
                        }
                    });
                }

                @Override
                public void onFailed(int code, String msg) {
                    ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
                }
            });
        }
    }

    private void hideOtherInvitingUserView() {
        mGroupInviting.setVisibility(View.GONE);
    }

    private TRTCGroupAudioLayout addUserToManager(UserModel userInfo) {
        TRTCGroupAudioLayout layout = mLayoutManagerTRTC.allocAudioCallLayout(userInfo.userId);
        if (layout == null) {
            return null;
        }
        TRTCLogger.d(TAG, String.format("addUserToManager, userId=%s, userName=%s, userAvatar=%s", userInfo.userId,
                userInfo.userName, userInfo.userAvatar));
        loadUserInfo(userInfo, layout);
        return layout;
    }

    //从IM查询用户信息并更新布局显示
    private void loadUserInfo(final UserModel userModel, TRTCGroupAudioLayout layout) {
        if (null == userModel || null == layout) {
            TRTCLogger.e(TAG, "loadUserInfo error: null == userModel || null == layout");
            return;
        }
        CallingInfoManager.getInstance().getUserInfoByUserId(userModel.userId, new CallingInfoManager.UserCallback() {
            @Override
            public void onSuccess(UserModel model) {
                userModel.userName = model.userName;
                userModel.userAvatar = model.userAvatar;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        layout.setUserName(userModel.userName);
                        ImageLoader.loadImage(mContext, layout.getImageView(), userModel.userAvatar, R.drawable.trtccalling_ic_avatar);
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
    }

    protected void finish() {
        super.finish();
        mOtherInvitingUserInfoList.clear();
        mCallUserInfoList.clear();
        mCallUserModelMap.clear();
        mIsInRoom = false;
    }

}
