package com.tencent.qcloud.tuikit.tuicontact.ui.interfaces;


import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;

import java.util.List;

public interface IContactListView {
    void onDataSourceChanged(List<ContactItemBean> contactItemBeanList);
    void onFriendApplicationChanged();
}
