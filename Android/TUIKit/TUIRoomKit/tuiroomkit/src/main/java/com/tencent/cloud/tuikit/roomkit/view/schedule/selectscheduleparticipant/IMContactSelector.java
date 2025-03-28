package com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import androidx.activity.result.ActivityResultCaller;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class IMContactSelector implements ParticipantSelector.IParticipantSelection {
    private static final String TAG = "IMContactSelector";

    @Override
    public void startParticipantSelect(Context context, ConferenceParticipants participants, ParticipantSelector.ParticipantSelectCallback participantSelectCallback) {
        if (!(context instanceof ActivityResultCaller)) {
            return;
        }
        ActivityResultCaller caller = (ActivityResultCaller) context;
        Bundle param = new Bundle();
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FRIENDS, true);
        param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST, getSelectedList(participants.selectedList));
        TUICore.startActivityForResult(caller, "StartGroupMemberSelectActivity", param, result -> {
            if (result.getData() == null) {
                participantSelectCallback.onParticipantSelected(transUserInfoList(participants.selectedList));
                return;
            }
            List<String> userIds = (List<String>) result.getData().getSerializableExtra(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.DATA_LIST);
            if (userIds == null) {
                participantSelectCallback.onParticipantSelected(transUserInfoList(participants.selectedList));
                return;
            }
            parseSelectedParticipant(participants.selectedList, userIds, participantSelectCallback);
        });
    }

    private ArrayList<String> getSelectedList(List<ConferenceDefine.User> participants) {
        ArrayList<String> selectedList = new ArrayList<>();
        if (participants == null || participants.isEmpty()) {
            return selectedList;
        }
        for (ConferenceDefine.User item : participants) {
            selectedList.add(item.id);
        }
        return selectedList;
    }

    private void parseSelectedParticipant(List<ConferenceDefine.User> oldParticipants, List<String> newParticipants, ParticipantSelector.ParticipantSelectCallback participantSelectCallback) {
        List<ConferenceDefine.User> participants = new ArrayList<>(newParticipants.size());
        List<String> users = new LinkedList<>();

        int index;
        for (String item : newParticipants) {
            ConferenceDefine.User user = new ConferenceDefine.User();
            user.id = item;
            index = oldParticipants.indexOf(user);
            if (index != -1) {
                participants.add(oldParticipants.get(index));
            } else {
                users.add(item);
            }
        }
        if (users.isEmpty()) {
            participantSelectCallback.onParticipantSelected(transUserInfoList(participants));
            return;
        }
        Log.e(TAG, "getUsersInfo size=" + users.size());
        V2TIMManager.getInstance().getUsersInfo(users, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> list) {
                Log.d(TAG, "getUsersInfo onSuccess size=" + list.size());
                for (V2TIMUserFullInfo item : list) {
                    ConferenceDefine.User user = new ConferenceDefine.User();
                    user.id = item.getUserID();
                    user.name = item.getNickName();
                    user.avatarUrl = item.getFaceUrl();
                    participants.add(user);
                }
                participantSelectCallback.onParticipantSelected(transUserInfoList(participants));
            }

            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "getUsersInfo onError code=" + code + " desc=" + desc);
                participantSelectCallback.onParticipantSelected(transUserInfoList(participants));
            }
        });
    }

    private List<UserState.UserInfo> transUserInfoList(List<ConferenceDefine.User> Participants) {
        List<UserState.UserInfo> userInfoList = new ArrayList<>();
        if (Participants == null) {
            return userInfoList;
        }
        for (ConferenceDefine.User participant : Participants) {
            UserState.UserInfo user = new UserState.UserInfo(participant.id);
            user.userName = participant.name;
            user.avatarUrl = participant.avatarUrl;
            userInfoList.add(user);
        }
        return userInfoList;
    }
}