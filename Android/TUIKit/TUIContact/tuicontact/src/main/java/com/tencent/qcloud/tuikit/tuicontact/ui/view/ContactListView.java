package com.tencent.qcloud.tuikit.tuicontact.ui.view;

import android.content.Context;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;


import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuicore.component.indexlib.IndexBar.widget.IndexBar;
import com.tencent.qcloud.tuicore.component.indexlib.suspension.SuspensionDecoration;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.ui.interfaces.IContactListView;

import java.util.ArrayList;
import java.util.List;


public class ContactListView extends LinearLayout implements IContactListView {

    private static final String TAG = ContactListView.class.getSimpleName();

    private static final String INDEX_STRING_TOP = "↑";
    private RecyclerView mRv;
    private ContactAdapter mAdapter;
    private CustomLinearLayoutManager mManager;
    private List<ContactItemBean> mData = new ArrayList<>();
    private SuspensionDecoration mDecoration;
    private ProgressBar mContactLoadingBar;
    private String groupId;

    /**
     * 右侧边栏导航区域
     */
    private IndexBar mIndexBar;

    /**
     * 显示指示器DialogText
     */
    private TextView mTvSideBarHint;

    private ContactPresenter presenter;

    private int dataSourceType = DataSource.UNKNOWN;

    public ContactListView(Context context) {
        super(context);
        init();
    }

    public ContactListView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ContactListView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(ContactPresenter presenter) {
        this.presenter = presenter;
        if (mAdapter != null) {
            mAdapter.setPresenter(presenter);
        }
    }

    private void init() {
        inflate(getContext(), R.layout.contact_list, this);
        mRv = findViewById(R.id.contact_member_list);
        mManager = new CustomLinearLayoutManager(getContext());
        mRv.setLayoutManager(mManager);

        mAdapter = new ContactAdapter(mData);
        mRv.setAdapter(mAdapter);
        mRv.addItemDecoration(mDecoration = new SuspensionDecoration(getContext(), mData));
        mRv.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
                int lastCompletelyVisibleItemPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                //TUILiveLog.i(TAG, "lastCompletelyVisibleItemPosition: "+lastCompletelyVisibleItemPosition);
                if(lastCompletelyVisibleItemPosition==layoutManager.getItemCount()-1) {
                    if (presenter.getNextSeq() > 0) {
                        presenter.loadGroupMemberList(groupId);
                    }
                }
            }
        });
        mTvSideBarHint = findViewById(R.id.contact_tvSideBarHint);
        mIndexBar = findViewById(R.id.contact_indexBar);
        mIndexBar.setPressedShowTextView(mTvSideBarHint)
                .setNeedRealIndex(false)
                .setLayoutManager(mManager);
        mContactLoadingBar = findViewById(R.id.contact_loading_bar);
    }

    public ContactAdapter getAdapter() {
        return mAdapter;
    }

    @Override
    public void onDataSourceChanged(List<ContactItemBean> data) {
        mContactLoadingBar.setVisibility(GONE);
        this.mData = data;
        mAdapter.setDataSource(mData);
        mIndexBar.setSourceDatas(mData).invalidate();
        mDecoration.setDatas(mData);
    }

    @Override
    public void onFriendApplicationChanged() {
        if (dataSourceType == DataSource.CONTACT_LIST) {
            mAdapter.notifyItemChanged(0);
        }
    }

    public void setSingleSelectMode(boolean mode) {
        mAdapter.setSingleSelectMode(mode);
    }

    public void setOnSelectChangeListener(OnSelectChangedListener selectChangeListener) {
        mAdapter.setOnSelectChangedListener(selectChangeListener);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mAdapter.setOnItemClickListener(listener);
    }

    public void loadDataSource(int dataSource) {
        this.dataSourceType = dataSource;
        if (presenter == null) {
            return;
        }
        mContactLoadingBar.setVisibility(VISIBLE);
        if (dataSource == ContactListView.DataSource.GROUP_MEMBER_LIST) {
            presenter.loadGroupMemberList(groupId);
        } else {
            presenter.loadDataSource(dataSource);
        }
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public interface OnSelectChangedListener {
        void onSelectChanged(ContactItemBean contact, boolean selected);
    }

    public interface OnItemClickListener {
        void onItemClick(int position, ContactItemBean contact);
    }

    public static class DataSource {
        public static final int UNKNOWN = -1;
        public static final int FRIEND_LIST = 1;
        public static final int BLACK_LIST = 2;
        public static final int GROUP_LIST = 3;
        public static final int CONTACT_LIST = 4;
        public static final int GROUP_MEMBER_LIST = 5;
    }
}
