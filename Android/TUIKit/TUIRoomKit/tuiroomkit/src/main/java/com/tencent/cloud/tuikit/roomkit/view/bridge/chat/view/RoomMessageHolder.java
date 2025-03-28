package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.MSG_MAX_SHOW_MEMBER_COUNT;

import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.constraintlayout.utils.widget.ImageFilterButton;
import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgUserEntity;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.presenter.RoomPresenter;
import com.tencent.cloud.tuikit.roomkit.common.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;

import java.nio.charset.StandardCharsets;
import java.util.List;

public class RoomMessageHolder extends MessageContentHolder {
    private static final String TAG = "RoomMessageHolder";

    private ImageView mTitleIconIv;
    private TextView  mTitleTv;
    private TextView  mManagerTv;

    private ImageFilterView[] mUserListFaceView;
    private TextView          mMoreMemberTv;
    private ImageFilterButton mInviteBtn;

    private TextView          mRoomStateTv;
    private ProgressBar       mRoomCreatingPb;
    private TextView          mJoinedMembersTv;
    private TextView          mJoinBtn;
    private ImageFilterButton mFullJoinBtn;

    private RoomMsgData mRoomMsgData;

    public RoomMessageHolder(View itemView) {
        super(itemView);

        mTitleIconIv = itemView.findViewById(R.id.tuiroomkit_room_msg_title_icon_iv);
        mTitleTv = itemView.findViewById(R.id.tuiroomkit_room_msg_title_tv);
        mManagerTv = itemView.findViewById(R.id.tuiroomkit_room_msg_manager_tv);

        mUserListFaceView = new ImageFilterView[]{
                itemView.findViewById(R.id.tuiroomkit_room_msg_joined_first_iv),
                itemView.findViewById(R.id.tuiroomkit_room_msg_joined_second_iv),
                itemView.findViewById(R.id.tuiroomkit_room_msg_joined_third_iv),
                itemView.findViewById(R.id.tuiroomkit_room_msg_joined_fourth_iv),
                itemView.findViewById(R.id.tuiroomkit_room_msg_joined_fifth_iv)};

        mMoreMemberTv = itemView.findViewById(R.id.tuiroomkit_room_msg_joined_more_tv);
        mInviteBtn = itemView.findViewById(R.id.tuiroomkit_room_msg_invite_btn);
        mInviteBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRoomMsgData == null) {
                    Log.e(TAG, "mInviteBtn onTouch mRoomMsgData is null");
                    return;
                }
                Log.d(TAG, "mInviteBtn onTouch userId=" + TUILogin.getUserId() + " userName=" + TUILogin.getNickName());
                RoomPresenter.getInstance().inviteOtherMembersToJoin(mRoomMsgData);
            }
        });

        mRoomStateTv = itemView.findViewById(R.id.tuiroomkit_room_msg_room_state_tv);
        mRoomCreatingPb = itemView.findViewById(R.id.tuiroomkit_room_msg_creating_pb);
        mJoinedMembersTv = itemView.findViewById(R.id.tuiroomkit_room_msg_joined_members_tv);
        mJoinBtn = itemView.findViewById(R.id.tuiroomkit_room_msg_join_btn);
        mFullJoinBtn = itemView.findViewById(R.id.tuiroomkit_room_msg_full_join_btn);
        mFullJoinBtn.setOnClickListener(v -> {
            if (mRoomMsgData == null) {
                Log.e(TAG, "mFullJoinBtn onClick mRoomMsgData is null");
                return;
            }
            Log.d(TAG, "mFullJoinBtn onclick userId=" + TUILogin.getUserId() + " userName=" + TUILogin.getNickName());
            if (BusinessSceneUtil.canJoinRoom()) {
                RoomPresenter.getInstance().enterRoom(mRoomMsgData);
            } else {
                RoomToast.toastLongMessage(
                        TUILogin.getAppContext().getResources().getString(R.string.tuiroomkit_can_not_join_room_tip));
            }
        });
    }

    @Override
    public int getVariableLayout() {
        return R.layout.tuiroomkit_room_msg_layout;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        msgArea.setBackgroundResource(android.R.color.transparent);
        if (!parseMessage(msg)) {
            return;
        }
        updateMessageView();
    }

    private void updateMessageView() {
        if (mRoomMsgData == null) {
            Log.w(TAG, "updateMessageView mRoomMsgData is null");
            return;
        }
        updateRoomStateView(mRoomMsgData);
        updateRoomManagerView(mRoomMsgData);
        updateJoinedMembersView(mRoomMsgData);
        updateInviteView(mRoomMsgData);
        updateRoomMsgBottomView(mRoomMsgData);
    }

    private void updateRoomStateView(RoomMsgData roomMsgData) {
        AccessRoomConstants.RoomState roomState = roomMsgData.getRoomState();
        switch (roomState) {
            case creating:
                mTitleIconIv.setBackgroundResource(R.drawable.tuiroomkit_room_msg_icon_creating);
                mTitleTv.setText(R.string.tuiroomkit_room_msg_meeting);
                mTitleTv.setTextColor(
                        TUILogin.getAppContext().getResources().getColor(R.color.tuiroomkit_room_msg_title_creating));
                break;

            case created:
                mTitleIconIv.setBackgroundResource(R.drawable.tuiroomkit_room_msg_icon_during);
                mTitleTv.setText(R.string.tuiroomkit_room_msg_meeting_in_progress);
                mTitleTv.setTextColor(
                        TUILogin.getAppContext().getResources().getColor(R.color.tuiroomkit_room_msg_title_created));
                break;

            default:
                mTitleIconIv.setBackgroundResource(R.drawable.tuiroomkit_room_msg_icon_destroyed);
                mTitleTv.setText(R.string.tuiroomkit_room_msg_meeting);
                mTitleTv.setTextColor(
                        TUILogin.getAppContext().getResources().getColor(R.color.tuiroomkit_room_msg_title_destroyed));
                break;
        }
    }

    private void updateRoomManagerView(RoomMsgData roomMsgData) {
        String roomManagerName = roomMsgData.getRoomManagerName();
        mManagerTv.setText(roomManagerName + TUILogin.getAppContext().getResources()
                .getString(R.string.tuiroomkit_room_msg_display_suffix));
    }

    private void updateJoinedMembersView(RoomMsgData roomMsgData) {
        List<RoomMsgUserEntity> users = roomMsgData.getUserList();
        for (int i = 0; i < MSG_MAX_SHOW_MEMBER_COUNT; i++) {
            if (i < users.size()) {
                mUserListFaceView[i].setVisibility(View.VISIBLE);
                ImageLoader.loadImage(TUILogin.getAppContext(), mUserListFaceView[i], users.get(i).getFaceUrl(),
                        R.drawable.tuiroomkit_head);
                continue;
            }
            mUserListFaceView[i].setVisibility(View.GONE);
        }
        mMoreMemberTv.setVisibility(
                roomMsgData.getMemberCount() > MSG_MAX_SHOW_MEMBER_COUNT ? View.VISIBLE : View.GONE);
    }

    private void updateInviteView(RoomMsgData roomMsgData) {
        String roomManagerId = roomMsgData.getRoomManagerId();
        mInviteBtn.setVisibility(TUILogin.getUserId().equals(roomManagerId) ? View.VISIBLE : View.GONE);
        AccessRoomConstants.RoomState roomState = roomMsgData.getRoomState();
        mInviteBtn.setEnabled(roomState != AccessRoomConstants.RoomState.creating
                && roomState != AccessRoomConstants.RoomState.destroyed);
    }

    private void updateRoomMsgBottomView(RoomMsgData roomMsgData) {
        AccessRoomConstants.RoomState roomState = roomMsgData.getRoomState();
        if (roomState == AccessRoomConstants.RoomState.creating) {
            mRoomStateTv.setVisibility(View.VISIBLE);
            mRoomCreatingPb.setVisibility(View.VISIBLE);
            mJoinedMembersTv.setVisibility(View.GONE);
            mJoinBtn.setVisibility(View.GONE);
            mFullJoinBtn.setEnabled(false);
            mRoomStateTv.setText(R.string.tuiroomkit_chat_access_room_creating);
            return;
        }
        if (roomState == AccessRoomConstants.RoomState.destroyed) {
            mRoomStateTv.setVisibility(View.VISIBLE);
            mRoomCreatingPb.setVisibility(View.GONE);
            mJoinedMembersTv.setVisibility(View.GONE);
            mJoinBtn.setVisibility(View.GONE);
            mFullJoinBtn.setEnabled(false);
            mRoomStateTv.setText(R.string.tuiroomkit_chat_access_room_ended);
            return;
        }
        mRoomStateTv.setVisibility(View.GONE);
        mRoomCreatingPb.setVisibility(View.GONE);
        mJoinedMembersTv.setVisibility(View.VISIBLE);
        mJoinBtn.setVisibility(View.VISIBLE);
        mFullJoinBtn.setEnabled(true);

        mJoinedMembersTv.setText(mRoomMsgData.getMemberCount() > 1 ?
                mRoomMsgData.getMemberCount() + TUILogin.getAppContext().getResources()
                        .getString(R.string.tuiroomkit_room_msg_members_has_joined) :
                TUILogin.getAppContext().getResources().getString(R.string.tuiroomkit_room_msg_waiting_for_members));

        boolean isJoined = BusinessSceneUtil.isInTheRoom(mRoomMsgData.getRoomId());
        mJoinBtn.setText(TUILogin.getAppContext().getResources()
                .getString(isJoined ? R.string.tuiroomkit_room_msg_joined : R.string.tuiroomkit_room_msg_join));
        mJoinBtn.setTextColor(TUILogin.getAppContext().getResources().getColor(
                isJoined ? R.color.tuiroomkit_room_msg_btn_text_color_joined :
                        R.color.tuiroomkit_room_msg_btn_text_color_join));
        mJoinBtn.setBackground(TUILogin.getAppContext().getResources().getDrawable(
                isJoined ? R.drawable.tuiroomkit_room_msg_btn_joined : R.drawable.tuiroomkit_room_msg_btn_join));
    }

    private boolean parseMessage(TUIMessageBean msg) {
        V2TIMMessage v2TIMMessage = msg.getV2TIMMessage();
        if (v2TIMMessage == null) {
            Log.w(TAG, "parseMessage v2TIMMessage is null");
            return false;
        }

        V2TIMCustomElem elem = v2TIMMessage.getCustomElem();
        if (elem == null) {
            Log.w(TAG, "parseMessage elem is null");
            return false;
        }
        byte[] data = elem.getData();
        if (data == null) {
            Log.w(TAG, "parseMessage data is null");
            return false;
        }
        String content = new String(data, StandardCharsets.UTF_8);
        if (TextUtils.isEmpty(content)) {
            Log.w(TAG, "parseMessage content is null");
            return false;
        }

        Gson gson = new Gson();
        Log.d(TAG, "parseMessage content = " + content);
        try {
            mRoomMsgData = gson.fromJson(content, RoomMsgData.class);
        } catch (JsonSyntaxException e) {
            Log.e(TAG, "parseMessage : JsonSyntaxException");
            e.printStackTrace();
            return false;
        }
        return mRoomMsgData.getUserList() != null || mRoomMsgData.getRoomState() != null;
    }
}
