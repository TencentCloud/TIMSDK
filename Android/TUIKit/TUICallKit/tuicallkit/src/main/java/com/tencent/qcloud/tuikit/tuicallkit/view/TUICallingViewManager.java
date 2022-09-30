package com.tencent.qcloud.tuikit.tuicallkit.view;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallengine.utils.TUICallingConstants.Scene;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.BaseCallActivity;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.Constants;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingAction;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayoutEntity;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest;
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils;
import com.tencent.qcloud.tuikit.tuicallkit.view.component.BaseUserView;
import com.tencent.qcloud.tuikit.tuicallkit.view.component.TUICallingSingleVideoUserView;
import com.tencent.qcloud.tuikit.tuicallkit.view.component.TUICallingUserView;
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatCallView;
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatWindowService;
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.HomeWatcher;
import com.tencent.qcloud.tuikit.tuicallkit.view.function.BaseFunctionView;
import com.tencent.qcloud.tuikit.tuicallkit.view.function.TUICallingAudioFunctionView;
import com.tencent.qcloud.tuikit.tuicallkit.view.function.TUICallingSwitchAudioView;
import com.tencent.qcloud.tuikit.tuicallkit.view.function.TUICallingVideoFunctionView;
import com.tencent.qcloud.tuikit.tuicallkit.view.function.TUICallingVideoInviteFunctionView;
import com.tencent.qcloud.tuikit.tuicallkit.view.function.TUICallingWaitFunctionView;
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView;
import com.tencent.qcloud.tuikit.tuicallkit.view.root.TUICallingGroupView;
import com.tencent.qcloud.tuikit.tuicallkit.view.root.TUICallingImageView;
import com.tencent.qcloud.tuikit.tuicallkit.view.root.TUICallingSingleView;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class TUICallingViewManager implements ITUINotification {
    private static final String TAG = "TUICallingViewManager";

    private final Context           mContext;
    private final Handler           mMainHandler = new Handler(Looper.getMainLooper());
    private final UserLayoutFactory mUserLayoutFactory;
    private final TUICallingAction  mCallingAction;

    private CallingUserModel        mSelfUserModel;
    private List<CallingUserModel>  mInviteeList      = new ArrayList<>();
    private CallingUserModel        mInviter;
    private TUICallDefine.MediaType mMediaType        = TUICallDefine.MediaType.Unknown;
    private TUICallDefine.Role      mCallRole         = TUICallDefine.Role.None;
    private Scene                   mCallScene;
    private boolean                 mEnableFloatView  = false;
    private boolean                 mEnableInviteUser = false;
    private String                  mGroupId;

    private BaseCallView     mBaseCallView;
    private BaseFunctionView mFunctionView;
    private BaseUserView     mUserView;
    private ImageView        mImageFloatFunction;
    private FloatCallView    mFloatCallView;
    private LinearLayout     mOtherUserLayout;
    private HomeWatcher      mHomeWatcher;
    private UserInfoUtils    mUserInfoUtils;

    public TUICallingViewManager(Context context) {
        mContext = context.getApplicationContext();
        mUserLayoutFactory = new UserLayoutFactory(mContext);
        mCallingAction = new TUICallingAction(context);
        mUserInfoUtils = new UserInfoUtils();
        registerCallingEvent();
    }

    private void registerCallingEvent() {
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CAMERA_OPEN, this);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CAMERA_FRONT, this);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_MIC_STATUS_CHANGED, this);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_AUDIOPLAYDEVICE_CHANGED, this);

        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CALL_STATUS_CHANGED, this);
        TUICore.registerEvent(TUIConstants.TUIGroup.EVENT_GROUP,
                TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_MEMBER_SELECTED, this);
    }

    public void createCallingView(List<CallingUserModel> inviteeList, CallingUserModel inviter,
                                  TUICallDefine.MediaType type, TUICallDefine.Role role, Scene scene) {
        mMediaType = type;
        mCallRole = role;
        mInviter = inviter;
        mInviteeList = inviteeList;
        mCallScene = scene;
        initHomeWatcher();

        TUILog.i(TAG, "createCallingView, mCallType: " + mMediaType + " ,mCallRole: " + mCallRole
                + " ,mInviter: " + mInviter + " ,mCallScene: " + mCallScene + " ,mInviteeList: " + mInviteeList);

        if (Scene.SINGLE_CALL.equals(mCallScene)) {
            initSingleWaitingView();
        } else {
            initGroupWaitingView();
        }
    }

    //中途加人: 主动加入一个已有通话
    public void createGroupCallingAcceptView(TUICallDefine.MediaType type, Scene scene) {
        initSelfModel();
        mMediaType = type;
        mCallRole = TUICallDefine.Role.Called;
        mCallScene = scene;
        mUserLayoutFactory.allocUserLayout(mSelfUserModel);
        initGroupAcceptCallView();
    }

    public void updateCallingUserView(List<CallingUserModel> inviteeList, CallingUserModel inviter) {
        TUILog.i(TAG, "updateCallingView: inviteeList = " + inviteeList + " ,inviter = " + inviter);
        mInviter = inviter;
        mInviteeList = inviteeList;

        CallingUserModel userModel;
        if (TUICallDefine.Role.Caller.equals(mCallRole)) {
            userModel = inviteeList.get(0);
            for (CallingUserModel model : inviteeList) {
                reloadUserModel(model);
            }
        } else {
            userModel = inviter;
            reloadUserModel(inviter);
        }

        if (null != mUserView) {
            mUserView.updateUserInfo(userModel);
        }
        initOtherInviteeView();
    }

    public void showCallingView() {
        TUILog.i(TAG, "startActivity: mBaseCallView: " + mBaseCallView);
        BaseCallActivity.updateBaseView(mBaseCallView);
        Intent intent = new Intent(mContext, BaseCallActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    public void closeCallingView() {
        if (null != mBaseCallView) {
            mBaseCallView.finish();
        }
        mBaseCallView = null;
        BaseCallActivity.finishActivity();

        mSelfUserModel = null;
        mInviteeList.clear();
        mInviter = new CallingUserModel();
        mMediaType = TUICallDefine.MediaType.Unknown;
        mCallRole = TUICallDefine.Role.None;
        mCallScene = null;

        TUICallingStatusManager.sharedInstance(mContext).clear();

        mFunctionView = null;
        mFloatCallView = null;
        mImageFloatFunction = null;

        if (null != mHomeWatcher) {
            mHomeWatcher.stopWatch();
            mHomeWatcher = null;
        }
        FloatWindowService.stopService(mContext);
    }

    public BaseCallView getBaseCallView() {
        return mBaseCallView;
    }

    /**
     * updateCallStatus
     *
     * @param status Status
     */
    private void updateCallStatus(TUICallDefine.Status status) {
        TUILog.i(TAG, "updateCallStatus: status: " + status);

        if (TUICallDefine.Status.None.equals(status)) {
            closeCallingView();
            return;
        }
        if (!TUICallDefine.Status.Accept.equals(status)) {
            return;
        }

        if (null != mBaseCallView) {
            if (Scene.SINGLE_CALL.equals(mCallScene)) {
                initSingleAcceptCallView();
            } else {
                initGroupAcceptCallView();
            }
        }
        if (null != mFloatCallView) {
            updateFloatView(TUICallingStatusManager.sharedInstance(mContext).getCallStatus());
        }
    }

    /**
     * updateCallType
     *
     * @param type MediaType
     */
    public void updateCallType(TUICallDefine.MediaType type) {
        if (TUICallDefine.MediaType.Unknown.equals(mMediaType) || TUICallDefine.MediaType.Unknown.equals(type)) {
            TUILog.i(TAG, "updateCallType, callType is empty");
            return;
        }
        if (mMediaType.equals(type)) {
            TUILog.i(TAG, "updateCallType, no change, type: " + type);
            return;
        }
        mMediaType = type;

        TUILog.i(TAG, "updateCallType, type: " + type);

        //Video call switch to audio call, need update AudioPlaybackDevice
        TUICommonDefine.AudioPlaybackDevice device = TUICommonDefine.AudioPlaybackDevice.Speakerphone;
        if (TUICallDefine.MediaType.Audio.equals(mMediaType)) {
            device = TUICommonDefine.AudioPlaybackDevice.Earpiece;
        }
        mCallingAction.selectAudioPlaybackDevice(device);

        if (null != mBaseCallView) {
            mBaseCallView.finish();
            mBaseCallView = null;
        }

        if (TUICallDefine.Status.Waiting.equals(TUICallingStatusManager.sharedInstance(mContext).getCallStatus())) {
            initSingleWaitingView();
        } else {
            mBaseCallView = new TUICallingImageView(mContext);
            mFunctionView = new TUICallingAudioFunctionView(mContext);
            mUserView = new TUICallingUserView(mContext);
            if (TUICallDefine.Role.Caller.equals(mCallRole) && !mInviteeList.isEmpty()) {
                mUserView.updateUserInfo(mInviteeList.get(0));
            } else {
                mUserView.updateUserInfo(mInviter);
            }

            mBaseCallView.updateFunctionView(mFunctionView);
            mBaseCallView.updateUserView(mUserView);
            mBaseCallView.updateCallingHint("");

            updateViewColor();
            updateButtonStatus();
            initFloatingWindowBtn();
            BaseCallActivity.updateBaseView(mBaseCallView);
        }

        if (null != mFloatCallView) {
            updateFloatView(TUICallingStatusManager.sharedInstance(mContext).getCallStatus());
        }
    }

    public void userCallingTimeStr(String time) {
        if (null == mBaseCallView) {
            return;
        }
        mMainHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mFloatCallView) {
                    mFloatCallView.updateCallTimeView(time);
                }

                if (null != mBaseCallView) {
                    mBaseCallView.updateCallTimeView(time);
                }
            }
        });
    }

    public void userEnter(CallingUserModel userModel) {
        TUILog.i(TAG, "userEnter, userModel: " + userModel);
        if (null == userModel || TextUtils.isEmpty(userModel.userId)) {
            return;
        }
        userModel.isEnter = true;
        if (!mInviteeList.contains(userModel)) {
            mInviteeList.add(userModel);
        }
        if (null != mBaseCallView) {
            mBaseCallView.userEnter(userModel);
        }
        if (TextUtils.isEmpty(userModel.userName) || TextUtils.isEmpty(userModel.userAvatar)) {
            loadUserInfo(userModel);
        }
    }

    public void userLeave(CallingUserModel userModel) {
        TUILog.i(TAG, "userLeave, userModel: " + userModel);
        if (userModel == null || TextUtils.isEmpty(userModel.userId)) {
            return;
        }
        if (mInviter != null && userModel.userId.equals(mInviter.userId)) {
            mInviter = new CallingUserModel();
        }
        mInviteeList.remove(userModel);
        initOtherInviteeView();

        if (null != mBaseCallView) {
            mBaseCallView.userLeave(userModel);
        }
    }

    public void updateUser(CallingUserModel userModel) {
        if (null == userModel || TextUtils.isEmpty(userModel.userId)) {
            return;
        }

        initSelfModel();
        if (mSelfUserModel != null && userModel.userId.equals(mSelfUserModel.userId)) {
            userModel.isVideoAvailable = mSelfUserModel.isVideoAvailable;
            userModel.isAudioAvailable = mSelfUserModel.isAudioAvailable;
        }

        if (null != mBaseCallView) {
            mBaseCallView.updateUserInfo(userModel);
        }

        if (mFloatCallView != null) {
            CallingUserModel model = findCallingUserModel(mFloatCallView.getCurrentUser());
            if (model != null && userModel.userId.equals(model.userId)) {
                updateFloatView(TUICallingStatusManager.sharedInstance(mContext).getCallStatus());
            }
            return;
        }

        UserLayout layout = mUserLayoutFactory.findUserLayout(userModel.userId);
        if (null != layout) {
            layout.setAudioVolume(userModel.volume, userModel.isAudioAvailable);
        }
    }

    private void openCamera(TUICommonDefine.Camera camera) {
        if (null != mFunctionView) {
            mFunctionView.updateCameraOpenStatus(true);
            mFunctionView.updateFrontCameraStatus(camera);
        }

        mSelfUserModel.isVideoAvailable = true;
    }

    private void closeCamera() {
        if (null != mFunctionView) {
            mFunctionView.updateCameraOpenStatus(false);
        }
        ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_toast_disable_camera));

        mSelfUserModel.isVideoAvailable = false;
    }

    private void switchCamera(TUICommonDefine.Camera camera) {
        if (null != mFunctionView) {
            mFunctionView.updateFrontCameraStatus(camera);
        }
    }

    private void setMuteMic(boolean isMicMute) {
        if (null != mFunctionView) {
            mFunctionView.updateMicMuteStatus(isMicMute);
        }
        UserLayout layout = mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser());
        if (null != layout) {
            layout.muteMic(isMicMute);
        }
        mSelfUserModel.isAudioAvailable = isMicMute;
    }

    private void setHandsFree(boolean isHandsFree) {
        if (null != mFunctionView) {
            mFunctionView.updateHandsFreeStatus(isHandsFree);
        }
    }

    public void enableFloatWindow(boolean enable) {
        mEnableFloatView = enable;
    }

    private void initSingleWaitingView() {
        initSelfModel();
        if (TUICallDefine.MediaType.Video.equals(mMediaType)) {
            initSingleVideoWaitingView();
        } else {
            initSingleAudioWaitingView();
        }
        TUICommonDefine.AudioPlaybackDevice device = TUICallDefine.MediaType.Audio.equals(mMediaType)
                ? TUICommonDefine.AudioPlaybackDevice.Earpiece : TUICommonDefine.AudioPlaybackDevice.Speakerphone;
        mCallingAction.selectAudioPlaybackDevice(device);
    }

    private void initSingleAudioWaitingView() {
        TUILog.i(TAG, "initSingleAudioWaitingView");
        mBaseCallView = new TUICallingImageView(mContext);
        String hint;

        if (TUICallDefine.Role.Caller.equals(mCallRole)) {
            hint = mContext.getString(R.string.tuicalling_waiting_accept);
            mFunctionView = new TUICallingAudioFunctionView(mContext);
        } else {
            hint = mContext.getString(R.string.tuicalling_invite_audio_call);
            mFunctionView = new TUICallingWaitFunctionView(mContext);
        }

        mUserView = new TUICallingUserView(mContext);
        if (TUICallDefine.Role.Caller.equals(mCallRole) && !mInviteeList.isEmpty()) {
            mUserView.updateUserInfo(mInviteeList.get(0));
        } else {
            mUserView.updateUserInfo(mInviter);
        }
        mBaseCallView.updateUserView(mUserView);

        mBaseCallView.updateCallingHint(hint);
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        updateButtonStatus();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initSingleVideoWaitingView() {
        TUILog.i(TAG, "initSingleVideoWaitingView");
        mUserLayoutFactory.allocUserLayout(mSelfUserModel);
        mBaseCallView = new TUICallingSingleView(mContext, mUserLayoutFactory);
        String hint = "";
        if (TUICallDefine.Role.Caller.equals(mCallRole)) {
            hint = mContext.getString(R.string.tuicalling_waiting_accept);
            mFunctionView = new TUICallingVideoInviteFunctionView(mContext);
        } else {
            hint = mContext.getString(R.string.tuicalling_invite_audio_call);
            mFunctionView = new TUICallingWaitFunctionView(mContext);
        }

        mUserView = new TUICallingSingleVideoUserView(mContext, hint);
        mBaseCallView.updateUserView(mUserView);

        mBaseCallView.updateSwitchAudioView(new TUICallingSwitchAudioView(mContext));

        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        updateButtonStatus();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initGroupWaitingView() {
        TUILog.i(TAG, "initGroupWaitingView");
        initSelfModel();
        String hint;
        if (TUICallDefine.Role.Caller.equals(mCallRole)) {
            mUserLayoutFactory.allocUserLayout(mSelfUserModel);
            for (CallingUserModel model : mInviteeList) {
                if (null != model && !TextUtils.isEmpty(model.userId)) {
                    mUserLayoutFactory.allocUserLayout(model);
                }
            }
            mBaseCallView = new TUICallingGroupView(mContext, mUserLayoutFactory, mMediaType);
            hint = mContext.getString(R.string.tuicalling_waiting_accept);
            mFunctionView = (TUICallDefine.MediaType.Video.equals(mMediaType))
                    ? new TUICallingVideoFunctionView(mContext) :
                    new TUICallingAudioFunctionView(mContext);
            initInviteUserFunction();
        } else {
            mBaseCallView = new TUICallingImageView(mContext);
            mUserView = new TUICallingUserView(mContext);
            mFunctionView = new TUICallingWaitFunctionView(mContext);
            hint = TUICallDefine.MediaType.Audio.equals(mMediaType)
                    ? mContext.getString(R.string.tuicalling_invite_audio_call) :
                    mContext.getString(R.string.tuicalling_invite_video_call);

            mBaseCallView.updateUserView(mUserView);
            mBaseCallView.addOtherUserView(initOtherInviteeView());
        }
        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));

        mBaseCallView.updateCallingHint(hint);
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        updateButtonStatus();
        initFloatingWindowBtn();

        TUICommonDefine.AudioPlaybackDevice device = TUICallDefine.MediaType.Audio.equals(mMediaType)
                ? TUICommonDefine.AudioPlaybackDevice.Earpiece : TUICommonDefine.AudioPlaybackDevice.Speakerphone;
        mCallingAction.selectAudioPlaybackDevice(device);
    }

    private void initSingleAcceptCallView() {
        TUICommonDefine.AudioPlaybackDevice device =
                TUICallingStatusManager.sharedInstance(mContext).getAudioPlaybackDevice();
        TUILog.i(TAG, "initSingleAcceptCallView, mCallType: " + mMediaType + " ,device: " + device);
        mCallingAction.selectAudioPlaybackDevice(device);
        initMicMute(TUICallingStatusManager.sharedInstance(mContext).isMicMute());

        if (TUICallDefine.MediaType.Audio.equals(mMediaType)) {
            initSingleAudioAcceptCallView();
        } else {
            initSingleVideoAcceptCallView();
        }
    }

    private void initSingleAudioAcceptCallView() {
        TUILog.i(TAG, "initSingleAudioAcceptCallView, mBaseCallView: " + mBaseCallView);
        if (null == mBaseCallView) {
            mBaseCallView = new TUICallingImageView(mContext);
        }
        mBaseCallView.updateCallingHint("");
        if (TUICallDefine.Role.Called.equals(mCallRole)) {
            mFunctionView = new TUICallingAudioFunctionView(mContext);
            mBaseCallView.updateFunctionView(mFunctionView);
        }
        updateViewColor();
        updateButtonStatus();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initSingleVideoAcceptCallView() {
        TUILog.i(TAG, "initSingleVideoAcceptCallView, mBaseCallView: " + mBaseCallView);
        if (null == mBaseCallView) {
            mBaseCallView = new TUICallingSingleView(mContext, mUserLayoutFactory);
            mBaseCallView.updateSwitchAudioView(new TUICallingSwitchAudioView(mContext));
        }
        mFunctionView = new TUICallingVideoFunctionView(mContext);
        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));

        mBaseCallView.updateUserView(null);
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        updateButtonStatus();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initGroupAcceptCallView() {
        TUICommonDefine.AudioPlaybackDevice device =
                TUICallingStatusManager.sharedInstance(mContext).getAudioPlaybackDevice();
        TUILog.i(TAG, "initGroupAcceptCallView, type: " + mMediaType + " ,mInviteeList: " + mInviteeList);
        mCallingAction.selectAudioPlaybackDevice(device);
        initMicMute(TUICallingStatusManager.sharedInstance(mContext).isMicMute());

        if (TUICallDefine.Role.Caller.equals(mCallRole)) {
            if (null == mBaseCallView) {
                mBaseCallView = new TUICallingGroupView(mContext, mUserLayoutFactory, mMediaType);
            }
            if (TUICallDefine.MediaType.Video.equals(mMediaType)) {
                mFunctionView = new TUICallingVideoFunctionView(mContext);
                mBaseCallView.updateFunctionView(mFunctionView);
            }
        } else {
            if (null != mBaseCallView) {
                mBaseCallView.finish();
            }

            mUserLayoutFactory.allocUserLayout(mInviter);
            for (CallingUserModel model : mInviteeList) {
                if (null != model && !TextUtils.isEmpty(model.userId)) {
                    mUserLayoutFactory.allocUserLayout(model);
                }
            }
            mBaseCallView = new TUICallingGroupView(mContext, mUserLayoutFactory, mMediaType);
            mFunctionView = (TUICallDefine.MediaType.Video.equals(mMediaType))
                    ? new TUICallingVideoFunctionView(mContext)
                    : new TUICallingAudioFunctionView(mContext);
            mBaseCallView.updateFunctionView(mFunctionView);
        }
        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));
        mBaseCallView.updateCallingHint("");

        updateViewColor();
        updateButtonStatus();
        initInviteUserFunction();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private View initOtherInviteeView() {
        if (mOtherUserLayout == null) {
            mOtherUserLayout = new LinearLayout(mContext);
        } else {
            mOtherUserLayout.removeAllViews();
        }

        List<CallingUserModel> otherInviteeList = mInviteeList;
        TUILog.i(TAG, "initOtherInviteeView, otherInviteeList: " + otherInviteeList);

        int squareWidth = mContext.getResources().getDimensionPixelOffset(R.dimen.tuicalling_small_image_size);
        int leftMargin = mContext.getResources().getDimensionPixelOffset(R.dimen.tuicalling_small_image_left_margin);

        for (int index = 0; index < otherInviteeList.size(); index++) {
            final CallingUserModel model = otherInviteeList.get(index);
            final ImageView imageView = new ImageView(mContext);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            ImageLoader.loadImage(mContext, imageView, model.userAvatar, R.drawable.tuicalling_ic_avatar);
            mOtherUserLayout.addView(imageView);
        }
        return mOtherUserLayout;
    }

    private void updateViewColor() {
        int backgroundColor = TUICallDefine.MediaType.Video.equals(mMediaType)
                ? mContext.getResources().getColor(R.color.tuicalling_color_video_background)
                : mContext.getResources().getColor(R.color.tuicalling_color_audio_background);

        int textColor = TUICallDefine.MediaType.Video.equals(mMediaType)
                ? mContext.getResources().getColor(R.color.tuicalling_color_white)
                : mContext.getResources().getColor(R.color.tuicalling_color_black);

        if (null != mBaseCallView) {
            mBaseCallView.updateBackgroundColor(backgroundColor);
            mBaseCallView.updateTextColor(textColor);
        }

        if (null != mUserView) {
            mUserView.updateTextColor(textColor);
        }
        if (null != mFunctionView) {
            mFunctionView.updateTextColor(textColor);
        }
    }

    private void updateButtonStatus() {
        if (null != mFunctionView) {
            mFunctionView.updateFrontCameraStatus(TUICallingStatusManager.sharedInstance(mContext).getFrontCamera());
            mFunctionView.updateCameraOpenStatus(TUICallingStatusManager.sharedInstance(mContext).isCameraOpen());
            mFunctionView.updateMicMuteStatus(TUICallingStatusManager.sharedInstance(mContext).isMicMute());
            boolean isHandsFree = TUICallingStatusManager.sharedInstance(mContext).getAudioPlaybackDevice()
                    .equals(TUICommonDefine.AudioPlaybackDevice.Speakerphone);
            mFunctionView.updateHandsFreeStatus(isHandsFree);
        }
    }

    private void initMicMute(boolean isMicMute) {
        if (isMicMute) {
            mCallingAction.closeMicrophone();
        } else {
            mCallingAction.openMicrophone(null);
        }
    }

    private void initSelfModel() {
        if (mSelfUserModel != null) {
            return;
        }
        mSelfUserModel = new CallingUserModel();
        mSelfUserModel.userId = TUILogin.getLoginUser();
        mSelfUserModel.userAvatar = TUILogin.getFaceUrl();
        mSelfUserModel.userName = TUILogin.getNickName();
        TUILog.i(TAG, "initSelfModel, mSelfUserModel: " + mSelfUserModel);
    }

    private void reloadUserModel(CallingUserModel model) {
        if (model == null || TextUtils.isEmpty(model.userId)) {
            return;
        }
        UserLayout layout = mUserLayoutFactory.findUserLayout(model.userId);
        TUILog.i(TAG, "reloadUserModel, model: " + model + " , layout: " + layout);
        if (null != layout) {
            layout.setUserName(model.userName);
            ImageLoader.loadImage(mContext, layout.getAvatarImage(), model.userAvatar, R.drawable.tuicalling_ic_avatar);
        }
    }

    private void initFloatingWindowBtn() {
        TUILog.i(TAG, "initFloatingWindowBtn, mEnableFloatView: " + mEnableFloatView);

        if (null != mBaseCallView && mEnableFloatView) {
            mImageFloatFunction = new ImageView(mContext);
            int resId = TUICallDefine.MediaType.Video.equals(mMediaType)
                    ? R.drawable.tuicalling_ic_move_back_white : R.drawable.tuicalling_ic_move_back_black;
            mImageFloatFunction.setBackgroundResource(resId);
            mImageFloatFunction.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    startFloatService();
                }
            });
        }

        if (mImageFloatFunction != null && mImageFloatFunction.getParent() != null) {
            ((ViewGroup) mImageFloatFunction.getParent()).removeView(mImageFloatFunction);
        }
        mBaseCallView.enableFloatView(mImageFloatFunction);
    }

    private void startFloatService() {
        if (!mEnableFloatView) {
            TUILog.w(TAG, "startFloatService, FloatView is unsupported");
            return;
        }

        if (null != mFloatCallView) {
            return;
        }
        if (PermissionUtils.hasPermission(mContext)) {
            mFloatCallView = createFloatView();
            updateFloatView(TUICallingStatusManager.sharedInstance(mContext).getCallStatus());
            FloatWindowService.startFloatService(mContext, mFloatCallView);
            BaseCallActivity.finishActivity();
        } else {
            TUILog.i(TAG, "please open Display over other apps permission");
            PermissionRequest.requestFloatPermission(mContext);
        }
    }

    private FloatCallView createFloatView() {
        FloatCallView floatView = new FloatCallView(mContext, mUserLayoutFactory);
        floatView.setOnClickListener(new FloatCallView.OnClickListener() {
            @Override
            public void onClick() {
                FloatWindowService.stopService(mContext);
                mFloatCallView = null;
                if (TUICallDefine.MediaType.Video.equals(mMediaType) && Scene.SINGLE_CALL.equals(mCallScene)) {
                    CallingUserModel model = (TUICallDefine.Role.Called.equals(mCallRole))
                            ? mInviter : mInviteeList.get(0);
                    if (null != mBaseCallView) {
                        mImageFloatFunction = null;
                        if (TUICallDefine.Status.Accept
                                .equals(TUICallingStatusManager.sharedInstance(mContext).getCallStatus())) {
                            resetVideoCloudView(mSelfUserModel);
                            resetVideoCloudView(model);
                        } else {
                            resetVideoCloudView(mSelfUserModel);
                        }
                    }
                }
                showCallingView();
            }
        });
        return floatView;
    }

    private void resetVideoCloudView(CallingUserModel model) {
        UserLayout userLayout = mUserLayoutFactory.findUserLayout(model.userId);
        TUILog.i(TAG, "resetVideoCloudView, model: " + model + " , userLayout: " + userLayout);
        if (null == userLayout) {
            userLayout = mUserLayoutFactory.allocUserLayout(model);
        }

        TUIVideoView videoView = userLayout.getVideoView();
        if (videoView != null) {
            if (null != videoView.getParent()) {
                ((ViewGroup) videoView.getParent()).removeView(videoView);
            }
            userLayout.addVideoView(videoView);
        }
    }

    private void updateFloatView(TUICallDefine.Status status) {
        if (null == mFloatCallView) {
            TUILog.i(TAG, "updateFloatView, floatView is empty");
            return;
        }

        TUILog.i(TAG, "updateFloatView, status: " + status + " ,mCallType: " + mMediaType);

        if (TUICallDefine.MediaType.Video.equals(mMediaType) && Scene.SINGLE_CALL.equals(mCallScene)) {
            mFloatCallView.enableCallingHint(false);
            String userId;
            if (TUICallDefine.Status.Waiting.equals(status)) {
                userId = TUILogin.getLoginUser();
            } else {
                userId = (TUICallDefine.Role.Caller.equals(mCallRole)) ? mInviteeList.get(0).userId : mInviter.userId;
            }
            mFloatCallView.updateView(true, userId);
        } else {
            mFloatCallView.enableCallingHint(TUICallDefine.Status.Waiting.equals(status));
            mFloatCallView.updateView(false, null);
        }
    }

    private void initHomeWatcher() {
        if (null == mHomeWatcher) {
            mHomeWatcher = new HomeWatcher(mContext);
        }
        mHomeWatcher.setOnHomePressedListener(new HomeWatcher.OnHomePressedListener() {
            @Override
            public void onHomePressed() {
                if (PermissionUtils.hasPermission(mContext)) {
                    startFloatService();
                }
            }

            @Override
            public void onRecentAppsPressed() {
                if (PermissionUtils.hasPermission(mContext)) {
                    startFloatService();
                }
            }
        });
        mHomeWatcher.startWatch();
    }

    private CallingUserModel findCallingUserModel(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        for (UserLayoutEntity entity : mUserLayoutFactory.mLayoutEntityList) {
            if (entity != null && userId.equals(entity.userId)) {
                return entity.userModel;
            }
        }
        return null;
    }

    public void setGroupId(String groupId) {
        mGroupId = groupId;
    }

    public void enableInviteUser(boolean enable) {
        mEnableInviteUser = enable;
    }

    private void initInviteUserFunction() {
        TUILog.i(TAG, "initInviteUserFunction, mEnableInviteUser: " + mEnableInviteUser);

        if (mEnableInviteUser && mBaseCallView != null) {
            Button inviteUserBtn = new Button(mContext);
            int resId = TUICallDefine.MediaType.Video.equals(mMediaType)
                    ? R.drawable.tuicalling_ic_add_user_white : R.drawable.tuicalling_ic_add_user_black;
            inviteUserBtn.setBackgroundResource(resId);
            inviteUserBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    if (TextUtils.isEmpty(mGroupId)) {
                        ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_groupid_is_empty));
                        TUILog.w(TAG, "initInviteUserFunction, groupId is empty");
                        return;
                    }

                    TUICallDefine.Status status = TUICallingStatusManager.sharedInstance(mContext).getCallStatus();
                    if (TUICallDefine.Role.Called.equals(mCallRole) && !TUICallDefine.Status.Accept.equals(status)) {
                        ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_status_is_not_accept));
                        TUILog.w(TAG, "initInviteUserFunction, status is not accept: " + status);
                        return;
                    }

                    ArrayList<String> list = new ArrayList<>();
                    list.add(mInviter.userId);
                    for (CallingUserModel model : mInviteeList) {
                        if (model != null && !TextUtils.isEmpty(model.userId) && !list.contains(model.userId)) {
                            list.add(model.userId);
                        }
                    }
                    if (!list.contains(TUILogin.getLoginUser())) {
                        list.add(TUILogin.getLoginUser());
                    }

                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TUIGroup.GROUP_ID, mGroupId);
                    bundle.putString(TUIConstants.TUIGroup.USER_DATA, Constants.TUICALLKIT);
                    bundle.putStringArrayList(TUIConstants.TUIGroup.SELECTED_LIST, list);
                    TUICore.startActivity("GroupMemberActivity", bundle);
                }
            });
            mBaseCallView.enableAddUserView(inviteUserBtn);
        }
    }

    private void inviteUsersToGroupCall(List<String> userIdList) {
        if (userIdList == null || userIdList.isEmpty()) {
            TUILog.e(TAG, "inviteUsersToGroupCall, userIdList is empty: " + userIdList);
            return;
        }

        TUILog.i(TAG, "inviteUsersToGroupCall, userIdList: " + userIdList);

        mCallingAction.inviteUser(userIdList, new TUICommonDefine.ValueCallback() {
            @Override
            public void onSuccess(Object data) {
                if (!(data instanceof List)) {
                    TUILog.e(TAG, "inviteUsersToGroupCall failed, data is not List, value is: " + data);
                    return;
                }

                List<String> list = (List<String>) data;

                TUILog.i(TAG, "inviteUsersToGroupCall success, list:" + list);
                for (String userId : list) {
                    if (!TextUtils.isEmpty(userId)) {
                        CallingUserModel userModel = new CallingUserModel();
                        userModel.userId = userId;
                        addUser(userModel);
                    }
                }
            }

            @Override
            public void onError(int errCode, String errMsg) {
                TUILog.e(TAG, "inviteUser failed, errCode: " + errCode + " , errMsg: " + errMsg);
            }
        });
    }

    private void addUser(CallingUserModel userModel) {
        if (!mInviteeList.contains(userModel)) {
            mInviteeList.add(userModel);
        }
        if (null != mBaseCallView) {
            mBaseCallView.userAdd(userModel);
        }
        loadUserInfo(userModel);
    }

    private void loadUserInfo(CallingUserModel model) {
        UserLayout userLayout = mUserLayoutFactory.allocUserLayout(model);
        if (userLayout == null) {
            TUILog.w(TAG, "loadUserInfo, userLayout is empty");
            return;
        }
        mUserInfoUtils.getUserInfo(model.userId, new UserInfoUtils.UserCallback() {
            @Override
            public void onSuccess(List<CallingUserModel> list) {
                TUILog.i(TAG, "loadUserInfo success, list: " + list);
                if (list != null && !list.isEmpty()) {
                    CallingUserModel tempModel = list.get(0);
                    if (tempModel != null && model.userId.equals(tempModel.userId)) {
                        model.userAvatar = tempModel.userAvatar;
                        model.userName = tempModel.userName;
                    }
                }
                userLayout.setUserName(model.userName);
                ImageLoader.loadImage(mContext, userLayout.getAvatarImage(), model.userAvatar,
                        R.drawable.tuicalling_ic_avatar);
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
            }
        });
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (param == null) {
            TUILog.w(TAG, "onNotifyEvent: param is empty");
            return;
        }

        if (Constants.EVENT_TUICALLING_CHANGED.equals(key)) {
            switch (subKey) {
                case Constants.EVENT_SUB_CAMERA_OPEN:
                    if ((boolean) param.get(Constants.OPEN_CAMERA)) {
                        openCamera((TUICommonDefine.Camera) param.get(Constants.SWITCH_CAMERA));
                    } else {
                        closeCamera();
                    }
                    break;
                case Constants.EVENT_SUB_CAMERA_FRONT:
                    switchCamera((TUICommonDefine.Camera) param.get(Constants.SWITCH_CAMERA));
                    break;
                case Constants.EVENT_SUB_MIC_STATUS_CHANGED:
                    setMuteMic((Boolean) param.get(Constants.MUTE_MIC));
                    break;
                case Constants.EVENT_SUB_AUDIOPLAYDEVICE_CHANGED:
                    TUICommonDefine.AudioPlaybackDevice device =
                            (TUICommonDefine.AudioPlaybackDevice) param.get(Constants.HANDS_FREE);
                    setHandsFree(TUICommonDefine.AudioPlaybackDevice.Speakerphone.equals(device));
                    break;
                case Constants.EVENT_SUB_CALL_STATUS_CHANGED:
                    updateCallStatus((TUICallDefine.Status) param.get(Constants.CALL_STATUS));
                    break;
                default:
                    break;
            }
        } else if (TUIConstants.TUIGroup.EVENT_GROUP.equals(key)) {
            if (TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_MEMBER_SELECTED.equals(subKey)) {
                String userData = (String) param.get(TUIConstants.TUIGroup.USER_DATA);
                if (!Constants.TUICALLKIT.equals(userData)) {
                    return;
                }
                List<String> list = (List<String>) param.get(TUIConstants.TUIGroup.LIST);
                inviteUsersToGroupCall(list);
            }
        }
    }
}
