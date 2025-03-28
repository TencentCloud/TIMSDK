package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.REQUEST_ID_REPEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_USER_MANAGEMENT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

import java.util.List;
import java.util.Map;

public class UserListViewModel
        implements ConferenceEventCenter.RoomEngineEventResponder, ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG        = "UserListViewModel";
    private static final int    SEAT_INDEX = -1;

    private static final int TIME_OUT_60_S = 60;

    private final Context         mContext;
    private final ConferenceState mConferenceState;
    private final UserListPanel   mUserListView;

    private List<UserEntity> mUserModelList;
    private boolean          mIsUserManagementPanelShowed = false;

    public UserListViewModel(Context context, UserListPanel userListView) {
        mContext = context;
        mUserListView = userListView;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();

        initUserModelList();
        subscribeEvent();
        Log.d(TAG, "UserListViewModel new : " + this);
    }

    public void updateViewInitState() {
        mUserListView.updateMuteVideoView(mConferenceState.roomInfo.isCameraDisableForAllUser);
        mUserListView.updateMuteAudioView(mConferenceState.roomInfo.isMicrophoneDisableForAllUser);
        mUserListView.updateMemberCount(mConferenceState.getTotalUserCount());
        mUserListView.updateViewForRole(mConferenceState.userModel.getRole());
    }

    private void subscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);

        eventCenter.subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, this);
        eventCenter.subscribeUIEvent(DISMISS_USER_MANAGEMENT, this);
        eventCenter.subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, this);
    }

    public void destroy() {
        unSubscribeEvent();
        Log.d(TAG, "UserListViewModel destroy : " + this);
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);

        eventCenter.unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, this);
        eventCenter.unsubscribeUIEvent(DISMISS_USER_MANAGEMENT, this);
        eventCenter.unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, this);
    }

    private void initUserModelList() {
        mUserModelList = mConferenceState.allUserList;
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case ALL_USER_CAMERA_DISABLE_CHANGED:
                onAllUserCameraDisableChanged(params);
                break;
            case ALL_USER_MICROPHONE_DISABLE_CHANGED:
                onAllUserMicrophoneDisableChanged(params);
                break;
            case USER_ROLE_CHANGED:
                onUserRoleChange(params);
                break;
            case REMOTE_USER_ENTER_ROOM:
            case REMOTE_USER_LEAVE_ROOM:
                mUserListView.updateMemberCount(mConferenceState.getTotalUserCount());
                break;
            default:
                break;
        }
    }

    private void onAllUserCameraDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        boolean isDisable = (Boolean) params.get(ConferenceEventConstant.KEY_IS_DISABLE);
        if (mConferenceState.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
            mUserListView.updateMuteVideoView(isDisable);
        }
    }

    private void onAllUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        boolean isDisable = (Boolean) params.get(ConferenceEventConstant.KEY_IS_DISABLE);
        if (mConferenceState.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
            mUserListView.updateMuteAudioView(isDisable);
        }
    }

    private void onUserRoleChange(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity changeUser = mConferenceState.allUserList.get(position);
        if (TextUtils.equals(mConferenceState.userModel.userId, changeUser.getUserId())) {
            mUserListView.updateViewForRole(mConferenceState.userModel.getRole());
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT:
                if (mIsUserManagementPanelShowed || params == null) {
                    break;
                }
                UserState.UserInfo user = (UserState.UserInfo) params.get(ConferenceEventConstant.KEY_USER_MODEL);
                if (user == null) {
                    break;
                }
                mIsUserManagementPanelShowed = true;
                ConferenceState state = ConferenceController.sharedInstance().getConferenceState();
                UserEntity userEntity = state.findUserWithCameraStream(state.allUserList, user.userId);
                mUserListView.showUserManagementView(userEntity);
                break;

            case DISMISS_USER_MANAGEMENT:
                mIsUserManagementPanelShowed = false;
                break;

            case ConferenceEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT:
                if (params == null) {
                    break;
                }
                String userId = (String) params.get(ConferenceEventConstant.KEY_USER_ID);
                if (TextUtils.isEmpty(userId)) {
                    break;
                }
                inviteUserOnSeat(userId);
                break;
            default:
                break;
        }
    }

    private void inviteUserOnSeat(final String userId) {
        UserEntity userEntity = mConferenceState.findUserWithCameraStream(mUserModelList, userId);
        if (userEntity == null) {
            return;
        }

        ConferenceController controller = ConferenceController.sharedInstance();
        if (controller.getSeatState().seatedUsers.size() >= controller.getRoomState().maxSeatCount.get()) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_stage_full_of_admin));
            return;
        }
        ConferenceController.sharedInstance()
                .takeUserOnSeatByAdmin(SEAT_INDEX, userId, TIME_OUT_60_S, new TUIRoomDefine.RequestCallback() {
                    @Override
                    public void onAccepted(String requestId, String userId) {
                        String name = TextUtils.isEmpty(userEntity.getNameCard()) ? userEntity.getUserName() : userEntity.getNameCard();
                        RoomToast.toastShortMessageCenter(
                                mContext.getString(R.string.tuiroomkit_accept_invite, name));
                    }

                    @Override
                    public void onRejected(String requestId, String userId, String message) {
                        String name = TextUtils.isEmpty(userEntity.getNameCard()) ? userEntity.getUserName() : userEntity.getNameCard();
                        RoomToast.toastShortMessageCenter(
                                mContext.getString(R.string.tuiroomkit_reject_invite, name));
                    }

                    @Override
                    public void onCancelled(String requestId, String userId) {
                        Log.e(TAG, "takeUserOnSeatByAdmin onRejected requestId : " + requestId + ",userId:" + userId);
                    }

                    @Override
                    public void onTimeout(String requestId, String userId) {
                        Log.w(TAG, "takeUserOnSeatByAdmin onTimeout userId : " + userId);
                        String name = TextUtils.isEmpty(userEntity.getNameCard()) ? userEntity.getUserName() : userEntity.getNameCard();
                        RoomToast.toastShortMessageCenter(
                                mContext.getString(R.string.tuiroomkit_invite_take_seat_time_out, name));
                    }

                    @Override
                    public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                        Log.e(TAG, "takeUserOnSeatByAdmin onError userId:" + userId + ",code : " + code + ",message:"
                                + message);
                        if (code == REQUEST_ID_REPEAT) {
                            RoomToast.toastShortMessageCenter(
                                    mContext.getString(R.string.tuiroomkit_toast_request_repeated));
                        }
                    }
                });
    }
}
