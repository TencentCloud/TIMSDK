package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.UserManagementViewModel;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.utils.ImageLoader;
import com.tencent.qcloud.tuicore.TUILogin;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserManagementView extends BaseBottomDialog implements View.OnClickListener {
    private Context                 mContext;
    private UserEntity              mUser;
    private TextView                mTextMute;
    private TextView                mTextCloseMic;
    private TextView                mTextUserName;
    private TextView                mTextCloseCamera;
    private ImageView               mImageMic;
    private ImageView               mImageCamera;
    private ImageView               mImageMute;
    private CircleImageView         mImageHead;
    private LinearLayout            mLayoutMuteMic;
    private LinearLayout            mLayoutCamera;
    private LinearLayout            mLayoutKickUser;
    private LinearLayout            mLayoutKickoffStage;
    private LinearLayout            mLayoutInviteToStage;
    private LinearLayout            mLayoutMuteUser;
    private LinearLayout            mLayoutForwardMaster;
    private UserManagementViewModel mViewModel;

    public UserManagementView(@NonNull Context context, UserEntity user) {
        super(context);
        mContext = context;
        mUser = user;
        mViewModel = new UserManagementViewModel(mContext, user, this);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_user_manager;
    }

    @Override
    protected void initView() {
        mImageHead = findViewById(R.id.image_head);
        mImageMic = findViewById(R.id.image_mic);
        mImageCamera = findViewById(R.id.image_camera);
        mImageMute = findViewById(R.id.image_mute);
        mTextUserName = findViewById(R.id.tv_user_name);
        mTextCloseMic = findViewById(R.id.tv_close_mic);
        mTextCloseCamera = findViewById(R.id.tv_open_camera);
        mTextMute = findViewById(R.id.tv_mute_user);
        mLayoutMuteMic = findViewById(R.id.ll_mute_mic);
        mLayoutCamera = findViewById(R.id.ll_close_camera);
        mLayoutForwardMaster = findViewById(R.id.ll_forward_master);
        mLayoutMuteUser = findViewById(R.id.ll_mute_user);
        mLayoutKickUser = findViewById(R.id.ll_kick_out);
        mLayoutKickoffStage = findViewById(R.id.ll_kick_off_stage);
        mLayoutInviteToStage = findViewById(R.id.ll_invite_to_stage);

        mLayoutMuteMic.setOnClickListener(this);
        mLayoutCamera.setOnClickListener(this);
        mLayoutForwardMaster.setOnClickListener(this);
        mLayoutMuteUser.setOnClickListener(this);
        mLayoutKickUser.setOnClickListener(this);
        mLayoutKickoffStage.setOnClickListener(this);
        mLayoutInviteToStage.setOnClickListener(this);

        if (mViewModel.isEnableSeatControl()) {
            updateLayout(mUser.isOnSeat());
        }
        updateCameraState(mUser.isHasVideoStream());
        updateMicState(mUser.isHasAudioStream());
        updateMuteState(!mUser.isDisableSendingMessage());

        ImageLoader.loadImage(getContext(), mImageHead, mUser.getAvatarUrl(), R.drawable.tuiroomkit_head);

        if (mViewModel.isSelf()) {
            String userName = mUser.getUserName() + getContext().getString(R.string.tuiroomkit_me);
            mTextUserName.setText(userName);
            mLayoutForwardMaster.setVisibility(View.GONE);
            mLayoutMuteUser.setVisibility(View.GONE);
            mLayoutKickUser.setVisibility(View.GONE);
            mLayoutKickoffStage.setVisibility(View.GONE);
            mLayoutInviteToStage.setVisibility(View.GONE);
        } else {
            mTextUserName.setText(mUser.getUserName());
        }
    }

    public void updateLayout(boolean isOnSeat) {
        if (isOnSeat) {
            mLayoutMuteUser.setVisibility(View.GONE);
            mLayoutKickoffStage.setVisibility(View.VISIBLE);
            mLayoutInviteToStage.setVisibility(View.GONE);
            mLayoutCamera.setVisibility(View.VISIBLE);
            mLayoutMuteMic.setVisibility(View.VISIBLE);
        } else {
            mLayoutInviteToStage.setVisibility(View.VISIBLE);
            mLayoutCamera.setVisibility(View.GONE);
            mLayoutKickoffStage.setVisibility(View.GONE);
            mLayoutMuteMic.setVisibility(View.GONE);
        }
    }

    public void showTransferRoomSuccessDialog() {
        ConfirmDialog confirmDialog = new ConfirmDialog(mContext);
        confirmDialog.setCancelable(true);
        confirmDialog.setMessage(mContext.getString(R.string.tuiroomkit_you_have_transferred_master));
        confirmDialog.setPositiveText(mContext.getString(R.string.tuiroomkit_dialog_ok));
        confirmDialog.setPositiveClickListener(new ConfirmDialog.PositiveClickListener() {
            @Override
            public void onClick() {
                confirmDialog.dismiss();
            }
        });
        confirmDialog.show();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.ll_mute_mic) {
            mViewModel.muteUserAudio();
            dismiss();
        } else if (v.getId() == R.id.ll_close_camera) {
            mViewModel.muteUserVideo();
            dismiss();
        } else if (v.getId() == R.id.ll_forward_master) {
            mViewModel.forwardMaster();
            dismiss();
        } else if (v.getId() == R.id.ll_mute_user) {
            mViewModel.muteUser();
            dismiss();
        } else if (v.getId() == R.id.ll_kick_out) {
            dismiss();
            showKickDialog(mUser.getUserId(), mUser.getUserName());
        } else if (v.getId() == R.id.ll_kick_off_stage) {
            mViewModel.kickOffStage();
        } else if (v.getId() == R.id.ll_invite_to_stage) {
            mViewModel.inviteToStage();
        }
    }

    @Override
    public void onDetachedFromWindow() {
        mViewModel.destroy();
        super.onDetachedFromWindow();
    }

    public void showKickDialog(final String userId, String userName) {
        final ConfirmDialog confirmDialog = new ConfirmDialog(mContext);
        confirmDialog.setCancelable(true);
        confirmDialog.setMessage(mContext.getString(R.string.tuiroomkit_kick_user_confirm, userName));
        if (confirmDialog.isShowing()) {
            confirmDialog.dismiss();
            return;
        }
        confirmDialog.setPositiveText(mContext.getString(R.string.tuiroomkit_dialog_ok));
        confirmDialog.setNegativeText(mContext.getString(R.string.tuiroomkit_dialog_cancel));
        confirmDialog.setPositiveClickListener(new ConfirmDialog.PositiveClickListener() {
            @Override
            public void onClick() {
                mViewModel.kickUser(userId);
                confirmDialog.dismiss();
            }
        });

        confirmDialog.setNegativeClickListener(new ConfirmDialog.NegativeClickListener() {
            @Override
            public void onClick() {
                confirmDialog.dismiss();
            }
        });
        confirmDialog.show();
    }

    public void updateMicState(boolean isSelect) {
        mImageMic.setSelected(isSelect);
        if (isSelect) {
            mTextCloseMic.setText(getContext().getString(R.string.tuiroomkit_item_close_microphone));
        } else {
            mTextCloseMic.setText(getContext().getString(R.string.tuiroomkit_item_open_microphone));
        }
    }

    public void updateCameraState(boolean isSelect) {
        mImageCamera.setSelected(isSelect);
        if (isSelect) {
            mTextCloseCamera.setText(getContext().getString(R.string.tuiroomkit_item_close_camera));
        } else {
            mTextCloseCamera.setText(getContext().getString(R.string.tuiroomkit_item_open_camera));
        }
    }

    public void updateMuteState(boolean isSelect) {
        mImageMute.setSelected(isSelect);
        if (isSelect) {
            mTextMute.setText(getContext().getString(R.string.tuiroomkit_mute_user));
        } else {
            mTextMute.setText(getContext().getString(R.string.tuiroomkit_un_mute_user));
        }
    }
}
