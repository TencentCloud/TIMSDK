package com.tencent.cloud.tuikit.roomkit.view.component;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.content.Context;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;

import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.UserListViewModel;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;

public class UserListView extends BaseBottomDialog implements
        View.OnClickListener {

    private Context           mContext;
    private TextView          mBtnConfirm;
    private TextView          mMuteAudioAllBtn;
    private TextView          mMuteVideoAllBtn;
    private EditText          mEditSearch;
    private RecyclerView      mRecyclerUserList;
    private UserListAdapter   mUserListAdapter;
    private UserListViewModel mViewModel;

    public UserListView(Context context) {
        super(context);
        mContext = context;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_room_remote_user_list;
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        updateHeightToMatchParent();
    }

    @Override
    protected void intiView() {
        mMuteAudioAllBtn = findViewById(R.id.btn_mute_audio_all);
        mMuteVideoAllBtn = findViewById(R.id.btn_mute_video_all);
        mRecyclerUserList = findViewById(R.id.rv_user_list);
        mBtnConfirm = findViewById(R.id.btn_confirm);
        mEditSearch = findViewById(R.id.et_search);
        mMuteAudioAllBtn.setOnClickListener(this);
        mMuteVideoAllBtn.setOnClickListener(this);
        mBtnConfirm.setOnClickListener(this);
        findViewById(R.id.toolbar).setOnClickListener(this);

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
        mViewModel = new UserListViewModel(mContext, this);
        mUserListAdapter.setUserId(mViewModel.getSelfUserId());
        mUserListAdapter.setSpeechMode(mViewModel.getSpeechMode());
    }

    public void setOwner(boolean isOwner) {
        mMuteAudioAllBtn.setVisibility(isOwner ? VISIBLE : GONE);
        mMuteVideoAllBtn.setVisibility(isOwner ? VISIBLE : GONE);
        mBtnConfirm.setVisibility(isOwner ? GONE : VISIBLE);
        mUserListAdapter.setOwner(isOwner);
        mUserListAdapter.notifyDataSetChanged();
    }

    public void addItem(UserModel userModel) {
        if (mUserListAdapter != null) {
            mUserListAdapter.addItem(userModel);
        }
    }

    public void removeItem(UserModel userModel) {
        if (mUserListAdapter != null) {
            mUserListAdapter.removeItem(userModel);
        }
    }

    public void updateItem(UserModel userModel) {
        if (mUserListAdapter != null) {
            mUserListAdapter.updateItem(userModel);
        }
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
            ToastUtil.toastShortMessage(getContext().getString(R.string.tuiroomkit_mute_all_camera_toast));
        } else {
            ToastUtil.toastShortMessage(getContext().getString(R.string.tuiroomkit_toast_not_mute_all_video));
        }
    }

    public void disableMuteAllAudio(boolean disable) {
        if (disable) {
            ToastUtil.toastShortMessage(getContext().getString(R.string.tuiroomkit_mute_all_mic_toast));
        } else {
            ToastUtil.toastShortMessage(getContext().getString(R.string.tuiroomkit_toast_not_mute_all_audio));
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
        }
    }

    public void destroy() {
        if (mViewModel != null) {
            mViewModel.destroy();
        }
    }

    public void showUserManagementView(UserModel userModel) {
        UserManagementView userManagementView = new UserManagementView(mContext, userModel);
        userManagementView.show();
    }
}

