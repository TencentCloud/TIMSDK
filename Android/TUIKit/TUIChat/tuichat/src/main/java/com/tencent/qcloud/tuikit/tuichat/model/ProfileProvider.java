package com.tencent.qcloud.tuikit.tuichat.model;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMReceiveMessageOptInfo;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.FriendProfileBean;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonUtil;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberBean;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProfileProvider {

    public void getGroupsProfile(String groupID, TUIValueCallback<GroupProfileBean> callback) {
        List<String> groupIDs = new ArrayList<>();
        groupIDs.add(groupID);
        V2TIMManager.getGroupManager().getGroupsInfo(groupIDs, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                if (v2TIMGroupInfoResults != null && !v2TIMGroupInfoResults.isEmpty()) {
                    V2TIMGroupInfoResult result = v2TIMGroupInfoResults.get(0);
                    if (result.getResultCode() == 0) {
                        V2TIMGroupInfo groupInfo = result.getGroupInfo();
                        GroupProfileBean groupProfileBean = new GroupProfileBean();
                        groupProfileBean.setGroupID(groupInfo.getGroupID());
                        groupProfileBean.setGroupName(groupInfo.getGroupName());
                        groupProfileBean.setGroupFaceUrl(groupInfo.getFaceUrl());
                        groupProfileBean.setRoleInGroup(groupInfo.getRole());
                        groupProfileBean.setGroupType(groupInfo.getGroupType());
                        groupProfileBean.setNotification(groupInfo.getNotification());
                        groupProfileBean.setMemberCount(groupInfo.getMemberCount());
                        groupProfileBean.setAllMuted(groupInfo.isAllMuted());
                        groupProfileBean.setApproveOpt(groupInfo.getGroupApproveOpt());
                        groupProfileBean.setAddOpt(groupInfo.getGroupAddOpt());
                        groupProfileBean.setRecvOpt(groupInfo.getRecvOpt());
                        TUIValueCallback.onSuccess(callback, groupProfileBean);
                    } else {
                        TUIValueCallback.onError(callback, result.getResultCode(), result.getResultMessage());
                    }
                } else {
                    TUIValueCallback.onError(callback, -1, "getGroupInfo failed, result is null");
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void getGroupMembersProfile(String groupID, List<String> userIDs, TUIValueCallback<List<GroupMemberBean>> callback) {
        V2TIMManager.getGroupManager().getGroupMembersInfo(groupID, userIDs, new V2TIMValueCallback<List<V2TIMGroupMemberFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfos) {
                List<GroupMemberBean> groupMemberBeans = new ArrayList<>();
                for (V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo : v2TIMGroupMemberFullInfos) {
                    GroupMemberBean groupMemberBean = new GroupMemberBean();
                    groupMemberBean.setUserId(v2TIMGroupMemberFullInfo.getUserID());
                    groupMemberBean.setFriendRemark(v2TIMGroupMemberFullInfo.getFriendRemark());
                    groupMemberBean.setFaceUrl(v2TIMGroupMemberFullInfo.getFaceUrl());
                    groupMemberBean.setNickName(v2TIMGroupMemberFullInfo.getNickName());
                    groupMemberBean.setNameCard(v2TIMGroupMemberFullInfo.getNameCard());
                    groupMemberBean.setRole(v2TIMGroupMemberFullInfo.getRole());
                    groupMemberBeans.add(groupMemberBean);
                }
                TUIValueCallback.onSuccess(callback, groupMemberBeans);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void getFriendsProfile(List<String> userIDList, TUIValueCallback<List<FriendProfileBean>> callback) {
        V2TIMManager.getFriendshipManager().getFriendsInfo(userIDList, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                List<FriendProfileBean> friendProfileBeans = new ArrayList<>();
                for (V2TIMFriendInfoResult result : v2TIMFriendInfoResults) {
                    if (result.getResultCode() == 0) {
                        V2TIMFriendInfo friendInfo = result.getFriendInfo();
                        FriendProfileBean friendProfileBean = new FriendProfileBean();
                        friendProfileBean.setUserId(friendInfo.getUserID());
                        friendProfileBean.setFriendRemark(friendInfo.getFriendRemark());
                        V2TIMUserFullInfo userFullInfo = friendInfo.getUserProfile();
                        friendProfileBean.setFaceUrl(userFullInfo.getFaceUrl());
                        friendProfileBean.setNickName(userFullInfo.getNickName());
                        friendProfileBean.setSignature(userFullInfo.getSelfSignature());
                        friendProfileBean.setAllowType(userFullInfo.getAllowType());
                        friendProfileBean.setBirthday(userFullInfo.getBirthday());
                        friendProfileBeans.add(friendProfileBean);
                    }
                }
                TUIValueCallback.onSuccess(callback, friendProfileBeans);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void checkFriend(List<String> userIDList, TUIValueCallback<Map<String, Integer>> callback) {
        V2TIMManager.getFriendshipManager().checkFriend(
            userIDList, V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH, new V2TIMValueCallback<List<V2TIMFriendCheckResult>>() {
                @Override
                public void onSuccess(List<V2TIMFriendCheckResult> v2TIMFriendCheckResults) {
                    Map<String, Integer> resultMap = new HashMap<>();
                    for (V2TIMFriendCheckResult result : v2TIMFriendCheckResults) {
                        if (result.getResultCode() == 0) {
                            resultMap.put(result.getUserID(), result.getResultType());
                        }
                    }
                    TUIValueCallback.onSuccess(callback, resultMap);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIValueCallback.onError(callback, code, desc);
                }
            });
    }

    public void checkBlackList(String userID, TUIValueCallback<Boolean> callback) {
        V2TIMManager.getFriendshipManager().getBlackList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                for (V2TIMFriendInfo friendInfo : v2TIMFriendInfos) {
                    if (TextUtils.equals(friendInfo.getUserID(), userID)) {
                        TUIValueCallback.onSuccess(callback, true);
                        return;
                    }
                }
                TUIValueCallback.onSuccess(callback, false);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void modifyGroupName(String groupID, String name, TUICallback callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setGroupName(name);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void modifyGroupFaceUrl(String groupID, String faceUrl, TUICallback callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setFaceUrl(faceUrl);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void modifyGroupNotification(String groupID, String notification, TUICallback callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setNotification(notification);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void modifyGroupApproveOpt(String groupID, int approveOpt, TUICallback callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setGroupApproveOpt(approveOpt);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void modifyGroupAddOpt(String groupID, int addOpt, TUICallback callback) {
        V2TIMGroupInfo groupInfo = new V2TIMGroupInfo();
        groupInfo.setGroupID(groupID);
        groupInfo.setGroupAddOpt(addOpt);
        V2TIMManager.getGroupManager().setGroupInfo(groupInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void modifySelfNameCard(String groupID, String nameCard, TUICallback callback) {
        V2TIMGroupMemberFullInfo memberInfo = new V2TIMGroupMemberFullInfo();
        memberInfo.setUserID(V2TIMManager.getInstance().getLoginUser());
        memberInfo.setNameCard(nameCard);
        V2TIMManager.getGroupManager().setGroupMemberInfo(groupID, memberInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void pinConversation(String conversationId, boolean isPinned, TUICallback callBack) {
        V2TIMManager.getConversationManager().pinConversation(conversationId, isPinned, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callBack);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callBack, code, desc);
            }
        });
    }

    public void setConversationFold(String conversationID, boolean isFolded, TUICallback callback) {
        List<String> conversationList = Collections.singletonList(conversationID);
        long markType = V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD;
        V2TIMManager.getConversationManager().markConversation(
            conversationList, markType, isFolded, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
                @Override
                public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                    if (!v2TIMConversationOperationResults.isEmpty()) {
                        V2TIMConversationOperationResult result = v2TIMConversationOperationResults.get(0);
                        if (result.getResultCode() == 0) {
                            TUICallback.onSuccess(callback);
                        } else {
                            TUICallback.onError(callback, result.getResultCode(), result.getResultInfo());
                        }
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUICallback.onError(callback, code, desc);
                }
            });
    }

    public void checkoutConversationPinned(String chatID, boolean isGroup, TUIValueCallback<Boolean> callback) {
        String conversationID = TIMCommonUtil.getConversationIdByID(chatID, isGroup);
        V2TIMManager.getConversationManager().getConversation(conversationID, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                TUIValueCallback.onSuccess(callback, v2TIMConversation.isPinned());
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void getConversation(String conversationID, TUIValueCallback<V2TIMConversation> callback) {
        V2TIMManager.getConversationManager().getConversation(conversationID, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                TUIValueCallback.onSuccess(callback, v2TIMConversation);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void setGroupMessageRecvOpt(String groupID, int opt, TUICallback callback) {
        V2TIMManager.getMessageManager().setGroupReceiveMessageOpt(groupID, opt, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void getC2CReceiveMessageOpt(List<String> userIdList, TUIValueCallback<Map<String, Integer>> callback) {
        V2TIMManager.getMessageManager().getC2CReceiveMessageOpt(userIdList, new V2TIMValueCallback<List<V2TIMReceiveMessageOptInfo>>() {
            @Override
            public void onSuccess(List<V2TIMReceiveMessageOptInfo> v2TIMReceiveMessageOptInfos) {
                if (v2TIMReceiveMessageOptInfos == null || v2TIMReceiveMessageOptInfos.isEmpty()) {
                    return;
                }
                Map<String, Integer> resultMap = new HashMap<>();
                for (V2TIMReceiveMessageOptInfo v2TIMReceiveMessageOptInfo : v2TIMReceiveMessageOptInfos) {
                    resultMap.put(v2TIMReceiveMessageOptInfo.getUserID(), v2TIMReceiveMessageOptInfo.getC2CReceiveMessageOpt());
                }
                TUIValueCallback.onSuccess(callback, resultMap);
            }

            @Override
            public void onError(int code, String desc) {}
        });
    }

    public void setC2CReceiveMessageOpt(List<String> userIdList, int opt, TUICallback callback) {
        V2TIMManager.getMessageManager().setC2CReceiveMessageOpt(userIdList, opt, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void modifyFriendRemark(String userID, String remark, TUICallback callback) {
        V2TIMFriendInfo friendInfo = new V2TIMFriendInfo();
        friendInfo.setUserID(userID);
        friendInfo.setFriendRemark(remark);
        V2TIMManager.getFriendshipManager().setFriendInfo(friendInfo, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void removeFriends(List<String> userIDList, TUIValueCallback<Map<String, Integer>> callback) {
        V2TIMManager.getFriendshipManager().deleteFromFriendList(
            userIDList, V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
                @Override
                public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                    Map<String, Integer> resultMap = new HashMap<>();
                    for (V2TIMFriendOperationResult v2TIMFriendOperationResult : v2TIMFriendOperationResults) {
                        resultMap.put(v2TIMFriendOperationResult.getUserID(), v2TIMFriendOperationResult.getResultCode());
                    }
                    TUIValueCallback.onSuccess(callback, resultMap);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIValueCallback.onError(callback, code, desc);
                }
            });
    }

    public void deleteFromBlackList(List<String> idList, TUICallback callback) {
        V2TIMManager.getFriendshipManager().deleteFromBlackList(idList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void addToBlackList(List<String> idList, TUIValueCallback<Map<String, Integer>> callback) {
        V2TIMManager.getFriendshipManager().addToBlackList(idList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                Map<String, Integer> resultMap = new HashMap<>();
                for (V2TIMFriendOperationResult result : v2TIMFriendOperationResults) {
                    resultMap.put(result.getUserID(), result.getResultCode());
                }
                TUIValueCallback.onSuccess(callback, resultMap);
            }

            @Override
            public void onError(int code, String desc) {
                TUIValueCallback.onError(callback, code, desc);
            }
        });
    }

    public void quitGroup(String groupID, TUICallback callback) {
        V2TIMManager.getInstance().quitGroup(groupID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void dismissGroup(String groupID, TUICallback callback) {
        V2TIMManager.getInstance().dismissGroup(groupID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void clearHistoryMessage(String chatID, boolean isGroup, TUICallback callback) {
        V2TIMCallback v2TIMCallback = new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        };
        if (isGroup) {
            V2TIMManager.getMessageManager().clearGroupHistoryMessage(chatID, v2TIMCallback);
        } else {
            V2TIMManager.getMessageManager().clearC2CHistoryMessage(chatID, v2TIMCallback);
        }
    }
}
