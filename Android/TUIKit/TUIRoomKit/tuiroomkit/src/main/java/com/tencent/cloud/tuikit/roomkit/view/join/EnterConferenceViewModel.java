package com.tencent.cloud.tuikit.roomkit.view.join;

import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.basic.SwitchSettingItem;

import java.util.ArrayList;

public class EnterConferenceViewModel {
    private Context mContext;

    private boolean mIsOpenVideo  = true;
    private boolean mIsOpenAudio  = true;
    private boolean mIsUseSpeaker = true;

    public EnterConferenceViewModel(Context context) {
        mContext = context;
    }

    public void enterRoom(String roomId) {
        if (TextUtils.isEmpty(roomId)) {
            return;
        }
        ConferenceDefine.JoinConferenceParams params = new ConferenceDefine.JoinConferenceParams(roomId);
        params.isOpenMicrophone = mIsOpenAudio;
        params.isOpenCamera = mIsOpenVideo;
        params.isOpenSpeaker = mIsUseSpeaker;
        Intent intent = new Intent(mContext, ConferenceMainActivity.class);
        intent.putExtra(KEY_JOIN_CONFERENCE_PARAMS, params);
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
