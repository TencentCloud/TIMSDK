package com.tencent.qcloud.tuikit.tuigroup.ui.view;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.component.popupcard.PopupInputCard;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.component.BottomSelectSheet;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.ui.page.GroupInfoActivity;
import com.tencent.qcloud.tuikit.tuigroup.ui.page.GroupMemberActivity;
import com.tencent.qcloud.tuikit.tuigroup.ui.page.GroupNoticeActivity;
import com.tencent.qcloud.tuikit.tuigroup.ui.page.ManageGroupActivity;
import com.tencent.qcloud.tuikit.tuigroup.ui.page.SetGroupManagerActivity;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;


public class GroupInfoLayout extends LinearLayout implements IGroupMemberLayout, View.OnClickListener {

    private static final String TAG = GroupInfoLayout.class.getSimpleName();
    private TitleBarLayout mTitleBar;
    private LineControllerView mMemberView;
    private GroupInfoAdapter mMemberAdapter;
    private IGroupMemberListener mMemberPreviewListener;
    private LineControllerView mGroupTypeView;
    private TextView mGroupIDView;
    private TextView mGroupNameView;
    private View groupDetailArea;
    private ImageView mGroupIcon;
    private ImageView mGroupDetailArrow;
    private View mGroupNotice;
    private TextView mGroupNoticeText;
    private LineControllerView mGroupManageView;
    private LineControllerView mNickView;
    private LineControllerView mJoinTypeView;
    private LineControllerView mTopSwitchView;
    private LineControllerView mMsgRevOptionSwitchView;
    private TextView mDissolveBtn;
    private TextView mClearMsgBtn;
    private TextView mChangeOwnerBtn;
    private GridView memberList;

    private GroupInfo mGroupInfo;
    private GroupInfoPresenter mPresenter;
    private ArrayList<String> mJoinTypes = new ArrayList<>();

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
        // 标题
        mTitleBar = findViewById(R.id.group_info_title_bar);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_detail), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) getContext()).finish();
            }
        });

        // 成员标题
        mMemberView = findViewById(R.id.group_member_bar);
        mMemberView.setOnClickListener(this);
        mMemberView.setCanNav(true);
        // 成员列表
        memberList = findViewById(R.id.group_members);
        mMemberAdapter = new GroupInfoAdapter();
        memberList.setAdapter(mMemberAdapter);
        // 群类型，只读
        mGroupTypeView = findViewById(R.id.group_type_bar);
        // 群ID，只读
        mGroupIDView = findViewById(R.id.group_account);
        // 群聊名称
        mGroupNameView = findViewById(R.id.group_name);

        groupDetailArea = findViewById(R.id.group_detail_area);
        groupDetailArea.setOnClickListener(this);
        // 群头像
        mGroupIcon = findViewById(R.id.group_icon);
        mGroupIcon.setOnClickListener(this);

        // 群详情右箭头
        mGroupDetailArrow = findViewById(R.id.group_detail_arrow);

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
                    public void onSuccess(Void data) {

                    }

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

        // 退群
        mDissolveBtn = findViewById(R.id.group_dissolve_button);
        mDissolveBtn.setOnClickListener(this);

        // 清空群消息按钮
        mClearMsgBtn = findViewById(R.id.group_clear_msg_button);
        mClearMsgBtn.setOnClickListener(this);

        // 转让群主
        mChangeOwnerBtn = findViewById(R.id.group_change_owner_button);
        mChangeOwnerBtn.setOnClickListener(this);
    }

    private void initView() {
        int radius = ScreenUtil.dip2px(5);
        GlideEngine.loadUserIcon(mGroupIcon, mGroupInfo.getFaceUrl(), TUIThemeManager.getAttrResId(getContext(), R.attr.core_default_group_icon), radius);
        if (!mGroupInfo.isCanManagerGroup()) {
            mGroupDetailArrow.setVisibility(GONE);
        }
        if (mGroupInfo.isOwner()) {
            mChangeOwnerBtn.setVisibility(VISIBLE);
        } else {
            mChangeOwnerBtn.setVisibility(GONE);
        }
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
        } else if (v.getId() == R.id.group_detail_area) {
            if (!mGroupInfo.isCanManagerGroup()) {
                return;
            }
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            BottomSelectSheet sheet = new BottomSelectSheet(getContext());
            List<String> stringList = new ArrayList<>();
            String modifyGroupName = getResources().getString(R.string.modify_group_name);
            String modifyGroupNotice = getResources().getString(R.string.modify_group_notice);
            stringList.add(modifyGroupName);
            stringList.add(modifyGroupNotice);
            sheet.setSelectList(stringList);
            sheet.setOnClickListener(new BottomSelectSheet.BottomSelectSheetOnClickListener() {
                @Override
                public void onSheetClick(int index) {
                    if (index == 0) {
                        popupInputCard.setContent(mGroupNameView.getText().toString());
                        popupInputCard.setTitle(modifyGroupName);
                        popupInputCard.setOnPositive((result -> {
                            mPresenter.modifyGroupName(result);
                            if (!TextUtils.isEmpty(result)) {
                                mGroupNameView.setText(result);
                            }
                        }));
                        popupInputCard.show(groupDetailArea, Gravity.BOTTOM);
                    } else if (index == 1) {
                        popupInputCard.setContent(mGroupNoticeText.getText().toString());
                        popupInputCard.setTitle(modifyGroupNotice);
                        popupInputCard.setOnPositive((result -> {
                            mPresenter.modifyGroupNotice(result);
                            if (TextUtils.isEmpty(result)) {
                                mGroupNoticeText.setText(getResources().getString(R.string.group_notice_empty_tip));
                            } else {
                                mGroupNoticeText.setText(result);
                            }
                        }));
                        popupInputCard.show(groupDetailArea, Gravity.BOTTOM);
                    }
                }
            });
            sheet.show();
        } else if (v.getId() == R.id.group_icon) {
            if (!mGroupInfo.isCanManagerGroup()) {
                return;
            }
            String groupUrl = String.format("https://picsum.photos/id/%d/200/200", new Random().nextInt(1000));
            mPresenter.modifyGroupFaceUrl(mGroupInfo.getId(), groupUrl, new IUIKitCallback<Void>() {
                @Override
                public void onSuccess(Void data) {
                    mGroupInfo.setFaceUrl(groupUrl);
                    setGroupInfo(mGroupInfo);
                    ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.modify_icon_suc));
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.modify_icon_fail) + ", code = " + errCode + ", info = " + errMsg);
                }
            });
        } else if (v.getId() == R.id.group_notice) {
            Intent intent = new Intent(getContext(), GroupNoticeActivity.class);
            GroupNoticeActivity.setOnGroupNoticeChangedListener(new GroupNoticeActivity.OnGroupNoticeChangedListener() {
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
            bundle.putString(SelectionActivity.Selection.TITLE, getResources().getString(R.string.group_join_type));
            bundle.putStringArrayList(SelectionActivity.Selection.LIST, mJoinTypes);
            bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, mGroupInfo.getJoinType());
            SelectionActivity.startListSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyGroupInfo((Integer) text, TUIGroupConstants.Group.MODIFY_GROUP_JOIN_TYPE);
                }
            });
        } else if (v.getId() == R.id.group_dissolve_button) {
            if (mGroupInfo.isOwner() &&
                    (!mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_WORK)
                            && !mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_PRIVATE))) {
                new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.dismiss_group_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(R.string.sure), new View.OnClickListener() {
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
                        .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
                        })
                        .show();
            } else {
                new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.quit_group_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(R.string.sure), new View.OnClickListener() {
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
                        .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
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
                    .setPositiveButton(getContext().getString(R.string.sure), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Map<String, Object> hashMap = new HashMap<>();
                            hashMap.put(TUIConstants.TUIGroup.GROUP_ID, mGroupInfo.getId());
                            TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP,
                                    TUIConstants.TUIGroup.EVENT_SUB_KEY_CLEAR_MESSAGE, hashMap);
                        }
                    })
                    .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {

                        }
                    })
                    .show();
        } else if (v.getId() == R.id.group_manage) {
            Intent intent = new Intent(getContext(), ManageGroupActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(TUIGroupConstants.Group.GROUP_INFO, mGroupInfo);
            getContext().startActivity(intent);
        } else if (v == mChangeOwnerBtn) {
            Intent intent = new Intent(getContext(), GroupMemberActivity.class);
            intent.putExtra(TUIGroupConstants.Selection.IS_SELECT_MODE, true);
            intent.putExtra(TUIGroupConstants.Group.GROUP_INFO, mGroupInfo);
            intent.putExtra(TUIGroupConstants.Selection.LIMIT, 1);
            intent.putExtra(TUIGroupConstants.Selection.TITLE, getResources().getString(R.string.group_transfer_group_owner));
            ((Activity) getContext()).startActivityForResult(intent, GroupInfoActivity.REQUEST_FOR_CHANGE_OWNER);
        }
    }

    public void loadGroupInfo(String groupId) {
        mPresenter.loadGroupInfo(groupId);
    }

    public void getGroupMembers(GroupInfo groupInfo) {
        mPresenter.getGroupMembers(groupInfo, new IUIKitCallback<GroupInfo>() {
            @Override
            public void onSuccess(GroupInfo data) {
                setGroupInfo((GroupInfo) data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    private void setGroupInfo(GroupInfo info) {
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
        mMemberView.setContent(info.getMemberCount() + "人");
        mMemberAdapter.setDataSource(info);

        int columnNum = memberList.getNumColumns();
        int rowNum = (int) Math.ceil(mMemberAdapter.getCount() * 1.0f / columnNum);
        int itemHeight = ScreenUtil.dip2px(88);
        ViewGroup.LayoutParams layoutParams = memberList.getLayoutParams();
        layoutParams.height = itemHeight * rowNum;
        memberList.setLayoutParams(layoutParams);

        mGroupTypeView.setContent(convertGroupText(info.getGroupType()));
        mJoinTypeView.setContent(mJoinTypes.get(info.getJoinType()));
        mNickView.setContent(mPresenter.getNickName());
        mTopSwitchView.setChecked(mGroupInfo.isTopChat());

        if (GroupInfo.GROUP_TYPE_MEETING.equals(info.getGroupType())) {
            mMsgRevOptionSwitchView.setVisibility(GONE);
        } else {
            mMsgRevOptionSwitchView.setChecked(mGroupInfo.getMessageReceiveOption());

            mMsgRevOptionSwitchView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                    mPresenter.setGroupReceiveMessageOpt(mGroupInfo, isChecked);
                }
            });
        }

        mDissolveBtn.setText(R.string.dissolve);
        mClearMsgBtn.setText(R.string.clear_message);
        if (mGroupInfo.isOwner()) {
            mJoinTypeView.setVisibility(VISIBLE);
            if (mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_WORK)
                    || mGroupInfo.getGroupType().equals(TUIConstants.GroupType.TYPE_PRIVATE)) {
                mDissolveBtn.setText(R.string.exit_group);
            }
        } else {
            mJoinTypeView.setCanNav(false);
            mJoinTypeView.setOnClickListener(null);
            mDissolveBtn.setText(R.string.exit_group);
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
        if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_PRIVATE)
                || TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_WORK)) {
            groupText = getContext().getString(R.string.private_group);
        } else if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_PUBLIC)) {
            groupText = getContext().getString(R.string.public_group);
        } else if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_CHAT_ROOM)
                || TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_MEETING)) {
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
            case TUIGroupConstants.Group.MODIFY_MEMBER_NAME:
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_nickname_success));
                mNickView.setContent(value.toString());
                break;
        }
    }

    public void setRouter(IGroupMemberListener listener) {
        mMemberPreviewListener = listener;
        mMemberAdapter.setManagerCallBack(listener);
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
    public void setParentLayout(Object parent) {

    }

}
