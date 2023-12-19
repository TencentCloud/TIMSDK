package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import static android.view.View.INVISIBLE;
import static android.view.View.VISIBLE;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_USER_LIST;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_INVITE_PANEL_SECOND;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.UserListViewModel;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;

public class UserListPanel extends BaseBottomDialog implements View.OnClickListener {
    private static final String TAG = "UserListPanel";

    private Context           mContext;
    private TextView          mBtnConfirm;
    private TextView          mMuteAudioAllBtn;
    private TextView          mMuteVideoAllBtn;
    private TextView          mMoreOptions;
    private TextView          mMemberCount;
    private EditText          mEditSearch;
    private LinearLayout      mBtnInvite;
    private RecyclerView      mRecyclerUserList;
    private UserListAdapter   mUserListAdapter;
    private UserListViewModel mViewModel;

    public UserListPanel(Context context) {
        super(context);
        mContext = context;
        mViewModel = new UserListViewModel(mContext, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        RoomEventCenter.getInstance().notifyUIEvent(DISMISS_USER_LIST, null);
        mViewModel.destroy();
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
        mRecyclerUserList = findViewById(R.id.rv_user_list);
        mBtnConfirm = findViewById(R.id.btn_confirm);
        mEditSearch = findViewById(R.id.et_search);
        mBtnInvite = findViewById(R.id.btn_invite);
        mMuteAudioAllBtn.setOnClickListener(this);
        mMuteVideoAllBtn.setOnClickListener(this);
        mMoreOptions.setOnClickListener(this);
        mBtnConfirm.setOnClickListener(this);
        mBtnInvite.setOnClickListener(this);
        findViewById(R.id.tuiroomkit_rl_title).setOnClickListener(this);

        mEditSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String userName = mEditSearch.getText().toString();
                if (TextUtils.isEmpty(userName)) {
                    mUserListAdapter.setDataList(mViewModel.getUserList());
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        mEditSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    String userName = mEditSearch.getText().toString();
                    mUserListAdapter.setDataList(mViewModel.searchUserByKeyWords(userName));
                }
                return false;
            }
        });

        mRecyclerUserList.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));
        mUserListAdapter = new UserListAdapter(mContext);
        mRecyclerUserList.setAdapter(mUserListAdapter);
        mRecyclerUserList.setHasFixedSize(true);

        mUserListAdapter.setUserId(TUILogin.getUserId());
        mUserListAdapter.setSpeechMode(RoomEngineManager.sharedInstance().getRoomStore().roomInfo.speechMode);
        mUserListAdapter.setDataList(mViewModel.getUserList());
        mViewModel.updateViewInitState();
    }

    public void updateMemberCount(int memberCount) {
        mMemberCount.setText(mContext.getString(R.string.tuiroomkit_tv_member_list, memberCount));
    }

    public void setOwner(boolean isOwner) {
        mMuteAudioAllBtn.setVisibility(isOwner ? VISIBLE : INVISIBLE);
        mMuteVideoAllBtn.setVisibility(isOwner ? VISIBLE : INVISIBLE);
        mMoreOptions.setVisibility(isOwner ? VISIBLE : INVISIBLE);
        mBtnConfirm.setVisibility(isOwner ? INVISIBLE : VISIBLE);
        mUserListAdapter.setOwner(isOwner);
        mUserListAdapter.notifyDataSetChanged();
    }

    public void notifyUserEnter(int position) {
        mUserListAdapter.notifyItemInserted(position);
    }

    public void notifyUserExit(int position) {
        mUserListAdapter.notifyItemRemoved(position);
    }

    public void notifyUserStateChanged(int position) {
        mUserListAdapter.notifyItemChanged(position);
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

    public void disableMuteAllVideo(boolean disable) {
        if (disable) {
            ToastUtil.toastShortMessageCenter(getContext().getString(R.string.tuiroomkit_mute_all_camera_toast));
        } else {
            ToastUtil.toastShortMessageCenter(getContext().getString(R.string.tuiroomkit_toast_not_mute_all_video));
        }
    }

    public void disableMuteAllAudio(boolean disable) {
        if (disable) {
            ToastUtil.toastShortMessageCenter(getContext().getString(R.string.tuiroomkit_mute_all_mic_toast));
        } else {
            ToastUtil.toastShortMessageCenter(getContext().getString(R.string.tuiroomkit_toast_not_mute_all_audio));
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btn_confirm) {
            if (isShowing()) {
                dismiss();
            } else {
                show();
            }
        } else if (v.getId() == R.id.toolbar) {
            dismiss();
        } else if (v.getId() == R.id.btn_mute_audio_all) {
            mViewModel.muteAllUserAudio();
        } else if (v.getId() == R.id.btn_mute_video_all) {
            mViewModel.muteAllUserVideo();
        } else if (v.getId() == R.id.btn_mute_more_options || v.getId() == R.id.btn_invite) {
            RoomEventCenter.getInstance().notifyUIEvent(SHOW_INVITE_PANEL_SECOND, null);
        }
    }

    public void showUserManagementView(UserEntity user) {
        UserManagementView userManagementView = new UserManagementView(mContext, user);
        try {
            userManagementView.show();
        } catch (WindowManager.BadTokenException e) {
            e.printStackTrace();
            if (mContext != null && mContext instanceof Activity) {
                Activity activity = (Activity) mContext;
                Log.e(TAG, "Activity is running : " + activity.isFinishing());
            }
        }
    }
}

