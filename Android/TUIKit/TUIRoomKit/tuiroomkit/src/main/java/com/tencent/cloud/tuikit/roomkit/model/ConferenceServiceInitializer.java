package com.tencent.cloud.tuikit.roomkit.model;

import static com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager.RejectedReason.IN_OTHER_CONFERENCE;
import static com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager.RejectedReason.REJECT_TO_ENTER;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.BUSINESS_ID_ROOM_MESSAGE;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.KEY_INVITE_DATA;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.ROOM_INVITE_SINGLING;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.manager.RoomMsgManager;
import com.tencent.cloud.tuikit.roomkit.common.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.InvitedToJoinRoomActivity;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomClickListener;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomMessageBean;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomMessageHolder;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSignalingListener;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;

import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ConferenceServiceInitializer extends ServiceInitializer implements ITUIExtension {
    private static final String TAG = "RoomServiceInitializer";

    @Override
    public void init(Context context) {
        initExtension();
        initRoomMessage();
        initSignalingListener();
        initConferenceInvitationObserver();
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TIMAppKit.Extension.ProfileSettings.CLASSIC_EXTENSION_ID, this);
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

    private void initConferenceInvitationObserver() {
        TUIConferenceInvitationManager invitationManager = (TUIConferenceInvitationManager) TUIRoomEngine.sharedInstance().getExtension(TUICommonDefine.ExtensionType.CONFERENCE_INVITATION_MANAGER);
        invitationManager.addObserver(new TUIConferenceInvitationManager.Observer() {
            @Override
            public void onReceiveInvitation(TUIRoomDefine.RoomInfo roomInfo, TUIConferenceInvitationManager.Invitation invitation, String extensionInfo) {
                if (ConferenceController.sharedInstance().getViewState().isInvitationPending.get()) {
                    ConferenceController.sharedInstance().getInvitationController().reject(roomInfo.roomId, REJECT_TO_ENTER, null);
                    return;
                }
                if (ConferenceController.sharedInstance().getRoomController().isInRoom()) {
                    ConferenceController.sharedInstance().getInvitationController().reject(roomInfo.roomId, IN_OTHER_CONFERENCE, null);
                    return;
                }

                Bundle bundle = new Bundle();
                bundle.putString("roomId", roomInfo.roomId);
                bundle.putString("conferenceName", roomInfo.name);
                bundle.putString("ownerName", roomInfo.ownerName);
                bundle.putString("inviterName", invitation.inviter.userName);
                bundle.putString("inviterAvatarUrl", roomInfo.ownerAvatarUrl);
                bundle.putInt("memberCount", roomInfo.memberCount);
                TUICore.startActivity("InvitationReceivedActivity", bundle);
            }
        });
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID)
                && !TextUtils.isEmpty((String) param.get(TUIConstants.TUIChat.Extension.InputMore.GROUP_ID))) {
            if (TextUtils.isEmpty(extensionID) || param == null) {
                Log.e(TAG, "onGetExtension TUIConstants.TUIChat.Extension.InputMore.GROUP_ID params is illegal");
                return null;
            }
            Object obj = param.get(TUIConstants.TUIChat.Extension.InputMore.FILTER_ROOM);
            if (obj != null && obj instanceof Boolean && ((boolean) obj)) {
                return null;
            }
            ChatInputMoreListener chatInputMoreListener =
                    (ChatInputMoreListener) param.get(TUIConstants.TUIChat.Extension.InputMore.INPUT_MORE_LISTENER);
            RoomMsgManager.setChatInputMoreListenerRef(new WeakReference<>(chatInputMoreListener));

            TUIExtensionInfo roomExtension = new TUIExtensionInfo();
            roomExtension.setWeight(200);
            roomExtension.setText(getAppContext().getString(R.string.tuiroomkit_chat_access_room));
            roomExtension.setIcon(R.drawable.tuiroomkit_chat_access_room_icon);
            roomExtension.setExtensionListener(new RoomClickListener());
            return Collections.singletonList(roomExtension);
        }
        if (TextUtils.equals(extensionID, TUIConstants.TIMAppKit.Extension.ProfileSettings.CLASSIC_EXTENSION_ID)) {
            View settingView = LayoutInflater.from(getAppContext())
                    .inflate(R.layout.tuiroomkit_room_setting_extention_layout, null);
            settingView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TUICore.startActivity("Chat2RoomExtensionSettingsActivity", new Bundle());
                }
            });

            LineControllerView groupView = settingView.findViewById(R.id.tuiroomkit_extension_setting);
            groupView.setCanNav(true);
            HashMap<String, Object> paramMap = new HashMap<>();
            paramMap.put(TUIConstants.TIMAppKit.Extension.ProfileSettings.KEY_VIEW, settingView);
            TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
            extensionInfo.setData(paramMap);
            extensionInfo.setWeight(501);
            return Collections.singletonList(extensionInfo);
        }
        return null;
    }
}
