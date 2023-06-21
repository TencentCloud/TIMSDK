package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.widget.IndexBar;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.suspension.SuspensionDecoration;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IContactListView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import java.util.ArrayList;
import java.util.List;

public class ContactListView extends LinearLayout implements IContactListView {
    private static final String TAG = ContactListView.class.getSimpleName();

    private RecyclerView mRv;
    private ContactAdapter mAdapter;
    private CustomLinearLayoutManager mManager;
    private List<ContactItemBean> mData = new ArrayList<>();
    private SuspensionDecoration mDecoration;
    private ProgressBar mContactLoadingBar;
    private String groupId;
    private boolean isGroupList = false;

    private TextView notFoundTip;
    /**
     * 右侧边栏导航区域
     */
    private IndexBar mIndexBar;

    private TextView mTvSideBarHint;

    private ContactPresenter presenter;

    private int dataSourceType = DataSource.UNKNOWN;
    private ArrayList<String> alreadySelectedList;

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
            mAdapter.setIsGroupList(isGroupList);
        }
    }

    public void setIsGroupList(boolean isGroupList) {
        this.isGroupList = isGroupList;
    }

    public void setAlreadySelectedList(ArrayList<String> alreadySelectedList) {
        this.alreadySelectedList = alreadySelectedList;
        mAdapter.setAlreadySelectedList(alreadySelectedList);
    }

    private void init() {
        inflate(getContext(), R.layout.minimalist_contact_list, this);
        mRv = findViewById(R.id.contact_member_list);
        notFoundTip = findViewById(R.id.not_found_tip);
        mManager = new CustomLinearLayoutManager(getContext());
        mRv.setLayoutManager(mManager);

        mAdapter = new ContactAdapter(mData);
        mRv.setAdapter(mAdapter);
        mDecoration = new SuspensionDecoration(getContext(), mData);
        mDecoration.setColorTitleBg(Color.WHITE);
        mDecoration.setColorTitleFont(Color.BLACK);
        mDecoration.setTitleHeight(ScreenUtil.dip2px(44));
        mDecoration.setShowLine(false);
        mRv.addItemDecoration(mDecoration);
        mRv.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
                int lastCompletelyVisibleItemPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                if (lastCompletelyVisibleItemPosition == layoutManager.getItemCount() - 1) {
                    if (presenter.getNextSeq() > 0) {
                        presenter.loadGroupMemberList(groupId);
                    }
                }
            }
        });
        mTvSideBarHint = findViewById(R.id.contact_tvSideBarHint);
        mIndexBar = findViewById(R.id.contact_indexBar);
        mIndexBar.setPressedShowTextView(mTvSideBarHint).setNeedRealIndex(false).setLayoutManager(mManager);
        mContactLoadingBar = findViewById(R.id.contact_loading_bar);
    }

    public ContactAdapter getAdapter() {
        return mAdapter;
    }

    public void setNotFoundTip(String text) {
        notFoundTip.setText(text);
    }

    @Override
    public void onDataSourceChanged(List<ContactItemBean> data) {
        if (data == null || data.isEmpty()) {
            if (!TextUtils.isEmpty(notFoundTip.getText())) {
                notFoundTip.setVisibility(VISIBLE);
            }
        } else {
            notFoundTip.setVisibility(GONE);
        }
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
        if (mAdapter != null) {
            mAdapter.setDataSourceType(dataSource);
        }
        mContactLoadingBar.setVisibility(VISIBLE);
        if (dataSource == DataSource.GROUP_MEMBER_LIST) {
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
}
