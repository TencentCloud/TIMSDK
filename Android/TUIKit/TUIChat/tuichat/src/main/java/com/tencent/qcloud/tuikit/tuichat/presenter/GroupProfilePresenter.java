package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonUtil;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupProfileListener;
import com.tencent.qcloud.tuikit.tuichat.model.ProfileProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupProfilePresenter {
    private static final String TAG = "GroupProfilePresenter";

    private final ProfileProvider provider = new ProfileProvider();
    private GroupProfileListener groupProfileListener;
    private GroupProfileBean groupProfileBean;
    private V2TIMGroupListener groupListener;

    public GroupProfilePresenter() {
    }

    public void registerGroupListener() {
        groupListener = new V2TIMGroupListener() {
            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                if (groupProfileBean != null && TextUtils.equals(groupProfileBean.getGroupID(), groupID)) {
                    for (V2TIMGroupChangeInfo changeInfo : changeInfos) {
                        if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                            groupProfileBean.setGroupName(changeInfo.getValue());
                        } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                            groupProfileBean.setGroupFaceUrl(changeInfo.getValue());
                        } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                            groupProfileBean.setNotification(changeInfo.getValue());
                        } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT) {
                            groupProfileBean.setApproveOpt(changeInfo.getIntValue());
                        } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT) {
                            groupProfileBean.setAddOpt(changeInfo.getIntValue());
                        } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_RECEIVE_MESSAGE_OPT) {
                            groupProfileBean.setRecvOpt(changeInfo.getIntValue());
                        }
                        onGroupChanged(changeInfo);
                    }
                }
            }

            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                onMemberCountChanged(groupID);
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                onMemberCountChanged(groupID);
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                onMemberCountChanged(groupID);
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                onMemberCountChanged(groupID);
            }
        };
        V2TIMManager.getInstance().addGroupListener(groupListener);
    }

    public void unregisterGroupListener() {
        V2TIMManager.getInstance().removeGroupListener(groupListener);
    }

    private void onMemberCountChanged(String groupID) {
        if (groupProfileBean != null && TextUtils.equals(groupProfileBean.getGroupID(), groupID)) {
            provider.getGroupsProfile(groupID, new TUIValueCallback<GroupProfileBean>() {
                @Override
                public void onSuccess(GroupProfileBean object) {
                    groupProfileBean.setMemberCount(object.getMemberCount());
                    if (groupProfileListener != null) {
                        groupProfileListener.onGroupMemberCountChanged(object.getMemberCount());
                    }
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    TUIChatLog.e(TAG, "onMemberCountChanged getGroupsProfile errorCode:" + errorCode + " errorMessage:" + errorMessage);
                }
            });
        }
    }

    private void onGroupChanged(V2TIMGroupChangeInfo changeInfo) {
        if (groupProfileListener != null) {
            groupProfileListener.onGroupProfileChanged(changeInfo);
        }
    }

    public void setGroupProfileListener(GroupProfileListener groupProfileListener) {
        this.groupProfileListener = groupProfileListener;
    }

    public void loadGroupProfile(String groupID) {
        provider.getGroupsProfile(groupID, new TUIValueCallback<GroupProfileBean>() {
            @Override
            public void onSuccess(GroupProfileBean object) {
                groupProfileBean = object;
                if (groupProfileListener != null) {
                    groupProfileListener.onGroupProfileLoaded(object);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "loadGroupProfile errorCode:" + errorCode + " errorMessage:" + errorMessage);
            }
        });

        getConversation(groupID, new TUIValueCallback<V2TIMConversation>() {
            @Override
            public void onSuccess(V2TIMConversation object) {
                if (groupProfileListener != null) {
                    boolean isFolded = false;
                    List<Long> markList = object.getMarkList();
                    if (markList != null && markList.contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD)) {
                        isFolded = true;
                    }
                    groupProfileListener.onConversationCheckResult(object.isPinned(), isFolded);

                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {

            }
        });
    }

    public void loadSelfInfo(String groupID) {
        List<String> userIDList = Collections.singletonList(V2TIMManager.getInstance().getLoginUser());
        provider.getGroupMembersProfile(groupID, userIDList, new TUIValueCallback<List<GroupMemberBean>>() {
            @Override
            public void onSuccess(List<GroupMemberBean> object) {
                if (!object.isEmpty()) {
                    if (groupProfileListener != null) {
                        groupProfileListener.onSelfInfoLoaded(object.get(0));
                    }
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "loadSelfInfo errorCode:" + errorCode + " errorMessage:" + errorMessage);
            }
        });
    }

    public void getConversation(String groupID, TUIValueCallback<V2TIMConversation> callback)  {
        String conversationID = TIMCommonUtil.getConversationIdByID(groupID, true);
        provider.getConversation(conversationID, callback);
    }

    public void setMessageRecvOpt(String groupID, boolean isRecv, TUICallback callback) {
        int opt = isRecv ? V2TIMMessage.V2TIM_RECEIVE_MESSAGE : V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
        provider.setGroupMessageRecvOpt(groupID, opt, callback);
    }

    public void setGroupFold(String groupID, boolean isFolded, TUICallback callback) {
        String conversationID = TIMCommonUtil.getConversationIdByID(groupID, true);
        provider.setConversationFold(conversationID, isFolded, callback);
    }

    public void modifyGroupName(final String groupID, final String name) {
        provider.modifyGroupName(groupID, name, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errCode, String errMsg) {}
        });
    }

    public void modifyGroupNotification(final String groupID, final String notification, TUICallback callback) {
        provider.modifyGroupNotification(groupID, notification, new TUICallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int errCode, String errMsg) {
                TUICallback.onError(callback, errCode, errMsg);
            }
        });
    }

    public void modifyGroupFaceUrl(final String groupID, final String faceUrl) {
        provider.modifyGroupFaceUrl(groupID, faceUrl, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errCode, String errMsg) {}
        });
    }

    public void modifyGroupApproveOpt(final String groupID, final int approveOpt) {
        provider.modifyGroupApproveOpt(groupID, approveOpt, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errCode, String errMsg) {}
        });
    }

    public void modifyGroupAddOpt(final String groupID, final int addOpt) {
        provider.modifyGroupAddOpt(groupID, addOpt, new TUICallback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int errCode, String errMsg) {}
        });
    }

    public void modifySelfNameCard(String groupID, String nameCard) {
        provider.modifySelfNameCard(groupID, nameCard, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void pinConversation(String chatID, boolean isPin) {
        String conversationId = TIMCommonUtil.getConversationIdByID(chatID, true);
        provider.pinConversation(conversationId, isPin, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void clearHistoryMessage(String groupID) {
        Map<String, Object> hashMap = new HashMap<>();
        hashMap.put(TUIConstants.TUIContact.GROUP_ID, groupID);
        TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_GROUP_MESSAGE, hashMap);
        provider.clearHistoryMessage(groupID, true, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void quitGroup(String groupID, TUICallback callback) {
        provider.quitGroup(groupID, new TUICallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUICallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public void dismissGroup(String groupID, TUICallback callback) {
        provider.dismissGroup(groupID, new TUICallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUICallback.onError(callback, errorCode, errorMessage);
            }
        });
    }
}
