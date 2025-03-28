package com.tencent.cloud.tuikit.roomkit.view.main.bottomnavigationbar;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.BAR_SHOW_TIME_RECOUNT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.SHOW_MEDIA_SETTING_PANEL;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.common.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.impl.ConferenceSessionImpl;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.state.entity.BottomItemData;
import com.tencent.cloud.tuikit.roomkit.state.entity.BottomSelectItemData;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.basic.TipToast;
import com.tencent.cloud.tuikit.roomkit.view.main.chat.ChatActivity;
import com.tencent.cloud.tuikit.roomkit.view.main.aisssistant.AIAssistantDialog;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.trtc.tuikit.common.system.ContextProvider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BottomViewModel implements ConferenceEventCenter.RoomEngineEventResponder {
    private static final String TAG        = "BottomMainViewModel";
    private static final int    SEAT_INDEX = -1;

    private static final int TIME_OUT_60S = 60;

    private static final int ITEM_NUM_EACH_LINE = 5;

    private Context              mContext;
    private BottomView           mBottomView;
    private ConferenceState      mConferenceState;
    private List<BottomItemData> mItemDataList;

    private int mType;

    public BottomViewModel(Context context, BottomView bottomView) {
        mContext = context;
        mBottomView = bottomView;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();
        mItemDataList = new ArrayList<>();
        subscribeEngineEvent();
    }

    private void subscribeEngineEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.subscribeEngine(ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
    }

    public void destroy() {
        unSubscribeEngineEvent();
        mBottomView = null;
    }

    private void unSubscribeEngineEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(LOCAL_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_SCREEN_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
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
            mBottomView.updateUserListText(mConferenceState.getTotalUserCount());
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
        addAIItemIfNeeded(itemDataList);
        addSettingsItemIfNeeded(itemDataList);
        return itemDataList;
    }

    private void addUserListItemIfNeeded(List<BottomItemData> itemDataList) {
        itemDataList.add(createUserListItem());
    }

    private void addMicItemIfNeeded(List<BottomItemData> itemDataList) {
        if (isSeatEnabled() && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER
                && !mConferenceState.userModel.isOnSeat()) {
            return;
        }
        itemDataList.add(createMicItem());
    }

    private void addCameraItemIfNeeded(List<BottomItemData> itemDataList) {
        if (isSeatEnabled() && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER
                && !mConferenceState.userModel.isOnSeat()) {
            return;
        }
        itemDataList.add(createCameraItem());
    }

    private void addRaiseHandItemIfNeeded(List<BottomItemData> itemDataList) {
        if (!isSeatEnabled()) {
            return;
        }
        if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
            return;
        }
        itemDataList.add(createRaiseHandItem());
    }

    private void addApplyListItemIfNeeded(List<BottomItemData> itemDataList) {
        if (!isSeatEnabled()) {
            return;
        }
        if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
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

    private void addAIItemIfNeeded(List<BottomItemData> itemDataList) {
        if (!ConferenceSessionImpl.sharedInstance().isShowAISpeechToTextButton) {
            return;
        }
        itemDataList.add(createAIItem());
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
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
                showChatView();
                MetricsStats.submit(MetricsStats.T_METRICS_CHAT_PANEL_SHOW);
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
        shareSelectItemData.setSelected(ConferenceController.sharedInstance().getConferenceState().videoModel.isScreenSharing());
        shareSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_tv_stop_screen_capture));
        shareSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_title_sharing));
        shareSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_sharing);
        shareSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_share);
        shareSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
                if (!isOnSeatInSeatMode()) {
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_please_raise_hand));
                    return;
                }
                if (ConferenceController.sharedInstance().getConferenceState().videoModel.isScreenSharing()) {
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
        if (ConferenceController.sharedInstance().getConferenceState().hasScreenSharingInRoom()) {
            TipToast.build().setDuration(Toast.LENGTH_SHORT).setMessage(
                    mContext.getString(R.string.tuiroomkit_other_user_in_screen_sharing)).setGravity(Gravity.CENTER_VERTICAL).show(mContext);
            return;
        }
        if (mConferenceState.roomState.isDisableScreen.get() && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            TipToast.build().setDuration(Toast.LENGTH_SHORT).setMessage(
                    mContext.getString(R.string.tuiroomkit_share_fail_cause_of_admin_disable)).setGravity(Gravity.CENTER_VERTICAL).show(mContext);
            return;
        }
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            DrawOverlaysPermissionUtil.requestDrawOverlays();
            return;
        }
        ConferenceController.sharedInstance().startScreenCapture();
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
        micSelectItemData.setSelected(mConferenceState.audioModel.isHasAudioStream());
        micSelectItemData.setSelectedName(mContext.getString(R.string.tuiroomkit_item_close_microphone));
        micSelectItemData.setUnSelectedName(mContext.getString(R.string.tuiroomkit_item_open_microphone));
        micSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_mic_on);
        micSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_mic_off);
        micSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                enableMicrophone(isSelected);
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
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
        camaraSelectItemData.setSelected(mConferenceState.videoModel.isCameraOpened());
        camaraSelectItemData.setSelectedIconId(R.drawable.tuiroomkit_ic_camera_on);
        camaraSelectItemData.setUnSelectedIconId(R.drawable.tuiroomkit_ic_camera_off);
        camaraSelectItemData.setOnItemSelectListener(new BottomSelectItemData.OnItemSelectListener() {
            @Override
            public void onItemSelected(boolean isSelected) {
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
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
                if (mConferenceState.userModel.isOffSeat()) {
                    raiseHand();
                } else if (mConferenceState.userModel.isOnSeat()) {
                    getOffStage();
                } else {
                    downHand();
                }
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return raiseHandItemData;
    }

    private int getRaiseHandIconId() {
        if (mConferenceState.userModel.isOffSeat()) {
            return R.drawable.tuiroomkit_icon_seat_state_off;
        }
        if (mConferenceState.userModel.isOnSeat()) {
            return R.drawable.tuiroomkit_icon_seat_state_on;
        }
        return R.drawable.tuiroomkit_icon_seat_state_applying;
    }

    private String getRaiseHandName() {
        if (mConferenceState.userModel.isOffSeat()) {
            return mContext.getString(R.string.tuiroomkit_raise_hand);
        }
        if (mConferenceState.userModel.isOnSeat()) {
            return mContext.getString(R.string.tuiroomkit_leave_stage);
        }
        return mContext.getString(R.string.tuiroomkit_hands_down);
    }


    private void raiseHand() {
        if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_raised_hand));
        }
        ConferenceController.sharedInstance().takeSeat(SEAT_INDEX, TIME_OUT_60S, new TUIRoomDefine.RequestCallback() {
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
                if (mConferenceState.userModel.isOffSeat()) {
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_apply_take_seat_time_out));
                }
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
        if (TextUtils.isEmpty(mConferenceState.userModel.takeSeatRequestId)) {
            return;
        }
        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_hands_down));
        ConferenceController.sharedInstance().cancelRequest(mConferenceState.userModel.takeSeatRequestId,
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
        if (mConferenceState.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
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
        ConferenceController.sharedInstance().leaveSeat(new TUIRoomDefine.ActionCallback() {
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
        applyListItemData.setName(mContext.getString(R.string.tuiroomkit_item_stage_control));
        applyListItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_APPLY_LIST, null);
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
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
                ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_LIST, null);
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
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
        return mConferenceState.roomInfo.isSeatEnabled;
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
            ConferenceController.sharedInstance().enableLocalAudio();
        } else {
            ConferenceController.sharedInstance().disableLocalAudio();
        }
    }

    private void updateAudioItemSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.AUDIO, isSelected);
        if (mConferenceState.roomInfo.isMicrophoneDisableForAllUser
                && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            mBottomView.updateItemEnableStatus(BottomItemData.Type.AUDIO, isSelected);
        }
    }

    private void enableCamera(boolean enable) {
        if (!enable) {
            ConferenceController.sharedInstance().closeLocalCamera();
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
        ConferenceController.sharedInstance().openLocalCamera(null);
    }

    private void updateScreenShareItemSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.SHARE, isSelected);
    }

    private void updateVideoButtonSelectStatus(boolean isSelected) {
        mBottomView.updateItemSelectStatus(BottomItemData.Type.VIDEO, isSelected);
        if (mConferenceState.roomInfo.isCameraDisableForAllUser
                && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            mBottomView.updateItemEnableStatus(BottomItemData.Type.VIDEO, isSelected);
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case LOCAL_USER_ENTER_ROOM:
                initData(mType);
                break;

            case LOCAL_CAMERA_STATE_CHANGED:
                updateVideoButtonSelectStatus(mConferenceState.videoModel.isCameraOpened());
                break;

            case LOCAL_SCREEN_STATE_CHANGED:
                updateScreenShareItemSelectStatus(mConferenceState.videoModel.isScreenSharing());
                break;

            case LOCAL_AUDIO_STATE_CHANGED:
                updateAudioItemSelectStatus(mConferenceState.audioModel.isHasAudioStream());
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
                mBottomView.updateUserListText(mConferenceState.getTotalUserCount());
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
        if (mConferenceState.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
            return;
        }
        mBottomView.updateItemEnableStatus(BottomItemData.Type.VIDEO, isShowCameraEnableEffect());
    }

    private void allUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (mConferenceState.userModel.getRole() != TUIRoomDefine.Role.GENERAL_USER) {
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
        if (TextUtils.equals(mConferenceState.allUserList.get(position).getUserId(), mConferenceState.userModel.userId)) {
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
        if (TextUtils.equals(mConferenceState.allUserList.get(position).getUserId(), mConferenceState.userModel.userId)) {
            refreshBottomList(position);
        }
    }

    private void refreshBottomList(int position) {
        UserEntity user = mConferenceState.allUserList.get(position);
        if (!TextUtils.equals(user.getUserId(), mConferenceState.userModel.userId)) {
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
                ConferenceEventCenter.getInstance().notifyUIEvent(
                        ConferenceEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL, null);
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
                if (isPictureInPictureSupported()) {
                    ConferenceController.sharedInstance().getViewState().floatWindowType = ViewState.FloatWindowType.PICTURE_IN_PICTURE;
                    ConferenceEventCenter.getInstance().notifyUIEvent(
                            ConferenceEventCenter.RoomKitUIEvent.ENTER_PIP_MODE, null);
                    return;
                }
                if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
                    DrawOverlaysPermissionUtil.requestDrawOverlays();
                    return;
                }
                ConferenceController.sharedInstance().getViewState().floatWindowType = ViewState.FloatWindowType.WINDOW_MANAGER;
                ConferenceController.sharedInstance(mContext).enterFloatWindow();
            }
        });
        return floatItemData;
    }

    private boolean isPictureInPictureSupported() {
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.O) {
            return false;
        }
        return ContextProvider.getApplicationContext().getPackageManager().hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE);
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

    private BottomItemData createAIItem() {
        BottomItemData aiItemData = new BottomItemData();
        aiItemData.setType(BottomItemData.Type.AI);
        aiItemData.setEnable(true);
        aiItemData.setIconId(R.drawable.tuiroomkit_ic_ai);
        aiItemData.setBackground(R.drawable.tuiroomkit_bg_bottom_item_black);
        aiItemData.setName(mContext.getString(R.string.tuiroomkit_ai_tool));
        aiItemData.setOnItemClickListener(new BottomItemData.OnItemClickListener() {
            @Override
            public void onItemClick() {
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
                AIAssistantDialog dialog = new AIAssistantDialog(mContext);
                dialog.show();
            }
        });
        return aiItemData;
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
                ConferenceEventCenter.getInstance().notifyUIEvent(SHOW_MEDIA_SETTING_PANEL, null);
                ConferenceEventCenter.getInstance().notifyUIEvent(BAR_SHOW_TIME_RECOUNT, null);
            }
        });
        return setttingItemData;
    }

    private boolean isShowMicEnableEffect() {
        return mConferenceState.audioModel.isHasAudioStream() || (isOnSeatInSeatMode() && isMicAvailableInAllBanAudioMode());
    }

    private boolean isShowCameraEnableEffect() {
        return mConferenceState.videoModel.isCameraOpened() || (isOnSeatInSeatMode()
                && isCameraAvailableInAllBanCameraMode());
    }

    private boolean isOnSeatInSeatMode() {
        return !mConferenceState.roomInfo.isSeatEnabled || mConferenceState.userModel.isOnSeat();
    }

    private boolean isMicAvailableInAllBanAudioMode() {
        return !(mConferenceState.roomInfo.isMicrophoneDisableForAllUser
                && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER);
    }

    private boolean isCameraAvailableInAllBanCameraMode() {
        return !(mConferenceState.roomInfo.isCameraDisableForAllUser
                && mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER);
    }
}
