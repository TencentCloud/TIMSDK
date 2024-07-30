package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import androidx.activity.result.ActivityResultCaller;

import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
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
    public void startParticipantSelect(Context context, List<UserState.UserInfo> participants, ParticipantSelector.ParticipantSelectCallback participantSelectCallback) {
        if (!(context instanceof ActivityResultCaller)) {
            return;
        }
        ActivityResultCaller caller = (ActivityResultCaller) context;
        Bundle param = new Bundle();
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FRIENDS, true);
        param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST, getSelectedList(participants));
        TUICore.startActivityForResult(caller, "StartGroupMemberSelectActivity", param, result -> {
            if (result.getData() == null) {
                participantSelectCallback.onParticipantSelected(participants);
                return;
            }
            List<String> userIds = (List<String>) result.getData().getSerializableExtra(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.DATA_LIST);
            if (userIds == null) {
                participantSelectCallback.onParticipantSelected(participants);
                return;
            }
            parseSelectedParticipant(participants, userIds, participantSelectCallback);
        });
    }

    private ArrayList<String> getSelectedList(List<UserState.UserInfo> participants) {
        ArrayList<String> selectedList = new ArrayList<>();
        if (participants == null || participants.isEmpty()) {
            return selectedList;
        }
        for (UserState.UserInfo item : participants) {
            selectedList.add(item.userId);
        }
        return selectedList;
    }

    private void parseSelectedParticipant(List<UserState.UserInfo> oldParticipants, List<String> newParticipants, ParticipantSelector.ParticipantSelectCallback participantSelectCallback) {
        List<UserState.UserInfo> participants = new ArrayList<>(newParticipants.size());
        List<String> users = new LinkedList<>();

        int index;
        for (String item : newParticipants) {
            index = oldParticipants.indexOf(new UserState.UserInfo(item));
            if (index != -1) {
                participants.add(oldParticipants.get(index));
            } else {
                users.add(item);
            }
        }
        if (users.isEmpty()) {
            participantSelectCallback.onParticipantSelected(participants);
            return;
        }
        Log.e(TAG, "getUsersInfo size=" + users.size());
        V2TIMManager.getInstance().getUsersInfo(users, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> list) {
                Log.d(TAG, "getUsersInfo onSuccess size=" + list.size());
                for (V2TIMUserFullInfo item : list) {
                    UserState.UserInfo userInfo  = new UserState.UserInfo(item.getUserID());
                    userInfo.userName = item.getNickName();
                    userInfo.avatarUrl = item.getFaceUrl();
                    participants.add(userInfo);
                }
                participantSelectCallback.onParticipantSelected(participants);
            }

            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "getUsersInfo onError code=" + code + " desc=" + desc);
                participantSelectCallback.onParticipantSelected(participants);
            }
        });
    }
}
