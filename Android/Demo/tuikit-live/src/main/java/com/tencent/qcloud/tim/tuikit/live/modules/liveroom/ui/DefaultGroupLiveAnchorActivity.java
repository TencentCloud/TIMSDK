package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui;

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
import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.base.Constants;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.TUILiveRoomAnchorLayout;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.utils.PermissionUtils;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;
import com.tencent.qcloud.tim.uikit.base.IBaseMessageSender;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;

import java.util.ArrayList;
import java.util.List;

public class DefaultGroupLiveAnchorActivity extends AppCompatActivity implements TUILiveRoomAnchorLayout.TUILiveRoomAnchorLayoutDelegate {

    private static final String TAG = "DefaultGroupLiveAnchorActivity";
    private TUILiveRoomAnchorLayout mLayoutTuiLiverRomAnchor;

    private String mGroupID;

    public static void start(Context context, String groupID) {
        Intent starter = new Intent(context, DefaultGroupLiveAnchorActivity.class);
        if(context instanceof Application) {
            starter.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        starter.putExtra(Constants.GROUP_ID, groupID);
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
        setContentView(R.layout.live_activity_default_gourp_live_anchor);

        List<String> permissionList = new ArrayList<>();
        permissionList.add(Manifest.permission.CAMERA);
        permissionList.add(Manifest.permission.RECORD_AUDIO);
        PermissionUtils.requestMorePermissions(this, permissionList, 100);

        mGroupID = getIntent().getStringExtra(Constants.GROUP_ID);
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
        if (!TextUtils.isEmpty(mGroupID)) {
            sendLiveGroupMessage(roomInfo, 1);
        }
    }

    @Override
    public void onRoomDestroy(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
        // 销毁房间
        if (!TextUtils.isEmpty(mGroupID)) {
            sendLiveGroupMessage(roomInfo, 0);
        }
    }

    @Override
    public void getRoomPKList(final TUILiveRoomAnchorLayout.OnRoomListCallback callback) {
    }

    private void sendLiveGroupMessage(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo, int roomStatus) {
        IBaseMessageSender messageSender = TUIKitListenerManager.getInstance().getMessageSender();
        if (messageSender == null) {
            TUILiveLog.e(TAG, "sendLiveGroupMessage error ,messageSender is null");
            return;
        }
        LiveMessageInfo liveMessageInfo = new LiveMessageInfo();
        liveMessageInfo.version = 1;
        liveMessageInfo.roomId = roomInfo.roomId;
        liveMessageInfo.roomName = roomInfo.roomName;
        liveMessageInfo.roomType = "liveRoom";
        liveMessageInfo.roomCover = roomInfo.coverUrl;
        liveMessageInfo.roomStatus = roomStatus;
        liveMessageInfo.anchorId = roomInfo.ownerId;
        liveMessageInfo.anchorName = roomInfo.ownerName;
        String data = new Gson().toJson(liveMessageInfo);
        MessageInfo messageInfo = MessageInfoUtil.buildCustomMessage(data);
        messageSender.sendMessage(messageInfo, null, mGroupID, true, false, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                TUILiveLog.d(TAG, "sendLiveGroupMessage onSuccess");
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public class LiveMessageInfo {
        public int version;
        public int roomId;
        /**
         * 0：stop
         * 1：start
         */
        public int roomStatus;
        public String roomName;
        /**
         * 封面图
         */
        public String roomCover;
        public String roomType;
        public String anchorId;
        public String anchorName;
        public String businessID = "group_live";

        @Override
        public String toString() {
            return "LiveMessageInfo{" +
                    "version=" + version +
                    ", roomId=" + roomId +
                    ", roomStatus=" + roomStatus +
                    ", roomName='" + roomName + '\'' +
                    ", roomCover='" + roomCover + '\'' +
                    ", roomType='" + roomType + '\'' +
                    ", anchorId='" + anchorId + '\'' +
                    ", anchorName='" + anchorName + '\'' +
                    ", businessID='" + businessID + '\'' +
                    '}';
        }
    }

}
