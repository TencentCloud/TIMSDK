package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.profile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
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

import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.SelectionActivity;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupMemberBean;
import com.tencent.qcloud.tuikit.tuichat.config.GroupConfig;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupProfileListener;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.GroupNoticeMinimalistActivity;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupProfilePresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupInfoLayout extends LinearLayout {
    private static final String TAG = "GroupInfoLayout";
    private TitleBarLayout mTitleBar;
    private MinimalistLineControllerView mMemberView;
    private MinimalistLineControllerView mGroupTypeView;
    private TextView mGroupIDView;
    private TextView mGroupNameView;
    private ImageView editGroupNameView;
    private ShadeImageView mGroupIcon;
    private View mGroupNotice;
    private TextView mGroupNotificationText;
    private MinimalistLineControllerView mSelfNameCardView;
    private MinimalistLineControllerView mAddTypeView;
    private MinimalistLineControllerView mApproveTypeView;
    private MinimalistLineControllerView mTopSwitchView;
    private MinimalistLineControllerView mMsgRevOptionSwitchView;
    private MinimalistLineControllerView mFoldGroupChatSwitchView;
    private MinimalistLineControllerView mChatBackground;
    private View mLayoutFold;
    private MinimalistLineControllerView mDissolveBtn;
    private MinimalistLineControllerView mClearMsgBtn;
    private ViewGroup warningExtensionListView;
    private ViewGroup groupMemberListContainer;
    private ViewGroup groupProfileBottomExtensionContainer;
    private ViewGroup extensionSettingsContainer;

    private OnChangeChatBackgroundListener changeChatBackgroundListener;

    private ArrayList<String> mAddTypes = new ArrayList<>();
    private ArrayList<String> mApproveTypes = new ArrayList<>();
    private GroupProfileBean profileBean;

    private RecyclerView profileItemListView;
    private ProfileItemAdapter profileItemAdapter;
    private GroupProfilePresenter groupProfilePresenter;

    public GroupInfoLayout(Context context) {
        super(context);
        init();
    }

    public GroupInfoLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupInfoLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.chat_group_minimalist_info_layout, this);

        mTitleBar = findViewById(R.id.group_info_title_bar);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_detail), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) getContext()).finish();
            }
        });
        mMemberView = findViewById(R.id.group_member_bar);
        mMemberView.setCanNav(true);
        mGroupTypeView = findViewById(R.id.group_type_bar);

        mGroupIDView = findViewById(R.id.group_account);

        mGroupNameView = findViewById(R.id.group_name);
        editGroupNameView = findViewById(R.id.edit_group_name);

        mGroupIcon = findViewById(R.id.group_icon);
        mGroupIcon.setRadius(ScreenUtil.dip2px(50));

        mGroupNotice = findViewById(R.id.group_notice);
        mGroupNotificationText = findViewById(R.id.group_notice_text);

        mAddTypeView = findViewById(R.id.join_type_bar);
        mAddTypeView.setCanNav(true);
        mAddTypes.addAll(Arrays.asList(getResources().getStringArray(R.array.group_join_type)));

        mApproveTypeView = findViewById(R.id.invite_type_bar);
        mApproveTypeView.setCanNav(true);
        mApproveTypes.addAll(Arrays.asList(getResources().getStringArray(R.array.group_invite_type)));

        mSelfNameCardView = findViewById(R.id.self_nickname_bar);
        mSelfNameCardView.setCanNav(true);

        mTopSwitchView = findViewById(R.id.chat_to_top_switch);

        mMsgRevOptionSwitchView = findViewById(R.id.msg_rev_option);

        mLayoutFold = findViewById(R.id.layout_fold);
        mFoldGroupChatSwitchView = findViewById(R.id.fold_group_chat);

        mDissolveBtn = findViewById(R.id.group_dissolve_button);
        mDissolveBtn.setNameColor(0xFFFF584C);

        mClearMsgBtn = findViewById(R.id.group_clear_msg_button);
        mClearMsgBtn.setNameColor(0xFFFF584C);

        mChatBackground = findViewById(R.id.chat_background);
        mChatBackground.setCanNav(true);

        warningExtensionListView = findViewById(R.id.warning_extension_list);
        groupMemberListContainer = findViewById(R.id.group_member_list_container);
        groupProfileBottomExtensionContainer = findViewById(R.id.group_profile_bottom_extension_list);
        extensionSettingsContainer = findViewById(R.id.extension_settings_container);

        int linearViewBgColor = 0xF0F9F9F9;
        mMsgRevOptionSwitchView.setBackgroundColor(linearViewBgColor);
        mLayoutFold.setBackgroundColor(linearViewBgColor);
        mFoldGroupChatSwitchView.setBackgroundColor(linearViewBgColor);
        mTopSwitchView.setBackgroundColor(linearViewBgColor);
        mGroupNotice.setBackgroundColor(linearViewBgColor);
        mAddTypeView.setBackgroundColor(linearViewBgColor);
        mApproveTypeView.setBackgroundColor(linearViewBgColor);
        mGroupTypeView.setBackgroundColor(linearViewBgColor);
        mSelfNameCardView.setBackgroundColor(linearViewBgColor);
        mMemberView.setBackgroundColor(linearViewBgColor);
        mChatBackground.setBackgroundColor(linearViewBgColor);
        mClearMsgBtn.setBackgroundColor(linearViewBgColor);
        mDissolveBtn.setBackgroundColor(linearViewBgColor);
        profileItemListView = findViewById(R.id.profile_item_container);
        profileItemAdapter = new ProfileItemAdapter();
        profileItemListView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        int leftRightSpace = com.tencent.qcloud.tuicore.util.ScreenUtil.dip2px(24);
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
    }

    public void setGroupProfilePresenter(GroupProfilePresenter groupProfilePresenter) {
        this.groupProfilePresenter = groupProfilePresenter;

        this.groupProfilePresenter.setGroupProfileListener(new GroupProfileListener() {
            @Override
            public void onGroupProfileLoaded(GroupProfileBean groupProfileBean) {
                setProfileBean(groupProfileBean);
            }

            @Override
            public void onConversationCheckResult(boolean isPinned, boolean isFolded) {
                mTopSwitchView.setChecked(isPinned);
                mTopSwitchView.setVisibility(VISIBLE);
                mFoldGroupChatSwitchView.setChecked(isFolded);
                if (isFolded) {
                    mTopSwitchView.setMask(true);
                }
            }

            @Override
            public void onGroupProfileChanged(V2TIMGroupChangeInfo changeInfo) {
                GroupInfoLayout.this.onGroupProfileChanged(changeInfo);
            }

            @Override
            public void onGroupMemberCountChanged(int count) {
                mMemberView.setContent(count + "");
            }
        });
    }

    public void setProfileBean(GroupProfileBean profileBean) {
        this.profileBean = profileBean;
        setClickListener();

        mGroupNameView.setText(profileBean.getGroupName());
        mGroupIDView.setText(profileBean.getGroupID());
        if (TextUtils.isEmpty(profileBean.getNotification())) {
            mGroupNotificationText.setText(getResources().getString(R.string.group_notice_empty_tip));
        } else {
            mGroupNotificationText.setText(profileBean.getNotification());
        }
        String groupType = profileBean.getGroupType();
        mGroupTypeView.setContent(TUIChatUtils.convertGroupTypeText(groupType));
        mAddTypeView.setContent(mAddTypes.get(profileBean.getAddOpt()));
        mApproveTypeView.setContent(mApproveTypes.get(profileBean.getApproveOpt()));
        if (profileBean.isOwner()) {
            mAddTypeView.setVisibility(VISIBLE);

            if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_WORK)) {
                mDissolveBtn.setName(getResources().getString(R.string.exit_group));
            }
            mAddTypeView.setCanNav(true);
            mApproveTypeView.setCanNav(true);
        } else {
            mAddTypeView.setCanNav(false);
            mApproveTypeView.setCanNav(false);
            mAddTypeView.setOnClickListener(null);
            mApproveTypeView.setOnClickListener(null);
            mDissolveBtn.setName(getResources().getString(R.string.exit_group));
        }
        if (TextUtils.equals(profileBean.getGroupType(), V2TIMManager.GROUP_TYPE_MEETING)) {
            mMsgRevOptionSwitchView.setVisibility(GONE);
            mLayoutFold.setVisibility(GONE);
        } else {
            if (profileBean.getRecvOpt() == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE) {
                mMsgRevOptionSwitchView.setChecked(true);
                mLayoutFold.setVisibility(View.VISIBLE);
            } else {
                mMsgRevOptionSwitchView.setChecked(false);
                mLayoutFold.setVisibility(View.GONE);
            }
        }

        if (profileBean.canManage()) {
            editGroupNameView.setVisibility(VISIBLE);
        }
        mSelfNameCardView.setContent(profileBean.getSelfInfo().getNameCard());
        mMemberView.setContent(profileBean.getMemberCount() + "");

        loadGroupFaceUrl();
        setupExtension();
        applyCustomConfig();
    }

    private void loadGroupFaceUrl() {
        String faceUrl = profileBean.getGroupFaceUrl();
        int defaultGroupFaceResID = TUIUtil.getDefaultGroupIconResIDByGroupType(getContext(), profileBean.getGroupType());
        Glide.with(TUIChatService.getAppContext())
            .load(faceUrl)
            .placeholder(defaultGroupFaceResID)
            .apply(new RequestOptions().centerCrop().error(defaultGroupFaceResID))
            .into(mGroupIcon);
    }

    private void setupExtension() {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIContact.Extension.GroupProfileItem.GROUP_ID, profileBean.getGroupID());
        param.put(TUIConstants.TUIContact.Extension.GroupProfileItem.CONTEXT, getContext());
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID, param);
        Collections.sort(extensionInfoList);
        profileItemAdapter.setExtensionInfoList(extensionInfoList);
        profileItemAdapter.notifyDataSetChanged();

        List<TUIExtensionInfo> warningExtensionList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.GroupProfileWarningButton.EXTENSION_ID, null);
        Collections.sort(warningExtensionList);
        warningExtensionListView.removeAllViews();
        for (TUIExtensionInfo extensionInfo : warningExtensionList) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.chat_minimalist_profile_warning_item_layout, null);
            MinimalistLineControllerView itemButton = itemView.findViewById(R.id.item_button);
            itemButton.setName(extensionInfo.getText());
            itemButton.setNameColor(getResources().getColor(R.color.group_minimalist_profile_item_warning_text_color));
            itemButton.setBackgroundColor(getResources().getColor(R.color.group_minimalist_profile_item_bg_color));
            itemButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (extensionInfo.getExtensionListener() != null) {
                        extensionInfo.getExtensionListener().onClicked(null);
                    }
                }
            });
            warningExtensionListView.addView(itemView);
        }

        groupMemberListContainer.removeAllViews();
        Map<String, Object> groupMemberParam = new HashMap<>();
        groupMemberParam.put(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.GROUP_PROFILE_BEAN, profileBean);
        groupMemberParam.put(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.VIEW_TYPE, TUIConstants.TUIChat.VIEW_TYPE_MINIMALIST);
        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.EXTENSION_ID, groupMemberListContainer, groupMemberParam);

        Map<String, Object> settingsParam = new HashMap<>();
        settingsParam.put(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.GROUP_PROFILE_BEAN, profileBean);
        settingsParam.put(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.VIEW_TYPE, TUIConstants.TUIChat.VIEW_TYPE_MINIMALIST);
        List<TUIExtensionInfo> settingsExtensionList =
            TUICore.getExtensionList(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.EXTENSION_ID, settingsParam);
        Collections.sort(settingsExtensionList);
        extensionSettingsContainer.removeAllViews();
        for (TUIExtensionInfo extensionInfo : settingsExtensionList) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.group_minimalist_profile_settings_item_layout, null);
            MinimalistLineControllerView itemView = view.findViewById(R.id.line_controller_view);
            itemView.setBackgroundColor(0xF0F9F9F9);
            itemView.setName(extensionInfo.getText());
            itemView.setOnClickListener(v -> {
                if (extensionInfo.getExtensionListener() != null) {
                    extensionInfo.getExtensionListener().onClicked(null);
                }
            });
            extensionSettingsContainer.addView(view);
        }

        Map<String, Object> bottomExtensionsParam = new HashMap<>();
        bottomExtensionsParam.put(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.GROUP_PROFILE_BEAN, profileBean);
        bottomExtensionsParam.put(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.VIEW_TYPE, TUIConstants.TUIChat.VIEW_TYPE_CLASSIC);
        bottomExtensionsParam.put(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.CALLER, getContext());
        List<TUIExtensionInfo> bottomExtensionList =
            TUICore.getExtensionList(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.EXTENSION_ID, bottomExtensionsParam);
        Collections.sort(bottomExtensionList);
        groupProfileBottomExtensionContainer.removeAllViews();
        for (TUIExtensionInfo extensionInfo : bottomExtensionList) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.group_minimalist_profile_bottom_item_layout, null);
            MinimalistLineControllerView itemView = view.findViewById(R.id.item_view);
            itemView.setBackgroundColor(0xF0F9F9F9);
            itemView.setNameColor(0xFFFF584C);
            itemView.setName(extensionInfo.getText());
            itemView.setOnClickListener(v -> {
                if (extensionInfo.getExtensionListener() != null) {
                    extensionInfo.getExtensionListener().onClicked(null);
                }
            });
            groupProfileBottomExtensionContainer.addView(view);
        }
    }

    private void setClickListener() {
        mMemberView.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString(TUIConstants.TUIContact.GROUP_ID, profileBean.getGroupID());
            bundle.putBoolean(TUIConstants.TUIContact.IS_SELECT_MODE, false);
            TUICore.startActivity(getContext(), "GroupMemberMinimalistActivity", bundle);
        });

        mGroupIcon.setOnClickListener(v -> {
            if (!profileBean.canManage()) {
                return;
            }

            startModifyGroupAvatar(profileBean.getGroupFaceUrl());
        });

        mSelfNameCardView.setOnClickListener(v -> {
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mSelfNameCardView.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.modify_nick_name_in_goup));
            popupInputCard.setOnPositive((result -> {
                groupProfilePresenter.modifySelfNameCard(profileBean.getGroupID(), result);
                mSelfNameCardView.setContent(result);
            }));
            popupInputCard.show(mSelfNameCardView, Gravity.BOTTOM);
        });

        editGroupNameView.setOnClickListener(v -> {
            if (!profileBean.canManage()) {
                return;
            }
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mGroupNameView.getText().toString());
            String modifyGroupName = getResources().getString(R.string.modify_group_name);
            popupInputCard.setTitle(modifyGroupName);
            popupInputCard.setOnPositive((result -> {
                groupProfilePresenter.modifyGroupName(profileBean.getGroupID(), result);
                if (!TextUtils.isEmpty(result)) {
                    mGroupNameView.setText(result);
                }
            }));
            popupInputCard.show(mGroupNameView, Gravity.BOTTOM);
        });

        mChatBackground.setOnClickListener(v -> {
            if (!profileBean.canManage()) {
                return;
            }
            if (changeChatBackgroundListener != null) {
                changeChatBackgroundListener.onChangeChatBackground();
            }
        });

        mGroupNotice.setOnClickListener(v -> {
            Intent intent = new Intent(getContext(), GroupNoticeMinimalistActivity.class);
            intent.putExtra(TUIChatConstants.Group.GROUP_INFO, profileBean);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getContext().startActivity(intent);
        });

        mSelfNameCardView.setOnClickListener(v -> {
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mSelfNameCardView.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.modify_nick_name_in_goup));
            popupInputCard.setOnPositive((result -> {
                groupProfilePresenter.modifySelfNameCard(profileBean.getGroupID(), result);
                mSelfNameCardView.setContent(result);
            }));
            popupInputCard.show(mSelfNameCardView, Gravity.BOTTOM);
        });

        mClearMsgBtn.setOnClickListener(v -> new TUIKitDialog(getContext())
            .builder()
            .setCancelable(true)
            .setCancelOutside(true)
            .setTitle(getContext().getString(R.string.clear_group_msg_tip))
            .setDialogWidth(0.75f)
            .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                    v1 -> {
                        Map<String, Object> hashMap = new HashMap<>();
                        hashMap.put(TUIConstants.TUIContact.GROUP_ID, profileBean.getGroupID());
                        TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_GROUP_MESSAGE, hashMap);
                    })
            .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                    v12 -> {})
            .show());

        mTopSwitchView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                pinConversation(isChecked);
            }
        });

        mAddTypeView.setOnClickListener(v -> {
            if (profileBean.canManage()) {
                Bundle bundle = new Bundle();
                bundle.putString(SelectionActivity.Selection.TITLE, getResources().getString(R.string.group_join_type));
                bundle.putStringArrayList(SelectionActivity.Selection.LIST, mAddTypes);
                bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, profileBean.getAddOpt());
                SelectionActivity.startListSelection(
                        getContext(), bundle, text -> groupProfilePresenter.modifyGroupAddOpt(profileBean.getGroupID(), (Integer) text));
            }
        });

        mApproveTypeView.setOnClickListener(v -> {
            if (profileBean.canManage()) {
                Bundle bundle = new Bundle();
                bundle.putString(SelectionActivity.Selection.TITLE, getResources().getString(R.string.group_invite_type));
                bundle.putStringArrayList(SelectionActivity.Selection.LIST, mApproveTypes);
                bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, profileBean.getApproveOpt());
                SelectionActivity.startListSelection(
                        getContext(), bundle, text -> groupProfilePresenter.modifyGroupApproveOpt(profileBean.getGroupID(), (Integer) text));
            }
        });

        mDissolveBtn.setOnClickListener(v -> {
            if (profileBean.isOwner()
                    && (!profileBean.getGroupType().equals(TUIConstants.GroupType.TYPE_WORK)
                    && !profileBean.getGroupType().equals(TUIConstants.GroupType.TYPE_PRIVATE))) {
                new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.dismiss_group_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), v14 -> dismissGroup())
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), v13 -> {})
                        .show();
            } else {
                new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.quit_group_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), v15 -> quitGroup())
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), v16 -> {})
                        .show();
            }
        });

        mMsgRevOptionSwitchView.setCheckListener((buttonView, isChecked) -> {
            mMsgRevOptionSwitchView.setMask(true);
            groupProfilePresenter.setMessageRecvOpt(profileBean.getGroupID(), !isChecked, new TUICallback() {
                @Override
                public void onSuccess() {
                    mMsgRevOptionSwitchView.setMask(false);
                    if (isChecked) {
                        mLayoutFold.setVisibility(VISIBLE);
                    } else {
                        mLayoutFold.setVisibility(GONE);
                        mFoldGroupChatSwitchView.setChecked(false);
                        groupProfilePresenter.setGroupFold(profileBean.getGroupID(), false, new TUICallback() {
                            @Override
                            public void onSuccess() {}

                            @Override
                            public void onError(int errCode, String errMsg) {
                                TUIChatLog.e(TAG, "setGroupFold error, errCode = " + errCode + ", errMsg = " + errMsg);
                            }
                        });
                    }
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    mMsgRevOptionSwitchView.setMask(false);
                }
            });

            mFoldGroupChatSwitchView.setCheckListener(
                    (buttonView1, isChecked1) -> groupProfilePresenter.setGroupFold(profileBean.getGroupID(), isChecked1, new TUICallback() {
                        @Override
                        public void onSuccess() {
                            if (isChecked1) {
                                groupProfilePresenter.pinConversation(profileBean.getGroupID(), false);
                                mTopSwitchView.setChecked(false);
                                mTopSwitchView.setMask(true);
                            } else {
                                mTopSwitchView.setMask(false);
                            }
                        }

                        @Override
                        public void onError(int errorCode, String errorMessage) {
                            TUIChatLog.e(TAG, "setGroupFold error, errCode = " + errorCode + ", errMsg = " + errorMessage);
                        }
                    }));
        });
    }

    private void startModifyGroupAvatar(String originAvatarUrl) {
        ArrayList<ImageSelectActivity.ImageBean> faceList = new ArrayList<>();
        for (int i = 0; i < TUIChatConstants.GROUP_FACE_COUNT; i++) {
            ImageSelectActivity.ImageBean imageBean = new ImageSelectActivity.ImageBean();
            imageBean.setThumbnailUri(String.format(TUIChatConstants.GROUP_FACE_URL, (i + 1) + ""));
            imageBean.setImageUri(String.format(TUIChatConstants.GROUP_FACE_URL, (i + 1) + ""));
            faceList.add(imageBean);
        }

        Intent intent = new Intent();
        intent.putExtra(ImageSelectActivity.TITLE, getResources().getString(R.string.group_choose_avatar));
        intent.putExtra(ImageSelectActivity.SPAN_COUNT, 4);
        int itemWidth = (int) (ScreenUtil.getScreenWidth(TUIChatService.getAppContext()) * 0.2f);
        intent.putExtra(ImageSelectMinimalistActivity.ITEM_WIDTH, itemWidth);
        intent.putExtra(ImageSelectMinimalistActivity.ITEM_HEIGHT, itemWidth);
        intent.putExtra(ImageSelectActivity.DATA, faceList);
        intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(originAvatarUrl, originAvatarUrl, false));
        TUICore.startActivityForResult((ActivityResultCaller) getContext(), ImageSelectActivity.class, intent.getExtras(), result -> {
            if (result.getData() != null) {
                ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) result.getData().getSerializableExtra(ImageSelectActivity.DATA);
                if (imageBean == null) {
                    return;
                }

                String avatarUrl = imageBean.getImageUri();
                groupProfilePresenter.modifyGroupFaceUrl(profileBean.getGroupID(), avatarUrl);
            }
        });
    }

    public void setSelfInfo(GroupMemberBean selfInfo) {
        mSelfNameCardView.setContent(selfInfo.getNameCard());
    }

    private void dismissGroup() {
        if (groupProfilePresenter == null || profileBean == null) {
            return;
        }
        groupProfilePresenter.dismissGroup(profileBean.getGroupID(), new TUICallback() {
            @Override
            public void onSuccess() {
                ((Activity) GroupInfoLayout.this.getContext()).finish();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    private void quitGroup() {
        if (groupProfilePresenter == null || profileBean == null) {
            return;
        }
        groupProfilePresenter.quitGroup(profileBean.getGroupID(), new TUICallback() {
            @Override
            public void onSuccess() {
                ((Activity) GroupInfoLayout.this.getContext()).finish();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    private void pinConversation(boolean isPin) {
        if (groupProfilePresenter == null || profileBean == null) {
            return;
        }
        groupProfilePresenter.pinConversation(profileBean.getGroupID(), isPin);
    }

    public void onGroupProfileChanged(V2TIMGroupChangeInfo changeInfo) {
        switch (changeInfo.getType()) {
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME:
                mGroupNameView.setText(changeInfo.getValue());
                break;
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
                if (TextUtils.isEmpty(changeInfo.getValue())) {
                    mGroupNotificationText.setText(getResources().getString(R.string.group_notice_empty_tip));
                } else {
                    mGroupNotificationText.setText(changeInfo.getValue());
                }
                break;
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT:
                mAddTypeView.setContent(mAddTypes.get(changeInfo.getIntValue()));
                break;
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT:
                mApproveTypeView.setContent(mApproveTypes.get(changeInfo.getIntValue()));
                break;
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_RECEIVE_MESSAGE_OPT:
                mMsgRevOptionSwitchView.setChecked(changeInfo.getIntValue() == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
                break;
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL:
                loadGroupFaceUrl();
                break;
            case V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
                setProfileBean(profileBean);
                break;
            default:
                break;
        }
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (groupProfilePresenter != null) {
            groupProfilePresenter.registerGroupListener();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (groupProfilePresenter != null) {
            groupProfilePresenter.unregisterGroupListener();
        }
    }


    private void applyCustomConfig() {
        if (!GroupConfig.isShowMuteAndPin()) {
            mMsgRevOptionSwitchView.setVisibility(GONE);
            mFoldGroupChatSwitchView.setVisibility(GONE);
            mTopSwitchView.setVisibility(GONE);
        }
        if (!GroupConfig.isShowManage()) {
            extensionSettingsContainer.setVisibility(GONE);
        }
        if (!GroupConfig.isShowAlias()) {
            mSelfNameCardView.setVisibility(GONE);
        }
        if (!GroupConfig.isShowBackground()) {
            mChatBackground.setVisibility(GONE);
        }
        if (!GroupConfig.isShowMembers()) {
            mMemberView.setVisibility(GONE);
            groupMemberListContainer.setVisibility(GONE);
        }
        if (!GroupConfig.isShowClearChatHistory()) {
            mClearMsgBtn.setVisibility(GONE);
        }
        if (!GroupConfig.isShowDeleteAndLeave()) {
            mDissolveBtn.setVisibility(GONE);
        }
        if (!GroupConfig.isShowTransfer()) {
            groupProfileBottomExtensionContainer.setVisibility(GONE);
        }
        if (!GroupConfig.isShowDismiss()) {
            mDissolveBtn.setVisibility(GONE);
        }
    }

    class ProfileItemAdapter extends RecyclerView.Adapter<ProfileItemAdapter.ItemViewHolder> {
        List<TUIExtensionInfo> extensionInfoList;

        public void setExtensionInfoList(List<TUIExtensionInfo> extensionInfoList) {
            this.extensionInfoList = extensionInfoList;
        }

        @NonNull
        @Override
        public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.chat_minimalist_group_profile_item_layout, null);
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

    public void setOnChangeChatBackgroundListener(OnChangeChatBackgroundListener listener) {
        changeChatBackgroundListener = listener;
    }

    public interface OnChangeChatBackgroundListener {
        default void onChangeChatBackground() {}
    }
}
