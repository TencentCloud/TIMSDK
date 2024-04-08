package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED;
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

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomItemData;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomSelectItemData;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.BottomNavigationBar.BottomView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Chat.ChatActivity;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BottomViewModel implements RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG          = "BottomMainViewModel";
    private static final int    SEAT_INDEX   = -1;

    private static final int NEVER_TIME_OUT = 0;

    private static final int ITEM_NUM_EACH_LINE = 5;

    private Context              mContext;
    private BottomView           mBottomView;
    private RoomStore            mRoomStore;
    private List<BottomItemData> mItemDataList;

    private int mType;

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
        eventCenter.subscribeEngine(ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
    }

    public void destroy() {
        unSubscribeEngineEvent();
        mBottomView = null;
    }

    private void unSubscribeEngineEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.unsubscribeEngine(ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
    }

    public List<BottomItemData> getItemDataList() {
        return mItemDataList;
    }

    public void initData(int type) {
        mType = type;
        List<BottomItemData> itemDataList = createItemList();
        mItemDataList.clear();
        mBottomView.clear();
        int start = type == BottomView.MAINVIEW ? 0 : ITEM_NUM_EACH_LINE;
        int end = type == BottomView.MAINVIEW ? ITEM_NUM_EACH_LINE :
                Math.min(itemDataList.size(), ITEM_NUM_EACH_LINE * 2);
        for (int i = start; i < end; i++) {
            mItemDataList.add(itemDataList.get(i));
            mBottomView.addItem(itemDataList.get(i));
        }
        if (type == BottomView.MAINVIEW) {
            mBottomView.updateUserListText(mRoomStore.getTotalUserCount());
        }
    }

    private List<BottomItemData> createItemList() {
        List<BottomItemData> itemDataList = new ArrayList<>();
        addUserListItemIfNeeded(itemDataList);
        addMicItemIfNeeded(itemDataList);
        addCameraItemIfNeeded(itemDataList);
        addRaiseHandItemIfNeeded(itemDataList);
        addApplyListItemIfNeeded(itemDataList);
        addScreenItemIfNeeded(itemDataList);
        addChatItemIfNeeded(itemDataList);
        addInviteItemIfNeeded(itemDataList);
        addFloatItemIfNeeded(itemDataList);
        addSettingsItemIfNeeded(itemDataList);
        return itemDataList;
    }

    private void addUserListItemIfNeeded(List<BottomItemData> itemDataList) {
        itemDataList.add(createUserListItem());
    }

    private void addMicItemIfNeeded(List<BottomItemData> itemDataList) {
        if (isSeatEnabled() && mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER
                && !mRoomStore.userModel.isOnSeat()) {
            return;
        }
        itemDataList.add(createMicItem());
    }

    private void addCameraItemIfNeeded(List<BottomItemData> itemDataList) {
        if (isSeatEnabled() && mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER
                && !mRoomStore.userModel.isOnSeat()) {
            return;
        }
        itemDataList.add(createCameraItem());
    }

    private void addRaiseHandItemIfNeeded(List<BottomItemData> itemDataList) {
        if (!isSeatEnabled()) {
            return;
        }
        if (mRoomStore.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
            return;
        }
        itemDataList.add(createRaiseHandItem());
    }

    private void addApplyListItemIfNeeded(List<BottomItemData> itemDataList) {
        if (!isSeatEnabled()) {
            return;
        }
        if (mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            return;
        }
        itemDataList.add(createApplyListItem());
    }

    private void addScreenItemIfNeeded(List<BottomItemData> itemDataList) {
        itemDataList.add(createShareItem());
    }

    private void addChatItemIfNeeded(List<BottomItemData> itemDataList) {
        ITUIService service = TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME);
        if (service == null) {
            return;
        }
        itemDataList.add(createChatItem());
    }

    private void addInviteItemIfNeeded(List<BottomItemData> itemDataList) {
        itemDataList.add(createInviteItem());
    }

    private void addFloatItemIfNeeded(List<BottomItemData> itemDataList) {
        itemDataList.add(createFloatItem());
    }

    private void addSettingsItemIfNeeded(List<BottomItemData> itemDataList) {
        itemDataList.add(createSettingItem());
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
                if (!isOnSeatInSeatMode()) {
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_please_raise_hand));
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
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_other_user_in_screen_sharing));
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
        micItemData.setEnable(isShowMicEnableEffect());
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
        cameraItemData.setEnable(isShowCameraEnableEffect());
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
                enableCamera(isSelected);
            }
        });
        cameraItemData.setSelectItemData(camaraSelectItemData);
        return cameraItemData;
    }

    private BottomItemData createRaiseHandItem() {
        BottomItemData raiseHandItemData = new BottomItemData();
        raiseHandItemData.setType(BottomItemData.Type.RAISE_HAND);
        raiseHandItemData.setIconId(getRaiseHandIconId());
        raiseHandItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        raiseHandItemData.setName(getRaiseHandName());
        raiseHandItemData.setEnable(true);
        raiseHandItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                if (mRoomStore.userModel.isOffSeat()) {
                    raiseHand();
                } else if (mRoomStore.userModel.isOnSeat()) {
                    getOffStage();
                } else {
                    downHand();
                }
                RoomEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return raiseHandItemData;
    }

    private int getRaiseHandIconId() {
        if (mRoomStore.userModel.isOffSeat()) {
            return R.drawable.tuiroomkit_icon_seat_state_off;
        }
        if (mRoomStore.userModel.isOnSeat()) {
            return R.drawable.tuiroomkit_icon_seat_state_on;
        }
        return R.drawable.tuiroomkit_icon_seat_state_applying;
    }

    private String getRaiseHandName() {
        if (mRoomStore.userModel.isOffSeat()) {
            return mContext.getString(R.string.tuiroomkit_raise_hand);
        }
        if (mRoomStore.userModel.isOnSeat()) {
            return mContext.getString(R.string.tuiroomkit_leave_stage);
        }
        return mContext.getString(R.string.tuiroomkit_hands_down);
    }


    private void raiseHand() {
        if (mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_raised_hand));
        }
        RoomEngineManager.sharedInstance().takeSeat(SEAT_INDEX, NEVER_TIME_OUT, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                if (mBottomView == null) {
                    return;
                }
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
                RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_take_seat_success));
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                if (mBottomView == null) {
                    return;
                }
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
                RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_take_seat_rejected));
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                if (mBottomView == null) {
                    return;
                }
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                if (mBottomView == null) {
                    return;
                }
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
            }

            @Override
            public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                if (mBottomView == null) {
                    return;
                }
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
            }
        });
        mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
    }

    private void downHand() {
        if (TextUtils.isEmpty(mRoomStore.userModel.takeSeatRequestId)) {
            return;
        }
        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_hands_down));
        RoomEngineManager.sharedInstance().cancelRequest(mRoomStore.userModel.takeSeatRequestId,
                new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
                    }
                });
    }

    private void getOffStage() {
        if (mRoomStore.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
            leaveSeat();
            return;
        }
        AppCompatActivity activity = null;
        if (mContext instanceof AppCompatActivity) {
            activity = (AppCompatActivity) mContext;
        }
        if (activity == null) {
            return;
        }
        BaseDialogFragment.build()
                .setTitle(mContext.getString(R.string.tuiroomkit_dialog_off_seat_title))
                .setContent(mContext.getString(R.string.tuiroomkit_dialog_off_seat_content))
                .setNegativeName(mContext.getString(R.string.tuiroomkit_cancel))
                .setPositiveName(mContext.getString(R.string.tuiroomkit_leave_stage))
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        leaveSeat();
                    }
                })
                .showDialog(activity, "leaveSeat");
    }

    private void leaveSeat() {
        RoomEngineManager.sharedInstance().leaveSeat(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                mBottomView.replaceItem(BottomItemData.Type.RAISE_HAND, createRaiseHandItem());
            }
        });
    }

    private BottomItemData createApplyListItem() {
        BottomItemData applyListItemData = new BottomItemData();
        applyListItemData.setType(BottomItemData.Type.APPLY);
        applyListItemData.setEnable(true);
        applyListItemData.setIconId(R.drawable.tuiroomkit_icon_seat_apply_control);
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

    public boolean isSeatEnabled() {
        return mRoomStore.roomInfo.isSeatEnabled;
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

    private void enableMicrophone(boolean enable) {
        if (enable) {
            RoomEngineManager.sharedInstance().enableLocalAudio();
        } else {
            RoomEngineManager.sharedInstance().disableLocalAudio();
        }
    }

    private void updateAudioItemSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.AUDIO, isSelected);
        if (mRoomStore.roomInfo.isMicrophoneDisableForAllUser
                && mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            mBottomView.updateItemEnableStatus(BottomItemData.Type.AUDIO, isSelected);
        }
    }

    private void enableCamera(boolean enable) {
        if (!enable) {
            RoomEngineManager.sharedInstance().closeLocalCamera();
            return;
        }
        if (!isOnSeatInSeatMode()) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_please_raise_hand));
            return;
        }
        if (!isCameraAvailableInAllBanCameraMode()) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_can_not_open_camera));
            return;
        }
        RoomEngineManager.sharedInstance().openLocalCamera(null);
    }

    private void updateScreenShareItemSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.SHARE, isSelected);
    }

    private void updateVideoButtonSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.VIDEO, isSelected);
        if (mRoomStore.roomInfo.isCameraDisableForAllUser
                && mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            mBottomView.updateItemEnableStatus(BottomItemData.Type.VIDEO, isSelected);
        }
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
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        refreshBottomList(position);
    }

    private void allUserCameraDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (mRoomStore.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
            return;
        }
        mBottomView.updateItemEnableStatus(BottomItemData.Type.VIDEO, isShowCameraEnableEffect());
    }

    private void allUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (mRoomStore.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
            return;
        }
        mBottomView.updateItemEnableStatus(BottomItemData.Type.AUDIO, isShowMicEnableEffect());
    }

    private void onRemoteUserTakeSeat(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (TextUtils.equals(mRoomStore.allUserList.get(position).getUserId(), mRoomStore.userModel.userId)) {
            refreshBottomList(position);
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
        if (TextUtils.equals(mRoomStore.allUserList.get(position).getUserId(), mRoomStore.userModel.userId)) {
            refreshBottomList(position);
        }
    }

    private void refreshBottomList(int position) {
        UserEntity user = mRoomStore.allUserList.get(position);
        if (!TextUtils.equals(user.getUserId(), mRoomStore.userModel.userId)) {
            return;
        }
        initData(mType);
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

    private boolean isShowMicEnableEffect() {
        return mRoomStore.audioModel.isHasAudioStream() || (isOnSeatInSeatMode() && isMicAvailableInAllBanAudioMode());
    }

    private boolean isShowCameraEnableEffect() {
        return mRoomStore.videoModel.isCameraOpened() || (isOnSeatInSeatMode()
                && isCameraAvailableInAllBanCameraMode());
    }

    private boolean isOnSeatInSeatMode() {
        return !mRoomStore.roomInfo.isSeatEnabled || mRoomStore.userModel.isOnSeat();
    }

    private boolean isMicAvailableInAllBanAudioMode() {
        return !(mRoomStore.roomInfo.isMicrophoneDisableForAllUser
                && mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER);
    }

    private boolean isCameraAvailableInAllBanCameraMode() {
        return !(mRoomStore.roomInfo.isCameraDisableForAllUser
                && mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER);
    }
}
