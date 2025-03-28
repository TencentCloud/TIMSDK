package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_MODEL;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OUT_ROOM;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.CallUserView;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.CameraIconView;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.InviteSeatButton;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.ListUserInfoView;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.MicIconView;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.ScreenIconView;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserRecyclerViewAdapter extends RecyclerView.Adapter<UserRecyclerViewAdapter.UserViewHolder> {
    private final Context                  mContext;
    private       List<UserState.UserInfo> mUserList;

    public UserRecyclerViewAdapter(Context context) {
        super();
        mContext = context;
    }

    public void setDataList(List<UserState.UserInfo> userList) {
        mUserList = userList;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_item_remote_user_list, parent, false);
        return new UserViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull UserViewHolder holder, int position) {
        UserState.UserInfo user = mUserList.get(position);
        holder.bindData(user);
    }

    @Override
    public int getItemCount() {
        return mUserList.size();
    }

    public static class UserViewHolder extends RecyclerView.ViewHolder {
        private final View             mRootView;
        private final ListUserInfoView mViewUserInfo;
        private final InviteSeatButton mBtnInvite;
        private final MicIconView      mViewMic;
        private final CameraIconView   mViewCamera;
        private final ScreenIconView   mViewScreen;
        private final CallUserView     mCallUserView;

        public UserViewHolder(View itemView) {
            super(itemView);
            mRootView = itemView.findViewById(R.id.cl_user_item_root);
            mViewUserInfo = itemView.findViewById(R.id.room_view_user_info);
            mBtnInvite = itemView.findViewById(R.id.tuiroomkit_btn_invite_seat);
            mViewMic = itemView.findViewById(R.id.tuiroomkit_img_mic_state);
            mViewCamera = itemView.findViewById(R.id.tuiroomkit_img_camera_state);
            mViewScreen = itemView.findViewById(R.id.room_view_screen_state);
            mCallUserView = itemView.findViewById(R.id.tuiroomkit_call_user_view);
        }

        public void bindData(UserState.UserInfo user) {
            mViewUserInfo.setUserId(user.userId);
            mBtnInvite.setUserId(user.userId);
            mViewMic.setUserId(user.userId);
            mViewCamera.setUserId(user.userId);
            mViewScreen.setUserId(user.userId);
            mCallUserView.setUserId(user.userId);
            initUserManager(user);
        }

        private void initUserManager(UserState.UserInfo user) {
            mRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!hasAbilityToManageUser(user)) {
                        return;
                    }
                    if (ConferenceController.sharedInstance().getViewState().userListType.get() == OUT_ROOM) {
                        return;
                    }
                    Map<String, Object> params = new HashMap<>();
                    params.put(KEY_USER_MODEL, user);
                    ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, params);
                }
            });
        }

        private boolean hasAbilityToManageUser(UserState.UserInfo user) {
            UserState.UserInfo localUser = ConferenceController.sharedInstance().getUserState().selfInfo.get();
            if (TextUtils.equals(localUser.userId, user.userId) || localUser.role.get() == TUIRoomDefine.Role.ROOM_OWNER) {
                return true;
            }
            if (localUser.role.get() == TUIRoomDefine.Role.MANAGER) {
                return user.role.get() == TUIRoomDefine.Role.GENERAL_USER;
            }
            return false;
        }
    }
}