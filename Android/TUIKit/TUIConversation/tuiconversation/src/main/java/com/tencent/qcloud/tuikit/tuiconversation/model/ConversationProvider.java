package com.tencent.qcloud.tuikit.tuiconversation.model;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.BuildConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.setting.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.util.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ConversationProvider {
    private static final String TAG = ConversationProvider.class.getSimpleName();

    private boolean isFinished = false;
    private long nextLoadSeq = 0L;

    public void loadConversation(long startSeq, int loadCount, final IUIKitCallback<List<ConversationInfo>> callBack) {
        isFinished = false;
        nextLoadSeq = 0;
        V2TIMManager.getConversationManager().getConversationList(startSeq, loadCount, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.v(TAG, "loadConversation getConversationList error, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                TUIConversationUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                List<V2TIMConversation> v2TIMConversationList = v2TIMConversationResult.getConversationList();
                List<ConversationInfo> conversationInfoList = ConversationUtils.convertV2TIMConversationList(v2TIMConversationList);
                isFinished = v2TIMConversationResult.isFinished();
                nextLoadSeq = v2TIMConversationResult.getNextSeq();
                TUIConversationUtils.callbackOnSuccess(callBack, conversationInfoList);
            }
        });
    }

    public void loadMoreConversation(int loadCount, IUIKitCallback<List<ConversationInfo>> callBack) {
        if (isFinished) {
            return;
        }
        loadConversation(nextLoadSeq, loadCount, callBack);
    }

    public boolean isLoadFinished() {
        return isFinished;
    }

    public void getTotalUnreadMessageCount(IUIKitCallback<Long> callBack) {

        // 更新消息未读总数
        V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
            @Override
            public void onSuccess(Long count) {
                TUIConversationUtils.callbackOnSuccess(callBack, count);
            }

            @Override
            public void onError(int code, String desc) {

            }
        });
    }

    public void setConversationTop(String conversationId, boolean isTop, IUIKitCallback<Void> callBack) {
        V2TIMManager.getConversationManager().pinConversation(conversationId, isTop, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIConversationUtils.callbackOnSuccess(callBack, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationUtils.callbackOnError(callBack, TAG, code, desc);
            }
        });
    }

    public void deleteConversation(String conversationId, IUIKitCallback<Void> callBack) {
        V2TIMManager.getConversationManager().deleteConversation(conversationId, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "deleteConversation error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                TUIConversationUtils.callbackOnError(callBack, TAG, code, desc);
            }

            @Override
            public void onSuccess() {
                TUIConversationLog.i(TAG, "deleteConversation success");
                TUIConversationUtils.callbackOnSuccess(callBack, null);
            }
        });

    }

    public void clearHistoryMessage(String userId, boolean isGroup, IUIKitCallback<Void> callBack) {
        if (isGroup) {
            V2TIMManager.getMessageManager().clearGroupHistoryMessage(userId, new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIConversationLog.e(TAG, "clearConversationMessage error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                    TUIConversationUtils.callbackOnError(callBack, TAG, code, desc);
                }

                @Override
                public void onSuccess() {
                    TUIConversationLog.i(TAG, "clearConversationMessage success");
                    TUIConversationUtils.callbackOnSuccess(callBack, null);
                }
            });
        } else {
            V2TIMManager.getMessageManager().clearC2CHistoryMessage(userId, new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIConversationLog.e(TAG, "clearConversationMessage error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                    TUIConversationUtils.callbackOnError(callBack, TAG, code, desc);

                }

                @Override
                public void onSuccess() {
                    TUIConversationLog.i(TAG, "clearConversationMessage success");
                    TUIConversationUtils.callbackOnSuccess(callBack, null);

                }
            });
        }
    }

    public void getGroupMemberIconList(String groupId, int iconCount, IUIKitCallback<List<Object>> callback) {
        V2TIMManager.getGroupManager().getGroupMemberList(groupId, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL, 0, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIConversationUtils.callbackOnError(callback, code, desc);
                TUIConversationLog.e("ConversationIconView", "getGroupMemberList failed! groupID:" + groupId + "|code:" + code + "|desc: " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfoList = v2TIMGroupMemberInfoResult.getMemberInfoList();
                int faceSize = Math.min(v2TIMGroupMemberFullInfoList.size(), iconCount);
                final List<Object> urlList = new ArrayList<>();
                for (int i = 0; i < faceSize; i++) {
                    V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo = v2TIMGroupMemberFullInfoList.get(i);
                    urlList.add(v2TIMGroupMemberFullInfo.getFaceUrl());
                }
                TUIConversationUtils.callbackOnSuccess(callback, urlList);
            }
        });
    }

    public void loadConversationUserStatus(List<ConversationInfo> dataSource, IUIKitCallback<Void> callback) {
        if (dataSource == null || dataSource.size() == 0) {
            TUIConversationLog.d(TAG, "loadConversationUserStatus datasource is null");
            TUIConversationUtils.callbackOnSuccess(callback, null);
            return;
        }

        HashMap<String, ConversationInfo> dataSourceMap = new HashMap<>();
        List<String> userList = new ArrayList<>();
        for(ConversationInfo itemBean : dataSource) {
            if (itemBean.isGroup()) {
                continue;
            }
            userList.add(itemBean.getId());
            dataSourceMap.put(itemBean.getId(), itemBean);
        }
        V2TIMManager.getInstance().getUserStatus(userList, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                for (V2TIMUserStatus item : v2TIMUserStatuses) {
                    ConversationInfo bean = dataSourceMap.get(item.getUserID());
                    if (bean != null) {
                        bean.setStatusType(item.getStatusType());
                    }
                }

                TUIConversationUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "getUserStatus error code = " + code + ",des = " + desc);
                TUIConversationUtils.callbackOnError(callback, code, desc);
                if (code == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT &&
                        TUIConversationConfig.getInstance().isShowUserStatus() && BuildConfig.DEBUG) {
                    ToastUtil.toastLongMessage(desc);
                }
            }
        });
    }

    public void subscribeConversationUserStatus(List<String> userIdList, IUIKitCallback<Void> callback) {
        if (userIdList == null || userIdList.size() == 0) {
            TUIConversationLog.e(TAG, "subscribeConversationUserStatus userId is null");
            TUIConversationUtils.callbackOnError(callback, BaseConstants.ERR_INVALID_PARAMETERS, "userid list is null");
            return;
        }

        V2TIMManager.getInstance().subscribeUserStatus(userIdList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIConversationUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "subscribeConversationUserStatus error code = " + code + ",des = " + desc);
                TUIConversationUtils.callbackOnError(callback, code, desc);
            }
        });
    }
}