package com.tencent.liteav.trtccalling.ui.videocall;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;
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
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;
import com.tencent.liteav.trtccalling.ui.common.Utils;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCGroupVideoLayout;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCGroupVideoLayoutManager;

import java.util.List;
import java.util.Map;

public class TUIGroupCallVideoView extends BaseTUICallView {
    private static final String TAG = "TUIGroupCallVideoView";

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
    private TRTCGroupVideoLayoutManager mLayoutManagerTRTC;
    private Group                       mInvitingGroup;
    private TextView                    mInvitedTag;
    private LinearLayout                mImgContainerLl;
    private TextView                    mTimeTv;
    private RoundCornerImageView        mSponsorAvatarImg;
    private TextView                    mSponsorUserNameTv;
    private TextView                    mSponsorUserVideoTag;
    private View                        mViewSwitchAudioCall;
    private View                        mShadeSponsor;

    public TUIGroupCallVideoView(Context context, TUICalling.Role role, TUICalling.Type type, String[] userIDs,
                                 String sponsorID, String groupID, boolean isFromGroup) {
        super(context, role, type, userIDs, sponsorID, groupID, isFromGroup);
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
        mLayoutManagerTRTC = (TRTCGroupVideoLayoutManager) findViewById(R.id.trtc_layout_manager);
        mInvitingGroup = (Group) findViewById(R.id.group_inviting);
        mInvitedTag = findViewById(R.id.tv_inviting_tag);
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
        setImageBackView(findViewById(R.id.img_video_back));
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (TUICalling.Role.CALLED == mRole && !mTRTCCalling.isValidInvite()) {
            TRTCLogger.w(TAG, "this invitation is invalid");
            onCallingCancel();
        }
        initListener();
        if (mRole == TUICalling.Role.CALLED) {
            // 被叫方
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
            showInvitingView();
            PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(List<String> permissionsGranted) {
                    TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(mSelfModel.userId);
                    if (null != layout) {
                        mTRTCCalling.openCamera(true, layout.getVideoView());
                    }
                    startInviting(TRTCCalling.TYPE_VIDEO_CALL);
                }

                @Override
                public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                    ToastUtils.showShort(R.string.trtccalling_tips_start_camera_audio);
                    finish();
                }
            }).request();
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
                TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(mSelfModel.userId);
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
                TRTCGroupVideoLayout videoLayout = mLayoutManagerTRTC.findVideoCallLayout(mSelfModel.userId);
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
            }
        });
    }

    @Override
    public void onUserEnter(final String userId) {
        super.onUserEnter(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showCallingView();
                UserModel userModel = mCallUserModelMap.get(userId);
                TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(userId);
                if (null == layout) {
                    layout = addUserToManager(userModel);
                }
                layout.stopLoading();
                loadUserInfo(userModel, layout);
                //C2C多人通话:有被叫用户接听了通话,从被叫列表中移除
                if (null != userModel && mOtherInviteeList.contains(userModel)) {
                    mOtherInviteeList.remove(userModel);
                }
            }
        });
    }

    @Override
    public void onUserLeave(final String userId) {
        super.onUserLeave(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.d(TAG, "onUserLeave userId:" + userId + " , list:" + mOtherInviteeList);
                //1. 回收界面元素
                mLayoutManagerTRTC.recyclerVideoCallLayout(userId);

                //C2C多人通话:被叫方:如果是主叫"取消"了电话,更新已接听用户的UI显示
                if (null != mSponsorUserInfo && userId.equals(mSponsorUserInfo.userId)) {
                    for (UserModel model : mOtherInviteeList) {
                        if (null != model && !TextUtils.isEmpty(model.userId)) {
                            //回收所有未接通用户的界面
                            mLayoutManagerTRTC.recyclerVideoCallLayout(model.userId);
                        }
                    }
                }
            }
        });
    }

    @Override
    public void onReject(final String userId) {
        super.onReject(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.d(TAG, "onReject: userId = " + userId + ",mCallUserModelMap " + mCallUserModelMap);
                //用户拒绝,回收界面元素
                mLayoutManagerTRTC.recyclerVideoCallLayout(userId);
                UserModel userInfo = getRemovedUserModel();
                if (null != userInfo && mOtherInviteeList.contains(userInfo)) {
                    mOtherInviteeList.remove(userInfo);
                    showOtherInvitingUserView();
                }
            }
        });
    }

    @Override
    public void onNoResp(final String userId) {
        super.onNoResp(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.d(TAG, "onNoResp: userId = " + userId + ",mCallUserModelMap: " + mCallUserModelMap);
                //用户无响应,回收界面元素
                mLayoutManagerTRTC.recyclerVideoCallLayout(userId);
                UserModel userInfo = getRemovedUserModel();
                //C2C多人通话:有被叫用户超时未接听,从被叫列表中移除
                if (null != userInfo && mOtherInviteeList.contains(userInfo)) {
                    mOtherInviteeList.remove(userInfo);
                    showOtherInvitingUserView();
                }
            }
        });
    }

    @Override
    public void onLineBusy(String userId) {
        super.onLineBusy(userId);
        TRTCLogger.d(TAG, "onLineBusy: userId = " + userId + ",mCallUserModelMap " + mCallUserModelMap);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // 用户忙线,回收界面元素
                mLayoutManagerTRTC.recyclerVideoCallLayout(userId);
                //2. 删除用户model
                UserModel userInfo = getRemovedUserModel();
                //C2C多人通话:有被叫用户忙线中,从被叫列表中移除
                if (null != userInfo && mOtherInviteeList.contains(userInfo)) {
                    mOtherInviteeList.remove(userInfo);
                    showOtherInvitingUserView();
                }
            }
        });
    }

    @Override
    public void onUserVideoAvailable(final String userId, final boolean isVideoAvailable) {
        //有用户的视频开启了
        TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(userId);
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
        TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(userId);
        if (layout != null) {
            layout.muteMic(!isAudioAvailable);
        }
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            int volume = entry.getValue();
            TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(userId);
            if (layout != null) {
                layout.setAudioVolumeProgress(volume);
                layout.setAudioVolume(volume);
            }
        }
    }

    @Override
    public void onSwitchToAudio(boolean success, String message) {
        if (success) {
            updateAudioCallView();
            mCallType = TUICalling.Type.AUDIO;
            if (mIsCalledClick && mRole == TUICalling.Role.CALLED) {
                mTRTCCalling.accept();
            }
            enableHandsFree(true);
        } else {
            ToastUtils.showShort(message);
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
        super.showWaitingResponseView();
        //1. 展示自己的画面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        visibleSponsorGroup(false);
        //2. 展示对方的头像和蒙层
        if (null == mSponsorUserInfo) {
            for (UserModel userModel : mOtherInviteeList) {
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
        //设置对应的listener
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.reject();
                finish();
            }
        });
        mDialingLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //接听电话
                mTRTCCalling.accept();
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        if (null != mSponsorUserInfo) {
            showOtherInvitingUserView();
        }
        mTvHangup.setText(R.string.trtccalling_text_reject);
        mInvitedTag.setText(mContext.getString(R.string.trtccalling_invite_video_call));
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
        super.showInvitingView();
        //1. 展示自己的界面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        final TRTCGroupVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout != null) {
            videoLayout.setVideoAvailable(true);
        }
        //2. 展示其他用户的画面
        for (int i = 0; i < mCallUserInfoList.size(); i++) {
            final UserModel userModel = mCallUserInfoList.get(i);
            TRTCGroupVideoLayout layout = addUserToManager(userModel);
            layout.startLoading();
            loadUserInfo(userModel, layout);
        }
        //3. 设置底部栏
        mHangupLl.setVisibility(View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                finish();
            }
        });
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        mSwitchCameraImg.setVisibility(View.GONE);
        mOpenCameraLl.setVisibility(View.GONE);
        //4. 隐藏中间他们也在界面
        hideOtherInvitingUserView();
        visibleSponsorGroup(false);
        UserModel initeeModel = mCallUserInfoList.get(0);
        ImageLoader.loadImage(mContext, mSponsorAvatarImg, initeeModel.userAvatar, R.drawable.trtccalling_ic_avatar);
        mSponsorUserVideoTag.setText(mContext.getString(R.string.trtccalling_waiting_be_accepted));
        mSponsorUserNameTv.setText(initeeModel.userName);
        mTvHangup.setText(R.string.trtccalling_text_hangup);
        mInvitingGroup.setVisibility(VISIBLE);
        mInvitedTag.setText(mContext.getString(R.string.trtccalling_waiting_be_accepted));
    }

    /**
     * 展示通话中的界面
     */
    public void showCallingView() {
        super.showCallingView();
        //1. 增加自己的画面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        TRTCGroupVideoLayout videoLayout = mLayoutManagerTRTC.findVideoCallLayout(mSelfModel.userId);
        if (null == videoLayout) {
            videoLayout = addUserToManager(mSelfModel);
            loadUserInfo(mSelfModel, videoLayout);
        }
        videoLayout.setVideoAvailable(true);
        mTRTCCalling.openCamera(true, videoLayout.getVideoView());
        visibleSponsorGroup(false);
        //2. 底部状态栏
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.VISIBLE);
        mMuteLl.setVisibility(View.VISIBLE);
        boolean isAudioMode = TUICalling.Type.AUDIO == mCallType;
        mSwitchCameraImg.setVisibility(isAudioMode ? View.GONE : View.VISIBLE);
        mOpenCameraLl.setVisibility(isAudioMode ? View.GONE : View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                finish();
            }
        });
        showTimeCount(mTimeTv);
        mTvHangup.setText(R.string.trtccalling_text_hangup);
        //3. 隐藏其他未接听用户的小窗
        hideOtherInvitingUserView();
        //mSponsorUserInfo不为空,说明是被叫;
        //C2C多人通话增加:自己接通后,其他用户大窗显示,未接听用户显示头像
        if (null != mSponsorUserInfo) {
            //被叫已接听
            mIsInRoom = true;
            TRTCLogger.d(TAG, "showCallingView: mCallUserModelMap = " + mCallUserModelMap);
            for (Map.Entry<String, UserModel> entry : mCallUserModelMap.entrySet()) {
                UserModel model = mCallUserModelMap.get(entry.getKey());
                if (null != model && !TextUtils.isEmpty(model.userId)) {
                    TRTCGroupVideoLayout layout = mLayoutManagerTRTC.findVideoCallLayout(model.userId);
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

    private void showOtherInvitingUserView() {
        if (CollectionUtils.isEmpty(mOtherInviteeList)) {
            mImgContainerLl.removeAllViews();
            mInvitingGroup.setVisibility(mIsInRoom ? GONE : VISIBLE);
            return;
        }
        mInvitingGroup.setVisibility(View.VISIBLE);
        mImgContainerLl.removeAllViews();
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_size);
        int leftMargin = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_left_margin);
        for (int index = 0; index < mOtherInviteeList.size(); index++) {
            final UserModel userInfo = mOtherInviteeList.get(index);
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
                            ImageLoader.loadImage(mContext, imageView, userInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
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
            TRTCGroupVideoLayout videoLayout = mLayoutManagerTRTC.findVideoCallLayout(remoteUser.userId);
            if (videoLayout == null) {
                return;
            }
            videoLayout.setVideoAvailable(false);
            videoLayout.setRemoteIconAvailable(true);
        }
    }

    private TRTCGroupVideoLayout addUserToManager(UserModel userInfo) {
        TRTCGroupVideoLayout layout = mLayoutManagerTRTC.allocVideoCallLayout(userInfo.userId);
        if (layout == null) {
            return null;
        }
        TRTCLogger.d(TAG, String.format("addUserToManager, userId=%s, userName=%s, userAvatar=%s", userInfo.userId,
                userInfo.userName, userInfo.userAvatar));
        loadUserInfo(userInfo, layout);
        return layout;
    }

    //从IM查询用户信息并更新布局显示
    private void loadUserInfo(final UserModel userModel, final TRTCGroupVideoLayout layout) {
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
                        ImageLoader.loadImage(mContext, layout.getHeadImg(), userModel.userAvatar, R.drawable.trtccalling_ic_avatar);
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
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

    @Override
    protected void finish() {
        super.finish();
        mTRTCCalling.closeCamera();
    }
}