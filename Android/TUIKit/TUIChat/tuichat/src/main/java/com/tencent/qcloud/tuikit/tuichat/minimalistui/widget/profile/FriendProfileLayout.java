package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.profile;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
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
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.FriendProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistTitleBar;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
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
import java.util.Map;

public class FriendProfileLayout extends LinearLayout {
    private static final String TAG = FriendProfileLayout.class.getSimpleName();

    private MinimalistTitleBar mTitleBar;

    private ShadeImageView mHeadImageView;
    private TextView mNickNameView;
    private MinimalistLineControllerView mRemarkView;
    private MinimalistLineControllerView mAddBlackView;
    private MinimalistLineControllerView mChatTopView;
    private MinimalistLineControllerView mMessageOptionView;
    private MinimalistLineControllerView mChatBackground;
    private MinimalistLineControllerView deleteFriendBtn;
    private MinimalistLineControllerView clearMessageBtn;
    private TextView friendIDTv;

    private RecyclerView profileItemListView;
    private ProfileItemAdapter profileItemAdapter;
    private ViewGroup warningExtensionListView;
    private ViewGroup friendSettingsArea;
    private ViewGroup addFriendArea;
    private TextView addFriendBtn;
    private ImageView addFriendIcon;
    private TextView addFriendNickname;
    private TextView addFriendIDTv;

    private OnButtonClickListener buttonClickListener;

    private FriendProfilePresenter presenter;
    private FriendProfileBean friendProfileBean;

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
        inflate(getContext(), R.layout.minimalist_contact_friend_profile_layout, this);

        mHeadImageView = findViewById(R.id.friend_icon);
        mNickNameView = findViewById(R.id.friend_nick_name);
        friendIDTv = findViewById(R.id.friend_account);
        mRemarkView = findViewById(R.id.remark);
        mMessageOptionView = findViewById(R.id.msg_rev_opt);
        mChatTopView = findViewById(R.id.chat_to_top);
        mAddBlackView = findViewById(R.id.blackList);
        deleteFriendBtn = findViewById(R.id.btn_delete);
        deleteFriendBtn.setNameColor(0xFFFF584C);
        clearMessageBtn = findViewById(R.id.clear_chat_history);
        clearMessageBtn.setNameColor(0xFFFF584C);
        mChatBackground = findViewById(R.id.chat_background);
        addFriendBtn = findViewById(R.id.add_friend_button);
        addFriendArea = findViewById(R.id.add_friend_area);
        addFriendIcon = findViewById(R.id.add_friend_icon);
        addFriendNickname = findViewById(R.id.add_friend_nick_name);
        addFriendIDTv = findViewById(R.id.add_friend_account);
        friendSettingsArea = findViewById(R.id.friend_area);

        profileItemListView = findViewById(R.id.profile_item_container);

        mTitleBar = findViewById(R.id.friend_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mRemarkView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mAddBlackView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mChatTopView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mMessageOptionView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mChatBackground.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        deleteFriendBtn.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        clearMessageBtn.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        profileItemAdapter = new ProfileItemAdapter();
        profileItemListView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        int leftRightSpace = ScreenUtil.dip2px(24);
        profileItemListView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int position = parent.getChildAdapterPosition(view);
                int column = position % 3;
                outRect.left = column * leftRightSpace / 3;
                outRect.right = leftRightSpace * (2 - column) / 3;
            }
        });
        profileItemListView.setAdapter(profileItemAdapter);
        warningExtensionListView = findViewById(R.id.warning_extension_list);
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
                    addFriendArea.setVisibility(GONE);
                } else {
                    addFriendArea.setVisibility(VISIBLE);
                    friendSettingsArea.setVisibility(GONE);
                }
            }

            @Override
            public void onConversationPinnedCheckResult(boolean isPinned) {
                mChatTopView.setChecked(isPinned);
                if (FriendConfig.isShowMuteAndPin()) {
                    mChatTopView.setVisibility(VISIBLE);
                }
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

        mRemarkView.setContent(friendProfileBean.getFriendRemark());

        int radius = ScreenUtil.dip2px(4.6f);
        GlideEngine.loadUserIcon(mHeadImageView, friendProfileBean.getFaceUrl(), radius);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mNickNameView.setText(friendProfileBean.getDisplayName());

        addFriendNickname.setText(friendProfileBean.getDisplayName());
        GlideEngine.loadUserIcon(addFriendIcon, friendProfileBean.getFaceUrl(), radius);
        addFriendIDTv.setText(friendProfileBean.getUserId());

        setOnClickListener();
        setupExtension();
        applyCustomConfig();
    }

    private void setupExtension() {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, friendProfileBean.getUserId());
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID, param);
        Collections.sort(extensionInfoList);
        profileItemAdapter.setExtensionInfoList(extensionInfoList);
        profileItemAdapter.notifyDataSetChanged();

        List<TUIExtensionInfo> warningExtensionList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.FriendProfileWarningButton.EXTENSION_ID, null);
        Collections.sort(warningExtensionList);
        warningExtensionListView.removeAllViews();
        for (TUIExtensionInfo extensionInfo : warningExtensionList) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.contact_minimalist_profile_warning_item_layout, null);
            MinimalistLineControllerView itemButton = itemView.findViewById(R.id.item_button);
            itemButton.setName(extensionInfo.getText());
            itemButton.setNameColor(getResources().getColor(R.color.contact_minimalist_profile_item_warning_text_color));
            itemButton.setBackgroundColor(getResources().getColor(R.color.contact_minimalist_profile_item_bg_color));
            itemButton.setOnClickListener(v -> {
                if (extensionInfo.getExtensionListener() != null) {
                    extensionInfo.getExtensionListener().onClicked(null);
                }
            });
            warningExtensionListView.addView(itemView);
        }
    }

    private void setOnClickListener() {
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

        mChatTopView.setCheckListener((buttonView, isChecked) -> {
            if (presenter != null) {
                pinConversation(isChecked);
            }
        });

        mAddBlackView.setCheckListener((buttonView, isChecked) -> {
            if (isChecked) {
                addToBlackList();
            } else {
                deleteFromBlackList();
            }
        });

        mMessageOptionView.setCheckListener((buttonView, isChecked) -> setNotificationMessage(!isChecked));

        addFriendBtn.setOnClickListener(v -> {
            Map<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIContact.Method.AddFriend.USER_ID, friendProfileBean.getUserId());
            param.put(TUIConstants.TUIContact.Method.AddFriend.ACTIVITY, getContext());
            TUICore.callService(TUIConstants.TUIContact.MINIMALIST_SERVICE_NAME, TUIConstants.TUIContact.Method.AddFriend.METHOD_NAME, param);
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

    class ProfileItemAdapter extends RecyclerView.Adapter<ProfileItemAdapter.ItemViewHolder> {
        List<TUIExtensionInfo> extensionInfoList;

        public void setExtensionInfoList(List<TUIExtensionInfo> extensionInfoList) {
            this.extensionInfoList = extensionInfoList;
        }

        @NonNull
        @Override
        public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.contact_minimalist_friend_profile_item_layout, null);
            return new ItemViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull ItemViewHolder holder, int position) {
            TUIExtensionInfo extensionInfo = extensionInfoList.get(position);
            holder.imageView.setBackgroundResource((Integer) extensionInfo.getIcon());
            holder.textView.setText(extensionInfo.getText());
            TUIExtensionEventListener eventListener = extensionInfo.getExtensionListener();
            holder.itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (eventListener != null) {
                        eventListener.onClicked(null);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (extensionInfoList == null) {
                return 0;
            }
            return extensionInfoList.size();
        }

        class ItemViewHolder extends RecyclerView.ViewHolder {
            public ImageView imageView;
            public TextView textView;

            public ItemViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.item_image);
                textView = itemView.findViewById(R.id.item_text);
            }
        }
    }

    public void setOnButtonClickListener(OnButtonClickListener listener) {
        buttonClickListener = listener;
    }

    public interface OnButtonClickListener {
        void onDeleteFriendClick(String id);

        default void onSetChatBackground() {}
    }
}
