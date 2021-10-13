package com.tencent.qcloud.tuikit.tuigroup.ui.view;

import android.content.Context;
import android.graphics.Color;

import androidx.annotation.Nullable;

import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;

import java.util.List;

public class GroupMemberDeleteLayout extends LinearLayout implements IGroupMemberLayout {

    private TitleBarLayout mTitleBar;
    private ListView mMembers;
    private GroupMemberDeleteAdapter mAdapter;
    private List<GroupMemberInfo> mDelMembers;
    private GroupInfo mGroupInfo;

    private GroupInfoPresenter presenter;

    public GroupMemberDeleteLayout(Context context) {
        super(context);
        init();
    }

    public GroupMemberDeleteLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberDeleteLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_del_layout, this);
        mTitleBar = findViewById(R.id.group_member_title_bar);
        mTitleBar.setTitle(getContext().getString(R.string.remove), ITitleBarLayout.Position.RIGHT);
        mTitleBar.setTitle(getContext().getString(R.string.remove_member), TitleBarLayout.Position.MIDDLE);
        mTitleBar.getRightTitle().setTextColor(Color.BLUE);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (presenter == null) {
                    return;
                }
                presenter.removeGroupMembers(mGroupInfo, mDelMembers, new IUIKitCallback<List<String>>() {
                    @Override
                    public void onSuccess(List<String> data) {
                        ToastUtil.toastLongMessage(getContext().getString(R.string.remove_tip_suc));
                        post(new Runnable() {
                            @Override
                            public void run() {
                                mTitleBar.setTitle(getContext().getString(R.string.remove), TitleBarLayout.Position.RIGHT);
                                mAdapter.clear();
                                mAdapter.notifyDataSetChanged();

                            }
                        });
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastLongMessage(getContext().getString(R.string.remove_tip_fail) + errCode + "=" + errMsg);
                    }
                });
            }
        });
        mAdapter = new GroupMemberDeleteAdapter();
        mAdapter.setOnSelectChangedListener(new GroupMemberDeleteAdapter.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(List<GroupMemberInfo> members) {
                mDelMembers = members;
                if (mDelMembers.size() > 0) {
                    mTitleBar.setTitle(getContext().getString(R.string.remove) + "（" + (mDelMembers.size() + "）"), TitleBarLayout.Position.RIGHT);
                } else {
                    mTitleBar.setTitle(getContext().getString(R.string.remove), TitleBarLayout.Position.RIGHT);
                }
            }
        });
        mMembers = findViewById(R.id.group_del_members);
        mMembers.setAdapter(mAdapter);
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setParentLayout(Object parent) {

    }

    @Override
    public void onGroupInfoChanged(GroupInfo groupInfo) {
        mGroupInfo = groupInfo;
        if (presenter != null) {
            presenter.setGroupInfo(groupInfo);
        }
        mAdapter.setDataSource(groupInfo.getMemberDetails());
    }

    @Override
    public void onGroupInfoModified(Object value, int type) {

    }

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
    }

}
