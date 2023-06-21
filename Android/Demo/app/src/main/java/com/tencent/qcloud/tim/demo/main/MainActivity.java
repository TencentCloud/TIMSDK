package com.tencent.qcloud.tim.demo.main;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;
import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.profile.ProfileFragment;
import com.tencent.qcloud.tim.demo.push.HandleOfflinePushCallBack;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIKitConstants;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.BuildConfig;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.UnreadCountTextView;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.TUICommunityFragment;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.classicui.pages.TUIContactFragment;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.page.TUIConversationFragmentContainer;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class MainActivity extends BaseLightActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private TabRecyclerView tabList;
    private View navigationBar;
    private TabAdapter tabAdapter;
    private OnTabEventListener onTabEventListener;
    private TabBean conversationBean;
    private TabBean communityBean;
    private TabBean contactsBean;
    private TabBean profileBean;
    private TabBean recentCallsBean;

    private TitleBarLayout mainTitleBar;
    private Menu menu;

    private ViewPager2 mainViewPager;
    private List<Fragment> fragments;
    private List<TabBean> tabBeanList;

    private int count = 0;
    private long lastClickTime = 0;
    private HashMap<String, V2TIMConversation> markUnreadMap = new HashMap<>();
    private TabBean selectedItem;
    private TabBean preSelectedItem;

    private static WeakReference<MainActivity> instance;
    private BroadcastReceiver unreadCountReceiver;
    private BroadcastReceiver recentCallsReceiver;

    private FragmentAdapter fragmentAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        instance = new WeakReference<>(this);
        initView();
        initUnreadCountReceiver();
        initRecentCallsReceiver();
    }

    private void initUnreadCountReceiver() {
        unreadCountReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                conversationBean.unreadCount = intent.getLongExtra(TUIConstants.UNREAD_COUNT_EXTRA, 0);
                onTabBeanChanged(conversationBean);
            }
        };

        IntentFilter unreadCountFilter = new IntentFilter();
        unreadCountFilter.addAction(TUIConstants.CONVERSATION_UNREAD_COUNT_ACTION);
        LocalBroadcastManager.getInstance(this).registerReceiver(unreadCountReceiver, unreadCountFilter);
    }

    private void initRecentCallsReceiver() {
        recentCallsReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (intent != null) {
                    boolean isEnableRecentCalls = intent.getBooleanExtra(TUIKitConstants.RECENT_CALLS_ENABLE, false);
                    onRecentCallsStatusChanged(isEnableRecentCalls);
                }
            }
        };

        IntentFilter recentCallsFilter = new IntentFilter();
        recentCallsFilter.addAction(TUIKitConstants.RECENT_CALLS_ENABLE_ACTION);
        LocalBroadcastManager.getInstance(this).registerReceiver(recentCallsReceiver, recentCallsFilter);
    }

    private void onRecentCallsStatusChanged(boolean isEnable) {
        if (isEnable) {
            Map<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE, TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE_CLASSIC);
            Object object =
                TUICore.createObject(TUIConstants.TUICalling.ObjectFactory.FACTORY_NAME, TUIConstants.TUICalling.ObjectFactory.RecentCalls.OBJECT_NAME, param);
            if (object instanceof Fragment) {
                recentCallsBean = new TabBean();
                recentCallsBean.weight = 95;
                recentCallsBean.text = R.string.appkit_recent_calls_tab_name;
                recentCallsBean.normalIcon = R.attr.demo_main_tab_recent_calls_normal_bg;
                recentCallsBean.selectedIcon = R.attr.demo_main_tab_recent_calls_selected_bg;
                recentCallsBean.fragment = (Fragment) object;
                onNewTabBean(recentCallsBean);
            }
        } else {
            onTabBeanRemoved(recentCallsBean);
            recentCallsBean = null;
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        DemoLog.i(TAG, "onNewIntent");
        setIntent(intent);
    }

    private void initView() {
        setContentView(R.layout.main_activity);

        mainTitleBar = findViewById(R.id.main_title_bar);
        navigationBar = findViewById(R.id.main_navigation_bar);
        initMenuAction();
        initTabs();
        setConversationTitleBar();
    }

    private void initTabs() {
        tabBeanList = new ArrayList<>();
        // conversation
        conversationBean = new TabBean();
        conversationBean.normalIcon = R.attr.demo_main_tab_conversation_normal_bg;
        conversationBean.selectedIcon = R.attr.demo_main_tab_conversation_selected_bg;
        conversationBean.text = R.string.tab_conversation_tab_text;
        conversationBean.fragment = new TUIConversationFragmentContainer();
        conversationBean.showUnread = true;
        conversationBean.unreadClearEnable = true;
        conversationBean.weight = 100;
        tabBeanList.add(conversationBean);

        // community
        communityBean = new TabBean();
        communityBean.normalIcon = R.attr.demo_main_tab_community_normal_bg;
        communityBean.selectedIcon = R.attr.demo_main_tab_community_selected_bg;
        communityBean.text = R.string.tab_community_tab_text;
        communityBean.fragment = new TUICommunityFragment();
        communityBean.weight = 90;
        tabBeanList.add(communityBean);

        // contacts
        contactsBean = new TabBean();
        contactsBean.normalIcon = R.attr.demo_main_tab_contact_normal_bg;
        contactsBean.selectedIcon = R.attr.demo_main_tab_contact_selected_bg;
        contactsBean.text = R.string.tab_contact_tab_text;
        contactsBean.fragment = new TUIContactFragment();
        contactsBean.weight = 80;
        contactsBean.showUnread = true;
        tabBeanList.add(contactsBean);

        // profile
        profileBean = new TabBean();
        profileBean.normalIcon = R.attr.demo_main_tab_profile_normal_bg;
        profileBean.selectedIcon = R.attr.demo_main_tab_profile_selected_bg;
        profileBean.text = R.string.tab_profile_tab_text;
        profileBean.fragment = new ProfileFragment();
        tabBeanList.add(profileBean);

        Collections.sort(tabBeanList, new Comparator<TabBean>() {
            @Override
            public int compare(TabBean o1, TabBean o2) {
                return o2.weight - o1.weight;
            }
        });

        tabList = findViewById(R.id.tab_list);
        tabList.disableIntercept();
        tabList.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        tabList.addItemDecoration(new TabDecoration());
        tabAdapter = new TabAdapter();
        tabList.setAdapter(tabAdapter);
        fragments = new ArrayList<>();
        for (TabBean tabBean : tabBeanList) {
            fragments.add(tabBean.fragment);
        }

        mainViewPager = findViewById(R.id.view_pager);
        fragmentAdapter = new FragmentAdapter(this);
        fragmentAdapter.setFragmentList(fragments);
        mainViewPager.setUserInputEnabled(false);
        mainViewPager.setOffscreenPageLimit(5);
        mainViewPager.setAdapter(fragmentAdapter);
        setTabSelected(conversationBean);

        onTabEventListener = new OnTabEventListener() {
            @Override
            public void onTabSelected(TabBean tabBean) {
                setTabSelected(tabBean);
            }

            @Override
            public void onTabUnreadCleared(TabBean tabBean) {
                if (tabBean == conversationBean) {
                    triggerClearAllUnreadMessage();
                }
            }
        };
    }

    private void initMenuAction() {
        int titleBarIconSize = getResources().getDimensionPixelSize(R.dimen.demo_title_bar_icon_size);
        mainTitleBar.getLeftIcon().setMaxHeight(titleBarIconSize);
        mainTitleBar.getLeftIcon().setMaxWidth(titleBarIconSize);
        mainTitleBar.getRightIcon().setMaxHeight(titleBarIconSize);
        mainTitleBar.getRightIcon().setMaxWidth(titleBarIconSize);
        mainTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (menu == null) {
                    return;
                }
                if (menu.isShowing()) {
                    menu.hide();
                } else {
                    menu.show();
                }
            }
        });
    }

    private void triggerClearAllUnreadMessage() {
        V2TIMManager.getConversationManager().cleanConversationUnreadMessageCount("", 0, 0, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "cleanConversationUnreadMessageCount success");
                if (conversationBean != null) {
                    conversationBean.unreadCount = 0;
                    onTabBeanChanged(conversationBean);
                }
                ToastUtil.toastShortMessage(MainActivity.this.getString(R.string.mark_all_message_as_read_succ));
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.i(TAG, "cleanConversationUnreadMessageCount error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                ToastUtil.toastShortMessage(
                    MainActivity.this.getString(R.string.mark_all_message_as_read_err_format, code, ErrorMessageConverter.convertIMError(code, desc)));
            }
        });

        V2TIMConversationListFilter filter = new V2TIMConversationListFilter();
        filter.setMarkType(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD);
        getMarkUnreadConversationList(filter, 0, 100, true, new V2TIMValueCallback<HashMap<String, V2TIMConversation>>() {
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

                V2TIMManager.getConversationManager().markConversation(unreadConversationIDList, V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD, false,
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
                        }

                        @Override
                        public void onError(int code, String desc) {
                            DemoLog.e(TAG,
                                "triggerClearAllUnreadMessage->markConversation error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                        }
                    });
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG,
                    "triggerClearAllUnreadMessage->getMarkUnreadConversationList error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    private void getMarkUnreadConversationList(
        V2TIMConversationListFilter filter, long nextSeq, int count, boolean fromStart, V2TIMValueCallback<HashMap<String, V2TIMConversation>> callback) {
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
                DemoLog.e(TAG, "getMarkUnreadConversationList error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    private void setTabSelected(TabBean tabBean) {
        if (tabBean == null) {
            return;
        }
        int position = tabBeanList.indexOf(tabBean);
        if (position == -1) {
            return;
        }
        tabAdapter.notifyItemChanged(position);
        mainViewPager.setCurrentItem(position, false);

        resetMenuState();
        mainTitleBar.setVisibility(View.VISIBLE);

        if (tabBean == conversationBean) {
            setConversationTitleBar();
        } else if (tabBean == communityBean) {
            mainTitleBar.setVisibility(View.GONE);
            setCommunityBackground();
        } else if (tabBean == contactsBean) {
            setContactTitleBar();
        } else if (tabBean == profileBean) {
            setProfileTitleBar();
        } else if (tabBean == recentCallsBean) {
            setRecentCallsTitleBar();
        }
        preSelectedItem = selectedItem;
        selectedItem = tabBean;
        int prePosition = tabBeanList.indexOf(preSelectedItem);
        if (prePosition == -1) {
            return;
        }
        tabAdapter.notifyItemChanged(prePosition);
    }

    private void setCommunityBackground() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(getResources().getColor(R.color.demo_community_page_status_bar_color));
        }
        navigationBar.setBackgroundColor(getResources().getColor(R.color.demo_community_page_navigate_bar_color));
    }

    private void setConversationTitleBar() {
        mainTitleBar.setTitle(getResources().getString(R.string.conversation_title), ITitleBarLayout.Position.MIDDLE);
        mainTitleBar.getLeftGroup().setVisibility(View.GONE);
        mainTitleBar.getRightGroup().setVisibility(View.VISIBLE);
        mainTitleBar.setRightIcon(TUIThemeManager.getAttrResId(this, R.attr.demo_title_bar_more));
        int titleBarIconSize = getResources().getDimensionPixelSize(R.dimen.demo_title_bar_icon_size);
        ViewGroup.LayoutParams params = mainTitleBar.getRightIcon().getLayoutParams();
        params.width = titleBarIconSize;
        params.height = titleBarIconSize;
        mainTitleBar.getRightIcon().setLayoutParams(params);
        setConversationMenu();
        initTUIKitDemoUI();
    }

    private void initTUIKitDemoUI() {
        if (TUIConfig.getTUIHostType() != TUIConfig.TUI_HOST_TYPE_RTCUBE) {
            mainTitleBar.getLeftGroup().setVisibility(View.GONE);
            profileBean.text = R.string.tab_profile_tab_text;
            onTabBeanChanged(profileBean);
        } else {
            mainTitleBar.getLeftGroup().setVisibility(View.VISIBLE);
            ImageView imageView = mainTitleBar.getLeftIcon();
            imageView.setBackgroundResource(R.drawable.title_bar_left_icon);
            int iconwidth = ScreenUtil.dip2px(TUIConstants.TIMAppKit.BACK_RTCUBE_HOME_ICON_WIDTH);
            int iconHeight = ScreenUtil.dip2px(TUIConstants.TIMAppKit.BACK_RTCUBE_HOME_ICON_HEIGHT);
            ViewGroup.LayoutParams iconParams = imageView.getLayoutParams();
            iconParams.width = iconwidth;
            iconParams.height = iconHeight;
            imageView.setLayoutParams(iconParams);
            mainTitleBar.setOnLeftClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TIMAppKit.BACK_TO_RTCUBE_DEMO_TYPE_KEY, TUIConstants.TIMAppKit.BACK_TO_RTCUBE_DEMO_TYPE_IM);
                    TUICore.startActivity("TRTCMainActivity", bundle);
                    finish();
                }
            });

            profileBean.text = R.string.minimalist_tab_settings_tab_text;
            onTabBeanChanged(profileBean);
        }
    }

    private void setConversationMenu() {
        menu = new Menu(this, mainTitleBar.getRightIcon());
        PopActionClickListener popActionClickListener = new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                PopMenuAction action = (PopMenuAction) data;
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.start_conversation))) {
                    TUIUtils.startActivity("StartC2CChatActivity", null);
                }

                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.create_private_group))) {
                    Bundle bundle = new Bundle();
                    bundle.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.PRIVATE);
                    TUIUtils.startActivity("StartGroupChatActivity", bundle);
                }
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.create_group_chat))) {
                    Bundle bundle = new Bundle();
                    bundle.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.PUBLIC);
                    TUIUtils.startActivity("StartGroupChatActivity", bundle);
                }
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.create_chat_room))) {
                    Bundle bundle = new Bundle();
                    bundle.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.CHAT_ROOM);
                    TUIUtils.startActivity("StartGroupChatActivity", bundle);
                }
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.create_community))) {
                    Bundle bundle = new Bundle();
                    bundle.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.COMMUNITY);
                    TUIUtils.startActivity("StartGroupChatActivity", bundle);
                }

                menu.hide();
            }
        };

        List<PopMenuAction> menuActions = new ArrayList<>();

        PopMenuAction action = new PopMenuAction();

        action.setActionName(getResources().getString(R.string.start_conversation));
        action.setActionClickListener(popActionClickListener);
        action.setIconResId(R.drawable.create_c2c);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_group_chat));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        menu.setMenuAction(menuActions);
    }

    private void setContactTitleBar() {
        mainTitleBar.setTitle(getResources().getString(R.string.contact_title), ITitleBarLayout.Position.MIDDLE);
        mainTitleBar.getLeftGroup().setVisibility(View.GONE);
        mainTitleBar.getRightGroup().setVisibility(View.VISIBLE);
        mainTitleBar.setRightIcon(TUIThemeManager.getAttrResId(this, R.attr.demo_title_bar_more));
        setContactMenu();
        initTUIKitDemoUI();
    }

    public void setContactMenu() {
        menu = new Menu(this, mainTitleBar.getRightIcon());
        List<PopMenuAction> menuActionList = new ArrayList<>(2);
        PopActionClickListener popActionClickListener = new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                PopMenuAction action = (PopMenuAction) data;
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.add_friend))) {
                    Bundle bundle = new Bundle();
                    bundle.putBoolean(TUIContactConstants.GroupType.GROUP, false);
                    TUIUtils.startActivity("AddMoreActivity", bundle);
                }
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.add_group))) {
                    Bundle bundle = new Bundle();
                    bundle.putBoolean(TUIContactConstants.GroupType.GROUP, true);
                    TUIUtils.startActivity("AddMoreActivity", bundle);
                }
                menu.hide();
            }
        };
        PopMenuAction action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.add_friend));
        action.setIconResId(com.tencent.qcloud.tuikit.tuicontact.R.drawable.contact_add_friend);
        action.setActionClickListener(popActionClickListener);
        menuActionList.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.add_group));
        action.setIconResId(com.tencent.qcloud.tuikit.tuicontact.R.drawable.contact_add_group);
        action.setActionClickListener(popActionClickListener);
        menuActionList.add(action);
        menu.setMenuAction(menuActionList);
    }

    private void setRecentCallsTitleBar() {
        mainTitleBar.setVisibility(View.GONE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(
                getResources().getColor(TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_header_start_color)));
        }
    }

    private void setProfileTitleBar() {
        mainTitleBar.getLeftGroup().setVisibility(View.GONE);
        mainTitleBar.getRightGroup().setVisibility(View.GONE);
        mainTitleBar.setTitle(getResources().getString(R.string.profile), ITitleBarLayout.Position.MIDDLE);

        initTUIKitDemoUI();
    }

    private void resetMenuState() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(
                getResources().getColor(TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_header_start_color)));
        }
        navigationBar.setBackgroundResource(TUIThemeManager.getAttrResId(this, R.attr.demo_navigate_bar_bg));
    }

    private final V2TIMFriendshipListener friendshipListener = new V2TIMFriendshipListener() {
        @Override
        public void onFriendApplicationListAdded(List<V2TIMFriendApplication> applicationList) {
            refreshFriendApplicationUnreadCount();
        }

        @Override
        public void onFriendApplicationListDeleted(List<String> userIDList) {
            refreshFriendApplicationUnreadCount();
        }

        @Override
        public void onFriendApplicationListRead() {
            refreshFriendApplicationUnreadCount();
        }
    };

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            finish();
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void finish() {
        super.finish();
    }

    @Override
    protected void onStart() {
        DemoLog.i(TAG, "onStart");
        super.onStart();
    }

    @Override
    protected void onResume() {
        DemoLog.i(TAG, "onResume");
        super.onResume();
        registerUnreadListener();
        setCurrentItemTab();
        handleOfflinePush();
    }

    private void setCurrentItemTab() {
        if (TUIConfig.getTUIHostType() == TUIConfig.TUI_HOST_TYPE_RTCUBE) {
            Intent intent = getIntent();
            if (intent != null) {
                String tabName = intent.getStringExtra(TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_KEY);
                if (TextUtils.isEmpty(tabName)) {
                    tabName = TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_CHAT;
                }
                if (TextUtils.equals(tabName, TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_CHAT)) {
                    setTabSelected(conversationBean);
                } else if (TextUtils.equals(tabName, TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_COMMUNITY)) {
                    setTabSelected(communityBean);
                } else if (TextUtils.equals(tabName, TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_CONTACT)) {
                    setTabSelected(contactsBean);
                } else if (TextUtils.equals(tabName, TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_RECENT_CALLS)) {
                    setTabSelected(recentCallsBean);
                } else if (TextUtils.equals(tabName, TUIConstants.TIMAppKit.IM_DEMO_ITEM_TYPE_PROFILE)) {
                    setTabSelected(profileBean);
                }
            }
        }
    }

    private void handleOfflinePush() {
        Intent intent = getIntent();
        if (intent == null) {
            DemoLog.d(TAG, "handleOfflinePush intent is null");
            return;
        }

        if (OfflinePushConfigs.getOfflinePushConfigs().getClickNotificationCallbackMode() == OfflinePushConfigs.CLICK_NOTIFICATION_CALLBACK_INTENT) {
            if (AppConfig.DEMO_UI_STYLE == 1) {
                Intent minimalistIntent = new Intent(this, MainMinimalistActivity.class);
                minimalistIntent.putExtras(intent);
                if (intent != null) {
                    String ext = intent.getStringExtra(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY);
                    minimalistIntent.putExtra(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY, ext);
                }
                minimalistIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(minimalistIntent);
                finish();
                return;
            }

            TUIUtils.handleOfflinePush(intent, new HandleOfflinePushCallBack() {
                @Override
                public void onHandleOfflinePush(boolean hasLogged) {
                    if (hasLogged) {
                        setIntent(null);
                    } else {
                        finish();
                    }
                }
            });
        } else {
            String ext = intent.getStringExtra(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY);
            TUIUtils.handleOfflinePush(ext, new HandleOfflinePushCallBack() {
                @Override
                public void onHandleOfflinePush(boolean hasLogged) {
                    if (hasLogged) {
                        setIntent(null);
                    } else {
                        finish();
                    }
                }
            });
        }
    }


    private void registerUnreadListener() {
        V2TIMManager.getFriendshipManager().addFriendListener(friendshipListener);
        refreshFriendApplicationUnreadCount();
    }

    private void refreshFriendApplicationUnreadCount() {
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        contactsBean.unreadCount = v2TIMFriendApplicationResult.getUnreadCount();
                        onTabBeanChanged(contactsBean);
                    }
                });
            }

            @Override
            public void onError(int code, String desc) {}
        });
    }

    @Override
    protected void onPause() {
        DemoLog.i(TAG, "onPause");
        super.onPause();
        V2TIMManager.getFriendshipManager().removeFriendListener(friendshipListener);
    }

    @Override
    protected void onStop() {
        DemoLog.i(TAG, "onStop");
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        DemoLog.i(TAG, "onDestroy");
        super.onDestroy();

        if (unreadCountReceiver != null) {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(unreadCountReceiver);
            unreadCountReceiver = null;
        }
        if (recentCallsReceiver != null) {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(recentCallsReceiver);
            recentCallsReceiver = null;
        }
    }

    public static void finishMainActivity() {
        if (instance != null && instance.get() != null) {
            instance.get().finish();
        }
    }

    private void onTabBeanChanged(TabBean tabBean) {
        int index = tabBeanList.indexOf(tabBean);
        if (index == -1) {
            return;
        }
        tabAdapter.notifyItemChanged(index);
    }

    private void onNewTabBean(TabBean tabBean) {
        if (tabBean == null) {
            return;
        }
        tabBeanList.add(tabBean);
        Collections.sort(tabBeanList, new Comparator<TabBean>() {
            @Override
            public int compare(TabBean o1, TabBean o2) {
                return o2.weight - o1.weight;
            }
        });
        int index = tabBeanList.indexOf(tabBean);
        fragments.add(index, tabBean.fragment);
        tabAdapter.notifyItemInserted(index);
        tabAdapter.notifyItemRangeChanged(0, tabBeanList.size());
        fragmentAdapter.notifyItemInserted(index);
    }

    private void onTabBeanRemoved(TabBean tabBean) {
        if (tabBean == null) {
            return;
        }
        int index = tabBeanList.indexOf(tabBean);
        if (index == -1) {
            return;
        }
        tabBeanList.remove(tabBean);
        tabAdapter.notifyItemRemoved(index);
        tabAdapter.notifyItemRangeChanged(0, tabBeanList.size());
        fragments.remove(tabBean.fragment);
        fragmentAdapter.notifyItemRemoved(index);
    }

    static class TabBean {
        int weight;
        int normalIcon;
        int selectedIcon;
        int text;
        Fragment fragment;
        long unreadCount;
        boolean showUnread = false;
        boolean unreadClearEnable = false;
    }

    class TabAdapter extends RecyclerView.Adapter<TabAdapter.TabViewHolder> {
        @NonNull
        @Override
        public TabViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(MainActivity.this).inflate(R.layout.main_classic_bottom_tab_item_layout, null);
            return new TabViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull TabViewHolder holder, int position) {
            TabBean tabBean = tabBeanList.get(position);
            int width = getResources().getDimensionPixelOffset(R.dimen.demo_tab_bottom_item_width);
            ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(width, ViewGroup.LayoutParams.MATCH_PARENT);
            holder.itemView.setLayoutParams(params);
            holder.textView.setText(tabBean.text);
            if (selectedItem == tabBean) {
                holder.imageView.setBackgroundResource(TUIThemeManager.getAttrResId(MainActivity.this, tabBean.selectedIcon));
                holder.textView.setTextColor(
                    getResources().getColor(TUIThemeManager.getAttrResId(MainActivity.this, R.attr.demo_main_tab_selected_text_color)));
            } else {
                holder.imageView.setBackgroundResource(TUIThemeManager.getAttrResId(MainActivity.this, tabBean.normalIcon));
                holder.textView.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(MainActivity.this, R.attr.demo_main_tab_normal_text_color)));
            }
            if (tabBean.showUnread && tabBean.unreadCount > 0) {
                holder.unreadCountTextView.setVisibility(View.VISIBLE);
                if (tabBean.unreadCount > 99) {
                    holder.unreadCountTextView.setText("99+");
                } else {
                    holder.unreadCountTextView.setText(tabBean.unreadCount + "");
                }
                if (tabBean.unreadClearEnable) {
                    prepareToClearAllUnreadMessage(holder.unreadCountTextView, tabBean);
                } else {
                    holder.unreadCountTextView.setOnTouchListener(null);
                }
            } else {
                holder.unreadCountTextView.setVisibility(View.GONE);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onTabEventListener.onTabSelected(tabBean);
                }
            });
        }

        @SuppressLint("ClickableViewAccessibility")
        private void prepareToClearAllUnreadMessage(UnreadCountTextView unreadCountTextView, TabBean tabBean) {
            unreadCountTextView.setOnTouchListener(new View.OnTouchListener() {
                private float downX;
                private float downY;
                private boolean isTriggered = false;
                @Override
                public boolean onTouch(View view, MotionEvent event) {
                    switch (event.getAction()) {
                        case MotionEvent.ACTION_DOWN:
                            downX = unreadCountTextView.getX();
                            downY = unreadCountTextView.getY();
                            break;
                        case MotionEvent.ACTION_MOVE:
                            if (isTriggered) {
                                return true;
                            }
                            float viewX = view.getX();
                            float viewY = view.getY();
                            float eventX = event.getX();
                            float eventY = event.getY();
                            float translationX = eventX + viewX - downX;
                            float translationY = eventY + viewY - downY;
                            view.setTranslationX(translationX);
                            view.setTranslationY(translationY);
                            // If the moved x and y axis coordinates exceed a certain pixel, it will trigger one-click to clear all unread sessions
                            if (Math.abs(translationX) > 200 || Math.abs(translationY) > 200) {
                                isTriggered = true;
                                unreadCountTextView.setVisibility(View.GONE);
                                onTabEventListener.onTabUnreadCleared(tabBean);
                            }
                            break;
                        case MotionEvent.ACTION_UP:
                            view.setTranslationX(0);
                            view.setTranslationY(0);
                            isTriggered = false;
                            break;
                        case MotionEvent.ACTION_CANCEL:
                            view.setTranslationX(0);
                            view.setTranslationY(0);
                            isTriggered = false;
                            break;
                    }

                    return true;
                }
            });
        }

        @Override
        public int getItemCount() {
            if (tabBeanList == null) {
                return 0;
            }
            return tabBeanList.size();
        }

        class TabViewHolder extends RecyclerView.ViewHolder {
            ImageView imageView;
            TextView textView;
            UnreadCountTextView unreadCountTextView;
            public TabViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.tab_icon);
                textView = itemView.findViewById(R.id.tab_text);
                unreadCountTextView = itemView.findViewById(R.id.unread_view);
                unreadCountTextView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                    @Override
                    public void onViewAttachedToWindow(View v) {
                        disableClipOnParents(v);
                    }

                    @Override
                    public void onViewDetachedFromWindow(View v) {}
                });
            }

            private void disableClipOnParents(View v) {
                if (v == null) {
                    return;
                }
                if (v instanceof ViewGroup) {
                    ((ViewGroup) v).setClipChildren(false);
                    ((ViewGroup) v).setClipToPadding(false);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        ((ViewGroup) v).setClipToOutline(false);
                    }
                }
                if (v.getParent() instanceof View) {
                    disableClipOnParents((View) v.getParent());
                }
            }
        }
    }

    class TabDecoration extends RecyclerView.ItemDecoration {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            int columnNum = tabBeanList.size();
            int column = parent.getChildAdapterPosition(view);
            int screenWidth = ScreenUtil.getScreenWidth(MainActivity.this);
            int columnWidth = parent.getResources().getDimensionPixelSize(R.dimen.demo_tab_bottom_item_width);
            if (columnNum > 1) {
                int leftRightSpace = (screenWidth - columnNum * columnWidth) / (columnNum - 1);
                outRect.left = column * leftRightSpace / columnNum;
                outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;
            }
        }
    }

    interface OnTabEventListener {
        void onTabSelected(TabBean tabBean);
        void onTabUnreadCleared(TabBean tabBean);
    }
}
