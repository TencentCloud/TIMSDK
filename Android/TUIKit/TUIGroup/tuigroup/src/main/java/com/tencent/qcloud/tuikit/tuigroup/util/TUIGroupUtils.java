package com.tencent.qcloud.tuikit.tuigroup.util;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;

public class TUIGroupUtils {
    private static final String TAG = "TUIGroupUtils";

    public static final int GROUP_EVENT_TIP_JOINED = 1;
    public static final int GROUP_EVENT_TIP_INVITED = 2;
    public static final int GROUP_EVENT_TIP_KICKED = 3;
    public static final int GROUP_EVENT_TIP_DISBANDED = 4;

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, desc);
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(null, errCode, desc);
        }
    }

    public static <T> void callbackOnSuccess(IUIKitCallback<T> callBack, T data) {
        if (callBack != null) {
            callBack.onSuccess(data);
        }
    }

    public static String getConversationIdByUserId(String id, boolean isGroup) {
        String conversationIdPrefix = isGroup ? CONVERSATION_GROUP_PREFIX : CONVERSATION_C2C_PREFIX;
        return conversationIdPrefix + id;
    }

    public static void toastGroupEvent(int type, String groupID) {
        List<String> groupList = new ArrayList<>();
        groupList.add(groupID);
        V2TIMManager.getGroupManager().getGroupsInfo(groupList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                V2TIMGroupInfoResult v2TIMGroupInfoResult = v2TIMGroupInfoResults.get(0);
                if (v2TIMGroupInfoResult.getResultCode() == 0) {
                    V2TIMGroupInfo groupInfo = v2TIMGroupInfoResult.getGroupInfo();
                    if (TextUtils.equals(TUILogin.getLoginUser(), groupInfo.getOwner())) {
                        return;
                    }
                    String groupName = groupInfo.getGroupName();
                    if (TextUtils.isEmpty(groupName)) {
                        groupName = groupID;
                    }
                    toastGroupEventByName(type, groupName);
                } else {
                    TUIGroupLog.e(TAG, "toastGroupEvent failed, code=" + v2TIMGroupInfoResult.getResultCode() + ", msg=" + v2TIMGroupInfoResult.getResultMessage());
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIGroupLog.e(TAG, "toastGroupEvent failed, code=" + code + ", msg=" + desc);
                toastGroupEventByName(type, groupID);
            }
        });
    }

    private static void toastGroupEventByName(int type, String groupName) {
        String toastString = null;
        if (type == GROUP_EVENT_TIP_JOINED) {
            toastString = TUIGroupService.getAppContext().getString(R.string.joined_tip) + groupName;
        } else if (type == GROUP_EVENT_TIP_INVITED) {
            toastString = TUIGroupService.getAppContext().getString(R.string.join_group_tip) + groupName;
        } else if (type == GROUP_EVENT_TIP_KICKED) {
            toastString = TUIGroupService.getAppContext().getString(R.string.kick_group) + groupName;
        } else if (type == GROUP_EVENT_TIP_DISBANDED) {
            toastString = TUIGroupService.getAppContext().getString(R.string.dismiss_tip_before) + groupName + TUIGroupService.getAppContext().getString(R.string.dismiss_tip_after);
        }
        if (toastString != null) {
            ToastUtil.toastLongMessage(toastString);
        }
    }
}
