package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;

import com.tencent.cloud.tuikit.roomkit.model.entity.BottomItemData;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomSelectItemData;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.BottomView;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class BottomViewModel implements RoomEventCenter.RoomEngineEventResponder {
    private static final int SEAT_INDEX   = -1;
    private static final int REQ_TIME_OUT = 30;

    private TUIRoomDefine.Request mLocalRequest;
    private Context               mContext;
    private BottomView            mBottomView;
    private RoomStore             mRoomStore;
    private TUIRoomEngine         mRoomEngine;
    private List<BottomItemData>  mItemDataList;

    public BottomViewModel(Context context, BottomView bottomView) {
        mContext = context;
        mBottomView = bottomView;
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(context);
        mRoomEngine = engineManager.getRoomEngine();
        mRoomStore = engineManager.getRoomStore();
        mItemDataList = new ArrayList<>();
        subscribeEngineEvent();
    }

    private void subscribeEngineEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);
    }

    public void destroy() {
        unSubscribeEngineEvent();
    }

    public void unSubscribeEngineEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);
    }

    public List<BottomItemData> getItemDataList() {
        return mItemDataList;
    }

    public void initData() {
        List<BottomItemData> itemDataList = createItemData();
        for (int i = 0; i < itemDataList.size(); i++) {
            addItem(i, itemDataList.get(i));
        }
    }

    private List<BottomItemData> createItemData() {
        List<BottomItemData> itemDataList = new ArrayList<>();
        itemDataList.add(createExitItem());
        itemDataList.add(createMicItem());
        itemDataList.add(createCameraItem());
        if (isTakeSeatSpeechMode()) {
            BottomItemData itemData = isOwner() ? createApplyListItem() : createRaiseHandItem();
            itemDataList.add(itemData);
        }
        itemDataList.add(createUserListItem());
        itemDataList.add(createExtensionItem());
        return itemDataList;
    }

    private BottomItemData createExitItem() {
        BottomItemData exitItemData = new BottomItemData();
        exitItemData.setType(BottomItemData.Type.EXIT);
        exitItemData.setEnable(true);
        exitItemData.setIconId(R.drawable.tuiroomkit_ic_exit);
        exitItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_red);
        exitItemData.setName(mContext.getString(R.string.tuiroomkit_item_leave));
        exitItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
            }
        });
        return exitItemData;
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
        micSelectItemData.setSelected(mRoomStore.roomInfo.isOpenMicrophone);
        micSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_item_close_microphone));
        micSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_item_open_microphone));
        micSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_mic_on);
        micSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_mic_off);
        micSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                enableMicrophone(isSelected);
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
        camaraSelectItemData.setSelected(false);
        camaraSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_camera_on);
        camaraSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_camera_off);
        camaraSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
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
        raiseHandSelectItemData.setSelected(false);
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
            }
        });
        return userListItemData;
    }

    private BottomItemData createExtensionItem() {
        BottomItemData extensionItemData = new BottomItemData();
        extensionItemData.setEnable(true);
        extensionItemData.setIconId(R.drawable.tuiroomkit_ic_more);
        extensionItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        extensionItemData.setType(BottomItemData.Type.EXTENSION);
        extensionItemData.setWidth(mContext.getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_bottom_extension_width));
        extensionItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXTENSION_VIEW, null);
            }
        });
        return extensionItemData;
    }

    private boolean isTakeSeatSpeechMode() {
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

    private void removeItem(int index) {
        if (index < 0 || index > mItemDataList.size() - 1) {
            return;
        }
        BottomItemData itemData = mItemDataList.get(index);
        if (itemData == null) {
            return;
        }
        mItemDataList.remove(index);
        mBottomView.removeItem(index);
    }

    private void replaceItem(int index, BottomItemData itemData) {
        if (index < 0 || index > mItemDataList.size() - 1) {
            return;
        }
        if (itemData == null) {
            return;
        }
        removeItem(index);
        addItem(index, itemData);
    }

    private int indexOf(BottomItemData.Type type) {
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
            if (isTakeSeatSpeechMode() && !mRoomStore.userModel.isOnSeat) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_please_raise_hand));
                return;
            }
            openMicrophone();
        } else {
            mRoomEngine.closeLocalMicrophone();
            updateAudioItemSelectStatus(false);
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

    private void openMicrophone() {
        if (mRoomStore.roomInfo.isMicrophoneDisableForAllUser && !isOwner()) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_can_not_open_mic));
            return;
        }

        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                updateAudioItemSelectStatus(true);
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, null);
            }

            @Override
            public void onDenied() {
                updateAudioItemSelectStatus(false);
            }
        };

        RoomPermissionUtil.requestAudioPermission(mContext, callback);
    }

    private void enableCamera(boolean enable) {
        if (enable) {
            if (isTakeSeatSpeechMode() && !mRoomStore.userModel.isOnSeat) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_please_raise_hand));
                return;
            }
            openCamera();
        } else {
            mRoomEngine.closeLocalCamera();
        }
    }

    private void openCamera() {
        if (mRoomStore.roomInfo.isCameraDisableForAllUser && !isOwner()) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_can_not_open_camera));
            return;
        }

        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                updateVideoButtonSelectStatus(true);
                mRoomEngine.openLocalCamera(mRoomStore.videoModel.isFrontCamera, TUIRoomDefine.VideoQuality.Q_720P,
                        null);
            }

            @Override
            public void onDenied() {
                updateVideoButtonSelectStatus(false);
            }
        };

        RoomPermissionUtil.requestCameraPermission(mContext, callback);
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
        ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_toast_raised_hand));
        mLocalRequest = mRoomEngine.takeSeat(SEAT_INDEX, REQ_TIME_OUT, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                replaceItem(indexOf(BottomItemData.Type.APPLY), createGetOffStageItem());
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                updateRaiseHandButton(false);
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                updateRaiseHandButton(false);
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                updateRaiseHandButton(false);
            }

            @Override
            public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                updateRaiseHandButton(false);
            }
        });
    }

    private void downHand() {
        if (mLocalRequest == null) {
            return;
        }
        ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_toast_hands_down));
        mRoomEngine.cancelRequest(mLocalRequest.requestId, null);
        mLocalRequest = null;
    }

    private void getOffStage() {
        mRoomEngine.leaveSeat(null);
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        String userId;
        switch (event) {
            case USER_VIDEO_STATE_CHANGED:
                if (params == null) {
                    break;
                }
                userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
                if (mRoomStore.userModel.userId.equals(userId)) {
                    boolean hasVideo = (boolean) params.get(RoomEventConstant.KEY_HAS_VIDEO);
                    updateVideoButtonSelectStatus(hasVideo);
                }
                break;
            case USER_AUDIO_STATE_CHANGED:
                if (params == null) {
                    break;
                }
                userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
                if (mRoomStore.userModel.userId.equals(userId)) {
                    boolean hasAudio = (boolean) params.get(RoomEventConstant.KEY_HAS_AUDIO);
                    updateAudioItemSelectStatus(hasAudio);
                }
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
            case SEAT_LIST_CHANGED:
                onSeatListChanged(params);
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
        updateVideoItemEnableStatus(!isDisable && mRoomStore.userModel.isOnSeat);
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
        updateAudioItemEnableStatus(!isDisable && mRoomStore.userModel.isOnSeat);
    }

    private void updateBottomView(boolean isOwner) {
        if (isOwner) {
            BottomItemData.Type type = mRoomStore.userModel.isOnSeat
                    ? BottomItemData.Type.OFF_STAGE
                    : BottomItemData.Type.RAISE_HAND;
            replaceItem(indexOf(type), createApplyListItem());
        } else {
            BottomItemData itemData = mRoomStore.userModel.isOnSeat
                    ? createGetOffStageItem()
                    : createRaiseHandItem();
            replaceItem(indexOf(BottomItemData.Type.APPLY), itemData);
        }
    }

    private void onSeatListChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        List<TUIRoomDefine.SeatInfo> userSeatedList = (List<TUIRoomDefine.SeatInfo>)
                params.get(RoomEventConstant.KEY_SEATED_LIST);

        if (userSeatedList != null && !userSeatedList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info :
                    userSeatedList) {
                if (info.userId.equals(mRoomStore.userModel.userId)) {
                    updateAudioItemEnableStatus(!mRoomStore.roomInfo.isMicrophoneDisableForAllUser);
                    updateVideoItemEnableStatus(!mRoomStore.roomInfo.isCameraDisableForAllUser);
                    mRoomStore.userModel.isOnSeat = true;
                    replaceItem(indexOf(BottomItemData.Type.RAISE_HAND), createGetOffStageItem());
                    break;
                }
            }
        }

        List<TUIRoomDefine.SeatInfo> userLeftList = (List<TUIRoomDefine.SeatInfo>)
                params.get(RoomEventConstant.KEY_LEFT_LIST);
        if (userLeftList != null && !userLeftList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info :
                    userLeftList) {
                if (info.userId.equals(mRoomStore.userModel.userId)) {
                    updateAudioItemEnableStatus(false);
                    updateVideoItemEnableStatus(false);
                    replaceItem(indexOf(BottomItemData.Type.OFF_STAGE), createRaiseHandItem());
                    mRoomStore.userModel.isOnSeat = false;
                    break;
                }
            }
        }
    }

}
