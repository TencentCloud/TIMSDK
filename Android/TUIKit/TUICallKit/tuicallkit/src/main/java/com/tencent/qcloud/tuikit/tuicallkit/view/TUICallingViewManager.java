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
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.TUIVideoView;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.MediaType;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.Role;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.Scene;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.Status;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.BaseCallActivity;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.Constants;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingAction;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayoutEntity;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.inviteuser.SelectGroupMemberActivity;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest;
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils;
import com.tencent.qcloud.tuikit.tuicallkit.view.common.RoundCornerImageView;
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

    private CallingUserModel       mSelfUserModel;
    private List<CallingUserModel> mInviteeList     = new ArrayList<>();
    private CallingUserModel       mInviter;
    private boolean                mEnableFloatView = false;

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
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_MIC_STATUS_CHANGED, this);

        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CALL_STATUS_CHANGED, this);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_CALL_TYPE_CHANGED, this);
        TUICore.registerEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_GROUP_MEMBER_SELECTED, this);
    }

    public void createCallingView(List<CallingUserModel> inviteeList, CallingUserModel inviter) {
        mInviter = inviter;
        mInviteeList = inviteeList;
        initHomeWatcher();
        TUILog.i(TAG, "createCallingView mInviter: " + mInviter + " ,mInviteeList: " + mInviteeList);

        if (Scene.SINGLE_CALL.equals(TUICallingStatusManager.sharedInstance(mContext).getCallScene())) {
            initSingleWaitingView();
        } else {
            initGroupWaitingView();
        }
    }

    //JoinInGroupCall
    public void createGroupCallingAcceptView() {
        initSelfModel();
        initHomeWatcher();
        mUserLayoutFactory.allocUserLayout(mSelfUserModel);
        initGroupAcceptCallView();
    }

    public void updateCallingUserView(List<CallingUserModel> inviteeList, CallingUserModel inviter) {
        mInviter = inviter;
        mInviteeList = inviteeList;

        CallingUserModel userModel;
        if (TUICallDefine.Role.Caller.equals(TUICallingStatusManager.sharedInstance(mContext).getCallRole())) {
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
        TUILog.i(TAG, "showCallingView: mBaseCallView: " + mBaseCallView);
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
        SelectGroupMemberActivity.finishActivity();

        mSelfUserModel = null;
        mInviteeList.clear();
        mInviter = new CallingUserModel();

        TUICallingStatusManager.sharedInstance(mContext).clear();

        mFunctionView = null;
        mFloatCallView = null;
        mUserView = null;
        mImageFloatFunction = null;
        mOtherUserLayout = null;

        if (null != mHomeWatcher) {
            mHomeWatcher.stopWatch();
            mHomeWatcher = null;
        }
        FloatWindowService.stopService(mContext);
    }

    private void updateCallStatus(TUICallDefine.Status status) {
        if (TUICallDefine.Status.None.equals(status)) {
            closeCallingView();
            return;
        }
        if (!TUICallDefine.Status.Accept.equals(status)) {
            return;
        }

        if (null != mBaseCallView) {
            if (Scene.SINGLE_CALL.equals(TUICallingStatusManager.sharedInstance(mContext).getCallScene())) {
                initSingleAcceptCallView();
            } else {
                initGroupAcceptCallView();
            }
        }
        if (null != mFloatCallView) {
            updateFloatView(TUICallingStatusManager.sharedInstance(mContext).getCallStatus());
        }
    }

    private void updateCallType(TUICallDefine.MediaType type) {
        if (TUICallDefine.MediaType.Unknown.equals(type)) {
            return;
        }

        if (mBaseCallView == null) {
            return;
        }
        mBaseCallView.finish();
        mBaseCallView = null;

        if (TUICallDefine.Status.Waiting.equals(TUICallingStatusManager.sharedInstance(mContext).getCallStatus())) {
            initSingleWaitingView();
        } else {
            initAudioPlayDevice();
            initSingleAcceptCallView();
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

    public void enableFloatWindow(boolean enable) {
        mEnableFloatView = enable;
    }

    private void initSingleWaitingView() {
        initSelfModel();
        initAudioPlayDevice();
        if (TUICallDefine.MediaType.Video.equals(TUICallingStatusManager.sharedInstance(mContext).getMediaType())) {
            initSingleVideoWaitingView();
        } else {
            initSingleAudioWaitingView();
        }
    }

    private void initSingleAudioWaitingView() {
        mBaseCallView = new TUICallingImageView(mContext);
        String hint;
        TUICallDefine.Role callRole = TUICallingStatusManager.sharedInstance(mContext).getCallRole();

        if (TUICallDefine.Role.Caller.equals(callRole)) {
            hint = mContext.getString(R.string.tuicalling_waiting_accept);
            mFunctionView = new TUICallingAudioFunctionView(mContext);
        } else {
            hint = mContext.getString(R.string.tuicalling_invite_audio_call);
            mFunctionView = new TUICallingWaitFunctionView(mContext);
        }

        mUserView = new TUICallingUserView(mContext);
        if (TUICallDefine.Role.Caller.equals(callRole) && !mInviteeList.isEmpty()) {
            mUserView.updateUserInfo(mInviteeList.get(0));
        } else {
            mUserView.updateUserInfo(mInviter);
        }
        mBaseCallView.updateUserView(mUserView);

        mBaseCallView.updateCallingHint(hint);
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initSingleVideoWaitingView() {
        mUserLayoutFactory.allocUserLayout(mSelfUserModel);
        mBaseCallView = new TUICallingSingleView(mContext, mUserLayoutFactory);
        String hint = "";
        if (TUICallDefine.Role.Caller.equals(TUICallingStatusManager.sharedInstance(mContext).getCallRole())) {
            hint = mContext.getString(R.string.tuicalling_waiting_accept);
            mFunctionView = new TUICallingVideoInviteFunctionView(mContext);
        } else {
            hint = mContext.getString(R.string.tuicalling_invite_video_call);
            mFunctionView = new TUICallingWaitFunctionView(mContext);
        }

        mUserView = new TUICallingSingleVideoUserView(mContext, hint);
        mBaseCallView.updateUserView(mUserView);

        mBaseCallView.updateSwitchAudioView(new TUICallingSwitchAudioView(mContext));

        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initGroupWaitingView() {
        initSelfModel();
        initAudioPlayDevice();

        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        String hint;
        if (TUICallDefine.Role.Caller.equals(TUICallingStatusManager.sharedInstance(mContext).getCallRole())) {
            mUserLayoutFactory.allocUserLayout(mSelfUserModel);
            for (CallingUserModel model : mInviteeList) {
                if (null != model && !TextUtils.isEmpty(model.userId)) {
                    mUserLayoutFactory.allocUserLayout(model);
                }
            }
            mBaseCallView = new TUICallingGroupView(mContext, mUserLayoutFactory);
            hint = mContext.getString(R.string.tuicalling_waiting_accept);
            mFunctionView = (TUICallDefine.MediaType.Video.equals(mediaType))
                    ? new TUICallingVideoFunctionView(mContext) :
                    new TUICallingAudioFunctionView(mContext);
            initInviteUserFunction();
        } else {
            mBaseCallView = new TUICallingImageView(mContext);
            mUserView = new TUICallingUserView(mContext);
            mFunctionView = new TUICallingWaitFunctionView(mContext);
            hint = TUICallDefine.MediaType.Audio.equals(mediaType)
                    ? mContext.getString(R.string.tuicalling_invite_audio_call) :
                    mContext.getString(R.string.tuicalling_invite_video_call);

            mBaseCallView.updateUserView(mUserView);
            mBaseCallView.addOtherUserView(initOtherInviteeView());
        }
        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));

        mBaseCallView.updateCallingHint(hint);
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        updateFunctionStatus();
        initFloatingWindowBtn();
    }

    private void initSingleAcceptCallView() {
        if (TUICallDefine.MediaType.Audio.equals(TUICallingStatusManager.sharedInstance(mContext).getMediaType())) {
            initSingleAudioAcceptCallView();
        } else {
            initSingleVideoAcceptCallView();
        }
    }

    private void initSingleAudioAcceptCallView() {
        if (mBaseCallView != null) {
            mBaseCallView.finish();
            mBaseCallView = null;
        }
        mBaseCallView = new TUICallingImageView(mContext);
        mFunctionView = new TUICallingAudioFunctionView(mContext);
        mUserView = new TUICallingUserView(mContext);
        TUICallDefine.Role role = TUICallingStatusManager.sharedInstance(mContext).getCallRole();
        if (TUICallDefine.Role.Caller.equals(role) && !mInviteeList.isEmpty()) {
            mUserView.updateUserInfo(mInviteeList.get(0));
        } else {
            mUserView.updateUserInfo(mInviter);
        }

        mBaseCallView.updateFunctionView(mFunctionView);
        mBaseCallView.updateUserView(mUserView);
        mBaseCallView.updateCallingHint("");

        updateViewColor();
        updateFunctionStatus();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initSingleVideoAcceptCallView() {
        if (null == mBaseCallView) {
            mBaseCallView = new TUICallingSingleView(mContext, mUserLayoutFactory);
            mBaseCallView.updateSwitchAudioView(new TUICallingSwitchAudioView(mContext));
        }
        mFunctionView = new TUICallingVideoFunctionView(mContext);
        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));

        mBaseCallView.updateUserView(null);
        mBaseCallView.updateFunctionView(mFunctionView);

        updateViewColor();
        updateFunctionStatus();
        initFloatingWindowBtn();
        BaseCallActivity.updateBaseView(mBaseCallView);
    }

    private void initGroupAcceptCallView() {
        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();

        if (TUICallDefine.Role.Caller.equals(TUICallingStatusManager.sharedInstance(mContext).getCallRole())) {
            if (null == mBaseCallView) {
                mBaseCallView = new TUICallingGroupView(mContext, mUserLayoutFactory);
            }
            if (TUICallDefine.MediaType.Video.equals(mediaType)) {
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
            mBaseCallView = new TUICallingGroupView(mContext, mUserLayoutFactory);
            mFunctionView = (TUICallDefine.MediaType.Video.equals(mediaType))
                    ? new TUICallingVideoFunctionView(mContext)
                    : new TUICallingAudioFunctionView(mContext);
            mBaseCallView.updateFunctionView(mFunctionView);
        }
        mFunctionView.setLocalUserLayout(mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser()));
        mBaseCallView.updateCallingHint("");

        updateViewColor();
        updateFunctionStatus();
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
        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        int backgroundColor = TUICallDefine.MediaType.Video.equals(mediaType)
                ? mContext.getResources().getColor(R.color.tuicalling_color_video_background)
                : mContext.getResources().getColor(R.color.tuicalling_color_audio_background);

        int textColor = TUICallDefine.MediaType.Video.equals(mediaType)
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

    private void updateFunctionStatus() {
        TUICallingStatusManager statusManager = TUICallingStatusManager.sharedInstance(mContext);
        statusManager.updateCameraOpenStatus(statusManager.isCameraOpen(), statusManager.getFrontCamera());
        mCallingAction.selectAudioPlaybackDevice(statusManager.getAudioPlaybackDevice());
        if (statusManager.isMicMute()) {
            mCallingAction.closeMicrophone();
        } else {
            mCallingAction.openMicrophone(null);
        }
    }

    private void initAudioPlayDevice() {
        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        TUICommonDefine.AudioPlaybackDevice device = TUICallDefine.MediaType.Audio.equals(mediaType)
                ? TUICommonDefine.AudioPlaybackDevice.Earpiece : TUICommonDefine.AudioPlaybackDevice.Speakerphone;
        TUICallingStatusManager.sharedInstance(mContext).updateAudioPlaybackDevice(device);
    }

    private void initSelfModel() {
        if (mSelfUserModel != null) {
            return;
        }
        mSelfUserModel = new CallingUserModel();
        mSelfUserModel.userId = TUILogin.getLoginUser();
        mSelfUserModel.userAvatar = TUILogin.getFaceUrl();
        mSelfUserModel.userName = TUILogin.getNickName();
    }

    private void reloadUserModel(CallingUserModel model) {
        if (model == null || TextUtils.isEmpty(model.userId)) {
            return;
        }
        UserLayout layout = mUserLayoutFactory.findUserLayout(model.userId);
        if (null != layout) {
            if (Scene.GROUP_CALL.equals(TUICallingStatusManager.sharedInstance(mContext).getCallScene())) {
                layout.setUserName(model.userName);
            }
            ImageLoader.loadImage(mContext, layout.getAvatarImage(), model.userAvatar, R.drawable.tuicalling_ic_avatar);
        }
    }

    private void initFloatingWindowBtn() {
        if (mBaseCallView == null) {
            return;
        }

        if (mEnableFloatView) {
            mImageFloatFunction = new ImageView(mContext);
            TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
            int resId = TUICallDefine.MediaType.Video.equals(mediaType)
                    ? R.drawable.tuicalling_ic_move_back_white : R.drawable.tuicalling_ic_move_back_black;
            mImageFloatFunction.setBackgroundResource(resId);
            ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT);
            mImageFloatFunction.setLayoutParams(lp);
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
                mImageFloatFunction = null;

                MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
                Scene callScene = TUICallingStatusManager.sharedInstance(mContext).getCallScene();
                if (MediaType.Video.equals(mediaType) && Scene.SINGLE_CALL.equals(callScene)) {

                    Role callRole = TUICallingStatusManager.sharedInstance(mContext).getCallRole();
                    CallingUserModel model = (Role.Called.equals(callRole)) ? mInviter : mInviteeList.get(0);
                    Status status = TUICallingStatusManager.sharedInstance(mContext).getCallStatus();

                    if (Status.Accept.equals(status)) {
                        resetVideoCloudView(mSelfUserModel);
                        resetVideoCloudView(model);
                    } else {
                        resetVideoCloudView(mSelfUserModel);
                    }
                }
                showCallingView();
            }
        });
        return floatView;
    }

    private void resetVideoCloudView(CallingUserModel model) {
        UserLayout userLayout = mUserLayoutFactory.findUserLayout(model.userId);
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
            return;
        }
        TUICallDefine.MediaType type = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        Scene scene = TUICallingStatusManager.sharedInstance(mContext).getCallScene();

        if (TUICallDefine.MediaType.Video.equals(type) && Scene.SINGLE_CALL.equals(scene)) {
            mFloatCallView.enableCallingHint(false);
            String userId;
            if (TUICallDefine.Status.Waiting.equals(status)) {
                userId = TUILogin.getLoginUser();
            } else {
                TUICallDefine.Role callRole = TUICallingStatusManager.sharedInstance(mContext).getCallRole();
                userId = (TUICallDefine.Role.Caller.equals(callRole)) ? mInviteeList.get(0).userId : mInviter.userId;
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

    private void initInviteUserFunction() {
        if (mBaseCallView == null) {
            return;
        }
        Button inviteUserBtn = new Button(mContext);
        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        int resId = TUICallDefine.MediaType.Video.equals(mediaType)
                ? R.drawable.tuicalling_ic_add_user_white : R.drawable.tuicalling_ic_add_user_black;
        inviteUserBtn.setBackgroundResource(resId);
        inviteUserBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String groupId = TUICallingStatusManager.sharedInstance(mContext).getGroupId();
                if (TextUtils.isEmpty(groupId)) {
                    ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_groupid_is_empty));
                    return;
                }

                TUICallDefine.Status status = TUICallingStatusManager.sharedInstance(mContext).getCallStatus();
                TUICallDefine.Role role = TUICallingStatusManager.sharedInstance(mContext).getCallRole();
                if (TUICallDefine.Role.Called.equals(role) && !TUICallDefine.Status.Accept.equals(status)) {
                    ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_status_is_not_accept));
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

                TUILog.i(TAG, "initInviteUserFunction, groupId: " + groupId + " ,list: " + list);

                Bundle bundle = new Bundle();
                bundle.putString(Constants.GROUP_ID, groupId);
                bundle.putStringArrayList(Constants.SELECT_MEMBER_LIST, list);
                TUICore.startActivity("SelectGroupMemberActivity", bundle);
            }
        });
        mBaseCallView.enableAddUserView(inviteUserBtn);
    }

    private void inviteUsersToGroupCall(List<String> userIdList) {
        if (userIdList == null || userIdList.isEmpty()) {
            TUILog.e(TAG, "inviteUsersToGroupCall, userIdList is empty: " + userIdList);
            return;
        }

        mCallingAction.inviteUser(userIdList, new TUICommonDefine.ValueCallback() {
            @Override
            public void onSuccess(Object data) {
                if (!(data instanceof List)) {
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
        UserLayout userLayout = mUserLayoutFactory.findUserLayout(model.userId);
        if (userLayout == null) {
            return;
        }
        mUserInfoUtils.getUserInfo(model.userId, new UserInfoUtils.UserCallback() {
            @Override
            public void onSuccess(List<CallingUserModel> list) {
                if (list != null && !list.isEmpty()) {
                    CallingUserModel tempModel = list.get(0);
                    if (tempModel != null && model.userId.equals(tempModel.userId)) {
                        model.userAvatar = tempModel.userAvatar;
                        model.userName = tempModel.userName;
                    }
                }
                if (Scene.GROUP_CALL.equals(TUICallingStatusManager.sharedInstance(mContext).getCallScene())) {
                    userLayout.setUserName(model.userName);
                }
                userLayout.setVideoAvailable(model.isVideoAvailable);
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
            return;
        }
        if (Constants.EVENT_TUICALLING_CHANGED.equals(key)) {
            switch (subKey) {
                case Constants.EVENT_SUB_CAMERA_OPEN:
                    if (mSelfUserModel == null) {
                        break;
                    }
                    mSelfUserModel.isVideoAvailable = (boolean) param.get(Constants.OPEN_CAMERA);

                    UserLayout selfLayout = mUserLayoutFactory.findUserLayout(mSelfUserModel.userId);
                    if (selfLayout == null) {
                        break;
                    }
                    selfLayout.setVideoAvailable(mSelfUserModel.isVideoAvailable);

                    if (Scene.SINGLE_CALL.equals(TUICallingStatusManager.sharedInstance(mContext).getCallScene())) {
                        RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(180, 180);
                        lp.addRule(RelativeLayout.CENTER_IN_PARENT);
                        ((RoundCornerImageView) selfLayout.getAvatarImage()).setRadius(15);
                        selfLayout.getAvatarImage().setLayoutParams(lp);
                    }
                    ImageLoader.loadImage(mContext, selfLayout.getAvatarImage(), mSelfUserModel.userAvatar);
                    break;
                case Constants.EVENT_SUB_MIC_STATUS_CHANGED:
                    if (mSelfUserModel != null) {
                        mSelfUserModel.isAudioAvailable = ((Boolean) param.get(Constants.MUTE_MIC));
                    }
                    UserLayout layout = mUserLayoutFactory.findUserLayout(TUILogin.getLoginUser());
                    if (null != layout) {
                        layout.muteMic(mSelfUserModel.isAudioAvailable);
                    }
                    break;
                case Constants.EVENT_SUB_CALL_STATUS_CHANGED:
                    updateCallStatus((TUICallDefine.Status) param.get(Constants.CALL_STATUS));
                    break;
                case Constants.EVENT_SUB_CALL_TYPE_CHANGED:
                    updateCallType((TUICallDefine.MediaType) param.get(Constants.CALL_MEDIA_TYPE));
                    break;
                case Constants.EVENT_SUB_GROUP_MEMBER_SELECTED:
                    List<String> list = (List<String>) param.get(Constants.SELECT_MEMBER_LIST);
                    inviteUsersToGroupCall(list);
                    break;
                default:
                    break;
            }
        }
    }
}
