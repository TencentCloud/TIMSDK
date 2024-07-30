package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.activity.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.component.SwitchSettingItem;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

public class CreateConferenceViewModel {
    private static final String TAG = "CreateRoomViewModel";

    private Context mContext;

    private boolean mIsOpenVideo  = true;
    private boolean mIsOpenAudio  = true;
    private boolean mIsUseSpeaker = true;

    private boolean mIsSeatEnabled;

    public CreateConferenceViewModel(Context context) {
        mContext = context;
    }

    public void setSeatEnable(boolean enable) {
        mIsSeatEnabled = enable;
    }

    public void createRoom(String conferenceId, TUIRoomDefine.ActionCallback callback) {
        Intent intent = new Intent(mContext, ConferenceMainActivity.class);
        intent.putExtra("id", conferenceId);
        intent.putExtra("enableSeatControl", mIsSeatEnabled);
        intent.putExtra("muteMicrophone", !mIsOpenAudio);
        intent.putExtra("openCamera", mIsOpenVideo);
        intent.putExtra("soundOnSpeaker", mIsUseSpeaker);
        intent.putExtra("isCreate", true);
        mContext.startActivity(intent);
    }

    private String truncateString(String string) {
        int length = string.getBytes(StandardCharsets.UTF_8).length;
        if (length <= 30) {
            return string;
        } else {
            int byteLen = 0;
            StringBuilder result = new StringBuilder();
            for (char c : string.toCharArray()) {
                byteLen += String.valueOf(c).getBytes(StandardCharsets.UTF_8).length;
                if (byteLen > 30) {
                    break;
                }
                result.append(c);
            }
            return result.toString();
        }
    }

    public ArrayList<SwitchSettingItem> createSwitchSettingItemList() {
        BaseSettingItem.ItemText audioItemText =
                new BaseSettingItem.ItemText(mContext.getString(R.string.tuiroomkit_turn_on_audio), "");
        SwitchSettingItem audioItem = new SwitchSettingItem(mContext, audioItemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                mIsOpenAudio = isChecked;
            }
        }).setCheck(mIsOpenAudio);
        ArrayList<SwitchSettingItem> settingItemList = new ArrayList<>();
        settingItemList.add(audioItem);

        BaseSettingItem.ItemText speakerItemText =
                new BaseSettingItem.ItemText(mContext.getString(R.string.tuiroomkit_turn_on_speaker), "");
        SwitchSettingItem speakerItem =
                new SwitchSettingItem(mContext, speakerItemText, new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mIsUseSpeaker = isChecked;
                    }
                }).setCheck(mIsUseSpeaker);
        settingItemList.add(speakerItem);

        BaseSettingItem.ItemText videoItemText =
                new BaseSettingItem.ItemText(mContext.getString(R.string.tuiroomkit_turn_on_video), "");
        SwitchSettingItem videoItem = new SwitchSettingItem(mContext, videoItemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                mIsOpenVideo = isChecked;
            }
        }).setCheck(mIsOpenVideo);
        settingItemList.add(videoItem);
        return settingItemList;
    }
}
