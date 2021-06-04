package com.tencent.qcloud.tim.demo.helper;

import android.content.Intent;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.tencent.liteav.login.ProfileManager;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.LiveRoomAnchorActivity;
import com.tencent.qcloud.tim.demo.scenes.LiveRoomAudienceActivity;
import com.tencent.qcloud.tim.demo.scenes.net.RoomManager;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.liteav.model.LiveMessageInfo;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

public class LiveGroupTIMUIController {

    private static final String TAG = LiveGroupTIMUIController.class.getSimpleName();

    public static void onDraw(ICustomMessageViewGroup parent, final LiveMessageInfo info, final String groupId) {
        // 把自定义消息view添加到TUIKit内部的父容器里
        View view = LayoutInflater.from(DemoApplication.instance()).inflate(R.layout.message_adapter_content_trtc, null, false);
        parent.addMessageContentView(view);

        TextView textLiveName = view.findViewById(R.id.msg_tv_live_name);
        TextView textStatus = view.findViewById(R.id.msg_tv_live_status);

        final String text = DemoApplication.instance().getString(R.string.no_support_msg);
        if (info == null) {

        } else {
            if (!TextUtils.isEmpty(info.anchorName)) {
                textLiveName.setText(info.anchorName + DemoApplication.instance().getString(R.string.live));
            } else {
                textLiveName.setText(info.roomName);
            }
            textStatus.setText(info.roomStatus == 1 ? DemoApplication.instance().getString(R.string.living) : DemoApplication.instance().getString(R.string.stop_live));
        }
        view.setClickable(true);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (info == null) {
                    ToastUtil.toastShortMessage(text);
                    return;
                }
                String selfUserId = ProfileManager.getInstance().getUserModel().userId;
                if (String.valueOf(info.anchorId).equals(selfUserId)) {
                    createRoom(groupId);
                } else {
                    checkRoomExist(info);
                }
            }
        });
    }

    private static void checkRoomExist(final LiveMessageInfo info) {
        RoomManager.getInstance().updateRoom(info.roomId, RoomManager.TYPE_GROUP_LIVE, new RoomManager.ActionCallback() {
            @Override
            public void onSuccess() {
                enterRoom(info);
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtil.toastShortMessage(TUIKitLive.getAppContext().getString(R.string.live_is_over));
            }
        });
    }

    private static void createRoom(String groupId) {
        LiveRoomAnchorActivity.start(DemoApplication.instance(), groupId);
    }

    private static void enterRoom(LiveMessageInfo info) {
        Intent intent = new Intent(DemoApplication.instance(), LiveRoomAudienceActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(RoomManager.ROOM_TITLE, info.roomName);
        intent.putExtra(RoomManager.GROUP_ID, info.roomId);
        intent.putExtra(RoomManager.USE_CDN_PLAY, false);
        intent.putExtra(RoomManager.ANCHOR_ID, info.anchorId);
        intent.putExtra(RoomManager.PUSHER_NAME, info.anchorName);
        intent.putExtra(RoomManager.COVER_PIC, info.roomCover);
        intent.putExtra(RoomManager.PUSHER_AVATAR, info.roomCover);
        DemoApplication.instance().startActivity(intent);
    }
}
