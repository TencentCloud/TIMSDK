package com.tencent.qcloud.tuikit.tuicontact.model;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMCreateGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMFriendAddApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMReceiveMessageOptInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.BuildConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactGroupApplyInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.config.TUIContactConfig;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ContactProvider {
    private static final String TAG = ContactProvider.class.getSimpleName();
    private long mNextSeq = 0;

    public void loadFriendListDataAsync(IUIKitCallback<List<ContactItemBean>> callback) {
        TUIContactLog.i(TAG, "loadFriendListDataAsync");
        ThreadHelper.INST.execute(new Runnable() {
            @Override
            public void run() {
                // 压测时数据量比较大，query耗时比较久，所以这里使用新线程来处理
                // The amount of data during the stress test is relatively large, and the query takes a long time, so a new thread is used here to process
                V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIContactLog.e(TAG, "loadFriendListDataAsync err code:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                        ContactUtils.callbackOnError(callback, TAG, code, desc);
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                        List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                        TUIContactLog.i(TAG, "loadFriendListDataAsync->getFriendList:" + v2TIMFriendInfos.size());
                        for (V2TIMFriendInfo timFriendInfo : v2TIMFriendInfos) {
                            ContactItemBean info = new ContactItemBean();
                            info.setFriend(true);
                            info.covertTIMFriend(timFriendInfo);
                            contactItemBeanList.add(info);
                        }
                        ContactUtils.callbackOnSuccess(callback, contactItemBeanList);
                    }
                });
            }
        });
    }


    public void loadBlackListData(IUIKitCallback<List<ContactItemBean>> callback) {
        TUIContactLog.i(TAG, "loadBlackListData");

        V2TIMManager.getFriendshipManager().getBlackList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getBlackList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                TUIContactLog.i(TAG, "getBlackList success: " + v2TIMFriendInfos.size());
                if (v2TIMFriendInfos.size() == 0) {
                    TUIContactLog.i(TAG, "getBlackList success but no data");
                }
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for (V2TIMFriendInfo timFriendInfo : v2TIMFriendInfos) {
                    ContactItemBean info = new ContactItemBean();
                    info.covertTIMFriend(timFriendInfo).setBlackList(true);
                    contactItemBeanList.add(info);
                }
                ContactUtils.callbackOnSuccess(callback, contactItemBeanList);
            }
        });

    }

    public void loadGroupListData(IUIKitCallback<List<ContactItemBean>> callback) {
        TUIContactLog.i(TAG, "loadGroupListData");
        V2TIMManager.getGroupManager().getJoinedGroupList(new V2TIMValueCallback<List<V2TIMGroupInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getGroupList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfo> v2TIMGroupInfos) {
                TUIContactLog.i(TAG, "getGroupList success: " + v2TIMGroupInfos.size());
                if (v2TIMGroupInfos.size() == 0) {
                    TUIContactLog.i(TAG, "getGroupList success but no data");
                }
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();

                for (V2TIMGroupInfo info : v2TIMGroupInfos) {
                    ContactItemBean bean = new ContactItemBean();
                    contactItemBeanList.add(bean.covertTIMGroupBaseInfo(info));
                }
                ContactUtils.callbackOnSuccess(callback, contactItemBeanList);
            }
        });
    }

    public long getNextSeq() {
        return mNextSeq;
    }

    public void setNextSeq(long nextSeq) {
        this.mNextSeq = nextSeq;
    }

    public void loadGroupMembers(String groupId, IUIKitCallback<List<ContactItemBean>> callback) {
        V2TIMManager.getGroupManager().getGroupMemberList(groupId, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL, mNextSeq, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int code, String desc) {
                ContactUtils.callbackOnError(callback, TAG, code, desc);
                TUIContactLog.e(TAG, "loadGroupMembers failed, code: " + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<V2TIMGroupMemberFullInfo> members = new ArrayList<>();
                for (int i = 0; i < v2TIMGroupMemberInfoResult.getMemberInfoList().size(); i++) {
                    if (v2TIMGroupMemberInfoResult.getMemberInfoList().get(i).getUserID().equals(V2TIMManager.getInstance().getLoginUser())) {
                        continue;
                    }
                    members.add(v2TIMGroupMemberInfoResult.getMemberInfoList().get(i));
                }

                mNextSeq = v2TIMGroupMemberInfoResult.getNextSeq();
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for (V2TIMGroupMemberFullInfo info : members) {
                    ContactItemBean bean = new ContactItemBean();
                    contactItemBeanList.add(bean.covertTIMGroupMemberFullInfo(info));
                }
                ContactUtils.callbackOnSuccess(callback, contactItemBeanList);
            }
        });
    }

    public void addFriend(String userId, String addWording, IUIKitCallback<Pair<Integer, String>> callback) {
        addFriend(userId, addWording, null, null, callback);
    }

    public void addFriend(String userId, String addWording, String friendGroup, String remark, IUIKitCallback<Pair<Integer, String>> callback) {
        V2TIMFriendAddApplication v2TIMFriendAddApplication = new V2TIMFriendAddApplication(userId);
        v2TIMFriendAddApplication.setAddWording(addWording);
        v2TIMFriendAddApplication.setAddSource("android");
        v2TIMFriendAddApplication.setFriendGroup(friendGroup);
        v2TIMFriendAddApplication.setFriendRemark(remark);
        V2TIMManager.getFriendshipManager().addFriend(v2TIMFriendAddApplication, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "addFriend err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                TUIContactLog.i(TAG, "addFriend success");
                ContactUtils.callbackOnSuccess(callback, new Pair<>(v2TIMFriendOperationResult.getResultCode(), v2TIMFriendOperationResult.getResultInfo()));
            }
        });
    }

    public void joinGroup(String groupId, String addWording, IUIKitCallback<Void> callback) {
        V2TIMManager.getInstance().joinGroup(groupId, addWording, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "addGroup err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                TUIContactLog.i(TAG, "addGroup success");
                ContactUtils.callbackOnSuccess(callback, null);
            }
        });
    }

    public void loadFriendApplicationList(IUIKitCallback<List<FriendApplicationBean>> callback) {
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getPendencyList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                List<FriendApplicationBean> applicationBeanList = new ArrayList<>();
                for (V2TIMFriendApplication application : v2TIMFriendApplicationResult.getFriendApplicationList()) {
                    FriendApplicationBean bean = new FriendApplicationBean();
                    bean.convertFromTimFriendApplication(application);
                    applicationBeanList.add(bean);
                }
                ContactUtils.callbackOnSuccess(callback, applicationBeanList);
            }
        });
    }

    public void getFriendApplicationListUnreadCount(IUIKitCallback<Integer> callback) {
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getPendencyList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                ContactUtils.callbackOnSuccess(callback, v2TIMFriendApplicationResult.getUnreadCount());
            }
        });
    }

    private void acceptFriendApplication(V2TIMFriendApplication friendApplication, int responseType, IUIKitCallback<Void> callback) {
        V2TIMManager.getFriendshipManager().acceptFriendApplication(
                friendApplication, responseType, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIContactLog.e(TAG, "acceptFriend err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                    }

                    @Override
                    public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                        TUIContactLog.i(TAG, "acceptFriend success");
                        ContactUtils.callbackOnSuccess(callback, null);
                    }
                });
    }

    public void acceptFriendApplication(FriendApplicationBean bean, int responseType, IUIKitCallback<Void> callback) {
        V2TIMFriendApplication friendApplication = bean.getFriendApplication();
        acceptFriendApplication(friendApplication, responseType, callback);

    }

    public void getC2CReceiveMessageOpt(List<String> userIdList, IUIKitCallback<Boolean> callback) {
        V2TIMManager.getMessageManager().getC2CReceiveMessageOpt(userIdList, new V2TIMValueCallback<List<V2TIMReceiveMessageOptInfo>>() {
            @Override
            public void onSuccess(List<V2TIMReceiveMessageOptInfo> V2TIMReceiveMessageOptInfos) {
                if (V2TIMReceiveMessageOptInfos == null || V2TIMReceiveMessageOptInfos.isEmpty()) {
                    TUIContactLog.d(TAG, "getC2CReceiveMessageOpt null");
                    ContactUtils.callbackOnError(callback, TAG, -1, "getC2CReceiveMessageOpt null");
                    return;
                }
                V2TIMReceiveMessageOptInfo V2TIMReceiveMessageOptInfo = V2TIMReceiveMessageOptInfos.get(0);
                int option = V2TIMReceiveMessageOptInfo.getC2CReceiveMessageOpt();

                TUIContactLog.d(TAG, "getC2CReceiveMessageOpt option = " + option);
                ContactUtils.callbackOnSuccess(callback, option == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
            }

            @Override
            public void onError(int code, String desc) {
                TUIContactLog.d(TAG, "getC2CReceiveMessageOpt onError code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }
        });
    }

    public void  setC2CReceiveMessageOpt(List<String> userIdList, boolean isReceiveMessage, IUIKitCallback<Void> callback) {
        int option;
        if (isReceiveMessage) {
            option = V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
        } else {
            option = V2TIMMessage.V2TIM_RECEIVE_MESSAGE;
        }
        V2TIMManager.getMessageManager().setC2CReceiveMessageOpt(userIdList, option, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIContactLog.d(TAG, "setC2CReceiveMessageOpt onSuccess");
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIContactLog.d(TAG, "setC2CReceiveMessageOpt onError code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }
        });
    }

    public void getGroupInfo(List<String> groupIds, IUIKitCallback<List<GroupInfo>> callback) {
        V2TIMManager.getGroupManager().getGroupsInfo(groupIds, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                List<GroupInfo> groupInfos = new ArrayList<>();
                for (V2TIMGroupInfoResult result : v2TIMGroupInfoResults) {
                    if (result.getResultCode() != 0) {
                        ContactUtils.callbackOnError(callback, result.getResultCode(), result.getResultMessage());
                        return;
                    }
                    GroupInfo groupInfo = new GroupInfo();
                    groupInfo.setId(result.getGroupInfo().getGroupID());
                    groupInfo.setFaceUrl(result.getGroupInfo().getFaceUrl());
                    groupInfo.setGroupName(result.getGroupInfo().getGroupName());
                    groupInfo.setMemberCount(result.getGroupInfo().getMemberCount());
                    groupInfo.setGroupType(result.getGroupInfo().getGroupType());
                    groupInfos.add(groupInfo);
                }
                ContactUtils.callbackOnSuccess(callback, groupInfos);
            }

            @Override
            public void onError(int code, String desc) {
                ContactUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void getUserInfo(List<String> userIdList, IUIKitCallback<List<ContactItemBean>> callback) {
        V2TIMManager.getInstance().getUsersInfo(userIdList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError ( int code, String desc){
                TUIContactLog.e(TAG, "loadUserProfile err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess (List<V2TIMUserFullInfo > v2TIMUserFullInfos) {
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for(V2TIMUserFullInfo userFullInfo : v2TIMUserFullInfos) {
                    ContactItemBean contactItemBean = new ContactItemBean();
                    contactItemBean.setNickName(userFullInfo.getNickName());
                    contactItemBean.setId(userFullInfo.getUserID());
                    contactItemBean.setAvatarUrl(userFullInfo.getFaceUrl());
                    contactItemBean.setSignature(userFullInfo.getSelfSignature());
                    contactItemBeanList.add(contactItemBean);
                }
                ContactUtils.callbackOnSuccess(callback, contactItemBeanList);
            }
        });
    }

    public void isInBlackList(String id, IUIKitCallback<Boolean> callback) {
        V2TIMManager.getFriendshipManager().getBlackList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getBlackList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                if (v2TIMFriendInfos != null && v2TIMFriendInfos.size() > 0) {
                    for (V2TIMFriendInfo friendInfo : v2TIMFriendInfos) {
                        if (TextUtils.equals(friendInfo.getUserID(), id)) {
                            ContactUtils.callbackOnSuccess(callback, true);
                            return;
                        }
                    }
                }
                ContactUtils.callbackOnSuccess(callback, false);
            }
        });
    }

    public void isFriend(String id, ContactItemBean bean, IUIKitCallback<Boolean> callback) {
        V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getFriendList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                if (v2TIMFriendInfos != null && v2TIMFriendInfos.size() > 0) {
                    for (V2TIMFriendInfo friendInfo : v2TIMFriendInfos) {
                        if (TextUtils.equals(friendInfo.getUserID(), id)) {
                            bean.setFriend(true);
                            bean.setRemark(friendInfo.getFriendRemark());
                            bean.setAvatarUrl(friendInfo.getUserProfile().getFaceUrl());
                            ContactUtils.callbackOnSuccess(callback, true);
                            return;
                        }
                    }
                }
                ContactUtils.callbackOnSuccess(callback, false);
            }
        });
    }

    public void deleteFromBlackList(List<String> idList, IUIKitCallback<Void> callback) {
        V2TIMManager.getFriendshipManager().deleteFromBlackList(idList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "deleteBlackList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUIContactLog.i(TAG, "deleteBlackList success");
                ContactUtils.callbackOnSuccess(callback, null);

            }
        });
    }

    public void addToBlackList(List<String> idList, IUIKitCallback<Void> callback) {
        V2TIMManager.getFriendshipManager().addToBlackList(idList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "deleteBlackList err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUIContactLog.i(TAG, "deleteBlackList success");
                ContactUtils.callbackOnSuccess(callback, null);

            }
        });
    }

    public void modifyRemark(String id, String remark, IUIKitCallback<String> callback) {

        V2TIMFriendInfo v2TIMFriendInfo = new V2TIMFriendInfo();
        v2TIMFriendInfo.setUserID(id);
        v2TIMFriendInfo.setFriendRemark(remark);

        V2TIMManager.getFriendshipManager().setFriendInfo(v2TIMFriendInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "modifyRemark err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                ContactUtils.callbackOnSuccess(callback, remark);
                TUIContactLog.i(TAG, "modifyRemark success");
            }
        });
    }

    public void deleteFriend(List<String> identifiers, IUIKitCallback<Void> callback) {
        V2TIMManager.getFriendshipManager().deleteFromFriendList(identifiers, V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "deleteFriends err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUIContactLog.i(TAG, "deleteFriends success");
                ContactUtils.callbackOnSuccess(callback, null);
            }
        });
    }

    public void refuseFriendApplication(FriendApplicationBean friendApplication, IUIKitCallback<Void> callback) {
        V2TIMFriendApplication v2TIMFriendApplication = friendApplication.getFriendApplication();
        if (v2TIMFriendApplication == null) {
            ContactUtils.callbackOnError(callback, "refuseFriendApplication", -1,  "V2TIMFriendApplication is null");
            return;
        }
        V2TIMManager.getFriendshipManager().refuseFriendApplication(v2TIMFriendApplication, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "accept err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ContactUtils.callbackOnError(callback, TAG, code, desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                TUIContactLog.i(TAG, "refuse success");
                ContactUtils.callbackOnSuccess(callback, null);
            }
        });
    }

    public void createGroupChat(GroupInfo groupInfo, IUIKitCallback<String> callback) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setGroupType(groupInfo.getGroupType());
        v2TIMGroupInfo.setGroupName(groupInfo.getGroupName());
        v2TIMGroupInfo.setGroupAddOpt(groupInfo.getJoinType());
        v2TIMGroupInfo.setGroupID(groupInfo.getId());
        v2TIMGroupInfo.setFaceUrl(groupInfo.getFaceUrl());
        if (TextUtils.equals(v2TIMGroupInfo.getGroupType(), V2TIMManager.GROUP_TYPE_COMMUNITY)) {
            v2TIMGroupInfo.setSupportTopic(groupInfo.isCommunitySupportTopic());
        }

        List<V2TIMCreateGroupMemberInfo> v2TIMCreateGroupMemberInfoList = new ArrayList<>();
        for (int i = 0; i < groupInfo.getMemberDetails().size(); i++) {
            GroupMemberInfo groupMemberInfo = groupInfo.getMemberDetails().get(i);
            V2TIMCreateGroupMemberInfo v2TIMCreateGroupMemberInfo = new V2TIMCreateGroupMemberInfo();
            v2TIMCreateGroupMemberInfo.setUserID(groupMemberInfo.getAccount());
            v2TIMCreateGroupMemberInfoList.add(v2TIMCreateGroupMemberInfo);
        }

        V2TIMManager.getGroupManager().createGroup(v2TIMGroupInfo, v2TIMCreateGroupMemberInfoList, new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String s) {
                ContactUtils.callbackOnSuccess(callback, s);
            }

            @Override
            public void onError(int code, String desc) {
                ContactUtils.callbackOnError(callback, code, desc);
            }
        });
    }


    public void sendGroupTipsMessage(String groupId, String message, IUIKitCallback<String> callback) {
        V2TIMMessage v2TIMMessage = V2TIMManager.getMessageManager().createCustomMessage(message.getBytes());
        V2TIMManager.getMessageManager().sendMessage(v2TIMMessage, null, groupId,
                V2TIMMessage.V2TIM_PRIORITY_DEFAULT, false, null, new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int progress) {

                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIContactLog.i(TAG, "sendTipsMessage error , code : " + code + " desc : " + ErrorMessageConverter.convertIMError(code, desc));
                        ContactUtils.callbackOnError(callback, TAG, code, desc);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        TUIContactLog.i(TAG, "sendTipsMessage onSuccess");
                        ContactUtils.callbackOnSuccess(callback, groupId);
                    }
                });

    }

    public void acceptJoinGroupApply(ContactGroupApplyInfo applyInfo, IUIKitCallback<Void> callback) {
        V2TIMGroupApplication application = applyInfo.getTimGroupApplication();
        String reason = applyInfo.getRequestMsg();
        V2TIMManager.getGroupManager().acceptGroupApplication(application, reason, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                ContactUtils.callbackOnError(callback, code, desc);

            }
        });
    }

    public void refuseJoinGroupApply(ContactGroupApplyInfo info, String reason, IUIKitCallback<Void> callback) {
        V2TIMGroupApplication application = info.getTimGroupApplication();
        V2TIMManager.getGroupManager().refuseGroupApplication(application, reason, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                ContactUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void setGroupApplicationRead(IUIKitCallback<Void> callback) {
        V2TIMManager.getGroupManager().setGroupApplicationRead(new V2TIMCallback() {
            @Override
            public void onSuccess() {
                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                ContactUtils.callbackOnError(callback, code, desc);
            }
        });
    }

    public void loadContactUserStatus(List<ContactItemBean> dataSource, IUIKitCallback<Void> callback) {
        if (dataSource == null || dataSource.size() == 0) {
            TUIContactLog.d(TAG, "loadContactUserStatus datasource is null");
            ContactUtils.callbackOnError(callback, -1, "data list is empty");
            return;
        }

        HashMap<String, ContactItemBean> dataSourceMap = new HashMap<>();
        List<String> userList = new ArrayList<>();
        for(ContactItemBean itemBean : dataSource) {
            if (TextUtils.equals(TUIContactService.getAppContext().getResources().getString(R.string.new_friend), itemBean.getId())
            || TextUtils.equals(TUIContactService.getAppContext().getResources().getString(R.string.blacklist), itemBean.getId())
            || TextUtils.equals(TUIContactService.getAppContext().getResources().getString(R.string.group), itemBean.getId())) {
                continue;
            }
            userList.add(itemBean.getId());
            dataSourceMap.put(itemBean.getId(), itemBean);
        }
        V2TIMManager.getInstance().getUserStatus(userList, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                TUIContactLog.i(TAG, "getUserStatus success");

                for (V2TIMUserStatus item : v2TIMUserStatuses) {
                    ContactItemBean bean = dataSourceMap.get(item.getUserID());
                    if (bean != null) {
                        bean.setStatusType(item.getStatusType());
                    }
                }

                ContactUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIContactLog.e(TAG, "getUserStatus error code = " + code + ",des = " + desc);
                ContactUtils.callbackOnError(callback, code, desc);
                if (code == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT &&
                        TUIContactConfig.getInstance().isShowUserStatus() && BuildConfig.DEBUG) {
                    ToastUtil.toastLongMessage(desc);
                }
            }
        });
    }

}
