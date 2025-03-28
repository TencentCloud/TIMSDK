package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.layout;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.ConferenceVideoView;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.RoundRelativeLayout;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.UserVolumePromptView;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.viewmodel.UserEntity;

import java.util.List;

public class UserListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int TYPE_SELF  = 0;
    private static final int TYPE_OTHER = 1;

    public static final String PAYLOAD_AUDIO = "PAYLOAD_AUDIO";
    public static final String PAYLOAD_VIDEO = "PAYLOAD_VIDEO";

    private Context mContext;

    private List<UserEntity> mList;

    private final int mRoundRadius;

    private OnItemClickListener mItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(View view, int position);

        void onItemDoubleClick(View view, int position);
    }

    public UserListAdapter(Context context, List<UserEntity> list) {
        this.mContext = context;
        this.mList = list;
        mRoundRadius = (int) context.getResources().getDimension(R.dimen.tuivideoseat_video_view_conor);
    }

    public void setItemClickListener(OnItemClickListener clickListener) {
        mItemClickListener = clickListener;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.tuivideoseat_item_member, parent, false);
        return new ViewHolder(view, viewType);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        UserEntity item = mList.get(position);
        ((ViewHolder) holder).bind(item);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position,
                                 @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
            return;
        }
        if (payloads.contains(PAYLOAD_AUDIO)) {
            UserEntity item = mList.get(position);
            ((ViewHolder) holder).setVolume(item);
            ((ViewHolder) holder).updateVolumeEffect(item.getAudioVolume());
            ((ViewHolder) holder).enableVolumeEffect(item.isAudioAvailable());
        }
        if (payloads.contains(PAYLOAD_VIDEO)) {
            ((ViewHolder) holder).updateUserInfoVisibility(mList.get(position));
        }
    }

    @Override
    public int getItemViewType(int position) {
        UserEntity memberEntity = mList.get(position);
        if (memberEntity != null) {
            if (memberEntity.isSelf()) {
                return TYPE_SELF;
            }
        }
        return TYPE_OTHER;
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private int                  mViewType;
        private View                 mTalkView;
        private View                 mViewBackground;
        private TextView             mUserNameTv;
        private ImageView            mIvRoomManage;
        private UserVolumePromptView mUserMic;
        private ImageFilterView      mUserHeadImg;
        private UserEntity           mMemberEntity;
        private FrameLayout          mVideoContainer;
        private RoundRelativeLayout  mTopLayout;

        private final ConferenceVideoView.ClickListener clickListener = new ConferenceVideoView.ClickListener() {
            @Override
            public void onSingleClick(View view) {
                if (mItemClickListener != null) {
                    mItemClickListener.onItemClick(view, getBindingAdapterPosition());
                }
            }

            @Override
            public void onDoubleClick(View view) {
                if (mItemClickListener != null) {
                    mItemClickListener.onItemDoubleClick(view, getBindingAdapterPosition());
                }
            }
        };

        private final Runnable mRunnable = new Runnable() {
            @Override
            public void run() {
                mTalkView.setVisibility(GONE);
                if (mMemberEntity != null) {
                    mMemberEntity.setTalk(false);
                }
            }
        };

        public ViewHolder(View itemView, int type) {
            super(itemView);
            mViewType = type;
            initView(itemView);
        }

        public void updateUserInfoVisibility(UserEntity model) {
            if (model.isSelf()) {
                mViewBackground.setVisibility(model.isVideoAvailable() ? GONE : VISIBLE);
                mUserHeadImg.setVisibility(model.isVideoAvailable() ? GONE : VISIBLE);
            } else {
                mViewBackground.setVisibility(model.isVideoPlaying() ? GONE : VISIBLE);
                mUserHeadImg.setVisibility(model.isVideoPlaying() ? GONE : VISIBLE);
            }
            mIvRoomManage.setVisibility(model.getRole() != TUIRoomDefine.Role.GENERAL_USER ? VISIBLE : GONE);
            if (model.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                mIvRoomManage.setBackgroundResource(R.drawable.tuiroomkit_icon_video_room_owner);
            } else if (model.getRole() == TUIRoomDefine.Role.MANAGER) {
                mIvRoomManage.setBackgroundResource(R.drawable.tuiroomkit_icon_video_room_manager);
            }
        }

        public void updateVolumeEffect(int volume) {
            mUserMic.updateVolumeEffect(volume);
        }

        public void enableVolumeEffect(boolean enable) {
            mUserMic.enableVolumeEffect(enable);
        }

        public void setVolume(UserEntity userEntity) {
            if (userEntity.isScreenShareAvailable()) {
                return;
            }
            mTalkView.setVisibility(userEntity.isTalk() ? VISIBLE : GONE);
            if (userEntity.isTalk()) {
                mTalkView.removeCallbacks(mRunnable);
                mTalkView.postDelayed(mRunnable, 2000);
            }
        }

        private void bind(final UserEntity model) {
            mMemberEntity = model;
            updateUserInfoVisibility(model);
            addRoomVideoView(model);
            ImageLoader.loadImage(mContext, mUserHeadImg, model.getUserAvatar(), R.drawable.tuivideoseat_head);
            mUserNameTv.setText(model.getUserName());
            enableVolumeEffect(model.isAudioAvailable());
            updateVolumeEffect(model.getAudioVolume());

            mTopLayout.setRadius(mRoundRadius);
            int backGroundId = R.drawable.tuivideoseat_talk_bg_round;
            mTalkView.setBackground(mContext.getResources().getDrawable(backGroundId));
        }

        private void addRoomVideoView(UserEntity userEntity) {
            ConferenceVideoView videoView = userEntity.getRoomVideoView();
            if (videoView == null) {
                return;
            }
            ViewParent viewParent = videoView.getParent();
            if (viewParent instanceof ViewGroup) {
                if (viewParent == mVideoContainer) {
                    return;
                }
                ((ViewGroup) viewParent).removeView(videoView);
            }
            mVideoContainer.removeAllViews();
            mVideoContainer.addView(videoView);
            videoView.setClickListener(clickListener);
            videoView.enableScale(userEntity.isScreenShareAvailable());
        }

        private void initView(final View itemView) {
            mTopLayout = itemView.findViewById(R.id.rl_content);
            mUserNameTv = itemView.findViewById(R.id.tv_user_name);
            mVideoContainer = itemView.findViewById(R.id.fl_container);
            mUserHeadImg = itemView.findViewById(R.id.img_user_head);
            mUserMic = itemView.findViewById(R.id.tuivideoseat_user_mic);
            mIvRoomManage = itemView.findViewById(R.id.tuiroomkit_iv_room_manage);
            mTalkView = itemView.findViewById(R.id.talk_view);
            mViewBackground = itemView.findViewById(R.id.view_background);
        }
    }
}