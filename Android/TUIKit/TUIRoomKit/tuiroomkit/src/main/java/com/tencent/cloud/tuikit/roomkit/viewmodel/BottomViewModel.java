package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.BAR_SHOW_TIME_RECOUNT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_MEDIA_SETTING_PANEL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomItemData;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomSelectItemData;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.BottomNavigationBar.BottomView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Chat.ChatActivity;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.MediaSettings.MediaSettingPanel;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BottomViewModel implements RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "BottomMainViewModel";
    private static final int SEAT_INDEX   = -1;
    private static final int REQ_TIME_OUT = 0;

    private Context              mContext;
    private BottomView           mBottomView;
    private RoomStore            mRoomStore;
    private List<BottomItemData> mItemDataList;

    public BottomViewModel(Context context, BottomView bottomView) {
        mContext = context;
        mBottomView = bottomView;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        mItemDataList = new ArrayList<>();
        subscribeEngineEvent();
    }

    private void subscribeEngineEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
    }

    public void destroy() {
        unSubscribeEngineEvent();
        mBottomView = null;
    }

    public void unSubscribeEngineEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
    }

    public List<BottomItemData> getItemDataList() {
        return mItemDataList;
    }

    public void initMainData() {
        List<BottomItemData> itemDataList = createMainItemData();
        for (int i = 0; i < itemDataList.size(); i++) {
            addItem(i, itemDataList.get(i));
        }
        mBottomView.updateUserListText(mRoomStore.getTotalUserCount());
    }

    private List<BottomItemData> createMainItemData() {
        List<BottomItemData> itemDataList = new ArrayList<>();
        itemDataList.add(createUserListItem());
        itemDataList.add(createMicItem());
        itemDataList.add(createCameraItem());
        if (isTakeSeatSpeechMode()) {
            BottomItemData itemData = isOwner() ? createApplyListItem() : mRoomStore.userModel.isOnSeat()
                    ? createGetOffStageItem() : createRaiseHandItem();
            itemDataList.add(itemData);
        }
        itemDataList.add(createShareItem());
        if (!isTakeSeatSpeechMode()) {
            itemDataList.add(createChatItem());
        }
        return itemDataList;
    }

    private BottomItemData createChatItem() {
        BottomItemData chatItemData = new BottomItemData();
        chatItemData.setType(BottomItemData.Type.CHAT);
        chatItemData.setEnable(true);
        chatItemData.setIconId(R.drawable.tuiroomkit_ic_chat);
        chatItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        chatItemData.setName(mContext.getString(R.string.tuiroomkit_item_chat));
        chatItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
                showChatView();
            }
        });
        return chatItemData;
    }


    private BottomItemData createShareItem() {
        BottomItemData shareItemData = new BottomItemData();
        shareItemData.setType(BottomItemData.Type.SHARE);
        shareItemData.setEnable(true);
        shareItemData.setIconId(R.drawable.tuiroomkit_ic_share);
        shareItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        shareItemData.setName(mContext.getString(R.string.tuiroomkit_title_sharing));
        BottomSelectItemData shareSelectItemData = new BottomSelectItemData();
        shareSelectItemData.setSelected(RoomEngineManager.sharedInstance().getRoomStore().videoModel.isScreenSharing());
        shareSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_tv_stop_screen_capture));
        shareSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_title_sharing));
        shareSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_sharing);
        shareSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_share);
        shareSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
                if (isNotOnSeatInSeatMode()) {
                    return;
                }
                if (RoomEngineManager.sharedInstance().getRoomStore().videoModel.isScreenSharing()) {
                    mBottomView.stopScreenShareDialog();
                } else {
                    showScreenShareTip();
                }
            }
        });
        shareItemData.setSelectItemData(shareSelectItemData);
        return shareItemData;
    }

    private void showScreenShareTip() {
        Map map = new HashMap();
        map.put(TUIConstants.Privacy.PARAM_DIALOG_CONTEXT, mContext);
        Object obj =
                TUICore.callService(TUIConstants.Service.TUI_PRIVACY, TUIConstants.Privacy.METHOD_SHOW_SCREEN_SHARE_TIP,
                        map, new TUIServiceCallback() {
                            @Override
                            public void onServiceCallback(int errorCode, String errorMessage, Bundle bundle) {
                                if (errorCode == TUIConstants.Privacy.RESULT_CONTINUE) {
                                    startScreenShare();
                                }
                            }
                        });
        if (obj == null) {
            startScreenShare();
        }
    }

    private void startScreenShare() {
        if (RoomEngineManager.sharedInstance().getRoomStore().hasScreenSharingInRoom()) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_other_user_in_screen_sharing));
            return;
        }
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            DrawOverlaysPermissionUtil.requestDrawOverlays();
            return;
        }
        RoomEngineManager.sharedInstance().startScreenCapture();
    }

    private BottomItemData createMicItem() {
        BottomItemData micItemData = new BottomItemData();
        micItemData.setType(BottomItemData.Type.AUDIO);
        if (isOwner()) {
            micItemData.setEnable(true);
        } else if (isTakeSeatSpeechMode()) {
            micItemData.setEnable(false);
        } else {
            micItemData.setEnable(!mRoomStore.roomInfo.isMicrophoneDisableForAllUser);
        }
        micItemData.setIconId(R.drawable.tuiroomkit_ic_mic_off);
        micItemData.setDisableIconId(R.drawable.tuiroomkit_ic_mic_off);
        micItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        micItemData.setName(mContext.getString(R.string.tuiroomkit_item_open_microphone));
        BottomSelectItemData micSelectItemData = new BottomSelectItemData();
        micSelectItemData.setSelected(mRoomStore.audioModel.isHasAudioStream());
        micSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_item_close_microphone));
        micSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_item_open_microphone));
        micSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_mic_on);
        micSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_mic_off);
        micSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                enableMicrophone(isSelected);
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        micItemData.setSelectItemData(micSelectItemData);
        return micItemData;
    }

    private BottomItemData createCameraItem() {
        BottomItemData cameraItemData = new BottomItemData();
        cameraItemData.setType(BottomItemData.Type.VIDEO);
        if (isOwner()) {
            cameraItemData.setEnable(true);
        } else if (isTakeSeatSpeechMode()) {
            cameraItemData.setEnable(false);
        } else {
            cameraItemData.setEnable(!mRoomStore.roomInfo.isCameraDisableForAllUser);
        }
        cameraItemData.setIconId(R.drawable.tuiroomkit_ic_camera_off);
        cameraItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        cameraItemData.setDisableIconId(R.drawable.tuiroomkit_ic_camera_off);
        cameraItemData.setName(mContext.getString(R.string.tuiroomkit_item_open_camera));
        BottomSelectItemData camaraSelectItemData = new BottomSelectItemData();
        camaraSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_item_close_camera));
        camaraSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_item_open_camera));
        camaraSelectItemData.setSelected(mRoomStore.videoModel.isCameraOpened());
        camaraSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_camera_on);
        camaraSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_camera_off);
        camaraSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
                if (isNotOnSeatInSeatMode()) {
                    return;
                }
                enableCamera(isSelected);
            }
        });
        cameraItemData.setSelectItemData(camaraSelectItemData);
        return cameraItemData;
    }

    private BottomItemData createRaiseHandItem() {
        BottomItemData raiseHandItemData = new BottomItemData();
        raiseHandItemData.setType(BottomItemData.Type.RAISE_HAND);
        raiseHandItemData.setIconId(R.drawable.tuiroomkit_ic_raise_hand);
        raiseHandItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        raiseHandItemData.setName(mContext.getString(R.string.tuiroomkit_raise_hand));
        raiseHandItemData.setEnable(true);
        BottomSelectItemData raiseHandSelectItemData = new BottomSelectItemData();
        raiseHandSelectItemData.setSelected(!RoomEngineManager.sharedInstance().getRoomStore().userModel.isOffSeat());
        raiseHandSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_hands_down));
        raiseHandSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_raise_hand));
        raiseHandSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_raise_hand);
        raiseHandSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_raise_hand);
        raiseHandSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                updateRaiseHandButton(isSelected);
                if (isSelected) {
                    raiseHand();
                } else {
                    downHand();
                }
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        raiseHandItemData.setSelectItemData(raiseHandSelectItemData);
        return raiseHandItemData;
    }

    private BottomItemData createGetOffStageItem() {
        BottomItemData getOffStageItemData = new BottomItemData();
        getOffStageItemData.setType(BottomItemData.Type.OFF_STAGE);
        getOffStageItemData.setIconId(R.drawable.tuiroomkit_ic_off_stage);
        getOffStageItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        getOffStageItemData.setName(mContext.getString(R.string.tuiroomkit_leave_stage));
        getOffStageItemData.setEnable(true);
        getOffStageItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                getOffStage();
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return getOffStageItemData;
    }

    private BottomItemData createApplyListItem() {
        BottomItemData applyListItemData = new BottomItemData();
        applyListItemData.setType(BottomItemData.Type.APPLY);
        applyListItemData.setEnable(true);
        applyListItemData.setIconId(R.drawable.tuiroomkit_ic_raise_hand);
        applyListItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        applyListItemData.setName(mContext.getString(R.string.tuiroomkit_raise_hand_applies));
        applyListItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST, null);
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return applyListItemData;
    }

    private BottomItemData createUserListItem() {
        BottomItemData userListItemData = new BottomItemData();
        userListItemData.setType(BottomItemData.Type.MEMBER_LIST);
        userListItemData.setEnable(true);
        userListItemData.setIconId(R.drawable.tuiroomkit_ic_member);
        userListItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        userListItemData.setName(mContext.getString(R.string.tuiroomkit_item_member));
        userListItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST, null);
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return userListItemData;
    }

    public void showChatView() {
        Log.d(TAG, "showChatView");
        Intent intent = new Intent(mContext, ChatActivity.class);
        IntentUtils.safeStartActivity(mContext, intent);
    }

    public boolean isTakeSeatSpeechMode() {
        return TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT.equals(mRoomStore.roomInfo.speechMode);
    }

    private void addItem(int index, BottomItemData itemData) {
        if (index < 0 || index > mItemDataList.size()) {
            return;
        }
        if (itemData == null) {
            return;
        }
        mItemDataList.add(index, itemData);
        mBottomView.addItem(index, itemData);
    }


    public int indexOf(BottomItemData.Type type) {
        BottomItemData itemData = findItemData(type);
        if (itemData == null) {
            return -1;
        }
        return mItemDataList.indexOf(itemData);
    }

    public BottomItemData findItemData(BottomItemData.Type type) {
        if (mItemDataList == null) {
            return null;
        }
        for (BottomItemData bottomItemData : mItemDataList) {
            if (bottomItemData.getType() == type) {
                return bottomItemData;
            }
        }
        return null;
    }

    private void updateRaiseHandButton(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.RAISE_HAND, isSelected);
    }

    private void enableMicrophone(boolean enable) {
        if (enable) {
            RoomEngineManager.sharedInstance().enableLocalAudio();
        } else {
            RoomEngineManager.sharedInstance().disableLocalAudio();
        }
    }

    private boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    private void updateAudioItemSelectStatus(boolean isSelected) {
        if (isSelected) {
            updateAudioItemEnableStatus(true);
        } else if (mRoomStore.roomInfo.isMicrophoneDisableForAllUser) {
            updateAudioItemEnableStatus(false);
        }
        mBottomView.updateItemSelectStatus(BottomItemData.Type.AUDIO, isSelected);
    }

    private void updateAudioItemEnableStatus(boolean enable) {
        mBottomView.updateItemEnableStatus(BottomItemData.Type.AUDIO, enable);
    }

    private void enableCamera(boolean enable) {
        if (enable) {
            openCamera();
        } else {
            RoomEngineManager.sharedInstance().closeLocalCamera();
        }
    }

    private boolean isNotOnSeatInSeatMode() {
        if (isTakeSeatSpeechMode() && !mRoomStore.userModel.isOnSeat()) {
            ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_please_raise_hand));
            return true;
        }
        return false;
    }

    private void openCamera() {
        if (mRoomStore.roomInfo.isCameraDisableForAllUser && !isOwner()) {
            ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_can_not_open_camera));
            return;
        }
        RoomEngineManager.sharedInstance().openLocalCamera(null);
    }

    private void updateScreenShareItemSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.SHARE, isSelected);
    }

    private void updateVideoButtonSelectStatus(boolean isSelected) {
        if (isSelected) {
            updateVideoItemEnableStatus(true);
        } else if (mRoomStore.roomInfo.isCameraDisableForAllUser) {
            updateVideoItemEnableStatus(false);
        }
        mBottomView.updateItemSelectStatus(BottomItemData.Type.VIDEO, isSelected);
    }

    private void updateVideoItemEnableStatus(boolean enable) {
        mBottomView.updateItemEnableStatus(BottomItemData.Type.VIDEO, enable);
    }

    private void raiseHand() {
        ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_raised_hand));
        RoomEngineManager.sharedInstance().takeSeat(SEAT_INDEX, REQ_TIME_OUT, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                if (mBottomView == null) {
                    return;
                }
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createGetOffStageItem());
                ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_take_seat_request_accepted));
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                if (mBottomView == null) {
                    return;
                }
                updateRaiseHandButton(false);
                ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_take_seat_request_rejected));
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                if (mBottomView == null) {
                    return;
                }
                updateRaiseHandButton(false);
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                if (mBottomView == null) {
                    return;
                }
                updateRaiseHandButton(false);
            }

            @Override
            public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                if (mBottomView == null) {
                    return;
                }
                updateRaiseHandButton(false);
            }
        });
    }

    private void downHand() {
        if (TextUtils.isEmpty(mRoomStore.userModel.takeSeatRequestId)) {
            return;
        }
        ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_hands_down));
        RoomEngineManager.sharedInstance().cancelRequest(mRoomStore.userModel.takeSeatRequestId, null);
    }

    private void getOffStage() {
        RoomEngineManager.sharedInstance().leaveSeat(null);
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case LOCAL_CAMERA_STATE_CHANGED:
                updateVideoButtonSelectStatus(mRoomStore.videoModel.isCameraOpened());
                break;

            case LOCAL_SCREEN_STATE_CHANGED:
                updateScreenShareItemSelectStatus(mRoomStore.videoModel.isScreenSharing());
                break;

            case LOCAL_AUDIO_STATE_CHANGED:
                updateAudioItemSelectStatus(mRoomStore.audioModel.isHasAudioStream());
                break;

            case USER_ROLE_CHANGED:
                onUserRoleChanged(params);
                break;
            case ALL_USER_CAMERA_DISABLE_CHANGED:
                allUserCameraDisableChanged(params);
                break;
            case ALL_USER_MICROPHONE_DISABLE_CHANGED:
                allUserMicrophoneDisableChanged(params);
                break;

            case REMOTE_USER_TAKE_SEAT:
                onRemoteUserTakeSeat(params);
                break;

            case REMOTE_USER_LEAVE_SEAT:
                onRemoteUserLeaveSeat(params);
                break;
            case REMOTE_USER_ENTER_ROOM:
            case REMOTE_USER_LEAVE_ROOM:
                mBottomView.updateUserListText(mRoomStore.getTotalUserCount());
                break;
            default:
                break;
        }
    }

    private void onUserRoleChanged(Map<String, Object> params) {
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

        if (isTakeSeatSpeechMode()) {
            boolean isOwner = TUIRoomDefine.Role.ROOM_OWNER.equals(role);
            updateBottomView(isOwner);
        }
    }

    private void allUserCameraDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (isOwner()) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        boolean isDisable = (Boolean) params.get(RoomEventConstant.KEY_IS_DISABLE);
        updateVideoItemEnableStatus(!isDisable && mRoomStore.userModel.isOnSeat());
    }

    private void allUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (isOwner()) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        boolean isDisable = (Boolean) params.get(RoomEventConstant.KEY_IS_DISABLE);
        updateAudioItemEnableStatus(!isDisable && mRoomStore.userModel.isOnSeat());
    }

    private void updateBottomView(boolean isOwner) {
        if (isOwner) {
            BottomItemData.Type type = mRoomStore.userModel.isOnSeat()
                    ? BottomItemData.Type.OFF_STAGE
                    : BottomItemData.Type.RAISE_HAND;
            mBottomView.replaceItem(type, createApplyListItem());
        } else {
            BottomItemData itemData = mRoomStore.userModel.isOnSeat()
                    ? createGetOffStageItem()
                    : createRaiseHandItem();
            mBottomView.replaceItem(BottomItemData.Type.APPLY, itemData);
        }
    }

    private void onRemoteUserTakeSeat(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (TextUtils.equals(mRoomStore.allUserList.get(position).getUserId(), TUILogin.getUserId())) {
            updateAudioItemEnableStatus(!mRoomStore.roomInfo.isMicrophoneDisableForAllUser);
            updateVideoItemEnableStatus(!mRoomStore.roomInfo.isCameraDisableForAllUser);
            mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createGetOffStageItem());
        }
    }

    private void onRemoteUserLeaveSeat(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (TextUtils.equals(mRoomStore.allUserList.get(position).getUserId(), TUILogin.getUserId())) {
            updateAudioItemEnableStatus(false);
            updateVideoItemEnableStatus(false);
            mBottomView.replaceItem(BottomItemData.Type.OFF_STAGE, createRaiseHandItem());
        }
    }

    public void initExtensionItemData() {
        List<BottomItemData> itemDataList = createExtensionItemData();
        for (int i = 0; i < itemDataList.size(); i++) {
            addItem(i, itemDataList.get(i));
        }
    }

    private List<BottomItemData> createExtensionItemData() {
        List<BottomItemData> itemDataList = new ArrayList<>();
        if (isTakeSeatSpeechMode()) {
            itemDataList.add(createChatItem());
        }
        itemDataList.add(createInviteItem());
        itemDataList.add(createFloatItem());
        if (createBeautyItem().isEnable()) {
            itemDataList.add(createBeautyItem());
        }
        if (createRecordItem().isEnable()) {
            itemDataList.add(createRecordItem());
        }
        itemDataList.add(createSettingItem());
        return itemDataList;
    }

    private BottomItemData createInviteItem() {
        BottomItemData inviteItemData = new BottomItemData();
        inviteItemData.setType(BottomItemData.Type.INVITE);
        inviteItemData.setEnable(true);
        inviteItemData.setIconId(R.drawable.tuiroomkit_ic_invite);
        inviteItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        inviteItemData.setName(mContext.getString(R.string.tuiroomkit_item_invite));
        inviteItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(
                        RoomEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL, null);
            }
        });
        return inviteItemData;
    }

    private BottomItemData createFloatItem() {
        BottomItemData floatItemData = new BottomItemData();
        floatItemData.setType(BottomItemData.Type.MINIMIZE);
        floatItemData.setEnable(true);
        floatItemData.setIconId(R.drawable.tuiroomkit_ic_minimize);
        floatItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        floatItemData.setName(mContext.getString(R.string.tuiroomkit_item_float));
        floatItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
                    DrawOverlaysPermissionUtil.requestDrawOverlays();
                    return;
                }
                RoomEngineManager.sharedInstance(mContext).enterFloatWindow();
            }
        });
        return floatItemData;
    }

    private BottomItemData createBeautyItem() {
        BottomItemData beautyItemData = new BottomItemData();
        beautyItemData.setType(BottomItemData.Type.BEAUTY);
        beautyItemData.setEnable(false);
        beautyItemData.setIconId(R.drawable.tuiroomkit_ic_beauty);
        beautyItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        beautyItemData.setName(mContext.getString(R.string.tuiroomkit_beauty));
        beautyItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {

            }
        });
        return beautyItemData;
    }

    private BottomItemData createRecordItem() {
        BottomItemData recordItemData = new BottomItemData();
        recordItemData.setType(BottomItemData.Type.RECORD);
        recordItemData.setEnable(false);
        recordItemData.setIconId(R.drawable.tuiroomkit_ic_record);
        recordItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        recordItemData.setName(mContext.getString(R.string.tuiroomkit_item_record));
        recordItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {

            }
        });
        return recordItemData;
    }

    private BottomItemData createSettingItem() {
        BottomItemData setttingItemData = new BottomItemData();
        setttingItemData.setType(BottomItemData.Type.SETTING);
        setttingItemData.setEnable(true);
        setttingItemData.setIconId(R.drawable.tuiroomkit_ic_setting);
        setttingItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        setttingItemData.setName(mContext.getString(R.string.tuiroomkit_settings));
        setttingItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(SHOW_MEDIA_SETTING_PANEL, null);
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return setttingItemData;
    }

}
