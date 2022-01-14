package com.tencent.liteav.trtccalling.ui.videocall;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.Group;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.TUICalling;
import com.tencent.liteav.trtccalling.model.impl.TRTCCalling;
import com.tencent.liteav.trtccalling.model.impl.UserModel;
import com.tencent.liteav.trtccalling.model.impl.base.CallingInfoManager;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.ImageLoader;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;
import com.tencent.liteav.trtccalling.ui.common.Utils;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCGroupVideoLayout;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCGroupVideoLayoutManager;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIGroupCallVideoView extends BaseTUICallView {

    private ImageView                   mMuteImg;
    private ImageView                   mSwitchCameraImg;
    private LinearLayout                mOpenCameraLl;
    private ImageView                   mOpenCameraImg;
    private LinearLayout                mMuteLl;
    private ImageView                   mHangupImg;
    private LinearLayout                mHangupLl;
    private ImageView                   mHandsfreeImg;
    private LinearLayout                mHandsfreeLl;
    private ImageView                   mDialingImg;
    private LinearLayout                mDialingLl;
    private TextView                    mTvHangup;
    private TRTCGroupVideoLayoutManager mLayoutManagerTrtc;
    private Group                       mInvitingGroup;
    private LinearLayout                mImgContainerLl;
    private TextView                    mTimeTv;
    private RoundCornerImageView        mSponsorAvatarImg;
    private TextView                    mSponsorUserNameTv;
    private TextView                    mSponsorUserVideoTag;
    private View                        mViewSwitchAudioCall;
    private View                        mShadeSponsor;
    private Runnable                    mTimeRunnable;
    private int                         mTimeCount;
    private Handler                     mTimeHandler;
    private HandlerThread               mTimeHandlerThread;

    /**
     * 拨号相关成员变量
     */
    private final List<UserModel>        mCallUserInfoList          = new ArrayList<>(); // 呼叫方
    private final Map<String, UserModel> mCallUserModelMap          = new HashMap<>();
    private       UserModel              mSponsorUserInfo;                               // 被叫方
    private final List<UserModel>        mOtherInvitingUserInfoList = new ArrayList<>();
    private       boolean                mIsHandsFree               = true;
    private       boolean                mIsMuteMic                 = false;
    private       boolean                mIsFrontCamera             = true;
    private       boolean                mIsCameraOpen              = true;
    private       boolean                mIsAudioMode               = false;
    private       boolean                mIsCalledClick             = false;  //被叫方点击转换语音

    private static final int MAX_SHOW_INVITING_USER = 4;

    private static final String TAG = "TUIGroupCallVideoView";

    public TUIGroupCallVideoView(Context context, TUICalling.Role role, String[] userIDs, String sponsorID, String groupID, boolean isFromGroup) {
        super(context, role, userIDs, sponsorID, groupID, isFromGroup);
    }

    @Override
    protected void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.trtccalling_group_videocall_activity_call_main, this);
        mMuteImg = (ImageView) findViewById(R.id.iv_mute);
        mMuteLl = (LinearLayout) findViewById(R.id.ll_mute);
        mHangupImg = (ImageView) findViewById(R.id.iv_hangup);
        mHangupLl = (LinearLayout) findViewById(R.id.ll_hangup);
        mHandsfreeImg = (ImageView) findViewById(R.id.iv_handsfree);
        mHandsfreeLl = (LinearLayout) findViewById(R.id.ll_handsfree);
        mDialingImg = (ImageView) findViewById(R.id.iv_dialing);
        mDialingLl = (LinearLayout) findViewById(R.id.ll_dialing);
        mLayoutManagerTrtc = (TRTCGroupVideoLayoutManager) findViewById(R.id.trtc_layout_manager);
        mInvitingGroup = (Group) findViewById(R.id.group_inviting);
        mImgContainerLl = (LinearLayout) findViewById(R.id.ll_img_container);
        mTimeTv = (TextView) findViewById(R.id.tv_time);
        mSponsorAvatarImg = (RoundCornerImageView) findViewById(R.id.iv_sponsor_avatar);
        mSponsorUserNameTv = (TextView) findViewById(R.id.tv_sponsor_user_name);
        mSwitchCameraImg = (ImageView) findViewById(R.id.switch_camera);
        mOpenCameraLl = (LinearLayout) findViewById(R.id.ll_open_camera);
        mOpenCameraImg = (ImageView) findViewById(R.id.img_camera);
        mSponsorUserVideoTag = (TextView) findViewById(R.id.tv_sponsor_video_tag);
        mViewSwitchAudioCall = findViewById(R.id.ll_switch_audio_call);
        mTvHangup = (TextView) findViewById(R.id.tv_hangup);
        mShadeSponsor = findViewById(R.id.shade_sponsor);
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
            PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(List<String> permissionsGranted) {
                    showWaitingResponseView();
                }

                @Override
                public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                    mTRTCCalling.reject();
                    ToastUtils.showShort(R.string.trtccalling_tips_start_camera_audio);
                    finish();
                }
            }).request();
        } else {
            // 主叫方
            if (mUserIDs != null) {
                for (String userId : mUserIDs) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userId;
                    mCallUserInfoList.add(userModel);
                    mCallUserModelMap.put(userModel.userId, userModel);
                }
                showInvitingView();
                startInviting();
            }
        }
    }

    private void initListener() {
        mMuteLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mIsMuteMic = !mIsMuteMic;
                mTRTCCalling.setMicMute(mIsMuteMic);
                mMuteImg.setActivated(mIsMuteMic);
                ToastUtils.showLong(mIsMuteMic ? R.string.trtccalling_toast_enable_mute : R.string.trtccalling_toast_disable_mute);
                TRTCGroupVideoLayout layout = mLayoutManagerTrtc.findVideoCallLayout(mSelfModel.userId);
                if (null != layout) {
                    layout.muteMic(mIsMuteMic);
                }
            }
        });
        mSwitchCameraImg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mIsCameraOpen) {
                    ToastUtils.showShort(R.string.trtccalling_switch_camera_hint);
                    return;
                }
                mIsFrontCamera = !mIsFrontCamera;
                mTRTCCalling.switchCamera(mIsFrontCamera);
                ToastUtils.showLong(R.string.trtccalling_toast_switch_camera);
            }
        });

        mOpenCameraLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TRTCGroupVideoLayout videoLayout = mLayoutManagerTrtc.findVideoCallLayout(mSelfModel.userId);
                if (videoLayout == null) {
                    return;
                }
                if (mIsCameraOpen) {
                    mTRTCCalling.closeCamera();
                    videoLayout.setVideoAvailable(false);
                    mIsCameraOpen = false;
                    mOpenCameraImg.setActivated(true);
                    mSwitchCameraImg.setVisibility(GONE);
                    loadUserInfo(mSelfModel, videoLayout);
                } else {
                    mTRTCCalling.openCamera(mIsFrontCamera, videoLayout.getVideoView());
                    videoLayout.setVideoAvailable(true);
                    mIsCameraOpen = true;
                    mOpenCameraImg.setActivated(false);
                    mSwitchCameraImg.setVisibility(VISIBLE);
                }
                ToastUtils.showLong(mIsCameraOpen ? R.string.trtccalling_toast_enable_camera : R.string.trtccalling_toast_disable_camera);
            }
        });
        mHandsfreeLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mIsHandsFree = !mIsHandsFree;
                mTRTCCalling.setHandsFree(mIsHandsFree);
                mHandsfreeImg.setActivated(mIsHandsFree);
                ToastUtils.showLong(mIsHandsFree ? R.string.trtccalling_toast_use_speaker : R.string.trtccalling_toast_use_handset);
            }
        });
        mMuteImg.setActivated(mIsMuteMic);
        mHandsfreeImg.setActivated(mIsHandsFree);
        mViewSwitchAudioCall.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.switchToAudioCall();
                mIsCalledClick = true;
                enableHandsFree(false);
            }
        });
    }

    private void startInviting() {
        final List<String> list = new ArrayList<>();
        for (UserModel userInfo : mCallUserInfoList) {
            list.add(userInfo.userId);
        }
        PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
            @Override
            public void onGranted(List<String> permissionsGranted) {
                TRTCGroupVideoLayout layout = mLayoutManagerTrtc.findVideoCallLayout(mSelfModel.userId);
                if (null != layout) {
                    mTRTCCalling.openCamera(true, layout.getVideoView());
                }
                mTRTCCalling.groupCall(list, TRTCCalling.TYPE_VIDEO_CALL, mGroupID);
            }

            @Override
            public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                ToastUtils.showShort(R.string.trtccalling_tips_start_camera_audio);
                finish();
            }
        }).request();
    }

    @Override
    public void onError(int code, String msg) {
        //发生了错误，报错并退出该页面
        ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_call_error_msg, code, msg));
        stopCameraAndFinish();
    }

    @Override
    public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, int callType) {
    }

    @Override
    public void onGroupCallInviteeListUpdate(List<String> userIdList) {

    }

    @Override
    public void onUserEnter(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showCallingView();
                UserModel userModel = mCallUserModelMap.get(userId);
                TRTCGroupVideoLayout layout = mLayoutManagerTrtc.findVideoCallLayout(userId);
                if (null == layout) {
                    layout = addUserToManager(userModel);
                }
                loadUserInfo(userModel, layout);
            }
        });
    }

    @Override
    public void onUserLeave(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //1. 回收界面元素
                mLayoutManagerTrtc.recyclerVideoCallLayout(userId);
                //2. 删除用户model
                UserModel userInfo = mCallUserModelMap.remove(userId);
                if (userInfo != null) {
                    mCallUserInfoList.remove(userInfo);
                }
            }
        });
    }

    @Override
    public void onReject(final String userId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mCallUserModelMap.containsKey(userId)) {
                    // 进入拒绝环节
                    //1. 回收界面元素
                    mLayoutManagerTrtc.recyclerVideoCallLayout(userId);
                    //2. 删除用户model
                    UserModel userInfo = mCallUserModelMap.remove(userId);
                    if (userInfo != null) {
                        mCallUserInfoList.remove(userInfo);
                        ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_reject_call, userInfo.userName));
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
                if (mCallUserModelMap.containsKey(userId)) {
                    // 进入无响应环节
                    //1. 回收界面元素
                    mLayoutManagerTrtc.recyclerVideoCallLayout(userId);
                    //2. 删除用户model
                    UserModel userInfo = mCallUserModelMap.remove(userId);
                    if (userInfo != null) {
                        mCallUserInfoList.remove(userInfo);
                        ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_not_response, userInfo.userName));
                    }
                }
            }
        });
    }

    @Override
    public void onLineBusy(String userId) {
        if (mCallUserModelMap.containsKey(userId)) {
            // 进入无响应环节
            //1. 回收界面元素
            mLayoutManagerTrtc.recyclerVideoCallLayout(userId);
            //2. 删除用户model
            UserModel userInfo = mCallUserModelMap.remove(userId);
            if (userInfo != null) {
                mCallUserInfoList.remove(userInfo);
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_busy, userInfo.userName));
            }
        }
    }

    @Override
    public void onCallingCancel() {
        if (mSponsorUserInfo != null) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_cancel_call, mSponsorUserInfo.userName));
        }
        stopCameraAndFinish();
    }

    @Override
    public void onCallingTimeout() {
        if (mSponsorUserInfo != null) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_timeout, mSponsorUserInfo.userName));
        }
        stopCameraAndFinish();
    }

    @Override
    public void onCallEnd() {
        if (mSponsorUserInfo != null) {
            ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_user_end, mSponsorUserInfo.userName));
        }
        stopCameraAndFinish();
    }

    @Override
    public void onUserVideoAvailable(final String userId, final boolean isVideoAvailable) {
        //有用户的视频开启了
        TRTCGroupVideoLayout layout = mLayoutManagerTrtc.findVideoCallLayout(userId);
        if (layout != null) {
            layout.setVideoAvailable(isVideoAvailable);
            if (isVideoAvailable) {
                mTRTCCalling.startRemoteView(userId, layout.getVideoView());
            } else {
                mTRTCCalling.stopRemoteView(userId);
            }
        }
    }

    @Override
    public void onUserAudioAvailable(String userId, boolean isAudioAvailable) {
        TRTCLogger.d(TAG, "onUserAudioAvailable, userId=" + userId + ", isAudioAvailable=" + isAudioAvailable);
        TRTCGroupVideoLayout layout = mLayoutManagerTrtc.findVideoCallLayout(userId);
        if (layout != null) {
            layout.muteMic(!isAudioAvailable);
        }
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            int volume = entry.getValue();
            TRTCGroupVideoLayout layout = mLayoutManagerTrtc.findVideoCallLayout(userId);
            if (layout != null) {
                layout.setAudioVolumeProgress(volume);
                layout.setAudioVolume(volume);
            }
        }
    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
        updateNetworkQuality(localQuality, remoteQuality);
    }

    @Override
    public void onSwitchToAudio(boolean success, String message) {
        if (success) {
            updateAudioCallView();
            mIsAudioMode = true;
            if (mIsCalledClick && mRole == TUICalling.Role.CALLED) {
                mTRTCCalling.accept();
            }
            enableHandsFree(false);
        } else {
            Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
        }
    }

    private void enableHandsFree(boolean enable) {
        mIsHandsFree = enable;
        mTRTCCalling.setHandsFree(mIsHandsFree);
        mHandsfreeImg.setActivated(mIsHandsFree);
    }

    /**
     * 等待接听界面
     */
    public void showWaitingResponseView() {
        // 展示自己的画面
        mLayoutManagerTrtc.setMySelfUserId(mSelfModel.userId);
        final TRTCGroupVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout == null) {
            return;
        }
        videoLayout.setVideoAvailable(true);
        mTRTCCalling.openCamera(true, videoLayout.getVideoView());
        visibleSponsorGroup(false);
        if (null == mSponsorUserInfo) {
            // 展示对方的头像和蒙层
            for (UserModel userModel : mOtherInvitingUserInfoList) {
                loadUserInfo(userModel, addUserToManager(userModel));
            }
        } else {
            loadUserInfo(mSponsorUserInfo, addUserToManager(mSponsorUserInfo));
        }

        //3. 展示电话对应界面
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.VISIBLE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        mSwitchCameraImg.setVisibility(View.GONE);
        mOpenCameraLl.setVisibility(View.GONE);
        //3. 设置对应的listener
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.reject();
                stopCameraAndFinish();
            }
        });
        mDialingLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //2.接听电话
                mTRTCCalling.accept();
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        if (null != mSponsorUserInfo) {
            showOtherInvitingUserView();
        }
        mTvHangup.setText(R.string.trtccalling_text_reject);
    }

    private void visibleSponsorGroup(boolean visible) {
        if (visible) {
            mSponsorUserVideoTag.setVisibility(View.VISIBLE);
            mSponsorUserNameTv.setVisibility(View.VISIBLE);
            mSponsorAvatarImg.setVisibility(View.VISIBLE);
            mShadeSponsor.setVisibility(View.VISIBLE);
        } else {
            mSponsorUserVideoTag.setVisibility(View.GONE);
            mSponsorUserNameTv.setVisibility(View.GONE);
            mSponsorAvatarImg.setVisibility(View.GONE);
            mShadeSponsor.setVisibility(View.GONE);
        }
    }

    /**
     * 展示邀请列表
     */
    public void showInvitingView() {
        //1. 展示自己的界面
        mLayoutManagerTrtc.setMySelfUserId(mSelfModel.userId);
        final TRTCGroupVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout != null) {
            videoLayout.setVideoAvailable(true);
        }
        for (int i = 0; i < mCallUserInfoList.size(); i++) {
            final UserModel userModel = mCallUserInfoList.get(i);
            loadUserInfo(userModel, addUserToManager(userModel));
        }
        //2. 设置底部栏
        mHangupLl.setVisibility(View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                stopCameraAndFinish();
            }
        });
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        mSwitchCameraImg.setVisibility(View.GONE);
        mOpenCameraLl.setVisibility(View.GONE);
        //3. 隐藏中间他们也在界面
        hideOtherInvitingUserView();
        //4. sponsor画面也隐藏
        visibleSponsorGroup(false);
        mSponsorUserInfo = mCallUserInfoList.get(0);
        ImageLoader.loadImage(mContext, mSponsorAvatarImg, mSponsorUserInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
        mSponsorUserVideoTag.setText(mContext.getString(R.string.trtccalling_waiting_be_accepted));
        mSponsorUserNameTv.setText(mSponsorUserInfo.userName);
        mTvHangup.setText(R.string.trtccalling_text_hangup);
    }

    /**
     * 展示通话中的界面
     */
    public void showCallingView() {
        //1. 蒙版消失
        visibleSponsorGroup(false);
        //2. 底部状态栏
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.VISIBLE);
        mMuteLl.setVisibility(View.VISIBLE);
        mSwitchCameraImg.setVisibility(mIsAudioMode ? View.GONE : View.VISIBLE);
        mOpenCameraLl.setVisibility(mIsAudioMode ? View.GONE : View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                stopCameraAndFinish();
            }
        });
        showTimeCount();
        hideOtherInvitingUserView();
        mTvHangup.setText(R.string.trtccalling_text_hangup);
    }

    private void showTimeCount() {
        if (mTimeRunnable != null) {
            return;
        }
        mTimeCount = 0;
        mTimeTv.setText(getShowTime(mTimeCount));
        if (mTimeRunnable == null) {
            mTimeRunnable = new Runnable() {
                @Override
                public void run() {
                    mTimeCount++;
                    if (mTimeTv != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTimeTv.setText(getShowTime(mTimeCount));
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

    private void showOtherInvitingUserView() {
        if (mOtherInvitingUserInfoList == null || mOtherInvitingUserInfoList.size() == 0) {
            return;
        }
        mInvitingGroup.setVisibility(View.VISIBLE);
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_size);
        int leftMargin = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_left_margin);
        for (int index = 0; index < mOtherInvitingUserInfoList.size() && index < MAX_SHOW_INVITING_USER; index++) {
            final UserModel userInfo = mOtherInvitingUserInfoList.get(index);
            final ImageView imageView = new ImageView(mContext);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            ImageLoader.loadImage(mContext, imageView, userInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
            mImgContainerLl.addView(imageView);
            CallingInfoManager.getInstance().getUserInfoByUserId(userInfo.userId, new CallingInfoManager.UserCallback() {
                @Override
                public void onSuccess(UserModel model) {
                    userInfo.userName = model.userName;
                    userInfo.userAvatar = model.userAvatar;
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ImageLoader.loadImage(mContext, imageView, userInfo.userAvatar, R.drawable.trtccalling_groupcall_wait_background);
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
        mInvitingGroup.setVisibility(View.GONE);
    }


    private void showRemoteUserView() {

        if (mCallUserInfoList.isEmpty()) {
            return;
        }
        for (int i = 0; i < mCallUserInfoList.size(); i++) {
            UserModel remoteUser = mCallUserInfoList.get(i);
            if (remoteUser == null) {
                return;
            }
            TRTCGroupVideoLayout videoLayout = mLayoutManagerTrtc.findVideoCallLayout(remoteUser.userId);
            if (videoLayout == null) {
                return;
            }
            videoLayout.setVideoAvailable(false);
            videoLayout.setRemoteIconAvailable(true);
        }
    }

    private TRTCGroupVideoLayout addUserToManager(UserModel userInfo) {
        TRTCGroupVideoLayout layout = mLayoutManagerTrtc.allocVideoCallLayout(userInfo.userId);
        if (layout == null) {
            return null;
        }
        Log.d(TAG, String.format("addUserToManager, userId=%s, userName=%s, userAvatar=%s", userInfo.userId, userInfo.userName, userInfo.userAvatar));
        layout.setUserName(userInfo.userName);
        ImageLoader.loadImage(mContext, layout.getHeadImg(), userInfo.userAvatar, R.drawable.trtccalling_groupcall_wait_background);
        return layout;
    }

    private void loadUserInfo(final UserModel userModel, final TRTCGroupVideoLayout layout) {
        if (null == userModel || null == layout) {
            Log.e(TAG, "loadUserInfo error: null == userModel || null == layout");
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
                        ImageLoader.loadImage(mContext, layout.getHeadImg(), userModel.userAvatar, R.drawable.trtccalling_groupcall_wait_background);
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
    }

    private void stopCameraAndFinish() {
        mTRTCCalling.closeCamera();
        finish();
    }

    private void updateAudioCallView() {
        mOpenCameraLl.setVisibility(View.GONE);
        mSwitchCameraImg.setVisibility(View.GONE);
        ConstraintLayout.LayoutParams muteLayoutParams = new ConstraintLayout.LayoutParams(
                ConstraintLayout.LayoutParams.WRAP_CONTENT, ConstraintLayout.LayoutParams.WRAP_CONTENT
        );
        int hangupLlId = mHangupLl.getId();
        muteLayoutParams.bottomToBottom = hangupLlId;
        muteLayoutParams.rightToLeft = hangupLlId;
        muteLayoutParams.rightMargin = Utils.dp2px(mContext, 40);
        mMuteLl.setLayoutParams(muteLayoutParams);

        ConstraintLayout.LayoutParams handsFreeLayoutParams = new ConstraintLayout.LayoutParams(
                ConstraintLayout.LayoutParams.WRAP_CONTENT, ConstraintLayout.LayoutParams.WRAP_CONTENT
        );
        handsFreeLayoutParams.bottomToBottom = hangupLlId;
        handsFreeLayoutParams.leftToRight = hangupLlId;
        handsFreeLayoutParams.leftMargin = Utils.dp2px(mContext, 40);
        mHandsfreeLl.setLayoutParams(handsFreeLayoutParams);

        ConstraintLayout.LayoutParams timeLayoutParams = new ConstraintLayout.LayoutParams(
                ConstraintLayout.LayoutParams.WRAP_CONTENT, ConstraintLayout.LayoutParams.WRAP_CONTENT
        );
        timeLayoutParams.bottomToTop = hangupLlId;
        timeLayoutParams.rightToRight = ConstraintLayout.LayoutParams.PARENT_ID;
        timeLayoutParams.leftToLeft = ConstraintLayout.LayoutParams.PARENT_ID;
        timeLayoutParams.bottomMargin = Utils.dp2px(mContext, 20);
        mTimeTv.setLayoutParams(timeLayoutParams);
        showRemoteUserView();
    }

    protected void finish() {
        super.finish();
        mOtherInvitingUserInfoList.clear();
        mCallUserInfoList.clear();
        mCallUserModelMap.clear();
    }

}