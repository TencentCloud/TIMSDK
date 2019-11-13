package com.tencent.qcloud.tim.uikit.modules.contact;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.group.TIMGroupBaseInfo;
import com.tencent.imsdk.friendship.TIMFriend;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tim.uikit.component.indexlib.IndexBar.widget.IndexBar;
import com.tencent.qcloud.tim.uikit.component.indexlib.suspension.SuspensionDecoration;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ThreadHelper;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;


public class ContactListView extends LinearLayout {

    private static final String TAG = ContactListView.class.getSimpleName();

    private static final String INDEX_STRING_TOP = "↑";
    private RecyclerView mRv;
    private ContactAdapter mAdapter;
    private CustomLinearLayoutManager mManager;
    private List<ContactItemBean> mData = new ArrayList<>();
    private SuspensionDecoration mDecoration;
    private ProgressBar mContactLoadingBar;
    private GroupInfo mGroupInfo;

    /**
     * 右侧边栏导航区域
     */
    private IndexBar mIndexBar;

    /**
     * 显示指示器DialogText
     */
    private TextView mTvSideBarHint;

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

    private void init() {
        inflate(getContext(), R.layout.contact_list, this);
        mRv = findViewById(R.id.contact_member_list);
        mManager = new CustomLinearLayoutManager(getContext());
        mRv.setLayoutManager(mManager);

        mAdapter = new ContactAdapter(mData);
        mRv.setAdapter(mAdapter);
        mRv.addItemDecoration(mDecoration = new SuspensionDecoration(getContext(), mData));
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

    public void setDataSource(List<ContactItemBean> data) {
        mContactLoadingBar.setVisibility(GONE);
        this.mData = data;
        mAdapter.setDataSource(mData);
        mIndexBar.setSourceDatas(mData).invalidate();
        mDecoration.setDatas(mData);
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
        mContactLoadingBar.setVisibility(VISIBLE);
        mData.clear();
        switch (dataSource) {
            case DataSource.FRIEND_LIST:
                loadFriendListDataAsync();
                break;
            case DataSource.BLACK_LIST:
                loadBlackListData();
                break;
            case DataSource.GROUP_LIST:
                loadGroupListData();
                break;
            case DataSource.CONTACT_LIST:
                mData.add((ContactItemBean) new ContactItemBean(getResources().getString(R.string.new_friend))
                        .setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                mData.add((ContactItemBean) new ContactItemBean(getResources().getString(R.string.group)).
                        setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                mData.add((ContactItemBean) new ContactItemBean(getResources().getString(R.string.blacklist)).
                        setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                loadFriendListDataAsync();
                break;
            default:
                break;
        }
        mAdapter.notifyDataSetChanged();
    }

    public void setGroupInfo(GroupInfo groupInfo) {
        mGroupInfo = groupInfo;
    }

    private void updateStatus(List<ContactItemBean> beanList) {
        if (mGroupInfo == null) {
            return;
        }
        List<GroupMemberInfo> list = mGroupInfo.getMemberDetails();
        boolean needFresh = false;
        if (list.size() > 0) {
            for (GroupMemberInfo info : list) {
                for (ContactItemBean bean : beanList) {
                    if (info.getAccount().equals(bean.getId())) {
                        bean.setSelected(true);
                        bean.setEnable(false);
                        needFresh = true;
                    }
                }
            }
        }
        if (needFresh) {
            BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mAdapter.notifyDataSetChanged();
                }
            });
        }
    }

    private void loadFriendListDataAsync() {
        TUIKitLog.i(TAG, "loadFriendListDataAsync");
        ThreadHelper.INST.execute(new Runnable() {
            @Override
            public void run() {
                // 压测时数据量比较大，query耗时比较久，所以这里使用新线程来处理
                TUIKitLog.i(TAG, "queryFriendList");
                List<TIMFriend> timFriends = TIMFriendshipManager.getInstance().queryFriendList();
                if (timFriends == null) {
                    timFriends = new ArrayList<>();
                }
                TUIKitLog.i(TAG, "queryFriendList: " + timFriends.size());
                fillFriendListData(timFriends);
            }
        });
    }

    private void fillFriendListData(final List<TIMFriend> timFriends) {
        // 外部调用是在其他线程里面，但是更新数据同时会刷新UI，所以需要放在主线程做。
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (timFriends.size() == 0) {
                    TIMFriendshipManager.getInstance().getFriendList(new TIMValueCallBack<List<TIMFriend>>() {
                        @Override
                        public void onError(int code, String desc) {
                            TUIKitLog.e(TAG, "getFriendList err code = " + code);
                            mContactLoadingBar.setVisibility(GONE);
                        }

                        @Override
                        public void onSuccess(List<TIMFriend> timFriends) {
                            if (timFriends == null) {
                                timFriends = new ArrayList<>();
                            }
                            TUIKitLog.i(TAG, "getFriendList success result = " + timFriends.size());
                            assembleFriendListData(timFriends);
                        }
                    });
                } else {
                    assembleFriendListData(timFriends);
                }
            }
        });
    }

    private void assembleFriendListData(final List<TIMFriend> timFriends) {
        for (TIMFriend timFriend : timFriends) {
            ContactItemBean info = new ContactItemBean();
            info.covertTIMFriend(timFriend);
            mData.add(info);
        }
        updateStatus(mData);
        setDataSource(mData);
    }

    private void loadBlackListData() {
        TUIKitLog.i(TAG, "loadBlackListData");
        TIMFriendshipManager.getInstance().getBlackList(new TIMValueCallBack<List<TIMFriend>>() {
            @Override
            public void onError(int i, String s) {
                TUIKitLog.e(TAG, "getBlackList err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
                mContactLoadingBar.setVisibility(GONE);
            }

            @Override
            public void onSuccess(List<TIMFriend> timFriends) {
                TUIKitLog.i(TAG, "getBlackList success: " + timFriends.size());
                if (timFriends.size() == 0) {
                    TUIKitLog.i(TAG, "getBlackList success but no data");
                }
                mData.clear();
                for (TIMFriend timFriend : timFriends) {
                    ContactItemBean info = new ContactItemBean();
                    info.covertTIMFriend(timFriend).setBlackList(true);
                    mData.add(info);
                }
                setDataSource(mData);
            }
        });
    }

    private void loadGroupListData() {
        TUIKitLog.i(TAG, "loadGroupListData");
        TIMGroupManager.getInstance().getGroupList(new TIMValueCallBack<List<TIMGroupBaseInfo>>() {

            @Override
            public void onError(int i, String s) {
                TUIKitLog.e(TAG, "getGroupList err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
                mContactLoadingBar.setVisibility(GONE);
            }

            @Override
            public void onSuccess(List<TIMGroupBaseInfo> infos) {
                TUIKitLog.i(TAG, "getGroupList success: " + infos.size());
                if (infos.size() == 0) {
                    TUIKitLog.i(TAG, "getGroupList success but no data");
                }
                mData.clear();
                for (TIMGroupBaseInfo info : infos) {
                    ContactItemBean bean = new ContactItemBean();
                    mData.add(bean.covertTIMGroupBaseInfo(info));
                }
                setDataSource(mData);
            }
        });
    }

    public List<ContactItemBean> getGroupData() {
        return mData;
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
    }
}
