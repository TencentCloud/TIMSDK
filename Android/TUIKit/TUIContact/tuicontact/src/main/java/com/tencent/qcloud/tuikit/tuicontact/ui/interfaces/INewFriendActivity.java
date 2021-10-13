package com.tencent.qcloud.tuikit.tuicontact.ui.interfaces;


import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;

import java.util.List;

public interface INewFriendActivity {
    void onDataSourceChanged(List<FriendApplicationBean> beanList);
}
