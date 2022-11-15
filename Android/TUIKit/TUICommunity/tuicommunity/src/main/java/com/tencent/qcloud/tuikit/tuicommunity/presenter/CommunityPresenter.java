package com.tencent.qcloud.tuikit.tuicommunity.presenter;

import android.text.TextUtils;
import android.util.Pair;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.TUICommunityService;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityChangeBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityMemberBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.CommunityEventListener;
import com.tencent.qcloud.tuikit.tuicommunity.model.CommunityProvider;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityDetailView;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityFragment;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityGroupIconList;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityMemberList;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunitySettingsActivity;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICreateTopicActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

public class CommunityPresenter {
    private static final String TAG = CommunityPresenter.class.getSimpleName();
    private static String switchCommunityID;

    private final CommunityProvider provider;
    private ICommunityGroupIconList groupIconList;
    private ICommunityFragment communityFragment;
    private ICreateTopicActivity createTopicActivity;
    private ICommunitySettingsActivity settingsActivity;
    private ICommunityDetailView communityDetailView;
    private ICommunityMemberList communityMemberListView;

    private final List<CommunityBean> joinedCommunityBeanList = new ArrayList<>();
    private final List<CommunityMemberBean> loadedCommunityMemberBeanList = new ArrayList<>();
    private final CommunityEventListener communityEventListener;

    private CommunityBean currentCommunityBean;
    public CommunityPresenter() {
        provider = new CommunityProvider();
        communityEventListener = new CommunityEventListener() {
            @Override
            public void onCommunityCreated(String groupID) {
                CommunityPresenter.this.addCommunityGroup(groupID);
            }

            @Override
            public void onCommunityDeleted(String groupID) {
                CommunityPresenter.this.deleteCommunity(groupID);
            }

            @Override
            public void onCommunityInfoChanged(String groupID, List<CommunityChangeBean> communityChangeBeans) {
                TUICommunityLog.i(TAG, "onCommunityInfoChanged groupID = " + groupID);
                CommunityPresenter.this.onCommunityBeanChanged(groupID);
            }

            @Override
            public void onJoinedCommunity(String groupID) {
                CommunityPresenter.this.onJoinedCommunity(groupID);
            }

            @Override
            public void onNetworkStateChanged(int state) {
                CommunityPresenter.this.onNetworkStateChanged(state);
            }

            @Override
            public void onSelfFaceChanged(String newFaceUrl) {
                CommunityPresenter.this.onSelfFaceChanged(newFaceUrl);
            }
        };
    }

    public void setCommunityEventListener() {
        TUICommunityService.getInstance().addCommunityEventListener(communityEventListener);
    }

    public void setCurrentCommunityBean(CommunityBean currentCommunityBean) {
        this.currentCommunityBean = currentCommunityBean;
    }

    private void onNetworkStateChanged(int state) {
        if (communityFragment != null) {
            communityFragment.onNetworkStateChanged(state);
        }
    }

    private void onSelfFaceChanged(String newFaceUrl) {
        if (communityFragment != null) {
            communityFragment.onSelfFaceChanged(newFaceUrl);
        }
    }

    private void onJoinedCommunity(String groupID) {
        for (CommunityBean communityBean : joinedCommunityBeanList) {
            if (TextUtils.equals(communityBean.getGroupId(), groupID)) {
                return;
            }
        }
        if (TextUtils.equals(switchCommunityID, groupID)) {
            addCommunityGroup(groupID, true);
            switchCommunityID = null;
        } else {
            addCommunityGroup(groupID);
        }
    }

    private void onCommunityBeanChanged(String groupID) {
        provider.getCommunityBean(groupID, new IUIKitCallback<CommunityBean>() {
            @Override
            public void onSuccess(CommunityBean data) {
                TUICommunityLog.i(TAG, "onCommunityBeanChanged getCommunityBean success");
                onCommunityChanged(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.e(TAG, "onCommunityBeanChanged getCommunityBean error, code=" + errCode + " errMsg=" + errMsg);
            }
        });
    }

    public void setCommunityMemberListView(ICommunityMemberList communityMemberListView) {
        this.communityMemberListView = communityMemberListView;
    }

    public void setCommunityDetailView(ICommunityDetailView communityDetailView) {
        this.communityDetailView = communityDetailView;
    }

    public void setSettingsActivity(ICommunitySettingsActivity settingsActivity) {
        this.settingsActivity = settingsActivity;
    }

    public void setCreateTopicActivity(ICreateTopicActivity createTopicActivity) {
        this.createTopicActivity = createTopicActivity;
    }

    public void setGroupIconList(ICommunityGroupIconList groupIconList) {
        this.groupIconList = groupIconList;
    }

    public void setCommunityFragment(ICommunityFragment communityFragment) {
        this.communityFragment = communityFragment;
    }

    public void getSelfFaceUrl(IUIKitCallback<String> callback) {
        provider.getSelfFaceUrl(callback);
    }

    public void getGroupNameCard(String groupID, IUIKitCallback<String> callback) {
        provider.getGroupNameCard(groupID, callback);
    }

    public void loadJoinedCommunityList() {
        provider.getJoinedCommunityList(new IUIKitCallback<List<CommunityBean>>() {
            @Override
            public void onSuccess(List<CommunityBean> data) {
                onNewCommunity(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                super.onError(module, errCode, errMsg);
            }
        });
    }


    private void addCommunityGroup(String groupID, boolean isSwitch) {
        for (CommunityBean communityBean : joinedCommunityBeanList) {
            if (TextUtils.equals(communityBean.getGroupId(), groupID)) {
                return;
            }
        }
        provider.getCommunityBean(groupID, new IUIKitCallback<CommunityBean>() {
            @Override
            public void onSuccess(CommunityBean data) {
                onNewCommunity(data);
                if (isSwitch) {
                    switchToCommunity(data);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                super.onError(module, errCode, errMsg);
            }
        });
    }

    public void addCommunityGroup(String groupID) {
        addCommunityGroup(groupID, false);
    }

    private void switchToCommunity(CommunityBean communityBean) {
        if (communityFragment != null) {
            communityFragment.onCommunitySelected(communityBean);
        }
    }

    private void deleteCommunity(String groupID) {
        for (CommunityBean communityBean : joinedCommunityBeanList) {
            if (TextUtils.equals(communityBean.getGroupId(), groupID)) {
                onCommunityRemoved(communityBean);
                break;
            }
        }
    }

    private void onNewCommunity(CommunityBean communityBean) {
        List<CommunityBean> communityBeans = new ArrayList<>();
        communityBeans.add(communityBean);
        onNewCommunity(communityBeans);
    }

    public void onNewCommunity(List<CommunityBean> communityBeanList) {
        TUICommunityLog.i(TAG, "onNewCommunity Communities:" + communityBeanList);

        ArrayList<CommunityBean> beans = new ArrayList<>();
        for (CommunityBean communityBean : communityBeanList) {
            TUICommunityLog.i(TAG, "onNewCommunity Communities " + communityBean);
            beans.add(communityBean);
        }
        if (beans.size() == 0) {
            return;
        }

        List<CommunityBean> exists = new ArrayList<>();
        Iterator<CommunityBean> iterator = beans.iterator();
        while (iterator.hasNext()) {
            CommunityBean update = iterator.next();
            for (int i = 0; i < joinedCommunityBeanList.size(); i++) {
                CommunityBean cacheInfo = joinedCommunityBeanList.get(i);
                if (cacheInfo.getGroupId().equals(update.getGroupId())) {
                    joinedCommunityBeanList.set(i, update);
                    iterator.remove();
                    exists.add(update);
                    break;
                }
            }
        }

        Collections.sort(beans);
        joinedCommunityBeanList.addAll(beans);
        Collections.sort(joinedCommunityBeanList);
        onDataSourceChanged(joinedCommunityBeanList);
        for (CommunityBean bean : beans) {
            int index = joinedCommunityBeanList.indexOf(bean);
            if (index != -1) {
                onItemInserted(index);
            }
        }

        for (CommunityBean bean : exists) {
            int index = joinedCommunityBeanList.indexOf(bean);
            if (index != -1) {
                onItemChanged(index);
            }
            judgeCurrentCommunityBeanChanged(bean);
        }
    }

    private void onCommunityChanged(CommunityBean communityBean) {
        List<CommunityBean> communityBeans = new ArrayList<>();
        communityBeans.add(communityBean);
        onCommunityChanged(communityBeans);
    }

    public void onCommunityChanged(List<CommunityBean> communityBeanList) {
        TUICommunityLog.i(TAG, "onCommunityChanged CommunityBeans:" + communityBeanList);

        ArrayList<CommunityBean> addInfoList = new ArrayList<>();
        ArrayList<CommunityBean> changedInfoList = new ArrayList<>();

        for (CommunityBean communityBean : communityBeanList) {
            boolean exists = false;
            for (CommunityBean loadedBean : joinedCommunityBeanList) {
                if (TextUtils.equals(communityBean.getGroupId(), loadedBean.getGroupId())) {
                    exists = true;
                }
            }
            if (exists) {
                TUICommunityLog.i(TAG, "onCommunityChanged communityBean " + communityBean);
                changedInfoList.add(communityBean);
            } else {
                addInfoList.add(communityBean);
            }
            judgeCurrentCommunityBeanChanged(communityBean);
        }
        if (!addInfoList.isEmpty()) {
            onNewCommunity(addInfoList);
        }

        if (changedInfoList.size() == 0) {
            return;
        }
        Collections.sort(changedInfoList);
        HashMap<CommunityBean, Integer> indexMap = new HashMap<>();
        for (int j = 0; j < changedInfoList.size(); j++) {
            CommunityBean update = changedInfoList.get(j);
            for (int i = 0; i < joinedCommunityBeanList.size(); i++) {
                CommunityBean cacheInfo = joinedCommunityBeanList.get(i);
                if (cacheInfo.getGroupId().equals(update.getGroupId())) {
                    joinedCommunityBeanList.set(i, update);
                    indexMap.put(update, i);
                    break;
                }
            }
        }
        Collections.sort(joinedCommunityBeanList);
        onDataSourceChanged(joinedCommunityBeanList);
        int minRefreshIndex = Integer.MAX_VALUE;
        int maxRefreshIndex = Integer.MIN_VALUE;
        for (CommunityBean communityBean : changedInfoList) {
            Integer oldIndexObj = indexMap.get(communityBean);
            if (oldIndexObj == null) {
                continue;
            }
            int oldIndex = oldIndexObj;
            int newIndex = joinedCommunityBeanList.indexOf(communityBean);
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
            onItemRangeChanged(minRefreshIndex, count);
        }
    }

    public void onCommunityRemoved(CommunityBean communityBean) {
        int index = joinedCommunityBeanList.indexOf(communityBean);
        boolean isRemove = joinedCommunityBeanList.remove(communityBean);
        if (isRemove && index != -1) {
            onItemRemoved(index);
        }
    }

    private void judgeCurrentCommunityBeanChanged(CommunityBean communityBean) {
        if (currentCommunityBean != null && TextUtils.equals(currentCommunityBean.getGroupId(), communityBean.getGroupId())) {
            currentCommunityBean = communityBean;
            if (createTopicActivity != null) {
                createTopicActivity.onCommunityChanged(currentCommunityBean);
            }
            if (settingsActivity != null) {
                settingsActivity.onCommunityChanged(currentCommunityBean);
            }
            if (communityDetailView != null) {
                communityDetailView.onCommunityChanged(currentCommunityBean);
            }
        }
    }

    private void onDataSourceChanged(List<CommunityBean> communityBeanList) {
        if (groupIconList != null) {
            groupIconList.onJoinedCommunityChanged(joinedCommunityBeanList);
        }
        if (communityFragment != null) {
            communityFragment.onJoinedCommunityChanged(joinedCommunityBeanList);
        }
    }

    private void onItemRangeChanged(int index, int count) {
        if (groupIconList != null) {
            groupIconList.onItemRangeChanged(index, count);
        }
        if (communityFragment != null) {
            communityFragment.onItemRangeChanged(index, count);
        }
    }

    private void onItemInserted(int index) {
        if (groupIconList != null) {
            groupIconList.onItemInserted(index);
        }
        if (communityFragment != null) {
            communityFragment.onItemInserted(index);
        }
    }

    private void onItemChanged(int index) {
        if (groupIconList != null) {
            groupIconList.onItemChanged(index);
        }
        if (communityFragment != null) {
            communityFragment.onItemChanged(index);
        }
    }

    private void onItemRemoved(int index) {
        if (groupIconList != null) {
            groupIconList.onItemRemoved(index);
        }
        if (communityFragment != null) {
            communityFragment.onItemRemoved(index);
        }
    }

    public void createCommunityGroup(String communityName, String introduction, String coverUrl, String faceUrl) {
        CommunityBean communityBean = new CommunityBean();
        communityBean.setCommunityName(communityName);
        communityBean.setIntroduction(introduction);
        communityBean.setCoverUrl(coverUrl);
        communityBean.setGroupFaceUrl(faceUrl);
        List<String> topicCategories = new ArrayList<>();
        topicCategories.add(TUICommunityService.getAppContext().getString(R.string.community_default_category_announcement));
        topicCategories.add(TUICommunityService.getAppContext().getString(R.string.community_default_category_communication));
        communityBean.setTopicCategories(topicCategories);
        provider.createCommunityGroup(communityBean, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                switchCommunityID = data;
                ToastUtil.toastLongMessage(TUICommunityService.getAppContext().getString(R.string.community_create_community_success));
                TUICore.notifyEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_CREATE_COMMUNITY, null);
                createDefaultTopic(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(TUICommunityService.getAppContext().getString(R.string.community_create_community_failed));
                TUICommunityLog.e(TAG, "create community error, code=" + errCode + " msg=" + errMsg);
            }
        });
    }

    private void createDefaultTopic(String groupID) {
        String topicCategoryAnnouncement = TUICommunityService.getAppContext().getString(R.string.community_default_category_announcement);
        String topicCategoryCommunication = TUICommunityService.getAppContext().getString(R.string.community_default_category_communication);
        String topicNameNotice = TUICommunityService.getAppContext().getString(R.string.community_topic_important_notice);
        String topicNameNewbie = TUICommunityService.getAppContext().getString(R.string.community_topic_newbie_report);
        String topicNameChat = TUICommunityService.getAppContext().getString(R.string.community_topic_chat_hall);
        TopicBean topicBean = new TopicBean();
        topicBean.setTopicName(topicNameNotice);
        topicBean.setCategory(topicCategoryAnnouncement);
        topicBean.setAllMute(true);
        provider.createTopic(groupID, topicBean, null);
        topicBean.setTopicName(topicNameNewbie);
        topicBean.setCategory(topicCategoryCommunication);
        provider.createTopic(groupID, topicBean, null);
        topicBean.setTopicName(topicNameChat);
        topicBean.setCategory(topicCategoryCommunication);
        provider.createTopic(groupID, topicBean, null);
    }

    private void onCommunityListChanged() {
        if (groupIconList != null) {
            groupIconList.onJoinedCommunityChanged(joinedCommunityBeanList);
        }
        if (communityFragment != null) {
            communityFragment.onJoinedCommunityChanged(joinedCommunityBeanList);
        }
    }

    public void searchCommunity(String groupID, IUIKitCallback<CommunityBean> callback) {
        provider.getCommunityBean(groupID, callback);
    }

    public void joinCommunity(String groupID, IUIKitCallback<Void> callback) {
        provider.joinCommunity(groupID, null, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                switchCommunityID = groupID;
                CommunityUtil.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                CommunityUtil.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void createCategory(String groupID, String category) {
        provider.createCategory(groupID, category, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                ToastUtil.toastShortMessage(TUICommunityService.getAppContext().getString(R.string.community_create_topic_category_success));
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(TUICommunityService.getAppContext().getString(R.string.community_create_topic_category_failed) + " code=" + errCode + " errMsg=" + errMsg);
            }
        });
    }

    public void deleteCategory(String groupID, String category) {
        provider.deleteCategory(groupID, category, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUICommunityLog.i(TAG, "delete category success");
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.i(TAG, "delete category failed, code=" + errCode + " errMsg=" + errMsg);
                ToastUtil.toastShortMessage("delete category failed, code=" + errCode + " errMsg=" + errMsg);
            }
        });
    }

    public void quitCommunity(String groupID, IUIKitCallback<Void> callback) {
        provider.quitCommunity(groupID, callback);
    }

    public void disbandCommunity(String groupID, IUIKitCallback<Void> callback) {
        provider.disbandCommunity(groupID, callback);
    }

    public void removeGroupMembers(String groupID, List<String> memberIDList, IUIKitCallback<List<String>> callBack) {
        provider.removeGroupMembers(groupID, memberIDList, new IUIKitCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> data) {
                CommunityUtil.callbackOnSuccess(callBack, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                CommunityUtil.callbackOnError(callBack, errCode, errMsg);
            }
        });
    }

    public void loadCommunityMembers(String groupID, long nextSeq) {
        provider.loadCommunityMembers(groupID, 0, nextSeq, new IUIKitCallback<Pair<List<CommunityMemberBean>, Long>>() {
            @Override
            public void onSuccess(Pair<List<CommunityMemberBean>, Long> data) {
                loadedCommunityMemberBeanList.addAll(data.first);
                LinkedHashMap<String, CommunityMemberBean> distinctMap = new LinkedHashMap<>();
                for (CommunityMemberBean communityMemberBean : loadedCommunityMemberBeanList) {
                    if (!TextUtils.isEmpty(communityMemberBean.getAccount())) {
                        distinctMap.put(communityMemberBean.getAccount(), communityMemberBean);
                    }
                }
                loadedCommunityMemberBeanList.clear();
                loadedCommunityMemberBeanList.addAll(distinctMap.values());
                long seq = data.second;
                onCommunityMemberListChanged(loadedCommunityMemberBeanList, seq);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                super.onError(module, errCode, errMsg);
            }
        });
    }

    public void inviteGroupMembers(String groupID, List<String> addMembers) {
        provider.inviteGroupMembers(groupID, addMembers, new IUIKitCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> data) {
                TUICommunityLog.i(TAG, " inviteGroupMembers success");
                loadCommunityMembers(groupID, 0);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.e(TAG, "inviteGroupMembers failed, code=" + errCode + " msg=" + errMsg);
            }
        });
    }

    private void onCommunityMemberListChanged(List<CommunityMemberBean> communityMemberBeanList, long seq) {
        if (communityMemberListView != null) {
            communityMemberListView.onMemberListChanged(communityMemberBeanList, seq);
        }
    }

    public void modifyCommunityCover(String groupID, String groupCoverUrl, IUIKitCallback<Void> callback) {
        provider.modifyCommunityCover(groupID, groupCoverUrl, callback);
    }

    public void modifyCommunityAvatar(String groupID, String groupFaceUrl, IUIKitCallback<Void> callback) {
        provider.modifyCommunityAvatar(groupID, groupFaceUrl, callback);
    }

    public void transferCommunityOwner(String groupID, String newOwnerID, IUIKitCallback<Void> callback) {
        provider.transferGroupOwner(groupID, newOwnerID, callback);
    }

    public void modifyCommunityName(String groupID, String name, IUIKitCallback<Void> callback) {
        provider.modifyCommunityName(groupID, name, callback);
    }

    public void modifyCommunityIntroduction(String groupID, String introduction, IUIKitCallback<Void> callback) {
        provider.modifyCommunityIntroduction(groupID, introduction, callback);
    }

    public void modifyCommunitySelfNameCard(String groupID, String nameCard, IUIKitCallback<Void> callback) {
        provider.modifyCommunitySelfNameCard(groupID, nameCard, callback);
    }

    public void loadCommunityBean(String groupID, IUIKitCallback<CommunityBean> callback) {
        provider.getCommunityBean(groupID, callback);
    }
}
