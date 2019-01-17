package com.tencent.qcloud.uikit.business.chat.group.view;

import android.content.Context;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupMemberInfo;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMemberDelAdapter;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.util.List;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class GroupMemberDelPanel extends LinearLayout implements GroupMemberDelAdapter.GroupMemberDelSelectCallback {
    private PageTitleBar mTitleBar;
    private ListView mMembers;
    private SearchView mMemberSearch;
    private GroupMemberDelAdapter mAdapter;
    private List<GroupMemberInfo> mDelMembers;

    public GroupMemberDelPanel(Context context) {
        super(context);
        init();
    }

    public GroupMemberDelPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberDelPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setGroupMembers(List<GroupMemberInfo> mMembers) {
        mAdapter.setDataSource(mMembers);
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_del_panel, this);
        mTitleBar = findViewById(R.id.group_member_title_bar);
        mTitleBar.setTitle("移除", PageTitleBar.POSITION.RIGHT);
        mTitleBar.setTitle("移除成员", PageTitleBar.POSITION.CENTER);
        mTitleBar.getRightTitle().setTextColor(Color.BLUE);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setRightClick(new OnClickListener() {
            @Override
            public void onClick(View v) {
                GroupChatManager.getInstance().removeGroupMembers(mDelMembers, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        UIUtils.toastLongMessage("删除成员成功");
                        post(new Runnable() {
                            @Override
                            public void run() {
                                mTitleBar.setTitle("移除", PageTitleBar.POSITION.RIGHT);
                                mAdapter.clear();
                                mAdapter.notifyDataSetChanged();

                            }
                        });

                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        UIUtils.toastLongMessage("删除成员失败:" + errCode + "=" + errMsg);
                    }
                });
            }
        });
        mMembers = findViewById(R.id.group_del_members);
        mMemberSearch = findViewById(R.id.group_member_search);
        mAdapter = new GroupMemberDelAdapter(this);
        mMembers.setAdapter(mAdapter);
        setGroupMembers(GroupChatManager.getInstance().getCurrentGroupMembers());
        int id = mMemberSearch.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        TextView textView = (TextView) mMemberSearch.findViewById(id);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
    }

    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }


    public void setMembers(List<GroupMemberInfo> members) {
        mAdapter.setDataSource(members);
    }


    @Override
    public void onDelSelectChanged(List<GroupMemberInfo> delMembers) {
        mDelMembers = delMembers;
        if (mDelMembers.size() > 0)
            mTitleBar.setTitle("移除（" + (mDelMembers.size() + "）"), PageTitleBar.POSITION.RIGHT);
        else
            mTitleBar.setTitle("移除", PageTitleBar.POSITION.RIGHT);
    }
}
