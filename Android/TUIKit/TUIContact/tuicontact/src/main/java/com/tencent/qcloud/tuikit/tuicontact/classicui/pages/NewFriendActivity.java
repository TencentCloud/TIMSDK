package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.classicui.widget.NewFriendListAdapter;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.INewFriendActivity;
import com.tencent.qcloud.tuikit.tuicontact.presenter.NewFriendPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.List;

public class NewFriendActivity extends BaseLightActivity implements INewFriendActivity {

    private static final String TAG = NewFriendActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ListView mNewFriendLv;
    private NewFriendListAdapter mAdapter;
    private TextView notFoundTip;

    private NewFriendPresenter presenter;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_new_friend_activity);
        init();
    }

    @Override
    protected void onResume() {
        super.onResume();
        initPendency();
    }

    private void init() {
        mTitleBar = findViewById(R.id.new_friend_titlebar);
        mTitleBar.setTitle(getResources().getString(R.string.new_friend), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        presenter = new NewFriendPresenter();
        presenter.setFriendActivity(this);
        presenter.setFriendApplicationListAllRead(new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
        mNewFriendLv = findViewById(R.id.new_friend_list);
        notFoundTip = findViewById(R.id.not_found_tip);
    }

    private void initPendency() {
        presenter.loadFriendApplicationList();
    }

    @Override
    public void onDataSourceChanged(List<FriendApplicationBean> dataSource) {
        TUIContactLog.i(TAG, "getFriendApplicationList success");
        if (dataSource == null || dataSource.isEmpty()) {
            notFoundTip.setVisibility(View.VISIBLE);
        } else {
            notFoundTip.setVisibility(View.GONE);
        }
        mNewFriendLv.setVisibility(View.VISIBLE);
        mAdapter = new NewFriendListAdapter(NewFriendActivity.this, R.layout.contact_new_friend_item, dataSource);
        mAdapter.setPresenter(presenter);
        mNewFriendLv.setAdapter(mAdapter);
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void finish() {
        super.finish();
    }

}
