package com.tencent.qcloud.tuikit.tuicontact.presenter;


import android.os.Bundle;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactGroupApplyInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;
import com.tencent.qcloud.tuikit.tuicontact.ui.interfaces.IFriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;

import java.util.HashMap;
import java.util.List;

public class FriendProfilePresenter {
    private static final String TAG = FriendProfilePresenter.class.getSimpleName();

    private final ContactProvider provider;

    private IFriendProfileLayout friendProfileLayout;

    public FriendProfilePresenter() {
        provider = new ContactProvider();
    }

    public void setFriendProfileLayout(IFriendProfileLayout friendProfileLayout) {
        this.friendProfileLayout = friendProfileLayout;
    }

    public void getC2CReceiveMessageOpt(List<String> userIdList, IUIKitCallback<Boolean> callback) {
        provider.getC2CReceiveMessageOpt(userIdList, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                ContactUtils.callbackOnSuccess(callback, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, TAG, errCode, errMsg);
            }
        });
    }

    public void setC2CReceiveMessageOpt(List<String> userIdList, boolean isReceiveMessage) {
        provider.setC2CReceiveMessageOpt(userIdList, isReceiveMessage, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public void getUsersInfo(List<String> list, ContactItemBean bean) {
        provider.getUserInfo(list, new IUIKitCallback<List<ContactItemBean>>() {
            @Override
            public void onSuccess(List<ContactItemBean> data) {
                if (data == null || data.size() != 1) {
                    return;
                }
                ContactItemBean user = data.get(0);
                bean.setNickName(user.getNickName());
                bean.setId(user.getId());
                bean.setAvatarUrl(user.getAvatarUrl());
                if (friendProfileLayout != null) {
                    friendProfileLayout.onDataSourceChanged(bean);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("getUsersInfo error , code = " + errCode + ", desc = " + errMsg);
            }
        });
    }


    public void getBlackList(String id, ContactItemBean bean) {
        provider.getBlackList(id, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                bean.setBlackList(true);
                if (friendProfileLayout != null) {
                    friendProfileLayout.onDataSourceChanged(bean);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("getBlackList error , code = " + errCode + ", desc = " + errMsg);
            }
        });
    }


    public void getFriendList(String id, ContactItemBean bean) {
        provider.getFriendList(id, new IUIKitCallback<ContactItemBean>() {
            @Override
            public void onSuccess(ContactItemBean data) {
                bean.setFriend(true);
                bean.setRemark(data.getRemark());
                bean.setAvatarUrl(data.getAvatarUrl());
                if (friendProfileLayout != null) {
                    friendProfileLayout.onDataSourceChanged(bean);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("getFriendList error, code = " + errCode + ", desc = " + errMsg);
            }
        });
    }

    public void deleteFromBlackList(List<String> idList) {
        provider.deleteFromBlackList(idList, new IUIKitCallback<Void>() {

            @Override
            public void onSuccess(Void data) {
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("deleteFromBlackList Error code = " + errCode + ", desc = " + errMsg);

            }
        });
    }

    public void addToBlackList(List<String> idList) {
        provider.addToBlackList(idList, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("addToBlackList Error code = " + errCode + ", desc = " + errMsg);

            }
        });
    }

    public void modifyRemark(String id, String remark, IUIKitCallback<String> callback) {
        provider.modifyRemark(id, remark, callback);
    }

    public void deleteFriend(List<String> idList, IUIKitCallback<Void> callback) {
        provider.deleteFriend(idList, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                for (String id : idList) {
                    String conversationId = TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX + id;
                    HashMap<String, Object> param = new HashMap<>();
                    param.put(TUIConstants.TUIConversation.CONVERSATION_ID, conversationId);
                    param.put(TUIConstants.TUIChat.CHAT_ID, id);
                    param.put(TUIConstants.TUIChat.IS_GROUP_CHAT, false);
                    TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME, TUIConstants.TUIConversation.METHOD_DELETE_CONVERSATION, param);
                    TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_EXIT_CHAT, param);
                }
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, module, errCode, errMsg);
            }
        });
    }

    public void refuseFriendApplication(FriendApplicationBean friendApplication, IUIKitCallback<Void> callback) {
        provider.refuseFriendApplication(friendApplication, callback);
    }

    public void acceptFriendApplication(FriendApplicationBean friendApplication, int responseType, IUIKitCallback<Void> callback) {
        provider.acceptFriendApplication(friendApplication, responseType, callback);
    }

    public boolean isTopConversation(String chatId) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.CHAT_ID, chatId);
        Object result = TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME,
                TUIConstants.TUIConversation.METHOD_IS_TOP_CONVERSATION, param);
        if (result instanceof Bundle) {
            return ((Bundle) result).getBoolean(TUIConstants.TUIConversation.IS_TOP, false);
        }
        return false;
    }

    public void setConversationTop(String chatId, boolean isSetTop) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.CHAT_ID, chatId);
        param.put(TUIConstants.TUIConversation.IS_SET_TOP, isSetTop);
        TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME, TUIConstants.TUIConversation.METHOD_SET_TOP_CONVERSATION, param);
    }


    public void acceptJoinGroupApply(ContactGroupApplyInfo info, IUIKitCallback<Void> callback) {
        provider.acceptJoinGroupApply(info, callback);
    }

    public void refuseJoinGroupApply(ContactGroupApplyInfo info, String reason, IUIKitCallback<Void> callback) {
        provider.refuseJoinGroupApply(info, reason, callback);
    }
}
