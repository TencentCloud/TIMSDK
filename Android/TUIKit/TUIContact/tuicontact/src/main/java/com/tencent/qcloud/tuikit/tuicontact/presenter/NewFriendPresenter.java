package com.tencent.qcloud.tuikit.tuicontact.presenter;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.ContactEventListener;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.INewFriendActivity;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class NewFriendPresenter {
    private static final String TAG = NewFriendPresenter.class.getSimpleName();

    private final ContactProvider provider;

    private INewFriendActivity friendActivity;

    private final List<FriendApplicationBean> dataSource = new ArrayList<>();

    private ContactEventListener friendApplicationListener;

    public NewFriendPresenter() {
        provider = new ContactProvider();

        friendApplicationListener = new ContactEventListener() {
            @Override
            public void onFriendApplicationListAdded(List<FriendApplicationBean> applicationList) {
                Iterator<FriendApplicationBean> beanIterator = applicationList.iterator();
                while(beanIterator.hasNext()) {
                    FriendApplicationBean friendApplicationBean = beanIterator.next();
                    for(FriendApplicationBean dataBean : dataSource) {
                        if (TextUtils.equals(dataBean.getUserId(), friendApplicationBean.getUserId())) {
                            beanIterator.remove();
                        }
                    }
                }
                dataSource.addAll(applicationList);
                notifyDataSourceChanged();
            }

            @Override
            public void onFriendApplicationListDeleted(List<String> userIDList) {
                Iterator<FriendApplicationBean> applicationIterator = dataSource.iterator();
                while(applicationIterator.hasNext()) {
                    FriendApplicationBean friendApplicationBean = applicationIterator.next();
                    for(String id : userIDList) {
                        if (TextUtils.equals(id, friendApplicationBean.getUserId())) {
                            applicationIterator.remove();
                        }
                    }
                }
                notifyDataSourceChanged();
            }

            @Override
            public void onFriendApplicationListRead() {
                super.onFriendApplicationListRead();
            }
        };
        TUIContactService.getInstance().addContactEventListener(friendApplicationListener);
    }

    public void setFriendActivity(INewFriendActivity friendActivity) {
        this.friendActivity = friendActivity;
    }

    public void loadFriendApplicationList() {
        dataSource.clear();
        provider.loadFriendApplicationList(new IUIKitCallback<List<FriendApplicationBean>>() {
            @Override
            public void onSuccess(List<FriendApplicationBean> data) {
                for (FriendApplicationBean friendApplicationBean : data) {
                    if (friendApplicationBean.getAddType() == FriendApplicationBean.FRIEND_APPLICATION_COME_IN) {
                        dataSource.add(friendApplicationBean);
                    }
                }
                notifyDataSourceChanged();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("Error code = " + errCode + ", desc = " + errMsg);
            }
        });
    }

    private void notifyDataSourceChanged() {
        if (friendActivity != null) {
            friendActivity.onDataSourceChanged(dataSource);
        }
    }

    public void acceptFriendApplication(FriendApplicationBean friendApplicationBean, IUIKitCallback<Void> callback) {
        provider.acceptFriendApplication(friendApplicationBean, FriendApplicationBean.FRIEND_ACCEPT_AGREE_AND_ADD, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e(TAG, "acceptFriendApplication error " + errCode + "  " + errMsg);
            }
        });
    }

    public void refuseFriendApplication(FriendApplicationBean friendApplicationBean, IUIKitCallback<Void> callback) {
        provider.refuseFriendApplication(friendApplicationBean, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e(TAG, "acceptFriendApplication error " + errCode + "  " + errMsg);
            }
        });
    }


    public void setFriendApplicationListAllRead(IUIKitCallback<Void> callback) {
        provider.setGroupApplicationRead(callback);
    }
}
