package com.tencent.qcloud.tuikit.tuicontact.presenter;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.MessageCustom;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.ContactEventListener;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;
import com.tencent.qcloud.tuikit.tuicontact.ui.interfaces.IContactListView;
import com.tencent.qcloud.tuikit.tuicontact.ui.view.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ContactPresenter {
    private static final String TAG = ContactPresenter.class.getSimpleName();

    private final ContactProvider provider;

    private IContactListView contactListView;

    private final List<ContactItemBean> dataSource = new ArrayList<>();

    private ContactEventListener friendListListener;
    private ContactEventListener blackListListener;

    private boolean isSelectForCall = false;

    public ContactPresenter() {
        provider = new ContactProvider();
        provider.setNextSeq(0);
    }

    public void setContactListView(IContactListView contactListView) {
        this.contactListView = contactListView;
    }

    public void setFriendListListener() {
        friendListListener = new ContactEventListener() {
            @Override
            public void onFriendListAdded(List<ContactItemBean> users) {
                onDataListAdd(users);
            }

            @Override
            public void onFriendListDeleted(List<String> userList) {
                onDataListDeleted(userList);
            }

            @Override
            public void onFriendInfoChanged(List<ContactItemBean> infoList) {
                ContactPresenter.this.onFriendInfoChanged(infoList);
            }

            @Override
            public void onFriendRemarkChanged(String id, String remark) {
                ContactPresenter.this.onFriendRemarkChanged(id, remark);
            }

            @Override
            public void onFriendApplicationListAdded(List<FriendApplicationBean> applicationList) {
                if (contactListView != null) {
                    contactListView.onFriendApplicationChanged();
                }
            }

            @Override
            public void onFriendApplicationListDeleted(List<String> userIDList) {
                if (contactListView != null) {
                    contactListView.onFriendApplicationChanged();
                }
            }
        };
        TUIContactService.getInstance().addContactEventListener(friendListListener);
    }

    public void setBlackListListener() {
        blackListListener = new ContactEventListener() {
            @Override
            public void onBlackListAdd(List<ContactItemBean> infoList) {
                onDataListAdd(infoList);
            }

            @Override
            public void onBlackListDeleted(List<String> userList) {
                onDataListDeleted(userList);
            }
        };
        TUIContactService.getInstance().addContactEventListener(blackListListener);
    }

    public void setIsForCall(boolean isSelectForCall) {
        this.isSelectForCall = isSelectForCall;
    }

    public void loadDataSource(int dataSourceType) {
        IUIKitCallback<List<ContactItemBean>> callback = new IUIKitCallback<List<ContactItemBean>>() {
            @Override
            public void onSuccess(List<ContactItemBean> data) {
                TUIContactLog.i(TAG, "load data source success , loadType = " + dataSourceType);
                onDataLoaded(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e(TAG, "load data source error , loadType = " + dataSourceType +
                        "  " + "errCode = " + errCode + "  errMsg = " + errMsg);
                onDataLoaded(new ArrayList<>());
            }
        };

        dataSource.clear();
        switch (dataSourceType) {
            case ContactListView.DataSource.FRIEND_LIST:
                provider.loadFriendListDataAsync(callback);
                break;
            case ContactListView.DataSource.BLACK_LIST:
                provider.loadBlackListData(callback);
                break;
            case ContactListView.DataSource.GROUP_LIST:
                provider.loadGroupListData(callback);
                break;
            case ContactListView.DataSource.CONTACT_LIST:
                dataSource.add((ContactItemBean) new ContactItemBean(TUIContactService.getAppContext().getResources().getString(R.string.new_friend))
                        .setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                dataSource.add((ContactItemBean) new ContactItemBean(TUIContactService.getAppContext().getResources().getString(R.string.group)).
                        setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                dataSource.add((ContactItemBean) new ContactItemBean(TUIContactService.getAppContext().getResources().getString(R.string.blacklist)).
                        setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
                provider.loadFriendListDataAsync(callback);
                break;
            default:
                break;
        }
    }

    public long getNextSeq() {
        return provider == null ? 0 : provider.getNextSeq();
    }

    public void loadGroupMemberList(String groupId) {
        if (!isSelectForCall && getNextSeq() == 0) {
            dataSource.add((ContactItemBean) new ContactItemBean(TUIContactService.getAppContext().getResources().getString(R.string.at_all))
                    .setTop(true).setBaseIndexTag(ContactItemBean.INDEX_STRING_TOP));
        }
        provider.loadGroupMembers(groupId, new IUIKitCallback<List<ContactItemBean>>() {
            @Override
            public void onSuccess(List<ContactItemBean> data) {
                TUIContactLog.i(TAG, "load data source success , loadType = " + ContactListView.DataSource.GROUP_MEMBER_LIST);
                onDataLoaded(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e(TAG, "load data source error , loadType = " + ContactListView.DataSource.GROUP_MEMBER_LIST +
                        "  " + "errCode = " + errCode + "  errMsg = " + errMsg);
                onDataLoaded(new ArrayList<>());

            }
        });
    }

    private void onDataLoaded(List<ContactItemBean> loadedData) {
        dataSource.addAll(loadedData);
        notifyDataSourceChanged();
    }

    private void notifyDataSourceChanged() {
        if (contactListView != null) {
            contactListView.onDataSourceChanged(dataSource);
        }
    }

    private void onDataListDeleted(List<String> userList) {
        Iterator<ContactItemBean> userIterator = dataSource.iterator();
        while(userIterator.hasNext()) {
            ContactItemBean contactItemBean = userIterator.next();
            for(String id : userList) {
                if (TextUtils.equals(id, contactItemBean.getId())) {
                    userIterator.remove();
                }
            }
        }
        notifyDataSourceChanged();
    }

    private void onDataListAdd(List<ContactItemBean> users) {
        List<ContactItemBean> addUserList = new ArrayList<>(users);
        Iterator<ContactItemBean> beanIterator = addUserList.iterator();
        while(beanIterator.hasNext()) {
            ContactItemBean contactItemBean = beanIterator.next();
            for(ContactItemBean dataItemBean : dataSource) {
                if (TextUtils.equals(contactItemBean.getId(), dataItemBean.getId())) {
                    beanIterator.remove();
                }
            }
        }
        dataSource.addAll(addUserList);
        notifyDataSourceChanged();
    }

    public void getFriendApplicationUnreadCount(IUIKitCallback<Integer> callback) {
        provider.getFriendApplicationListUnreadCount(callback);
    }

    public void loadFriendApplicationList(IUIKitCallback<Integer> callback) {
        provider.loadFriendApplicationList(new IUIKitCallback<List<FriendApplicationBean>>() {
            @Override
            public void onSuccess(List<FriendApplicationBean> data) {
                int size = 0;
                for (FriendApplicationBean friendApplicationBean : data) {
                    if (friendApplicationBean.getAddType() == FriendApplicationBean.FRIEND_APPLICATION_COME_IN) {
                        size++;
                    }
                }
                ContactUtils.callbackOnSuccess(callback, size);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void createGroupChat(GroupInfo groupInfo, IUIKitCallback<String> callback) {
        provider.createGroupChat(groupInfo, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String groupId) {
                groupInfo.setId(groupId);
                Gson gson = new Gson();
                MessageCustom messageCustom = new MessageCustom();
                messageCustom.version = TUIContactConstants.version;
                messageCustom.businessID = MessageCustom.BUSINESS_ID_GROUP_CREATE;
                messageCustom.opUser = TUILogin.getLoginUser();
                messageCustom.content = TUIContactService.getAppContext().getString(R.string.create_group);
                String data = gson.toJson(messageCustom);

                ThreadHelper.INST.execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            Thread.sleep(200);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        sendGroupTipsMessage(groupId, data, new IUIKitCallback<String>() {
                            @Override
                            public void onSuccess(String result) {
                                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        ContactUtils.callbackOnSuccess(callback, result);
                                    }
                                });
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        ContactUtils.callbackOnError(callback, module, errCode, errMsg);
                                    }
                                });
                            }
                        });
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void onFriendInfoChanged(List<ContactItemBean> infoList) {
        for (ContactItemBean changedItem : infoList) {
            for (int i = 0;i < dataSource.size();i++) {
                if (TextUtils.equals(dataSource.get(i).getId(), changedItem.getId())) {
                    dataSource.set(i, changedItem);
                    break;
                }
            }
        }
        notifyDataSourceChanged();
    }

    public void onFriendRemarkChanged(String id, String remark) {
        loadDataSource(ContactListView.DataSource.CONTACT_LIST);
    }

    public void sendGroupTipsMessage(String groupId, String messageData, IUIKitCallback<String> callback) {
        provider.sendGroupTipsMessage(groupId, messageData, callback);
    }

}
