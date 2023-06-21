package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;

import java.util.List;

public interface IContactListView {
    class DataSource {
        public static final int UNKNOWN = -1;
        public static final int FRIEND_LIST = 1;
        public static final int BLACK_LIST = 2;
        public static final int GROUP_LIST = 3;
        public static final int CONTACT_LIST = 4;
        public static final int GROUP_MEMBER_LIST = 5;
    }

    void onDataSourceChanged(List<ContactItemBean> contactItemBeanList);

    void onFriendApplicationChanged();
}
