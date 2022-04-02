package com.tencent.liteav.trtccalling.ui.videocall;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.Group;

import com.blankj.utilcode.constant.PermissionConstants;
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
import com.tencent.liteav.trtccalling.ui.base.VideoLayoutFactory;
import com.tencent.liteav.trtccalling.ui.common.RoundCornerImageView;
import com.tencent.liteav.trtccalling.ui.common.Utils;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayout;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayoutManager;

import java.util.List;
import java.util.Map;

public class TUICallVideoView extends BaseTUICallView {
    private static final String TAG = "TUICallVideoView";

    private ImageView              mMuteImg;
    private ImageView              mSwitchCameraImg;
    private LinearLayout           mOpenCameraLl;
    private ImageView              mOpenCameraImg;
    private LinearLayout           mMuteLl;
    private ImageView              mHangupImg;
    private LinearLayout           mHangupLl;
    private ImageView              mHandsfreeImg;
    private LinearLayout           mHandsfreeLl;
    private ImageView              mDialingImg;
    private LinearLayout           mDialingLl;
    private TextView               mTvHangup;
    private TRTCVideoLayoutManager mLayoutManagerTRTC;
    private Group                  mInvitingGroup;
    private LinearLayout           mImgContainerLl;
    private TextView               mTimeTv;
    private RoundCornerImageView   mSponsorAvatarImg;
    private TextView               mSponsorUserNameTv;
    private TextView               mSponsorUserVideoTag;
    private View                   mViewSwitchAudioCall;
    private View                   mShadeSponsor;
    private TextView               mTextInviteWait;
    private View                   mRootView;

    public TUICallVideoView(Context context, TUICalling.Role role, TUICalling.Type type, String[] userIDs,
                            String sponsorID, String groupID, boolean isFromGroup, VideoLayoutFactory factory) {
        super(context, role, type, userIDs, sponsorID, groupID, isFromGroup);
        mLayoutManagerTRTC.initVideoFactory(factory);
    }

    @Override
    protected void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.trtccalling_videocall_activity_call_main, this);
        mRootView = findViewById(R.id.cl_root);
        mMuteImg = (ImageView) findViewById(R.id.iv_mute);
        mMuteLl = (LinearLayout) findViewById(R.id.ll_mute);
        mHangupImg = (ImageView) findViewById(R.id.iv_hangup);
        mHangupLl = (LinearLayout) findViewById(R.id.ll_hangup);
        mHandsfreeImg = (ImageView) findViewById(R.id.iv_handsfree);
        mHandsfreeLl = (LinearLayout) findViewById(R.id.ll_handsfree);
        mDialingImg = (ImageView) findViewById(R.id.iv_dialing);
        mDialingLl = (LinearLayout) findViewById(R.id.ll_dialing);
        mLayoutManagerTRTC = (TRTCVideoLayoutManager) findViewById(R.id.trtc_layout_manager);
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
        if (TUICalling.Role.CALLED == mRole) {
            // 被叫方
            PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.MICROPHONE)
                    .callback(new PermissionUtils.FullCallback() {
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
            PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.MICROPHONE)
                    .callback(new PermissionUtils.FullCallback() {
                        @Override
                        public void onGranted(List<String> permissionsGranted) {
                            TRTCVideoLayout layout = mLayoutManagerTRTC.findCloudView(mSelfModel.userId);
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
                TRTCVideoLayout videoLayout = mLayoutManagerTRTC.findCloudView(mSelfModel.userId);
                if (videoLayout == null) {
                    return;
                }
                if (mIsCameraOpen) {
                    mTRTCCalling.closeCamera();
                    videoLayout.setVideoAvailable(false);
                    mIsCameraOpen = false;
                    mOpenCameraImg.setActivated(true);
                    mSwitchCameraImg.setVisibility(GONE);
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
                UserModel userModel = new UserModel();
                userModel.userId = userId;
                mCallUserModelMap.put(userId, userModel);
                TRTCVideoLayout videoLayout = mLayoutManagerTRTC.findCloudView(userId);
                if (null == videoLayout) {
                    videoLayout = addUserToManager(userModel);
                }
                boolean isAudioMode = (TUICalling.Type.AUDIO == mCallType);
                videoLayout.setVideoAvailable(!isAudioMode);
                videoLayout.setRemoteIconAvailable(isAudioMode);
                loadUserInfo(userModel, videoLayout);
            }
        });
    }

    @Override
    public void onUserLeave(final String userId) {
        super.onUserLeave(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //1. 回收界面元素
                mLayoutManagerTRTC.recyclerCloudViewView(userId);
            }
        });
    }

    @Override
    public void onReject(final String userId) {
        super.onReject(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //用户拒绝,回收界面元素
                mLayoutManagerTRTC.recyclerCloudViewView(userId);
            }
        });
    }

    @Override
    public void onNoResp(final String userId) {
        super.onNoResp(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //用户无响应,回收界面元素
                mLayoutManagerTRTC.recyclerCloudViewView(userId);
            }
        });
    }

    @Override
    public void onLineBusy(String userId) {
        super.onLineBusy(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //用户忙线,回收界面元素
                mLayoutManagerTRTC.recyclerCloudViewView(userId);
            }
        });
    }

    @Override
    public void onUserVideoAvailable(final String userId, final boolean isVideoAvailable) {
        //有用户的视频开启了
        TRTCVideoLayout layout = mLayoutManagerTRTC.findCloudView(userId);
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
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            TRTCVideoLayout layout = mLayoutManagerTRTC.findCloudView(userId);
            if (layout != null) {
                layout.setAudioVolumeProgress(entry.getValue());
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
        super.showWaitingResponseView();
        //1. 展示自己的画面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        final TRTCVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout == null) {
            return;
        }
        videoLayout.setVideoAvailable(true);
        mTRTCCalling.openCamera(true, videoLayout.getVideoView());
        //2. 展示对方的头像和蒙层
        visibleSponsorGroup(true);
        CallingInfoManager.getInstance().getUserInfoByUserId(mSponsorUserInfo.userId, new CallingInfoManager.UserCallback() {
            @Override
            public void onSuccess(UserModel model) {
                mSponsorUserInfo.userName = model.userName;
                mSponsorUserInfo.userAvatar = model.userAvatar;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isDestroyed()) {
                            return;
                        }
                        ImageLoader.loadImage(mContext, mSponsorAvatarImg, mSponsorUserInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
                        mSponsorUserNameTv.setText(mSponsorUserInfo.userName);
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
        //3. 展示电话对应界面
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.VISIBLE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        mSwitchCameraImg.setVisibility(View.GONE);
        mOpenCameraLl.setVisibility(View.GONE);
        mViewSwitchAudioCall.setVisibility(View.VISIBLE);
        //3. 设置对应的listener
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
                //2.接听电话
                mTRTCCalling.accept();
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        showOtherInvitingUserView();
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
        super.showInvitingView();
        //1. 展示自己的界面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
        final TRTCVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout == null) {
            return;
        }
        videoLayout.setVideoAvailable(true);

        //2. 设置底部栏
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
        mViewSwitchAudioCall.setVisibility(View.VISIBLE);
        //3. 隐藏中间他们也在界面
        hideOtherInvitingUserView();
        //4. sponsor画面也隐藏
        visibleSponsorGroup(true);
        UserModel invitee = mCallUserInfoList.get(0);
        mSponsorUserVideoTag.setText(mContext.getString(R.string.trtccalling_waiting_be_accepted));
        mTvHangup.setText(R.string.trtccalling_text_hangup);
        CallingInfoManager.getInstance().getUserInfoByUserId(invitee.userId, new CallingInfoManager.UserCallback() {
            @Override
            public void onSuccess(UserModel model) {
                invitee.userName = model.userName;
                invitee.userAvatar = model.userAvatar;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isDestroyed()) {
                            return;
                        }
                        mSponsorUserNameTv.setText(invitee.userName);
                        ImageLoader.loadImage(mContext, mSponsorAvatarImg, invitee.userAvatar, R.drawable.trtccalling_ic_avatar);
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
    }

    /**
     * 展示通话中的界面
     */
    public void showCallingView() {
        super.showCallingView();
        mIsCalling = true;
        //1. 蒙版消失
        visibleSponsorGroup(false);
        //2. 底部状态栏
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.VISIBLE);
        mMuteLl.setVisibility(View.VISIBLE);
        boolean isAudioMode = (TUICalling.Type.AUDIO == mCallType);
        mSwitchCameraImg.setVisibility(isAudioMode ? View.GONE : View.VISIBLE);
        mOpenCameraLl.setVisibility(isAudioMode ? View.GONE : View.VISIBLE);
        mViewSwitchAudioCall.setVisibility(isAudioMode ? View.GONE : View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                finish();
            }
        });
        showTimeCount(mTimeTv);
        hideOtherInvitingUserView();
        mTvHangup.setText(R.string.trtccalling_text_hangup);
        if (mTextInviteWait != null && null != mTextInviteWait.getParent()) {
            ((ViewGroup) mTextInviteWait.getParent()).removeView(mTextInviteWait);
            mTextInviteWait = null;
        }
    }

    private void showOtherInvitingUserView() {
        if (mOtherInviteeList == null || mOtherInviteeList.size() == 0) {
            return;
        }
        mInvitingGroup.setVisibility(View.VISIBLE);
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_size);
        int leftMargin = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_left_margin);
        for (int index = 0; index < mOtherInviteeList.size(); index++) {
            UserModel userInfo = mOtherInviteeList.get(index);
            ImageView imageView = new ImageView(mContext);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            ImageLoader.loadImage(mContext, imageView, userInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
            mImgContainerLl.addView(imageView);
        }
    }

    private void hideOtherInvitingUserView() {
        mInvitingGroup.setVisibility(View.GONE);
    }

    private void showRemoteUserView(UserModel remoteUser) {
        if (null == remoteUser) {
            return;
        }
        String userId = remoteUser.userId;
        TRTCVideoLayout videoLayout = mLayoutManagerTRTC.findCloudView(userId);
        if (videoLayout == null) {
            videoLayout = addUserToManager(remoteUser);
        }
        videoLayout.setVideoAvailable(false);
        videoLayout.setRemoteIconAvailable(true);
        CallingInfoManager.getInstance().getUserInfoByUserId(userId, new CallingInfoManager.UserCallback() {
            @Override
            public void onSuccess(UserModel model) {
                if (isDestroyed()) {
                    return;
                }
                TRTCVideoLayout layout = mLayoutManagerTRTC.findCloudView(model.userId);
                if (layout != null) {
                    layout.setUserName(model.userName);
                    if (TUICalling.Type.AUDIO == mCallType) {
                        layout.setUserNameColor(getResources().getColor(R.color.trtccalling_color_black));
                    }
                    ImageLoader.loadImage(mContext, layout.getHeadImg(), model.userAvatar,
                            R.drawable.trtccalling_ic_avatar);
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.trtccalling_toast_search_fail, msg));
            }
        });
    }

    private TRTCVideoLayout addUserToManager(UserModel userInfo) {
        TRTCVideoLayout layout = mLayoutManagerTRTC.allocCloudVideoView(userInfo.userId);
        if (layout == null) {
            return null;
        }
        return layout;
    }

    //查询昵称和头像
    private void loadUserInfo(final UserModel userModel, TRTCVideoLayout layout) {
        if (null == userModel || null == layout) {
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
                        if (isDestroyed()) {
                            return;
                        }
                        layout.setUserName(userModel.userName);
                        ImageLoader.loadImage(mContext, layout.getHeadImg(), userModel.userAvatar,
                                R.drawable.trtccalling_ic_avatar);
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
        updateAudioCallViewColor();
        visibleSponsorGroup(false);
        mViewSwitchAudioCall.setVisibility(View.GONE);
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
        UserModel remoteUser = null;
        if (mRole == TUICalling.Role.CALLED) {
            remoteUser = mSponsorUserInfo;
        } else if (mRole == TUICalling.Role.CALL) {
            TRTCVideoLayout videoLayout = mLayoutManagerTRTC.findCloudView(mSelfModel.userId);
            videoLayout.setVideoAvailable(false);
            videoLayout.setRemoteIconAvailable(false);
            if (!mCallUserInfoList.isEmpty()) {
                remoteUser = mCallUserInfoList.get(0);
            }
        }
        showRemoteUserView(remoteUser);
        TRTCVideoLayout videoLayout = mLayoutManagerTRTC.findCloudView(remoteUser.userId);
        if (null != videoLayout && !mIsCalling) {
            mTextInviteWait = new TextView(mContext);
            mTextInviteWait.setTextColor(getResources().getColor(R.color.trtccalling_color_gray));
            mTextInviteWait.setText(mRole == TUICalling.Role.CALL ? mContext.getString(R.string.trtccalling_waiting_be_accepted) : mContext.getString(R.string.trtccalling_invite_audio_call));
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
            params.addRule(RelativeLayout.BELOW, R.id.tv_user_name);
            params.addRule(RelativeLayout.CENTER_HORIZONTAL);
            videoLayout.addView(mTextInviteWait, params);
        }
    }

    private void updateAudioCallViewColor() {
        mRootView.setBackgroundColor(getResources().getColor(R.color.trtccalling_color_audiocall_background));
        ((TextView) findViewById(R.id.tv_time)).setTextColor(getResources().getColor(R.color.trtccalling_color_main));
        ((TextView) findViewById(R.id.tv_mic)).setTextColor(getResources().getColor(R.color.trtccalling_color_second));
        ((TextView) findViewById(R.id.tv_speaker)).setTextColor(getResources().getColor(R.color.trtccalling_color_second));
        ((TextView) findViewById(R.id.tv_hangup)).setTextColor(getResources().getColor(R.color.trtccalling_color_second));
        ((TextView) findViewById(R.id.tv_answer)).setTextColor(getResources().getColor(R.color.trtccalling_color_second));
    }

    @Override
    protected void finish() {
        super.finish();
        mTRTCCalling.closeCamera();
    }
}
