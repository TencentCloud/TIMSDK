package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.widget.AppCompatImageButton;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.base.UserBaseAdapter;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;

import java.util.HashMap;
import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserListAdapter extends UserBaseAdapter {
    private boolean                  mIsOwner;
    private String                   mSelfId;
    private Context                  mContext;
    private TUIRoomDefine.SpeechMode mSpeechMode;

    public UserListAdapter(Context context) {
        super(context);
        this.mContext = context;
    }

    public void setUserId(String userId) {
        mSelfId = userId;
    }

    public void setOwner(boolean isOwner) {
        this.mIsOwner = isOwner;
    }

    public void setSpeechMode(TUIRoomDefine.SpeechMode speechMode) {
        this.mSpeechMode = speechMode;
    }

    public class ViewHolder extends UserBaseViewHolder {
        private View                 mRootView;
        private TextView             mTextUserName;
        private Button               mBtnInvite;
        private CircleImageView      mImageHead;
        private AppCompatImageButton mImageAudio;
        private AppCompatImageButton mImageVideo;

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
        }

        @Override
        public void bind(Context context, final UserModel model) {
            ImageLoader.loadImage(context, mImageHead, model.userAvatar, R.drawable.tuiroomkit_head);
            String userName = model.userName;
            if (TextUtils.isEmpty(userName)) {
                userName = model.userId;
            }
            if (model.userId.equals(mSelfId)) {
                userName = userName + mContext.getString(R.string.tuiroomkit_me);
            }
            mTextUserName.setText(userName);
            mImageAudio.setSelected(model.isAudioAvailable);
            mImageVideo.setSelected(model.isVideoAvailable);

            if (TUIRoomDefine.SpeechMode.FREE_TO_SPEAK.equals(mSpeechMode) || model.isOnSeat) {
                mImageAudio.setVisibility(View.VISIBLE);
                mImageVideo.setVisibility(View.VISIBLE);
                mBtnInvite.setVisibility(View.GONE);
            } else {
                mImageAudio.setVisibility(View.GONE);
                mImageVideo.setVisibility(View.GONE);
                mBtnInvite.setVisibility(mIsOwner ? View.VISIBLE : View.GONE);
                mBtnInvite.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mIsOwner) {
                            Map<String, Object> params = new HashMap<>();
                            params.put("userId", model.userId);
                            RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT,
                                    params);
                        }
                    }

                });
            }
            mRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!mIsOwner && !mSelfId.equals(model.userId)) {
                        return;
                    }
                    Map<String, Object> params = new HashMap<>();
                    params.put("userModel", model);
                    RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT,
                            params);
                }
            });
        }
    }

    @Override
    protected UserBaseViewHolder createViewHolder(View view) {
        return new ViewHolder(view);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_item_remote_user_list;
    }
}