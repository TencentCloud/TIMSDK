package com.tencent.qcloud.tuikit.tuiconversation.classicui.page;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.tabs.TabLayout;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationGroupBean;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationTabLayoutMediator;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.ConversationGroupNotifyListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

public class TUIConversationFragmentContainer extends BaseFragment {
    private static final String TAG = TUIConversationFragmentContainer.class.getSimpleName();
    private List<ConversationGroupBean> mConversationGroupBeans = new ArrayList<>();

    private View mBaseView;
    private ViewGroup searchLayout;
    private ViewGroup mTabLayout;
    private TabLayout mConversationTabLayout;
    private ViewGroup mConversationGroupSettingLayout;
    private ViewPager2 mViewPager;
    private ConversationTabLayoutMediator mediator;
    private FragmentStateAdapter adapter;
    private ConversationGroupNotifyListener conversationGroupNotifyListener;

    private int selectedColor;
    private int selectedPosition;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIConversationLog.d(TAG, "onCreateView");
        mBaseView = inflater.inflate(R.layout.conversation_base_fragment, container, false);
        searchLayout = mBaseView.findViewById(R.id.conversation_search_layout);
        mTabLayout = mBaseView.findViewById(R.id.conversation_tab_layout);
        mConversationTabLayout = (TabLayout) mBaseView.findViewById(R.id.conversation_tabs);
        mConversationGroupSettingLayout = mBaseView.findViewById(R.id.conversation_group_setting);
        mViewPager = (ViewPager2) mBaseView.findViewById(R.id.converstion_viewpager);

        initSearchView();
        initGroupView();
        return mBaseView;
    }

    private Fragment newConversationMarkFragment(ConversationGroupBean bean) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConversationConstants.CONVERSATION_MARK_NAME_KEY, bean.getMarkType());
        Object markFragment = TUICore.createObject(
            TUIConstants.TUIConversationMarkPlugin.OBJECT_FACTORY_NAME, TUIConstants.TUIConversationMarkPlugin.OBJECT_CONVERSATION_MARK_FRAGMENT, param);
        if (markFragment instanceof Fragment) {
            return (Fragment) markFragment;
        }

        return null;
    }

    private Fragment newConversationGroupFragment(ConversationGroupBean bean) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConversationConstants.CONVERSATION_GROUP_NAME_KEY, bean.getTitle());
        Object groupFragment = TUICore.createObject(
            TUIConstants.TUIConversationGroupPlugin.OBJECT_FACTORY_NAME, TUIConstants.TUIConversationGroupPlugin.OBJECT_CONVERSATION_GROUP_FRAGMENT, param);
        if (groupFragment instanceof Fragment) {
            return (Fragment) groupFragment;
        }

        return null;
    }

    private void refreshConversationGroupSort() {
        Collections.sort(mConversationGroupBeans, new Comparator<ConversationGroupBean>() {
            @Override
            public int compare(ConversationGroupBean o1, ConversationGroupBean o2) {
                return o1.getWeight() - o2.getWeight();
            }
        });
    }

    private List<ConversationGroupBean> getGroupExtensionMoreSettings() {
        List<ConversationGroupBean> groupBeanList = new ArrayList<>();
        List<TUIExtensionInfo> extensionList =
            TUICore.getExtensionList(TUIConstants.TUIConversation.Extension.ConversationGroupBean.CLASSIC_EXTENSION_ID, null);
        for (TUIExtensionInfo extensionInfo : extensionList) {
            Map<String, Object> paramMap = extensionInfo.getData();
            Object beanObjectList = paramMap.get(TUIConstants.TUIConversation.Extension.ConversationGroupBean.KEY_DATA);
            if (beanObjectList != null && beanObjectList instanceof List) {
                groupBeanList = (List<ConversationGroupBean>) beanObjectList;
            }
        }

        return groupBeanList;
    }

    private List<ConversationGroupBean> getMarkExtensionMoreSettings() {
        List<ConversationGroupBean> groupBeanList = new ArrayList<>();
        List<TUIExtensionInfo> extensionList =
            TUICore.getExtensionList(TUIConstants.TUIConversation.Extension.ConversationMarkBean.CLASSIC_EXTENSION_ID, null);
        for (TUIExtensionInfo extensionInfo : extensionList) {
            Map<String, Object> paramMap = extensionInfo.getData();
            Object beanObjectList = paramMap.get(TUIConstants.TUIConversation.Extension.ConversationMarkBean.KEY_DATA);
            if (beanObjectList != null && beanObjectList instanceof List) {
                groupBeanList = (List<ConversationGroupBean>) beanObjectList;
            }
        }

        return groupBeanList;
    }

    private void refreshGroupView(boolean hide) {
        if (hide) {
            mTabLayout.setVisibility(View.GONE);
        } else {
            mTabLayout.setVisibility(View.VISIBLE);
            HashMap<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIConversationGroupPlugin.CONTEXT, getContext());
            TUICore.raiseExtension(TUIConstants.TUIConversationGroupPlugin.EXTENSION_GROUP_SETTING_MENU, mConversationGroupSettingLayout, param);
        }
    }

    private void initGroupView() {
        mConversationGroupBeans.clear();

        List<ConversationGroupBean> groupBeanList = getGroupExtensionMoreSettings();
        List<ConversationGroupBean> markBeanList = getMarkExtensionMoreSettings();
        // 分组中包含了标记的信息
        if (groupBeanList != null && !groupBeanList.isEmpty()) {
            mConversationGroupBeans.addAll(groupBeanList);
        }

        if (markBeanList != null && !markBeanList.isEmpty()) {
            mConversationGroupBeans.addAll(markBeanList);
        }

        if (mConversationGroupBeans.isEmpty()) {
            refreshGroupView(true);
        } else {
            refreshGroupView(false);
        }

        ConversationGroupBean bean = new ConversationGroupBean();
        bean.setTitle(getString(R.string.conversation_page_all));
        bean.setWeight(ConversationGroupBean.CONVERSATION_ALL_GROUP_WEIGHT);
        bean.setGroupType(ConversationGroupBean.CONVERSATION_GROUP_TYPE_DEFAULT);
        if (!mConversationGroupBeans.contains(bean)) {
            mConversationGroupBeans.add(bean);
        }

        refreshConversationGroupSort();

        // 因为分组未读数问题，这里预加载界面设置3个，默认将未读、@我和标记加载上，保证未读数正确监听
        mViewPager.setOffscreenPageLimit(3);
        // 关闭预加载
        // mViewPager.setOffscreenPageLimit(ViewPager2.OFFSCREEN_PAGE_LIMIT_DEFAULT);
        //((RecyclerView)mViewPager.getChildAt(0)).getLayoutManager().setItemPrefetchEnabled(false);
        // 设置缓存数量，对应 RecyclerView 中的 mCachedViews，即屏幕外的视图数量
        //((RecyclerView)mViewPager.getChildAt(0)).setItemViewCacheSize(0);
        adapter = new FragmentStateAdapter(getChildFragmentManager(), getLifecycle()) {
            @NonNull
            @Override
            public Fragment createFragment(int position) {
                ConversationGroupBean bean = mConversationGroupBeans.get(position);
                if (bean.getGroupType() == ConversationGroupBean.CONVERSATION_GROUP_TYPE_DEFAULT) {
                    return TUIConversationFragment.newInstance();
                } else if (bean.getGroupType() == ConversationGroupBean.CONVERSATION_GROUP_TYPE_GROUP) {
                    return newConversationGroupFragment(bean);
                } else if (bean.getGroupType() == ConversationGroupBean.CONVERSATION_GROUP_TYPE_MARK) {
                    return newConversationMarkFragment(bean);
                } else {
                    return TUIConversationFragment.newInstance();
                }
            }

            @Override
            public int getItemCount() {
                return mConversationGroupBeans.size();
            }

            @Override
            public long getItemId(int position) {
                return mConversationGroupBeans.get(position).hashCode();
            }

            @Override
            public boolean containsItem(long itemId) {
                for (ConversationGroupBean bean : mConversationGroupBeans) {
                    if (itemId == bean.hashCode()) {
                        return true;
                    }
                }

                return false;
            }
        };

        mViewPager.setAdapter(adapter);
        selectedPosition = 0;
        mViewPager.setCurrentItem(selectedPosition);
        mViewPager.registerOnPageChangeCallback(changeCallback);
        selectedColor = getResources().getColor(TUIThemeManager.getAttrResId(getContext(), R.attr.conversation_tab_selected));
        mConversationTabLayout.setTabTextColors(getResources().getColor(R.color.black), selectedColor);
        adapter.notifyDataSetChanged();
        // mViewPager.setUserInputEnabled(false);
        mediator =
            new ConversationTabLayoutMediator(mConversationTabLayout, mViewPager, true, false, new ConversationTabLayoutMediator.TabConfigurationStrategy() {
                @Override
                public void onConfigureTab(@NonNull TabLayout.Tab tab, int position) {
                    TUIConversationLog.d(TAG, "onConfigureTab position" + position);
                    // 这里可以自定义TabView
                    View layoutView = LayoutInflater.from(getContext()).inflate(R.layout.conversation_group_tab_item, null, false);
                    TextView titileView = layoutView.findViewById(R.id.tab_title);
                    TextView unreadView = layoutView.findViewById(R.id.tab_unread);
                    titileView.setText(mConversationGroupBeans.get(position).getTitle());
                    long count = mConversationGroupBeans.get(position).getUnReadCount();
                    if (count == 0) {
                        unreadView.setText("");
                    } else if (count > 99) {
                        unreadView.setText("99+");
                    } else {
                        unreadView.setText(String.valueOf(count));
                    }
                    tab.setCustomView(layoutView);

                    if (position == selectedPosition) {
                        titileView.setTextColor(selectedColor);
                    }
                }
            });
        mediator.attach();

        conversationGroupNotifyListener = new ConversationGroupNotifyListener() {
            @Override
            public void notifyGroupsAdd(List<ConversationGroupBean> beans) {
                addRefreshData(beans, false);
            }

            @Override
            public void notifyMarkGroupsAdd(List<ConversationGroupBean> beans) {
                addRefreshData(beans, true);
            }

            @Override
            public void notifyGroupAdd(ConversationGroupBean bean) {
                TUIConversationLog.d(TAG, "notifyGroupAdd");
                if (!mConversationGroupBeans.contains(bean)) {
                    mConversationGroupBeans.add(bean);
                    if (bean.getGroupType() == ConversationGroupBean.CONVERSATION_GROUP_TYPE_MARK) {
                        refreshConversationGroupSort();
                        adapter.notifyDataSetChanged();
                    } else {
                        int notifyIndex = mConversationGroupBeans.size() - 1;
                        adapter.notifyItemInserted(notifyIndex);
                    }
                } else {
                    TUIConversationLog.d(TAG, "notifyGroupAdd contains groupName = " + bean.getTitle());
                }
            }

            @Override
            public void notifyGroupDelete(String groupName) {
                TUIConversationLog.d(TAG, "notifyGroupDelete");
                ListIterator<ConversationGroupBean> iterator = mConversationGroupBeans.listIterator();
                int index = 0;
                while (iterator.hasNext()) {
                    ConversationGroupBean next = iterator.next();
                    if (next.getTitle().equals(groupName)) {
                        iterator.remove();
                        adapter.notifyItemRangeRemoved(index, 1);
                        break;
                    } else {
                        index++;
                    }
                }
            }

            @Override
            public void notifyGroupRename(String oldName, String newName) {
                TUIConversationLog.d(TAG, "notifyGroupRename");
                ListIterator<ConversationGroupBean> iterator = mConversationGroupBeans.listIterator();
                int index = 0;
                while (iterator.hasNext()) {
                    ConversationGroupBean next = iterator.next();
                    if (next.getTitle().equals(oldName)) {
                        next.setTitle(newName);
                        adapter.notifyItemChanged(index);
                        break;
                    } else {
                        index++;
                    }
                }
            }

            @Override
            public void notifyGroupUnreadMessageCountChanged(String groupName, long totalUnreadCount) {
                TUIConversationLog.d(TAG, "notifyGroupUnreadMessageCountChanged");
                ListIterator<ConversationGroupBean> iterator = mConversationGroupBeans.listIterator();
                int index = 0;
                while (iterator.hasNext()) {
                    ConversationGroupBean next = iterator.next();
                    if (next.getTitle().equals(groupName)) {
                        next.setUnReadCount(totalUnreadCount);
                        refreshTabUnreadCount(index, totalUnreadCount);
                        break;
                    } else {
                        index++;
                    }
                }
            }
        };
        TUIConversationService.getInstance().setConversationGroupNotifyListener(conversationGroupNotifyListener);
    }

    private void refreshTabUnreadCount(int position, long unreadCount) {
        TabLayout.Tab tab = mConversationTabLayout.getTabAt(position);
        if (tab != null) {
            View layoutView = tab.getCustomView();
            if (layoutView != null) {
                TextView unreadView = layoutView.findViewById(R.id.tab_unread);
                if (unreadCount == 0) {
                    unreadView.setText("");
                } else if (unreadCount > 99) {
                    unreadView.setText("99+");
                } else {
                    unreadView.setText(String.valueOf(unreadCount));
                }
            }

            // 修改刷新 tab 时候引起 TabLayout 位置异常
            int selectPositon = mConversationTabLayout.getSelectedTabPosition();
            if (selectPositon >= 0) {
                TabLayout.Tab selectedTab = mConversationTabLayout.getTabAt(selectPositon);
                if (selectedTab != null) {
                    selectedTab.select();
                }
            }
        }
    }

    private void addRefreshData(List<ConversationGroupBean> beans, boolean isMark) {
        List<ConversationGroupBean> markBeans = new ArrayList<>();
        List<ConversationGroupBean> groupBeans = new ArrayList<>();
        for (ConversationGroupBean bean : mConversationGroupBeans) {
            if (bean.getGroupType() == ConversationGroupBean.CONVERSATION_GROUP_TYPE_MARK) {
                markBeans.add(bean);
            } else if (bean.getGroupType() == ConversationGroupBean.CONVERSATION_GROUP_TYPE_GROUP) {
                groupBeans.add(bean);
            }
        }

        if (beans == null || beans.isEmpty()) {
            if (isMark) {
                mConversationGroupBeans.removeAll(markBeans);
            } else {
                mConversationGroupBeans.removeAll(groupBeans);
            }
        } else {
            mConversationGroupBeans.clear();
            if (isMark) {
                mConversationGroupBeans.addAll(groupBeans);
                mConversationGroupBeans.addAll(beans);
            } else {
                mConversationGroupBeans.addAll(beans);
                mConversationGroupBeans.addAll(markBeans);
            }
        }

        if (mConversationGroupBeans.isEmpty()) {
            refreshGroupView(true);
        } else {
            refreshGroupView(false);
        }

        ConversationGroupBean bean = new ConversationGroupBean();
        bean.setTitle(getString(R.string.conversation_page_all));
        bean.setWeight(ConversationGroupBean.CONVERSATION_ALL_GROUP_WEIGHT);
        bean.setGroupType(ConversationGroupBean.CONVERSATION_GROUP_TYPE_DEFAULT);
        if (!mConversationGroupBeans.contains(bean)) {
            mConversationGroupBeans.add(bean);
        }

        refreshConversationGroupSort();
        adapter.notifyDataSetChanged();
    }

    private ViewPager2.OnPageChangeCallback changeCallback = new ViewPager2.OnPageChangeCallback() {
        @Override
        public void onPageSelected(int position) {
            TUIConversationLog.d(TAG, "onPageSelected position" + position);
            // 可以来设置选中时tab的大小
            selectedPosition = position;
            int tabCount = mConversationTabLayout.getTabCount();
            for (int i = 0; i < tabCount; i++) {
                TabLayout.Tab tab = mConversationTabLayout.getTabAt(i);
                View layoutView = tab.getCustomView();
                TextView titileView = layoutView.findViewById(R.id.tab_title);
                if (tab.getPosition() == position) {
                    titileView.setTextColor(selectedColor);
                } else {
                    titileView.setTextColor(getResources().getColor(R.color.black));
                }
            }
        }
    };

    public void initSearchView() {
        TUICore.raiseExtension(TUIConstants.TUIConversation.Extension.ConversationListHeader.CLASSIC_EXTENSION_ID, searchLayout, null);
    }

    @Override
    public void onResume() {
        TUIConversationLog.d(TAG, "onResume");
        super.onResume();
    }

    @Override
    public void onDestroy() {
        TUIConversationLog.d(TAG, "onDestroy");
        mediator.detach();
        mViewPager.unregisterOnPageChangeCallback(changeCallback);
        mConversationGroupBeans.clear();
        TUIConversationService.getInstance().setConversationGroupNotifyListenerNull();
        conversationGroupNotifyListener = null;
        super.onDestroy();
    }
}
