package com.tencent.qcloud.tuikit.tuicommunity.presenter;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicommunity.TUICommunityService;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicFoldBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TreeNode;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.CommunityEventListener;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.ITopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.model.CommunityProvider;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityDetailView;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityTopicList;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ITopicInfoActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TopicPresenter {
    private static final String TAG = "TopicPresenter";

    private final CommunityProvider provider;
    private final List<TopicBean> loadedTopicBeanList = new ArrayList<>();

    private ICommunityTopicList communityTopicList;
    private ICommunityDetailView communityDetailFragment;
    private ITopicInfoActivity topicInfoActivity;
    private CommunityBean communityBean;

    private final TreeNode<ITopicBean> topicBeanTreeNode = new TreeNode<>();
    private Map<String, Map<String, Boolean>> collapseMap;
    private Map<String, Boolean> currentCollapseMap;
    private final CommunityEventListener communityEventListener;
    public TopicPresenter() {
        provider = new CommunityProvider();
        communityEventListener = new CommunityEventListener() {
            @Override
            public void onTopicCreated(String groupID, String topicID) {
                if (communityBean != null && TextUtils.equals(groupID, communityBean.getGroupId())) {
                    TopicPresenter.this.onTopicCreated(topicID);
                }
            }

            @Override
            public void onTopicDeleted(String groupID, List<String> topicIDs) {
                if (communityBean != null && TextUtils.equals(groupID, communityBean.getGroupId())) {
                    TopicPresenter.this.onTopicDeleted(topicIDs);
                }
            }

            @Override
            public void onTopicChanged(String groupID, TopicBean topicBean) {
                if (communityBean != null && TextUtils.equals(groupID, communityBean.getGroupId())) {
                    TopicPresenter.this.onTopicChanged(topicBean);
                }
            }
        };
    }

    public void setTopicInfoActivity(ITopicInfoActivity topicInfoActivity) {
        this.topicInfoActivity = topicInfoActivity;
    }

    public void deleteCategory(TreeNode<ITopicBean> node) {
        if (node.hasChild()) {
            for (TreeNode<ITopicBean> topicNode : node.getChildList()) {
                if (topicNode.getData() instanceof TopicBean) {
                    deleteCategory((TopicBean) topicNode.getData());
                }
            }
        }
        topicBeanTreeNode.delete(node);
    }

    private void deleteCategory(TopicBean topicBean) {
        provider.deleteTopicCategory(topicBean, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                TUICommunityLog.e(TAG, "deleteCategory success");
                // do nothing, you can receive onTopicInfoChanged callback in TUICommunityService.java
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.e(TAG, "deleteCategory failed, code=" + errCode + " ,msg=" + errMsg);
            }
        });
    }

    public void setCommunityEventListener() {
        TUICommunityService.getInstance().addCommunityEventListener(communityEventListener);
    }

    private void onTopicCreated(String topicID) {
        getTopicBean(topicID, new IUIKitCallback<TopicBean>() {
            @Override
            public void onSuccess(TopicBean data) {
                addTopic(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.e(TAG, "onTopicCreated getTopicBean error");
            }
        });
    }

    private void onTopicDeleted(List<String> topicIDs) {
        boolean changed = false;
        for (String topicID : topicIDs) {
            Iterator<TopicBean> iterator = loadedTopicBeanList.iterator();
            while(iterator.hasNext()) {
                TopicBean topicBean = iterator.next();
                if (TextUtils.equals(topicBean.getID(), topicID)) {
                    iterator.remove();
                    changed = true;
                }
            }
        }
        if (changed) {
            processLoadedData();
        }
    }

    private void onTopicChanged(TopicBean topicBean) {
        boolean changed = false;
        for (int i = 0; i < loadedTopicBeanList.size(); i++) {
            if (TextUtils.equals(topicBean.getID(), (loadedTopicBeanList.get(i)).getID())) {
                loadedTopicBeanList.set(i, topicBean);
                changed = true;
                break;
            }
        }
        if (changed) {
            processLoadedData();
        }
        notifyTopicChanged(topicBean);
    }

    private void notifyTopicChanged(TopicBean topicBean) {
        if (topicInfoActivity != null) {
            topicInfoActivity.onTopicChanged(topicBean);
        }
    }

    private void setTopicCategory() {
        List<String> categories = communityBean.getTopicCategories();
        if (categories == null || categories.isEmpty()) {
            return;
        }
        for (String category : categories) {
            TopicFoldBean topicFoldBean = new TopicFoldBean();
            topicFoldBean.setFoldName(category);
            TreeNode<ITopicBean> treeNode = new TreeNode<>();
            Boolean isCollapse = currentCollapseMap.get(category);
            if (isCollapse == null) {
                treeNode.setCollapse(false);
            } else {
                treeNode.setCollapse(isCollapse);
            }
            treeNode.setData(topicFoldBean);
            treeNode.setNodeName(topicFoldBean.getFoldName());
            topicBeanTreeNode.getRoot().addNode(treeNode);
        }
    }

    private void setTopic() {
        List<TreeNode<ITopicBean>> dataList = topicBeanTreeNode.toList();
        for (TopicBean topicBean : loadedTopicBeanList) {
            addTopicToTree(dataList, topicBean);
        }
    }

    private void addTopic(TopicBean topicBean) {
        for (TopicBean loadedTopicBean : loadedTopicBeanList) {
            if (TextUtils.equals(topicBean.getID(), loadedTopicBean.getID())) {
                return;
            }
        }
        loadedTopicBeanList.add(topicBean);
        List<TreeNode<ITopicBean>> dataList = topicBeanTreeNode.toList();
        addTopicToTree(dataList, topicBean);
    }

    private void addTopicToTree(List<TreeNode<ITopicBean>> dataList, TopicBean topicBean) {
        for (TreeNode<ITopicBean> loadedTopicBean : dataList) {
            if (loadedTopicBean.getData() instanceof TopicBean) {
                if (TextUtils.equals(topicBean.getID(), ((TopicBean) loadedTopicBean.getData()).getID())) {
                    return;
                }
            }
        }
        String category = topicBean.getCategory();
        boolean isExistsCategory = false;
        for (TreeNode<ITopicBean> loadedTopicBean : dataList) {
            if (loadedTopicBean.getData() instanceof TopicFoldBean) {
                if (TextUtils.equals(((TopicFoldBean) loadedTopicBean.getData()).getFoldName(), category)) {
                    TreeNode<ITopicBean> treeNode = new TreeNode<>();
                    treeNode.setData(topicBean);
                    treeNode.setNodeName(topicBean.getID());
                    loadedTopicBean.addNode(treeNode);
                    isExistsCategory = true;
                }
            }
        }
        if (!isExistsCategory) {
            TreeNode<ITopicBean> topicNode = new TreeNode<>();
            topicNode.setData(topicBean);
            topicNode.setNodeName(topicBean.getID());
            topicBeanTreeNode.addNode(topicNode);
        }
        onTopicListChanged();
    }

    private void deleteTopic(TopicBean topicBean) {
        List<TopicBean> topicBeanList = new ArrayList<>();
        topicBeanList.add(topicBean);
        deleteTopicList(topicBeanList);
    }

    private void deleteTopicList(List<TopicBean> topicBeanList) {
        List<String> topicIDs = new ArrayList<>();
        for (TopicBean topicBean : topicBeanList) {
            topicIDs.add(topicBean.getID());
        }
        onTopicDeleted(topicIDs);
    }

    public void setCommunityDetailFragment(ICommunityDetailView communityDetailFragment) {
        this.communityDetailFragment = communityDetailFragment;
    }

    public void setCommunityTopicList(ICommunityTopicList communityTopicList) {
        this.communityTopicList = communityTopicList;
    }

    public void setCommunityBean(CommunityBean communityBean) {
        TUICommunityLog.i(TAG, "setCommunityBean " + communityBean);
        this.communityBean = communityBean;
        topicBeanTreeNode.clear();
        Gson gson = new Gson();
        String collapseStr = SPUtils.getInstance(CommunityConstants.COMMUNITY_SP_NAME).getString(CommunityConstants.COMMUNITY_COLLAPSE_SP_KEY);
        collapseMap = gson.fromJson(collapseStr,
                TypeToken.getParameterized(Map.class, String.class,
                        TypeToken.getParameterized(Map.class, String.class, Boolean.class).getType()).getType());
        if (collapseMap != null) {
            currentCollapseMap = collapseMap.get(communityBean.getGroupId());
        } else {
            collapseMap = new HashMap<>();
        }
        if (currentCollapseMap == null) {
            currentCollapseMap = new HashMap<>();
            collapseMap.put(communityBean.getGroupId(), currentCollapseMap);
        }
        if (communityTopicList != null) {
            processLoadedData();
        }
    }

    public void getTopicList(String groupID) {
        topicBeanTreeNode.clear();
        loadedTopicBeanList.clear();
        onTopicListChanged();
        TUICommunityLog.i(TAG, "getTopicList groupID = " + groupID);
        provider.getTopicList(groupID, null, new IUIKitCallback<List<TopicBean>>() {
            @Override
            public void onSuccess(List<TopicBean> data) {
                TUICommunityLog.i(TAG, "getTopicList success size=" + data.size());
                loadedTopicBeanList.addAll(data);
                processLoadedData();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.e(TAG, "getTopicList failed, code=" + errCode + ", msg=" + errMsg);
                onTopicListChanged();
            }
        });
    }

    private void processLoadedData() {
        topicBeanTreeNode.clear();
        setTopicCategory();
        setTopic();
        onTopicListChanged();
    }

    public void changeTreeNodeCollapseStatus(TreeNode<ITopicBean> node) {
        node.setCollapse(!node.isCollapse());
        currentCollapseMap.put(node.getNodeName(), node.isCollapse());
        Gson gson = new Gson();
        SPUtils.getInstance(CommunityConstants.COMMUNITY_SP_NAME).put(CommunityConstants.COMMUNITY_COLLAPSE_SP_KEY, gson.toJson(collapseMap));
        onTopicListChanged();
    }

    public void createTopic(String groupID, String topicName, String topicCategory, int type, IUIKitCallback<String> callback) {
        TopicBean topicBean = new TopicBean();
        topicBean.setTopicName(topicName);
        topicBean.setCategory(topicCategory);
        topicBean.setType(type);
        provider.createTopic(groupID, topicBean, callback);
    }

    private void onTopicListChanged() {
        List<TreeNode<ITopicBean>> dataList = topicBeanTreeNode.toList();
        if (communityTopicList != null) {
            communityTopicList.onTopicListChanged(dataList, null);
        }
    }

    public void getTopicBeanList(String groupID, List<String> topicIDs, IUIKitCallback<List<TopicBean>> callback) {
        provider.getTopicList(groupID, topicIDs, new IUIKitCallback<List<TopicBean>>() {
            @Override
            public void onSuccess(List<TopicBean> data) {
                CommunityUtil.callbackOnSuccess(callback, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                CommunityUtil.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void getTopicBean(String topicID, IUIKitCallback<TopicBean> callback) {
        String groupID = CommunityUtil.getGroupIDFromTopicID(topicID);
        List<String> topicIDs = new ArrayList<>();
        topicIDs.add(topicID);
        provider.getTopicList(groupID, topicIDs, new IUIKitCallback<List<TopicBean>>() {
            @Override
            public void onSuccess(List<TopicBean> data) {
                CommunityUtil.callbackOnSuccess(callback, data.get(0));
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                CommunityUtil.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void getCommunityBean(String topicID, IUIKitCallback<CommunityBean> callback) {
        String groupID = CommunityUtil.getGroupIDFromTopicID(topicID);
        provider.getCommunityBean(groupID, callback);
    }

    public void modifyTopicName(String topicID, String name, IUIKitCallback<Void> callback) {
        provider.modifyTopicName(topicID, name, callback);
    }

    public void modifyTopicCategory(TopicBean topicBean, String category, IUIKitCallback<Void> callback) {
        provider.modifyTopicCategory(topicBean, category, callback);
    }

    public void deleteTopic(String topicID, IUIKitCallback<Void> callback) {
        String groupID = CommunityUtil.getGroupIDFromTopicID(topicID);
        provider.deleteTopic(groupID, topicID, callback);
    }
}
