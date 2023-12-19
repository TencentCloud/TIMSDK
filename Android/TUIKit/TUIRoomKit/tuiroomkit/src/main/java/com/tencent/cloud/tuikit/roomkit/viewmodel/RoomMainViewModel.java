package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static android.content.res.Configuration.ORIENTATION_PORTRAIT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.BAR_SHOW_TIME_RECOUNT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_APPLY_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_EXIT_ROOM_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_INVITE_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_INVITE_PANEL_SECOND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_MEDIA_SETTING_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_MEETING_INFO;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_OWNER_EXIT_ROOM_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_QRCODE_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL_SECOND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_MEDIA_SETTING_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_OWNER_EXIT_ROOM_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.RoomMainView;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class RoomMainViewModel implements RoomEventCenter.RoomKitUIEventResponder,
        RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "MeetingViewModel";

    private static final int SEAT_INDEX   = -1;
    private static final int REQ_TIME_OUT = 0;

    private Context       mContext;
    private RoomStore     mRoomStore;
    private RoomMainView  mRoomMainView;

    private boolean mIsFirstPanelShowed  = false;
    private boolean mIsSecondPanelShowed = false;

    public RoomMainViewModel(Context context, RoomMainView meetingView) {
        mContext = context;
        mRoomMainView = meetingView;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        subscribeEvent();
    }

    public void stopScreenCapture() {
        mRoomMainView.stopScreenShare();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeUIEvent(SHOW_MEETING_INFO, this);
        eventCenter.subscribeUIEvent(DISMISS_MEETING_INFO, this);
        eventCenter.subscribeUIEvent(SHOW_USER_LIST, this);
        eventCenter.subscribeUIEvent(DISMISS_USER_LIST, this);
        eventCenter.subscribeUIEvent(SHOW_QRCODE_VIEW, this);
        eventCenter.subscribeUIEvent(DISMISS_QRCODE_VIEW, this);
        eventCenter.subscribeUIEvent(SHOW_MEDIA_SETTING_PANEL, this);
        eventCenter.subscribeUIEvent(DISMISS_MEDIA_SETTING_PANEL, this);
        eventCenter.subscribeUIEvent(SHOW_APPLY_LIST, this);
        eventCenter.subscribeUIEvent(DISMISS_APPLY_LIST, this);
        eventCenter.subscribeUIEvent(SHOW_EXIT_ROOM_VIEW, this);
        eventCenter.subscribeUIEvent(DISMISS_EXIT_ROOM_VIEW, this);
        eventCenter.subscribeUIEvent(SHOW_OWNER_EXIT_ROOM_PANEL, this);
        eventCenter.subscribeUIEvent(DISMISS_OWNER_EXIT_ROOM_PANEL, this);
        eventCenter.subscribeUIEvent(SHOW_INVITE_PANEL, this);
        eventCenter.subscribeUIEvent(DISMISS_INVITE_PANEL, this);
        eventCenter.subscribeUIEvent(SHOW_INVITE_PANEL_SECOND, this);
        eventCenter.subscribeUIEvent(DISMISS_INVITE_PANEL_SECOND, this);
        eventCenter.subscribeUIEvent(BAR_SHOW_TIME_RECOUNT, this);

        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OFF_LINE, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeUIEvent(SHOW_MEETING_INFO, this);
        eventCenter.unsubscribeUIEvent(DISMISS_MEETING_INFO, this);
        eventCenter.unsubscribeUIEvent(SHOW_USER_LIST, this);
        eventCenter.unsubscribeUIEvent(DISMISS_USER_LIST, this);
        eventCenter.unsubscribeUIEvent(SHOW_QRCODE_VIEW, this);
        eventCenter.unsubscribeUIEvent(DISMISS_QRCODE_VIEW, this);
        eventCenter.unsubscribeUIEvent(SHOW_MEDIA_SETTING_PANEL, this);
        eventCenter.unsubscribeUIEvent(DISMISS_MEDIA_SETTING_PANEL, this);
        eventCenter.unsubscribeUIEvent(SHOW_APPLY_LIST, this);
        eventCenter.unsubscribeUIEvent(DISMISS_APPLY_LIST, this);
        eventCenter.unsubscribeUIEvent(SHOW_EXIT_ROOM_VIEW, this);
        eventCenter.unsubscribeUIEvent(DISMISS_EXIT_ROOM_VIEW, this);
        eventCenter.unsubscribeUIEvent(SHOW_OWNER_EXIT_ROOM_PANEL, this);
        eventCenter.unsubscribeUIEvent(DISMISS_OWNER_EXIT_ROOM_PANEL, this);
        eventCenter.unsubscribeUIEvent(SHOW_INVITE_PANEL, this);
        eventCenter.unsubscribeUIEvent(DISMISS_INVITE_PANEL, this);
        eventCenter.unsubscribeUIEvent(SHOW_INVITE_PANEL_SECOND, this);
        eventCenter.unsubscribeUIEvent(DISMISS_INVITE_PANEL_SECOND, this);
        eventCenter.unsubscribeUIEvent(BAR_SHOW_TIME_RECOUNT, this);

        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.KICKED_OFF_LINE, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
    }

    public boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    public void responseRequest(TUIRoomDefine.RequestAction requestAction, String requestId, boolean agree) {
        RoomEngineManager.sharedInstance().responseRemoteRequest(requestAction, requestId, agree, null);
    }

    public void setCameraResolutionMode(Configuration configuration) {
        RoomEngineManager.sharedInstance().setCameraResolutionMode(configuration.orientation == ORIENTATION_PORTRAIT);
    }

    public UserModel getUserModel() {
        return mRoomStore.userModel;
    }

    public void notifyConfigChange(Configuration configuration) {
        Map<String, Object> params = new HashMap<>();
        params.put(RoomEventConstant.KEY_CONFIGURATION, configuration);
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, params);
    }

    private void onCameraMuted(boolean muted) {
        mRoomMainView.onCameraMuted(muted);
    }

    private void onMicrophoneMuted(boolean muted) {
        mRoomMainView.onMicrophoneMuted(muted);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        handleEventOfShowTimeRecount(key);
        handleEventOfMediaSettings(key);
        handleEventOfMeetingInfo(key);
        handleEventOfUserList(key);
        handleEventOfOwnerExitRoom(key);
        handleEventOfUserExitRoom(key);
        handleEventOfApplyList(key);
        handleEventOfInvite(key);
        handleEventOfInviteSecond(key);
    }

    private void handleEventOfShowTimeRecount(String key) {
        if (TextUtils.equals(key, BAR_SHOW_TIME_RECOUNT)) {
            mRoomMainView.recountBarShowTime();
        }
    }

    private void handleEventOfMediaSettings(String key) {
        if (TextUtils.equals(key, DISMISS_MEDIA_SETTING_PANEL)) {
            mIsFirstPanelShowed = false;
            return;
        }
        if (mIsFirstPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_MEDIA_SETTING_PANEL)) {
            mRoomMainView.showMediaSettingsPanel();
            mIsFirstPanelShowed = true;
        }
    }

    private void handleEventOfMeetingInfo(String key) {
        if (TextUtils.equals(key, DISMISS_MEETING_INFO)) {
            mIsFirstPanelShowed = false;
            return;
        }
        if (mIsFirstPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_MEETING_INFO)) {
            mRoomMainView.showRoomInfo();
            mIsFirstPanelShowed = true;
        }
    }

    private void handleEventOfUserList(String key) {
        if (TextUtils.equals(key, DISMISS_USER_LIST)) {
            mIsFirstPanelShowed = false;
            return;
        }
        if (mIsFirstPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_USER_LIST)) {
            mRoomMainView.showUserList();
            mIsFirstPanelShowed = true;
        }
    }

    private void handleEventOfOwnerExitRoom(String key) {
        if (TextUtils.equals(key, DISMISS_OWNER_EXIT_ROOM_PANEL)) {
            mIsSecondPanelShowed = false;
            return;
        }
        if (mIsSecondPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_OWNER_EXIT_ROOM_PANEL)) {
            mRoomMainView.showTransferMasterView();
            mIsSecondPanelShowed = true;
        }
    }

    private void handleEventOfUserExitRoom(String key) {
        if (TextUtils.equals(key, DISMISS_EXIT_ROOM_VIEW)) {
            mIsFirstPanelShowed = false;
            return;
        }
        if (mIsFirstPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_EXIT_ROOM_VIEW)) {
            mRoomMainView.showExitRoomDialog();
            mIsFirstPanelShowed = true;
        }
    }

    private void handleEventOfApplyList(String key) {
        if (TextUtils.equals(key, DISMISS_APPLY_LIST)) {
            mIsFirstPanelShowed = false;
            return;
        }
        if (mIsFirstPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_APPLY_LIST)) {
            mRoomMainView.showApplyList();
            mIsFirstPanelShowed = true;
        }
    }

    private void handleEventOfInvite(String key) {
        if (TextUtils.equals(key, DISMISS_INVITE_PANEL)) {
            mIsFirstPanelShowed = false;
            return;
        }
        if (mIsFirstPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_INVITE_PANEL)) {
            mRoomMainView.showMemberInvitePanel();
            mIsFirstPanelShowed = true;
        }
    }

    private void handleEventOfInviteSecond(String key) {
        if (TextUtils.equals(key, DISMISS_INVITE_PANEL_SECOND)) {
            mIsSecondPanelShowed = false;
            return;
        }
        if (mIsSecondPanelShowed) {
            return;
        }
        if (TextUtils.equals(key, SHOW_INVITE_PANEL_SECOND)) {
            mRoomMainView.showMemberInvitePanel();
            mIsSecondPanelShowed = true;
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
                mRoomMainView.showExitRoomConfirmDialog(mContext.getString(R.string.tuiroomkit_kicked_by_master));
                break;
            case KICKED_OFF_LINE:
                mRoomMainView.showKickedOffLineDialog();
                break;
            case USER_CAMERA_STATE_CHANGED:
                onUserCameraStateChanged(params);
                break;
            case USER_MIC_STATE_CHANGED:
                onUserMicStateChanged(params);
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

            case LOCAL_SCREEN_STATE_CHANGED:
                onScreenShareStateChanged();
                break;

            default:
                break;
        }
    }

    private void onRoomDisMissed() {
        ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_end_room));
        if (isOwner()) {
            showDestroyDialog();
        } else {
            mRoomMainView.showExitRoomConfirmDialog(mContext.getString(R.string.tuiroomkit_room_room_destroyed));
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

    private void onUserCameraStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity cameraUser = mRoomStore.allUserList.get(position);
        TUIRoomDefine.ChangeReason changeReason = (TUIRoomDefine.ChangeReason) params.get(RoomEventConstant.KEY_REASON);
        if (TextUtils.equals(cameraUser.getUserId(), TUILogin.getUserId())
                && TUIRoomDefine.ChangeReason.BY_ADMIN == changeReason) {
            onCameraMuted(!cameraUser.isHasVideoStream());
        }
    }

    private void onUserMicStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity micUser = mRoomStore.allUserList.get(position);
        TUIRoomDefine.ChangeReason changeReason = (TUIRoomDefine.ChangeReason) params.get(RoomEventConstant.KEY_REASON);
        if (TextUtils.equals(micUser.getUserId(), TUILogin.getUserId())
                && TUIRoomDefine.ChangeReason.BY_ADMIN == changeReason) {
            onMicrophoneMuted(!micUser.isHasAudioStream());
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
        ToastUtil.toastShortMessageCenter(mContext.getString(stringResId));

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
        ToastUtil.toastShortMessageCenter(mContext.getString(resId));

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
            mRoomMainView.showSingleConfirmDialog(mContext.getString(R.string.tuiroomkit_have_become_master));
        }
    }
}
