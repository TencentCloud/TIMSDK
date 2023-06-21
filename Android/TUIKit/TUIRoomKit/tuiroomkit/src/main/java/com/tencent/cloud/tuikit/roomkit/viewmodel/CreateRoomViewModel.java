package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.UserModel;
import com.tencent.cloud.tuikit.roomkit.utils.UserModelManager;
import com.tencent.cloud.tuikit.roomkit.view.component.CreateRoomView;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SwitchSettingItem;

import java.util.ArrayList;
import java.util.Map;

public class CreateRoomViewModel implements RoomEventCenter.RoomKitUIEventResponder {
    private Context        mContext;
    private CreateRoomView mCreateRoomView;
    private RoomStore      mRoomStore;

    public CreateRoomViewModel(Context context, CreateRoomView createRoomView) {
        mContext = context;
        mCreateRoomView = createRoomView;
        mRoomStore = RoomEngineManager.sharedInstance(mContext).getRoomStore();
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.ROOM_TYPE_CHANGE, this);
    }

    public void destroy() {
        RoomEventCenter.getInstance().unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.ROOM_TYPE_CHANGE, this);
    }

    public String getRoomId(String userId) {
        return String.valueOf((userId + "_room_kit").hashCode() & 0x3B9AC9FF);
    }

    public void createRoom(String roomId) {
        UserModel userModel = UserModelManager.getInstance().getUserModel();
        RoomInfo roomInfo = new RoomInfo();
        roomInfo.roomId = roomId;
        roomInfo.owner = userModel.userId;
        roomInfo.name = userModel.userName + mContext.getString(R.string.tuiroomkit_meeting_title);
        roomInfo.isOpenCamera = mRoomStore.roomInfo.isOpenCamera;
        roomInfo.isOpenMicrophone = mRoomStore.roomInfo.isOpenMicrophone;
        roomInfo.isUseSpeaker = mRoomStore.roomInfo.isUseSpeaker;
        roomInfo.isMicrophoneDisableForAllUser = false;
        roomInfo.isCameraDisableForAllUser = false;
        roomInfo.isMessageDisableForAllUser = false;
        roomInfo.speechMode = mRoomStore.roomInfo.speechMode;
        TUIRoomKit tuiRoomKit = TUIRoomKit.sharedInstance(mContext);
        tuiRoomKit.createRoom(roomInfo, TUIRoomKit.RoomScene.MEETING);
    }

    public void finishActivity() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_CREATE_ROOM, null);
    }

    public ArrayList<SwitchSettingItem> createSwitchSettingItemList() {
        BaseSettingItem.ItemText audioItemText = new BaseSettingItem
                .ItemText(mContext.getString(R.string.tuiroomkit_turn_on_microphone), "");
        SwitchSettingItem audioItem = new SwitchSettingItem(mContext, audioItemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mRoomStore.roomInfo.isOpenMicrophone = isChecked;
                    }
                }).setCheck(mRoomStore.roomInfo.isOpenMicrophone);
        ArrayList<SwitchSettingItem> settingItemList = new ArrayList<>();
        settingItemList.add(audioItem);

        BaseSettingItem.ItemText speakerItemText = new BaseSettingItem
                .ItemText(mContext.getString(R.string.tuiroomkit_turn_on_speaker), "");
        SwitchSettingItem speakerItem = new SwitchSettingItem(mContext, speakerItemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mRoomStore.roomInfo.isUseSpeaker = isChecked;
                    }
                }).setCheck(mRoomStore.roomInfo.isUseSpeaker);
        settingItemList.add(speakerItem);

        BaseSettingItem.ItemText videoItemText =
                new BaseSettingItem.ItemText(mContext.getString(R.string.tuiroomkit_turn_on_camera), "");
        SwitchSettingItem videoItem = new SwitchSettingItem(mContext, videoItemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mRoomStore.roomInfo.isOpenCamera = isChecked;
                    }
                }).setCheck(mRoomStore.roomInfo.isOpenCamera);
        settingItemList.add(videoItem);
        return settingItemList;
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.ROOM_TYPE_CHANGE.equals(key)) {
            if (params == null) {
                return;
            }
            TUIRoomDefine.SpeechMode speechMode = (TUIRoomDefine.SpeechMode)
                    params.get(RoomEventConstant.KEY_IS_FREE_SPEECH);
            mRoomStore.roomInfo.speechMode = speechMode;
            int resId = TUIRoomDefine.SpeechMode.FREE_TO_SPEAK.equals(speechMode)
                    ? R.string.tuiroomkit_room_free_speech
                    : R.string.tuiroomkit_room_raise_hand;
            mCreateRoomView.setRoomTypeText(mContext.getString(resId));
        }
    }
}
