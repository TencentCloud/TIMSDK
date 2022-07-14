package com.tencent.qcloud.tuikit.tuiconversation.presenter;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.ConversationEventListener;
import com.tencent.qcloud.tuikit.tuiconversation.model.ConversationProvider;
import com.tencent.qcloud.tuikit.tuiconversation.setting.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.util.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class ConversationPresenter {
    private static final String TAG = ConversationPresenter.class.getSimpleName();

    private final static int GET_CONVERSATION_COUNT = 100;

    ConversationEventListener conversationEventListener;

    private final ConversationProvider provider;

    private IConversationListAdapter adapter;

    private final List<ConversationInfo> loadedConversationInfoList = new ArrayList<>();

    private long totalUnreadCount;

    public ConversationPresenter() {
        provider = new ConversationProvider();
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
            public void deleteConversation(String conversationId) {
                ConversationPresenter.this.deleteConversation(conversationId);
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
            public void updateTotalUnreadMessageCount(long count) {
                ConversationPresenter.this.updateTotalUnreadMessageCount(count);
            }

            @Override
            public void onNewConversation(List<ConversationInfo> conversationList) {
                ConversationPresenter.this.onNewConversation(conversationList);
            }

            @Override
            public void onConversationChanged(List<ConversationInfo> conversationList) {
                ConversationPresenter.this.onConversationChanged(conversationList);
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
        };
        TUIConversationService.getInstance().setConversationEventListener(conversationEventListener);
    }

    public void setAdapter(IConversationListAdapter adapter) {
        this.adapter = adapter;
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
        onNewConversation(conversationInfoList);
        if (adapter != null) {
            adapter.onLoadingStateChanged(false);
        }
        provider.getTotalUnreadMessageCount(new IUIKitCallback<Long>() {
            @Override
            public void onSuccess(Long data) {
                totalUnreadCount = data.intValue();
                updateUnreadTotal(totalUnreadCount);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    private void loadAndsubscribeConversationUserStatus(List<ConversationInfo> conversationInfoList) {
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
    public void onNewConversation(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "onNewConversation conversations:" + conversationInfoList);

        ArrayList<ConversationInfo> infos = new ArrayList<>();
        for (ConversationInfo conversationInfo : conversationInfoList) {
            if (!ConversationUtils.isNeedUpdate(conversationInfo)) {
                TUIConversationLog.i(TAG, "onNewConversation conversationInfo " + conversationInfo.toString());
                infos.add(conversationInfo);
            }
        }
        if (infos.size() == 0) {
            return;
        }

        List<ConversationInfo> exists = new ArrayList<>();
        Iterator<ConversationInfo> iterator = infos.iterator();
        while(iterator.hasNext()) {
            ConversationInfo update = iterator.next();
            for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                ConversationInfo cacheInfo = loadedConversationInfoList.get(i);
                // 去重
                if (cacheInfo.getConversationId().equals(update.getConversationId())) {
                    if (update.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN) {
                        update.setStatusType(cacheInfo.getStatusType());
                    }
                    loadedConversationInfoList.set(i, update);
                    iterator.remove();
                    exists.add(update);
                    break;
                }
            }
        }

        // 对新增会话排序，避免插入 recyclerview 时错乱
        Collections.sort(infos);
        loadedConversationInfoList.addAll(infos);
        if (adapter != null) {
            Collections.sort(loadedConversationInfoList);
            adapter.onDataSourceChanged(loadedConversationInfoList);
            for (ConversationInfo info : infos) {
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

        loadAndsubscribeConversationUserStatus(conversationInfoList);
    }

    /**
     * 部分会话刷新（包括多终端已读上报同步）
     *
     * @param conversationInfoList 需要刷新的会话列表
     */
    public void onConversationChanged(List<ConversationInfo> conversationInfoList) {
        TUIConversationLog.i(TAG, "onConversationChanged conversations:" + conversationInfoList);

        ArrayList<ConversationInfo> addInfoList = new ArrayList<>();
        ArrayList<ConversationInfo> changedInfoList = new ArrayList<>();

        for (ConversationInfo conversationInfo : conversationInfoList) {
            if (!ConversationUtils.isNeedUpdate(conversationInfo)) {
                boolean exists = false;
                for (ConversationInfo loadedInfo : loadedConversationInfoList) {
                    if (TextUtils.equals(conversationInfo.getConversationId(), loadedInfo.getConversationId())) {
                        exists = true;
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
        Collections.sort(changedInfoList);
        HashMap<ConversationInfo, Integer> indexMap = new HashMap<>();
        for (int j = 0; j < changedInfoList.size(); j++) {
            ConversationInfo update = changedInfoList.get(j);
            for (int i = 0; i < loadedConversationInfoList.size(); i++) {
                ConversationInfo cacheInfo = loadedConversationInfoList.get(i);
                //单个会话刷新时找到老的会话数据，替换
                if (cacheInfo.getConversationId().equals(update.getConversationId())) {
                    if (update.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN) {
                        update.setStatusType(cacheInfo.getStatusType());
                    }
                    loadedConversationInfoList.set(i, update);
                    indexMap.put(update, i);
                    break;
                }
            }
        }
        if (adapter != null) {
            Collections.sort(loadedConversationInfoList);
            adapter.onDataSourceChanged(loadedConversationInfoList);
            int minRefreshIndex = Integer.MAX_VALUE;
            int maxRefreshIndex = Integer.MIN_VALUE;
            for (ConversationInfo info : changedInfoList) {
                Integer oldIndexObj = indexMap.get(info);
                if (oldIndexObj == null) {
                    continue;
                }
                int oldIndex = oldIndexObj;
                int newIndex = loadedConversationInfoList.indexOf(info);
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

    public void updateTotalUnreadMessageCount(long totalUnreadCount) {
        this.totalUnreadCount = (int) totalUnreadCount;
        updateUnreadTotal(this.totalUnreadCount);
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

    public void deleteConversation(String conversationId) {
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
        deleteConversation(conversationInfo);
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

    /**
     * 会话会话列界面，在数据源更新的地方调用
     */
    public void updateAdapter() {
        if (adapter != null) {
            adapter.onViewNeedRefresh();
        }
    }

}