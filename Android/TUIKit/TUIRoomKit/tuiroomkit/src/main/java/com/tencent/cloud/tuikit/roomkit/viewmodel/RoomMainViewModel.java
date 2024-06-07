package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static android.content.res.Configuration.ORIENTATION_PORTRAIT;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_GENERAL_TO_MANAGER;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_MANAGER_TO_GENERAL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_TO_OWNER;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.REQUEST_RECEIVED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.BAR_SHOW_TIME_RECOUNT;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_APPLY_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_EXIT_ROOM_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_INVITE_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_INVITE_PANEL_SECOND;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MEDIA_SETTING_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MEETING_INFO;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_OWNER_EXIT_ROOM_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_QRCODE_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.ENABLE_FLOAT_CHAT;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL_SECOND;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_MEDIA_SETTING_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_MEETING_INFO;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_OWNER_EXIT_ROOM_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_ENABLE_FLOAT_CHAT;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_USER_POSITION;
import static com.tencent.qcloud.tuicore.TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED;
import static com.tencent.qcloud.tuicore.TUIConstants.TUILogin.EVENT_SUB_KEY_START_UNINIT;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.page.ConferenceMainView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.store.FloatChatStore;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class RoomMainViewModel implements ConferenceEventCenter.RoomKitUIEventResponder,
        ConferenceEventCenter.RoomEngineEventResponder, ITUINotification {
    private static final String TAG = "MeetingViewModel";

    private Context            mContext;
    private ConferenceState    mConferenceState;
    private ConferenceMainView mRoomMainView;

    private boolean mIsFirstPanelShowed  = false;
    private boolean mIsSecondPanelShowed = false;

    public RoomMainViewModel(Context context, ConferenceMainView meetingView) {
        mContext = context;
        mRoomMainView = meetingView;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();
        subscribeEvent();
    }

    public void stopScreenCapture() {
        mRoomMainView.stopScreenShare();
    }

    private void subscribeEvent() {
        TUICore.registerEvent(EVENT_IMSDK_INIT_STATE_CHANGED, EVENT_SUB_KEY_START_UNINIT, this);

        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
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
        eventCenter.subscribeUIEvent(ENABLE_FLOAT_CHAT, this);
        eventCenter.subscribeEngine(REQUEST_RECEIVED, this);
        eventCenter.subscribeEngine(LOCAL_USER_GENERAL_TO_MANAGER, this);
        eventCenter.subscribeEngine(LOCAL_USER_MANAGER_TO_GENERAL, this);
        eventCenter.subscribeEngine(LOCAL_USER_TO_OWNER, this);

        eventCenter.subscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_LINE, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.subscribeEngine(KICKED_OFF_SEAT, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        TUICore.unRegisterEvent(EVENT_IMSDK_INIT_STATE_CHANGED, EVENT_SUB_KEY_START_UNINIT, this);

        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
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
        eventCenter.unsubscribeUIEvent(ENABLE_FLOAT_CHAT, this);
        eventCenter.unsubscribeEngine(REQUEST_RECEIVED, this);
        eventCenter.unsubscribeEngine(LOCAL_USER_GENERAL_TO_MANAGER, this);
        eventCenter.unsubscribeEngine(LOCAL_USER_MANAGER_TO_GENERAL, this);
        eventCenter.unsubscribeEngine(LOCAL_USER_TO_OWNER, this);

        eventCenter.unsubscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_LINE, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(KICKED_OFF_SEAT, this);
    }

    public boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mConferenceState.userModel.getRole());
    }

    public void responseRequest(TUIRoomDefine.RequestAction requestAction, String requestId, boolean agree) {
        ConferenceController.sharedInstance().responseRemoteRequest(requestAction, requestId, agree, null);
    }

    public void setCameraResolutionMode(Configuration configuration) {
        ConferenceController.sharedInstance().setCameraResolutionMode(configuration.orientation == ORIENTATION_PORTRAIT);
    }

    public String getWaterMakText() {
        return TUILogin.getUserId() + "(" + TUILogin.getNickName() + ")";
    }

    public UserModel getUserModel() {
        return mConferenceState.userModel;
    }

    public String getRoomId() {
        return mConferenceState.roomInfo.roomId;
    }

    public boolean isFloatChatEnable() {
        return mConferenceState.getEnableFloatChat();
    }

    public UserState getUserState() {
        return ConferenceController.sharedInstance().getUserState();
    }

    public void notifyConfigChange(Configuration configuration) {
        Map<String, Object> params = new HashMap<>();
        params.put(ConferenceEventConstant.KEY_CONFIGURATION, configuration);
        ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, params);
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
        handleEventOfEnableFloatChat(key, params);
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

    public void handleEventOfEnableFloatChat(String key, Map<String, Object> params) {
        if (TextUtils.equals(key, ENABLE_FLOAT_CHAT) && params != null) {
            boolean enableFloatChat = (Boolean) params.get(KEY_ENABLE_FLOAT_CHAT);
            mRoomMainView.isShowFloatChat(enableFloatChat);
        }
    }

    private void onScreenShareStateChanged() {
        if (ConferenceController.sharedInstance().getConferenceState().videoModel.isScreenSharing()) {
            mRoomMainView.onScreenShareStarted();
        } else {
            mRoomMainView.onScreenShareStopped();
        }
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, EVENT_IMSDK_INIT_STATE_CHANGED) && TextUtils.equals(subKey,
                EVENT_SUB_KEY_START_UNINIT)) {
            mRoomMainView.showLogoutDialog();
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case ROOM_DISMISSED:
                onRoomDisMissed();
                break;
            case KICKED_OUT_OF_ROOM:
                mRoomMainView.showLeavedRoomConfirmDialog(mContext.getString(R.string.tuiroomkit_kicked_by_master));
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

            case KICKED_OFF_SEAT:
                onKickedOffSeat();
                break;

            case LOCAL_USER_GENERAL_TO_MANAGER:
                mRoomMainView.toastForGeneralToManager();
                break;

            case LOCAL_USER_MANAGER_TO_GENERAL:
                mRoomMainView.toastForManagerToGeneral();
                break;

            case LOCAL_USER_TO_OWNER:
                mRoomMainView.toastForToOwner();
                break;

            case REQUEST_RECEIVED:
                mRoomMainView.showRequestDialog(params);
                break;

            case GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM:
                mRoomMainView.showAlertUserLiveTips();
                break;

            default:
                break;
        }
    }

    private void onRoomDisMissed() {
        if (isOwner() && showRTCubeAppLegalDialog()) {
            return;
        }
        mRoomMainView.showLeavedRoomConfirmDialog(mContext.getString(R.string.tuiroomkit_room_room_destroyed));
    }

    private boolean showRTCubeAppLegalDialog() {
        boolean isShow = false;
        try {
            Class clz = Class.forName("com.tencent.liteav.privacy.util.RTCubeAppLegalUtils");
            Method method = clz.getDeclaredMethod("showRoomDestroyTips", Context.class);
            method.invoke(null, mContext);
            isShow = true;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return isShow;
        }
    }

    private void onUserCameraStateChanged(Map<String, Object> params) {
        if (params == null || !mConferenceState.userModel.isOnSeat()) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity cameraUser = mConferenceState.allUserList.get(position);
        TUIRoomDefine.ChangeReason changeReason = (TUIRoomDefine.ChangeReason) params.get(ConferenceEventConstant.KEY_REASON);
        if (TextUtils.equals(cameraUser.getUserId(), TUILogin.getUserId())
                && TUIRoomDefine.ChangeReason.BY_ADMIN == changeReason) {
            onCameraMuted(!cameraUser.isHasVideoStream());
        }
    }

    private void onUserMicStateChanged(Map<String, Object> params) {
        if (params == null || !mConferenceState.userModel.isOnSeat()) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity micUser = mConferenceState.allUserList.get(position);
        TUIRoomDefine.ChangeReason changeReason = (TUIRoomDefine.ChangeReason) params.get(ConferenceEventConstant.KEY_REASON);
        if (TextUtils.equals(micUser.getUserId(), TUILogin.getUserId())
                && TUIRoomDefine.ChangeReason.BY_ADMIN == changeReason) {
            onMicrophoneMuted(!micUser.isHasAudioStream());
        }
    }

    private void onKickedOffSeat() {
        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_tip_kicked_off_seat));
    }

    private void allUserCameraDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        boolean isDisable = (Boolean) params.get(ConferenceEventConstant.KEY_IS_DISABLE);
        int stringResId = isDisable
                ? R.string.tuiroomkit_mute_all_camera_toast
                : R.string.tuiroomkit_toast_not_mute_all_video;
        RoomToast.toastShortMessageCenter(mContext.getString(stringResId));
    }

    private void allUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        boolean isDisable = (Boolean) params.get(ConferenceEventConstant.KEY_IS_DISABLE);
        int resId = isDisable ? R.string.tuiroomkit_mute_all_mic_toast : R.string.tuiroomkit_toast_not_mute_all_audio;
        RoomToast.toastShortMessageCenter(mContext.getString(resId));
    }

    private void sendMessageForAllUserDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        mConferenceState.roomInfo.isMessageDisableForAllUser = (boolean) params
                .get(ConferenceEventConstant.KEY_IS_DISABLE);
    }

    private void onUserRoleChange(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        String userId = (String) params.get(ConferenceEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId) || !mConferenceState.userModel.userId.equals(userId)) {
            return;
        }

        TUIRoomDefine.Role role = (TUIRoomDefine.Role) params.get(ConferenceEventConstant.KEY_ROLE);
        if (role == null) {
            return;
        }

        if (TUIRoomDefine.Role.ROOM_OWNER.equals(role)) {
            mRoomMainView.showSingleConfirmDialog(mContext.getString(R.string.tuiroomkit_have_become_master));
        }
    }
}
