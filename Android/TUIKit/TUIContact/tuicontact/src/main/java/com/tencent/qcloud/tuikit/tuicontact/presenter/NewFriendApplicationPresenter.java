package com.tencent.qcloud.tuikit.tuicontact.presenter;

import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;

public class NewFriendApplicationPresenter {
    private static final String TAG = "AddFriendPresenter";
    private ContactProvider provider = new ContactProvider();

    public void acceptFriendApplication(FriendApplicationBean friendApplication, TUICallback callback) {
        int responseType = V2TIMFriendApplication.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD;
        provider.acceptFriendApplication(friendApplication, responseType, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICallback.onError(callback, errCode, errMsg);
            }
        });
    }

    public void refuseFriendApplication(FriendApplicationBean friendApplication, TUICallback callback) {
        provider.refuseFriendApplication(friendApplication, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICallback.onError(callback, errCode, errMsg);
            }

        });
    }

}
