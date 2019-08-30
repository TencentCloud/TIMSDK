package com.tencent.qcloud.tim.uikit.modules.group.info;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.GridView;
import android.widget.LinearLayout;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.LineControllerView;
import com.tencent.qcloud.tim.uikit.component.SelectionActivity;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tim.uikit.modules.group.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tim.uikit.modules.group.member.IGroupMemberRouter;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;


public class GroupInfoLayout extends LinearLayout implements IGroupMemberLayout, View.OnClickListener {

    private static final String TAG = GroupInfoLayout.class.getSimpleName();
    private TitleBarLayout mTitleBar;
    private LineControllerView mMemberView;
    private GroupInfoAdapter mMemberAdapter;
    private IGroupMemberRouter mMemberPreviewListener;
    private LineControllerView mGroupTypeView;
    private LineControllerView mGroupIDView;
    private LineControllerView mGroupNameView;
    private LineControllerView mGroupIcon;
    private LineControllerView mGroupNotice;
    private LineControllerView mNickView;
    private LineControllerView mJoinTypeView;
    private LineControllerView mTopSwitchView;
    private Button mDissolveBtn;

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
        mTitleBar.setTitle(getResources().getString(R.string.group_detail), TitleBarLayout.POSITION.MIDDLE);
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
        GridView memberList = findViewById(R.id.group_members);
        mMemberAdapter = new GroupInfoAdapter();
        memberList.setAdapter(mMemberAdapter);
        // 群类型，只读
        mGroupTypeView = findViewById(R.id.group_type_bar);
        // 群ID，只读
        mGroupIDView = findViewById(R.id.group_account);
        // 群聊名称
        mGroupNameView = findViewById(R.id.group_name);
        mGroupNameView.setOnClickListener(this);
        mGroupNameView.setCanNav(true);
        // 群头像
        mGroupIcon = findViewById(R.id.group_icon);
        mGroupIcon.setOnClickListener(this);
        mGroupIcon.setCanNav(false);
        // 群公告
        mGroupNotice = findViewById(R.id.group_notice);
        mGroupNotice.setOnClickListener(this);
        mGroupNotice.setCanNav(true);
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
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mPresenter.setTopConversation(isChecked);
            }
        });
        // 退群
        mDissolveBtn = findViewById(R.id.group_dissolve_button);
        mDissolveBtn.setOnClickListener(this);

        mPresenter = new GroupInfoPresenter(this);
    }

    @Override
    public void onClick(View v) {
        if (mGroupInfo == null) {
            TUIKitLog.e(TAG, "mGroupInfo is NULL");
            return;
        }
        if (v.getId() == R.id.group_member_bar) {
            if (mMemberPreviewListener != null) {
                mMemberPreviewListener.forwardListMember(mGroupInfo);
            }
        } else if (v.getId() == R.id.group_name) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.modify_group_name));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mGroupNameView.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 20);
            SelectionActivity.startTextSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyGroupName(text.toString());
                    mGroupNameView.setContent(text.toString());
                }
            });
        } else if (v.getId() == R.id.group_icon) {
            String groupUrl = String.format("https://picsum.photos/id/%d/200/200", new Random().nextInt(1000));
            TIMGroupManager.ModifyGroupInfoParam param = new TIMGroupManager.ModifyGroupInfoParam(mGroupInfo.getId());
            param.setFaceUrl(groupUrl);
            TIMGroupManager.getInstance().modifyGroupInfo(param, new TIMCallBack() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "modify group icon failed, code:" + code +"|desc:" + desc);
                    ToastUtil.toastLongMessage("修改群头像失败, code = " + code + ", info = " + desc);
                }

                @Override
                public void onSuccess() {
                    ToastUtil.toastLongMessage("修改群头像成功");
                }
            });

        } else if (v.getId() == R.id.group_notice) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.modify_group_notice));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mGroupNotice.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 200);
            SelectionActivity.startTextSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyGroupNotice(text.toString());
                    mGroupNotice.setContent(text.toString());
                }
            });
        } else if (v.getId() == R.id.self_nickname_bar) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.modify_nick_name_in_goup));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mNickView.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 20);
            SelectionActivity.startTextSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyMyGroupNickname(text.toString());
                    mNickView.setContent(text.toString());
                }
            });
        } else if (v.getId() == R.id.join_type_bar) {
            if (mGroupTypeView.getContent().equals("聊天室")) {
                ToastUtil.toastLongMessage("加入聊天室为自动审批，暂不支持修改");
                return;
            }
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.group_join_type));
            bundle.putStringArrayList(TUIKitConstants.Selection.LIST, mJoinTypes);
            bundle.putInt(TUIKitConstants.Selection.DEFAULT_SELECT_ITEM_INDEX, mGroupInfo.getJoinType());
            SelectionActivity.startListSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(final Object text) {
                    mPresenter.modifyGroupInfo((Integer) text, TUIKitConstants.Group.MODIFY_GROUP_JOIN_TYPE);
                    mJoinTypeView.setContent(mJoinTypes.get((Integer) text));

                }
            });
        } else if (v.getId() == R.id.group_dissolve_button) {
            if (mGroupInfo.isOwner() && !mGroupInfo.getGroupType().equals("Private")) {
                new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle("您确认解散该群?")
                        .setDialogWidth(0.75f)
                        .setPositiveButton("确定", new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mPresenter.deleteGroup();
                            }
                        })
                        .setNegativeButton("取消", new View.OnClickListener() {
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
                        .setTitle("您确认退出该群？")
                        .setDialogWidth(0.75f)
                        .setPositiveButton("确定", new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mPresenter.quitGroup();
                            }
                        })
                        .setNegativeButton("取消", new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
                        })
                        .show();
            }
        }
    }

    public void setGroupId(String groupId) {
        mPresenter.loadGroupInfo(groupId, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
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
        mGroupNameView.setContent(info.getGroupName());
        mGroupIDView.setContent(info.getId());
        mGroupNotice.setContent(info.getNotice());
        mMemberView.setContent(info.getMemberCount() + "人");
        mMemberAdapter.setDataSource(info);
        mGroupTypeView.setContent(convertGroupText(info.getGroupType()));
        mJoinTypeView.setContent(mJoinTypes.get(info.getJoinType()));
        mNickView.setContent(mPresenter.getNickName());
        mTopSwitchView.setChecked(mGroupInfo.isTopChat());

        mDissolveBtn.setText(R.string.dissolve);
        if (mGroupInfo.isOwner()) {
            mGroupNotice.setVisibility(VISIBLE);
            mJoinTypeView.setVisibility(VISIBLE);
            if (mGroupInfo.getGroupType().equals("Private")) {
                mDissolveBtn.setText(R.string.exit_group);
            }
        } else {
            mGroupNotice.setVisibility(GONE);
            mJoinTypeView.setVisibility(GONE);
            mDissolveBtn.setText(R.string.exit_group);
        }
    }

    private String convertGroupText(String groupType) {
        String groupText = "";
        if (TextUtils.isEmpty(groupType)) {
            return groupText;
        }
        if (TextUtils.equals(groupType, TUIKitConstants.GroupType.TYPE_PRIVATE)) {
            groupText = "讨论组";
        } else if (TextUtils.equals(groupType, TUIKitConstants.GroupType.TYPE_PUBLIC)) {
            groupText = "公开群";
        } else if (TextUtils.equals(groupType, TUIKitConstants.GroupType.TYPE_CHAT_ROOM)) {
            groupText = "聊天室";
        }
        return groupText;
    }

    public void onGroupInfoModified(Object value, int type) {
        switch (type) {
            case TUIKitConstants.Group.MODIFY_GROUP_NAME:
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_group_name_success));
                mGroupNameView.setContent(value.toString());
                break;
            case TUIKitConstants.Group.MODIFY_GROUP_NOTICE:
                mGroupNotice.setContent(value.toString());
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_group_notice_success));
                break;
            case TUIKitConstants.Group.MODIFY_GROUP_JOIN_TYPE:
                mJoinTypeView.setContent(mJoinTypes.get((Integer) value));
                break;
            case TUIKitConstants.Group.MODIFY_MEMBER_NAME:
                ToastUtil.toastLongMessage(getResources().getString(R.string.modify_nickname_success));
                mNickView.setContent(value.toString());
                break;
        }
    }

    public void setRouter(IGroupMemberRouter listener) {
        mMemberPreviewListener = listener;
        mMemberAdapter.setManagerCallBack(listener);
    }

    @Override
    public void setDataSource(GroupInfo dataSource) {

    }

    @Override
    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setParentLayout(Object parent) {

    }

}
