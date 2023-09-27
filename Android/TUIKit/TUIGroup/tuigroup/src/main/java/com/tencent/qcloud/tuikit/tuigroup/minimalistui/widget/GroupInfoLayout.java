package com.tencent.qcloud.tuikit.tuigroup.minimalistui.widget;

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
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.SelectionMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.page.GroupInfoMinimalistFragment;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.page.GroupMemberMinimalistActivity;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.page.GroupNoticeMinimalistActivity;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.page.ManageGroupMinimalistActivity;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupInfoLayout extends LinearLayout implements IGroupMemberLayout, View.OnClickListener {
    private static final String TAG = GroupInfoLayout.class.getSimpleName();
    private TitleBarLayout mTitleBar;
    private MinimalistLineControllerView mMemberView;
    private GroupInfoAdapter mMemberAdapter;
    private IGroupMemberListener mMemberPreviewListener;
    private MinimalistLineControllerView mGroupTypeView;
    private TextView mGroupIDView;
    private TextView mGroupNameView;
    private ImageView editGroupNameView;
    private ShadeImageView mGroupIcon;
    private View mGroupNotice;
    private TextView mGroupNoticeText;
    private MinimalistLineControllerView mGroupManageView;
    private MinimalistLineControllerView mAddMembersView;
    private MinimalistLineControllerView mNickView;
    private MinimalistLineControllerView mJoinTypeView;
    private MinimalistLineControllerView mInviteTypeView;
    private MinimalistLineControllerView mTopSwitchView;
    private MinimalistLineControllerView mMsgRevOptionSwitchView;
    private MinimalistLineControllerView mFoldGroupChatSwitchView;
    private MinimalistLineControllerView mChatBackground;
    private View mLayoutFold;
    private MinimalistLineControllerView mDissolveBtn;
    private MinimalistLineControllerView mClearMsgBtn;
    private MinimalistLineControllerView mChangeOwnerBtn;
    private RecyclerView memberList;

    private OnButtonClickListener mListener;

    private GroupInfo mGroupInfo;
    private GroupInfoPresenter mPresenter;
    private ArrayList<String> mJoinTypes = new ArrayList<>();
    private ArrayList<String> mInviteTypes = new ArrayList<>();
    private GroupInfoMinimalistFragment.OnModifyGroupAvatarListener onModifyGroupAvatarListener;

    private RecyclerView profileItemListView;
    private ProfileItemAdapter profileItemAdapter;

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
        inflate(getContext(), R.layout.group_minimalist_info_layout, this);
        // 标题
        mTitleBar = findViewById(R.id.group_info_title_bar);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_detail), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) getContext()).finish();
            }
        });
        mAddMembersView = findViewById(R.id.add_group_members);
        mAddMembersView.setOnClickListener(this);

        // 成员标题
        mMemberView = findViewById(R.id.group_member_bar);
        mMemberView.setOnClickListener(this);
        mMemberView.setCanNav(true);
        // 成员列表
        memberList = findViewById(R.id.group_members);
        mMemberAdapter = new GroupInfoAdapter();
        // 群类型，只读
        mGroupTypeView = findViewById(R.id.group_type_bar);
        // 群ID，只读
        mGroupIDView = findViewById(R.id.group_account);
        // 群聊名称
        mGroupNameView = findViewById(R.id.group_name);
        editGroupNameView = findViewById(R.id.edit_group_name);
        editGroupNameView.setOnClickListener(this);
        // 群头像
        mGroupIcon = findViewById(R.id.group_icon);
        mGroupIcon.setRadius(ScreenUtil.dip2px(50));
        mGroupIcon.setOnClickListener(this);

        // 群公告
        mGroupNotice = findViewById(R.id.group_notice);
        mGroupNotice.setOnClickListener(this);
        mGroupNoticeText = findViewById(R.id.group_notice_text);
        // 群管理
        mGroupManageView = findViewById(R.id.group_manage);
        mGroupManageView.setOnClickListener(this);

        // 加群方式
        mJoinTypeView = findViewById(R.id.join_type_bar);
        mJoinTypeView.setOnClickListener(this);
        mJoinTypeView.setCanNav(true);
        mJoinTypes.addAll(Arrays.asList(getResources().getStringArray(R.array.group_join_type)));

        // 邀请进群方式
        mInviteTypeView = findViewById(R.id.invite_type_bar);
        mInviteTypeView.setOnClickListener(this);
        mInviteTypeView.setCanNav(true);
        mInviteTypes.addAll(Arrays.asList(getResources().getStringArray(R.array.group_invite_type)));

        // 群昵称
        mNickView = findViewById(R.id.self_nickname_bar);
        mNickView.setOnClickListener(this);
        mNickView.setCanNav(true);
        // 是否置顶
        mTopSwitchView = findViewById(R.id.chat_to_top_switch);
        mTopSwitchView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                if (mGroupInfo == null) {
                    return;
                }
                mPresenter.setTopConversation(mGroupInfo.getId(), isChecked, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {}

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(module + ", Error code = " + errCode + ", desc = " + errMsg);
                        buttonView.setChecked(false);
                    }
                });
            }
        });
        // 消息接收选项
        mMsgRevOptionSwitchView = findViewById(R.id.msg_rev_option);
        // 折叠
        mLayoutFold = findViewById(R.id.layout_fold);
        mFoldGroupChatSwitchView = findViewById(R.id.fold_group_chat);

        // 退群
        mDissolveBtn = findViewById(R.id.group_dissolve_button);
        mDissolveBtn.setOnClickListener(this);
        mDissolveBtn.setNameColor(0xFFFF584C);

        // 清空群消息按钮
        mClearMsgBtn = findViewById(R.id.group_clear_msg_button);
        mClearMsgBtn.setOnClickListener(this);
        mClearMsgBtn.setNameColor(0xFFFF584C);

        // 转让群主
        mChangeOwnerBtn = findViewById(R.id.group_change_owner_button);
        mChangeOwnerBtn.setOnClickListener(this);
        mChangeOwnerBtn.setNameColor(0xFFFF584C);

        mChatBackground = findViewById(R.id.chat_background);
        mChatBackground.setOnClickListener(this);
        mChatBackground.setCanNav(true);

        int linearViewBgColor = 0xF0F9F9F9;
        mMsgRevOptionSwitchView.setBackgroundColor(linearViewBgColor);
        mLayoutFold.setBackgroundColor(linearViewBgColor);
        mFoldGroupChatSwitchView.setBackgroundColor(linearViewBgColor);
        mTopSwitchView.setBackgroundColor(linearViewBgColor);
        mGroupNotice.setBackgroundColor(linearViewBgColor);
        mGroupManageView.setBackgroundColor(linearViewBgColor);
        mJoinTypeView.setBackgroundColor(linearViewBgColor);
        mInviteTypeView.setBackgroundColor(linearViewBgColor);
        mGroupTypeView.setBackgroundColor(linearViewBgColor);
        mNickView.setBackgroundColor(linearViewBgColor);
        mMemberView.setBackgroundColor(linearViewBgColor);
        mChatBackground.setBackgroundColor(linearViewBgColor);
        mChangeOwnerBtn.setBackgroundColor(linearViewBgColor);
        mClearMsgBtn.setBackgroundColor(linearViewBgColor);
        mDissolveBtn.setBackgroundColor(linearViewBgColor);
        mAddMembersView.setBackgroundColor(linearViewBgColor);
        mAddMembersView.setNameColor(0xFF0365F9);

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

    private void initView() {
        if (TextUtils.isEmpty(mGroupInfo.getFaceUrl())) {
            String conversationID = "group_" + mGroupInfo.getId();
            String avatarUrl = ImageUtil.getGroupConversationAvatar(conversationID);
            GlideEngine.loadImageSetDefault(mGroupIcon, avatarUrl, TUIUtil.getDefaultGroupIconResIDByGroupType(getContext(), mGroupInfo.getGroupType()));
        } else {
            GlideEngine.loadImageSetDefault(
                mGroupIcon, mGroupInfo.getFaceUrl(), TUIUtil.getDefaultGroupIconResIDByGroupType(getContext(), mGroupInfo.getGroupType()));
        }
        if (mGroupInfo.isCanManagerGroup()) {
            editGroupNameView.setVisibility(VISIBLE);
        }
        if (mGroupInfo.isOwner()) {
            mChangeOwnerBtn.setVisibility(VISIBLE);
        } else {
            mChangeOwnerBtn.setVisibility(GONE);
        }
        String groupType = mGroupInfo.getGroupType();
        if (mGroupInfo.getInviteType() != V2TIMGroupInfo.V2TIM_GROUP_ADD_FORBID) {
            mAddMembersView.setVisibility(VISIBLE);
        } else {
            mAddMembersView.setVisibility(GONE);
        }
        setupExtension();
    }

    private void setupExtension() {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIGroup.Extension.GroupProfileItem.GROUP_ID, mGroupInfo.getId());
        param.put(TUIConstants.TUIGroup.Extension.GroupProfileItem.CONTEXT, getContext());
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID, param);
        Collections.sort(extensionInfoList);
        profileItemAdapter.setExtensionInfoList(extensionInfoList);
        profileItemAdapter.notifyDataSetChanged();
    }

    public void setGroupInfoPresenter(GroupInfoPresenter presenter) {
        this.mPresenter = presenter;
        if (mMemberAdapter != null) {
            mMemberAdapter.setPresenter(presenter);
        }
    }

    @Override
    public void onClick(View v) {
        if (mGroupInfo == null) {
            TUIGroupLog.e(TAG, "mGroupInfo is NULL");
            return;
        }
        if (v.getId() == R.id.group_member_bar) {
            if (mMemberPreviewListener != null) {
                mMemberPreviewListener.forwardListMember(mGroupInfo);
            }
        } else if (v == editGroupNameView) {
            if (!mGroupInfo.isCanManagerGroup()) {
                return;
            }
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mGroupNameView.getText().toString());
            String modifyGroupName = getResources().getString(R.string.modify_group_name);
            popupInputCard.setTitle(modifyGroupName);
            popupInputCard.setOnPositive((result -> {
                mPresenter.modifyGroupName(result);
                if (!TextUtils.isEmpty(result)) {
                    mGroupNameView.setText(result);
                }
            }));
            popupInputCard.show(mGroupNameView, Gravity.BOTTOM);
        } else if (v.getId() == R.id.group_icon) {
            if (!mGroupInfo.isCanManagerGroup()) {
                return;
            }

            if (onModifyGroupAvatarListener != null) {
                onModifyGroupAvatarListener.onModifyGroupAvatar(mGroupInfo.getFaceUrl());
            }
        } else if (v.getId() == R.id.group_notice) {
            Intent intent = new Intent(getContext(), GroupNoticeMinimalistActivity.class);
            GroupNoticeMinimalistActivity.setOnGroupNoticeChangedListener(new GroupNoticeMinimalistActivity.OnGroupNoticeChangedListener() {
                @Override
                public void onChanged(String notice) {
                    if (TextUtils.isEmpty(notice)) {
                        mGroupNoticeText.setText(getResources().getString(R.string.group_notice_empty_tip));
                    } else {
                        mGroupNoticeText.setText(notice);
                    }
                }
            });
            intent.putExtra(TUIGroupConstants.Group.GROUP_INFO, mGroupInfo);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getContext().startActivity(intent);
        } else if (v.getId() == R.id.self_nickname_bar) {
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mNickView.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.modify_nick_name_in_goup));
            popupInputCard.setOnPositive((result -> {
                mPresenter.modifyMyGroupNickname(result);
                mNickView.setContent(result);
            }));
            popupInputCard.show(mNickView, Gravity.BOTTOM);

        } else if (v.getId() == R.id.join_type_bar) {
            if (mGroupTypeView.getContent().equals(getContext().getString(R.string.chat_room))) {
                ToastUtil.toastLongMessage(getContext().getString(R.string.chat_room_tip));
                return;
            }
            Bundle bundle = new Bundle();
            bundle.putString(SelectionMinimalistActivity.Selection.TITLE, getResources().getString(R.string.group_join_type));
            bundle.putStringArrayList(SelectionMinimalistActivity.Selection.LIST, mJoinTypes);
            bundle.putInt(SelectionMinimalistActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, mGroupInfo.getJoinType());
            SelectionMinimalistActivity.startListSelection((Activity) getContext(), bundle, new SelectionMinimalistActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyGroupInfo((Integer) text, TUIGroupConstants.Group.MODIFY_GROUP_JOIN_TYPE);
                }
            });
        } else if (v.getId() == R.id.invite_type_bar) {
            Bundle bundle = new Bundle();
            bundle.putString(SelectionMinimalistActivity.Selection.TITLE, getResources().getString(R.string.group_invite_type));
            bundle.putStringArrayList(SelectionMinimalistActivity.Selection.LIST, mInviteTypes);
            bundle.putInt(SelectionMinimalistActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, mGroupInfo.getInviteType());
            SelectionMinimalistActivity.startListSelection((Activity) getContext(), bundle, new SelectionMinimalistActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyGroupInfo((Integer) text, TUIGroupConstants.Group.MODIFY_GROUP_INVITE_TYPE);
                }
            });
        } else if (v.getId() == R.id.group_dissolve_button) {
            if (mGroupInfo.isOwner()
                && (!mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_WORK)
                    && !mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_PRIVATE))) {
                new TUIKitDialog(getContext())
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getContext().getString(R.string.dismiss_group_tip))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mPresenter.deleteGroup(new IUIKitCallback<Void>() {
                                    @Override
                                    public void onSuccess(Void data) {
                                        ((Activity) GroupInfoLayout.this.getContext()).finish();
                                    }

                                    @Override
                                    public void onError(String module, int errCode, String errMsg) {
                                        ToastUtil.toastLongMessage(errMsg);
                                    }
                                });
                            }
                        })
                    .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        })
                    .show();
            } else {
                new TUIKitDialog(getContext())
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getContext().getString(R.string.quit_group_tip))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mPresenter.quitGroup(new IUIKitCallback<Void>() {
                                    @Override
                                    public void onSuccess(Void data) {
                                        ((Activity) GroupInfoLayout.this.getContext()).finish();
                                    }

                                    @Override
                                    public void onError(String module, int errCode, String errMsg) {
                                        ((Activity) GroupInfoLayout.this.getContext()).finish();
                                        ToastUtil.toastShortMessage("quitGroup failed, errCode =  " + errCode + " errMsg = " + errMsg);
                                    }
                                });
                            }
                        })
                    .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        })
                    .show();
            }
        } else if (v.getId() == R.id.group_clear_msg_button) {
            new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.clear_group_msg_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Map<String, Object> hashMap = new HashMap<>();
                            hashMap.put(TUIConstants.TUIGroup.GROUP_ID, mGroupInfo.getId());
                            TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE, hashMap);
                        }
                    })
                .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {}
                    })
                .show();
        } else if (v.getId() == R.id.group_manage) {
            Intent intent = new Intent(getContext(), ManageGroupMinimalistActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(TUIGroupConstants.Group.GROUP_INFO, mGroupInfo);
            getContext().startActivity(intent);
        } else if (v == mChangeOwnerBtn) {
            ArrayList<String> excludeList = new ArrayList<>();
            excludeList.add(TUILogin.getLoginUser());
            Bundle param = new Bundle();
            param.putBoolean(TUIConstants.TUIGroup.IS_SELECT_MODE, true);
            param.putString(TUIConstants.TUIGroup.GROUP_ID, mGroupInfo.getId());
            param.putInt(TUIConstants.TUIGroup.LIMIT, 1);
            param.putStringArrayList(TUIConstants.TUIGroup.EXCLUDE_LIST, excludeList);
            param.putString(TUIConstants.TUIGroup.TITLE, getResources().getString(R.string.group_transfer_group_owner));

            TUICore.startActivityForResult(
                (ActivityResultCaller) getContext(), GroupMemberMinimalistActivity.class, param, new ActivityResultCallback<ActivityResult>() {
                    @Override
                    public void onActivityResult(ActivityResult result) {
                        if (result.getData() != null) {
                            List<String> selectedList = result.getData().getStringArrayListExtra(TUIGroupConstants.Selection.LIST);
                            if (selectedList != null && !selectedList.isEmpty()) {
                                String newOwnerId = selectedList.get(0);
                                if (mListener != null) {
                                    mListener.onChangeGroupOwner(newOwnerId);
                                }
                            }
                        }
                    }
                });

        } else if (v.getId() == R.id.chat_background) {
            if (mListener != null) {
                mListener.onSetChatBackground();
            }
        } else if (v == mAddMembersView) {
            if (mMemberPreviewListener != null) {
                mMemberPreviewListener.forwardAddMember(mGroupInfo);
            }
        }
    }

    public void loadGroupInfo(String groupId) {
        mPresenter.loadGroupInfo(groupId);
    }

    public void setGroupInfo(GroupInfo info) {
        if (info == null) {
            return;
        }
        this.mGroupInfo = info;
        mGroupNameView.setText(info.getGroupName());
        mGroupIDView.setText(info.getId());
        if (TextUtils.isEmpty(info.getNotice())) {
            mGroupNoticeText.setText(getResources().getString(R.string.group_notice_empty_tip));
        } else {
            mGroupNoticeText.setText(info.getNotice());
        }
        mMemberView.setName(getResources().getString(R.string.group_members) + String.format("（%s）", info.getMemberCount() + ""));
        mMemberAdapter.setDataSource(info);
        mMemberAdapter.setOnGroupMemberClickListener(new GroupMemberLayout.OnGroupMemberClickListener() {
            @Override
            public void onClick(GroupMemberInfo groupMemberInfo) {
                Bundle params = new Bundle();
                params.putString(TUIConstants.TUIChat.CHAT_ID, groupMemberInfo.getAccount());
                TUICore.startActivity("FriendProfileMinimalistActivity", params);
            }
        });
        memberList.setLayoutManager(new LinearLayoutManager(getContext()));
        memberList.setAdapter(mMemberAdapter);

        mGroupTypeView.setContent(convertGroupText(info.getGroupType()));
        mJoinTypeView.setContent(mJoinTypes.get(info.getJoinType()));
        mInviteTypeView.setContent(mInviteTypes.get(info.getInviteType()));
        mNickView.setContent(mPresenter.getNickName());
        mTopSwitchView.setChecked(mGroupInfo.isTopChat());

        if (GroupInfo.GROUP_TYPE_MEETING.equals(info.getGroupType())) {
            mMsgRevOptionSwitchView.setVisibility(GONE);
            mLayoutFold.setVisibility(GONE);
        } else {
            if (mGroupInfo.getMessageReceiveOption()) {
                mLayoutFold.setVisibility(View.VISIBLE);
                if (mGroupInfo.isFolded()) {
                    mFoldGroupChatSwitchView.setChecked(true);
                }
            } else {
                mLayoutFold.setVisibility(View.GONE);
            }

            mMsgRevOptionSwitchView.setChecked(mGroupInfo.getMessageReceiveOption());
            mMsgRevOptionSwitchView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                    mPresenter.setGroupNotDisturb(mGroupInfo, isChecked, new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            if (!isChecked) {
                                mLayoutFold.setVisibility(View.GONE);
                                if (mGroupInfo.isFolded()) {
                                    mPresenter.setGroupFold(mGroupInfo, false, new IUIKitCallback<Void>() {
                                        @Override
                                        public void onSuccess(Void data) {
                                            mFoldGroupChatSwitchView.setChecked(false);
                                        }

                                        @Override
                                        public void onError(String module, int errCode, String errMsg) {
                                            ToastUtil.toastShortMessage(module + ", Error code = " + errCode + ", desc = " + errMsg);
                                        }
                                    });
                                }
                            } else {
                                mLayoutFold.setVisibility(View.VISIBLE);
                            }
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastShortMessage(module + ", Error code = " + errCode + ", desc = " + errMsg);
                        }
                    });
                }
            });
        }

        if (mGroupInfo.isFolded()) {
            mTopSwitchView.setMask(true);
        }

        mFoldGroupChatSwitchView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mPresenter.setGroupFold(mGroupInfo, isChecked, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        if (isChecked) {
                            if (mGroupInfo.isTopChat()) {
                                mPresenter.setTopConversation(mGroupInfo.getId(), false, new IUIKitCallback<Void>() {
                                    @Override
                                    public void onSuccess(Void data) {
                                        mTopSwitchView.setChecked(false);
                                        mTopSwitchView.setMask(true);
                                    }

                                    @Override
                                    public void onError(String module, int errCode, String errMsg) {
                                        ToastUtil.toastShortMessage(module + ", Error code = " + errCode + ", desc = " + errMsg);
                                    }
                                });
                            } else {
                                mTopSwitchView.setMask(true);
                            }
                        } else {
                            mTopSwitchView.setMask(false);
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(module + ", Error code = " + errCode + ", desc = " + errMsg);
                    }
                });
            }
        });

        mDissolveBtn.setName(getResources().getString(R.string.dissolve));
        mClearMsgBtn.setName(getResources().getString(R.string.clear_message));
        if (mGroupInfo.isOwner()) {
            mJoinTypeView.setVisibility(VISIBLE);
            if (mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_WORK) || mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_PRIVATE)) {
                mDissolveBtn.setName(getResources().getString(R.string.exit_group));
            }
        } else {
            mJoinTypeView.setCanNav(false);
            mJoinTypeView.setOnClickListener(null);
            mInviteTypeView.setCanNav(false);
            mInviteTypeView.setOnClickListener(null);
            mDissolveBtn.setName(getResources().getString(R.string.exit_group));
        }

        if (mGroupInfo.isCanManagerGroup()) {
            mGroupManageView.setVisibility(VISIBLE);
        }

        initView();
    }

    private String convertGroupText(String groupType) {
        String groupText = "";
        if (TextUtils.isEmpty(groupType)) {
            return groupText;
        }
        if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_PRIVATE) || TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_WORK)) {
            groupText = getContext().getString(R.string.private_group);
        } else if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_PUBLIC)) {
            groupText = getContext().getString(R.string.public_group);
        } else if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_CHAT_ROOM) || TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_MEETING)) {
            groupText = getContext().getString(R.string.chat_room);
        } else if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_COMMUNITY)) {
            groupText = getContext().getString(R.string.community_group);
        }
        return groupText;
    }

    public void onGroupInfoModified(Object value, int type) {
        switch (type) {
            case TUIGroupConstants.Group.MODIFY_GROUP_NAME:
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_group_name_success));
                mGroupNameView.setText(value.toString());
                break;
            case TUIGroupConstants.Group.MODIFY_GROUP_NOTICE:
                if (TextUtils.isEmpty(value.toString())) {
                    mGroupNoticeText.setText(getResources().getString(R.string.group_notice_empty_tip));
                } else {
                    mGroupNoticeText.setText(value.toString());
                }
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_group_notice_success));
                break;
            case TUIGroupConstants.Group.MODIFY_GROUP_JOIN_TYPE:
                mJoinTypeView.setContent(mJoinTypes.get((Integer) value));
                break;
            case TUIGroupConstants.Group.MODIFY_GROUP_INVITE_TYPE:
                mInviteTypeView.setContent(mInviteTypes.get((Integer) value));
                break;
            case TUIGroupConstants.Group.MODIFY_MEMBER_NAME:
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_nickname_success));
                mNickView.setContent(value.toString());
                break;
            default:
                break;
        }
    }

    public void setRouter(IGroupMemberListener listener) {
        mMemberPreviewListener = listener;
    }

    public void setOnModifyGroupAvatarListener(GroupInfoMinimalistFragment.OnModifyGroupAvatarListener onModifyGroupAvatarListener) {
        this.onModifyGroupAvatarListener = onModifyGroupAvatarListener;
    }

    public void modifyGroupAvatar(String avatarUrl) {
        mPresenter.modifyGroupFaceUrl(mGroupInfo.getId(), avatarUrl, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                mGroupInfo.setFaceUrl(avatarUrl);
                setGroupInfo(mGroupInfo);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(
                    TUIGroupService.getAppContext().getString(R.string.modify_icon_fail) + ", code = " + errCode + ", info = " + errMsg);
            }
        });
    }

    @Override
    public void onGroupInfoChanged(GroupInfo dataSource) {
        setGroupInfo(dataSource);
    }

    @Override
    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setParentLayout(Object parent) {}

    class ProfileItemAdapter extends RecyclerView.Adapter<ProfileItemAdapter.ItemViewHolder> {
        List<TUIExtensionInfo> extensionInfoList;

        public void setExtensionInfoList(List<TUIExtensionInfo> extensionInfoList) {
            this.extensionInfoList = extensionInfoList;
        }

        @NonNull
        @Override
        public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.group_minimalist_group_profile_item_layout, null);
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

    public void setOnButtonClickListener(OnButtonClickListener l) {
        mListener = l;
    }

    public abstract static class OnButtonClickListener {
        public void onSetChatBackground() {}

        public void onChangeGroupOwner(String newOwnerId) {}
    }
}
