package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SwitchSettingItem;

import java.util.ArrayList;

public class EnterRoomViewModel {
    private Context   mContext;
    private RoomStore mRoomStore;

    public EnterRoomViewModel(Context context) {
        mContext = context;
        mRoomStore = RoomEngineManager.sharedInstance(mContext).getRoomStore();
    }

    public void enterRoom(String roomId) {
        if (TextUtils.isEmpty(roomId)) {
            return;
        }
        RoomInfo roomInfo = new RoomInfo();
        roomInfo.roomId = roomId;
        roomInfo.isOpenCamera = mRoomStore.roomInfo.isOpenCamera;
        roomInfo.isOpenMicrophone = mRoomStore.roomInfo.isOpenMicrophone;
        roomInfo.isUseSpeaker = mRoomStore.roomInfo.isUseSpeaker;
        TUIRoomKit tuiRoomKit = TUIRoomKit.sharedInstance(mContext);
        tuiRoomKit.enterRoom(roomInfo);
    }

    public void finishActivity() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_ENTER_ROOM, null);
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
}
