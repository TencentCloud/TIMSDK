package com.tencent.cloud.tuikit.roomkit.imaccess;

import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.BUSINESS_ID_ROOM_MESSAGE;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.KEY_INVITE_DATA;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.ROOM_INVITE_SINGLING;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.manager.RoomMsgManager;
import com.tencent.cloud.tuikit.roomkit.imaccess.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.InvitedToJoinRoomActivity;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomClickListener;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomMessageBean;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomMessageHolder;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSignalingListener;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;

import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIRoomImAccessService extends ServiceInitializer implements ITUIExtension {
    private static final String TAG = "TUIRoomImAccessService";

    @Override
    public void init(Context context) {
        initExtension();
        initRoomMessage();
        initSignalingListener();
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, this);
    }

    private void initRoomMessage() {
        Map<String, Object> roomMsgParam = new HashMap<>();
        roomMsgParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID,
                BUSINESS_ID_ROOM_MESSAGE);
        roomMsgParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS, RoomMessageBean.class);
        roomMsgParam.put(TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS,
                RoomMessageHolder.class);
        TUICore.callService(TUIConstants.TUIChat.Method.RegisterCustomMessage.CLASSIC_SERVICE_NAME,
                TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME, roomMsgParam);

    }

    private void initSignalingListener() {
        V2TIMManager.getSignalingManager().addSignalingListener(new V2TIMSignalingListener() {
            @Override
            public void onReceiveNewInvitation(String inviteID, String inviter, String groupID,
                                               List<String> inviteeList, String data) {
                if (!isRoomInviteSingling(data)) {
                    return;
                }
                if (!isInvited(inviteeList)) {
                    return;
                }
                Log.d(TAG, "onReceiveNewInvitation inviteID=" + inviteID + " inviter=" + inviter + " groupID=" + groupID
                        + " data=" + data);
                if (!BusinessSceneUtil.canJoinRoom()) {
                    return;
                }
                BusinessSceneUtil.setJoinRoomFlag();

                Context context = TUIConfig.getAppContext();
                if (context == null) {
                    return;
                }
                Intent intent = new Intent(context, InvitedToJoinRoomActivity.class);
                intent.putExtra(KEY_INVITE_DATA, data);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            }

            @Override
            public void onInviteeAccepted(String inviteID, String invitee, String data) {
                Log.d(TAG, "onInviteeAccepted inviteID=" + inviteID + " invitee=" + invitee + " data=" + data);
            }

            @Override
            public void onInviteeRejected(String inviteID, String invitee, String data) {
                Log.d(TAG, "onInviteeRejected inviteID=" + inviteID + " invitee=" + invitee + " data=" + data);
            }
        });
    }

    private boolean isRoomInviteSingling(String data) {
        return !TextUtils.isEmpty(data) && data.contains(ROOM_INVITE_SINGLING);
    }

    private boolean isInvited(List<String> inviteeList) {
        String myId = TUILogin.getUserId();
        for (String item : inviteeList) {
            if (myId.equals(item)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.isEmpty(extensionID) || param == null) {
            Log.e(TAG, "onGetExtension params is illegal");
            return null;
        }
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID)
                && !TextUtils.isEmpty((String) param.get(TUIConstants.TUIChat.Extension.InputMore.GROUP_ID))) {
            ChatInputMoreListener chatInputMoreListener =
                    (ChatInputMoreListener) param.get(TUIConstants.TUIChat.Extension.InputMore.INPUT_MORE_LISTENER);
            RoomMsgManager.setChatInputMoreListenerRef(new WeakReference<>(chatInputMoreListener));

            TUIExtensionInfo roomExtension = new TUIExtensionInfo();
            // 参与排序的权重为 100
            roomExtension.setWeight(200);
            // 扩展名称为 “快速会议”
            roomExtension.setText(getAppContext().getString(R.string.tuiroomkit_chat_access_room));
            roomExtension.setIcon(R.drawable.tuiroomkit_chat_access_room_icon);
            // 设置扩展被点击事件
            roomExtension.setExtensionListener(new RoomClickListener());
            return Collections.singletonList(roomExtension);
        }
        return null;
    }
}
