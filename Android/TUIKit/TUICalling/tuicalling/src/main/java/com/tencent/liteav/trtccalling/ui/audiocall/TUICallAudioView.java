package com.tencent.liteav.trtccalling.ui.audiocall;

import android.content.Context;
import android.util.Log;
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
import com.tencent.liteav.trtccalling.ui.audiocall.audiolayout.TRTCAudioLayout;
import com.tencent.liteav.trtccalling.ui.audiocall.audiolayout.TRTCAudioLayoutManager;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;

import java.util.List;
import java.util.Map;

public class TUICallAudioView extends BaseTUICallView {
    private static final String TAG = "TUICallAudioView";

    private ImageView              mImageMute;
    private ImageView              mImageHangup;
    private LinearLayout           mLayoutMute;
    private LinearLayout           mLayoutHangup;
    private ImageView              mImageHandsFree;
    private LinearLayout           mLayoutHandsFree;
    private ImageView              mImageDialing;
    private LinearLayout           mLayoutDialing;
    private TRTCAudioLayoutManager mLayoutManagerTRTC;
    private Group                  mGroupInviting;
    private LinearLayout           mLayoutImgContainer;
    private TextView               mTextTime;
    private TextView               mInvitedTag;
    private TextView               mTvHangup;

    public TUICallAudioView(Context context, TUICalling.Role role, TUICalling.Type type, String[] userIDs,
                            String sponsorID, String groupID, boolean isFromGroup) {
        super(context, role, type, userIDs, sponsorID, groupID, isFromGroup);
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
            showInvitingView();
            PermissionUtils.permission(PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(List<String> permissionsGranted) {
                    startInviting(TRTCCalling.TYPE_AUDIO_CALL);
                }

                @Override
                public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                    ToastUtils.showShort(R.string.trtccalling_tips_start_audio);
                    finish();
                }
            }).request();
        }
    }

    @Override
    protected void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.trtccalling_audiocall_activity_call_main, this);
        mImageMute = (ImageView) findViewById(R.id.img_mute);
        mLayoutMute = (LinearLayout) findViewById(R.id.ll_mute);
        mImageHangup = (ImageView) findViewById(R.id.img_hangup);
        mLayoutHangup = (LinearLayout) findViewById(R.id.ll_hangup);
        mImageHandsFree = (ImageView) findViewById(R.id.img_handsfree);
        mLayoutHandsFree = (LinearLayout) findViewById(R.id.ll_handsfree);
        mImageDialing = (ImageView) findViewById(R.id.img_dialing);
        mLayoutDialing = (LinearLayout) findViewById(R.id.ll_dialing);
        mLayoutManagerTRTC = (TRTCAudioLayoutManager) findViewById(R.id.trtc_layout_manager);
        mGroupInviting = (Group) findViewById(R.id.group_inviting);
        mLayoutImgContainer = (LinearLayout) findViewById(R.id.ll_img_container);
        mTextTime = (TextView) findViewById(R.id.tv_time);
        mInvitedTag = (TextView) findViewById(R.id.tv_inviting_tag);
        mTvHangup = (TextView) findViewById(R.id.tv_hangup);
        setImageBackView(findViewById(R.id.img_audio_back));
    }

    private void initListener() {
        mLayoutMute.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mIsMuteMic = !mIsMuteMic;
                mTRTCCalling.setMicMute(mIsMuteMic);
                mImageMute.setActivated(mIsMuteMic);
                ToastUtils.showLong(mIsMuteMic ? R.string.trtccalling_toast_enable_mute : R.string.trtccalling_toast_disable_mute);
            }
        });
        mLayoutHandsFree.setOnClickListener(new View.OnClickListener() {
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
    public void onUserEnter(final String userId) {
        super.onUserEnter(userId);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showCallingView();
                TRTCAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(userId);
                if (layout != null) {
                    layout.stopLoading();
                } else {
                    UserModel model = new UserModel();
                    model.userId = userId;
                    model.userAvatar = "";
                    mCallUserInfoList.add(model);
                    mCallUserModelMap.put(model.userId, model);
                    loadUserInfo(model, addUserToManager(model));
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
                //回收界面元素
                mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
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
                mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
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
                mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
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
                mLayoutManagerTRTC.recyclerAudioCallLayout(userId);
            }
        });
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            TRTCAudioLayout layout = mLayoutManagerTRTC.findAudioCallLayout(userId);
            if (layout != null) {
                layout.setAudioVolume(entry.getValue());
            }
        }
    }

    /**
     * 等待接听界面
     */
    public void showWaitingResponseView() {
        super.showWaitingResponseView();
        //1. 展示对方的画面
        TRTCAudioLayout layout = addUserToManager(mSponsorUserInfo);
        loadUserInfo(mSponsorUserInfo, layout);
        //2. 展示电话对应界面
        mLayoutHangup.setVisibility(View.VISIBLE);
        mLayoutDialing.setVisibility(View.VISIBLE);
        mLayoutHandsFree.setVisibility(View.GONE);
        mLayoutMute.setVisibility(View.GONE);
        //3. 设置对应的listener
        mLayoutHangup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.reject();
                finish();
            }
        });
        mLayoutDialing.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //1.分配自己的画面
                mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
                //2.接听电话
                mTRTCCalling.accept();
                mTRTCCalling.setHandsFree(mIsHandsFree);
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        showOtherInvitingUserView();
        mInvitedTag.setText(mContext.getString(R.string.trtccalling_invite_audio_call));
        mTvHangup.setText(R.string.trtccalling_text_reject);
    }

    /**
     * 展示邀请列表
     */
    public void showInvitingView() {
        super.showInvitingView();
        //1. 展示自己的界面
        mLayoutManagerTRTC.setMySelfUserId(mSelfModel.userId);
//        addUserToManager(mSelfModel);
        //2. 展示对方的画面
        for (UserModel userInfo : mCallUserInfoList) {
            TRTCAudioLayout layout = addUserToManager(userInfo);
            layout.startLoading();
            loadUserInfo(userInfo, layout);
        }
        //3. 设置底部栏
        mLayoutHangup.setVisibility(View.VISIBLE);
        mLayoutHangup.setOnClickListener(new View.OnClickListener() {
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
        super.showCallingView();
        mLayoutHangup.setVisibility(View.VISIBLE);
        mLayoutDialing.setVisibility(View.GONE);
        mLayoutHandsFree.setVisibility(View.VISIBLE);
        mLayoutMute.setVisibility(View.VISIBLE);
        mTvHangup.setText(R.string.trtccalling_text_hangup);
        mLayoutHangup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                finish();
            }
        });
        showTimeCount(mTextTime);
        hideOtherInvitingUserView();
    }

    private void showOtherInvitingUserView() {
        if (CollectionUtils.isEmpty(mOtherInviteeList)) {
            return;
        }
        mGroupInviting.setVisibility(View.VISIBLE);
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_size);
        int leftMargin = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_left_margin);
        for (int index = 0; index < mOtherInviteeList.size(); index++) {
            ImageView imageView = new ImageView(mContext);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            ImageLoader.loadImage(mContext, imageView, mSponsorUserInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
            mLayoutImgContainer.addView(imageView);
        }
    }

    private void hideOtherInvitingUserView() {
        mGroupInviting.setVisibility(View.GONE);
    }

    private TRTCAudioLayout addUserToManager(UserModel userInfo) {
        TRTCAudioLayout layout = mLayoutManagerTRTC.allocAudioCallLayout(userInfo.userId);
        if (layout == null) {
            return null;
        }
        layout.setUserName(userInfo.userName);
        ImageLoader.loadImage(mContext, layout.getImageView(), userInfo.userAvatar, R.drawable.trtccalling_ic_avatar);
        return layout;
    }

    private void loadUserInfo(final UserModel userModel, final TRTCAudioLayout layout) {
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
                        if (isDestroyed()) {
                            return;
                        }
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
}
