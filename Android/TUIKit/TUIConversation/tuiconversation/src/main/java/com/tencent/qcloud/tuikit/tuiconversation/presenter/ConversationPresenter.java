package com.tencent.qcloud.tuikit.tuiconversation.presenter;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Pair;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.FaceUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationUserStatusBean;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.config.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.ConversationEventListener;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.model.ConversationProvider;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class ConversationPresenter {
    private static final String TAG = ConversationPresenter.class.getSimpleName();

    public static final int SHOW_TYPE_CONVERSATION_LIST = 0;
    public static final int SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD = 1;

    protected int showType = SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD;

    protected static final int GET_CONVERSATION_COUNT = 100;
    protected static final int REFRESH_UNREAD_COUNT_DELAY = 200;

    protected ConversationEventListener conversationEventListener;

    private final ConversationProvider provider;

    protected IConversationListAdapter adapter;

    protected final List<ConversationInfo> loadedConversationInfoList = new ArrayList<>();
    private List<ConversationInfo> foldConversationInfoList = new ArrayList<>();

    private ConversationInfo mUIFoldConversation;

    protected HashMap<String, ConversationInfo> markUnreadAndHiddenMap = new HashMap<>();

    protected long totalUnreadCount;

    private boolean hideFoldItem;
    private boolean isUnreadStatusOfFoldItem;

    public ConversationPresenter() {
        provider = new ConversationProvider();
        String loginUserID = TUILogin.getLoginUser();
        hideFoldItem = SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME)
                           .getBoolean(TUIConversationConstants.HIDE_FOLD_ITEM_SP_KEY_PREFIX + loginUserID, false);
        isUnreadStatusOfFoldItem = SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME)
                                       .getBoolean(TUIConversationConstants.FOLD_ITEM_IS_UNREAD_SP_KEY_PREFIX + loginUserID, false);
    }

    public void setConversationListener() {
        conversationEventListener = new ConversationEventListener() {
            @Override
            public void deleteConversation(String chatId, boolean isGroup) {
                ConversationPresenter.this.deleteConversation(chatId, isGroup);
            }

            @Override
            public void clearConversationMessage(String chatId, boolean isGroup) {
                ConversationPresenter.this.clearConversationMessage(chatId, isGroup);
            }

            @Override
            public void clearFoldMarkAndDeleteConversation(String conversationId) {
                ConversationPresenter.this.clearFoldMarkAndDeleteConversation(conversationId);
            }

            @Override
            public void setConversationTop(String chatId, boolean isChecked, IUIKitCallback<Void> iuiKitCallBack) {
                ConversationPresenter.this.setConversationTop(chatId, isChecked, iuiKitCallBack);
            }

            @Override
            public boolean isTopConversation(String chatId) {
                return ConversationPresenter.this.isTopConversation(chatId);
            }

            @Override
            public long getUnreadTotal() {
                return totalUnreadCount;
            }

            @Override
            public void onSyncServerFinish() {
                TUIConversationLog.i(TAG, "onSyncServerFinish");
            }

            @Override
            public void updateTotalUnreadMessageCount(long count) {
                TUIConversationLog.i(TAG, "updateTotalUnreadMessageCount: " + count);
                ThreadUtils.postOnUiThreadDelayed(() -> ConversationPresenter.this.updateTotalUnreadMessageCount(count), REFRESH_UNREAD_COUNT_DELAY);
            }

            @Override
            public void onNewConversation(List<ConversationInfo> conversationList) {
                ConversationPresenter.this.onNewConversation(conversationList, false);
                if (updateMarkedUnreadAndHiddenList(conversationList)) {
                    refreshUnreadCount();
                }
            }

            @Override
            public void onConversationChanged(List<ConversationInfo> conversationList) {
                ConversationPresenter.this.onConversationChanged(conversationList);
                if (updateMarkedUnreadAndHiddenList(conversationList)) {
                    refreshUnreadCount();
                }
            }

            @Override
            public void onFriendRemarkChanged(String id, String remark) {
                ConversationPresenter.this.onFriendRemarkChanged(id, remark);
            }

            @Override
            public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList) {
                ConversationPresenter.this.onUserStatusChanged(userStatusList);
            }

            @Override
            public void refreshUserStatusFragmentUI() {
                ConversationPresenter.this.updateAdapter();
            }

            @Override
            public void onReceiveMessage(String conversationID, boolean isTypingMessage) {
                processNewMessage(conversationID, isTypingMessage);
            }

            @Override
            public void onMessageSendForHideConversation(String conversationID) {
                ConversationPresenter.this.onMessageSendForHideConversation(conversationID);
            }

            @Override
            public void onConversationDeleted(List<String> conversationIDList) {
                ConversationPresenter.this.onConversationDeleted(conversationIDList);
            }

            @Override
            public void onConversationLastMessageBeanChanged(String conversationID, TUIMessageBean messageBean) {
                ConversationPresenter.this.onConversationLastMessageBeanChanged(conversationID, messageBean);
            }
        };
        TUIConversationService.getInstance().setConversationEventListener(conversationEventListener);
    }

    public void destroy() {
        TUIConversationService.getInstance().setConversationEventListenerNull();
        this.conversationEventListener = null;
    }

    public void setAdapter(IConversationListAdapter adapter) {
        this.adapter = adapter;
    }

    public void setShowType(int showType) {
        this.showType = showType;
    }

    public void loadMoreConversation() {
        provider.loadMoreConversation(GET_CONVERSATION_COUNT, new IUIKitCallback<List<ConversationInfo>>() {
            @Override
            public void onSuccess(List<ConversationInfo> data) {
                onLoadConversationCompleted(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (adapter != null) {
                    adapter.onLoadingStateChanged(false);
                }
            }
        });
    }

    public void reLoadConversation() {}

    protected void onLoadConversationCompleted(List<ConversationInfo> conversationInfoList) {
        onNewConversation(conversationInfoList, false);
        if (adapter != null) {
            adapter.onLoadingStateChanged(false);
            adapter.onViewNeedRefresh();
        }
    }

    protected void refreshUnreadCount() {
        provider.getTotalUnreadMessageCount(new IUIKitCallback<Long>() {
            @Override
            public void onSuccess(Long data) {
                TUIConversationLog.d(TAG, "getTotalUnreadMessageCount: " + data);
                int sdkUnreadCount = data.intValue();
                updateTotalUnreadMessageCount(sdkUnreadCount);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void loadMarkedConversation() {
        TUIConversationLog.i(TAG, "loadMarkedConversation");
        V2TIMConversationListFilter filter = new V2TIMConversationListFilter();
        long markType = V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD | V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD
            | V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_HIDE;
        filter.setMarkType(markType);
        provider.getMarkConversationList(filter, 0, GET_CONVERSATION_COUNT, true, new IUIKitCallback<List<ConversationInfo>>() {
            @Override
            public void onSuccess(List<ConversationInfo> conversationInfoList) {
                if (conversationInfoList.size() == 0) {
                    refreshUnreadCount();
                    return;
                }

                Collections.sort(conversationInfoList);
                for (ConversationInfo conversationInfo : conversationInfoList) {
                    if (conversationInfo.isMarkFold()) {
                        boolean existInFoldList = false;
                        for (int i = 0; i < foldConversationInfoList.size(); i++) {
                            ConversationInfo foldInfo = foldConversationInfoList.get(i);
                            if (TextUtils.equals(conversationInfo.getConversationId(), foldInfo.getConversationId())) {
                                existInFoldList = true;
                                break;
                            }
                        }
                        if (!existInFoldList) {
                            foldConversationInfoList.add(conversationInfo);
                        }
                    }
                    if (conversationInfo.isMarkHidden()) {
                        markUnreadAndHiddenMap.put(conversationInfo.getConversationId(), conversationInfo);
                    }
                    if (conversationInfo.isMarkUnread()) {
                        markUnreadAndHiddenMap.put(conversationInfo.getConversationId(), conversationInfo);
                    }
                }

                ConversationInfo firstChangedFoldInfo = getFirstFoldInfo();
                if (firstChangedFoldInfo != null) {
                    List<ConversationInfo> changedInfoList = new ArrayList<>();
                    changedInfoList.add(firstChangedFoldInfo);
                    onConversationChanged(changedInfoList);
                }

                refreshUnreadCount();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                refreshUnreadCount();
                TUIConversationLog.e(TAG, "loadMarkedConversation error:" + errCode + ", " + errMsg);
            }
        });
    }

    protected boolean updateMarkedUnreadAndHiddenList(List<ConversationInfo> conversationList) {
        boolean isChanged = false;
        for (ConversationInfo conversationInfo : conversationList) {
            if (conversationInfo.isMarkUnread() || conversationInfo.isMarkHidden()) {
                ConversationInfo cached = markUnreadAndHiddenMap.get(conversationInfo.getConversationId());
                markUnreadAndHiddenMap.put(conversationInfo.getConversationId(), conversationInfo);
                if (cached == null) {
                    isChanged = true;
                } else {
                    if (cached.isMarkUnread() != conversationInfo.isMarkUnread() || cached.isMarkHidden() != conversationInfo.isMarkHidden()) {
                        isChanged = true;
                    }
                }
            } else {
                ConversationInfo cacheConversation = markUnreadAndHiddenMap.get(conversationInfo.getConversationId());
                if (cacheConversation != null) {
                    markUnreadAndHiddenMap.remove(conversationInfo.getConversationId());
                    isChanged = true;
                }
            }
        }

        return isChanged;
    }

    private void loadAndSubscribeConversationUserStatus(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "loadAndSubscribeConversationUserStatus");
        provider.loadConversationUserStatus(conversationInfoList, new IUIKitCallback<Map<String, ConversationUserStatusBean>>() {
            @Override
            public void onSuccess(Map<String, ConversationUserStatusBean> data) {
                List<ConversationInfo> changedConversations = new ArrayList<>();
                for (ConversationInfo conversationInfo : loadedConversationInfoList) {
                    if (!conversationInfo.isGroup()) {
                        String userID = conversationInfo.getId();
                        if (data.containsKey(userID)) {
                            ConversationUserStatusBean statusBean = data.get(userID);
                            if (statusBean != null) {
                                conversationInfo.setStatusType(statusBean.getStatusType());
                                changedConversations.add(conversationInfo);
                            }
                        }
                    }
                }
                TUIConversationLog.i(TAG, "on load user status success");
                onConversationChanged(changedConversations);
            }

            @Override
            public void onError(String module, int code, String desc) {
                TUIConversationLog.e(TAG, "loadConversationUserStatus code:" + code + "|desc:" + desc);
            }
        });

        List<String> userIdList = new ArrayList<>();
        for (ConversationInfo conversationInfo : conversationInfoList) {
            if (conversationInfo.isGroup()) {
                continue;
            }
            userIdList.add(conversationInfo.getId());
        }
        provider.subscribeConversationUserStatus(userIdList, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUIConversationLog.d(TAG, "subscribeConversationUserStatus success");
            }

            @Override
            public void onError(String module, int code, String desc) {
                TUIConversationLog.e(TAG, "subscribeConversationUserStatus code:" + code + "|desc:" + desc);
            }
        });
    }

    public boolean isLoadFinished() {
        return provider.isLoadFinished();
    }

    public void onNewConversation(List<ConversationInfo> conversationInfoList, boolean showFoldItem) {
        TUIConversationLog.i(TAG, "onNewConversation conversations:" + conversationInfoList);
        getLastMessageBean(conversationInfoList);
        ArrayList<ConversationInfo> infos = new ArrayList<>();
        for (ConversationInfo conversationInfo : conversationInfoList) {
            if (!ConversationUtils.isIgnored(conversationInfo) && !conversationInfo.isMarkHidden()) {
                if (showType == SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD) {
                    if (!conversationInfo.isMarkFold() || showFoldItem) {
                        TUIConversationLog.i(TAG, "onNewConversation conversationInfo " + conversationInfo.toString());
                        infos.add(conversationInfo);
                    }
                } else {
                    TUIConversationLog.i(TAG, "onNewConversation conversationInfo " + conversationInfo.toString());
                    infos.add(conversationInfo);
                }
            }
        }
        if (infos.isEmpty()) {
            return;
        }

        List<ConversationInfo> uiSourceInfoList;
        if (showType == SHOW_TYPE_CONVERSATION_LIST) {
            uiSourceInfoList = loadedConversationInfoList;
        } else if (showType == SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD) {
            uiSourceInfoList = loadedConversationInfoList;
        } else {
            uiSourceInfoList = foldConversationInfoList;
        }

        List<ConversationInfo> exists = new ArrayList<>();
        Iterator<ConversationInfo> iterator = infos.iterator();
        while (iterator.hasNext()) {
            ConversationInfo update = iterator.next();
            for (int i = 0; i < uiSourceInfoList.size(); i++) {
                ConversationInfo cacheInfo = uiSourceInfoList.get(i);

                if (cacheInfo.getConversationId().equals(update.getConversationId())) {
                    if (update.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN) {
                        update.setStatusType(cacheInfo.getStatusType());
                    }
                    uiSourceInfoList.set(i, update);
                    iterator.remove();
                    exists.add(update);
                    break;
                }
            }
        }

        Collections.sort(infos);
        uiSourceInfoList.addAll(infos);
        if (adapter != null) {
            Collections.sort(uiSourceInfoList);
            adapter.onDataSourceChanged(uiSourceInfoList);
            for (ConversationInfo info : infos) {
                int index = uiSourceInfoList.indexOf(info);
                if (index != -1) {
                    adapter.onItemInserted(index);
                }
            }

            for (ConversationInfo info : exists) {
                int index = uiSourceInfoList.indexOf(info);
                if (index != -1) {
                    adapter.onItemChanged(index);
                }
            }
        }

        loadAndSubscribeConversationUserStatus(conversationInfoList);
    }

    public void onConversationChanged(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "onConversationChanged conversations:" + conversationInfoList);
        getLastMessageBean(conversationInfoList);

        List<ConversationInfo> uiSourceInfoList;
        ArrayList<ConversationInfo> infoList;
        infoList = processHiddenConversation(conversationInfoList);

        ArrayList<ConversationInfo> changedInfoList;
        if (showType == SHOW_TYPE_CONVERSATION_LIST) {
            uiSourceInfoList = loadedConversationInfoList;
            changedInfoList = processConversationList(infoList);
        } else {
            uiSourceInfoList = loadedConversationInfoList;
            changedInfoList = processConversationListWithFold(infoList);
        }

        if (changedInfoList.size() == 0) {
            return;
        }

        if (adapter != null) {
            adapter.onConversationChanged(changedInfoList);
        }
        refreshChangedInfo(uiSourceInfoList, changedInfoList);
    }

    private void refreshChangedInfo(List<ConversationInfo> uiSourceInfoList, List<ConversationInfo> changedInfoList) {
        Collections.sort(changedInfoList);

        HashMap<ConversationInfo, Integer> indexMap = new HashMap<>();
        for (int j = 0; j < changedInfoList.size(); j++) {
            ConversationInfo update = changedInfoList.get(j);
            for (int i = 0; i < uiSourceInfoList.size(); i++) {
                ConversationInfo cacheInfo = uiSourceInfoList.get(i);

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

    private ArrayList<ConversationInfo> processHiddenConversation(List<ConversationInfo> infoList) {
        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        //  1.1 ui had loaded data
        //   1.1.1 hidden status, to delete it from ui data
        //   1.1.2 not hidden status, to collect it in changed list
        //  1.2 ui not loaded, to collect it in changed list
        for (ConversationInfo conversationInfo : infoList) {
            int uiIndex = -1;
            for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                ConversationInfo loadedInfo = loadedConversationInfoList.get(i);
                if (TextUtils.equals(conversationInfo.getConversationId(), loadedInfo.getConversationId())) {
                    uiIndex = i;
                    break;
                }
            }
            if (uiIndex >= 0 && conversationInfo.isMarkHidden()) {
                loadedConversationInfoList.remove(uiIndex);
                if (adapter != null) {
                    adapter.onItemRemoved(uiIndex);
                }
                if (mUIFoldConversation != null) {
                    if (TextUtils.equals(conversationInfo.getConversationId(), mUIFoldConversation.getConversationId())) {
                        mUIFoldConversation = null;
                        changedInfoList.add(conversationInfo);
                    }
                }
            } else {
                changedInfoList.add(conversationInfo);
            }
        }

        return changedInfoList;
    }

    private ArrayList<ConversationInfo> processConversationList(List<ConversationInfo> conversationInfoList) {
        ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        for (ConversationInfo conversationInfo : conversationInfoList) {
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
            onNewConversation(addInfoList, true);
        }

        return changedInfoList;
    }

    private ArrayList<ConversationInfo> processConversationListWithFold(List<ConversationInfo> conversationInfoList) {
        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
        // process conversation list: add to fold list/update fold
        // list/delete from fold list/add to ui list/update in ui list
        // 1、 exist in fold list
        //  1.1  is folded status, replace it from fold list
        //  1.2 is not folded status, delete it from fold list, and collect it in added list
        // 2、 not exist in fold list
        //  2.1  is folded status, insert to fold list, and delete it from ui list
        //  2.2  is not folded status, if in ui list then update it, if not, insert it to ui list
        for (ConversationInfo conversationInfo : conversationInfoList) {
            if (ConversationUtils.isIgnored(conversationInfo)) {
                continue;
            }
            int foldIndex = -1;
            for (int i = 0; i < foldConversationInfoList.size(); i++) {
                ConversationInfo foldInfo = foldConversationInfoList.get(i);
                if (TextUtils.equals(foldInfo.getConversationId(), conversationInfo.getConversationId())) {
                    foldIndex = i;
                    break;
                }
            }
            if (foldIndex >= 0) {
                // 1  exist in fold list
                if (conversationInfo.isMarkFold()) {
                    // 1.1  if is folded, then replace
                    foldConversationInfoList.set(foldIndex, conversationInfo);
                } else {
                    // 1.2  if if not folded, delete it from folded list, and insert to added list
                    foldConversationInfoList.remove(foldIndex);
                    addInfoList.add(conversationInfo);
                }
            } else {
                // 2  not exist in fold list
                //  if ui list exist or not
                int uiIndex = -1;
                for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                    ConversationInfo loadedInfo = loadedConversationInfoList.get(i);
                    if (TextUtils.equals(conversationInfo.getConversationId(), loadedInfo.getConversationId())) {
                        uiIndex = i;
                        break;
                    }
                }
                if (conversationInfo.isMarkFold()) {
                    // 2.1  is folded status, insert to fold list
                    foldConversationInfoList.add(conversationInfo);
                    //  if find it in ui list, delete it
                    if (uiIndex >= 0) {
                        loadedConversationInfoList.remove(uiIndex);
                        if (adapter != null) {
                            adapter.onItemRemoved(uiIndex);
                        }
                    }
                } else {
                    // 2.2  is not folded status, if exist in ui list then update it, if not, insert it
                    if (uiIndex >= 0) {
                        TUIConversationLog.i(TAG, "onConversationChanged conversationInfo " + conversationInfo);
                        changedInfoList.add(conversationInfo);
                    } else {
                        addInfoList.add(conversationInfo);
                    }
                }
            }
        }
        //  process fold info item and fold list in main ui
        // 1、 fold list size > 0
        //  1.1  sort list, then compare the first which not mark hidden and fold this item in ui
        //   1.1.1  is the same conversation, insert to changed list, and replace cache info
        //   1.1.2  is not the same conversation, delete
        //   the fold item from ui first, then insert it to added list and update cache info
        //   1.1.3 info not exist, insert it to added list, and update cache info
        // 2、 fold list is empty, delete fold item from ui and clear cache info
        if (!hideFoldItem) {
            ConversationInfo firstChangedFoldInfo = getFirstFoldInfo();
            if (foldConversationInfoList.size() > 0 && firstChangedFoldInfo != null) {
                // 1
                if (mUIFoldConversation != null) {
                    if (mUIFoldConversation != firstChangedFoldInfo) {
                        if (TextUtils.equals(mUIFoldConversation.getConversationId(), firstChangedFoldInfo.getConversationId())) {
                            // 1.1.1
                            changedInfoList.add(firstChangedFoldInfo);
                            mUIFoldConversation = firstChangedFoldInfo;
                            mUIFoldConversation.setMarkLocalUnread(isUnreadStatusOfFoldItem);
                        } else {
                            // 1.1.2
                            int uiIndex = loadedConversationInfoList.indexOf(mUIFoldConversation);
                            if (uiIndex != -1) {
                                loadedConversationInfoList.remove(uiIndex);
                                loadedConversationInfoList.add(firstChangedFoldInfo);
                                Collections.sort(loadedConversationInfoList);
                                int newIndex = loadedConversationInfoList.indexOf(firstChangedFoldInfo);
                                if (uiIndex == newIndex) {
                                    if (adapter != null) {
                                        adapter.onItemChanged(newIndex);
                                    }
                                } else {
                                    if (adapter != null) {
                                        adapter.onItemMoved(uiIndex, newIndex);
                                    }
                                }
                            } else {
                                addInfoList.add(firstChangedFoldInfo);
                            }
                            mUIFoldConversation = firstChangedFoldInfo;
                            mUIFoldConversation.setMarkLocalUnread(isUnreadStatusOfFoldItem);
                        }
                    }
                } else {
                    // 1.1.3
                    addInfoList.add(firstChangedFoldInfo);
                    mUIFoldConversation = firstChangedFoldInfo;
                    mUIFoldConversation.setMarkLocalUnread(isUnreadStatusOfFoldItem);
                }
            } else {
                // 2
                hideFoldItemFromUI();
            }
        } else {
            hideFoldItemFromUI();
        }

        if (!addInfoList.isEmpty()) {
            onNewConversation(addInfoList, true);
        }

        return changedInfoList;
    }

    protected void processNewMessage(String conversationID, boolean isTypingMessage) {
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

        boolean existInFoldList = false;
        ConversationInfo foldedConversation = null;
        for (ConversationInfo conversationInfo : foldConversationInfoList) {
            if (TextUtils.equals(conversationID, conversationInfo.getConversationId())) {
                existInFoldList = true;
                foldedConversation = conversationInfo;
                break;
            }
        }

        if (existInFoldList) {
            if (hideFoldItem) {
                showFoldItem(foldedConversation);
            }
            setUnreadStatusOfFoldItem(true);
        }

        if (cacheInfo != null) {
            if (cacheInfo.isMarkUnread()) {
                markConversationRead(cacheInfo.getConversationId(), null);
            }
        } else {
            provider.getConversation(conversationID, new IUIKitCallback<ConversationInfo>() {
                @Override
                public void onSuccess(ConversationInfo conversationInfo) {
                    if (conversationInfo.isMarkHidden()) {
                        markConversationHidden(conversationInfo, false);
                    }
                    if (conversationInfo.isMarkUnread()) {
                        markConversationUnreadAndCleanUnreadCount(conversationInfo, false);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {}
            });

            // if new message is belong to one of the foldedConversationInfoList, then show fold item
            if (existInFoldList) {
                hideFoldItem(false);
            }
        }
    }

    public void hideFoldItem(boolean needHide) {
        String loginUserID = TUILogin.getLoginUser();
        SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME)
            .put(TUIConversationConstants.HIDE_FOLD_ITEM_SP_KEY_PREFIX + loginUserID, needHide);
        hideFoldItem = needHide;
        if (needHide) {
            hideFoldItemFromUI();
        }
    }

    public void showFoldItem(ConversationInfo conversationInfo) {
        hideFoldItem(false);
        mUIFoldConversation = conversationInfo;
        onNewConversation(Collections.singletonList(conversationInfo), true);
    }

    private void hideFoldItemFromUI() {
        if (mUIFoldConversation != null) {
            int uiIndex = loadedConversationInfoList.indexOf(mUIFoldConversation);
            if (uiIndex != -1) {
                loadedConversationInfoList.remove(uiIndex);
                if (adapter != null) {
                    adapter.onItemRemoved(uiIndex);
                }
                mUIFoldConversation = null;
            }
        }
    }

    public void setUnreadStatusOfFoldItem(boolean isUnread) {
        String loginUserID = TUILogin.getLoginUser();
        SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME)
            .put(TUIConversationConstants.FOLD_ITEM_IS_UNREAD_SP_KEY_PREFIX + loginUserID, isUnread);
        isUnreadStatusOfFoldItem = isUnread;
        if (mUIFoldConversation == null) {
            return;
        }
        mUIFoldConversation.setMarkLocalUnread(isUnread);

        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        changedInfoList.add(mUIFoldConversation);
        List<ConversationInfo> uiSourceInfoList = loadedConversationInfoList;
        refreshChangedInfo(uiSourceInfoList, changedInfoList);
    }

    private ConversationInfo getFirstFoldInfo() {
        Collections.sort(foldConversationInfoList);
        ConversationInfo firstChangedFoldInfo = null;
        for (ConversationInfo conversationInfo : foldConversationInfoList) {
            if (!conversationInfo.isMarkHidden()) {
                firstChangedFoldInfo = conversationInfo;
                break;
            }
        }
        return firstChangedFoldInfo;
    }

    protected List<ConversationInfo> getMarkUnreadConversationList() {
        List<ConversationInfo> conversationInfos = new ArrayList<>();

        Iterator<Map.Entry<String, ConversationInfo>> iterator = markUnreadAndHiddenMap.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ConversationInfo> entry = iterator.next();
            ConversationInfo conversationInfo = entry.getValue();
            if (conversationInfo.isShowDisturbIcon()) {
                continue;
            }

            if (conversationInfo.isMarkUnread()) {
                conversationInfos.add(conversationInfo);
            }
        }

        return conversationInfos;
    }

    protected void updateTotalUnreadMessageCount(long sdkUnreadCount) {
        int markUnreadCount = 0;
        int markHiddenCount = 0;
        Iterator<Map.Entry<String, ConversationInfo>> iterator = markUnreadAndHiddenMap.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ConversationInfo> entry = iterator.next();
            ConversationInfo conversationInfo = entry.getValue();
            if (conversationInfo.isShowDisturbIcon()) {
                continue;
            }

            if (conversationInfo.isMarkHidden()) {
                markHiddenCount += conversationInfo.getUnRead();
            } else if (conversationInfo.isMarkUnread()) {
                markUnreadCount++;
            }
        }

        TUIConversationLog.i(TAG,
            "updateTotalUnreadMessageCount sdkUnreadCount:" + sdkUnreadCount + ", markUnreadCount:" + markUnreadCount + ", markHiddenCount:" + markHiddenCount);

        totalUnreadCount = sdkUnreadCount + markUnreadCount - markHiddenCount;
        if (totalUnreadCount < 0) {
            totalUnreadCount = 0;
        }
        TUIConversationService.getInstance().setConversationAllGroupUnreadDiff(markUnreadCount - markHiddenCount);
        updateUnreadTotal(totalUnreadCount);
    }

    /**
     *
     *
     * @param unreadTotal
     */
    public void updateUnreadTotal(long unreadTotal) {
        TUIConversationLog.i(TAG, "updateUnreadTotal:" + unreadTotal);
        totalUnreadCount = unreadTotal;
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT, totalUnreadCount);
        TUICore.notifyEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, param);

        Intent intent = new Intent();
        intent.setAction(TUIConstants.CONVERSATION_UNREAD_COUNT_ACTION);
        intent.putExtra(TUIConstants.UNREAD_COUNT_EXTRA, totalUnreadCount);
        LocalBroadcastManager.getInstance(TUIConversationService.getAppContext()).sendBroadcast(intent);
    }

    public void updateUnreadTotalByDiff(int diff) {
        provider.getTotalUnreadMessageCount(new IUIKitCallback<Long>() {
            @Override
            public void onSuccess(Long data) {
                int sdkUnreadCount = data.intValue();
                TUIConversationLog.i(TAG, "updateUnreadTotalByDiff:" + sdkUnreadCount);
                totalUnreadCount = sdkUnreadCount + diff;
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT, totalUnreadCount);
                TUICore.notifyEvent(TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, param);

                Intent intent = new Intent();
                intent.setAction(TUIConstants.CONVERSATION_UNREAD_COUNT_ACTION);
                intent.putExtra(TUIConstants.UNREAD_COUNT_EXTRA, totalUnreadCount);
                LocalBroadcastManager.getInstance(TUIConversationService.getAppContext()).sendBroadcast(intent);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void setConversationTop(final ConversationInfo conversation, final IUIKitCallback<Void> callBack) {
        TUIConversationLog.i(TAG,
            "setConversationTop"
                + "|conversation:" + conversation);
        final boolean setTop = !conversation.isTop();

        provider.setConversationTop(conversation.getConversationId(), setTop, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                conversation.setTop(setTop);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(TAG, "setConversationTop code:" + errCode + "|desc:" + errMsg);
                if (callBack != null) {
                    callBack.onError("setConversationTop", errCode, errMsg);
                }
            }
        });
    }

    public void setConversationTop(String id, final boolean isTop, final IUIKitCallback<Void> callBack) {
        TUIConversationLog.i(TAG, "setConversationTop id:" + id + "|isTop:" + isTop);
        ConversationInfo conversation = null;
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (info.getId().equals(id)) {
                conversation = info;
                break;
            }
        }
        if (conversation == null) {
            return;
        }
        final ConversationInfo conversationInfo = conversation;
        final String conversationId = conversation.getConversationId();
        provider.setConversationTop(conversationId, isTop, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                conversationInfo.setTop(isTop);
                TUIConversationUtils.callbackOnSuccess(callBack, null);
            }

            @Override
            public void onError(String module, int code, String desc) {
                TUIConversationLog.e(TAG, "setConversationTop code:" + code + "|desc:" + desc);
                if (callBack != null) {
                    callBack.onError("setConversationTop", code, desc);
                }
            }
        });
    }

    public boolean isTopConversation(String conversationID) {
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (info.getId().equals(conversationID)) {
                return info.isTop();
            }
        }
        return false;
    }

    public void deleteConversation(ConversationInfo conversation) {
        TUIConversationLog.i(TAG, "deleteConversation conversation:" + conversation);
        if (conversation == null) {
            return;
        }
        provider.deleteConversation(conversation.getConversationId(), new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                int index = loadedConversationInfoList.indexOf(conversation);
                boolean isRemove = loadedConversationInfoList.remove(conversation);
                if (adapter != null && isRemove && index != -1) {
                    adapter.onItemRemoved(index);
                }

                String conversationId = conversation.getConversationId();
                ConversationInfo cacheConversation = markUnreadAndHiddenMap.get(conversationId);
                if (cacheConversation != null) {
                    markUnreadAndHiddenMap.remove(conversationId);
                    refreshUnreadCount();
                }

                if (mUIFoldConversation == null) {
                    return;
                }

                Iterator<ConversationInfo> iterator = foldConversationInfoList.iterator();
                while (iterator.hasNext()) {
                    ConversationInfo cacheConversationInfo = iterator.next();
                    if (TextUtils.equals(conversationId, cacheConversationInfo.getConversationId())) {
                        iterator.remove();
                        break;
                    }
                }

                if (!TextUtils.equals(conversationId, mUIFoldConversation.getConversationId())) {
                    return;
                }

                mUIFoldConversation = null;
                for (ConversationInfo conversationInfo : foldConversationInfoList) {
                    if (!conversationInfo.isMarkHidden()) {
                        mUIFoldConversation = conversationInfo;
                        ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
                        addInfoList.add(mUIFoldConversation);
                        onNewConversation(addInfoList, true);
                        break;
                    }
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void deleteConversation(String id, boolean isGroup) {
        ConversationInfo conversationInfo = null;
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (isGroup == info.isGroup() && info.getId().equals(id)) {
                conversationInfo = info;
                break;
            }
        }

        if (conversationInfo == null) {
            String conversationID;
            if (isGroup) {
                conversationID = TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX + id;
            } else {
                conversationID = TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX + id;
            }

            conversationInfo = new ConversationInfo();
            conversationInfo.setConversationId(conversationID);
        }

        deleteConversation(conversationInfo);
    }

    public void clearConversationMessage(ConversationInfo conversation) {
        if (conversation == null || TextUtils.isEmpty(conversation.getConversationId())) {
            TUIConversationLog.e(TAG, "clearConversationMessage error: invalid conversation");
            return;
        }

        provider.clearHistoryMessage(conversation.getId(), conversation.isGroup(), new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {}

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void clearConversationMessage(String chatId, boolean isGroup) {
        provider.clearHistoryMessage(chatId, isGroup, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {}

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void markConversationHidden(ConversationInfo conversationInfo, boolean isHidden) {
        if (conversationInfo == null || TextUtils.isEmpty(conversationInfo.getConversationId())) {
            TUIConversationLog.e(TAG, "markConversationHidden error: invalid conversationInfo");
            return;
        }

        provider.markConversationHidden(conversationInfo.getConversationId(), isHidden, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                conversationInfo.setMarkHidden(isHidden);
                TUIConversationLog.i(TAG, "markConversationHidden success, conversationID:" + conversationInfo.getConversationId() + ", isHidden:" + isHidden);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(
                    TAG, "markConversationHidden error, conversationID:" + conversationInfo.getConversationId() + ", code:" + errCode + "|msg:" + errMsg);
            }
        });
    }

    public void markConversationUnreadAndCleanUnreadCount(ConversationInfo conversationInfo, boolean markUnread) {
        if (conversationInfo == null || TextUtils.isEmpty(conversationInfo.getConversationId())) {
            TUIConversationLog.e(TAG, "markConversationUnread error: invalid conversationInfo");
            return;
        }

        provider.markConversationUnread(conversationInfo, markUnread, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                conversationInfo.setMarkUnread(markUnread);
                TUIConversationLog.i(TAG, "markConversationRead success, conversationID:" + conversationInfo.getConversationId());
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(
                    TAG, "markConversationRead error, conversationID:" + conversationInfo.getConversationId() + ", code:" + errCode + "|msg:" + errMsg);
            }
        });
    }

    public void markConversationUnread(String conversationID, TUICallback callback) {
        provider.markConversationUnread(conversationID, callback);
    }

    public void markConversationRead(String conversationID, TUICallback callback) {
        provider.markConversationRead(conversationID, callback);
    }

    public void cleanConversationUnreadCount(String conversationID, TUICallback callback) {
        provider.cleanConversationUnreadCount(conversationID, callback);
    }

    public void clearFoldMarkAndDeleteConversation(String conversationId) {
        if (TextUtils.isEmpty(conversationId)) {
            return;
        }
        ConversationInfo conversationInfo = null;
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (info.getConversationId().equals(conversationId)) {
                conversationInfo = info;
                break;
            }
        }

        if (conversationInfo == null) {
            return;
        }

        if (conversationInfo.isMarkFold()) {
            ConversationInfo finalConversationInfo = conversationInfo;
            provider.markConversationFold(conversationId, false, new IUIKitCallback<Void>() {
                @Override
                public void onSuccess(Void data) {
                    deleteConversation(finalConversationInfo);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIConversationLog.e(TAG, "markConversationFold error, conversationID:" + conversationId + ", code:" + errCode + "|msg:" + errMsg);
                }
            });
        } else {
            deleteConversation(conversationInfo);
        }
    }

    public void onFriendRemarkChanged(String id, String remark) {
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (info.getId().equals(id) && !info.isGroup()) {
                String title = info.getShowName();
                if (!TextUtils.isEmpty(remark)) {
                    title = remark;
                }
                info.setTitle(title);
                if (adapter != null) {
                    adapter.onDataSourceChanged(loadedConversationInfoList);
                    adapter.onItemChanged(i);
                }
                break;
            }
        }
    }

    public void onMessageSendForHideConversation(String id) {
        if (TextUtils.isEmpty(id)) {
            return;
        }

        boolean isHide = false;
        ConversationInfo conversationInfo = markUnreadAndHiddenMap.get(id);
        if (conversationInfo != null && conversationInfo.isMarkHidden()) {
            isHide = true;
        }

        if (!isHide) {
            return;
        }

        provider.markConversationHidden(id, false, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUIConversationLog.i(TAG, "onMessageSendForHideConversation markConversationHidden success, conversationID:" + id + ", isHidden:false");
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(
                    TAG, "onMessageSendForHideConversation markConversationHidden error, conversationID:" + id + ", code:" + errCode + "|msg:" + errMsg);
            }
        });
    }

    public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList) {
        if (!TUIConversationConfig.getInstance().isShowUserStatus()) {
            return;
        }
        HashMap<String, Pair<Integer, ConversationInfo>> dataSourceMap = new HashMap<>();
        int index = 0;
        for (ConversationInfo itemBean : loadedConversationInfoList) {
            dataSourceMap.put(itemBean.getId(), Pair.create(index++, itemBean));
        }

        for (V2TIMUserStatus timUserStatus : userStatusList) {
            String userid = timUserStatus.getUserID();
            Pair<Integer, ConversationInfo> beanPair = dataSourceMap.get(userid);
            if (beanPair == null) {
                continue;
            }
            ConversationInfo bean = dataSourceMap.get(userid).second;
            int position = dataSourceMap.get(userid).first;
            if (bean != null && bean.getStatusType() != timUserStatus.getStatusType()) {
                bean.setStatusType(timUserStatus.getStatusType());
                if (adapter != null) {
                    adapter.onDataSourceChanged(loadedConversationInfoList);
                    adapter.onItemChanged(position);
                }
            }
        }
    }

    public void clearAllUnreadMessage() {
        provider.clearAllUnreadMessage(new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {}

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public void updateAdapter() {
        if (adapter != null) {
            adapter.onViewNeedRefresh();
        }
    }

    public void onConversationDeleted(List<String> conversationIdList) {
        TUIConversationLog.i(TAG, "onConversationDeleted conversations:" + conversationIdList);

        if (conversationIdList == null || conversationIdList.isEmpty()) {
            return;
        }

        for (String conversationId : conversationIdList) {
            deleteConversationById(conversationId);
        }
    }

    public void onDeleteConversation(List<ConversationInfo> conversationInfoList) {
        if (conversationInfoList == null || conversationInfoList.isEmpty()) {
            return;
        }

        for (ConversationInfo conversation : conversationInfoList) {
            deleteConversationById(conversation.getConversationId());
        }
    }

    private void deleteConversationById(String conversationId) {
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (info.getConversationId().equals(conversationId)) {
                loadedConversationInfoList.remove(i);
                if (adapter != null) {
                    adapter.onItemRemoved(i);
                }
                break;
            }
        }

        ConversationInfo cacheConversation = markUnreadAndHiddenMap.get(conversationId);
        if (cacheConversation != null) {
            markUnreadAndHiddenMap.remove(conversationId);
            refreshUnreadCount();
        }

        if (mUIFoldConversation == null) {
            return;
        }

        if (!TextUtils.equals(conversationId, mUIFoldConversation.getConversationId())) {
            return;
        }

        mUIFoldConversation = null;
        Iterator<ConversationInfo> iterator = foldConversationInfoList.iterator();
        while (iterator.hasNext()) {
            ConversationInfo cacheConversationInfo = iterator.next();
            if (TextUtils.equals(conversationId, cacheConversationInfo.getConversationId())) {
                iterator.remove();
                break;
            }
        }

        for (ConversationInfo conversationInfo : foldConversationInfoList) {
            if (!conversationInfo.isMarkHidden()) {
                mUIFoldConversation = conversationInfo;
                ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
                addInfoList.add(mUIFoldConversation);
                onNewConversation(addInfoList, true);
                break;
            }
        }
    }

    private void getLastMessageBean(List<ConversationInfo> conversationInfoList) {
        if (conversationInfoList == null || conversationInfoList.isEmpty()) {
            return;
        }

        Map<String, TUIMessageBean> messageBeanMap = new HashMap<>();
        for (ConversationInfo conversationInfo : conversationInfoList) {
            if (conversationInfo.getLastMessage() != null && conversationInfo.getLastTUIMessageBean() == null) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIChat.Method.GetTUIMessageBean.V2TIM_MESSAGE, conversationInfo.getLastMessage());
                Object messageBeanObj = TUICore.callService(
                        TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.Method.GetTUIMessageBean.METHOD_NAME, param);
                if (messageBeanObj instanceof TUIMessageBean) {
                    TUIMessageBean messageBean = (TUIMessageBean) messageBeanObj;
                    if (messageBean.needAsyncGetDisplayString()) {
                        messageBeanMap.put(conversationInfo.getConversationId(), messageBean);
                        continue;
                    }
                    conversationInfo.setLastTUIMessageBean(messageBean);
                }
            }
        }

        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Method.GetMessagesDisplayString.MESSAGE_MAP, messageBeanMap);
        TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.Method.GetMessagesDisplayString.METHOD_NAME, param);
    }

    protected void onConversationLastMessageBeanChanged(String conversationID, TUIMessageBean messageBean) {
        ConversationInfo changedInfo = null;
        for (ConversationInfo conversationInfo : loadedConversationInfoList) {
            if (TextUtils.equals(conversationInfo.getConversationId(), conversationID)) {
                if (conversationInfo.getLastMessage() != null) {
                    String msgID = conversationInfo.getLastMessage().getMsgID();
                    if (TextUtils.equals(msgID, messageBean.getId())) {
                        conversationInfo.setLastTUIMessageBean(messageBean);
                        changedInfo = conversationInfo;
                        break;
                    }
                }
            }
        }
        if (changedInfo == null) {
            return;
        }
        List<ConversationInfo> changedInfoList = new ArrayList<>();
        changedInfoList.add(changedInfo);
        if (adapter != null) {
            adapter.onConversationChanged(changedInfoList);
        }
        refreshChangedInfo(loadedConversationInfoList, changedInfoList);
    }

    public static String getMessageDisplayString(TUIMessageBean messageBean) {
        if (messageBean == null) {
            return "";
        }
        String displayString;
        if (messageBean.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            displayString = getRevokeMessageDisplayString(messageBean);
        } else {
            displayString = messageBean.onGetDisplayString();
        }
        displayString = FaceUtil.emojiJudge(displayString);
        return displayString;
    }

    public static String getRevokeMessageDisplayString(TUIMessageBean msg) {
        Context context = TUIConversationService.getAppContext();
        if (context == null) {
            return "";
        }
        String showString;
        String revoker = msg.getSender();
        String messageSender = msg.getSender();
        UserBean revokerBean = msg.getRevoker();
        if (revokerBean != null && !TextUtils.isEmpty(revokerBean.getUserId())) {
            revoker = revokerBean.getUserId();
        }
        if (TextUtils.equals(revoker, messageSender)) {
            if (msg.isSelf()) {
                showString = context.getResources().getString(com.tencent.qcloud.tuikit.timcommon.R.string.revoke_tips_you);
            } else {
                if (!msg.isGroup()) {
                    showString = context.getResources().getString(com.tencent.qcloud.tuikit.timcommon.R.string.revoke_tips_other);
                } else {
                    String operatorName = msg.getUserDisplayName();
                    showString = operatorName + context.getResources().getString(com.tencent.qcloud.tuikit.timcommon.R.string.revoke_tips);
                }
            }
        } else {
            String operatorName = revoker;
            if (revokerBean != null) {
                operatorName = revokerBean.getDisplayString();
            }
            showString = operatorName + context.getResources().getString(com.tencent.qcloud.tuikit.timcommon.R.string.revoke_tips);
        }
        return showString;
    }
}