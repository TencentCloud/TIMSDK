package com.tencent.qcloud.tuikit.tuiconversation.presenter;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.ConversationEventListener;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.model.ConversationProvider;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class ConversationFoldPresenter {
    private static final String TAG = ConversationFoldPresenter.class.getSimpleName();

    private final static int GET_CONVERSATION_COUNT = 100;

    ConversationEventListener conversationEventForMarkObserver;

    private final ConversationProvider provider;

    private IConversationListAdapter adapter;

    private final List<ConversationInfo> loadedConversationInfoList = new ArrayList<>();

    public ConversationFoldPresenter() {
        provider = new ConversationProvider();
    }

    public void setAdapter(IConversationListAdapter adapter) {
        this.adapter = adapter;
    }

    public void initListener() {
        conversationEventForMarkObserver = new ConversationEventListener() {
            @Override
            public void deleteConversation(String chatId, boolean isGroup) {
                ConversationFoldPresenter.this.deleteConversationFromUI(chatId, isGroup);
            }

            @Override
            public void clearConversationMessage(String chatId, boolean isGroup) {

            }

            @Override
            public void clearFoldMarkAndDeleteConversation(String conversationId) {
                ConversationFoldPresenter.this.deleteConversationFromUI(conversationId);
            }

            @Override
            public void setConversationTop(String chatId, boolean isChecked, IUIKitCallback<Void> iuiKitCallBack) {

            }

            @Override
            public boolean isTopConversation(String chatId) {
                return false;
            }

            @Override
            public long getUnreadTotal() {
                return 0;
            }

            @Override
            public void onSyncServerFinish() {

            }

            @Override
            public void updateTotalUnreadMessageCount(long count) {

            }

            @Override
            public void onNewConversation(List<ConversationInfo> conversationList) {
                ConversationFoldPresenter.this.onNewConversation(conversationList);
            }

            @Override
            public void onConversationChanged(List<ConversationInfo> conversationList) {
                ConversationFoldPresenter.this.onConversationChanged(conversationList);
            }

            @Override
            public void onFriendRemarkChanged(String id, String remark) {

            }

            @Override
            public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList) {

            }

            @Override
            public void refreshUserStatusFragmentUI() {

            }

            @Override
            public void onReceiveMessage(String conversationID, boolean isTypingMessage) {
                processNewMessage(conversationID, isTypingMessage);
            }

            @Override
            public void onMessageSendForHideConversation(String conversationID) {

            }
        };
        TUIConversationService.getInstance().addConversationEventListener(conversationEventForMarkObserver);
    }

    public void loadConversation() {
        TUIConversationLog.i(TAG, "loadConversation");
        V2TIMConversationListFilter filter = new V2TIMConversationListFilter();
        long markType = V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD;
        filter.setMarkType(markType);
        provider.getMarkConversationList(filter, 0, GET_CONVERSATION_COUNT, true, new IUIKitCallback<List<ConversationInfo>>() {
            @Override
            public void onSuccess(List<ConversationInfo> conversationInfoList) {
                if (conversationInfoList.size() == 0) {
                    return;
                }

                Collections.sort(conversationInfoList);
                List<ConversationInfo> loadList = new ArrayList<>();
                for (ConversationInfo conversationInfo : conversationInfoList) {
                    if (!conversationInfo.isMarkHidden()) {
                        loadList.add(conversationInfo);
                    }
                }
                onLoadConversationCompleted(loadList);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(TAG, "loadConversation error:" + errCode + ", " + errMsg);
                if (adapter != null) {
                    adapter.onLoadingStateChanged(false);
                }
            }
        });
    }

    private void onLoadConversationCompleted(List<ConversationInfo> conversationInfoList) {
        onNewConversation(conversationInfoList);
        if (adapter != null) {
            adapter.onLoadingStateChanged(false);
        }
    }

    /**
     * 有新的会话
     * @param conversationInfoList 新的会话列表
     */
    public void onNewConversation(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "onNewConversation conversations:" + conversationInfoList);

        if (conversationInfoList.size() == 0) {
            return;
        }

        ArrayList<ConversationInfo> processedInfoList = processFoldedAndHiddenConversation(conversationInfoList);

        List<ConversationInfo> exists = new ArrayList<>();
        Iterator<ConversationInfo> iterator = processedInfoList.iterator();
        while (iterator.hasNext()) {
            ConversationInfo update = iterator.next();
            for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                ConversationInfo cacheInfo = loadedConversationInfoList.get(i);
                // 去重
                if (cacheInfo.getConversationId().equals(update.getConversationId())) {
                    loadedConversationInfoList.set(i, update);
                    iterator.remove();
                    exists.add(update);
                    break;
                }
            }

        }

        // 对新增会话排序，避免插入 recyclerview 时错乱
        Collections.sort(processedInfoList);
        loadedConversationInfoList.addAll(processedInfoList);
        if (adapter != null) {
            Collections.sort(loadedConversationInfoList);
            adapter.onDataSourceChanged(loadedConversationInfoList);
            for (ConversationInfo info : processedInfoList) {
                int index = loadedConversationInfoList.indexOf(info);
                if (index != -1) {
                    adapter.onItemInserted(index);
                }
            }

            for (ConversationInfo info : exists) {
                int index = loadedConversationInfoList.indexOf(info);
                if (index != -1) {
                    adapter.onItemChanged(index);
                }
            }
        }
    }

    public void onConversationChanged(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "onConversationChanged conversations:" + conversationInfoList);

        ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
        ArrayList<ConversationInfo> infoList = processFoldedAndHiddenConversation(conversationInfoList);

        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        for (ConversationInfo conversationInfo : infoList) {
            if (!ConversationUtils.isIgnored(conversationInfo)) {
                boolean exists = false;
                for (ConversationInfo loadedInfo : loadedConversationInfoList) {
                    if (TextUtils.equals(conversationInfo.getConversationId(), loadedInfo.getConversationId())) {
                        exists = true;
                        break;
                    }
                }
                if (exists) {
                    TUIConversationLog.i(TAG, "onConversationChanged conversationInfo " + conversationInfo);
                    changedInfoList.add(conversationInfo);
                } else {
                    addInfoList.add(conversationInfo);
                }
            }
        }
        if (!addInfoList.isEmpty()) {
            onNewConversation(addInfoList);
        }

        if (changedInfoList.size() == 0) {
            return;
        }

        refreshChangedInfo(loadedConversationInfoList, changedInfoList);
    }

    private void refreshChangedInfo(List<ConversationInfo> uiSourceInfoList,
                                    ArrayList<ConversationInfo> changedInfoList) {
        Collections.sort(changedInfoList);

        HashMap<ConversationInfo, Integer> indexMap = new HashMap<>();
        for (int j = 0; j < changedInfoList.size(); j++) {
            ConversationInfo update = changedInfoList.get(j);
            for (int i = 0; i < uiSourceInfoList.size(); i++) {
                ConversationInfo cacheInfo = uiSourceInfoList.get(i);
                //单个会话刷新时找到老的会话数据，替换
                if (cacheInfo.getConversationId().equals(update.getConversationId())) {
                    if (update.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN) {
                        update.setStatusType(cacheInfo.getStatusType());
                    }
                    uiSourceInfoList.set(i, update);
                    indexMap.put(update, i);
                    break;
                }
            }
        }
        if (adapter != null) {
            Collections.sort(uiSourceInfoList);
            adapter.onDataSourceChanged(uiSourceInfoList);
            int minRefreshIndex = Integer.MAX_VALUE;
            int maxRefreshIndex = Integer.MIN_VALUE;
            for (ConversationInfo info : changedInfoList) {
                Integer oldIndexObj = indexMap.get(info);
                if (oldIndexObj == null) {
                    continue;
                }
                int oldIndex = oldIndexObj;
                int newIndex = uiSourceInfoList.indexOf(info);
                if (newIndex != -1) {
                    minRefreshIndex = Math.min(minRefreshIndex, Math.min(oldIndex, newIndex));
                    maxRefreshIndex = Math.max(maxRefreshIndex, Math.max(oldIndex, newIndex));
                }
            }
            int count;
            if (minRefreshIndex == maxRefreshIndex) {
                count = 1;
            } else {
                count = maxRefreshIndex - minRefreshIndex + 1;
            }
            if (count > 0 && maxRefreshIndex >= minRefreshIndex) {
                adapter.onItemRangeChanged(minRefreshIndex, count);
            }
        }
    }

    private ArrayList<ConversationInfo> processFoldedAndHiddenConversation(List<ConversationInfo> infoList) {
        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        for (ConversationInfo conversationInfo : infoList) {
            int uiIndex = -1;
            for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                ConversationInfo loadedInfo = loadedConversationInfoList.get(i);
                if (TextUtils.equals(conversationInfo.getConversationId(), loadedInfo.getConversationId())) {
                    uiIndex = i;
                    break;
                }
            }
            if (uiIndex >= 0) {
                if (!conversationInfo.isMarkFold() || conversationInfo.isMarkHidden()) {
                    loadedConversationInfoList.remove(uiIndex);
                    if (adapter != null) {
                        adapter.onItemRemoved(uiIndex);
                    }
                } else if (conversationInfo.isMarkFold()) {
                    changedInfoList.add(conversationInfo);
                }
            } else {
                if (conversationInfo.isMarkFold() && !conversationInfo.isMarkHidden()) {
                    changedInfoList.add(conversationInfo);
                }
            }
        }

        return changedInfoList;
    }

    private void processNewMessage(String conversationID, boolean isTypingMessage) {
        if (TextUtils.isEmpty(conversationID)) {
           return;
        }
        if (isTypingMessage) {
            return;
        }

        ConversationInfo cacheInfo = null;
        for (ConversationInfo conversationInfo : loadedConversationInfoList) {
            if (TextUtils.equals(conversationID, conversationInfo.getConversationId())) {
                cacheInfo = conversationInfo;
                break;
            }
        }

        if (cacheInfo != null) {
            if (cacheInfo.isMarkUnread()) {
                markConversationUnread(cacheInfo, false);
            }
        } else {
            provider.getConversation(conversationID, new IUIKitCallback<ConversationInfo>() {
                @Override
                public void onSuccess(ConversationInfo conversationInfo) {
                    if (conversationInfo.isMarkHidden()) {
                        markConversationHidden(conversationInfo, false);
                    }
                    if (conversationInfo.isMarkUnread()) {
                        markConversationUnread(conversationInfo, false);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {

                }
            });
        }
    }

    /**
     * 删除会话，会将本地会话数据从imsdk中删除
     *
     * @param conversation 会话信息
     */
    public void deleteConversation(ConversationInfo conversation) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.CONVERSATION_ID, conversation.getConversationId());
        TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME, TUIConstants.TUIConversation.METHOD_DELETE_CONVERSATION, param);
    }

    /**
     * 隐藏会话
     * hide conversation
     * @param conversationInfo 会话信息 conversation info
     */
    public void markConversationHidden(ConversationInfo conversationInfo, boolean isHidden) {
        if (conversationInfo == null || TextUtils.isEmpty(conversationInfo.getConversationId())) {
            TUIConversationLog.e(TAG, "markConversationHidden error: invalid conversationInfo");
            return;
        }

        provider.markConversationHidden(conversationInfo.getConversationId(), isHidden, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                conversationInfo.setMarkHidden(isHidden);
                TUIConversationLog.i(TAG, "markConversationHidden success, conversationID:" +
                        conversationInfo.getConversationId() + ", isHidden:" + isHidden);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(TAG, "markConversationHidden error, conversationID:" +
                        conversationInfo.getConversationId() + ", code:" + errCode + "|msg:" + errMsg);
            }
        });
    }

    public void markConversationUnread(ConversationInfo conversationInfo, boolean markUnread) {
        if (conversationInfo == null || TextUtils.isEmpty(conversationInfo.getConversationId())) {
            TUIConversationLog.e(TAG, "markConversationUnread error: invalid conversationInfo");
            return;
        }

        provider.markConversationUnread(conversationInfo, markUnread, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                conversationInfo.setMarkUnread(markUnread);
                TUIConversationLog.i(TAG, "markConversationRead success, conversationID:" +
                        conversationInfo.getConversationId());
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(TAG, "markConversationRead error, conversationID:" +
                        conversationInfo.getConversationId() + ", code:" + errCode + "|msg:" + errMsg);
            }
        });
    }

    public void deleteConversationFromUI(String id, boolean isGroup) {
        if (!isGroup) {
            return;
        }
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (TextUtils.equals(info.getId(), id)) {
                boolean isRemove = loadedConversationInfoList.remove(info);
                if (adapter != null && isRemove) {
                    adapter.onItemRemoved(i);
                }
                break;
            }
        }
    }

    public void deleteConversationFromUI(String conversationId) {
        if (TextUtils.isEmpty(conversationId)) {
            return;
        }
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (TextUtils.equals(info.getConversationId(), conversationId)) {
                boolean isRemove = loadedConversationInfoList.remove(info);
                if (adapter != null && isRemove) {
                    adapter.onItemRemoved(i);
                }
                break;
            }
        }
    }
}