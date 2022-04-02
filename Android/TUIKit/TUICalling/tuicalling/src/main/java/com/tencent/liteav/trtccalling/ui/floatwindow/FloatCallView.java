package com.tencent.liteav.trtccalling.ui.floatwindow;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.base.BaseCallActivity;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.liteav.trtccalling.ui.base.Status;
import com.tencent.liteav.trtccalling.ui.base.VideoLayoutFactory;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayout;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.rtmp.ui.TXCloudVideoView;

public class FloatCallView extends BaseTUICallView {
    private static final String TAG = "FloatCallView";

    private TXCloudVideoView mRemoteTxCloudView; //远端用户视频画面
    private TXCloudVideoView mLocalTxCloudView;  //本地用户视频画面
    private ImageView        mAudioView;         //语音图标
    private TextView         mTextViewWaiting;
    private TextView         mTextViewTimeCount;
    private String           mRemoteUserId;      //对端用户,主叫保存第一个被叫;被叫保存主叫
    private TUICalling.Type  mCallType;          //通话类型
    private TXCloudVideoView mVideoView;
    private String           mNewUser;           //新进房的用户
    private int              mCount;

    private static final int UPDATE_COUNT    = 3;   //视频加载最大次数
    private static final int UPDATE_INTERVAL = 300; //视频重加载间隔(单位:ms)

    private final VideoLayoutFactory mVideoFactory;

    public FloatCallView(Context context, TUICalling.Role role, TUICalling.Type type, String[] userIDs,
                         String sponsorID, String groupID, boolean isFromGroup, VideoLayoutFactory factory) {
        super(context, role, type, userIDs, sponsorID, groupID, isFromGroup);
        mCallType = type;
        mVideoFactory = factory;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        initData();
        initListener();
        showFloatWindow();
    }

    private void initData() {
        if (TUICalling.Role.CALL == mRole) {
            for (String userId : mUserIDs) {
                mRemoteUserId = userId;
                return;
            }
        } else if (TUICalling.Role.CALLED == mRole) {
            mRemoteUserId = mSponsorID;
        } else {
            TRTCLogger.i(TAG, "initData mRole: " + mRole);
        }
    }

    @Override
    protected void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.trtccalling_floatwindow_layout, this);
        mRemoteTxCloudView = findViewById(R.id.float_video_remote);
        mLocalTxCloudView = findViewById(R.id.float_video_local);
        mTextViewWaiting = findViewById(R.id.tv_waiting_response);
        mAudioView = findViewById(R.id.float_audioView);
        mTextViewTimeCount = findViewById(R.id.tv_time);
    }

    private void showFloatWindow() {
        TRTCLogger.i(TAG, "showFloatWindow: CallStatus = " + Status.mCallStatus
                + " , mRemoteUser = " + mRemoteUserId);
        if (Status.CALL_STATUS.NONE == Status.mCallStatus) {
            return;
        }
        if (Status.mCallStatus == Status.CALL_STATUS.ACCEPT) {
            mTextViewWaiting.setVisibility(View.GONE);
            mTextViewTimeCount.setVisibility(View.VISIBLE);
            showTimeCount(mTextViewTimeCount);
            updateView(mRemoteUserId);
        } else {
            mTextViewWaiting.setVisibility(View.VISIBLE);
            mTextViewTimeCount.setVisibility(View.GONE);
            updateView(TUILogin.getUserId());
        }
    }

    //更新显示
    private void updateView(String userId) {
        TRTCLogger.i(TAG, "updateView userId : " + userId + " , mCallType : " + mCallType);
        if (TUICalling.Type.VIDEO.equals(mCallType)) {
            if (isGroupCall()) {
                mRemoteTxCloudView.setVisibility(GONE);
                mLocalTxCloudView.setVisibility(GONE);
                mAudioView.setVisibility(View.VISIBLE);
            } else {
                mAudioView.setVisibility(View.GONE);
                mTextViewWaiting.setVisibility(View.GONE);
                mTextViewTimeCount.setVisibility(View.GONE);
                mRemoteTxCloudView.setVisibility(VISIBLE);
                updateVideoFloatWindow(userId);
            }
        } else if (TUICalling.Type.AUDIO.equals(mCallType)) {
            mRemoteTxCloudView.setVisibility(GONE);
            mLocalTxCloudView.setVisibility(GONE);
            mAudioView.setVisibility(View.VISIBLE);
        }
        //更新当前悬浮窗状态
        Status.mCurFloatUserId = userId;
        Status.mIsShowFloatWindow = true;
    }

    //更新视频通话界面
    //视频通话未接通时,悬浮窗显示自己的画面,
    //视频通话已接听,悬浮窗显示对端画面.
    private void updateVideoFloatWindow(String userId) {
        if (TextUtils.isEmpty(userId)) {
            TRTCLogger.d(TAG, "userId is empty");
            return;
        }
        if (null == mVideoFactory) {
            TRTCLogger.d(TAG, "VideoFactory is empty");
            return;
        }

        TRTCVideoLayout videoLayout = mVideoFactory.findUserLayout(userId);
        if (null == videoLayout) {
            videoLayout = mVideoFactory.allocUserLayout(userId, new TRTCVideoLayout(mContext));
        }
        TRTCLogger.i(TAG, "updateVideoFloatWindow: userId = " + userId + " ,videoLayout: " + videoLayout);
        TXCloudVideoView renderView = videoLayout.getVideoView();
        if (null == renderView) {
            TRTCLogger.d(TAG, "video renderView is empty");
            return;
        }

        TextureView mTextureView = renderView.getVideoView();
        if (null == mTextureView) {
            return;
        }
        if (null != mTextureView.getParent()) {
            ((ViewGroup) mTextureView.getParent()).removeView(mTextureView);
        }
        if (userId.equals(TUILogin.getLoginUser())) {
            mRemoteTxCloudView.setVisibility(GONE);
            mLocalTxCloudView.setVisibility(VISIBLE);
            mLocalTxCloudView.removeAllViews();
            mLocalTxCloudView.addVideoView(mTextureView);
        } else {
            mLocalTxCloudView.setVisibility(GONE);
            mRemoteTxCloudView.setVisibility(VISIBLE);
            mRemoteTxCloudView.removeAllViews();
            mRemoteTxCloudView.addVideoView(mTextureView);
        }
    }

    private void initListener() {
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(mContext, BaseCallActivity.class);
                intent.putExtra(TUICallingConstants.PARAM_NAME_TYPE, mCallType);
                intent.putExtra(TUICallingConstants.PARAM_NAME_ROLE, mRole);
                if (TUICalling.Role.CALLED == mRole) {
                    intent.putExtra(TUICallingConstants.PARAM_NAME_SPONSORID, mSponsorID);
                    intent.putExtra(TUICallingConstants.PARAM_NAME_ISFROMGROUP, mIsFromGroup);
                }
                intent.putExtra(TUICallingConstants.PARAM_NAME_USERIDS, mUserIDs);
                intent.putExtra(TUICallingConstants.PARAM_NAME_GROUPID, mGroupID);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                mContext.startActivity(intent);
            }
        });
    }

    @Override
    public void onUserEnter(String userId) {
        super.onUserEnter(userId);
        if (!Status.mIsShowFloatWindow) {
            return;
        }
        //语音通话和群聊,用户进房后更新悬浮窗状态
        if (TUICalling.Type.AUDIO == mCallType || isGroupCall()) {
            mTextViewWaiting.setVisibility(GONE);
            mTextViewTimeCount.setVisibility(VISIBLE);
            showTimeCount(mTextViewTimeCount);
        }
    }

    @Override
    public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
        if (!Status.mIsShowFloatWindow) {
            return;
        }
        //单聊有用户的视频开启了
        if (null == mVideoFactory) {
            TRTCLogger.d(TAG, "VideoFactory is empty,ignore");
            return;
        }
        TRTCVideoLayout layout = mVideoFactory.findUserLayout(userId);
        if (null == layout) {
            return;
        }
        layout.setVideoAvailable(isVideoAvailable);
        if (isVideoAvailable) {
            mVideoView = layout.getVideoView();
            mNewUser = userId;
            //TextureView绘制会慢一点,等view准备好了,再去更新悬浮窗显示
            if (null == mVideoView.getVideoView()) {
                mVideoViewHandler.sendEmptyMessageDelayed(0, UPDATE_INTERVAL);
            } else {
                mTRTCCalling.startRemoteView(mNewUser, mVideoView);
                updateView(mNewUser);
            }
        } else {
            mTRTCCalling.stopRemoteView(userId);
        }
    }

    @Override
    public void onSwitchToAudio(boolean success, String message) {
        super.onSwitchToAudio(success, message);
        if (!Status.mIsShowFloatWindow) {
            return;
        }
        TRTCLogger.i(TAG, "onSwitchToAudio: success = " + success + " ,message = " + message);
        if (success) {
            //1.悬浮窗状态下,主叫端视频切语音,主叫端收到该回调,更新mCallStatus为ACCEPT;
            // 若被叫拒接,这直接挂断,走挂断流程,mCallStatus重置为NONE;
            // 若被叫接听,则表明是通话中,mCallStatus为ACCEPT.
            //2.悬浮窗状态下,被叫端视频切语音,被叫切语音后会默认进房,因此主叫收到该回调,表明在通话中.
            if (TUICalling.Role.CALL == mRole) {
                Status.mCallStatus = Status.CALL_STATUS.ACCEPT;
            }
            updateSwitchToAudioView();
        } else {
            TRTCLogger.e(TAG, "onSwitchToAudio failed ,message: " + message);
        }
    }

    //视频切语音后,更新悬浮窗的显示
    private void updateSwitchToAudioView() {
        mLocalTxCloudView.setVisibility(GONE);
        mRemoteTxCloudView.setVisibility(GONE);
        mAudioView.setVisibility(VISIBLE);
        if (Status.CALL_STATUS.ACCEPT == Status.mCallStatus) {
            mTextViewTimeCount.setVisibility(VISIBLE);
            showTimeCount(mTextViewTimeCount);
        } else if (Status.CALL_STATUS.WAITING == Status.mCallStatus) {
            mTextViewWaiting.setVisibility(VISIBLE);
        } else {
            TRTCLogger.i(TAG, "CallStatus is NONE");
        }
    }

    @Override
    public void onCallEnd() {
        super.onCallEnd();
        //通话结束,停止悬浮窗显示
        if (Status.mIsShowFloatWindow) {
            FloatWindowService.stopService(mContext);
            finish();
        }
    }

    private final Handler mVideoViewHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (null == mVideoView.getVideoView() && mCount <= UPDATE_COUNT) {
                sendEmptyMessageDelayed(0, UPDATE_INTERVAL);
                mCount++;
            } else {
                mTRTCCalling.startRemoteView(mNewUser, mVideoView);
                updateView(mNewUser);
            }
        }
    };

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        //悬浮窗这里拦截掉,否则不能响应onTouch事件
        return true;
    }

    @Override
    protected void onDetachedFromWindow() {
        TRTCLogger.i(TAG, "onDetachedFromWindow");
        mVideoViewHandler.removeCallbacksAndMessages(null);
        super.onDetachedFromWindow();
    }
}
