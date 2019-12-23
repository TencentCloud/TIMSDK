package com.tencent.qcloud.tim.demo.helper;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import com.tencent.imsdk.TIMManager;
import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import androidx.annotation.Nullable;

import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;

public class TRTCActivity extends BaseActivity {

    private static final String TAG = TRTCActivity.class.getSimpleName();

    public static final String KEY_ROOM_ID = "room_id";

    private ImageView mHangupIv;
    private TXCloudVideoView mLocalPreviewView;
    private TXCloudVideoView mSubVideoView;

    private TRTCCloud mTRTCCloud;
    private TRTCCloudDef.TRTCParams mTRTCParams;
    private TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            DemoLog.i(TAG, "onError " + errCode + " " + errMsg);
            finish();
        }

        @Override
        public void onExitRoom(int reason) {
            super.onExitRoom(reason);
            DemoLog.i(TAG, "onExitRoom " + reason);
            finish();
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            super.onRemoteUserEnterRoom(userId);
            DemoLog.i(TAG, "onRemoteUserEnterRoom " + userId);
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            super.onRemoteUserLeaveRoom(userId, reason);
            DemoLog.i(TAG, "onRemoteUserLeaveRoom " + userId + " " + reason);
            // 对方超时掉线
            if (reason == 1) {
                finishVideoCall();
                finish();
            }
        }

        @Override
        public void onFirstVideoFrame(String userId, int steamType, int width, int height) {
            DemoLog.i(TAG, "onFirstVideoFrame " + userId + " " + steamType + " " + width + " " + height);
            super.onFirstVideoFrame(userId, steamType, width, height);
            if (!TextUtils.equals(userId, TIMManager.getInstance().getLoginUser())) {
                ViewGroup.LayoutParams params = mSubVideoView.getLayoutParams();
                final int FIXED = 480;
                params.width = FIXED;
                params.height = FIXED * height / width;
                mSubVideoView.setLayoutParams(params);
            }
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            super.onUserVideoAvailable(userId, available);
            DemoLog.i(TAG, "onUserVideoAvailable " + userId + " " + available);
            if (available) {
                mTRTCCloud.setRemoteViewFillMode(userId, TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT);
                mTRTCCloud.startRemoteView(userId, mSubVideoView);
            }
        }

    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // 设置布局
        setContentView(R.layout.trtc_activity);
        mLocalPreviewView = findViewById(R.id.local_video_preview);
        mSubVideoView = findViewById(R.id.sub_video);
        mHangupIv = findViewById(R.id.hangup);
        mHangupIv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DemoLog.i(TAG, "mHangupIv click");
                finish();
                finishVideoCall();
            }
        });

        // 获取进房参数
        int roomId = getIntent().getIntExtra(KEY_ROOM_ID, 0);
        DemoLog.i(TAG, "enter room id: " + roomId);
        int sdkAppId = GenerateTestUserSig.SDKAPPID;
        String userId = TIMManager.getInstance().getLoginUser();
        String userSig  = GenerateTestUserSig.genTestUserSig(userId);
        mTRTCParams = new TRTCCloudDef.TRTCParams(sdkAppId, userId, userSig, roomId, "", "");
        mTRTCCloud = TRTCCloud.sharedInstance(this);

        // 开始进房
        enterRoom();
    }

    private void enterRoom() {
        TRTCListener.getInstance().addTRTCCloudListener(mTRTCCloudListener);
        mTRTCCloud.setListener(TRTCListener.getInstance());
        mTRTCCloud.startLocalAudio();
        mTRTCCloud.startLocalPreview(true, mLocalPreviewView);
        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_VIDEOCALL);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        DemoLog.i(TAG, "onBackPressed");
        finishVideoCall();
    }

    private void finishVideoCall() {
        CustomAVCallUIController.getInstance().hangup();
        mTRTCCloud.exitRoom();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        TRTCListener.getInstance().removeTRTCCloudListener(mTRTCCloudListener);
    }
}
