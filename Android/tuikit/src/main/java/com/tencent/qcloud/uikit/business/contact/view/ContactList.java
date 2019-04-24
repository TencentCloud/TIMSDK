package com.tencent.qcloud.uikit.business.contact.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;
import com.tencent.qcloud.uikit.business.contact.view.adapter.ContactAdapter;
import com.tencent.qcloud.uikit.business.contact.view.widget.IndexBar.widget.IndexBar;
import com.tencent.qcloud.uikit.business.contact.view.widget.suspension.SuspensionDecoration;

import java.util.ArrayList;
import java.util.List;


public class ContactList extends LinearLayout {

    private static final String INDEX_STRING_TOP = "↑";
    private RecyclerView mRv;
    private ContactAdapter mAdapter;
    private LinearLayoutManager mManager;
    private List<ContactInfoBean> mDatas = new ArrayList<>();
    private SuspensionDecoration mDecoration;

    /**
     * 右侧边栏导航区域
     */
    private IndexBar mIndexBar;

    /**
     * 显示指示器DialogText
     */
    private TextView mTvSideBarHint;

    public ContactList(Context context) {
        super(context);
        init();
    }

    public ContactList(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ContactList(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.contact_list, this);
        mRv = (RecyclerView) findViewById(R.id.contact_member_list);
        mRv.setLayoutManager(mManager = new LinearLayoutManager(getContext()));

        mAdapter = new ContactAdapter(mDatas);
        mRv.setAdapter(mAdapter);
        mRv.addItemDecoration(mDecoration = new SuspensionDecoration(getContext(), mDatas));
        //如果add两个，那么按照先后顺序，依次渲染。
        mRv.addItemDecoration(new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL));
        //使用indexBar
        mTvSideBarHint = (TextView) findViewById(R.id.contact_tvSideBarHint);//HintTextView
        mIndexBar = (IndexBar) findViewById(R.id.contact_indexBar);//IndexBar
        //indexbar初始化
        mIndexBar.setmPressedShowTextView(mTvSideBarHint)//设置HintTextView
                .setNeedRealIndex(true)//设置需要真实的索引
                .setmLayoutManager(mManager);//设置RecyclerView的LayoutManager

    }

    public ContactAdapter getAdapter() {
        return mAdapter;
    }

    public void setDatas(List<ContactInfoBean> datas) {
        this.mDatas = datas;
        mAdapter.setDataSource(mDatas);
        mIndexBar.setmSourceDatas(mDatas)//设置数据
                .invalidate();
        mDecoration.setmDatas(mDatas);
    }


    public void setSelectChangeListener(ContactSelectChangedListener selectChangeListener) {
        mAdapter.setContactSelectListener(selectChangeListener);
    }

    public interface ContactSelectChangedListener {
        void onSelectChanged(ContactInfoBean contact, boolean selected);
    }
}
