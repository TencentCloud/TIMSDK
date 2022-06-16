package com.tencent.qcloud.tuikit.tuigroup;

import android.content.Context;
import android.os.Bundle;

import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIGroupService extends ServiceInitializer implements ITUIGroupService {
    public static final String TAG = TUIGroupService.class.getSimpleName();
    private static TUIGroupService instance;

    public static TUIGroupService getInstance() {
        return instance;
    }


    @Override
    public void init(Context context) {
        instance = this;
        initService();
        initEvent();
        initIMListener();
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        return null;
    }

    private void initService() {
    }

    private void initEvent() {

    }

    private void initIMListener() {
        V2TIMManager.getInstance().addGroupListener(new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                ArrayList<String> userIds = new ArrayList<>();
                for (V2TIMGroupMemberInfo memberInfo : memberList) {
                    userIds.add(memberInfo.getUserID());
                }
                param.put(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST, userIds);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_JOIN_GROUP, param);
                if (userIds.contains(TUILogin.getLoginUser())) {
                    ToastUtil.toastLongMessage(getAppContext().getString(R.string.joined_tip) + groupID);
                }
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                super.onMemberLeave(groupID, member);
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                ArrayList<String> userIds = new ArrayList<>();
                for (V2TIMGroupMemberInfo memberInfo : memberList) {
                    userIds.add(memberInfo.getUserID());
                }
                param.put(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST, userIds);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_INVITED_GROUP, param);
                if (userIds.contains(TUILogin.getLoginUser())) {
                    ToastUtil.toastLongMessage(getAppContext().getString(R.string.join_group_tip) + groupID);
                }
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                ArrayList<String> userIds = new ArrayList<>();
                for (V2TIMGroupMemberInfo memberInfo : memberList) {
                    userIds.add(memberInfo.getUserID());
                }
                param.put(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST, userIds);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP, param);
                if (userIds.contains(TUILogin.getLoginUser())) {
                    ToastUtil.toastLongMessage(getAppContext().getString(R.string.kick_group) + groupID);
                }
            }

            @Override
            public void onMemberInfoChanged(String groupID, List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
                super.onMemberInfoChanged(groupID, v2TIMGroupMemberChangeInfoList);
            }

            @Override
            public void onGroupCreated(String groupID) {
                super.onGroupCreated(groupID);
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS, param);
                ToastUtil.toastLongMessage(getAppContext().getString(R.string.dismiss_tip_before) + groupID + getAppContext().getString(R.string.dismiss_tip_after));

            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE, param);
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                for (V2TIMGroupChangeInfo changeInfo : changeInfos) {
                    if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                        param.put(TUIConstants.TUIGroup.GROUP_NAME, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                        param.put(TUIConstants.TUIGroup.GROUP_FACE_URL, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                        param.put(TUIConstants.TUIGroup.GROUP_OWNER, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                        param.put(TUIConstants.TUIGroup.GROUP_NOTIFICATION, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                        param.put(TUIConstants.TUIGroup.GROUP_INTRODUCTION, changeInfo.getValue());
                    } else {
                        return;
                    }
                }
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED, param);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
                super.onReceiveJoinApplication(groupID, member, opReason);
            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
                super.onApplicationProcessed(groupID, opUser, isAgreeJoin, opReason);
            }

            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                super.onGrantAdministrator(groupID, opUser, memberList);
            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                super.onRevokeAdministrator(groupID, opUser, memberList);
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, groupID);
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP, param);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                super.onReceiveRESTCustomData(groupID, customData);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                super.onGroupAttributeChanged(groupID, groupAttributeMap);
            }
        });
    }

    @Override
    public int getLightThemeResId() {
        return R.style.TUIGroupLightTheme;
    }

    @Override
    public int getLivelyThemeResId() {
        return R.style.TUIGroupLivelyTheme;
    }

    @Override
    public int getSeriousThemeResId() {
        return R.style.TUIGroupSeriousTheme;
    }
}
