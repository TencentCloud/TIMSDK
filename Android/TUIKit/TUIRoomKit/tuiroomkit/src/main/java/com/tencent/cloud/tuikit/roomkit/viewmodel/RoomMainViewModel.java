package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.TUIVideoSeatView;
import com.tencent.cloud.tuikit.roomkit.view.component.RoomMainView;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class RoomMainViewModel implements RoomEventCenter.RoomKitUIEventResponder,
        RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "MeetingViewModel";

    private static final int SEAT_INDEX   = -1;
    private static final int REQ_TIME_OUT = 30;

    private Context       mContext;
    private RoomStore     mRoomStore;
    private TUIRoomEngine mRoomEngine;
    private RoomMainView  mRoomMainView;

    public RoomMainViewModel(Context context, RoomMainView meetingView) {
        mContext = context;
        mRoomMainView = meetingView;
        mRoomEngine = RoomEngineManager.sharedInstance(context).getRoomEngine();
        mRoomStore = RoomEngineManager.sharedInstance(context).getRoomStore();
        subscribeEvent();
        setMirror();
        setAudioRoute();
    }

    private void setMirror() {
        RoomEngineManager.sharedInstance().enableVideoLocalMirror(mRoomStore.videoModel.isLocalMirror);
    }

    public void stopScreenCapture() {
        RoomEngineManager.sharedInstance().stopScreenCapture();
    }

    private void setAudioRoute() {
        mRoomEngine.getDeviceManager().setAudioRoute(mRoomStore.roomInfo.isUseSpeaker
                ? TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone
                : TXDeviceManager.TXAudioRoute.TXAudioRouteEarpiece);
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXTENSION_VIEW, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.LOCAL_SCREEN_SHARE_STATE_CHANGED, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.LEAVE_MEETING, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, this);

        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OFF_LINE, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXTENSION_VIEW, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.LOCAL_SCREEN_SHARE_STATE_CHANGED, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.LEAVE_MEETING, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, this);

        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OFF_LINE, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
    }

    public boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    public View getVideoSeatView() {
        TUIVideoSeatView seatView = new TUIVideoSeatView(mContext, mRoomStore.roomInfo.roomId,
                RoomEngineManager.sharedInstance(mContext).getRoomEngine());
        return seatView;
    }

    public void responseRequest(String requestId, boolean agree) {
        mRoomEngine.responseRemoteRequest(requestId, agree, null);
    }

    public RoomInfo getRoomInfo() {
        return mRoomStore.roomInfo;
    }

    public UserModel getUserModel() {
        return mRoomStore.userModel;
    }

    public void notifyConfigChange(Configuration configuration) {
        Map<String, Object> params = new HashMap<>();
        params.put(RoomEventConstant.KEY_CONFIGURATION, configuration);
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, params);
    }

    public void notifyExitRoom() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, null);
    }

    private void onCameraMuted(boolean muted) {
        mRoomMainView.onCameraMuted(muted);
    }

    private void onMicrophoneMuted(boolean muted) {
        mRoomMainView.onMicrophoneMuted(muted);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case RoomEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO:
                mRoomMainView.showRoomInfo();
                break;
            case RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST:
                mRoomMainView.showUserList();
                break;
            case RoomEventCenter.RoomKitUIEvent.SHOW_EXTENSION_VIEW:
                mRoomMainView.showExtensionView();
                break;
            case RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW:
                mRoomMainView.showExitRoomDialog();
                break;
            case RoomEventCenter.RoomKitUIEvent.LEAVE_MEETING:
                mRoomMainView.showTransferMasterView();
                break;
            case RoomEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW:
                if (params == null) {
                    break;
                }
                String url = (String) params.get(RoomEventConstant.KEY_ROOM_URL);
                if (!TextUtils.isEmpty(url)) {
                    mRoomMainView.showQRCodeView(url);
                }
                break;
            case RoomEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST:
                mRoomMainView.showApplyList();
                break;
            case RoomEventCenter.RoomKitUIEvent.LOCAL_SCREEN_SHARE_STATE_CHANGED:
                onScreenShareStateChanged();
                break;

            case RoomEventCenter.RoomKitUIEvent.EXIT_MEETING:
                RoomEngineManager.sharedInstance(mContext).exitRoom();
                break;
            default:
                break;
        }
    }

    private void onScreenShareStateChanged() {
        if (RoomEngineManager.sharedInstance().getRoomStore().videoModel.isScreenSharing()) {
            mRoomMainView.onScreenShareStarted();
        } else {
            mRoomMainView.onScreenShareStopped();
        }
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case ROOM_DISMISSED:
                onRoomDisMissed();
                break;
            case KICKED_OUT_OF_ROOM:
                mRoomMainView.showSingleConfirmDialog(mContext.getString(R.string.tuiroomkit_kicked_by_master), true);
                break;
            case KICKED_OFF_LINE:
                mRoomMainView.showKickedOffLineDialog();
                break;
            case USER_VIDEO_STATE_CHANGED:
                onUserVideoStateChanged(params);
                break;
            case USER_AUDIO_STATE_CHANGED:
                onUserAudioStateChanged(params);
                break;
            case REQUEST_RECEIVED:
                onRequestReceived(params);
                break;
            case ALL_USER_CAMERA_DISABLE_CHANGED:
                allUserCameraDisableChanged(params);
                break;
            case ALL_USER_MICROPHONE_DISABLE_CHANGED:
                allUserMicrophoneDisableChanged(params);
                break;
            case SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED:
                sendMessageForAllUserDisableChanged(params);
                break;
            case USER_ROLE_CHANGED:
                onUserRoleChange(params);
                break;
            default:
                break;
        }
    }

    private void onRoomDisMissed() {
        ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_toast_end_room));
        if (isOwner()) {
            showDestroyDialog();
        } else {
            mRoomMainView.showSingleConfirmDialog(mContext.getString(R.string.tuiroomkit_room_room_destroyed), true);
        }
    }

    private void showDestroyDialog() {
        try {
            Class clz = Class.forName("com.tencent.liteav.privacy.util.RTCubeAppLegalUtils");
            Method method = clz.getDeclaredMethod("showRoomDestroyTips", Context.class);
            method.invoke(null, this);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void onUserVideoStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        TUIRoomDefine.VideoStreamType videoStreamType = (TUIRoomDefine.VideoStreamType)
                params.get(RoomEventConstant.KEY_STREAM_TYPE);

        if (TUIRoomDefine.VideoStreamType.SCREEN_STREAM.equals(videoStreamType)) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        boolean available = (boolean) params.get(RoomEventConstant.KEY_HAS_VIDEO);
        TUIRoomDefine.ChangeReason changeReason = (TUIRoomDefine.ChangeReason) params.get(RoomEventConstant.KEY_REASON);
        if (mRoomStore.userModel.userId.equals(userId)
                && !TUIRoomDefine.ChangeReason.BY_SELF.equals(changeReason)) {
            onCameraMuted(!available);
        }
    }

    private void onUserAudioStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        TUIRoomDefine.ChangeReason changeReason = (TUIRoomDefine.ChangeReason) params.get(RoomEventConstant.KEY_REASON);
        if (changeReason == null) {
            return;
        }
        boolean available = (boolean) params.get(RoomEventConstant.KEY_HAS_AUDIO);
        if (mRoomStore.userModel.userId.equals(userId)
                && !TUIRoomDefine.ChangeReason.BY_SELF.equals(changeReason)) {
            onMicrophoneMuted(!available);
        }
    }

    private void onRequestReceived(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        TUIRoomDefine.Request request = (TUIRoomDefine.Request) params.get(RoomEventConstant.KEY_REQUEST);
        if (request == null) {
            return;
        }
        switch (request.requestAction) {
            case REQUEST_TO_OPEN_REMOTE_MICROPHONE:
            case REQUEST_REMOTE_USER_ON_SEAT:
            case REQUEST_TO_OPEN_REMOTE_CAMERA:
                mRoomMainView.showInvitationDialog(request.requestId, request.requestAction);
                break;
            default:
                Log.i(TAG, "onRequestReceived ignore, request type :" + request.requestAction);
                break;
        }
    }


    private void allUserCameraDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (isOwner()) {
            return;
        }

        boolean isDisable = (Boolean) params.get(RoomEventConstant.KEY_IS_DISABLE);
        int stringResId = isDisable
                ? R.string.tuiroomkit_mute_all_camera_toast
                : R.string.tuiroomkit_toast_not_mute_all_video;
        ToastUtil.toastShortMessage(mContext.getString(stringResId));

        if (isDisable) {
            RoomEngineManager.sharedInstance().closeLocalCamera();
        }
    }

    private void allUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (isOwner()) {
            return;
        }

        boolean isDisable = (Boolean) params.get(RoomEventConstant.KEY_IS_DISABLE);
        int resId = isDisable ? R.string.tuiroomkit_mute_all_mic_toast : R.string.tuiroomkit_toast_not_mute_all_audio;
        ToastUtil.toastShortMessage(mContext.getString(resId));

        if (isDisable) {
            RoomEngineManager.sharedInstance().closeLocalMicrophone();
        }
    }

    private void sendMessageForAllUserDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        mRoomStore.roomInfo.isMessageDisableForAllUser = (boolean) params
                .get(RoomEventConstant.KEY_IS_DISABLE);
    }

    private void onUserRoleChange(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId) || !mRoomStore.userModel.userId.equals(userId)) {
            return;
        }

        TUIRoomDefine.Role role = (TUIRoomDefine.Role) params.get(RoomEventConstant.KEY_ROLE);
        if (role == null) {
            return;
        }

        if (TUIRoomDefine.Role.ROOM_OWNER.equals(role)) {
            mRoomEngine.takeSeat(SEAT_INDEX, REQ_TIME_OUT, null);
            mRoomMainView.showSingleConfirmDialog(mContext.getString(R.string.tuiroomkit_have_become_master), false);
        }
    }
}
