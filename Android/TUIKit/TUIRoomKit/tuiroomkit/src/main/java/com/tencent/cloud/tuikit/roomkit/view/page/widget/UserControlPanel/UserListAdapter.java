package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_MODEL;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageButton;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserListAdapter extends RecyclerView.Adapter<UserListAdapter.ViewHolder> {
    private Context                mContext;
    private TUIRoomDefine.RoomInfo mRoomInfo  = RoomEngineManager.sharedInstance().getRoomStore().roomInfo;
    private UserModel              mLocalUser = RoomEngineManager.sharedInstance().getRoomStore().userModel;
    private List<UserEntity>       mUserList;

    public UserListAdapter(Context context) {
        super();
        mContext = context;
    }

    public void setDataList(List<UserEntity> userList) {
        mUserList = userList;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_item_remote_user_list, parent, false);
        return new UserListAdapter.ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        UserEntity user = mUserList.get(position);
        holder.bind(mContext, user);
    }

    @Override
    public int getItemCount() {
        return mUserList.size();
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        private View                 mRootView;
        private TextView             mTextUserName;
        private Button               mBtnInvite;
        private CircleImageView      mImageHead;
        private AppCompatImageButton mImageAudio;
        private AppCompatImageButton mImageVideo;
        private LinearLayout         mLayoutRoomOwner;
        private LinearLayout         mLayoutRoomManager;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(final View itemView) {
            mRootView = itemView.findViewById(R.id.cl_user_item_root);
            mImageHead = itemView.findViewById(R.id.img_head);
            mTextUserName = itemView.findViewById(R.id.tv_user_name);
            mBtnInvite = itemView.findViewById(R.id.tv_invite_to_stage);
            mImageAudio = itemView.findViewById(R.id.img_audio);
            mImageVideo = itemView.findViewById(R.id.img_video);
            mLayoutRoomOwner = itemView.findViewById(R.id.tuiroomkit_ll_room_owner);
            mLayoutRoomManager = itemView.findViewById(R.id.tuiroomkit_ll_room_manager);
        }

        private void bind(Context context, final UserEntity user) {
            if (hideItemForScreenSharing(user)) {
                return;
            }
            setUserInfo(context, user);
            setRoomAdminFlag(user);
            setMediaState(user);
            initInviteUser(user);
            initUserManager(user);
        }

        private boolean hideItemForScreenSharing(UserEntity user) {
            if (user.getVideoStreamType() == SCREEN_STREAM) {
                mRootView.setLayoutParams(new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0));
                return true;
            }
            if (mRootView.getHeight() == 0) {
                mRootView.setLayoutParams(
                        new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ScreenUtil.dip2px(70)));
            }
            return false;
        }

        private void setUserInfo(Context context, UserEntity user) {
            String userName = user.getUserName();
            if (TextUtils.isEmpty(userName)) {
                userName = user.getUserId();
            }
            if (TextUtils.equals(user.getUserId(), mLocalUser.userId)) {
                userName = userName + mContext.getString(R.string.tuiroomkit_me);
            }
            mTextUserName.setText(userName);
            ImageLoader.loadImage(context, mImageHead, user.getAvatarUrl(), R.drawable.tuiroomkit_head);
        }

        private void setRoomAdminFlag(UserEntity user) {
            if (user.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
                mLayoutRoomOwner.setVisibility(View.INVISIBLE);
                mLayoutRoomManager.setVisibility(View.INVISIBLE);
                return;
            }
            if (user.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                mLayoutRoomOwner.setVisibility(View.VISIBLE);
                mLayoutRoomManager.setVisibility(View.INVISIBLE);
                return;
            }
            mLayoutRoomOwner.setVisibility(View.INVISIBLE);
            mLayoutRoomManager.setVisibility(View.VISIBLE);
        }

        private void setMediaState(UserEntity user) {
            if (!mRoomInfo.isSeatEnabled || user.isOnSeat()) {
                mImageAudio.setVisibility(View.VISIBLE);
                mImageVideo.setVisibility(View.VISIBLE);
                mImageAudio.setSelected(user.isHasAudioStream());
                mImageVideo.setSelected(user.isHasVideoStream());
            } else {
                mImageAudio.setVisibility(View.GONE);
                mImageVideo.setVisibility(View.GONE);
            }
        }

        private void initInviteUser(UserEntity user) {
            if (shouldShowInviteUser(user)) {
                mBtnInvite.setVisibility(View.VISIBLE);
                mBtnInvite.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Map<String, Object> params = new HashMap<>();
                        params.put("userId", user.getUserId());
                        RoomEventCenter.getInstance()
                                .notifyUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, params);
                    }
                });
            } else {
                mBtnInvite.setVisibility(View.GONE);
            }
        }

        private void initUserManager(UserEntity user) {
            mRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!hasAbilityToManageUser(user)) {
                        return;
                    }
                    Map<String, Object> params = new HashMap<>();
                    params.put(KEY_USER_MODEL, user);
                    RoomEventCenter.getInstance()
                            .notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, params);
                }
            });
        }

        private boolean shouldShowInviteUser(UserEntity user) {
            if (!mRoomInfo.isSeatEnabled) {
                return false;
            }
            if (user.isOnSeat()) {
                return false;
            }
            if (mLocalUser.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
                return false;
            }
            if (mLocalUser.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                return true;
            }
            return user.getRole() == TUIRoomDefine.Role.GENERAL_USER;
        }

        private boolean hasAbilityToManageUser(UserEntity user) {
            if (TextUtils.equals(mLocalUser.userId, user.getUserId())) {
                return false;
            }
            if (mLocalUser.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                return true;
            }
            if (mLocalUser.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
                return TextUtils.equals(mLocalUser.userId, user.getUserId());
            }
            if (TextUtils.equals(mLocalUser.userId, user.getUserId())) {
                return true;
            }
            return user.getRole() == TUIRoomDefine.Role.GENERAL_USER;
        }
    }
}