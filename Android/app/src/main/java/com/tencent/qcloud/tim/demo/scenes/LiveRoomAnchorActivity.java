package com.tencent.qcloud.tim.demo.scenes;

import android.Manifest;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.net.HeartbeatManager;
import com.tencent.qcloud.tim.demo.scenes.net.RoomManager;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.TUILiveRoomAnchorLayout;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.utils.PermissionUtils;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.message.LiveMessageInfo;

import java.util.ArrayList;
import java.util.List;

public class LiveRoomAnchorActivity extends BaseActivity implements TUILiveRoomAnchorLayout.TUILiveRoomAnchorLayoutDelegate {

    private static final String TAG = "LiveRoomAnchorActivity";
    private TUILiveRoomAnchorLayout mLayoutTuiLiverRomAnchor;

    private String mGroupID;

    public static void start(Context context, String groupID) {
        Intent starter = new Intent(context, LiveRoomAnchorActivity.class);
        if(context instanceof Application) {
            starter.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        starter.putExtra(RoomManager.GROUP_ID, groupID);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setTurnScreenOn(true);
        } else {
        }
        setContentView(R.layout.test_activity_live_room_anchor);

        mGroupID = getIntent().getStringExtra(RoomManager.GROUP_ID);
        // 判断当前的房间类型
        mLayoutTuiLiverRomAnchor = findViewById(R.id.tui_liveroom_anchor_layout);
        mLayoutTuiLiverRomAnchor.setLiveRoomAnchorLayoutDelegate(this);
        mLayoutTuiLiverRomAnchor.initWithRoomId(getSupportFragmentManager(), getRoomId());
        mLayoutTuiLiverRomAnchor.enablePK(TextUtils.isEmpty(mGroupID));
    }

    private int getRoomId() {
        // 这里我们用简单的 userId hashcode，然后
        // 您的room id应该是您后台生成的唯一值
        String ownerId =  V2TIMManager.getInstance().getLoginUser();
        return (mGroupID + ownerId + "liveRoom").hashCode() & 0x7FFFFFFF;
    }

    @Override
    public void onBackPressed() {
        mLayoutTuiLiverRomAnchor.onBackPress();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (PermissionUtils.isPermissionRequestSuccess(grantResults)) {
        }
    }

    @Override
    public void onClose() {
        finish();
    }

    @Override
    public void onError(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo, int errorCode, String errorMsg) {

    }

    @Override
    public void onRoomCreate(final TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
        // 创建房间
        String type = RoomManager.TYPE_LIVE_ROOM;
        if (!TextUtils.isEmpty(mGroupID)) {
            sendLiveGroupMessage(roomInfo, 1);
            type = RoomManager.TYPE_GROUP_LIVE;
        }
        final String finalType = type;
        RoomManager.getInstance().createRoom(roomInfo.roomId, finalType, new RoomManager.ActionCallback() {
            @Override
            public void onSuccess() {
                HeartbeatManager.getInstance().start(finalType, roomInfo.roomId);
            }

            @Override
            public void onFailed(int code, String msg) {

            }
        });
    }

    @Override
    public void onRoomDestroy(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
        // 销毁房间
        String type = RoomManager.TYPE_LIVE_ROOM;
        if (!TextUtils.isEmpty(mGroupID)) {
            sendLiveGroupMessage(roomInfo, 0);
            type = RoomManager.TYPE_GROUP_LIVE;
        }
        RoomManager.getInstance().destroyRoom(roomInfo.roomId, type, null);
        HeartbeatManager.getInstance().stop();
    }

    @Override
    public void getRoomPKList(final TUILiveRoomAnchorLayout.OnRoomListCallback callback) {
        RoomManager.getInstance().getRoomList(RoomManager.TYPE_LIVE_ROOM, new RoomManager.GetRoomListCallback() {
            @Override
            public void onSuccess(List<String> roomIdList) {
                if (callback != null) {
                    callback.onSuccess(roomIdList);
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                if (callback != null) {
                    callback.onFailed();
                }
            }
        });
    }

    private void sendLiveGroupMessage(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo, int roomStatus) {
        LiveMessageInfo liveMessageInfo = new LiveMessageInfo();
        liveMessageInfo.version = 1;
        liveMessageInfo.roomId = roomInfo.roomId;
        liveMessageInfo.roomName = roomInfo.roomName;
        liveMessageInfo.roomType = RoomManager.TYPE_LIVE_ROOM;
        liveMessageInfo.roomCover = roomInfo.coverUrl;
        liveMessageInfo.roomStatus = roomStatus;
        liveMessageInfo.anchorId = roomInfo.ownerId;
        liveMessageInfo.anchorName = roomInfo.ownerName;
        GroupChatManagerKit.getInstance().sendLiveGroupMessage(mGroupID, liveMessageInfo, null);
    }
}
