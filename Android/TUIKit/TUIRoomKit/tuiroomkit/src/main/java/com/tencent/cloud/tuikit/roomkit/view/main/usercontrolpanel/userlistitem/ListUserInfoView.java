package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.GENERAL_USER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OUT_ROOM;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.List;

public class ListUserInfoView extends FrameLayout {

    private final ImageFilterView mIfvUserAvatar;
    private final ImageFilterView mIfvUserRole;
    private final TextView        mTvUserName;
    private final TextView        mTvUserRole;

    private String mUserId;

    private final LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
            super.onDataChanged(list);
            ConferenceController controller = ConferenceController.sharedInstance();
            if (controller.getViewState().userListType.get() == OUT_ROOM) {
                return;
            }
            UserState.UserInfo userInfo = controller.getUserState().allUsers.find(new UserState.UserInfo(mUserId));
            updateView(userInfo);
        }

        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            super.onItemChanged(position, item);
            if (!TextUtils.equals(mUserId, item.userId)) {
                return;
            }
            updateView(item);
        }
    };

    private final LiveListObserver<InvitationState.Invitation> mInvitationObserver = new LiveListObserver<InvitationState.Invitation>() {
        @Override
        public void onDataChanged(List<InvitationState.Invitation> list) {
            super.onDataChanged(list);
            ConferenceController controller = ConferenceController.sharedInstance();
            if (controller.getViewState().userListType.get() != OUT_ROOM) {
                return;
            }
            InvitationState.Invitation invitation = controller.getInvitationState().invitationList.find(new InvitationState.Invitation(mUserId));
            updateView(invitation.invitee);
        }

        @Override
        public void onItemChanged(int position, InvitationState.Invitation item) {
            super.onItemChanged(position, item);
            if (!TextUtils.equals(mUserId, item.invitee.userId)) {
                return;
            }
            updateView(item.invitee);
        }
    };

    public ListUserInfoView(@NonNull Context context) {
        this(context, null);
    }

    public ListUserInfoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ListUserInfoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View parent = View.inflate(context, R.layout.tuiroomkit_item_list_user_info, this);
        mIfvUserAvatar = parent.findViewById(R.id.room_ifv_list_user_avatar);
        mTvUserName = parent.findViewById(R.id.room_tv_list_user_name);
        mIfvUserRole = parent.findViewById(R.id.room_ifv_list_user_role);
        mTvUserRole = parent.findViewById(R.id.room_tv_list_user_role);
    }

    public void setUserId(String userId) {
        mUserId = userId;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getUserState().allUsers.observe(mAllUserObserver);
        ConferenceController.sharedInstance().getInvitationState().invitationList.observe(mInvitationObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getUserState().allUsers.removeObserver(mAllUserObserver);
        ConferenceController.sharedInstance().getInvitationState().invitationList.removeObserver(mInvitationObserver);
    }

    private void updateView(UserState.UserInfo userInfo) {
        if (userInfo == null) {
            return;
        }
        ImageLoader.loadImage(getContext(), mIfvUserAvatar, userInfo.avatarUrl, R.drawable.tuiroomkit_head);

        String userName = userInfo.userName;
        if (TextUtils.isEmpty(userName)) {
            userName = userInfo.userId;
        }
        if (TextUtils.equals(userInfo.userId, TUILogin.getUserId())) {
            userName = userName + getContext().getString(R.string.tuiroomkit_me);
        }
        mTvUserName.setText(userName);

        TUIRoomDefine.Role role = userInfo.role.get();
        mIfvUserRole.setVisibility(role == GENERAL_USER ? INVISIBLE : VISIBLE);
        mTvUserRole.setVisibility(role == GENERAL_USER ? INVISIBLE : VISIBLE);
        mIfvUserRole.setImageResource(role == ROOM_OWNER ? R.drawable.tuiroomkit_icon_user_room_owner
                : R.drawable.tuiroomkit_icon_user_room_manager);
        mTvUserRole.setText(getContext().getString(role == ROOM_OWNER ? R.string.tuiroomkit_master
                : R.string.tuiroomkit_room_manager));
    }
}
