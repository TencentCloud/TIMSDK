package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_ROUTE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.ROOM_NAME_CHANGED;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.common.utils.RTCubeUtils;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.TopNavigationBar.TopView;

import java.lang.reflect.Method;
import java.util.Map;

public class TopViewModel implements ConferenceEventCenter.RoomEngineEventResponder {
    private Context         mContext;
    private TopView         mTopView;
    private ConferenceState mConferenceState;
    private Runnable        mTimeRunnable;
    private Handler         mTimeHandler;
    private Handler         mMainHandler;
    private HandlerThread   mTimeHandlerThread;

    public TopViewModel(Context context, TopView topView) {
        mContext = context;
        mTopView = topView;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();
        boolean isGeneralUser = TUIRoomDefine.Role.GENERAL_USER.equals(mConferenceState.userModel.getRole());
        mTopView.showReportView(isGeneralUser && RTCubeUtils.isRTCubeApp(context));
        mTopView.setTitle(mConferenceState.roomInfo.name);
        mTopView.setHeadsetImg(mConferenceState.audioModel.isSoundOnSpeaker());
        mTopView.setSwitchCameraViewVisible(
                ConferenceController.sharedInstance().getConferenceState().videoModel.isCameraOpened());
        mMainHandler = new Handler(Looper.getMainLooper());
        createTimeHandler();
        subscribeEngineEvent();
    }

    public void destroy() {
        unSubscribeEngineEvent();
    }

    private void subscribeEngineEvent() {
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_AUDIO_ROUTE_CHANGED, this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        ConferenceEventCenter.getInstance().subscribeEngine(ROOM_NAME_CHANGED, this);
    }

    public void unSubscribeEngineEvent() {
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_AUDIO_ROUTE_CHANGED, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(ROOM_NAME_CHANGED, this);
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
                int time = (int) (System.currentTimeMillis() - mConferenceState.userModel.enterRoomTime) / 1000;
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
        ConferenceController.sharedInstance().setAudioRoute(!mConferenceState.audioModel.isSoundOnSpeaker());
    }

    public void switchCamera() {
        ConferenceController.sharedInstance().switchCamera();
    }

    public void report() {
        if (mConferenceState.roomInfo == null) {
            return;
        }
        try {
            Class clz = Class.forName("com.tencent.liteav.demo.report.ReportDialog");
            Method method = clz.getDeclaredMethod("showReportDialog", Context.class, String.class, String.class);
            method.invoke(null, mContext, String.valueOf(mConferenceState.roomInfo.roomId), mConferenceState.roomInfo.ownerId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showMeetingInfo() {
        ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO, null);
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (event == LOCAL_AUDIO_ROUTE_CHANGED) {
            mTopView.setHeadsetImg(mConferenceState.audioModel.isSoundOnSpeaker());
            return;
        }
        if (event == LOCAL_CAMERA_STATE_CHANGED) {
            mTopView.setSwitchCameraViewVisible(mConferenceState.videoModel.isCameraOpened());
            return;
        }
        if (event == LOCAL_USER_ENTER_ROOM) {
            mTopView.setTitle(mConferenceState.roomInfo.name);
        }
        if (event == ROOM_NAME_CHANGED) {
            String conferenceName = (String) params.get(ConferenceEventConstant.KEY_ROOM_NAME);
            mTopView.setTitle(conferenceName);
        }
    }
}
