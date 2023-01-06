package com.tencent.qcloud.tuikit.tuiconversation.presenter;

import android.content.Intent;
import android.text.TextUtils;
import android.util.Pair;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
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

    public final static int SHOW_TYPE_CONVERSATION_LIST = 0;
    public final static int SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD = 1;

    private int showType = SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD;

    private final static int GET_CONVERSATION_COUNT = 100;

    ConversationEventListener conversationEventListener;

    private final ConversationProvider provider;

    private IConversationListAdapter adapter;

    private final List<ConversationInfo> loadedConversationInfoList = new ArrayList<>();
    private List<ConversationInfo> foldConversationInfoList = new ArrayList<>();

    private ConversationInfo mUIFoldConversation;

    private HashMap<String, ConversationInfo> markUnreadAndHiddenMap = new HashMap<>();

    private long totalUnreadCount;

    private boolean hideFoldItem;
    private boolean isUnreadStatusOfFoldItem;

    public ConversationPresenter() {
        provider = new ConversationProvider();
        String loginUserID = TUILogin.getLoginUser();
        hideFoldItem = SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME).
                getBoolean(TUIConversationConstants.HIDE_FOLD_ITEM_SP_KEY_PREFIX + loginUserID, false);
        isUnreadStatusOfFoldItem = SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME).
                getBoolean(TUIConversationConstants.FOLD_ITEM_IS_UNREAD_SP_KEY_PREFIX + loginUserID, false);
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
                loadConversation(0);
                ConversationPresenter.this.loadMarkedConversation();
            }

            @Override
            public void updateTotalUnreadMessageCount(long count) {
                ConversationPresenter.this.updateTotalUnreadMessageCount(count);
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
        };
        TUIConversationService.getInstance().setConversationEventListener(conversationEventListener);
    }

    public void setAdapter(IConversationListAdapter adapter) {
        this.adapter = adapter;
    }

    public void setShowType(int showType) {
        this.showType = showType;
    }

    /**
     * 加载会话信息
     *
     * @param nextSeq 分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
     */
    public void loadConversation(long nextSeq) {
        TUIConversationLog.i(TAG, "loadConversation");
        provider.loadConversation(nextSeq, GET_CONVERSATION_COUNT, new IUIKitCallback<List<ConversationInfo>>() {
            @Override
            public void onSuccess(List<ConversationInfo> conversationInfoList) {
                onLoadConversationCompleted(conversationInfoList);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (adapter != null) {
                    adapter.onLoadingStateChanged(false);
                }
            }
        });
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

    private void onLoadConversationCompleted(List<ConversationInfo> conversationInfoList) {
        onNewConversation(conversationInfoList, false);
        if (adapter != null) {
            adapter.onLoadingStateChanged(false);
        }
    }

    private void refreshUnreadCount() {
        provider.getTotalUnreadMessageCount(new IUIKitCallback<Long>() {
            @Override
            public void onSuccess(Long data) {
                int sdkUnreadCount = data.intValue();
                updateTotalUnreadMessageCount(sdkUnreadCount);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    private void loadMarkedConversation() {
        TUIConversationLog.i(TAG, "loadMarkedConversation");
        V2TIMConversationListFilter filter = new V2TIMConversationListFilter();
        long markType = V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD |
                V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD |
                V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_HIDE;
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

    private boolean updateMarkedUnreadAndHiddenList(List<ConversationInfo> conversationList) {
        boolean isChanged = false;
        for (ConversationInfo conversationInfo : conversationList) {
            if (conversationInfo.isMarkUnread() || conversationInfo.isMarkHidden()) {
                markUnreadAndHiddenMap.put(conversationInfo.getConversationId(), conversationInfo);
                isChanged = true;
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
        provider.loadConversationUserStatus(conversationInfoList, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                onConversationChanged(conversationInfoList);
            }

            @Override
            public void onError(String module, int code, String desc) {
                TUIConversationLog.e(TAG, "loadConversationUserStatus code:" + code + "|desc:" + desc);
            }
        });

        List<String> userIdList = new ArrayList<>();
        for(ConversationInfo conversationInfo : conversationInfoList) {
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

    /**
     * 有新的会话
     * @param conversationInfoList 新的会话列表
     */
    public void onNewConversation(List<ConversationInfo> conversationInfoList, boolean showFoldItem) {
        TUIConversationLog.i(TAG, "onNewConversation conversations:" + conversationInfoList);

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
        if (infos.size() == 0) {
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
                // 去重
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

        // 对新增会话排序，避免插入 recyclerview 时错乱
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

    /**
     * 部分会话刷新（包括多终端已读上报同步）
     *
     * @param conversationInfoList 需要刷新的会话列表
     */
    public void onConversationChanged(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "onConversationChanged conversations:" + conversationInfoList);

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

        adapter.onConversationChanged(changedInfoList);
        refreshChangedInfo(uiSourceInfoList, changedInfoList);
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

    private ArrayList<ConversationInfo> processHiddenConversation(List<ConversationInfo> infoList) {
        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();
        //  1.1 UI 已加载  ui had loaded data
        //   1.1.1 隐藏状态，则从 UI 删除  hidden status, to delete it from ui data
        //   1.1.2 非隐藏，则收集到更新列表  not hidden status, to collect it in changed list
        //  1.2 UI 未加载，则收集到更新列表  ui not loaded, to collect it in changed list
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
        // 会话列表处理：折叠列表新增/折叠列表更新替换/折叠列表删除/UI加载列表新增/UI加载列表更新替换  process conversation list: add to fold list/update fold list/delete from fold list/add to ui list/update in ui list
        // 1、存在于折叠列表  exist in fold list
        //  1.1 是折叠的，替换折叠列表中的对应会话  is folded status, replace it from fold list
        //  1.2 非折叠的，从折叠列表删除该会话，并收集到新增列表中 is not folded status, delete it from fold list, and collect it in added list
        // 2、不存在于折叠列表  not exist in fold list
        //  2.1 是折叠的，插入到折叠列表，并从 UI 上找到并删除  is folded status, insert to fold list, and delete it from ui list
        //  2.2 非折叠的，UI 上已展示的则更新，否则插入  is not folded status, if in ui list then update it, if not, insert it to ui list
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
                // 1 之前存在于折叠列表  exist in fold list
                if (conversationInfo.isMarkFold()) {
                    // 1.1 仍然是折叠的，替换  if is folded, then replace
                    foldConversationInfoList.set(foldIndex, conversationInfo);
                } else {
                    // 1.2 更新为非折叠，从折叠列表删除，并插入新增列表  if if not folded, delete it from folded list, and insert to added list
                    foldConversationInfoList.remove(foldIndex);
                    addInfoList.add(conversationInfo);
                }
            } else {
                // 2 之前不存在于折叠列表  not exist in fold list
                // UI 上判断是否展示过  if ui list exist or not
                int uiIndex = -1;
                for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                    ConversationInfo loadedInfo = loadedConversationInfoList.get(i);
                    if (TextUtils.equals(conversationInfo.getConversationId(), loadedInfo.getConversationId())) {
                        uiIndex = i;
                        break;
                    }
                }
                if (conversationInfo.isMarkFold()) {
                    // 2.1 折叠会话，则添加到折叠列表  is folded status, insert to fold list
                    foldConversationInfoList.add(conversationInfo);
                    // UI 上找到该会话，并移除不去展示  if find it in ui list, delete it
                    if (uiIndex >= 0) {
                        loadedConversationInfoList.remove(uiIndex);
                        if (adapter != null) {
                            adapter.onItemRemoved(uiIndex);
                        }
                    }
                } else {
                    // 2.2 非折叠会话，UI 上已展示则更新，未展示则插入  is not folded status, if exist in ui list then update it, if not, insert it
                    if (uiIndex >= 0) {
                        TUIConversationLog.i(TAG, "onConversationChanged conversationInfo " + conversationInfo);
                        changedInfoList.add(conversationInfo);
                    } else {
                        addInfoList.add(conversationInfo);
                    }
                }
            }
        }
        // 主界面显示的折叠会话信息与折叠会话列表的处理  process fold info item and fold list in main ui
        // 1、折叠列表有会话  fold list size > 0
        //  1.1 排序后取出第一个非隐藏会话，并与 UI 折叠会话比较  sort list, then compare the first which not mark hidden and fold this item in ui
        //   1.1.1 与 UI 折叠会话是同一个会话，添加到待更新列表中，并更新 UI 折叠会话  is the same conversation, insert to changed list, and replace cache info
        //   1.1.2 与 UI 折叠会话不是一个会话，从 UI 先删除折叠的会话，添加新的折叠会话到新增列表中，并更新 UI 折叠会话  is not the same conversation, delete the fold item from ui first, then insert it to added list and update cache info
        //   1.1.3 UI 的不存在，则插入到新增会话列表，并赋值给 UI 折叠会话  cache info not exist, insert it to added list, and update cache info
        // 2、折叠列表无会话，且 UI 会话存在，则从 UI 先删除折叠的会话，然后清空 UI 会话  fold list is empty, delete fold item from ui and clear cache info
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
                                if (adapter != null) {
                                    adapter.onItemRemoved(uiIndex);
                                }
                            }
                            addInfoList.add(firstChangedFoldInfo);
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
            onNewConversation(addInfoList,true);
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

        boolean existInFoldList = false;
        for (ConversationInfo conversationInfo : foldConversationInfoList) {
            if (TextUtils.equals(conversationID, conversationInfo.getConversationId())) {
                existInFoldList = true;
                break;
            }
        }

        if (existInFoldList) {
            if (!isUnreadStatusOfFoldItem) {
                setUnreadStatusOfFoldItem(true);
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

            // if new message is belong to one of the foldedConversationInfoList, then show fold item
            if (existInFoldList) {
                hideFoldItem(false);
            }
        }
    }

    public void hideFoldItem(boolean needHide) {
        String loginUserID = TUILogin.getLoginUser();
        SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME).
                put(TUIConversationConstants.HIDE_FOLD_ITEM_SP_KEY_PREFIX + loginUserID, needHide);
        hideFoldItem = needHide;
        if (needHide) {
            hideFoldItemFromUI();
        }
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
        SPUtils.getInstance(TUIConversationConstants.CONVERSATION_SETTINGS_SP_NAME).
                put(TUIConversationConstants.FOLD_ITEM_IS_UNREAD_SP_KEY_PREFIX + loginUserID, isUnread);
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

    private void updateTotalUnreadMessageCount(long sdkUnreadCount) {
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

        TUIConversationLog.i(TAG, "updateTotalUnreadMessageCount sdkUnreadCount:" + sdkUnreadCount + ", markUnreadCount:" + markUnreadCount + ", markHiddenCount:" + markHiddenCount);

        totalUnreadCount = sdkUnreadCount + markUnreadCount - markHiddenCount;
        if (totalUnreadCount < 0) {
            totalUnreadCount = 0;
        }
        updateUnreadTotal(totalUnreadCount);
    }

    /**
     * 更新会话未读计数
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

    /**
     * 将某个会话置顶
     *
     * @param conversation
     */
    public void setConversationTop(final ConversationInfo conversation, final IUIKitCallback<Void> callBack) {
        TUIConversationLog.i(TAG, "setConversationTop" + "|conversation:" + conversation);
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

    /**
     * 会话置顶操作
     *
     * @param id    会话ID
     * @param isTop 是否置顶
     */
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

    /**
     * 删除会话，会将本地会话数据从imsdk中删除
     *
     * @param conversation 会话信息
     */
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

                if (mUIFoldConversation == null || !conversation.isGroup()) {
                    return;
                }

                if (!TextUtils.equals(conversation.getConversationId(), mUIFoldConversation.getConversationId())) {
                    return;
                }

                mUIFoldConversation = null;
                Iterator<ConversationInfo> iterator = foldConversationInfoList.iterator();
                while (iterator.hasNext()) {
                    ConversationInfo cacheConversationInfo = iterator.next();
                    if (TextUtils.equals(conversation.getConversationId(), cacheConversationInfo.getConversationId())) {
                        iterator.remove();
                        break;
                    }
                }

                for (ConversationInfo conversationInfo : foldConversationInfoList) {
                    if (!conversationInfo.isMarkHidden()) {
                        mUIFoldConversation = conversationInfo;
                        ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
                        addInfoList.add(mUIFoldConversation);
                        onNewConversation(addInfoList,true);
                        break;
                    }
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });

    }

    /**
     * 清空会话
     *
     * @param conversation 会话信息
     */
    public void clearConversationMessage(ConversationInfo conversation) {
        if (conversation == null || TextUtils.isEmpty(conversation.getConversationId())) {
            TUIConversationLog.e(TAG, "clearConversationMessage error: invalid conversation");
            return;
        }

        provider.clearHistoryMessage(conversation.getId(), conversation.isGroup(), new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
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

    public void clearConversationMessage(String chatId, boolean isGroup) {
        provider.clearHistoryMessage(chatId, isGroup, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    /**
     * 删除会话，只删除数据源中的会话信息
     *
     * @param id C2C：对方的 userID；Group：群 ID
     */
    public void deleteConversation(String id, boolean isGroup) {
        ConversationInfo conversationInfo = null;
        for (int i = 0; i < loadedConversationInfoList.size(); i++) {
            ConversationInfo info = loadedConversationInfoList.get(i);
            if (isGroup == info.isGroup() && info.getId().equals(id)) {
                conversationInfo = info;
                break;
            }
        }
        deleteConversation(conversationInfo);
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
                    TUIConversationLog.e(TAG, "markConversationFold error, conversationID:" +
                            conversationId + ", code:" + errCode + "|msg:" + errMsg);
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
                adapter.onDataSourceChanged(loadedConversationInfoList);
                if (adapter != null) {
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
        if (conversationInfo!= null && conversationInfo.isMarkHidden()) {
            isHide = true;
        }

        if (!isHide) {
            return;
        }

        provider.markConversationHidden(id, false, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUIConversationLog.i(TAG, "onMessageSendForHideConversation markConversationHidden success, conversationID:" +
                        id + ", isHidden:false");
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIConversationLog.e(TAG, "onMessageSendForHideConversation markConversationHidden error, conversationID:" +
                        id + ", code:" + errCode + "|msg:" + errMsg);
            }
        });
    }

    public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList) {
        if (!TUIConversationConfig.getInstance().isShowUserStatus()) {
            return;
        }
        HashMap<String, Pair<Integer, ConversationInfo>> dataSourceMap = new HashMap<>();
        int index = 0;
        for(ConversationInfo itemBean : loadedConversationInfoList) {
            dataSourceMap.put(itemBean.getId(), Pair.create(index++, itemBean));
        }

        for(V2TIMUserStatus timUserStatus : userStatusList) {
            String userid = timUserStatus.getUserID();
            Pair<Integer, ConversationInfo> beanPair = dataSourceMap.get(userid);
            if (beanPair == null) {
                continue;
            }
            ConversationInfo bean = dataSourceMap.get(userid).second;
            int position = dataSourceMap.get(userid).first;
            if (bean != null && bean.getStatusType() != timUserStatus.getStatusType()) {
                bean.setStatusType(timUserStatus.getStatusType());
                adapter.onDataSourceChanged(loadedConversationInfoList);
                if (adapter != null) {
                    adapter.onItemChanged(position);
                }
            }
        }
    }

    public void clearAllUnreadMessage() {
        provider.clearAllUnreadMessage(new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    /**
     * 会话会话列界面，在数据源更新的地方调用
     */
    public void updateAdapter() {
        if (adapter != null) {
            adapter.onViewNeedRefresh();
        }
    }

}