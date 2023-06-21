package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.RTCubeUtils;
import com.tencent.cloud.tuikit.roomkit.view.component.TopView;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.trtc.TRTCCloudDef;

import java.lang.reflect.Method;

public class TopViewModel {
    private int           mTimeCount;
    private Context       mContext;
    private TopView       mTopView;
    private RoomStore     mRoomStore;
    private Runnable      mTimeRunnable;
    private Handler       mTimeHandler;
    private Handler       mMainHandler;
    private HandlerThread mTimeHandlerThread;
    private TUIRoomEngine mRoomEngine;

    public TopViewModel(Context context, TopView topView) {
        mContext = context;
        mTopView = topView;
        mRoomEngine = RoomEngineManager.sharedInstance(context).getRoomEngine();
        mRoomStore = RoomEngineManager.sharedInstance(context).getRoomStore();
        boolean isGeneralUser = TUIRoomDefine.Role.GENERAL_USER.equals(mRoomStore.userModel.role);
        mTopView.showReportView(isGeneralUser && RTCubeUtils.isRTCubeApp(context));
        mTopView.setTitle(TextUtils.isEmpty(mRoomStore.roomInfo.name)
                ? mRoomStore.roomInfo.roomId
                : mRoomStore.roomInfo.name);
        mTopView.setHeadsetImg(mRoomStore.roomInfo.isUseSpeaker);
        mMainHandler = new Handler(Looper.getMainLooper());
        createTimeHandler();
    }

    private void createTimeHandler() {
        mTimeHandlerThread = new HandlerThread("time-count-thread");
        mTimeHandlerThread.start();
        mTimeHandler = new Handler(mTimeHandlerThread.getLooper());
    }

    public void startTimeCount() {
        if (mTimeRunnable != null) {
            return;
        }
        mTimeCount = 0;
        mTimeRunnable = new Runnable() {
            @Override
            public void run() {
                mTimeCount++;
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mTopView.updateTimeCount(mTimeCount);
                    }
                });
                mTimeHandler.postDelayed(mTimeRunnable, 1000);
            }
        };
        boolean isOk = mTimeHandler.postDelayed(mTimeRunnable, 1000);
        if (!isOk) {
            createTimeHandler();
            mTimeHandler.postDelayed(mTimeRunnable, 1000);
        }
    }

    public void stopTimeCount() {
        mTimeHandler.removeCallbacks(mTimeRunnable);
        mTimeRunnable = null;
        mTimeHandlerThread.quit();
        mTimeCount = 0;
    }

    public void switchAudioRoute() {
        mRoomStore.roomInfo.isUseSpeaker = !mRoomStore.roomInfo.isUseSpeaker;
        mRoomEngine.getDeviceManager().setAudioRoute(mRoomStore.roomInfo.isUseSpeaker
                ? TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone
                : TXDeviceManager.TXAudioRoute.TXAudioRouteEarpiece);
        mTopView.setHeadsetImg(mRoomStore.roomInfo.isUseSpeaker);
    }

    public void switchCamera() {
        mRoomStore.videoModel.isFrontCamera = !mRoomStore.videoModel.isFrontCamera;
        mRoomEngine.getDeviceManager().switchCamera(mRoomStore.videoModel.isFrontCamera);
    }

    public void report() {
        if (mRoomStore.roomInfo == null) {
            return;
        }
        try {
            Class clz = Class.forName("com.tencent.liteav.demo.report.ReportDialog");
            Method method = clz.getDeclaredMethod("showReportDialog", Context.class, String.class, String.class);
            method.invoke(null, mContext, String.valueOf(mRoomStore.roomInfo.roomId), mRoomStore.roomInfo.owner);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showMeetingInfo() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO, null);
    }

    public void setMirror() {
        mRoomStore.videoModel.isMirror = !mRoomStore.videoModel.isMirror;
        TRTCCloudDef.TRTCRenderParams param = new TRTCCloudDef.TRTCRenderParams();
        param.mirrorType = mRoomStore.videoModel.isMirror ? TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE
                : TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE;
        mRoomEngine.getTRTCCloud().setLocalRenderParams(param);
    }
}
