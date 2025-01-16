package com.tencent.qcloud.tuikit.tuichat.classicui.widget.profile;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.FriendProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.config.FriendConfig;
import com.tencent.qcloud.tuikit.tuichat.interfaces.FriendProfileListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.FriendProfilePresenter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class FriendProfileLayout extends LinearLayout {
    private static final String TAG = FriendProfileLayout.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ImageView mHeadImageView;
    private TextView mNickNameView;
    private TextView mIDView;
    private TextView mSignatureView;
    private TextView mSignatureTagView;
    private LineControllerView mRemarkView;
    private LineControllerView mAddBlackView;
    private LineControllerView mChatTopView;
    private LineControllerView mMessageOptionView;
    private LineControllerView mChatBackground;
    private TextView deleteFriendBtn;
    private TextView clearMessageBtn;
    private ViewGroup friendSettingsArea;
    private TextView addFriendBtn;

    private ViewGroup extensionListView;
    private ViewGroup warningExtensionListView;

    private FriendProfilePresenter presenter;
    private FriendProfileBean friendProfileBean;
    private OnButtonClickListener buttonClickListener;

    public FriendProfileLayout(Context context) {
        super(context);
        init();
    }

    public FriendProfileLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public FriendProfileLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.contact_friend_profile_layout, this);

        mHeadImageView = findViewById(R.id.friend_icon);
        mNickNameView = findViewById(R.id.friend_nick_name);
        mIDView = findViewById(R.id.friend_account);
        mRemarkView = findViewById(R.id.remark);
        mSignatureTagView = findViewById(R.id.friend_signature_tag);
        mSignatureView = findViewById(R.id.friend_signature);
        mMessageOptionView = findViewById(R.id.msg_rev_opt);
        mChatTopView = findViewById(R.id.chat_to_top);
        mAddBlackView = findViewById(R.id.blackList);
        deleteFriendBtn = findViewById(R.id.btn_delete);
        clearMessageBtn = findViewById(R.id.btn_clear_chat_history);
        mChatBackground = findViewById(R.id.chat_background);
        addFriendBtn = findViewById(R.id.add_friend_button);
        friendSettingsArea = findViewById(R.id.friend_settings_area);

        extensionListView = findViewById(R.id.extension_list);
        warningExtensionListView = findViewById(R.id.warning_extension_list);

        mTitleBar = findViewById(R.id.friend_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) getContext()).finish();
            }
        });
    }

    public void setPresenter(FriendProfilePresenter presenter) {
        this.presenter = presenter;
        presenter.setProfileListener(new FriendProfileListener() {
            @Override
            public void onFriendProfileLoaded(FriendProfileBean friendProfileBean) {
                setFriendProfile(friendProfileBean);
            }

            @Override
            public void onBlackListCheckResult(boolean isInBlackList) {
                mAddBlackView.setChecked(isInBlackList);
                if (FriendConfig.isShowBlock()) {
                    mAddBlackView.setVisibility(VISIBLE);
                }
                if (isInBlackList && FriendConfig.isShowAlias()) {
                    mRemarkView.setVisibility(VISIBLE);
                }
            }

            @Override
            public void onFriendCheckResult(boolean isFriend) {
                if (isFriend) {
                    if (FriendConfig.isShowDelete()) {
                        deleteFriendBtn.setVisibility(VISIBLE);
                    }
                    if (FriendConfig.isShowAlias()) {
                        mRemarkView.setVisibility(VISIBLE);
                    }
                    friendSettingsArea.setVisibility(VISIBLE);
                    addFriendBtn.setVisibility(GONE);
                } else {
                    friendSettingsArea.setVisibility(GONE);
                    if (FriendConfig.isShowAddFriend()) {
                        addFriendBtn.setVisibility(VISIBLE);
                    }
                    mSignatureTagView.setVisibility(GONE);
                    mSignatureView.setVisibility(GONE);
                }
            }

            @Override
            public void onConversationPinnedCheckResult(boolean isPinned) {
                mChatTopView.setChecked(isPinned);
                if (FriendConfig.isShowMuteAndPin()) {
                    mChatTopView.setVisibility(VISIBLE);
                }
                extensionListView.setVisibility(VISIBLE);
                if (FriendConfig.isShowClearChatHistory()) {
                    clearMessageBtn.setVisibility(VISIBLE);
                }
            }

            @Override
            public void onMessageHasNotificationCheckResult(boolean hasNotification) {
                mMessageOptionView.setChecked(hasNotification);
                if (FriendConfig.isShowMuteAndPin()) {
                    mMessageOptionView.setVisibility(VISIBLE);
                }
            }
        });
    }

    public void loadFriendProfile(String userID) {
        presenter.loadFriendProfile(userID);
    }

    public void setFriendProfile(FriendProfileBean friendProfileBean) {
        this.friendProfileBean = friendProfileBean;

        mSignatureView.setText(friendProfileBean.getSignature());
        if (TextUtils.isEmpty(friendProfileBean.getSignature())) {
            mSignatureTagView.setText(getResources().getString(R.string.contact_no_status));
        } else {
            mSignatureTagView.setText(getResources().getString(R.string.contact_signature_tag));
        }
        mRemarkView.setContent(friendProfileBean.getFriendRemark());

        int radius = ScreenUtil.dip2px(4.6f);
        GlideEngine.loadUserIcon(mHeadImageView, friendProfileBean.getFaceUrl(), radius);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mNickNameView.setText(friendProfileBean.getDisplayName());
        mIDView.setText(friendProfileBean.getUserId());

        setOnClickListener();
        setupExtension();
        applyCustomConfig();
    }

    private void setupExtension() {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, friendProfileBean.getUserId());
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID, param);
        Collections.sort(extensionInfoList);
        extensionListView.removeAllViews();
        for (TUIExtensionInfo extensionInfo : extensionInfoList) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.contact_friend_profile_item_layout, null);
            TextView itemButton = itemView.findViewById(R.id.item_button);
            itemButton.setText(extensionInfo.getText());
            itemButton.setOnClickListener(v -> {
                if (extensionInfo.getExtensionListener() != null) {
                    extensionInfo.getExtensionListener().onClicked(null);
                }
            });
            extensionListView.addView(itemView);
        }

        List<TUIExtensionInfo> warningExtensionList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.FriendProfileWarningButton.EXTENSION_ID, null);
        Collections.sort(warningExtensionList);
        warningExtensionListView.removeAllViews();
        for (TUIExtensionInfo extensionInfo : warningExtensionList) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.contact_friend_profile_warning_item_layout, null);
            TextView itemButton = itemView.findViewById(R.id.item_button);
            itemButton.setText(extensionInfo.getText());
            itemButton.setOnClickListener(v -> {
                if (extensionInfo.getExtensionListener() != null) {
                    extensionInfo.getExtensionListener().onClicked(null);
                }
            });
            warningExtensionListView.addView(itemView);
        }
    }

    public void setOnClickListener() {
        deleteFriendBtn.setOnClickListener(v
            -> new TUIKitDialog(getContext())
                   .builder()
                   .setCancelable(true)
                   .setCancelOutside(true)
                   .setTitle(getContext().getString(R.string.contact_delete_friend_tip))
                   .setDialogWidth(0.75f)
                   .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                       v1 -> {
                           removeFriend();
                           if (buttonClickListener != null) {
                               buttonClickListener.onDeleteFriendClick(friendProfileBean.getUserId());
                           }
                       })
                   .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), v12 -> {})
                   .show());

        clearMessageBtn.setOnClickListener(v
            -> new TUIKitDialog(getContext())
                   .builder()
                   .setCancelable(true)
                   .setCancelOutside(true)
                   .setTitle(getContext().getString(R.string.clear_msg_tip))
                   .setDialogWidth(0.75f)
                   .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), v13 -> clearHistoryMessage())
                   .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), v14 -> {})
                   .show());

        mRemarkView.setOnClickListener(v -> {
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mRemarkView.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.profile_remark_edit));
            String description = getResources().getString(R.string.contact_modify_remark_rule);
            popupInputCard.setDescription(description);
            popupInputCard.setOnPositive((result -> {
                mRemarkView.setContent(result);
                if (TextUtils.isEmpty(result)) {
                    result = "";
                }
                modifyRemark(result);
            }));
            popupInputCard.show(mRemarkView, Gravity.BOTTOM);
        });

        mChatBackground.setOnClickListener(v -> {
            if (buttonClickListener != null) {
                buttonClickListener.onSetChatBackground();
            }
        });

        mChatTopView.setCheckListener((buttonView, isChecked) -> pinConversation(isChecked));

        mAddBlackView.setCheckListener((buttonView, isChecked) -> {
            if (isChecked) {
                addToBlackList();
            } else {
                deleteFromBlackList();
            }
        });

        mMessageOptionView.setCheckListener((buttonView, isChecked) -> setNotificationMessage(!isChecked));

        addFriendBtn.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString(TUIConstants.TUIContact.USER_ID, friendProfileBean.getUserId());
            TUICore.startActivity(this, "AddMoreDetailActivity", bundle);
        });
    }

    public void applyCustomConfig() {
        if (!FriendConfig.isShowAlias()) {
            mRemarkView.setVisibility(GONE);
        }
        if (!FriendConfig.isShowMuteAndPin()) {
            mChatTopView.setVisibility(GONE);
            mMessageOptionView.setVisibility(GONE);
        }
        if (!FriendConfig.isShowBackground()) {
            mChatBackground.setVisibility(GONE);
        }
        if (!FriendConfig.isShowBlock()) {
            mAddBlackView.setVisibility(GONE);
        }
        if (!FriendConfig.isShowClearChatHistory()) {
            clearMessageBtn.setVisibility(GONE);
        }
        if (!FriendConfig.isShowDelete()) {
            deleteFriendBtn.setVisibility(GONE);
        }
        if (!FriendConfig.isShowAddFriend()) {
            addFriendBtn.setVisibility(GONE);
        }
    }

    private void modifyRemark(String friendRemark) {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.modifyFriendRemark(friendProfileBean.getUserId(), friendRemark);
    }

    private void addToBlackList() {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.addToBlackList(friendProfileBean.getUserId());
    }

    private void deleteFromBlackList() {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.deleteFromBlackList(friendProfileBean.getUserId());
    }

    private void removeFriend() {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.removeFriend(friendProfileBean.getUserId());
    }

    private void pinConversation(boolean isPinned) {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.pinConversation(friendProfileBean.getUserId(), isPinned);
    }

    private void clearHistoryMessage() {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.clearHistoryMessage(friendProfileBean.getUserId());
    }

    private void setNotificationMessage(boolean isNotification) {
        if (presenter == null || friendProfileBean == null) {
            return;
        }
        presenter.setMessageHasNotification(friendProfileBean.getUserId(), isNotification);
    }

    public void setOnButtonClickListener(OnButtonClickListener listener) {
        buttonClickListener = listener;
    }

    public interface OnButtonClickListener {
        void onDeleteFriendClick(String id);

        default void onSetChatBackground() {}
    }
}
