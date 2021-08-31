package com.tencent.liteav.ui;

import android.Manifest;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Vibrator;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.Group;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.SelectContactActivity;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.liteav.model.ITRTCAVCall;
import com.tencent.liteav.model.IntentParams;
import com.tencent.liteav.model.TRTCAVCallImpl;
import com.tencent.liteav.model.TRTCAVCallListener;
import com.tencent.liteav.ui.audiolayout.TRTCAudioLayout;
import com.tencent.liteav.ui.audiolayout.TRTCAudioLayoutManager;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;
import com.tencent.qcloud.tim.tuikit.live.utils.PermissionUtils;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用于展示语音通话的主界面，通话的接听和拒绝就是在这个界面中完成的。
 *
 * @author guanyifeng
 */
public class TRTCAudioCallActivity extends AppCompatActivity {
    private static final String TAG = TRTCAudioCallActivity.class.getName();

    public static final int TYPE_BEING_CALLED = 1;
    public static final int TYPE_BEING_CALLED_FROM_NOTIFICATION = 3;
    public static final int TYPE_CALL         = 2;

    public static final String PARAM_GROUP_ID = "group_id";
    public static final  String PARAM_TYPE                = "type";
    public static final  String PARAM_USER                = "user_model";
    public static final  String PARAM_BEINGCALL_USER      = "beingcall_user_model";
    public static final  String PARAM_OTHER_INVITING_USER = "other_inviting_user_model";
    private static final int    MAX_SHOW_INVITING_USER    = 2;

    private static final int RADIUS = 30;
    private static final int REQUEST_PERMISSION_CODE = 99;

    /**
     * 界面元素相关
     */
    private ImageView              mMuteImg;
    private LinearLayout           mMuteLl;
    private ImageView              mHangupImg;
    private LinearLayout           mHangupLl;
    private ImageView              mHandsfreeImg;
    private LinearLayout           mHandsfreeLl;
    private ImageView              mDialingImg;
    private LinearLayout           mDialingLl;
    private TRTCAudioLayoutManager mLayoutManagerTrtc;
    private Group mInvitingGroup;
    private LinearLayout           mImgContainerLl;
    private TextView               mTimeTv;
    private Runnable               mTimeRunnable;
    private int                    mTimeCount;
    private Handler                mTimeHandler;
    private HandlerThread          mTimeHandlerThread;

    /**
     * 拨号相关成员变量
     */
    private UserModel mSelfModel;
    private List<UserModel>        mCallUserModelList = new ArrayList<>(); // 呼叫方
    private Map<String, UserModel> mCallUserModelMap  = new HashMap<>();
    private UserModel              mSponsorUserModel; // 被叫方
    private List<UserModel>        mOtherInvitingUserModelList;
    private int                    mCallType;
    private ITRTCAVCall mITRTCAVCall;
    private String mGroupId;
    private boolean                isHandsFree        = true;
    private boolean                isMuteMic          = false;
    private Vibrator mVibrator;
    private Ringtone mRingtone;

    /**
     * 拨号的回调
     */
    private TRTCAVCallListener mTRTCAudioCallListener = new TRTCAVCallListener() {
        @Override
        public void onError(int code, String msg) {
            //发生了错误，报错并退出该页面
            ToastUtil.toastLongMessage(getString(R.string.error)+ "[" + code + "]:" + msg);
            finishActivity();
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
                    TRTCAudioLayout layout = mLayoutManagerTrtc.findAudioCallLayout(userId);
                    if (layout != null) {
                        layout.stopLoading();
                    } else {
                        // 没有这个用户，需要重新分配, 先获取用户资料，在进行分配
                        ProfileManager.getInstance().getUserInfoByUserId(userId, new ProfileManager.GetUserInfoCallback() {
                            @Override
                            public void onSuccess(UserModel model) {
                                mCallUserModelList.add(model);
                                mCallUserModelMap.put(model.userId, model);
                                addUserToManager(model);
                            }

                            @Override
                            public void onFailed(int code, String msg) {
                                // 获取用户资料失败了，模拟一个用户
                                ToastUtil.toastLongMessage(getString(R.string.get_user_info_tips_before) + userId + getString(R.string.get_user_info_tips_after));
                                UserModel model = new UserModel();
                                model.userId = userId;
                                model.phone = "";
                                model.userName = userId;
                                model.userAvatar = "";
                                mCallUserModelList.add(model);
                                mCallUserModelMap.put(model.userId, model);
                                addUserToManager(model);
                            }
                        });
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
                    mLayoutManagerTrtc.recyclerAudioCallLayout(userId);
                    //2. 删除用户model
                    UserModel userModel = mCallUserModelMap.remove(userId);
                    if (userModel != null) {
                        mCallUserModelList.remove(userModel);
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
                        mLayoutManagerTrtc.recyclerAudioCallLayout(userId);
                        //2. 删除用户model
                        UserModel userModel = mCallUserModelMap.remove(userId);
                        if (userModel != null) {
                            mCallUserModelList.remove(userModel);
                            ToastUtil.toastLongMessage(userModel.userName + getString(R.string.reject_call));
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
                        mLayoutManagerTrtc.recyclerAudioCallLayout(userId);
                        //2. 删除用户model
                        UserModel userModel = mCallUserModelMap.remove(userId);
                        if (userModel != null) {
                            mCallUserModelList.remove(userModel);
                            ToastUtil.toastLongMessage(userModel.userName + getString(R.string.no_response));
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
                mLayoutManagerTrtc.recyclerAudioCallLayout(userId);
                //2. 删除用户model
                UserModel userModel = mCallUserModelMap.remove(userId);
                if (userModel != null) {
                    mCallUserModelList.remove(userModel);
                    ToastUtil.toastLongMessage(userModel.userName + getString(R.string.line_busy));
                }
            }
        }

        @Override
        public void onCallingCancel() {
            if (mSponsorUserModel != null) {
                ToastUtil.toastLongMessage(mSponsorUserModel.userName + getString(R.string.cancle_calling));
            }
            finishActivity();
        }

        @Override
        public void onCallingTimeout() {
            if (mSponsorUserModel != null) {
                ToastUtil.toastLongMessage(mSponsorUserModel.userName + getString(R.string.call_time_out));
            }
            finishActivity();
        }

        @Override
        public void onCallEnd() {
            finishActivity();
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
            for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
                String          userId = entry.getKey();
                TRTCAudioLayout layout = mLayoutManagerTrtc.findAudioCallLayout(userId);
                if (layout != null) {
                    layout.setAudioVolume(entry.getValue());
                }
            }
        }
    };

    /**
     * 主动拨打给某个用户
     *
     * @param context
     * @param models
     */
    public static void startCallSomeone(Context context, List<UserModel> models) {
        TUILiveLog.i(TAG, "startCallSomeone");
        ((TRTCAVCallImpl)TRTCAVCallImpl.sharedInstance(context)).setWaitingLastActivityFinished(false);
        Intent starter = new Intent(context, TRTCAudioCallActivity.class);
        starter.putExtra(PARAM_TYPE, TYPE_CALL);
        starter.putExtra(PARAM_USER, new IntentParams(models));
        starter.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(starter);
    }

    /**
     * 主动拨打给某些用户
     *
     * @param context
     * @param models
     */
    public static void startCallSomePeople(Context context, List<UserModel> models, String groupId) {
        TUILiveLog.i(TAG, "startCallSomePeople");
        ((TRTCAVCallImpl)TRTCAVCallImpl.sharedInstance(context)).setWaitingLastActivityFinished(false);
        Intent starter = new Intent(context, TRTCAudioCallActivity.class);
        starter.putExtra(PARAM_GROUP_ID, groupId);
        starter.putExtra(PARAM_TYPE, TYPE_CALL);
        starter.putExtra(PARAM_USER, new IntentParams(models));
        starter.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(starter);
    }

    /**
     * 作为用户被叫
     *
     * @param context
     * @param beingCallUserModel
     */
    public static void startBeingCall(Context context, UserModel beingCallUserModel, List<UserModel> otherInvitingUserModel) {
        TUILiveLog.i(TAG, "startBeingCall");
        ((TRTCAVCallImpl)TRTCAVCallImpl.sharedInstance(context)).setWaitingLastActivityFinished(false);
        Intent starter = new Intent(context, TRTCAudioCallActivity.class);
        starter.putExtra(PARAM_TYPE, TYPE_BEING_CALLED);
        starter.putExtra(PARAM_BEINGCALL_USER, beingCallUserModel);
        starter.putExtra(PARAM_OTHER_INVITING_USER, new IntentParams(otherInvitingUserModel));
        starter.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TUILiveLog.i(TAG, "onCreate");
        if (!PermissionUtils.checkPermission(this, Manifest.permission.RECORD_AUDIO)) {
            PermissionUtils.requestPermission(this, Manifest.permission.RECORD_AUDIO, REQUEST_PERMISSION_CODE);
            ToastUtil.toastLongMessage(this.getString(R.string.audio_permission_error));
            finish();
            return;
        }

        mCallType = getIntent().getIntExtra(PARAM_TYPE, TYPE_BEING_CALLED);
        TUILiveLog.i(TAG, "mCallType: " + mCallType);
        if (mCallType == TYPE_BEING_CALLED && ((TRTCAVCallImpl)TRTCAVCallImpl.sharedInstance(this)).isWaitingLastActivityFinished()) {
            // 有些手机禁止后台启动Activity，但是有bug，比如一种场景：对方反复拨打并取消，三次以上极容易从后台启动成功通话界面，
            // 此时对方再挂断时，此通话Activity调用finish后，上一个从后台启动的Activity就会弹出。此时这个Activity就不能再启动。
            TUILiveLog.w(TAG, "ignore activity launch");
            finishActivity();
            return;
        }

        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager != null) {
            manager.cancelAll();
        }

        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.audiocall_activity_call_main);

        mVibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);
        mRingtone = RingtoneManager.getRingtone(this,
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE));

        initView();
        initData();
        initListener();
    }

    private void finishActivity() {
        ((TRTCAVCallImpl)TRTCAVCallImpl.sharedInstance(this)).setWaitingLastActivityFinished(true);
        finish();
    }

    @Override
    public void onResume() {
        super.onResume();
        TUILiveLog.i(TAG, "onResume");
    }


    @Override
    public void onPause() {
        super.onPause();
        TUILiveLog.i(TAG, "onPause");
    }

    @Override
    public void onStart() {
        super.onStart();
        TUILiveLog.i(TAG, "onStart");
    }

    @Override
    public void onStop() {
        super.onStop();
        TUILiveLog.i(TAG, "onStop");
    }

    @Override
    public void onBackPressed() {
        TUILiveLog.i(TAG, "onBackPressed");
        // 退出这个界面的时候，需要挂断
        mITRTCAVCall.hangup();
        super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        TUILiveLog.i(TAG, "onDestroy");
        super.onDestroy();
        if (mVibrator != null) {
            mVibrator.cancel();
        }
        if (mRingtone != null) {
            mRingtone.stop();
        }
        if (mITRTCAVCall != null) {
            mITRTCAVCall.removeListener(mTRTCAudioCallListener);
        }
        stopTimeCount();
        if (mTimeHandlerThread != null) {
            mTimeHandlerThread.quit();
        }
    }

    private void initListener() {
        mMuteLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isMuteMic = !isMuteMic;
                mITRTCAVCall.setMicMute(isMuteMic);
                mMuteImg.setActivated(isMuteMic);
                ToastUtil.toastLongMessage(isMuteMic ? getString(R.string.open_silent) : getString(R.string.close_silent));
            }
        });
        mHandsfreeLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isHandsFree = !isHandsFree;
                mITRTCAVCall.setHandsFree(isHandsFree);
                mHandsfreeImg.setActivated(isHandsFree);
                ToastUtil.toastLongMessage(isHandsFree ? getString(R.string.use_speakers) : getString(R.string.use_handset));
            }
        });
        mMuteImg.setActivated(isMuteMic);
        mHandsfreeImg.setActivated(isHandsFree);
    }

    private void initData() {
        // 初始化成员变量
        mITRTCAVCall = TRTCAVCallImpl.sharedInstance(this);
        mITRTCAVCall.addListener(mTRTCAudioCallListener);
        mTimeHandlerThread = new HandlerThread("time-count-thread");
        mTimeHandlerThread.start();
        mTimeHandler = new Handler(mTimeHandlerThread.getLooper());
        // 初始化从外界获取的数据
        Intent intent = getIntent();
        //自己的资料
        mSelfModel = ProfileManager.getInstance().getUserModel();
        mCallType = intent.getIntExtra(PARAM_TYPE, TYPE_BEING_CALLED);
        mGroupId = intent.getStringExtra(PARAM_GROUP_ID);
        if (mCallType == TYPE_BEING_CALLED) {
            // 作为被叫
            mSponsorUserModel = (UserModel) intent.getSerializableExtra(PARAM_BEINGCALL_USER);
            IntentParams params = (IntentParams) intent.getSerializableExtra(PARAM_OTHER_INVITING_USER);
            if (params != null) {
                mOtherInvitingUserModelList = params.mUserModels;
            }
            showWaitingResponseView();
            mVibrator.vibrate(new long[] { 0, 1000, 1000 }, 0);
            mRingtone.play();
        } else {
            // 主叫方
            IntentParams params = (IntentParams) intent.getSerializableExtra(PARAM_USER);
            if (params != null) {
                mCallUserModelList = params.mUserModels;
                for (UserModel userModel : mCallUserModelList) {
                    mCallUserModelMap.put(userModel.userId, userModel);
                }
                startInviting();
                showInvitingView();
            }
        }
    }

    private void startInviting() {
        List<String> list = new ArrayList<>();
        for (UserModel userModel : mCallUserModelList) {
            list.add(userModel.userId);
        }
        mITRTCAVCall.groupCall(list, ITRTCAVCall.TYPE_AUDIO_CALL, mGroupId);
    }

    private void initView() {
        mMuteImg = (ImageView) findViewById(R.id.img_mute);
        mMuteLl = (LinearLayout) findViewById(R.id.ll_mute);
        mHangupImg = (ImageView) findViewById(R.id.img_hangup);
        mHangupLl = (LinearLayout) findViewById(R.id.ll_hangup);
        mHandsfreeImg = (ImageView) findViewById(R.id.img_handsfree);
        mHandsfreeLl = (LinearLayout) findViewById(R.id.ll_handsfree);
        mDialingImg = (ImageView) findViewById(R.id.img_dialing);
        mDialingLl = (LinearLayout) findViewById(R.id.ll_dialing);
        mLayoutManagerTrtc = (TRTCAudioLayoutManager) findViewById(R.id.trtc_layout_manager);
        mInvitingGroup = (Group) findViewById(R.id.group_inviting);
        mImgContainerLl = (LinearLayout) findViewById(R.id.ll_img_container);
        mTimeTv = (TextView) findViewById(R.id.tv_time);
    }


    /**
     * 等待接听界面
     */
    public void showWaitingResponseView() {
        //1. 展示对方的画面
        TRTCAudioLayout layout = mLayoutManagerTrtc.allocAudioCallLayout(mSponsorUserModel.userId);
        layout.setUserId(mSponsorUserModel.userName);
        GlideEngine.loadImage(layout.getImageView(), mSponsorUserModel.userAvatar, R.drawable.live_default_head_img, RADIUS);
        updateUserView(mSponsorUserModel, layout);
        //2. 展示电话对应界面
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.VISIBLE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        //3. 设置对应的listener
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mVibrator.cancel();
                mRingtone.stop();
                mITRTCAVCall.reject();
                finishActivity();
            }
        });
        mDialingLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mVibrator.cancel();
                mRingtone.stop();
                //1.分配自己的画面
                mLayoutManagerTrtc.setMySelfUserId(mSelfModel.userId);
                addUserToManager(mSelfModel);
                //2.接听电话
                mITRTCAVCall.accept();
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        showOtherInvitingUserView();
    }

    /**
     * 展示邀请列表
     */
    public void showInvitingView() {
        //1. 展示自己的界面
        mLayoutManagerTrtc.setMySelfUserId(mSelfModel.userId);
        addUserToManager(mSelfModel);
        //2. 展示对方的画面
        for (UserModel userModel : mCallUserModelList) {
            TRTCAudioLayout layout = addUserToManager(userModel);
            if (layout != null) {
                layout.startLoading();
            }
        }
        //3. 设置底部栏
        mHangupLl.setVisibility(View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mITRTCAVCall.hangup();
                finishActivity();
            }
        });
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        //4. 隐藏中间他们也在界面
        hideOtherInvitingUserView();
    }

    /**
     * 展示通话中的界面
     */
    public void showCallingView() {
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.VISIBLE);
        mMuteLl.setVisibility(View.VISIBLE);

        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mITRTCAVCall.hangup();
                finishActivity();
            }
        });
        showTimeCount();
        hideOtherInvitingUserView();
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
        if (mTimeHandler != null) {
            mTimeHandler.removeCallbacks(mTimeRunnable);
        }
        mTimeRunnable = null;
    }

    private String getShowTime(int count) {
        return String.format("%02d:%02d", count / 60, count % 60);
    }

    private void showOtherInvitingUserView() {
        if (mOtherInvitingUserModelList == null || mOtherInvitingUserModelList.isEmpty()) {
            return;
        }
        mInvitingGroup.setVisibility(View.VISIBLE);
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.contact_avatar_width);
        int leftMargin  = getResources().getDimensionPixelOffset(R.dimen.small_image_left_margin);
        for (int index = 0; index < mOtherInvitingUserModelList.size() && index < MAX_SHOW_INVITING_USER; index++) {
            UserModel                 userModel    = mOtherInvitingUserModelList.get(index);
            ImageView                 imageView    = new ImageView(this);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            GlideEngine.loadImage(imageView, userModel.userAvatar, R.drawable.live_default_head_img, SelectContactActivity.RADIUS);
            updateUserView(userModel, imageView);
            mImgContainerLl.addView(imageView);
        }
    }

    private void hideOtherInvitingUserView() {
        mInvitingGroup.setVisibility(View.GONE);
    }

    private TRTCAudioLayout addUserToManager(final UserModel userModel) {
        final TRTCAudioLayout layout = mLayoutManagerTrtc.allocAudioCallLayout(userModel.userId);
        if (layout == null) {
            return null;
        }
        layout.setUserId(userModel.userName);
        GlideEngine.loadImage(layout.getImageView(), userModel.userAvatar, R.drawable.live_default_head_img, RADIUS);
        updateUserView(userModel, layout);
        return layout;
    }

    private void updateUserView(final UserModel userModel, final Object layout) {
        if (!TextUtils.isEmpty(userModel.userName) && !TextUtils.isEmpty(userModel.userAvatar)) {
            return;
        }
        ArrayList<String> users = new ArrayList<>();
        users.add(userModel.userId);
        V2TIMManager.getInstance().getUsersInfo(users, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUILiveLog.w(TAG, "getUsersInfo code:" + "|desc:" +desc);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.size() != 1) {
                    TUILiveLog.w(TAG, "getUsersInfo v2TIMUserFullInfos error");
                    return;
                }
                if (TextUtils.isEmpty(userModel.userName)) {
                    userModel.userName = v2TIMUserFullInfos.get(0).getNickName();
                    if (layout instanceof TRTCAudioLayout) {
                        ((TRTCAudioLayout)layout).setUserId(v2TIMUserFullInfos.get(0).getNickName());
                    }
                }
                userModel.userAvatar = v2TIMUserFullInfos.get(0).getFaceUrl();
                if (layout instanceof TRTCAudioLayout) {
                    GlideEngine.loadImage(((TRTCAudioLayout)layout).getImageView(), userModel.userAvatar, R.drawable.live_default_head_img, RADIUS);
                } else if (layout instanceof ImageView) {
                    GlideEngine.loadImage((ImageView)layout, userModel.userAvatar, R.drawable.live_default_head_img, RADIUS);
                }
            }
        });
    }

}
