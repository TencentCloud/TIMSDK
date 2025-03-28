package com.tencent.cloud.tuikit.roomkit.view.main.contacts.view;

import android.app.Activity;
import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.adapter.ContactsAdapter;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.adapter.SelectedPanelAdapter;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.ContactsStateHolder;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.Participants;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.ArrayList;
import java.util.List;

public class ContactsView extends FrameLayout {
    public static final String                         TAG                      = "ContactsView";
    public static final int                            MAX_VISIBLE_USER_AVATARS = 10;
    private             Context                        mContext;
    private             TextView                       mTvContactsTitle;
    private             TextView                       mTvSelectedDialogTitle;
    private             Button                         mBtnConfirmSelect;
    private             RecyclerView                   mRecyclerContacts;
    private             RecyclerView                   mRecyclerSelectedPanel;
    private             LinearLayout                   mLlSelectedDialogLayout;
    private             ContactsAdapter                mContactsAdapter;
    private             SelectedPanelAdapter           mSelectedPanelAdapter;
    private             List<Participants>             mParticipants            = new ArrayList<>();
    private             List<ConferenceDefine.User>    mSelectedList            = new ArrayList<>();
    private             List<ConferenceDefine.User>    mDisableList             = new ArrayList<>();
    private             ContactsStateHolder            mStateHolder             = new ContactsStateHolder();
    private             SelectedParticipantsDialog     mSelectedDialog;
    private             ConfirmSelectCallback          mCallback;
    private             LiveListObserver<Participants> mAttendeesObserver       = new LiveListObserver<Participants>() {//
        @Override
        public void onDataChanged(List<Participants> list) {
            super.onDataChanged(list);
            updateContactsTitle(list.size());
        }

        @Override
        public void onItemChanged(int position, Participants item) {
            super.onItemChanged(position, item);
            updateContacts(item);
            updateMoreParticipantsView();
        }
    };

    public interface ConfirmSelectCallback {
        void confirm(List<ConferenceDefine.User> selectedList);
    }

    public ContactsView(@NonNull Context context) {
        super(context);
        mContext = context;
        initView();
    }

    public void setConfirmSelectedCallback(ConfirmSelectCallback callback) {
        mCallback = callback;
    }

    public void setContacts(List<ConferenceDefine.User> allList, List<ConferenceDefine.User> selectedList, List<ConferenceDefine.User> disableList) {
        mSelectedList = selectedList;
        mDisableList = disableList;
        if (allList == null || allList.isEmpty()) {
            setIMAttendees(selectedList, disableList);
            return;
        }
        for (ConferenceDefine.User user : allList) {
            Participants participants = new Participants();
            participants.userInfo = user;
            participants.isSelected = selectedList.contains(user);
            participants.isDisable = disableList.contains(user);
            mParticipants.add(participants);
        }
        updateContactsView();
    }

    private void setIMAttendees(List<ConferenceDefine.User> selectedList, List<ConferenceDefine.User> disableList) {
        V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                for (V2TIMFriendInfo user : v2TIMFriendInfos) {
                    Participants participant = new Participants();
                    participant.userInfo = new ConferenceDefine.User();
                    participant.userInfo.id = user.getUserID();
                    participant.userInfo.name = user.getUserProfile().getNickName();
                    participant.userInfo.avatarUrl = user.getUserProfile().getFaceUrl();
                    participant.isSelected = selectedList.contains(participant.userInfo);
                    participant.isDisable = disableList.contains(participant.userInfo);
                    mParticipants.add(participant);
                }
                updateContactsView();
            }

            @Override
            public void onError(int code, String desc) {
            }
        });
    }

    private void initView() {
        addView(LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_contacts, this, false));
        mTvContactsTitle = findViewById(R.id.rv_select_participant_title);
        mRecyclerContacts = findViewById(R.id.rv_select_participant);
        mRecyclerSelectedPanel = findViewById(R.id.rv_participant_avatar);
        mLlSelectedDialogLayout = findViewById(R.id.ll_selected_dialog);
        mTvSelectedDialogTitle = findViewById(R.id.tv_participants_title);
        mBtnConfirmSelect = findViewById(R.id.btn_confirm_participants);
        ImageView finishIcon = findViewById(R.id.img_select_participant_arrows_return);
        EditText searchEdit = findViewById(R.id.et_search_participant);

        mSelectedDialog = new SelectedParticipantsDialog(mContext);
        mSelectedDialog.setStateHolder(mStateHolder);
        mStateHolder.observe(mAttendeesObserver);
        mRecyclerContacts.setLayoutManager(new LinearLayoutManager(mContext));
        mContactsAdapter = new ContactsAdapter(mContext);
        mContactsAdapter.setStateHolder(mStateHolder);
        mRecyclerContacts.setAdapter(mContactsAdapter);
        mSelectedPanelAdapter = new SelectedPanelAdapter(mContext);
        mRecyclerSelectedPanel.setAdapter(mSelectedPanelAdapter);
        mRecyclerSelectedPanel.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false));
        mBtnConfirmSelect.setOnClickListener(this::onClick);
        mLlSelectedDialogLayout.setOnClickListener(this::onClick);
        finishIcon.setOnClickListener(this::onClick);
        searchEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(s.toString())) {
                    restoreParticipants();
                } else {
                    searchParticipant(s.toString());
                }
            }
        });
    }

    private void onClick(View view) {
        if (view.getId() == R.id.img_select_participant_arrows_return) {
            destroy();
        } else if (view.getId() == R.id.ll_selected_dialog) {
            if (!mSelectedDialog.isShowing()) {
                mSelectedDialog.setAttendees(mSelectedPanelAdapter.getSelectedParticipant());
                mSelectedDialog.show();
            }
        } else if (view.getId() == R.id.btn_confirm_participants) {
            confirmSelected();
        }
    }

    private void destroy() {
        Activity activity = (Activity) mContext;
        activity.finish();
        mStateHolder.removeObserve(mAttendeesObserver);
    }

    private void confirmSelected() {
        if (mCallback != null) {
            mCallback.confirm(mSelectedPanelAdapter.getSelectedParticipant());
        }
    }

    private void searchParticipant(String targetParticipant) {
        if (mParticipants.isEmpty()) {
            return;
        }
        List<ConferenceDefine.User> selectedList = mSelectedPanelAdapter.getSelectedParticipant();
        List<Participants> targetList = new ArrayList<>();
        for (Participants participants : mParticipants) {
            if (isTargetParticipant(participants.userInfo, targetParticipant)) {
                Participants participant = new Participants();
                participant.userInfo = participants.userInfo;
                participant.isSelected = selectedList.contains(participants.userInfo);
                participant.isDisable = mDisableList.contains(participants.userInfo);
                targetList.add(participant);
            }
        }
        mContactsAdapter.setAttendees(targetList);
    }

    private void restoreParticipants() {
        List<ConferenceDefine.User> selectedList = mSelectedPanelAdapter.getSelectedParticipant();
        List<Participants> allList = new ArrayList<>();
        for (Participants user : mParticipants) {
            Participants participant = new Participants();
            participant.userInfo = user.userInfo;
            participant.isSelected = selectedList.contains(user.userInfo);
            participant.isDisable = mDisableList.contains(user.userInfo);
            allList.add(participant);
        }
        mContactsAdapter.setAttendees(allList);
    }

    private boolean isTargetParticipant(ConferenceDefine.User user, String content) {
        if (user.id.toLowerCase().contains(content.toLowerCase())) {
            return true;
        }
        if (TextUtils.isEmpty(user.name)) {
            return false;
        }
        return user.name.toLowerCase().contains(content.toLowerCase());
    }

    private void updateContactsView() {
        mStateHolder.initAttendees(mParticipants);
        mContactsAdapter.setAttendees(mParticipants);
        mContactsAdapter.notifyDataSetChanged();
        mSelectedPanelAdapter.setAttendees(mSelectedList);
        mSelectedPanelAdapter.notifyDataSetChanged();
        updateMoreParticipantsView();
    }

    private void updateContactsTitle(int userCount) {
        mTvContactsTitle.setText(mContext.getString(R.string.tuiroomkit_all_participant, userCount));
    }

    private void updateMoreParticipantsView() {
        int selectedCount = mSelectedPanelAdapter.getSelectedParticipant().size();
        mRecyclerSelectedPanel.setVisibility(selectedCount > MAX_VISIBLE_USER_AVATARS ? View.GONE : View.VISIBLE);
        mLlSelectedDialogLayout.setVisibility(selectedCount > MAX_VISIBLE_USER_AVATARS ? View.VISIBLE : View.GONE);
        mTvSelectedDialogTitle.setText(mContext.getString(R.string.tuiroomkit_selected_participant_size, selectedCount));
        mBtnConfirmSelect.setText(mContext.getString(R.string.tuiroomkit_confirm_select_participant, selectedCount));
    }

    private void updateContacts(Participants item) {
        mContactsAdapter.updateItem(item);
        mSelectedPanelAdapter.updateItem(item);
    }
}
