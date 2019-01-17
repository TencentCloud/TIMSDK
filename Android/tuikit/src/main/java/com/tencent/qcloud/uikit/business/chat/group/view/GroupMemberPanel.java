package com.tencent.qcloud.uikit.business.chat.group.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.widget.Button;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.SearchView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.infos.IGroupMemberPanel;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupMemberInfo;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMemberCallback;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMembersAdapter;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;

import java.util.List;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class GroupMemberPanel extends LinearLayout implements IGroupMemberPanel {
    private PageTitleBar mTitleBar;
    private GridView mMemberGrid;
    private SearchView mMemberSearch;
    private GroupMembersAdapter mAdapter;
    private AlertDialog mDialog;
    private Button mAddMemberBtn, mDelMemberBtn, mCancelBtn;
    private GroupMemberPanelEvent mEvent;

    public GroupMemberPanel(Context context) {
        super(context);
        init();
    }

    public GroupMemberPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_panel, this);
        mTitleBar = findViewById(R.id.group_member_title_bar);
        mTitleBar.setTitle("管理", PageTitleBar.POSITION.RIGHT);
        mTitleBar.getRightIcon().setVisibility(GONE);
        mTitleBar.setLeftClick(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mEvent != null)
                    mEvent.backBtnClick();
            }
        });
        mTitleBar.setRightClick(new OnClickListener() {
            @Override
            public void onClick(View v) {
                buildPopMenu();
            }
        });
        mMemberGrid = findViewById(R.id.group_all_members);

        mMemberSearch = findViewById(R.id.group_member_search);
        mAdapter = new GroupMembersAdapter();
        mMemberGrid.setAdapter(mAdapter);
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

    private void buildPopMenu() {
        if (mDialog == null) {
            mDialog = PopWindowUtil.buildFullScreenDialog((Activity) getContext());
            View moreActionView = inflate(getContext(), R.layout.group_member_pop_menu, null);
            moreActionView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mAddMemberBtn = moreActionView.findViewById(R.id.add_group_member);
            mAddMemberBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mEvent != null)
                        mEvent.addMemberBtnClick();
                    mDialog.dismiss();

                }
            });
            mDelMemberBtn = moreActionView.findViewById(R.id.remove_group_member);
            if (!GroupChatManager.getInstance().getCurrentChatInfo().isOwner())
                mDelMemberBtn.setVisibility(View.GONE);
            mDelMemberBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mEvent != null)
                        mEvent.delMemberBtnClick();
                    mDialog.dismiss();
                }
            });
            mCancelBtn = moreActionView.findViewById(R.id.cancel);
            mCancelBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mDialog.setContentView(moreActionView);
        } else {
            mDialog.show();
        }

    }

    @Override
    public void initDefault() {

    }

    @Override
    public void setGroupMemberCallback(GroupMemberCallback callback) {
        mAdapter.setMemberCallback(callback);
    }

    public void setMemberPanelEvent(GroupMemberPanelEvent event) {
        this.mEvent = event;
    }

    public interface GroupMemberPanelEvent {
        public void backBtnClick();

        public void addMemberBtnClick();

        public void delMemberBtnClick();
    }

}
