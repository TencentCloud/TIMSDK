package com.tencent.qcloud.tuikit.tuiconversation.model;

import android.text.TextUtils;
import android.view.View;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
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
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.config.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class ConversationProvider {
    private static final String TAG = ConversationProvider.class.getSimpleName();

    private boolean isFinished = false;
    private long nextLoadSeq = 0L;

    private List<ConversationInfo> markConversationInfoList = new ArrayList<>();
    private HashMap<String, V2TIMConversation> markUnreadMap = new HashMap<>();

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

    public void getConversation(String conversationID, IUIKitCallback<ConversationInfo> callback) {
        V2TIMManager.getConversationManager().getConversation(conversationID, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                ConversationInfo conversationInfo = ConversationUtils.convertV2TIMConversation(v2TIMConversation);
                TUIConversationUtils.callbackOnSuccess(callback, conversationInfo);
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.v(TAG, "getConversation error, code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                TUIConversationUtils.callbackOnError(callback, TAG, code, desc);
            }
        });
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

    public void markConversationFold(String conversationID, boolean isFold, IUIKitCallback<Void> callback) {
        List<String> conversationIDList = new ArrayList<>();
        conversationIDList.add(conversationID);
        V2TIMManager.getConversationManager().markConversation(conversationIDList,
                V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD, isFold,
                new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
                    @Override
                    public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                        if (v2TIMConversationOperationResults.size() == 0) {
                            return;
                        }
                        V2TIMConversationOperationResult result = v2TIMConversationOperationResults.get(0);
                        if (result.getResultCode() == BaseConstants.ERR_SUCC) {
                            TUIConversationUtils.callbackOnSuccess(callback, null);
                        } else {
                            TUIConversationUtils.callbackOnError(callback, TAG, result.getResultCode(), result.getResultInfo());
                        }
                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIConversationLog.e(TAG, "markConversationFold error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                        TUIConversationUtils.callbackOnError(callback, TAG, code, desc);
                    }
                });
    }

    public void markConversationHidden(String conversationID, boolean isHidden, IUIKitCallback<Void> callback) {
        List<String> conversationIDList = new ArrayList<>();
        if (!TextUtils.isEmpty(conversationID)) {
            conversationIDList.add(conversationID);
        }
        V2TIMManager.getConversationManager().markConversation(conversationIDList,
                V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_HIDE, isHidden, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                if (v2TIMConversationOperationResults.size() == 0) {
                    return;
                }
                V2TIMConversationOperationResult result = v2TIMConversationOperationResults.get(0);
                if (result.getResultCode() == BaseConstants.ERR_SUCC) {
                    TUIConversationUtils.callbackOnSuccess(callback, null);
                } else {
                    TUIConversationUtils.callbackOnError(callback, TAG, result.getResultCode(), result.getResultInfo());
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "markConversationHidden error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                TUIConversationUtils.callbackOnError(callback, TAG, code, desc);
            }
        });
    }

    public void markConversationUnread(ConversationInfo conversationInfo, boolean markUnread, IUIKitCallback<Void> callback) {
        List<String> conversationIDList = new ArrayList<>();
        if (!TextUtils.isEmpty(conversationInfo.getConversationId())) {
            conversationIDList.add(conversationInfo.getConversationId());
        }
        if (!markUnread && conversationInfo.getUnRead() > 0) {
            if (conversationInfo.isGroup()) {
                V2TIMManager.getMessageManager().markGroupMessageAsRead(conversationInfo.getId(), new V2TIMCallback() {
                    @Override
                    public void onSuccess() {
                        TUIConversationLog.i(TAG, "markConversationUnread->markGroupMessageAsRead success");
                    }

                @Override
                public void onError(int code, String desc) {
                    TUIConversationLog.e(TAG, "markConversationUnread error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                }
            });
        } else {
            V2TIMManager.getMessageManager().markC2CMessageAsRead(conversationInfo.getId(), new V2TIMCallback() {
                @Override
                public void onSuccess() {
                    TUIConversationLog.i(TAG, "markConversationUnread->markC2CMessageAsRead success");
                }

                    @Override
                    public void onError(int code, String desc) {
                        TUIConversationLog.e(TAG, "markConversationUnread error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                    }
                });
            }
        }

        if (markUnread != conversationInfo.isMarkUnread()) {
            V2TIMManager.getConversationManager().markConversation(conversationIDList, V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD, markUnread, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
                @Override
                public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                    if (v2TIMConversationOperationResults.size() == 0) {
                        return;
                    }
                    V2TIMConversationOperationResult result = v2TIMConversationOperationResults.get(0);
                    if (result.getResultCode() == BaseConstants.ERR_SUCC) {
                        TUIConversationUtils.callbackOnSuccess(callback, null);
                    } else {
                        TUIConversationUtils.callbackOnError(callback, TAG, result.getResultCode(), result.getResultInfo());
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    TUIConversationLog.e(TAG, "markConversationUnread error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                    TUIConversationUtils.callbackOnError(callback, TAG, code, desc);
                }
            });
        }
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
        if (userList.isEmpty()) {
            TUIConversationLog.d(TAG, "loadConversationUserStatus userList is empty");
            return;
        }
        V2TIMManager.getInstance().getUserStatus(userList, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                TUIConversationLog.i(TAG, "getUserStatus success");
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

    public void getMarkConversationList(final V2TIMConversationListFilter filter, long nextSeq, int count, boolean fromStart, IUIKitCallback<List<ConversationInfo>> callback) {
        if (fromStart) {
            markConversationInfoList.clear();
        }
        V2TIMManager.getConversationManager().getConversationListByFilter(filter, nextSeq, count, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                List<V2TIMConversation> conversationList = v2TIMConversationResult.getConversationList();
                List<ConversationInfo> conversationInfoList = ConversationUtils.convertV2TIMConversationList(conversationList);
                markConversationInfoList.addAll(conversationInfoList);

                if (!v2TIMConversationResult.isFinished()) {
                    getMarkConversationList(filter, v2TIMConversationResult.getNextSeq(), count, false, callback);
                } else {
                    if (callback != null) {
                        callback.onSuccess(markConversationInfoList);
                    }
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "getMarkConversationList error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    public void clearAllUnreadMessage(IUIKitCallback<Void> callback) {
        V2TIMManager.getMessageManager().markAllMessageAsRead(new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUIConversationLog.i(TAG, "markAllMessageAsRead success");
                TUIConversationUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.i(TAG, "markAllMessageAsRead error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                TUIConversationUtils.callbackOnError(callback, code, desc);
            }
        });

        V2TIMConversationListFilter filter = new V2TIMConversationListFilter();
        filter.setMarkType(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD);
        getMarkUnreadConversationList(filter, 0, 100,  true, new V2TIMValueCallback<HashMap<String, V2TIMConversation>>() {
            @Override
            public void onSuccess(HashMap<String, V2TIMConversation> stringV2TIMConversationHashMap) {
                if (stringV2TIMConversationHashMap.size() == 0) {
                    return;
                }
                List<String> unreadConversationIDList = new ArrayList<>();
                Iterator<Map.Entry<String, V2TIMConversation>> iterator = markUnreadMap.entrySet().iterator();
                while (iterator.hasNext()) {
                    Map.Entry<String, V2TIMConversation> entry = iterator.next();
                    unreadConversationIDList.add(entry.getKey());
                }

                V2TIMManager.getConversationManager().markConversation(unreadConversationIDList,
                        V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD,
                        false,
                        new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
                            @Override
                            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                                for (V2TIMConversationOperationResult result : v2TIMConversationOperationResults) {
                                    if (result.getResultCode() == BaseConstants.ERR_SUCC) {
                                        V2TIMConversation v2TIMConversation = markUnreadMap.get(result.getConversationID());
                                        if (!v2TIMConversation.getMarkList().contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_HIDE)) {
                                            markUnreadMap.remove(result.getConversationID());
                                        }
                                    }
                                }
                                TUIConversationUtils.callbackOnSuccess(callback, null);
                            }

                            @Override
                            public void onError(int code, String desc) {
                                TUIConversationLog.e(TAG, "triggerClearAllUnreadMessage->markConversation error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                                TUIConversationUtils.callbackOnError(callback, code, desc);
                            }
                        });
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "triggerClearAllUnreadMessage->getMarkUnreadConversationList error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    private void getMarkUnreadConversationList(V2TIMConversationListFilter filter, long nextSeq, int count, boolean fromStart, V2TIMValueCallback<HashMap<String, V2TIMConversation>> callback) {
        if (fromStart) {
            markUnreadMap.clear();
        }
        V2TIMManager.getConversationManager().getConversationListByFilter(filter, nextSeq, count, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                List<V2TIMConversation> conversationList = v2TIMConversationResult.getConversationList();
                for (V2TIMConversation conversation : conversationList) {
                    markUnreadMap.put(conversation.getConversationID(), conversation);
                }

                if (!v2TIMConversationResult.isFinished()) {
                    getMarkUnreadConversationList(filter, v2TIMConversationResult.getNextSeq(), count, false, callback);
                } else {
                    if (callback != null) {
                        callback.onSuccess(markUnreadMap);
                    }
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIConversationLog.e(TAG, "getMarkUnreadConversationList error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }
}