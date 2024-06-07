package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import static android.view.View.INVISIBLE;
import static android.view.View.VISIBLE;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL_SECOND;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.content.ContextCompat;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.viewmodel.UserListViewModel;
import com.trtc.tuikit.common.livedata.Observer;

public class UserListPanel extends BaseBottomDialog implements View.OnClickListener {
    private static final String TAG = "UserListPanel";

    private static final float PORTRAIT_HEIGHT_OF_SCREEN = 0.9f;

    private Context           mContext;
    private TextView          mMuteAudioAllBtn;
    private TextView          mMuteVideoAllBtn;
    private TextView          mMoreOptions;
    private TextView          mMemberCount;
    private EditText          mEditSearch;
    private LinearLayout      mBtnInvite;
    private LinearLayout      mLayoutOnOffSeatTab;
    private AppCompatButton   mBtnOnSeatTab;
    private AppCompatButton   mBtnOffSeatTab;
    private UserListViewModel mViewModel;

    private UserListPanelStateHolder       mStateHolder = new UserListPanelStateHolder();
    private Observer<UserListPanelUiState> mUiObserver  = this::updateView;

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
        mStateHolder.observe(mUiObserver);
        ConferenceController.sharedInstance().getViewState().isScreenPortrait.observe(mScreenOrientationObserver);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getViewState().isScreenPortrait.removeObserver(
                mScreenOrientationObserver);
        mStateHolder.removeObserver(mUiObserver);
        ConferenceController.sharedInstance().getViewController().updateSearchUserKeyWord("");
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_panel_user_management;
    }

    @Override
    protected void initView() {
        initTabView();
        mMemberCount = findViewById(R.id.main_title);
        mMuteAudioAllBtn = findViewById(R.id.btn_mute_audio_all);
        mMuteVideoAllBtn = findViewById(R.id.btn_mute_video_all);
        mMoreOptions = findViewById(R.id.btn_mute_more_options);
        mEditSearch = findViewById(R.id.et_search);
        mBtnInvite = findViewById(R.id.btn_invite);
        mMuteAudioAllBtn.setOnClickListener(this);
        mMuteVideoAllBtn.setOnClickListener(this);
        mMoreOptions.setOnClickListener(this);
        mBtnInvite.setOnClickListener(this);
        findViewById(R.id.tuiroomkit_rl_title).setOnClickListener(this);

        mEditSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String searchWord = mEditSearch.getText().toString();
                ConferenceController.sharedInstance().getViewController().updateSearchUserKeyWord(searchWord);
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
        } else if (v.getId() == R.id.btn_mute_more_options || v.getId() == R.id.btn_invite) {
            ConferenceEventCenter.getInstance().notifyUIEvent(SHOW_INVITE_PANEL_SECOND, null);
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

    private void initTabView() {
        mLayoutOnOffSeatTab = findViewById(R.id.tuiroomkit_ll_seat_tab);
        mBtnOnSeatTab = findViewById(R.id.tuiroomkit_btn_user_on_seat);
        mBtnOffSeatTab = findViewById(R.id.tuiroomkit_btn_user_off_seat);
        mBtnOnSeatTab.setOnClickListener(v -> {
            ConferenceController.sharedInstance().getViewController().updateOnSeatPanelSelected(true);
        });
        mBtnOffSeatTab.setOnClickListener(v -> {
            ConferenceController.sharedInstance().getViewController().updateOnSeatPanelSelected(false);
        });
    }
    private void updateView(UserListPanelUiState uiState) {
        mLayoutOnOffSeatTab.setVisibility(uiState.isShowOnOffSeatTab ? VISIBLE : View.GONE);
        mBtnOnSeatTab.setBackground(uiState.isOnSeatTabSelected ?
                ContextCompat.getDrawable(mContext, R.drawable.tuiroomkit_bg_user_list_tab_selected) : null);
        mBtnOnSeatTab.setText(
                mContext.getString(R.string.tuiroomkit_user_list_on_seat, String.valueOf(uiState.onSeatUserCount)));
        mBtnOffSeatTab.setBackground(uiState.isOnSeatTabSelected ?
                null : ContextCompat.getDrawable(mContext, R.drawable.tuiroomkit_bg_user_list_tab_selected));
        mBtnOffSeatTab.setText(
                mContext.getString(R.string.tuiroomkit_user_list_off_seat, String.valueOf(uiState.offSeatUserCount)));
    }

    private void updateViewOrientation(Boolean isScreenPortrait) {
        changeConfiguration(null);
        mStateHolder.removeObserver(mUiObserver);
        mStateHolder.observe(mUiObserver);
    }
}

