package com.tencent.qcloud.uikit.business.chat.group.model;

import android.text.TextUtils;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMGroupAddOpt;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupSystemElem;
import com.tencent.imsdk.TIMGroupSystemElemType;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMGroupTipsElemGroupInfo;
import com.tencent.imsdk.TIMGroupTipsGroupInfoType;
import com.tencent.imsdk.TIMGroupTipsType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageListener;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfo;
import com.tencent.imsdk.ext.group.TIMGroupManagerExt;
import com.tencent.imsdk.ext.group.TIMGroupMemberResult;
import com.tencent.imsdk.ext.group.TIMGroupPendencyGetParam;
import com.tencent.imsdk.ext.group.TIMGroupPendencyHandledStatus;
import com.tencent.imsdk.ext.group.TIMGroupPendencyItem;
import com.tencent.imsdk.ext.group.TIMGroupPendencyListGetSucc;
import com.tencent.imsdk.ext.message.TIMConversationExt;
import com.tencent.imsdk.ext.message.TIMMessageExt;
import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.imsdk.log.QLog;
import com.tencent.qcloud.uikit.business.chat.model.BaseChatInfo;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfoUtil;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.operation.UIKitMessageRevokedManager;
import com.tencent.qcloud.uikit.operation.message.UIKitRequest;
import com.tencent.qcloud.uikit.operation.message.UIKitRequestDispatcher;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class GroupChatManager implements TIMMessageListener, UIKitMessageRevokedManager.MessageRevokeHandler {
    private static final String TAG = "GroupChatManager";
    private static final int MSG_PAGE_COUNT = 10;
    private static GroupChatManager instance = new GroupChatManager();
    private GroupChatProvider mCurrentProvider;
    private TIMConversation mCurrentConversation;
    private TIMConversationExt mCurrentConversationExt;
    private GroupChatInfo mCurrentChatInfo;
    private List<GroupApplyInfo> mCurrentApplies = new ArrayList<>();
    private List<GroupMemberInfo> mCurrentGroupMembers = new ArrayList<>();
    private GroupMemberInfo mSelfInfo;
    private long pendencyTime;
    private boolean hasMore;
    private GroupNotifyHandler mGroupHandler;
    private boolean sending, mLoading;


    public static GroupChatManager getInstance() {
        return instance;
    }


    private GroupChatManager() {

    }

    public void init() {
        destroyGroupChat();
        TIMManager.getInstance().addMessageListener(instance);
        UIKitMessageRevokedManager.getInstance().addHandler(this);
    }


    public void getGroupChatInfo(final String peer, final IUIKitCallBack callBack) {
        getGroupRemote(peer, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                final GroupChatInfo chatInfo = TIMGroupDetailInfo2GroupChatInfo((TIMGroupDetailInfo) data);
                UIKitRequest topRequest = new UIKitRequest();
                topRequest.setAction(UIKitRequestDispatcher.SESSION_ACTION_GET_TOP);
                topRequest.setRequest(peer);
                topRequest.setModel(UIKitRequestDispatcher.MODEL_SESSION);

                Object res = UIKitRequestDispatcher.getInstance().dispatchRequest(topRequest);
                if (res == null)
                    return;
                boolean isTop = (boolean) res;
                chatInfo.setTopChat(isTop);
                if (chatInfo != null) {
                    loadGroupMembersRemote(peer, new IUIKitCallBack() {
                        @Override
                        public void onSuccess(Object data) {
                            setChatInfo(chatInfo);
                            mCurrentGroupMembers = (List<GroupMemberInfo>) data;
                            loadGroupMembersDetailRemote(0);
                            mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
                            callBack.onSuccess(chatInfo);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            QLog.e(TAG, "loadGroupMembersRemote failed, code: " + errCode + "|desc: " + errMsg);
                        }
                    });
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                QLog.e(TAG, "getGroupChatInfo failed, code: " + errCode + "|desc: " + errMsg);
            }
        });


    }


    public void setChatInfo(BaseChatInfo info) {
        mCurrentChatInfo = (GroupChatInfo) info;
        mCurrentConversation = TIMManager.getInstance().getConversation(info.getType(), info.getPeer());
        mCurrentConversationExt = new TIMConversationExt(mCurrentConversation);
        mCurrentProvider = new GroupChatProvider();
        mCurrentApplies.clear();
        mCurrentGroupMembers.clear();
        mSelfInfo = null;
        hasMore = true;
        sending = false;
    }

    public GroupChatInfo getCurrentChatInfo() {
        return mCurrentChatInfo;
    }

    public synchronized void loadChatMessages(MessageInfo lastMessage, final IUIKitCallBack callBack) {
        if (mCurrentChatInfo == null)
            return;
        if (mLoading)
            return;
        mLoading = true;
        if (!hasMore) {
            mCurrentProvider.addMessageInfo(null);
            callBack.onSuccess(null);
            mLoading = false;
            return;
        }

        TIMMessage lastTIMMsg = null;
        if (lastMessage == null) {
            mCurrentProvider.clear();
        } else {
            lastTIMMsg = lastMessage.getTIMMessage();
        }
        final int unread = (int) mCurrentConversationExt.getUnreadMessageNum();
        mCurrentConversationExt.getMessage(unread > MSG_PAGE_COUNT ? unread : MSG_PAGE_COUNT
                , lastTIMMsg, new TIMValueCallBack<List<TIMMessage>>() {
                    @Override
                    public void onError(int code, String desc) {
                        callBack.onError(TAG, code, desc);
                        mLoading = false;
                        QLog.e(TAG, "group getMessage failed, code: " + code + "|desc: " + desc);
                    }

                    @Override
                    public void onSuccess(List<TIMMessage> timMessages) {
                        mLoading = false;
                        if (mCurrentProvider == null)
                            return;
                        if (unread > 0) {
                            mCurrentConversationExt.setReadMessage(null, new TIMCallBack() {
                                @Override
                                public void onError(int code, String desc) {
                                    QLog.e(TAG, "setReadMessage failed, code: " + code + "|desc: " + desc);
                                }

                                @Override
                                public void onSuccess() {
                                    QLog.d(TAG, "setReadMessage succ");
                                }
                            });
                        }
                        if (timMessages.size() < MSG_PAGE_COUNT)
                            hasMore = false;

                        ArrayList<TIMMessage> messages = new ArrayList<>(timMessages);
                        Collections.reverse(messages);
                        mCurrentProvider.addMessageInfos(MessageInfoUtil.TIMMessages2MessageInfos(messages, true), true);
                        callBack.onSuccess(mCurrentProvider);
                    }
                });

    }


    public synchronized void sendGroupMessage(final MessageInfo message, final IUIKitCallBack callBack) {

        if (mCurrentConversation == null || sending)
            return;
        sending = true;
        message.setPeer(mCurrentChatInfo.getPeer());
        message.setSelf(true);
        message.setRead(true);
        message.setGroup(true);
        if (mSelfInfo != null && mSelfInfo.getDetail() != null && !TextUtils.isEmpty(mSelfInfo.getDetail().getNameCard())) {
            message.setFromUser(mSelfInfo.getDetail().getNameCard());
        } else {
            message.setFromUser(TIMManager.getInstance().getLoginUser());
        }

        //消息先展示，通过状态来确认发送是否成功
        if (message.getMsgType() < MessageInfo.MSG_TYPE_TIPS) {
            message.setStatus(MessageInfo.MSG_STATUS_SENDING);
            mCurrentProvider.addMessageInfo(message);
            callBack.onSuccess(mCurrentProvider);

        }
        new Thread() {
            @Override
            public void run() {
                mCurrentConversation.sendMessage(message.getTIMMessage(), new TIMValueCallBack<TIMMessage>() {
                    @Override
                    public void onError(final int code, final String desc) {
                        QLog.i(TAG, "sendGroupMessage fail:" + code + "=" + desc);
                        sending = false;
                        if (mCurrentProvider == null)
                            return;
                        if (callBack != null)
                            callBack.onError(TAG, code, desc);
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_FAIL);
                        mCurrentProvider.updateMessageInfo(message);

                    }

                    @Override
                    public void onSuccess(TIMMessage timMessage) {
                        QLog.i(TAG, "sendGroupMessage onSuccess");
                        sending = false;
                        if (mCurrentProvider == null)
                            return;
                        message.setStatus(MessageInfo.MSG_STATUS_SEND_SUCCESS);
                        message.setMsgId(timMessage.getMsgId());
                        if (callBack != null)
                            callBack.onSuccess(mCurrentProvider);
                        mCurrentProvider.updateMessageInfo(message);

                    }
                });
            }
        }.start();

    }

    private void sendTipsMessage(TIMConversation conversation, MessageInfo message, final IUIKitCallBack callBack) {
        message.setSelf(true);
        message.setRead(true);
        conversation.sendMessage(message.getTIMMessage(), new TIMValueCallBack<TIMMessage>() {
            @Override
            public void onError(final int code, final String desc) {
                QLog.i(TAG, "sendTipsMessage fail:" + code + "=" + desc);
                if (callBack != null)
                    callBack.onError(TAG, code, desc);

            }

            @Override
            public void onSuccess(TIMMessage timMessage) {
                QLog.i(TAG, "sendTipsMessage onSuccess");
                if (callBack != null)
                    callBack.onSuccess(mCurrentProvider);
            }
        });
    }


    public void deleteMessage(int position, MessageInfo messageInfo) {
        TIMMessageExt ext = new TIMMessageExt(messageInfo.getTIMMessage());
        if (ext.remove()) {
            if (mCurrentProvider == null)
                return;
            mCurrentProvider.remove(position);
        }
    }


    public void revokeMessage(final int position, final MessageInfo messageInfo) {
        mCurrentConversationExt.revokeMessage(messageInfo.getTIMMessage(), new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                UIUtils.toastLongMessage("撤销失败:" + code + "=" + desc);
            }

            @Override
            public void onSuccess() {
                if (mCurrentProvider == null)
                    return;
                mCurrentProvider.updateMessageRevoked(messageInfo.getMsgId());
            }
        });
    }


    public void createGroupChat(final GroupChatInfo chatInfo, final IUIKitCallBack callBack) {
        final TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam(chatInfo.getGroupType(), chatInfo.getGroupName());
        if (chatInfo.getJoinType() > -1)
            param.setAddOption(TIMGroupAddOpt.values()[chatInfo.getJoinType()]);
        param.setIntroduction(chatInfo.getNotice());
        List<TIMGroupMemberInfo> infos = new ArrayList<>();
        for (int i = 0; i < chatInfo.getMemberDetails().size(); i++) {
            TIMGroupMemberInfo memberInfo = new TIMGroupMemberInfo(chatInfo.getMemberDetails().get(i).getAccount());
            infos.add(memberInfo);
        }
        param.setMembers(infos);
        TIMGroupManager.getInstance().createGroup(param, new TIMValueCallBack<String>() {
            @Override
            public void onError(final int code, final String desc) {
                callBack.onError(TAG, code, desc);
                QLog.e(TAG, "createGroup failed, code: " + code + "|desc: " + desc);
            }

            @Override
            public void onSuccess(String s) {
                chatInfo.setPeer(s);
                String message = TIMManager.getInstance().getLoginUser() + "创建群组";
                final MessageInfo createTips = MessageInfoUtil.buildGroupCustomMessage(MessageInfoUtil.GROUP_CREATE, message);
                createTips.setPeer(s);
                TIMConversation conversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, s);
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                sendTipsMessage(conversation, createTips, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        callBack.onSuccess(createTips);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        QLog.e(TAG, "sendTipsMessage failed, code: " + errCode + "|desc: " + errMsg);
                    }
                });
            }
        });

    }

    public void deleteGroup(String groupId, final IUIKitCallBack callBack) {
        if (groupId == null)
            groupId = mCurrentChatInfo.getPeer();

        TIMGroupManager.getInstance().deleteGroup(groupId, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                callBack.onError(TAG, code, desc);
                QLog.e(TAG, "deleteGroup failed, code: " + code + "|desc: " + desc);

            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
                mGroupHandler.onGroupForceExit();
                destroyGroupChat();
            }
        });

    }


    public void getGroupRemote(String groupId, final IUIKitCallBack callBack) {
        List<String> groupList = new ArrayList<>();
        groupList.add(groupId);
        TIMGroupManagerExt.getInstance().getGroupPublicInfo(groupList, new TIMValueCallBack<List<TIMGroupDetailInfo>>() {
            @Override
            public void onError(final int code, final String desc) {
                QLog.e(TAG, "getGroupPublicInfo failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(final List<TIMGroupDetailInfo> timGroupDetailInfos) {
                if (timGroupDetailInfos.size() > 0) {
                    TIMGroupDetailInfo info = timGroupDetailInfos.get(0);
                    QLog.i(TAG, info.toString());
                    callBack.onSuccess(info);
                }
            }
        });
    }

    public void loadGroupMembersRemote(String groupId, final IUIKitCallBack callBack) {
        TIMGroupManagerExt.getInstance().getGroupMembers(groupId, new TIMValueCallBack<List<TIMGroupMemberInfo>>() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "getGroupMembers failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<TIMGroupMemberInfo> timGroupMemberInfos) {
                List<GroupMemberInfo> members = new ArrayList<>();
                for (int i = 0; i < timGroupMemberInfos.size(); i++) {
                    members.add(TIMGroupMember2GroupMember(timGroupMemberInfos.get(i)));
                }
                callBack.onSuccess(members);
            }
        });
    }

    public void loadGroupMembersDetailRemote(final int begin) {
        final ArrayList memberIds = new ArrayList();
        final int end;
        if (begin + 100 > mCurrentGroupMembers.size()) {
            end = mCurrentGroupMembers.size();
        } else {
            end = begin + 100;
        }
        for (int i = begin; i < end; i++) {
            memberIds.add(mCurrentGroupMembers.get(i).getAccount());
        }
        //final int end = begin + memberIds.size();

        TIMGroupManagerExt.getInstance().getGroupMembersInfo(mCurrentChatInfo.getPeer(), memberIds, new TIMValueCallBack<List<TIMGroupMemberInfo>>() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "getGroupMembersInfo failed, code: " + code + "|desc: " + desc);

            }

            @Override
            public void onSuccess(List<TIMGroupMemberInfo> timGroupMemberInfos) {
                for (int i = begin; i < end; i++) {
                    GroupMemberInfo memberInfo = mCurrentGroupMembers.get(i);
                    for (int j = 0; j < timGroupMemberInfos.size(); j++) {
                        TIMGroupMemberInfo detail = timGroupMemberInfos.get(j);
                        if (memberInfo.getAccount().equals(detail.getUser())) {
                            memberInfo.setDetail(detail);
                            timGroupMemberInfos.remove(j);
                            break;
                        }
                    }
                }

                if (end < mCurrentGroupMembers.size()) {
                    loadGroupMembersDetailRemote(end);
                }
            }
        });
    }

    public List<GroupMemberInfo> getCurrentGroupMembers() {
        return mCurrentGroupMembers;
    }

    public GroupMemberInfo getSelfGroupInfo() {
        if (mSelfInfo != null)
            return mSelfInfo;
        for (int i = 0; i < mCurrentGroupMembers.size(); i++) {
            GroupMemberInfo memberInfo = mCurrentGroupMembers.get(i);
            if (memberInfo.getAccount().equals(TIMManager.getInstance().getLoginUser())) {
                mSelfInfo = memberInfo;
                return memberInfo;
            }

        }
        return null;
    }

    public void modifyGroupInfo(final Object value, final int type, final IUIKitCallBack callBack) {

        TIMGroupManagerExt.ModifyGroupInfoParam param = new TIMGroupManagerExt.ModifyGroupInfoParam(mCurrentChatInfo.getPeer());
        if (type == GroupInfoUtils.MODIFY_GROUP_NAME) {
            param.setGroupName(value.toString());
        } else if (type == GroupInfoUtils.MODIFY_GROUP_NOTICE) {
            param.setNotification(value.toString());
        } else if (type == GroupInfoUtils.MODIFY_GROUP_JOIN_TYPE) {
            param.setAddOption(TIMGroupAddOpt.values()[(Integer) value]);
        }


        TIMGroupManagerExt.getInstance().modifyGroupInfo(param, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                QLog.i(TAG, "modifyGroupInfo faild tyep| value| code| desc " + value + ":" + type + ":" + code + ":" + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                if (type == GroupInfoUtils.MODIFY_GROUP_NAME) {
                    mCurrentChatInfo.setGroupName(value.toString());
                    if (mGroupHandler != null)
                        mGroupHandler.onGroupNameChanged(value.toString());
                } else if (type == GroupInfoUtils.MODIFY_GROUP_NOTICE) {
                    mCurrentChatInfo.setNotice(value.toString());
                } else if (type == GroupInfoUtils.MODIFY_GROUP_NOTICE) {
                    mCurrentChatInfo.setJoinType((Integer) value);
                }
                callBack.onSuccess(null);
            }
        });
    }


    public void modifyGroupNickname(final String nickname, int type, final IUIKitCallBack callBack) {
        TIMGroupManagerExt.ModifyMemberInfoParam param = new TIMGroupManagerExt.ModifyMemberInfoParam(mCurrentChatInfo.getPeer(), TIMManager.getInstance().getLoginUser());
        if (type == GroupInfoUtils.MODIFY_MEMBER_NAME) {
            param.setNameCard(nickname);
        }
        TIMGroupManagerExt.getInstance().modifyMemberInfo(param, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                callBack.onError(TAG, code, desc);
                UIUtils.toastLongMessage("modifyGroupNickname fail: " + code + "=" + desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
                if (mSelfInfo != null)
                    mSelfInfo.getDetail().setNameCard(nickname);
            }
        });
    }

    public void setTopSession(boolean flag) {
        UIKitRequest request = new UIKitRequest();
        request.setModel(UIKitRequestDispatcher.MODEL_SESSION);
        request.setAction(UIKitRequestDispatcher.SESSION_ACTION_SET_TOP);
        Map requestData = new HashMap();
        requestData.put("peer", mCurrentChatInfo.getPeer());
        requestData.put("topFlag", flag);
        request.setRequest(requestData);
        UIKitRequestDispatcher.getInstance().dispatchRequest(request);
    }

    public void quiteGroup(final IUIKitCallBack callBack) {
        TIMGroupManager.getInstance().quitGroup(mCurrentChatInfo.getPeer(), new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "quiteGroup failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                UIKitRequest request = new UIKitRequest();
                request.setModel(UIKitRequestDispatcher.MODEL_SESSION);
                request.setAction(UIKitRequestDispatcher.SESSION_DELETE);
                request.setRequest(mCurrentChatInfo.getPeer());
                UIKitRequestDispatcher.getInstance().dispatchRequest(request);
                callBack.onSuccess(null);
                mGroupHandler.onGroupForceExit();
                destroyGroupChat();

            }
        });
    }

    public void applyJoinGroup(final String groupId, final String reason, final IUIKitCallBack callBack) {

        getGroupRemote(groupId, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                final TIMGroupDetailInfo groupDetailInfo = (TIMGroupDetailInfo) data;

                TIMGroupManager.getInstance().applyJoinGroup(groupId, reason, new TIMCallBack() {
                    @Override
                    public void onError(final int code, final String desc) {
                        QLog.e(TAG, "applyJoinGroup failed, code: " + code + "|desc: " + desc);
                        callBack.onError(TAG, code, desc);
                    }

                    @Override
                    public void onSuccess() {
                        callBack.onSuccess(groupDetailInfo.getAddOption());

                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                callBack.onError(module, errCode, errMsg);
            }
        });


    }


    public void inviteGroupMembers(List<String> addMembers, final IUIKitCallBack callBack) {

        TIMGroupManagerExt.getInstance().inviteGroupMember(mCurrentChatInfo.getPeer(), addMembers, new TIMValueCallBack<List<TIMGroupMemberResult>>() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "addGroupMembers failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<TIMGroupMemberResult> timGroupMemberResults) {
                final List<String> adds = new ArrayList<>();
                if (timGroupMemberResults.size() > 0) {
                    for (int i = 0; i < timGroupMemberResults.size(); i++) {
                        TIMGroupMemberResult res = timGroupMemberResults.get(i);
                        if (res.getResult() == 3) {
                            callBack.onSuccess("邀请成功，等待对方接受");
                            return;
                        }
                        if (res.getResult() > 0)
                            adds.add(res.getUser());
                    }
                }
                if (adds.size() > 0) {
                    loadGroupMembersRemote(mCurrentChatInfo.getPeer(), new IUIKitCallBack() {
                        @Override
                        public void onSuccess(Object data) {
                            mCurrentGroupMembers = (List<GroupMemberInfo>) data;
                            loadGroupMembersDetailRemote(0);
                            mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
                            callBack.onSuccess(adds);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            callBack.onError(TAG, errCode, errMsg);
                        }
                    });

                }

            }
        });
    }

    public void removeGroupMembers(List<GroupMemberInfo> delMembers, final IUIKitCallBack callBack) {
        if (delMembers == null)
            return;
        List<String> members = new ArrayList<>();
        for (int i = 0; i < delMembers.size(); i++) {
            members.add(delMembers.get(i).getAccount());
        }

        TIMGroupManagerExt.DeleteMemberParam param = new TIMGroupManagerExt.DeleteMemberParam(mCurrentChatInfo.getPeer(), members);
        TIMGroupManagerExt.getInstance().deleteGroupMember(param, new TIMValueCallBack<List<TIMGroupMemberResult>>() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "removeGroupMembers failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<TIMGroupMemberResult> timGroupMemberResults) {
                List<String> dels = new ArrayList<>();
                for (int i = 0; i < timGroupMemberResults.size(); i++) {
                    TIMGroupMemberResult res = timGroupMemberResults.get(i);
                    if (res.getResult() == 1) {
                        dels.add(res.getUser());
                    }
                }

                for (int i = 0; i < dels.size(); i++) {
                    for (int j = 0; j < mCurrentGroupMembers.size(); j++) {
                        if (mCurrentGroupMembers.get(j).getAccount().equals(dels.get(i))) {
                            mCurrentGroupMembers.remove(j);
                            break;
                        }
                    }
                }
                mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
                callBack.onSuccess(dels);
            }
        });
    }


    public List<GroupApplyInfo> getGroupApplies(String groupId) {
        if (groupId == null) {
            if (mCurrentChatInfo == null)
                return null;
            groupId = mCurrentChatInfo.getPeer();
        }
        List<GroupApplyInfo> applyInfos = new ArrayList<>();
        for (int i = 0; i < mCurrentApplies.size(); i++) {
            GroupApplyInfo applyInfo = mCurrentApplies.get(i);
            if (groupId.equals(applyInfo.getPendencyItem().getGroupId()) && applyInfo.getPendencyItem().getHandledStatus() == TIMGroupPendencyHandledStatus.NOT_HANDLED)
                applyInfos.add(applyInfo);
        }
        return applyInfos;
    }

    public void loadRemoteApplayInfos(final IUIKitCallBack callBack) {
        TIMGroupPendencyGetParam param = new TIMGroupPendencyGetParam();
        param.setTimestamp(pendencyTime);
        TIMGroupManagerExt.getInstance().getGroupPendencyList(param, new TIMValueCallBack<TIMGroupPendencyListGetSucc>() {
            @Override
            public void onError(final int code, final String desc) {
                QLog.e(TAG, "getGroupPendencyList failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(final TIMGroupPendencyListGetSucc timGroupPendencyListGetSucc) {
                pendencyTime = timGroupPendencyListGetSucc.getMeta().getNextStartTimestamp();
                List<TIMGroupPendencyItem> pendencies = timGroupPendencyListGetSucc.getPendencies();
                for (int i = 0; i < pendencies.size(); i++) {
                    System.out.println("!!!!!!!!!!!!!!!!!" + new String(pendencies.get(i).getAuth()));
                    GroupApplyInfo info = new GroupApplyInfo(pendencies.get(i));
                    info.setStatus(0);
                    mCurrentApplies.add(info);
                }
                if (mCurrentApplies.size() > 0)
                    callBack.onSuccess(mCurrentApplies.size());


            }
        });
    }


    public void acceptApply(GroupApplyInfo item, final IUIKitCallBack callBack) {
        item.getPendencyItem().accept("", new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "acceptApply failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
            }
        });

    }

    public void refuseApply(GroupApplyInfo item, final IUIKitCallBack callBack) {
        item.getPendencyItem().refuse("", new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "refuseApply failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
            }
        });
    }

    @Override
    public boolean onNewMessages(List<TIMMessage> msgs) {
        for (TIMMessage msg : msgs) {
            TIMConversation conversation = msg.getConversation();
            TIMConversationType type = conversation.getType();
            if (type == TIMConversationType.Group) {
                receiveMessageHandle(conversation, msg);
                QLog.i(TAG, "onNewMessages::: " + msg);
            }
            if (type == TIMConversationType.System) {
                TIMElem ele = msg.getElement(0);
                TIMElemType eleType = ele.getType();
                if (eleType == TIMElemType.GroupSystem) {
                    QLog.i(TAG, "onNewMessages::: " + msg);
                    TIMGroupSystemElem groupSysEle = (TIMGroupSystemElem) ele;
                    groupSystMsgHandle(groupSysEle);
                }
            }
        }
        return false;
    }

    private void receiveMessageHandle(final TIMConversation conversation, final TIMMessage msg) {
        if (conversation == null || conversation.getPeer() == null || mCurrentChatInfo == null)
            return;
        //图片，视频类的消息先把快照下载了再通知用户
         /*
        现在用占位图，直接通知用户了
        if (MessageInfoUtil.checkMessage(msg, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                QLog.e(TAG, "group checkMessage failed, code: " + code + "|desc: " + desc);
            }

            @Override
            public void onSuccess() {
                executeMessage(conversation, msg);
            }
        })) {
            return;
        }
        */
        executeMessage(conversation, msg);
    }

    private void executeMessage(TIMConversation conversation, TIMMessage msg) {
        final MessageInfo msgInfo = MessageInfoUtil.TIMMessage2MessageInfo(msg, true);
        if (msgInfo != null && mCurrentConversation != null && conversation.getPeer().endsWith(mCurrentConversation.getPeer())) {
            mCurrentProvider.addMessageInfo(msgInfo);
            msgInfo.setRead(true);
            mCurrentConversationExt.setReadMessage(msg, new TIMCallBack() {
                @Override
                public void onError(int code, String desc) {
                    QLog.e(TAG, "setReadMessage failed, code: " + code + "|desc: " + desc);
                }

                @Override
                public void onSuccess() {
                    QLog.d(TAG, "setReadMessage succ");
                }
            });
            if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_JOIN) {
                for (int i = 0; i < msg.getElementCount(); i++) {
                    TIMGroupTipsElem groupTips = (TIMGroupTipsElem) msg.getElement(i);
                    Map<String, TIMGroupMemberInfo> changeInfos = groupTips.getChangedGroupMemberInfo();
                    if (changeInfos.size() > 0) {
                        Iterator<String> keys = changeInfos.keySet().iterator();
                        while (keys.hasNext()) {
                            mCurrentGroupMembers.add(TIMGroupMember2GroupMember(changeInfos.get(keys.next())));
                        }
                    } else {
                        mCurrentGroupMembers.add(TIMGroupMember2GroupMember(groupTips.getOpGroupMemberInfo()));
                    }
                }
                mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
            } else if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_QUITE || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_KICK) {
                for (int i = 0; i < msg.getElementCount(); i++) {

                    TIMGroupTipsElem groupTips = (TIMGroupTipsElem) msg.getElement(i);
                    Map<String, TIMGroupMemberInfo> changeInfos = groupTips.getChangedGroupMemberInfo();
                    if (changeInfos.size() > 0) {
                        Iterator<String> keys = changeInfos.keySet().iterator();
                        while (keys.hasNext()) {
                            String id = keys.next();
                            for (int j = 0; j < mCurrentGroupMembers.size(); j++) {
                                if (mCurrentGroupMembers.get(i).getAccount().equals(id)) {
                                    mCurrentGroupMembers.remove(i);
                                    break;
                                }
                            }
                        }
                    } else {
                        TIMGroupMemberInfo memberInfo = groupTips.getOpGroupMemberInfo();
                        for (int j = 0; j < mCurrentGroupMembers.size(); j++) {
                            if (mCurrentGroupMembers.get(i).getAccount().equals(memberInfo.getUser())) {
                                mCurrentGroupMembers.remove(i);
                                break;
                            }
                        }
                    }
                }
                mCurrentChatInfo.setMemberDetails(mCurrentGroupMembers);
            } else if (msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NAME || msgInfo.getMsgType() == MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE) {
                TIMGroupTipsElem groupTips = (TIMGroupTipsElem) msg.getElement(0);
                List<TIMGroupTipsElemGroupInfo> modifyList = groupTips.getGroupInfoList();
                if (modifyList.size() > 0) {
                    TIMGroupTipsElemGroupInfo modifyInfo = modifyList.get(0);
                    TIMGroupTipsGroupInfoType modifyType = modifyInfo.getType();
                    if (modifyType == TIMGroupTipsGroupInfoType.ModifyName) {
                        mCurrentChatInfo.setGroupName(modifyInfo.getContent());
                        mGroupHandler.onGroupNameChanged(modifyInfo.getContent());
                    } else if (modifyType == TIMGroupTipsGroupInfoType.ModifyNotification) {
                        mCurrentChatInfo.setNotice(modifyInfo.getContent());
                    }
                }
            }

        }
    }


    //群系统消息处理，不需要显示信息的
    private void groupSystMsgHandle(TIMGroupSystemElem groupSysEle) {
        if (mCurrentChatInfo == null)
            return;
        TIMGroupSystemElemType type = groupSysEle.getSubtype();
        if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_ADD_GROUP_ACCEPT_TYPE) {
            UIUtils.toastLongMessage("您已被同意加入群：" + groupSysEle.getGroupId());
        } else if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_ADD_GROUP_REFUSE_TYPE) {
            UIUtils.toastLongMessage("您被拒绝加入群：" + groupSysEle.getGroupId());
        } else if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE) {
            UIUtils.toastLongMessage("您已被踢出群：" + groupSysEle.getGroupId());
            if (mCurrentChatInfo != null && groupSysEle.getGroupId().equals(mCurrentChatInfo.getPeer())) {
                if (mGroupHandler != null)
                    mGroupHandler.onGroupForceExit();
            }
        } else if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE) {
            UIUtils.toastLongMessage("您所在的群" + groupSysEle.getGroupId() + "已解散");
            if (mCurrentChatInfo != null && groupSysEle.getGroupId().equals(mCurrentChatInfo.getPeer())) {
                if (mGroupHandler != null)
                    mGroupHandler.onGroupForceExit();
            }
        }
    }

    //群提示信息处理，需要展示信息的
    private void GroupTipsHandle(TIMElem ele) {
        TIMGroupTipsElem groupTips = (TIMGroupTipsElem) ele;
        TIMGroupTipsType tipsType = groupTips.getTipsType();
        if (tipsType == TIMGroupTipsType.ModifyGroupInfo) {
            modifyGroupInfo(groupTips);
        }
    }


    private void modifyGroupInfo(TIMGroupTipsElem groupTips) {
        List<TIMGroupTipsElemGroupInfo> modifyList = groupTips.getGroupInfoList();
        if (modifyList.size() > 0) {
            TIMGroupTipsElemGroupInfo modifyInfo = modifyList.get(0);
            TIMGroupTipsGroupInfoType type = modifyInfo.getType();
            if (type == TIMGroupTipsGroupInfoType.ModifyName) {
                mCurrentChatInfo.setGroupName(modifyInfo.getContent());
            } else if (type == TIMGroupTipsGroupInfoType.ModifyNotification) {
                mCurrentChatInfo.setNotice(modifyInfo.getContent());
            }
        }
    }

    public void destroyGroupChat() {
        mCurrentChatInfo = null;
        mCurrentConversation = null;
        mCurrentConversationExt = null;
        mCurrentProvider = null;
        mSelfInfo = null;
        mCurrentApplies.clear();
        mCurrentGroupMembers.clear();
    }


    public static GroupMemberInfo TIMGroupMember2GroupMember(TIMGroupMemberInfo info) {
        GroupMemberInfo member = new GroupMemberInfo();
        member.setAccount(info.getUser());
        member.setTinyId(info.getTinyId());
        member.setJoinTime(info.getJoinTime());
        member.setMemberType(info.getRole().ordinal());
        return member;
    }


    public static GroupChatInfo TIMGroupDetailInfo2GroupChatInfo(TIMGroupDetailInfo detailInfo) {
        if (detailInfo == null)
            return null;
        GroupChatInfo chatInfo = new GroupChatInfo();
        chatInfo.setChatName(detailInfo.getGroupName());
        chatInfo.setGroupName(detailInfo.getGroupName());
        chatInfo.setPeer(detailInfo.getGroupId());
        chatInfo.setNotice(detailInfo.getGroupNotification());
        chatInfo.setMemberCount((int) detailInfo.getMemberNum());
        chatInfo.setGroupType(detailInfo.getGroupType());
        chatInfo.setOwner(detailInfo.getGroupOwner());
        chatInfo.setJoinType((int) detailInfo.getAddOption().getValue());
        return chatInfo;
    }


    public void setGroupHandler(GroupNotifyHandler mGroupHandler) {
        this.mGroupHandler = mGroupHandler;
    }

    public void removeGroupHandler() {
        this.mGroupHandler = null;
    }


    @Override
    public void handleInvoke(TIMMessageLocator locator) {
        if (mCurrentChatInfo != null && locator.getConversationId().equals(mCurrentChatInfo.getPeer())) {
            QLog.i(TAG, "handleInvoke::: " + locator);
            mCurrentProvider.updateMessageRevoked(locator);
        }

    }

    public interface GroupNotifyHandler {
        void onGroupForceExit();

        void onGroupNameChanged(String newName);
    }

}
