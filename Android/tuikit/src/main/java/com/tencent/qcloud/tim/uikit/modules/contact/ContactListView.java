package com.tencent.qcloud.tim.uikit.modules.contact;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.LinearLayout;
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
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
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
    private TextView mContactCountTv;
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
        //如果add两个，那么按照先后顺序，依次渲染。
        //使用indexBar
        mTvSideBarHint = findViewById(R.id.contact_tvSideBarHint);
        mIndexBar = findViewById(R.id.contact_indexBar);
        //indexbar初始化
        mIndexBar.setPressedShowTextView(mTvSideBarHint)
                .setNeedRealIndex(true)
                .setLayoutManager(mManager);
        mContactCountTv = findViewById(R.id.contact_count);
        mContactCountTv.setText(String.format(getResources().getString(R.string.contact_count), 0));
    }

    public ContactAdapter getAdapter() {
        return mAdapter;
    }

    public void setDataSource(List<ContactItemBean> data) {
        this.mData = data;
        mAdapter.setDataSource(mData);
        mIndexBar.setSourceDatas(mData).invalidate();
        mDecoration.setDatas(mData);
        mContactCountTv.setText(String.format(getResources().getString(R.string.contact_count), mData.size()));
        // 根据内容动态设置右侧导航栏的高度
        ViewGroup.LayoutParams params = mIndexBar.getLayoutParams();
        if (mData.size() * 50 < mIndexBar.getMeasuredHeight()) { // 若动态设置的侧边栏高度大于之前的旧值，则不改变侧边栏高度
            params.height = mData.size() * 50;
        }
        mIndexBar.setLayoutParams(params);
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

    public void loadDataSource(int dataSource) {
        switch (dataSource) {
            case DataSource.FRIEND_LIST:
                loadFriendListData(false);
                break;
            case DataSource.BLACK_LIST:
                loadBlackListData();
                break;
            case DataSource.GROUP_LIST:
                loadGroupListData();
                break;
            case DataSource.CONTACT_LIST:
                loadFriendListData(true);
                break;
        }
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
            mAdapter.notifyDataSetChanged();
        }
    }

    private void loadFriendListData(final boolean loopMore) {
        TIMFriendshipManager.getInstance().getFriendList(new TIMValueCallBack<List<TIMFriend>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "getFriendList err code = " + code);
            }

            @Override
            public void onSuccess(List<TIMFriend> timFriends) {
                TUIKitLog.i(TAG, "getFriendList success result = " + timFriends.size());
                if (timFriends.size() == 0) {
                    TUIKitLog.i(TAG, "getFriendList success but no data");
                }
                mData.clear();
                if (loopMore) {
                    mData.add((ContactItemBean) new ContactItemBean(getResources().getString(R.string.new_friend))
                            .setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                    mData.add((ContactItemBean) new ContactItemBean(getResources().getString(R.string.group)).
                            setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                    mData.add((ContactItemBean) new ContactItemBean(getResources().getString(R.string.blacklist)).
                            setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                }
                for (TIMFriend timFriend : timFriends) {
                    ContactItemBean info = new ContactItemBean();
                    info.covertTIMFriend(timFriend);
                    mData.add(info);
                }
                updateStatus(mData);
                setDataSource(mData);
            }
        });
    }

    private void loadBlackListData() {
        TIMFriendshipManager.getInstance().getBlackList(new TIMValueCallBack<List<TIMFriend>>() {
            @Override
            public void onError(int i, String s) {
                TUIKitLog.e(TAG, "getBlackList err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
            }

            @Override
            public void onSuccess(List<TIMFriend> timFriends) {
                TUIKitLog.i(TAG, "getFriendGroups success");
                if (timFriends.size() == 0) {
                    TUIKitLog.i(TAG, "getFriendGroups success but no data");
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
        TIMGroupManager.getInstance().getGroupList(new TIMValueCallBack<List<TIMGroupBaseInfo>>() {

            @Override
            public void onError(int i, String s) {
                TUIKitLog.e(TAG, "getGroupList err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
            }

            @Override
            public void onSuccess(List<TIMGroupBaseInfo> infos) {
                TUIKitLog.i(TAG, "getFriendGroups success");
                if (infos.size() == 0) {
                    TUIKitLog.i(TAG, "getFriendGroups success but no data");
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
}
