package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;

public class BlackListMinimalistActivity extends BaseMinimalistLightActivity {
    private TitleBarLayout mTitleBar;
    private ContactListView mListView;

    private ContactPresenter presenter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.minimalist_contact_blacklist_activity);

        init();
    }

    private void init() {
        mTitleBar = findViewById(R.id.black_list_titlebar);
        mTitleBar.setTitle(getResources().getString(R.string.blacklist), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mTitleBar.getRightGroup().setVisibility(View.GONE);

        mListView = findViewById(R.id.black_list);
        mListView.setOnItemClickListener(new ContactListView.OnItemClickListener() {
            @Override
            public void onItemClick(int position, ContactItemBean contact) {
                Intent intent = new Intent(BlackListMinimalistActivity.this, FriendProfileMinimalistActivity.class);
                intent.putExtra(TUIContactConstants.ProfileType.CONTENT, contact);
                startActivity(intent);
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadDataSource();
    }

    public void loadDataSource() {
        presenter = new ContactPresenter();
        mListView.setPresenter(presenter);
        mListView.setNotFoundTip(getString(R.string.contact_no_block_list));
        presenter.setContactListView(mListView);
        presenter.setBlackListListener();
        mListView.loadDataSource(ContactListView.DataSource.BLACK_LIST);
    }

    @Override
    public void finish() {
        super.finish();
    }
}
