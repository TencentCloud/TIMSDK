package com.tencent.qcloud.tuikit.tuicontact.presenter;

import android.text.TextUtils;
import android.util.Pair;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IFriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
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
            public void onSuccess(Void data) {}

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void getUsersInfo(String id, ContactItemBean bean) {
        ArrayList<String> list = new ArrayList<>();
        list.add(id);
        provider.getUserInfo(list, new TUIValueCallback<List<ContactItemBean>>() {
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
                refreshDataSource(bean);
            }

            @Override
            public void onError(int errCode, String errMsg) {
                ToastUtil.toastShortMessage("getUsersInfo error , code = " + errCode + ", desc = " + errMsg);
            }
        });

        isInBlackList(id, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                bean.setBlackList(data);
                refreshDataSource(bean);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                refreshDataSource(bean);
            }
        });

        isFriend(id, bean, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                bean.setFriend(data);
                refreshDataSource(bean);
            }

            @Override
            public void onError(int errCode, String errMsg) {
                refreshDataSource(bean);
            }
        });
    }

    private void refreshDataSource(ContactItemBean bean) {
        if (friendProfileLayout != null) {
            friendProfileLayout.onDataSourceChanged(bean);
        }
    }

    public void isInBlackList(String id, IUIKitCallback<Boolean> callback) {
        provider.isInBlackList(id, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                ContactUtils.callbackOnSuccess(callback, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIContactLog.e(TAG, "isInBlackList err code = " + errCode + ", desc = " + errMsg);
                ContactUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void isFriend(String id, ContactItemBean bean, TUIValueCallback<Boolean> callback) {
        provider.isFriend(id, bean, callback);
    }

    public void addFriend(String userId, String addWord, String remark, IUIKitCallback<Pair<Integer, String>> callback) {
        provider.addFriend(userId, addWord, remark, new IUIKitCallback<Pair<Integer, String>>() {
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
                        break;
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
                    case FriendApplicationBean.ERR_SVR_FRIENDSHIP_ALREADY_FRIENDS:
                        result = TUIContactService.getAppContext().getString(R.string.have_be_friend);
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
