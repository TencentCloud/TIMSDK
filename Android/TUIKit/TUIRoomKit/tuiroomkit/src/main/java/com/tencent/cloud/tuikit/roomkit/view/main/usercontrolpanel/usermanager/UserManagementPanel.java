package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.usermanager;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_USER_MANAGEMENT;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.basic.ConfirmDialog;
import com.tencent.cloud.tuikit.roomkit.view.basic.TipToast;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserManagementPanel extends BaseBottomDialog {
    private static final String TAG = "UserManagementPanel";

    private Context                 mContext;
    private UserEntity              mUser;
    private TextView                mTextMessageDisable;
    private TextView                mTextCloseMic;
    private TextView                mTextCloseCamera;
    private TextView                mTextUserName;
    private ImageView               mImageMic;
    private ImageView               mImageCamera;
    private ImageView               mImageMessageDisable;
    private CircleImageView         mImageHead;
    private RelativeLayout          mLayoutMic;
    private RelativeLayout          mLayoutCamera;
    private RelativeLayout          mLayoutKickoffStage;
    private RelativeLayout          mLayoutInviteToStage;
    private RelativeLayout          mLayoutModifyName;
    private UserManagementViewModel mViewModel;
    private ModifyNameKeyboard      mKeyBoard;

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            onUserNameCardChanged(item.userId, item.userName);
        }
    };

    public UserManagementPanel(@NonNull Context context, UserEntity user) {
        super(context);
        mContext = context;
        mUser = user;
        mViewModel = new UserManagementViewModel(mContext, user, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_USER_MANAGEMENT, null);
        ConferenceController.sharedInstance().getUserState().allUsers.removeObserver(mAllUserObserver);
        mViewModel.destroy();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_user_manager;
    }

    @Override
    protected void initView() {
        initUserInfoView();
        initMediaView();

        initMessageDisableView();
        initKickOutView();
        initKickOffSeatView();
        initInviteTakeSeatView();

        initTransferOwnerView();
        initManagerAddView();
        initManagerRemoveView();
        initModifyNameView();
        ConferenceController.sharedInstance().getUserState().allUsers.observe(mAllUserObserver);
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
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
    }

    @Override
    public void onDetachedFromWindow() {
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

    public void updateMicState(boolean isOpened) {
        mImageMic.setSelected(isOpened);
        if (isOpened) {
            mTextCloseMic.setText(getContext().getString(R.string.tuiroomkit_item_close_microphone));
        } else {
            mTextCloseMic.setText(getContext().getString(R.string.tuiroomkit_item_request_open_microphone));
        }
    }

    public void updateCameraState(boolean isOpened) {
        mImageCamera.setSelected(isOpened);
        if (isOpened) {
            mTextCloseCamera.setText(getContext().getString(R.string.tuiroomkit_item_close_camera));
        } else {
            mTextCloseCamera.setText(getContext().getString(R.string.tuiroomkit_item_request_open_camera));
        }
    }

    public void updateMessageEnableState(boolean isEnable) {
        mImageMessageDisable.setSelected(isEnable);
        if (isEnable) {
            mTextMessageDisable.setText(getContext().getString(R.string.tuiroomkit_mute_user));
        } else {
            mTextMessageDisable.setText(getContext().getString(R.string.tuiroomkit_un_mute_user));
        }
    }

    private void initUserInfoView() {
        mImageHead = findViewById(R.id.image_head);
        mTextUserName = findViewById(R.id.tv_user_name);
        String userName = TextUtils.isEmpty(mUser.getNameCard()) ? mUser.getUserName() : mUser.getNameCard();
        if (mViewModel.isSelf()) {
            userName = userName + getContext().getString(R.string.tuiroomkit_me);
        }
        mTextUserName.setText(userName);
        ImageLoader.loadImage(mContext, mImageHead, mUser.getAvatarUrl(), R.drawable.tuiroomkit_head);
    }

    private void initMediaView() {
        mImageMic = findViewById(R.id.image_mic);
        mImageCamera = findViewById(R.id.image_camera);
        mTextCloseMic = findViewById(R.id.tv_close_mic);
        mTextCloseCamera = findViewById(R.id.tv_open_camera);
        mLayoutMic = findViewById(R.id.ll_mute_mic);
        mLayoutCamera = findViewById(R.id.ll_close_camera);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_MEDIA_CONTROL)) {
            mLayoutMic.setVisibility(View.GONE);
            mLayoutCamera.setVisibility(View.GONE);
            return;
        }
        mLayoutMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.muteUserAudio();
                dismiss();
            }
        });
        mLayoutCamera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.muteUserVideo();
                dismiss();
            }
        });
        updateCameraState(mUser.isHasVideoStream());
        updateMicState(mUser.isHasAudioStream());
    }

    private void initMessageDisableView() {
        mImageMessageDisable = findViewById(R.id.tuiroomkit_image_message_disable);
        mTextMessageDisable = findViewById(R.id.tuiroomkit_tv_message_disable);
        View layoutMessageDisable = findViewById(R.id.tuiroomkit_ll_message_disable);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_MESSAGE_ENABLE)) {
            layoutMessageDisable.setVisibility(View.GONE);
            return;
        }
        layoutMessageDisable.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.switchSendingMessageAbility();
                dismiss();
            }
        });
        updateMessageEnableState(mUser.isEnableSendingMessage());
    }

    private void initTransferOwnerView() {
        View layoutTransferOwner = findViewById(R.id.tuiroomkit_ll_transfer_owner);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_OWNER_TRANSFER)) {
            layoutTransferOwner.setVisibility(View.GONE);
            return;
        }
        layoutTransferOwner.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showTransferOwnerDialog();
                dismiss();
            }
        });
    }

    private void initManagerAddView() {
        View layoutManagerControl = findViewById(R.id.tuiroomkit_ll_manager_add);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_MANAGER_CONTROL)
                || mUser.getRole() == TUIRoomDefine.Role.MANAGER) {
            layoutManagerControl.setVisibility(View.GONE);
            return;
        }
        layoutManagerControl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.switchManagerRole(new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        String name = TextUtils.isEmpty(mUser.getNameCard()) ? mUser.getUserName() : mUser.getNameCard();
                        TipToast.build()
                                .setDuration(Toast.LENGTH_LONG)
                                .setMessage(mContext.getString(R.string.tuiroomkit_make_user_as_manager, name))
                                .show(mContext);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "onError error=" + error + " message=" + message);
                    }
                });
                dismiss();
            }
        });
    }

    private void initModifyNameView() {
        mLayoutModifyName = findViewById(R.id.tuiroomkit_rl_modify_name);
        String name = TextUtils.isEmpty(mUser.getNameCard()) ? mUser.getUserName() : mUser.getNameCard();
        mKeyBoard = new ModifyNameKeyboard(mContext, mUser.getUserId(), name);
        mLayoutModifyName.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mKeyBoard.show();
                dismiss();
            }
        });
    }

    private void initManagerRemoveView() {
        View layoutManagerControl = findViewById(R.id.tuiroomkit_ll_manager_remove);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_MANAGER_CONTROL)
                || mUser.getRole() != TUIRoomDefine.Role.MANAGER) {
            layoutManagerControl.setVisibility(View.GONE);
            return;
        }
        layoutManagerControl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.switchManagerRole(new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        String name = TextUtils.isEmpty(mUser.getNameCard()) ? mUser.getUserName() : mUser.getNameCard();
                        TipToast.build()
                                .setDuration(Toast.LENGTH_LONG)
                                .setMessage(mContext.getString(R.string.tuiroomkit_make_user_as_general, name))
                                .show(mContext);
                        if (mViewModel.isDisableScreenShare()) {
                            mViewModel.stopScreenShareAfterManagerRemove();
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "onError error=" + error + " message=" + message);
                    }
                });
                dismiss();
            }
        });
    }

    private void initKickOutView() {
        View layoutKickOut = findViewById(R.id.tuiroomkit_ll_kick_out);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_KICK_OUT_ROOM)) {
            layoutKickOut.setVisibility(View.GONE);
            return;
        }
        layoutKickOut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showKickDialog(mUser.getUserId(), TextUtils.isEmpty(mUser.getNameCard()) ? mUser.getUserName() : mUser.getNameCard());
                dismiss();
            }
        });
    }

    private void initKickOffSeatView() {
        mLayoutKickoffStage = findViewById(R.id.ll_kick_off_stage);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_SEAT_CONTROL)
                || !mViewModel.isEnableSeatControl() || !mUser.isOnSeat()) {
            mLayoutKickoffStage.setVisibility(View.GONE);
            return;
        }
        mLayoutKickoffStage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.kickOffStage();
                dismiss();
            }
        });
    }

    private void initInviteTakeSeatView() {
        mLayoutInviteToStage = findViewById(R.id.ll_invite_to_stage);
        if (!mViewModel.checkPermission(UserManagementViewModel.ACTION_SEAT_CONTROL)
                || !mViewModel.isEnableSeatControl() || mUser.isOnSeat()) {
            mLayoutInviteToStage.setVisibility(View.GONE);
            return;
        }
        mLayoutInviteToStage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.inviteToStage();
                dismiss();
            }
        });
    }

    private void showTransferOwnerDialog() {
        AppCompatActivity activity = null;
        if (mContext instanceof AppCompatActivity) {
            activity = (AppCompatActivity) mContext;
        }
        if (activity == null) {
            return;
        }
        String name = TextUtils.isEmpty(mUser.getNameCard()) ? mUser.getUserName() : mUser.getNameCard();
        BaseDialogFragment.build()
                .setTitle(mContext.getString(R.string.tuiroomkit_dialog_transfer_owner_title, name))
                .setContent(mContext.getString(R.string.tuiroomkit_dialog_transfer_owner_content))
                .setNegativeName(mContext.getString(R.string.tuiroomkit_cancel))
                .setPositiveName(mContext.getString(R.string.tuiroomkit_dialog_transfer_owner_confirm))
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        mViewModel.forwardMaster(new TUIRoomDefine.ActionCallback() {
                            @Override
                            public void onSuccess() {
                                TipToast.build().setDuration(Toast.LENGTH_LONG).setMessage(
                                        mContext.getString(R.string.tuiroomkit_toast_transfer_owner_success, name)).show(mContext);
                                if (mViewModel.isDisableScreenShare()) {
                                    mViewModel.stopScreenShareAfterTransferOwner();
                                }
                            }

                            @Override
                            public void onError(TUICommonDefine.Error error, String message) {
                                Log.e(TAG, "forwardMaster onError error=" + error + " message=" + message);
                            }
                        });
                    }
                })
                .showDialog(activity, "showTransferOwnerDialog");
    }

    public void onUserNameCardChanged(String userId, String userName) {
        if (!TextUtils.equals(mUser.getUserId(), userId) || TextUtils.isEmpty(userName)) {
            return;
        }
        if (TextUtils.equals(userId, ConferenceController.sharedInstance().getUserState().selfInfo.get().userId)) {
            userName += getContext().getString(R.string.tuiroomkit_me);
        }
        mTextUserName.setText(userName);
    }

}
