package com.tencent.qcloud.tim.demo.main;

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
import androidx.cardview.widget.CardView;
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
import com.tencent.qcloud.tim.demo.profile.ProfileMinimalistFragment;
import com.tencent.qcloud.tim.demo.push.HandleOfflinePushCallBack;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIKitConstants;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.BuildConfig;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.UnreadCountTextView;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.TUIContactMinimalistFragment;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page.TUIConversationMinimalistFragment;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class MainMinimalistActivity extends BaseMinimalistLightActivity {
    private static final String TAG = MainMinimalistActivity.class.getSimpleName();

    private ViewPager2 mainViewPager;
    private List<Fragment> fragments;
    private FragmentAdapter fragmentAdapter;
    private HashMap<String, V2TIMConversation> markUnreadMap = new HashMap<>();

    private static WeakReference<MainMinimalistActivity> instance;
    private BroadcastReceiver unreadCountReceiver;
    private BroadcastReceiver recentCallsReceiver;

    private TabRecyclerView tabList;
    private CardView navigationBar;
    private TabAdapter tabAdapter;
    private OnTabEventListener onTabEventListener;
    private TabBean conversationBean;
    private TabBean communityBean;
    private TabBean contactsBean;
    private TabBean profileBean;
    private TabBean recentCallsBean;

    private List<TabBean> tabBeanList;

    private TabBean selectedItem;
    private TabBean preSelectedItem;

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
                long unreadCount = intent.getLongExtra(TUIConstants.UNREAD_COUNT_EXTRA, 0);
                conversationBean.unreadCount = unreadCount;
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
                    boolean enableRecentCalls = intent.getBooleanExtra(TUIKitConstants.MINIMALIST_RECENT_CALLS_ENABLE, true);
                    onRecentCallsStatusChanged(enableRecentCalls);
                }
            }
        };

        IntentFilter recentCallsFilter = new IntentFilter();
        recentCallsFilter.addAction(TUIKitConstants.RECENT_CALLS_ENABLE_ACTION);
        LocalBroadcastManager.getInstance(this).registerReceiver(recentCallsReceiver, recentCallsFilter);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        DemoLog.i(TAG, "onNewIntent");
        setIntent(intent);
    }

    private void initView() {
        setContentView(R.layout.overseas_main_activity);
        navigationBar = findViewById(R.id.main_navigation_bar);
        initTabs();
    }

    private void initTabs() {
        tabBeanList = new ArrayList<>();
        // conversation
        conversationBean = new TabBean();
        conversationBean.normalIcon = R.drawable.demo_overseas_main_tab_conversation_normal;
        conversationBean.selectedIcon = R.drawable.demo_overseas_main_tab_conversation_selected;
        conversationBean.text = R.string.tab_conversation_tab_text;
        conversationBean.fragment = new TUIConversationMinimalistFragment();
        conversationBean.showUnread = true;
        conversationBean.unreadClearEnable = true;
        conversationBean.weight = 100;
        tabBeanList.add(conversationBean);

        // contacts
        contactsBean = new TabBean();
        contactsBean.normalIcon = R.drawable.demo_overseas_main_tab_contact_normal_bg;
        contactsBean.selectedIcon = R.drawable.demo_overseas_main_tab_contact_selected_bg;
        contactsBean.text = R.string.minimalist_tab_contacts_tab_text;
        contactsBean.fragment = new TUIContactMinimalistFragment();
        contactsBean.weight = 80;
        contactsBean.showUnread = true;
        tabBeanList.add(contactsBean);

        // profile
        profileBean = new TabBean();
        profileBean.normalIcon = R.drawable.demo_overseas_main_tab_settings_normal_bg;
        profileBean.selectedIcon = R.drawable.demo_overseas_main_tab_settings_selected_bg;
        profileBean.text = R.string.minimalist_tab_settings_tab_text;
        profileBean.weight = 70;
        profileBean.fragment = new ProfileMinimalistFragment();
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

        mainViewPager.requestDisallowInterceptTouchEvent(true);
        tabList.requestDisallowInterceptTouchEvent(true);
        navigationBar.requestDisallowInterceptTouchEvent(true);
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

    private void onRecentCallsStatusChanged(boolean isEnable) {
        if (isEnable) {
            Map<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE, TUIConstants.TUICalling.ObjectFactory.RecentCalls.UI_STYLE_MINIMALIST);
            Object object =
                TUICore.createObject(TUIConstants.TUICalling.ObjectFactory.FACTORY_NAME, TUIConstants.TUICalling.ObjectFactory.RecentCalls.OBJECT_NAME, param);
            if (object instanceof Fragment) {
                recentCallsBean = new TabBean();
                recentCallsBean.weight = 95;
                recentCallsBean.text = R.string.appkit_recent_calls_tab_name;
                recentCallsBean.normalIcon = R.drawable.demo_minimalist_recent_calls_not_selected;
                recentCallsBean.selectedIcon = R.drawable.demo_minimalist_recent_calls_selected;
                recentCallsBean.fragment = (Fragment) object;
                onNewTabBean(recentCallsBean);
            }
        } else {
            onTabBeanRemoved(recentCallsBean);
            recentCallsBean = null;
        }
    }

    private void triggerClearAllUnreadMessage() {
        V2TIMManager.getMessageManager().markAllMessageAsRead(new V2TIMCallback() {
            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "markAllMessageAsRead success");
                if (conversationBean != null) {
                    conversationBean.unreadCount = 0;
                    onTabBeanChanged(conversationBean);
                }
                ToastUtil.toastShortMessage(MainMinimalistActivity.this.getString(R.string.mark_all_message_as_read_succ));
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.i(TAG, "markAllMessageAsRead error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                ToastUtil.toastShortMessage(MainMinimalistActivity.this.getString(
                    R.string.mark_all_message_as_read_err_format, code, ErrorMessageConverter.convertIMError(code, desc)));
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
        preSelectedItem = selectedItem;
        selectedItem = tabBean;
        int prePosition = tabBeanList.indexOf(preSelectedItem);
        if (prePosition == -1) {
            return;
        }
        tabAdapter.notifyItemChanged(prePosition);
    }

    private void setCurrentMenuState(int type) {
        //        selectedItem = type;
        mainViewPager.setCurrentItem(type, false);
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
        setCurrentItemTab();
        registerUnreadListener();
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
                        int unreadCount = v2TIMFriendApplicationResult.getUnreadCount();
                        contactsBean.unreadCount = unreadCount;
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
        public TabAdapter.TabViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(MainMinimalistActivity.this).inflate(R.layout.main_classic_bottom_tab_item_layout, null);
            return new TabAdapter.TabViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull TabAdapter.TabViewHolder holder, int position) {
            TabBean tabBean = tabBeanList.get(position);
            int width = getResources().getDimensionPixelOffset(R.dimen.demo_tab_bottom_item_width);
            ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(width, ViewGroup.LayoutParams.MATCH_PARENT);
            holder.itemView.setLayoutParams(params);
            holder.textView.setText(tabBean.text);
            ((ViewGroup) holder.itemView).requestDisallowInterceptTouchEvent(true);

            if (tabBean == selectedItem) {
                holder.imageView.setBackgroundResource(tabBean.selectedIcon);
                holder.textView.setTextColor(getResources().getColor(R.color.demo_main_tab_text_selected_color_light));
            } else {
                holder.imageView.setBackgroundResource(tabBean.normalIcon);
                holder.textView.setTextColor(getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_light_bg_secondary_text_color_light));
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

            holder.itemView.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    return false;
                }
            });
        }

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

        public void disableClipOnParents(View v) {
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
                        disableClipOnParents((View) v.getParent());
                    }

                    @Override
                    public void onViewDetachedFromWindow(View v) {}
                });
            }
        }
    }

    class TabDecoration extends RecyclerView.ItemDecoration {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            int columnNum = tabBeanList.size();
            int column = parent.getChildAdapterPosition(view);
            int screenWidth = ScreenUtil.getScreenWidth(MainMinimalistActivity.this);
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
