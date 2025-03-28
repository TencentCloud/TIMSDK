package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import static android.view.View.GONE;
import static android.view.View.INVISIBLE;
import static android.view.View.VISIBLE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.SHOW_MORE_FUNCTION_PANEL;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.InvitationController;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.usermanager.UserManagementPanel;
import com.trtc.tuikit.common.livedata.Observer;

public class UserListPanel extends BaseBottomDialog implements View.OnClickListener {
    private static final String TAG = "UserListPanel";

    private static final float PORTRAIT_HEIGHT_OF_SCREEN = 0.9f;

    private Context           mContext;
    private TextView          mMuteAudioAllBtn;
    private TextView          mMuteVideoAllBtn;
    private TextView          mMoreOptions;
    private TextView          mCallAllBtn;
    private TextView          mMemberCount;
    private EditText          mEditSearch;
    private UserListViewModel mViewModel;

    private UserListPanelStateHolder mStateHolder          = new UserListPanelStateHolder();
    private Observer<Boolean>        mUserListTypeObserver = this::updateBottomButtonVisibility;
    private Observer<Boolean>        mUserListSizeObserver = this::updateCallAllButtonVisibility;

    private Observer<Boolean> mScreenOrientationObserver = this::updateViewOrientation;

    public UserListPanel(Context context) {
        super(context);
        mContext = context;
        mViewModel = new UserListViewModel(mContext, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_USER_LIST, null);
        mViewModel.destroy();
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeUserListType(mUserListTypeObserver);
        mStateHolder.observeCallAllButtonState(mUserListSizeObserver);
        ConferenceController.sharedInstance().getViewState().isScreenPortrait.observe(mScreenOrientationObserver);
        ConferenceController.sharedInstance().getInvitationController().initInvitationList();
        MetricsStats.submit(MetricsStats.T_METRICS_USER_LIST_PANEL_SHOW);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getViewState().isScreenPortrait.removeObserver(
                mScreenOrientationObserver);
        mStateHolder.removeObserverListType(mUserListTypeObserver);
        mStateHolder.removeObserverCallButtonState(mUserListSizeObserver);
        ConferenceController.sharedInstance().getViewController().updateSearchUserKeyWord("");
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_panel_user_management;
    }

    @Override
    protected void initView() {
        mMemberCount = findViewById(R.id.main_title);
        mMuteAudioAllBtn = findViewById(R.id.btn_mute_audio_all);
        mMuteVideoAllBtn = findViewById(R.id.btn_mute_video_all);
        mMoreOptions = findViewById(R.id.btn_mute_more_options);
        mCallAllBtn = findViewById(R.id.btn_call_all_user);
        mEditSearch = findViewById(R.id.et_search);
        mMuteAudioAllBtn.setOnClickListener(this);
        mMuteVideoAllBtn.setOnClickListener(this);
        mMoreOptions.setOnClickListener(this);
        mCallAllBtn.setOnClickListener(this);
        findViewById(R.id.tuiroomkit_rl_title).setOnClickListener(this);

        mEditSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String searchWord = mEditSearch.getText().toString();
                ConferenceController.sharedInstance().getViewController().updateSearchUserKeyWord(searchWord);
                MetricsStats.submit(MetricsStats.T_METRICS_USER_LIST_SEARCH);
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        mViewModel.updateViewInitState();

        View view = findViewById(R.id.tuiroomkit_root_user_management_panel);
        setPortraitHeightPercentOfScreen(view, PORTRAIT_HEIGHT_OF_SCREEN);
    }

    public void updateMemberCount(int memberCount) {
        mMemberCount.setText(mContext.getString(R.string.tuiroomkit_tv_member_list, memberCount));
    }

    public void updateViewForRole(TUIRoomDefine.Role role) {
        mMuteAudioAllBtn.setVisibility(role == TUIRoomDefine.Role.GENERAL_USER ? INVISIBLE : VISIBLE);
        mMuteVideoAllBtn.setVisibility(role == TUIRoomDefine.Role.GENERAL_USER ? INVISIBLE : VISIBLE);
        mMoreOptions.setVisibility(role == TUIRoomDefine.Role.GENERAL_USER ? INVISIBLE : VISIBLE);
    }

    public void updateMuteAudioView(boolean isMute) {
        if (isMute) {
            mMuteAudioAllBtn.setText(R.string.tuiroomkit_not_mute_all_audio);
            mMuteAudioAllBtn.setTextColor(mContext.getResources().getColor(R.color.tuiroomkit_color_text_red));
        } else {
            mMuteAudioAllBtn.setText(R.string.tuiroomkit_mute_all_audio);
            mMuteAudioAllBtn.setTextColor(mContext.getResources().getColor(R.color.tuiroomkit_color_text_light_grey));
        }
    }

    public void updateMuteVideoView(boolean isMute) {
        if (isMute) {
            mMuteVideoAllBtn.setText(R.string.tuiroomkit_not_mute_all_video);
            mMuteVideoAllBtn.setTextColor(mContext.getResources().getColor(R.color.tuiroomkit_color_text_red));
        } else {
            mMuteVideoAllBtn.setText(R.string.tuiroomkit_mute_all_video);
            mMuteVideoAllBtn.setTextColor(mContext.getResources().getColor(R.color.tuiroomkit_color_text_light_grey));
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.toolbar) {
            dismiss();
        } else if (v.getId() == R.id.btn_mute_audio_all) {
            showDisableAllMicDialog();
        } else if (v.getId() == R.id.btn_mute_video_all) {
            showDisableAllCameraDialog();
        } else if (v.getId() == R.id.btn_mute_more_options) {
            ConferenceEventCenter.getInstance().notifyUIEvent(SHOW_MORE_FUNCTION_PANEL, null);
        } else if (v.getId() == R.id.btn_call_all_user) {
            InvitationController invitationController = ConferenceController.sharedInstance().getInvitationController();
            invitationController.inviteUsers(invitationController.getInviteeListFormInvitationList(
                    ConferenceController.sharedInstance().getInvitationState().invitationList.getList()), null);
        }
    }

    public void showUserManagementView(UserEntity user) {
        UserManagementPanel userManagementPanel = new UserManagementPanel(mContext, user);
        try {
            userManagementPanel.show();
        } catch (WindowManager.BadTokenException e) {
            e.printStackTrace();
            if (mContext != null && mContext instanceof Activity) {
                Activity activity = (Activity) mContext;
                Log.e(TAG, "Activity is running : " + activity.isFinishing());
            }
        }
    }

    private void showDisableAllMicDialog() {
        if (!(mContext instanceof AppCompatActivity)) {
            Log.e(TAG, "showDisableAllMicDialog mContext is not a Activity");
            return;
        }
        AppCompatActivity activity = (AppCompatActivity) mContext;
        boolean isDisable =
                ConferenceController.sharedInstance().getConferenceState().roomInfo.isMicrophoneDisableForAllUser;
        BaseDialogFragment.build().setTitle(mContext.getString(
                        isDisable ? R.string.tuiroomkit_dialog_unmute_all_audio_title :
                                R.string.tuiroomkit_dialog_mute_all_audio_title)).setContent(mContext.getString(
                        isDisable ? R.string.tuiroomkit_dialog_unmute_all_audio_content :
                                R.string.tuiroomkit_dialog_mute_all_audio_content))
                .setNegativeName(mContext.getString(R.string.tuiroomkit_cancel)).setPositiveName(mContext.getString(
                        isDisable ? R.string.tuiroomkit_dialog_unmute_all_confirm : R.string.tuiroomkit_mute_all_audio))
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        if (isDisable && !ConferenceController.sharedInstance()
                                .getConferenceState().roomInfo.isMicrophoneDisableForAllUser) {
                            RoomToast.toastShortMessageCenter(
                                    getContext().getString(R.string.tuiroomkit_toast_not_mute_all_audio));
                            return;
                        }
                        if (!isDisable && ConferenceController.sharedInstance()
                                .getConferenceState().roomInfo.isMicrophoneDisableForAllUser) {
                            RoomToast.toastShortMessageCenter(
                                    getContext().getString(R.string.tuiroomkit_mute_all_mic_toast));
                            return;
                        }
                        ConferenceController.sharedInstance()
                                .disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.MICROPHONE, !isDisable, null);

                    }
                }).showDialog(activity, "disableDeviceForAllUserByAdmin");
    }

    private void showDisableAllCameraDialog() {
        if (!(mContext instanceof AppCompatActivity)) {
            Log.e(TAG, "showDisableAllCameraDialog mContext is not a Activity");
            return;
        }
        AppCompatActivity activity = (AppCompatActivity) mContext;
        boolean isDisable =
                ConferenceController.sharedInstance().getConferenceState().roomInfo.isCameraDisableForAllUser;
        BaseDialogFragment.build().setTitle(mContext.getString(
                        isDisable ? R.string.tuiroomkit_dialog_unmute_all_video_title :
                                R.string.tuiroomkit_dialog_mute_all_video_title)).setContent(mContext.getString(
                        isDisable ? R.string.tuiroomkit_dialog_unmute_all_video_content :
                                R.string.tuiroomkit_dialog_mute_all_video_content))
                .setNegativeName(mContext.getString(R.string.tuiroomkit_cancel)).setPositiveName(mContext.getString(
                        isDisable ? R.string.tuiroomkit_dialog_unmute_all_confirm : R.string.tuiroomkit_mute_all_video))
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        if (isDisable && !ConferenceController.sharedInstance()
                                .getConferenceState().roomInfo.isCameraDisableForAllUser) {
                            RoomToast.toastShortMessageCenter(
                                    getContext().getString(R.string.tuiroomkit_toast_not_mute_all_video));
                            return;
                        }
                        if (!isDisable && ConferenceController.sharedInstance()
                                .getConferenceState().roomInfo.isCameraDisableForAllUser) {
                            RoomToast.toastShortMessageCenter(
                                    getContext().getString(R.string.tuiroomkit_mute_all_camera_toast));
                            return;
                        }
                        ConferenceController.sharedInstance()
                                .disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.CAMERA, !isDisable, null);

                    }
                }).showDialog(activity, "disableDeviceForAllUserByAdmin");
    }

    private void updateBottomButtonVisibility(boolean isNotEnteredUserTab) {
        if (isNotEnteredUserTab) {
            mMuteAudioAllBtn.setVisibility(GONE);
            mMuteVideoAllBtn.setVisibility(GONE);
            mMoreOptions.setVisibility(GONE);
        } else if (!TUIRoomDefine.Role.GENERAL_USER.equals(ConferenceController.sharedInstance().getUserState().selfInfo.get().role.get())) {
            mMuteAudioAllBtn.setVisibility(VISIBLE);
            mMuteVideoAllBtn.setVisibility(VISIBLE);
            mMoreOptions.setVisibility(VISIBLE);
        }
    }

    private void updateCallAllButtonVisibility(boolean isShow) {
        mCallAllBtn.setVisibility(isShow ? VISIBLE : GONE);
    }

    private void updateViewOrientation(Boolean isScreenPortrait) {
        changeConfiguration(null);
        mStateHolder.removeObserverListType(mUserListTypeObserver);
        mStateHolder.removeObserverCallButtonState(mUserListTypeObserver);
        mStateHolder.observeUserListType(mUserListTypeObserver);
        mStateHolder.observeCallAllButtonState(mUserListTypeObserver);
    }
}

