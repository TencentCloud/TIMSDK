package com.tencent.cloud.tuikit.roomkit.view.main.conferenceinvitation;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DESTROY_INVITATION_RECEIVED_ACTIVITY;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.ViewGroup;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;

import java.util.Map;

public class InvitationReceivedActivity extends AppCompatActivity implements ConferenceEventCenter.RoomKitUIEventResponder {

    public static final String INTENT_ROOM_ID            = "roomId";
    public static final String INTENT_CONFERENCE_NAME    = "conferenceName";
    public static final String INTENT_OWNER_NAME         = "ownerName";
    public static final String INTENT_INVITER_NAME       = "inviterName";
    public static final String INTENT_INVITER_AVATAR_URL = "inviterAvatarUrl";
    public static final String INTENT_MEMBER_COUNT       = "memberCount";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_receive_invitation);
        String roomId = getIntent().getStringExtra(INTENT_ROOM_ID);
        String conferenceName = getIntent().getStringExtra(INTENT_CONFERENCE_NAME);
        String ownerName = getIntent().getStringExtra(INTENT_OWNER_NAME);
        String inviterName = getIntent().getStringExtra(INTENT_INVITER_NAME);
        String inviterAvatarUrl = getIntent().getStringExtra(INTENT_INVITER_AVATAR_URL);
        int memberCount = getIntent().getIntExtra(INTENT_MEMBER_COUNT, 0);
        InvitationReceivedView invitationReceivedView = new InvitationReceivedView(this);
        invitationReceivedView.setData(roomId, inviterAvatarUrl, inviterName, conferenceName, ownerName, memberCount);
        ViewGroup root = findViewById(R.id.ll_root_receive_invitation);
        root.addView(invitationReceivedView);
        ConferenceEventCenter.getInstance().subscribeUIEvent(DESTROY_INVITATION_RECEIVED_ACTIVITY, this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(DESTROY_INVITATION_RECEIVED_ACTIVITY, this);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (DESTROY_INVITATION_RECEIVED_ACTIVITY.equals(key)) {
            finish();
        }
    }
}