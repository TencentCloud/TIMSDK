package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.KEY_INVITE_DATA;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.utils.widget.ImageFilterButton;
import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.extensions.RoomBellFeature;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager.InviteJoinData;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.presenter.RoomPresenter;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.qcloud.tuicore.TUILogin;

public class InvitedToJoinRoomActivity extends AppCompatActivity {
    private static final String TAG = "InvitedToJoinRoomAy";

    private RoomBellFeature mRingBell;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate");
        InviteJoinData inviteJoinData = parseData();
        if (inviteJoinData == null || inviteJoinData.data == null || inviteJoinData.data.inviter == null
                || inviteJoinData.data.roomInfo == null) {
            finish();
            return;
        }
        setContentView(R.layout.tuiroomkit_room_invited_layout);
        initView(inviteJoinData);
        mRingBell = new RoomBellFeature(this.getApplicationContext());
        mRingBell.startDialingMusic();
    }

    private void initView(InviteJoinData inviteJoinData) {
        ImageFilterView inviterFaceIv = findViewById(R.id.tuiroomkit_invite_user_face_iv);
        TUIRoomDefine.LoginUserInfo inviter = inviteJoinData.data.inviter;
        ImageLoader.loadImage(TUILogin.getAppContext(), inviterFaceIv, inviter.avatarUrl,
                R.drawable.tuiroomkit_head);
        TextView inviterNameTv = findViewById(R.id.tuiroomkit_invite_user_name_tv);
        inviterNameTv.setText(inviter.userName);
        ImageFilterButton acceptBtn = findViewById(R.id.tuiroomkit_room_accept_invite_btn);
        acceptBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "acceptBtn onClick");
                RoomPresenter.getInstance().enterRoom(inviteJoinData.data.roomInfo);
                finish();
            }
        });
        ImageFilterButton rejectBtn = findViewById(R.id.tuiroomkit_room_reject_invite_btn);
        rejectBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "rejectBtn onClick");
                finish();
            }
        });
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
        mRingBell.stopMusic();
        mRingBell = null;
    }
}
