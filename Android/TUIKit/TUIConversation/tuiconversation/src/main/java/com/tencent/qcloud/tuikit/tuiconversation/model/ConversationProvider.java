package com.tencent.qcloud.tuikit.tuiconversation.model;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.util.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationUtils;

import java.util.ArrayList;
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
}