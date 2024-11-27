package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_USER_MODEL;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserRecyclerViewAdapter extends RecyclerView.Adapter<UserRecyclerViewAdapter.UserViewHolder> {
    private Context                  mContext;
    private List<UserState.UserInfo> mUserList;

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
        holder.bindData(mContext, user);
    }

    @Override
    public int getItemCount() {
        return mUserList.size();
    }

    class UserViewHolder extends RecyclerView.ViewHolder {
        private View             mRootView;
        private TextView         mTextUserName;
        private InviteSeatButton mBtnInvite;
        private CircleImageView  mImageHead;
        private MicIconView      mViewMic;
        private CameraIconView   mViewCamera;
        private CallUserView     mCallUserView;
        private LinearLayout     mLayoutOwner;
        private LinearLayout     mLayoutManager;

        private String mSelfUserId = TUILogin.getUserId();

        public UserViewHolder(View itemView) {
            super(itemView);
            mRootView = itemView.findViewById(R.id.cl_user_item_root);
            mImageHead = itemView.findViewById(R.id.img_head);
            mTextUserName = itemView.findViewById(R.id.tv_user_name);
            mBtnInvite = itemView.findViewById(R.id.tuiroomkit_btn_invite_seat);
            mViewMic = itemView.findViewById(R.id.tuiroomkit_img_mic_state);
            mViewCamera = itemView.findViewById(R.id.tuiroomkit_img_camera_state);

            mCallUserView = itemView.findViewById(R.id.tuiroomkit_call_user_view);
            mLayoutOwner = itemView.findViewById(R.id.tuiroomkit_ll_room_owner);
            mLayoutManager = itemView.findViewById(R.id.tuiroomkit_ll_room_manager);
        }

        public void bindData(Context context, UserState.UserInfo user) {
            bindUserInfo(context, user);
            setRoomAdminFlag(user);
            setMediaState(user);
            initInviteUser(user);
            initUserManager(user);
            initCallUser(user);
        }

        private void bindUserInfo(Context context, UserState.UserInfo user) {
            String userName = user.userName;
            if (TextUtils.isEmpty(userName)) {
                userName = user.userId;
            }
            if (TextUtils.equals(user.userId, mSelfUserId)) {
                userName = userName + mContext.getString(R.string.tuiroomkit_me);
            }
            mTextUserName.setText(userName);
            ImageLoader.loadImage(context, mImageHead, user.avatarUrl, R.drawable.tuiroomkit_head);
        }

        private void setRoomAdminFlag(UserState.UserInfo user) {
            if (user.role.get() == TUIRoomDefine.Role.GENERAL_USER) {
                mLayoutOwner.setVisibility(View.INVISIBLE);
                mLayoutManager.setVisibility(View.INVISIBLE);
                return;
            }
            if (user.role.get() == TUIRoomDefine.Role.ROOM_OWNER) {
                mLayoutOwner.setVisibility(View.VISIBLE);
                mLayoutManager.setVisibility(View.INVISIBLE);
                return;
            }
            mLayoutOwner.setVisibility(View.INVISIBLE);
            mLayoutManager.setVisibility(View.VISIBLE);
        }

        private void setMediaState(UserState.UserInfo user) {
            mViewMic.setUserId(user.userId);
            mViewCamera.setUserId(user.userId);
        }

        private void initInviteUser(UserState.UserInfo user) {
            mBtnInvite.setUserId(user.userId);
        }

        private void initUserManager(UserState.UserInfo user) {
            mRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!hasAbilityToManageUser(user)) {
                        return;
                    }
                    if (ConferenceController.sharedInstance().getViewState().userListType.get() == ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM) {
                        return;
                    }
                    Map<String, Object> params = new HashMap<>();
                    params.put(KEY_USER_MODEL, user);
                    ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, params);
                }
            });
        }

        private void initCallUser(UserState.UserInfo user) {
            mCallUserView.setUserId(user.userId);
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