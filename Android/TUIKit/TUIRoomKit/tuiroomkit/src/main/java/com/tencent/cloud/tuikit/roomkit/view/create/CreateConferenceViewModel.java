package com.tencent.cloud.tuikit.roomkit.view.create;

import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.KEY_START_CONFERENCE_PARAMS;

import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseSettingItem;
import com.tencent.cloud.tuikit.roomkit.view.basic.SwitchSettingItem;

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

    public void createRoom(String conferenceId) {
        ConferenceDefine.StartConferenceParams params = new ConferenceDefine.StartConferenceParams(conferenceId);
        params.isSeatEnabled = mIsSeatEnabled;
        params.isOpenMicrophone = mIsOpenAudio;
        params.isOpenCamera = mIsOpenVideo;
        params.isOpenSpeaker = mIsUseSpeaker;
        Intent intent = new Intent(mContext, ConferenceMainActivity.class);
        intent.putExtra(KEY_START_CONFERENCE_PARAMS, params);
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
