package com.tencent.qcloud.uikit.business.contact.presenter;

import com.tencent.qcloud.uikit.api.contact.IContactPanel;
import com.tencent.qcloud.uikit.business.contact.model.ContactManager;
import com.tencent.qcloud.uikit.common.IUIKitUICallback;
import com.tencent.qcloud.uikit.common.utils.UIUtils;


public class ContactPresenter {

    private IContactPanel mView;
    public ContactManager manager = ContactManager.getInstance();

    public ContactPresenter(IContactPanel panel) {
        mView = panel;
        loadContact();
    }

    public void loadContact() {
        manager.loadFriends(new IUIKitUICallback() {
            @Override
            public void onSuccess(Object res) {
                mView.setDataProvider(manager.getContactProvider());
            }

            @Override
            public void onFail(Object res) {
                UIUtils.toastLongMessage("加载联系人失败" + res);
            }
        });

    }

    public void addContact(String identifier) {
        manager.addFriend(identifier, new IUIKitUICallback() {
            @Override
            public void onSuccess(Object res) {
                UIUtils.toastLongMessage("添加好友成功");
                mView.refreshData();
            }

            @Override
            public void onFail(Object res) {
                UIUtils.toastLongMessage("添加好友失败:" + res);
            }
        });
    }

    public void delContact(String identifier) {
        manager.delFriend(identifier, new IUIKitUICallback() {
            @Override
            public void onSuccess(Object res) {
                UIUtils.toastLongMessage("删除好友成功");
                mView.refreshData();
            }

            @Override
            public void onFail(Object res) {
                UIUtils.toastLongMessage("删除好友失败:" + res);
            }
        });
    }

}
