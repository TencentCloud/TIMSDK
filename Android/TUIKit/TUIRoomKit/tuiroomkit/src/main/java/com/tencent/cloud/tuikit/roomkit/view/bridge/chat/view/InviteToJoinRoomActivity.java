package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.KEY_INVITE_DATA;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager.InviteJoinData;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgUserEntity;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.ArrayList;
import java.util.List;

public class InviteToJoinRoomActivity extends AppCompatActivity {
    private static final String TAG = "InviteToJoinRoomAy";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate");
        InviteJoinData inviteJoinData = parseData();
        if (inviteJoinData == null) {
            finish();
            return;
        }

        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID,
                inviteJoinData.data.roomInfo.getGroupId());
        param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST,
                getSelectedList(inviteJoinData));
        TUICore.startActivityForResult(this, "StartGroupMemberSelectActivity", param, result -> {
            if (result.getData() == null) {
                Log.w(TAG, "StartGroupMemberSelectActivity result is null");
                finish();
                return;
            }
            List<String> userIds = (List<String>) result.getData()
                    .getSerializableExtra(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.DATA_LIST);
            inviteToJoinRoom(inviteJoinData, userIds);
        });
    }

    private ArrayList<String> getSelectedList(InviteJoinData inviteJoinData) {
        ArrayList<String> selectedList = new ArrayList<>();
        if (inviteJoinData == null || inviteJoinData.data == null || inviteJoinData.data.roomInfo == null
                || inviteJoinData.data.roomInfo.getUserList() == null) {
            return selectedList;
        }
        List<RoomMsgUserEntity> userList = inviteJoinData.data.roomInfo.getUserList();
        for (RoomMsgUserEntity item : userList) {
            selectedList.add(item.getUserId());
        }
        return selectedList;
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.d(TAG, "onStart");
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG, "onStop");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
    }

    private InviteJoinData parseData() {
        Intent intent = getIntent();
        if (intent == null) {
            Log.e(TAG, "intent is null");
            return null;
        }
        String content = intent.getStringExtra(KEY_INVITE_DATA);
        if (TextUtils.isEmpty(content)) {
            Log.e(TAG, "content is null");
            return null;
        }
        Gson gson = new Gson();
        InviteJoinData inviteJoinData = null;
        try {
            inviteJoinData = gson.fromJson(content, InviteJoinData.class);
        } catch (JsonSyntaxException e) {
            Log.e(TAG, "parseData JsonSyntaxException");
            e.printStackTrace();
        }
        return inviteJoinData;
    }

    private void inviteToJoinRoom(InviteJoinData inviteJoinData, List<String> invitedList) {
        Gson gson = new Gson();
        String inviteData = gson.toJson(inviteJoinData);
        V2TIMManager.getSignalingManager()
                .inviteInGroup(inviteJoinData.data.roomInfo.getGroupId(), invitedList, inviteData, true, 0,
                        new V2TIMCallback() {
                            @Override
                            public void onSuccess() {
                                Log.d(TAG, "inviteInGroup onSuccess");
                                finish();
                            }

                            @Override
                            public void onError(int errorCode, String errorMsg) {
                                Log.e(TAG, "inviteInGroup onError errorCode=" + errorCode + " errorMsg=" + errorMsg);
                                finish();
                            }
                        });
    }
}
