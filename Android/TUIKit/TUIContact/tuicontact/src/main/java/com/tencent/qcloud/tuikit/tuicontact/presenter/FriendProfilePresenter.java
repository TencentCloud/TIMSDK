package com.tencent.qcloud.tuikit.tuicontact.presenter;


import android.os.Bundle;
import android.text.TextUtils;
import android.util.Pair;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactGroupApplyInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IFriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CountDownLatch;

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

    public void getUsersInfo(String id, ContactItemBean bean) {
        ArrayList<String> list = new ArrayList<>();
        list.add(id);
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
                bean.setSignature(user.getSignature());

                CountDownLatch latch = new CountDownLatch(2);
                ThreadHelper.INST.execute(new Runnable() {
                    @Override
                    public void run() {
                        isInBlackList(id, new IUIKitCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean data) {
                                bean.setBlackList(data);
                                latch.countDown();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                latch.countDown();
                            }
                        });
                    }
                });

                ThreadHelper.INST.execute(new Runnable() {
                    @Override
                    public void run() {
                        isFriend(id, bean, new IUIKitCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean data) {
                                bean.setFriend(data);
                                latch.countDown();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                latch.countDown();
                            }
                        });
                    }
                });

                ThreadHelper.INST.execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            latch.await();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (friendProfileLayout != null) {
                                    friendProfileLayout.onDataSourceChanged(bean);
                                }
                            }
                        });
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("getUsersInfo error , code = " + errCode + ", desc = " + errMsg);
            }
        });
    }


    public void isInBlackList(String id, IUIKitCallback<Boolean> callback) {
        provider.isInBlackList(id, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                ContactUtils.callbackOnSuccess(callback, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("getBlackList error , code = " + errCode + ", desc = " + errMsg);
                ContactUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }


    public void isFriend(String id, ContactItemBean bean, IUIKitCallback<Boolean> callback) {
        provider.isFriend(id, bean, callback);
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

    public void addFriend(String userId, String addWord, String friendGroup, String remark, IUIKitCallback<Pair<Integer, String>> callback) {
        provider.addFriend(userId, addWord, friendGroup, remark, new IUIKitCallback<Pair<Integer, String>>() {
            @Override
            public void onSuccess(Pair<Integer, String> data) {
                int code = data.first;
                String result = "";
                switch (code) {
                    case FriendApplicationBean.ERR_SUCC:
                        result = TUIContactService.getAppContext().getString(R.string.success);
                        break;
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS:
                        if (TextUtils.equals(data.second, "Err_SNS_FriendAdd_Friend_Exist")) {
                            result = TUIContactService.getAppContext().getString(R.string.have_be_friend);
                            break;
                        }
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_COUNT_LIMIT:
                        result = TUIContactService.getAppContext().getString(R.string.friend_limit);
                        break;
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT:
                        result = TUIContactService.getAppContext().getString(R.string.other_friend_limit);
                        break;
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST:
                        result = TUIContactService.getAppContext().getString(R.string.in_blacklist);
                        break;
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY:
                        result = TUIContactService.getAppContext().getString(R.string.forbid_add_friend);
                        break;
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST:
                        result = TUIContactService.getAppContext().getString(R.string.set_in_blacklist);
                        break;
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM:
                        result = TUIContactService.getAppContext().getString(R.string.wait_agree_friend);
                        break;
                    default:
                        result = TUIContactService.getAppContext().getString(R.string.other_friend_limit);
                        ToastUtil.toastLongMessage(data.first + " " + data.second);
                        break;
                }
                ContactUtils.callbackOnSuccess(callback, new Pair<>(code, result));
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ContactUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void joinGroup(String groupId, String addWord, IUIKitCallback<Void> callback) {
        provider.joinGroup(groupId, addWord, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                String msg = errMsg;
                if (errCode == GroupInfo.ERR_SVR_GROUP_PERMISSION_DENY) {
                    msg = TUIContactService.getAppContext().getString(R.string.add_group_permission_deny);
                } else if (errCode == GroupInfo.ERR_SVR_GROUP_ALLREADY_MEMBER) {
                    msg = TUIContactService.getAppContext().getString(R.string.add_group_allready_member);
                } else if (errCode == GroupInfo.ERR_SVR_GROUP_NOT_FOUND) {
                    msg = TUIContactService.getAppContext().getString(R.string.add_group_not_found);
                } else if (errCode == GroupInfo.ERR_SVR_GROUP_FULL_MEMBER_COUNT) {
                    msg = TUIContactService.getAppContext().getString(R.string.add_group_full_member);
                }
                ContactUtils.callbackOnError(callback, errCode, msg);
            }
        });
    }
}
