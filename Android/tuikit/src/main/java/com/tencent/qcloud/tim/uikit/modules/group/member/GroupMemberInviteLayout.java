package com.tencent.qcloud.tim.uikit.modules.group.member;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseFragment;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactItemBean;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactListView;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoProvider;
import com.tencent.qcloud.tim.uikit.modules.group.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class GroupMemberInviteLayout extends LinearLayout implements IGroupMemberLayout {

    private static final String TAG = GroupMemberInviteLayout.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private List<String> mInviteMembers = new ArrayList<>();
    private Object mParentLayout;
    private GroupInfo mGroupInfo;

    public GroupMemberInviteLayout(Context context) {
        super(context);
        init();
    }

    public GroupMemberInviteLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberInviteLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_invite_layout, this);
        mTitleBar = findViewById(R.id.group_invite_title_bar);
        mTitleBar.setTitle("确定", TitleBarLayout.POSITION.RIGHT);
        mTitleBar.setTitle("添加成员", TitleBarLayout.POSITION.MIDDLE);
        mTitleBar.getRightTitle().setTextColor(Color.BLUE);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                GroupInfoProvider provider = new GroupInfoProvider();
                provider.loadGroupInfo(mGroupInfo);
                provider.inviteGroupMembers(mInviteMembers, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        if (data instanceof String) {
                            ToastUtil.toastLongMessage(data.toString());
                        } else {
                            ToastUtil.toastLongMessage("邀请成员成功");
                        }
                        mInviteMembers.clear();
                        finish();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastLongMessage("邀请成员失败:" + errCode + "=" + errMsg);
                    }
                });
            }
        });
        mContactListView = findViewById(R.id.group_invite_member_list);
        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    mInviteMembers.add(contact.getId());
                } else {
                    mInviteMembers.remove(contact.getId());
                }
                if (mInviteMembers.size() > 0) {
                    mTitleBar.setTitle("确定（" + mInviteMembers.size() + "）", TitleBarLayout.POSITION.RIGHT);
                } else {
                    mTitleBar.setTitle("确定", TitleBarLayout.POSITION.RIGHT);
                }
            }
        });
    }

    public void setDataSource(GroupInfo groupInfo) {
        mGroupInfo = groupInfo;
        if (mContactListView != null) {
            mContactListView.setGroupInfo(mGroupInfo);
        }
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setParentLayout(Object parent) {
        mParentLayout = parent;
    }

    private void finish() {
        if (mParentLayout instanceof Activity) {
            ((Activity) mParentLayout).finish();
        } else if (mParentLayout instanceof BaseFragment) {
            ((BaseFragment) mParentLayout).backward();
        }
    }

}
