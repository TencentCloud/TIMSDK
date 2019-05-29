package com.tencent.qcloud.uikit.business.contact.view.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;
import com.tencent.qcloud.uikit.business.contact.view.ContactList;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

import java.util.ArrayList;
import java.util.List;


public class StartGroupChatFragment extends BaseFragment {

    private View mBaseView;
    private ContactList mContactList;
    private PageTitleBar mTitleBar;
    private EditText mSearch;
    private List<ContactInfoBean> mDatas = new ArrayList();
    private List<ContactInfoBean> mSelectedContacts = new ArrayList<>();


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.contact_fragment_start_group_chat, container, false);
        mTitleBar = mBaseView.findViewById(R.id.start_group_title_bar);
        mContactList = mBaseView.findViewById(R.id.start_group_contact_list);
        mContactList.setSelectChangeListener(new ContactList.ContactSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactInfoBean contact, boolean selected) {
                if (selected) {
                    mSelectedContacts.add(contact);
                } else {
                    mSelectedContacts.remove(contact);
                }
                if (mSelectedContacts.size() == 0) {
                    mTitleBar.setTitle("确定", PageTitleBar.POSITION.RIGHT);
                    return;
                }
                mTitleBar.setTitle("确定" + (mSelectedContacts.size()), PageTitleBar.POSITION.RIGHT);
            }
        });

        mSearch = mBaseView.findViewById(R.id.start_group_contact_search);

        mTitleBar.setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                backward();
            }
        });
        mTitleBar.setTitle("发起群聊", PageTitleBar.POSITION.CENTER);
        mTitleBar.setTitle("确定", PageTitleBar.POSITION.RIGHT);
        mTitleBar.setRightClick(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                backward();
            }
        });

        initDatas();
        return mBaseView;
    }

    private void initDatas() {
        String data[] = getResources().getStringArray(R.array.provinces);
        mDatas = new ArrayList<>();
        ContactInfoBean bean = new ContactInfoBean("面对面建群");
        bean.setTop(true).setBaseIndexTag(ContactInfoBean.INDEX_STRING_TOP);
        mDatas.add(bean);
        for (int i = 0; i < data.length; i++) {
            ContactInfoBean cityBean = new ContactInfoBean();
            cityBean.setIdentifier(data[i]);//设置城市名称
            mDatas.add(cityBean);
        }
        mContactList.setDatas(mDatas);

    }
}
