package com.tencent.qcloud.tuikit.tuigroup.classicui.view;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.Nullable;

import android.os.Bundle;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupApplyLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupApplyPresenter;

import java.util.HashMap;
import java.util.List;


public class GroupApplyManagerLayout extends LinearLayout implements IGroupApplyLayout {

    private TitleBarLayout mTitleBar;
    private ListView mApplyMemberList;
    private GroupApplyAdapter mAdapter;

    private GroupApplyPresenter presenter;
    public GroupApplyManagerLayout(Context context) {
        super(context);
        init();
    }

    public GroupApplyManagerLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupApplyManagerLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_apply_manager_layout, this);
        mApplyMemberList = findViewById(R.id.group_apply_members);
        mAdapter = new GroupApplyAdapter();
        mAdapter.setOnItemClickListener(new GroupApplyAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(GroupApplyInfo info) {
                Bundle bundle = new Bundle();
                bundle.putString("fromUser", info.getFromUser());
                bundle.putString("fromUserNickName", info.getFromUserNickName());
                bundle.putString("requestMsg", info.getRequestMsg());
                bundle.putSerializable("groupApplication", info.getGroupApplication());
                TUICore.startActivity(getContext(),"FriendProfileActivity", bundle, TUIGroupConstants.ActivityRequest.CODE_1);
            }
        });
        mApplyMemberList.setAdapter(mAdapter);
        mTitleBar = findViewById(R.id.group_apply_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_apply_members), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    public void updateItemData(GroupApplyInfo info) {
        mAdapter.updateItemData(info);
    }

    public void onDataSetChanged() {
        mAdapter.notifyDataSetChanged();

        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.IS_GROUP_CHAT, true);
        param.put(TUIConstants.TUIChat.GROUP_APPLY_NUM, mAdapter.getCount()-1);
        TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_GROUP_APPLICAITON_PROCESSED, param);
    }

    public void setPresenter(GroupApplyPresenter groupApplyPresenter) {
        this.presenter = groupApplyPresenter;
        mAdapter.setPresenter(groupApplyPresenter);
    }

    public void onGroupApplyInfoListChanged(List<GroupApplyInfo> applyInfoList) {
        mAdapter.setDataSource(applyInfoList);
    }

    public void setDataSource(GroupInfo dataSource) {
        presenter.setGroupInfo(dataSource);
        mAdapter.setDataSource(dataSource);
    }
}
