package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.activity.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.component.SwitchSettingItem;

import java.util.ArrayList;

public class EnterConferenceViewModel {
    private Context mContext;

    private boolean mIsOpenVideo  = true;
    private boolean mIsOpenAudio  = true;
    private boolean mIsUseSpeaker = true;

    public EnterConferenceViewModel(Context context) {
        mContext = context;
    }

    public void enterRoom(String roomId, TUIRoomDefine.ActionCallback callback) {
        if (TextUtils.isEmpty(roomId)) {
            return;
        }
        Intent intent = new Intent(mContext, ConferenceMainActivity.class);
        intent.putExtra("id", roomId);
        intent.putExtra("muteMicrophone", !mIsOpenAudio);
        intent.putExtra("openCamera", mIsOpenVideo);
        intent.putExtra("soundOnSpeaker", mIsUseSpeaker);
        intent.putExtra("isCreate", false);
        mContext.startActivity(intent);
    }

    public ArrayList<SwitchSettingItem> createSwitchSettingItemList() {
        BaseSettingItem.ItemText audioItemText = new BaseSettingItem
                .ItemText(mContext.getString(R.string.tuiroomkit_turn_on_audio), "");
        SwitchSettingItem audioItem = new SwitchSettingItem(mContext, audioItemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mIsOpenAudio = isChecked;
                    }
                }).setCheck(mIsOpenAudio);
        ArrayList<SwitchSettingItem> settingItemList = new ArrayList<>();
        settingItemList.add(audioItem);

        BaseSettingItem.ItemText speakerItemText = new BaseSettingItem
                .ItemText(mContext.getString(R.string.tuiroomkit_turn_on_speaker), "");
        SwitchSettingItem speakerItem = new SwitchSettingItem(mContext, speakerItemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mIsUseSpeaker = isChecked;
                    }
                }).setCheck(mIsUseSpeaker);
        settingItemList.add(speakerItem);

        BaseSettingItem.ItemText videoItemText =
                new BaseSettingItem.ItemText(mContext.getString(R.string.tuiroomkit_turn_on_video), "");
        SwitchSettingItem videoItem = new SwitchSettingItem(mContext, videoItemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mIsOpenVideo = isChecked;
                    }
                }).setCheck(mIsOpenVideo);
        settingItemList.add(videoItem);
        return settingItemList;
    }
}
