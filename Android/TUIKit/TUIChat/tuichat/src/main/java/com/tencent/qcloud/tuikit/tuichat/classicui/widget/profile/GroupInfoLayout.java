package com.tencent.qcloud.tuikit.tuichat.classicui.widget.profile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
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
import androidx.annotation.Nullable;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.BottomSelectSheet;
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.SelectionActivity;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupMemberBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.GroupNoticeActivity;
import com.tencent.qcloud.tuikit.tuichat.config.GroupConfig;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupProfileListener;
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
    private LineControllerView mMemberView;
    private LineControllerView mGroupTypeView;
    private TextView mGroupIDView;
    private TextView mGroupNameView;
    private View groupDetailArea;
    private ImageView mGroupIcon;
    private ImageView mGroupDetailArrow;
    private View mGroupNotice;
    private TextView mGroupNotificationText;
    private LineControllerView mSelfNameCardView;
    private LineControllerView mAddTypeView;
    private LineControllerView mApproveTypeView;
    private LineControllerView mTopSwitchView;
    private LineControllerView mMsgRevOptionSwitchView;
    private LineControllerView mFoldGroupChatSwitchView;
    private LineControllerView mChatBackground;
    private View mLayoutFold;
    private TextView mDissolveBtn;
    private TextView mClearMsgBtn;
    private ViewGroup warningExtensionListView;
    private ViewGroup extensionSettingsContainer;
    private ViewGroup groupProfileBottomExtensionContainer;
    private View groupMemberListView;
    private OnChangeChatBackgroundListener onChangeChatBackgroundListener;

    private GroupProfileBean profileBean;
    private ArrayList<String> mAddTypes = new ArrayList<>();
    private ArrayList<String> mApproveTypes = new ArrayList<>();
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
        inflate(getContext(), R.layout.group_info_layout, this);

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

        groupMemberListView = findViewById(R.id.group_member_grid_container);

        mGroupTypeView = findViewById(R.id.group_type_bar);

        mGroupIDView = findViewById(R.id.group_account);

        mGroupNameView = findViewById(R.id.group_name);

        groupDetailArea = findViewById(R.id.group_detail_area);

        mGroupIcon = findViewById(R.id.group_icon);

        mGroupDetailArrow = findViewById(R.id.group_detail_arrow);

        mGroupNotice = findViewById(R.id.group_notice);
        mGroupNotificationText = findViewById(R.id.group_notice_text);

        mAddTypeView = findViewById(R.id.join_type_bar);
        mAddTypes.addAll(Arrays.asList(getResources().getStringArray(R.array.group_join_type)));

        mApproveTypeView = findViewById(R.id.invite_type_bar);
        mApproveTypes.addAll(Arrays.asList(getResources().getStringArray(R.array.group_invite_type)));

        mSelfNameCardView = findViewById(R.id.self_nickname_bar);
        mSelfNameCardView.setCanNav(true);

        mTopSwitchView = findViewById(R.id.chat_to_top_switch);

        mMsgRevOptionSwitchView = findViewById(R.id.msg_rev_option);

        mLayoutFold = findViewById(R.id.layout_fold);
        mFoldGroupChatSwitchView = findViewById(R.id.fold_group_chat);

        mDissolveBtn = findViewById(R.id.group_dissolve_button);

        mClearMsgBtn = findViewById(R.id.group_clear_msg_button);

        mChatBackground = findViewById(R.id.chat_background);
        mChatBackground.setCanNav(true);

        warningExtensionListView = findViewById(R.id.warning_extension_list);
        extensionSettingsContainer = findViewById(R.id.extension_settings_container);
        groupProfileBottomExtensionContainer = findViewById(R.id.group_profile_bottom_extension_list);
    }

    public void setGroupProfilePresenter(GroupProfilePresenter groupProfilePresenter) {
        this.groupProfilePresenter = groupProfilePresenter;
        this.groupProfilePresenter.setGroupProfileListener(new GroupProfileListener() {
            @Override
            public void onGroupProfileLoaded(GroupProfileBean groupProfileBean) {
                setGroupProfile(groupProfileBean);
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

    public void setGroupProfile(GroupProfileBean profileBean) {
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
                mDissolveBtn.setText(R.string.exit_group);
            }
            mAddTypeView.setCanNav(true);
            mApproveTypeView.setCanNav(true);
        } else {
            mAddTypeView.setCanNav(false);
            mApproveTypeView.setCanNav(false);
            mAddTypeView.setOnClickListener(null);
            mApproveTypeView.setOnClickListener(null);
            mDissolveBtn.setText(R.string.exit_group);
        }

        mMemberView.setContent(profileBean.getMemberCount() + "");

        loadGroupFaceUrl();

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
        mSelfNameCardView.setContent(profileBean.getSelfInfo().getNameCard());

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
        List<TUIExtensionInfo> warningExtensionList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.GroupProfileWarningButton.EXTENSION_ID, null);
        Collections.sort(warningExtensionList);
        warningExtensionListView.removeAllViews();
        for (TUIExtensionInfo extensionInfo : warningExtensionList) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.group_profile_warning_item_layout, null);
            TextView itemButton = itemView.findViewById(R.id.item_button);
            itemButton.setText(extensionInfo.getText());
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

        ((ViewGroup) groupMemberListView).removeAllViews();
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.GROUP_PROFILE_BEAN, profileBean);
        param.put(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.VIEW_TYPE, TUIConstants.TUIChat.VIEW_TYPE_CLASSIC);
        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.EXTENSION_ID, groupMemberListView, param);

        Map<String, Object> settingsParam = new HashMap<>();
        settingsParam.put(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.GROUP_PROFILE_BEAN, profileBean);
        settingsParam.put(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.VIEW_TYPE, TUIConstants.TUIChat.VIEW_TYPE_CLASSIC);
        List<TUIExtensionInfo> settingsExtensionList =
            TUICore.getExtensionList(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.EXTENSION_ID, settingsParam);
        Collections.sort(settingsExtensionList);
        extensionSettingsContainer.removeAllViews();
        for (TUIExtensionInfo extensionInfo : settingsExtensionList) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.group_profile_settings_item_layout, null);
            LineControllerView itemView = view.findViewById(R.id.line_controller_view);
            itemView.setName(extensionInfo.getText());
            itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (extensionInfo.getExtensionListener() != null) {
                        extensionInfo.getExtensionListener().onClicked(null);
                    }
                }
            });
            extensionSettingsContainer.addView(view);
        }

        Map<String, Object> bottomExtensionsParam = new HashMap<>();
        bottomExtensionsParam.put(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.GROUP_PROFILE_BEAN, profileBean);
        bottomExtensionsParam.put(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.CALLER, getContext());
        bottomExtensionsParam.put(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.VIEW_TYPE, TUIConstants.TUIChat.VIEW_TYPE_CLASSIC);
        List<TUIExtensionInfo> bottomExtensionList =
            TUICore.getExtensionList(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.EXTENSION_ID, bottomExtensionsParam);
        Collections.sort(bottomExtensionList);
        groupProfileBottomExtensionContainer.removeAllViews();
        for (TUIExtensionInfo extensionInfo : bottomExtensionList) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.group_profile_bottom_item_layout, null);
            TextView itemView = view.findViewById(R.id.item_view);
            itemView.setText(extensionInfo.getText());
            itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (extensionInfo.getExtensionListener() != null) {
                        extensionInfo.getExtensionListener().onClicked(null);
                    }
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
            TUICore.startActivity(getContext(), "GroupMemberActivity", bundle);
        });

        mGroupNotice.setOnClickListener(v -> {
            Intent intent = new Intent(getContext(), GroupNoticeActivity.class);
            intent.putExtra(TUIChatConstants.Group.GROUP_INFO, profileBean);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getContext().startActivity(intent);
        });
        groupDetailArea.setOnClickListener(v -> {
            if (!profileBean.canManage()) {
                return;
            }
            BottomSelectSheet sheet = new BottomSelectSheet(getContext());
            List<String> stringList = new ArrayList<>();
            String modifyGroupName = getResources().getString(R.string.modify_group_name);
            String modifyGroupNotice = getResources().getString(R.string.modify_group_notice);
            stringList.add(modifyGroupName);
            stringList.add(modifyGroupNotice);
            sheet.setSelectList(stringList);
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            sheet.setOnClickListener(index -> {
                if (index == 0) {
                    popupInputCard.setContent(mGroupNameView.getText().toString());
                    popupInputCard.setTitle(modifyGroupName);
                    popupInputCard.setOnPositive((result -> {
                        groupProfilePresenter.modifyGroupName(profileBean.getGroupID(), result);
                        if (!TextUtils.isEmpty(result)) {
                            mGroupNameView.setText(result);
                        }
                    }));
                    popupInputCard.show(groupDetailArea, Gravity.BOTTOM);
                } else if (index == 1) {
                    popupInputCard.setContent(mGroupNotificationText.getText().toString());
                    popupInputCard.setTitle(modifyGroupNotice);
                    popupInputCard.setOnPositive((result -> {
                        groupProfilePresenter.modifyGroupNotification(profileBean.getGroupID(), result, null);
                        if (TextUtils.isEmpty(result)) {
                            mGroupNotificationText.setText(getResources().getString(R.string.group_notice_empty_tip));
                        } else {
                            mGroupNotificationText.setText(result);
                        }
                    }));
                    popupInputCard.show(groupDetailArea, Gravity.BOTTOM);
                }
            });
            sheet.show();
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

        mChatBackground.setOnClickListener(v -> {
            if (onChangeChatBackgroundListener != null) {
                onChangeChatBackgroundListener.onChangeChatBackground();
            }
        });

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

        mClearMsgBtn.setOnClickListener(v
            -> new TUIKitDialog(getContext())
                   .builder()
                   .setCancelable(true)
                   .setCancelOutside(true)
                   .setTitle(getContext().getString(R.string.clear_group_msg_tip))
                   .setDialogWidth(0.75f)
                   .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), v12 -> clearHistoryMessage())
                   .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), v1 -> {})
                   .show());

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
            groupMemberListView.setVisibility(GONE);
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

    private void clearHistoryMessage() {
        if (groupProfilePresenter == null || profileBean == null) {
            return;
        }
        groupProfilePresenter.clearHistoryMessage(profileBean.getGroupID());
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
                setGroupProfile(profileBean);
                break;
            default:
                break;
        }
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

    public void setOnChangeChatBackgroundListener(OnChangeChatBackgroundListener listener) {
        onChangeChatBackgroundListener = listener;
    }

    public interface OnChangeChatBackgroundListener {
        default void onChangeChatBackground() {}
    }
}
