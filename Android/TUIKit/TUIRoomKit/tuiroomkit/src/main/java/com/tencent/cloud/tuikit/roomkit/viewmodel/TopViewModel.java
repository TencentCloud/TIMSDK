package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_ROUTE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.RTCubeUtils;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.TopNavigationBar.TopView;

import java.lang.reflect.Method;
import java.util.Map;

public class TopViewModel implements RoomEventCenter.RoomEngineEventResponder {
    private Context       mContext;
    private TopView       mTopView;
    private RoomStore     mRoomStore;
    private Runnable      mTimeRunnable;
    private Handler       mTimeHandler;
    private Handler       mMainHandler;
    private HandlerThread mTimeHandlerThread;

    public TopViewModel(Context context, TopView topView) {
        mContext = context;
        mTopView = topView;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        boolean isGeneralUser = TUIRoomDefine.Role.GENERAL_USER.equals(mRoomStore.userModel.getRole());
        mTopView.showReportView(isGeneralUser && RTCubeUtils.isRTCubeApp(context));
        mTopView.setTitle(TextUtils.isEmpty(mRoomStore.roomInfo.name) ? mRoomStore.roomInfo.roomId
                : mRoomStore.roomInfo.name + mContext.getString(R.string.tuiroomkit_meeting_title));
        mTopView.setHeadsetImg(mRoomStore.audioModel.isSoundOnSpeaker());
        mTopView.setSwitchCameraViewVisible(
                RoomEngineManager.sharedInstance().getRoomStore().videoModel.isCameraOpened());
        mMainHandler = new Handler(Looper.getMainLooper());
        createTimeHandler();
        subscribeEngineEvent();
    }

    public void destroy() {
        unSubscribeEngineEvent();
    }

    private void subscribeEngineEvent() {
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_AUDIO_ROUTE_CHANGED, this);
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
    }

    public void unSubscribeEngineEvent() {
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_AUDIO_ROUTE_CHANGED, this);
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
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
        mTimeRunnable = new Runnable() {
            @Override
            public void run() {
                int time = (int) (System.currentTimeMillis() - mRoomStore.userModel.enterRoomTime) / 1000;
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mTopView.updateTimeCount(time);
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
    }

    public void switchAudioRoute() {
        RoomEngineManager.sharedInstance().setAudioRoute(!mRoomStore.audioModel.isSoundOnSpeaker());
    }

    public void switchCamera() {
        RoomEngineManager.sharedInstance().switchCamera();
    }

    public void report() {
        if (mRoomStore.roomInfo == null) {
            return;
        }
        try {
            Class clz = Class.forName("com.tencent.liteav.demo.report.ReportDialog");
            Method method = clz.getDeclaredMethod("showReportDialog", Context.class, String.class, String.class);
            method.invoke(null, mContext, String.valueOf(mRoomStore.roomInfo.roomId), mRoomStore.roomInfo.ownerId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showMeetingInfo() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO, null);
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (event == LOCAL_AUDIO_ROUTE_CHANGED) {
            mTopView.setHeadsetImg(mRoomStore.audioModel.isSoundOnSpeaker());
            return;
        }
        if (event == LOCAL_CAMERA_STATE_CHANGED) {
            mTopView.setSwitchCameraViewVisible(mRoomStore.videoModel.isCameraOpened());
            return;
        }
        if (event == LOCAL_USER_ENTER_ROOM) {
            mTopView.setTitle(TextUtils.isEmpty(mRoomStore.roomInfo.name) ? mRoomStore.roomInfo.roomId :
                    mRoomStore.roomInfo.name + mContext.getString(R.string.tuiroomkit_meeting_title));
        }
    }
}
