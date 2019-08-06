package com.tencent.qcloud.tim.uikit.modules.group.info;

import android.text.TextUtils;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMGroupAddOpt;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfoResult;
import com.tencent.imsdk.ext.group.TIMGroupMemberResult;
import com.tencent.imsdk.ext.group.TIMGroupPendencyGetParam;
import com.tencent.imsdk.ext.group.TIMGroupPendencyHandledStatus;
import com.tencent.imsdk.ext.group.TIMGroupPendencyItem;
import com.tencent.imsdk.ext.group.TIMGroupPendencyListGetSucc;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.group.apply.GroupApplyInfo;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class GroupInfoProvider {

    private static final String TAG = GroupInfoProvider.class.getSimpleName();

    private static final int PAGE = 50;

    private GroupInfo mGroupInfo;
    private GroupMemberInfo mSelfInfo;
    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();
    private List<GroupApplyInfo> mApplyList = new ArrayList<>();
    private long mPendencyTime;

    private void reset() {
        mGroupInfo = new GroupInfo();
        mGroupMembers = new ArrayList<>();
        mSelfInfo = null;
        mPendencyTime = 0;
    }

    public void loadGroupInfo(GroupInfo info) {
        mGroupInfo = info;
        mGroupMembers = info.getMemberDetails();
    }

    public void loadGroupInfo(final String groupId, final IUIKitCallBack callBack) {

        reset();

        // 串行异步加载群组信息
        loadGroupPublicInfo(groupId, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {

                // 设置群的一般信息，比如名称、类型等
                mGroupInfo.covertTIMGroupDetailInfo((TIMGroupDetailInfoResult) data);

                // 设置是否为置顶聊天
                boolean isTop = ConversationManagerKit.getInstance().isTopConversation(groupId);
                mGroupInfo.setTopChat(isTop);

                // 异步获取群成员
                loadGroupMembers(mGroupInfo, callBack);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e(TAG, "loadGroupPublicInfo failed, code: " + errCode + "|desc: " + errMsg);
                if (callBack != null) {
                    callBack.onError(module, errCode, errMsg);
                }
            }
        });
    }

    public void deleteGroup(final IUIKitCallBack callBack) {
        TIMGroupManager.getInstance().deleteGroup(mGroupInfo.getId(), new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                callBack.onError(TAG, code, desc);
                TUIKitLog.e(TAG, "deleteGroup failed, code: " + code + "|desc: " + desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
                ConversationManagerKit.getInstance().deleteConversation(mGroupInfo.getId(), true);
                GroupChatManagerKit.getInstance().onGroupForceExit();
            }
        });
    }


    public void loadGroupPublicInfo(String groupId, final IUIKitCallBack callBack) {
        List<String> groupList = new ArrayList<>();
        groupList.add(groupId);
        TIMGroupManager.getInstance().getGroupInfo(groupList, new TIMValueCallBack<List<TIMGroupDetailInfoResult>>() {
            @Override
            public void onError(final int code, final String desc) {
                TUIKitLog.e(TAG, "loadGroupPublicInfo failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(final List<TIMGroupDetailInfoResult> timGroupDetailInfoResults) {
                if (timGroupDetailInfoResults.size() > 0) {
                    TIMGroupDetailInfoResult info = timGroupDetailInfoResults.get(0);
                    TUIKitLog.i(TAG, info.toString());
                    callBack.onSuccess(info);
                }
            }
        });
    }

    public void loadGroupMembers(final Object result, final IUIKitCallBack callBack) {
        TIMGroupManager.getInstance().getGroupMembers(mGroupInfo.getId(), new TIMValueCallBack<List<TIMGroupMemberInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "loadGroupMembers failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<TIMGroupMemberInfo> timGroupMemberInfos) {
                List<GroupMemberInfo> members = new ArrayList<>();
                for (int i = 0; i < timGroupMemberInfos.size(); i++) {
                    GroupMemberInfo member = new GroupMemberInfo();
                    members.add(member.covertTIMGroupMemberInfo(timGroupMemberInfos.get(i)));
                }
                mGroupMembers = members;
                mGroupInfo.setMemberDetails(mGroupMembers);
                loadGroupMembersDetail(0, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        callBack.onSuccess(result);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        callBack.onError(module, errCode, errMsg);
                    }
                });
            }
        });
    }

    private void loadGroupMembersDetail(final int begin, final IUIKitCallBack callBack) {
        if (callBack == null) {
            return;
        }
        final ArrayList<String> memberIds = new ArrayList<>();
        final int end;
        if (mGroupMembers.size() == 0) {
            return;
        }
        if (begin + PAGE > mGroupMembers.size()) {
            end = mGroupMembers.size();
        } else {
            end = begin + PAGE;
        }
        for (int i = begin; i < end; i++) {
            memberIds.add(mGroupMembers.get(i).getAccount());
        }
        TIMGroupManager.getInstance().getGroupMembersInfo(mGroupInfo.getId(), memberIds, new TIMValueCallBack<List<TIMGroupMemberInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "getGroupMembersInfo failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(List<TIMGroupMemberInfo> timGroupMemberInfos) {
                TUIKitLog.i(TAG, "getGroupMembersInfo success: " + timGroupMemberInfos.size());
                for (int i = begin; i < end; i++) {
                    GroupMemberInfo memberInfo = mGroupMembers.get(i);
                    for (int j = timGroupMemberInfos.size() - 1; j >= 0; j--) {
                        TIMGroupMemberInfo detail = timGroupMemberInfos.get(j);
                        if (memberInfo.getAccount().equals(detail.getUser())) {
                            memberInfo.setDetail(detail);
                            timGroupMemberInfos.remove(j);
                            break;
                        }
                    }
                }

                if (end < mGroupMembers.size()) {
                    loadGroupMembersDetail(end, callBack);
                } else {
                    callBack.onSuccess(null);
                }
            }
        });
    }

    public List<GroupMemberInfo> getGroupMembers() {
        return mGroupMembers;
    }

    public void modifyGroupInfo(final Object value, final int type, final IUIKitCallBack callBack) {
        TIMGroupManager.ModifyGroupInfoParam param = new TIMGroupManager.ModifyGroupInfoParam(mGroupInfo.getId());
        if (type == TUIKitConstants.Group.MODIFY_GROUP_NAME) {
            param.setGroupName(value.toString());
        } else if (type == TUIKitConstants.Group.MODIFY_GROUP_NOTICE) {
            param.setNotification(value.toString());
        } else if (type == TUIKitConstants.Group.MODIFY_GROUP_JOIN_TYPE) {
            param.setAddOption(TIMGroupAddOpt.values()[(Integer) value]);
        }

        TIMGroupManager.getInstance().modifyGroupInfo(param, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.i(TAG, "modifyGroupInfo faild tyep| value| code| desc " + value + ":" + type + ":" + code + ":" + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                if (type == TUIKitConstants.Group.MODIFY_GROUP_NAME) {
                    mGroupInfo.setGroupName(value.toString());
                } else if (type == TUIKitConstants.Group.MODIFY_GROUP_NOTICE) {
                    mGroupInfo.setNotice(value.toString());
                } else if (type == TUIKitConstants.Group.MODIFY_GROUP_JOIN_TYPE) {
                    mGroupInfo.setJoinType((Integer) value);
                }
                callBack.onSuccess(value);
            }
        });
    }

    public void modifyMyGroupNickname(final String nickname, final IUIKitCallBack callBack) {
        if (mGroupInfo == null) {
            ToastUtil.toastLongMessage("modifyMyGroupNickname fail: NO GROUP");
        }
        TIMGroupManager.ModifyMemberInfoParam param = new TIMGroupManager.ModifyMemberInfoParam(mGroupInfo.getId(), TIMManager.getInstance().getLoginUser());
        param.setNameCard(nickname);
        TIMGroupManager.getInstance().modifyMemberInfo(param, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                callBack.onError(TAG, code, desc);
                ToastUtil.toastLongMessage("modifyMyGroupNickname fail: " + code + "=" + desc);
            }

            @Override
            public void onSuccess() {
                callBack.onSuccess(null);
            }
        });
    }

    public GroupMemberInfo getSelfGroupInfo() {
        if (mSelfInfo != null) {
            return mSelfInfo;
        }
        for (int i = 0; i < mGroupMembers.size(); i++) {
            GroupMemberInfo memberInfo = mGroupMembers.get(i);
            if (TextUtils.equals(memberInfo.getAccount(), TIMManager.getInstance().getLoginUser())) {
                mSelfInfo = memberInfo;
                return memberInfo;
            }

        }
        return null;
    }

    public void setTopConversation(boolean flag) {
        ConversationManagerKit.getInstance().setConversationTop(mGroupInfo.getId(), flag);
    }

    public void quitGroup(final IUIKitCallBack callBack) {
        TIMGroupManager.getInstance().quitGroup(mGroupInfo.getId(), new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "quitGroup failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                ConversationManagerKit.getInstance().deleteConversation(mGroupInfo.getId(), true);
                GroupChatManagerKit.getInstance().onGroupForceExit();
                callBack.onSuccess(null);
                reset();
            }
        });
    }

    public void inviteGroupMembers(List<String> addMembers, final IUIKitCallBack callBack) {
        if (addMembers == null || addMembers.size() == 0) {
            return;
        }
        TIMGroupManager.getInstance().inviteGroupMember(mGroupInfo.getId(), addMembers, new TIMValueCallBack<List<TIMGroupMemberResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "addGroupMembers failed, code: " + code + "|desc: " + desc);
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
                        if (res.getResult() > 0) {
                            adds.add(res.getUser());
                        }
                    }
                }
                if (adds.size() > 0) {
                    loadGroupMembers(adds, callBack);
                }
            }
        });
    }

    public void removeGroupMembers(List<GroupMemberInfo> delMembers, final IUIKitCallBack callBack) {
        if (delMembers == null || delMembers.size() == 0) {
            return;
        }
        List<String> members = new ArrayList<>();
        for (int i = 0; i < delMembers.size(); i++) {
            members.add(delMembers.get(i).getAccount());
        }

        TIMGroupManager.DeleteMemberParam param = new TIMGroupManager.DeleteMemberParam(mGroupInfo.getId(), members);
        TIMGroupManager.getInstance().deleteGroupMember(param, new TIMValueCallBack<List<TIMGroupMemberResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "removeGroupMembers failed, code: " + code + "|desc: " + desc);
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
                    for (int j = mGroupMembers.size() - 1; j >= 0; j--) {
                        if (mGroupMembers.get(j).getAccount().equals(dels.get(i))) {
                            mGroupMembers.remove(j);
                            break;
                        }
                    }
                }
                mGroupInfo.setMemberDetails(mGroupMembers);
                callBack.onSuccess(dels);
            }
        });
    }

    public List<GroupApplyInfo> getApplyList() {
        return mApplyList;
    }

    public void loadGroupApplies(final IUIKitCallBack callBack) {
        loadApplyInfo(new IUIKitCallBack() {

            @Override
            public void onSuccess(Object data) {
                if (mGroupInfo == null) {
                    callBack.onError(TAG, 0, "no groupInfo");
                    return;
                }
                String groupId = mGroupInfo.getId();
                List<GroupApplyInfo> allApplies = (List<GroupApplyInfo>) data;
                List<GroupApplyInfo> applyInfos = new ArrayList<>();
                for (int i = 0; i < allApplies.size(); i++) {
                    GroupApplyInfo applyInfo = allApplies.get(i);
                    if (groupId.equals(applyInfo.getPendencyItem().getGroupId())
                            && applyInfo.getPendencyItem().getHandledStatus() == TIMGroupPendencyHandledStatus.NOT_HANDLED) {
                        applyInfos.add(applyInfo);
                    }
                }
                mApplyList = applyInfos;
                callBack.onSuccess(applyInfos);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.e(TAG, "loadApplyInfo failed, code: " + errCode + "|desc: " + errMsg);
                callBack.onError(module, errCode, errMsg);
            }
        });
    }

    private void loadApplyInfo(final IUIKitCallBack callBack) {
        final List<GroupApplyInfo> applies = new ArrayList<>();
        TIMGroupPendencyGetParam param = new TIMGroupPendencyGetParam();
        param.setTimestamp(mPendencyTime);
        TIMGroupManager.getInstance().getGroupPendencyList(param, new TIMValueCallBack<TIMGroupPendencyListGetSucc>() {
            @Override
            public void onError(final int code, final String desc) {
                TUIKitLog.e(TAG, "getGroupPendencyList failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess(final TIMGroupPendencyListGetSucc timGroupPendencyListGetSucc) {
                mPendencyTime = timGroupPendencyListGetSucc.getMeta().getNextStartTimestamp();
                List<TIMGroupPendencyItem> pendencies = timGroupPendencyListGetSucc.getPendencies();
                for (int i = 0; i < pendencies.size(); i++) {
                    GroupApplyInfo info = new GroupApplyInfo(pendencies.get(i));
                    info.setStatus(0);
                    applies.add(info);
                }
                callBack.onSuccess(applies);
            }
        });
    }

    public void acceptApply(final GroupApplyInfo item, final IUIKitCallBack callBack) {
        item.getPendencyItem().accept("", new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "acceptApply failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                item.setStatus(GroupApplyInfo.APPLIED);
                callBack.onSuccess(null);
            }
        });

    }

    public void refuseApply(final GroupApplyInfo item, final IUIKitCallBack callBack) {
        item.getPendencyItem().refuse("", new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "refuseApply failed, code: " + code + "|desc: " + desc);
                callBack.onError(TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                item.setStatus(GroupApplyInfo.REFUSED);
                callBack.onSuccess(null);
            }
        });
    }
}
