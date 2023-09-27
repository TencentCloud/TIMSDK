package com.tencent.cloud.tuikit.roomkit.view.component;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_MODEL;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.widget.AppCompatImageButton;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.base.UserBaseAdapter;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.HashMap;
import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserListAdapter extends UserBaseAdapter {
    private boolean                  mIsOwner;
    private String                   mSelfId;
    private Context                  mContext;
    private TUIRoomDefine.SpeechMode mSpeechMode;
    private TUIRoomDefine.RoomInfo   mRoomInfo;

    public UserListAdapter(Context context) {
        super(context);
        mContext = context;
        mRoomInfo = RoomEngineManager.sharedInstance().getRoomStore().roomInfo;
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
        private LinearLayout         mOwnerIdentify;

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
            mOwnerIdentify = itemView.findViewById(R.id.room_owner);
        }

        @Override
        public void bind(Context context, final UserEntity user) {
            if (user.getVideoStreamType() == SCREEN_STREAM) {
                mRootView.setLayoutParams(new RecyclerView.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, 0));
                return;
            }
            if (mRootView.getHeight() == 0) {
                mRootView.setLayoutParams(
                        new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ScreenUtil.dip2px(70)));
            }
            ImageLoader.loadImage(context, mImageHead, user.getAvatarUrl(), R.drawable.tuiroomkit_head);
            String userName = user.getUserName();
            if (TextUtils.isEmpty(userName)) {
                userName = user.getUserId();
            }
            if (TextUtils.equals(user.getUserId(), mSelfId)) {
                userName = userName + mContext.getString(R.string.tuiroomkit_me);
            }
            mOwnerIdentify.setVisibility(TextUtils.equals(user.getUserId(), mRoomInfo.ownerId)
                    ? View.VISIBLE : View.GONE);
            mTextUserName.setText(userName);
            mImageAudio.setSelected(user.isHasAudioStream());
            mImageVideo.setSelected(user.isHasVideoStream());

            if (TUIRoomDefine.SpeechMode.FREE_TO_SPEAK.equals(mSpeechMode) || user.isOnSeat()) {
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
                            params.put("userId", user.getUserId());
                            RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT,
                                    params);
                        }
                    }

                });
            }
            mRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!mIsOwner && !TextUtils.equals(mSelfId, user.getUserId())) {
                        return;
                    }
                    Map<String, Object> params = new HashMap<>();
                    params.put(KEY_USER_MODEL, user);
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