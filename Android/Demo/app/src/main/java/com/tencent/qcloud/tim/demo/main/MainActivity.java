package com.tencent.qcloud.tim.demo.main;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.viewpager2.widget.ViewPager2;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.SplashActivity;
import com.tencent.qcloud.tim.demo.profile.ProfileFragment;
import com.tencent.qcloud.tim.demo.push.HandleOfflinePushCallBack;
import com.tencent.qcloud.tim.demo.push.OfflineMessageBean;
import com.tencent.qcloud.tim.demo.push.OfflineMessageDispatcher;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.action.PopActionClickListener;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.TUICommunityFragment;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.classicui.pages.TUIContactFragment;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.page.TUIConversationFragment;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class MainActivity extends BaseLightActivity {

    private static final String TAG = MainActivity.class.getSimpleName();
    private TextView mCommunityBtnText;
    private TextView mConversationBtnText;
    private TextView mContactBtnText;
    private TextView mProfileSelfBtnText;
    private View mConversationBtn;
    private ImageView mCommunityBtnIcon;
    private ImageView mConversationBtnIcon;
    private ImageView mContactBtnIcon;
    private ImageView mProfileSelfBtnIcon;
    private TextView mMsgUnread;
    private TextView mNewFriendUnread;
    private View mainNavigationBar;

    private TitleBarLayout mainTitleBar;
    private Menu menu;

    private ViewPager2 mainViewPager;
    private List<Fragment> fragments;

    private int count = 0;
    private long lastClickTime = 0;
    private HashMap<String, V2TIMConversation> markUnreadMap = new HashMap<>();

    private static WeakReference<MainActivity> instance;
    private BroadcastReceiver unreadCountReceiver;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        instance = new WeakReference<>(this);

        initView();
        initUnreadCountReceiver();
    }

    private void initUnreadCountReceiver() {
        unreadCountReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                long unreadCount = intent.getLongExtra(TUIConstants.UNREAD_COUNT_EXTRA, 0);
                if (unreadCount > 0) {
                    mMsgUnread.setVisibility(View.VISIBLE);
                } else {
                    mMsgUnread.setVisibility(View.GONE);
                }
                String unreadStr = "" + unreadCount;
                if (unreadCount > 100) {
                    unreadStr = "99+";
                }
                mMsgUnread.setText(unreadStr);
                // update Huawei offline push Badge
                OfflineMessageDispatcher.updateBadge(MainActivity.this, (int) unreadCount);
            }
        };

        IntentFilter unreadCountFilter = new IntentFilter();
        unreadCountFilter.addAction(TUIConstants.CONVERSATION_UNREAD_COUNT_ACTION);
        LocalBroadcastManager.getInstance(this).registerReceiver(unreadCountReceiver, unreadCountFilter);
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
        initMenuAction();
        mCommunityBtnText = findViewById(R.id.tab_community_tv);
        mConversationBtnText = findViewById(R.id.conversation);
        mContactBtnText = findViewById(R.id.contact);
        mProfileSelfBtnText = findViewById(R.id.mine);
        mCommunityBtnIcon = findViewById(R.id.tab_community_icon);
        mConversationBtnIcon = findViewById(R.id.tab_conversation_icon);
        mContactBtnIcon = findViewById(R.id.tab_contact_icon);
        mProfileSelfBtnIcon = findViewById(R.id.tab_profile_icon);
        mConversationBtn = findViewById(R.id.conversation_btn_group);
        mMsgUnread = findViewById(R.id.msg_total_unread);
        mNewFriendUnread = findViewById(R.id.new_friend_total_unread);
        mainNavigationBar = findViewById(R.id.main_navigation_bar);

        fragments = new ArrayList<>();
        fragments.add(new TUIConversationFragment());
        fragments.add(new TUICommunityFragment());
        fragments.add(new TUIContactFragment());
        fragments.add(new ProfileFragment());

        mainViewPager = findViewById(R.id.view_pager);
        FragmentAdapter fragmentAdapter = new FragmentAdapter(this);
        fragmentAdapter.setFragmentList(fragments);
        mainViewPager.setUserInputEnabled(false);
        mainViewPager.setOffscreenPageLimit(4);
        mainViewPager.setAdapter(fragmentAdapter);
        mainViewPager.setCurrentItem(0, false);
        setConversationTitleBar();

        prepareToClearAllUnreadMessage();
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

    private void prepareToClearAllUnreadMessage() {
        mMsgUnread.setOnTouchListener(new View.OnTouchListener() {
            private float downX;
            private float downY;
            private boolean isTriggered = false;
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        downX = mMsgUnread.getX();
                        downY = mMsgUnread.getY();
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
                        if (Math.abs(translationX) > 200|| Math.abs(translationY) > 200) {
                            isTriggered = true;
                            mMsgUnread.setVisibility(View.GONE);
                            triggerClearAllUnreadMessage();
                        }
                        break;
                    case MotionEvent.ACTION_UP:
                        view.setTranslationX(0);
                        view.setTranslationY(0);
                        isTriggered = false;
                        break;
                    case MotionEvent.ACTION_CANCEL:
                        isTriggered = false;
                        break;
                }

                return true;
            }
        });
    }

    private void triggerClearAllUnreadMessage() {
        V2TIMManager.getMessageManager().markAllMessageAsRead(new V2TIMCallback() {
            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "markAllMessageAsRead success");
                ToastUtil.toastShortMessage(MainActivity.this.getString(R.string.mark_all_message_as_read_succ));
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.i(TAG, "markAllMessageAsRead error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                ToastUtil.toastShortMessage(MainActivity.this.getString(R.string.mark_all_message_as_read_err_format, code, ErrorMessageConverter.convertIMError(code, desc)));
                mMsgUnread.setVisibility(View.VISIBLE);
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

                V2TIMManager.getConversationManager().markConversation(unreadConversationIDList,
                        V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD,
                        false,
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
                        DemoLog.e(TAG, "triggerClearAllUnreadMessage->markConversation error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                    }
                });
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "triggerClearAllUnreadMessage->getMarkUnreadConversationList error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    private void getMarkUnreadConversationList(V2TIMConversationListFilter filter, long nextSeq, int count, boolean fromStart, V2TIMValueCallback<HashMap<String, V2TIMConversation>> callback) {
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


    public void tabClick(View view) {
        resetMenuState();
        switch (view.getId()) {
            case R.id.conversation_btn_group:
                mainTitleBar.setVisibility(View.VISIBLE);
                mainViewPager.setCurrentItem(0, false);
                setConversationTitleBar();
                mConversationBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_selected_text_color)));
                mConversationBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_conversation_selected_bg)));
                break;
            case R.id.community_btn_group:
                mainTitleBar.setVisibility(View.GONE);
                mainViewPager.setCurrentItem(1, false);
                mCommunityBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_selected_text_color)));
                mCommunityBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_community_selected_bg)));
                setCommunityBackground();
                break;
            case R.id.contact_btn_group:
                mainTitleBar.setVisibility(View.VISIBLE);
                mainViewPager.setCurrentItem(2, false);
                setContactTitleBar();
                mContactBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_selected_text_color)));
                mContactBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_contact_selected_bg)));
                break;
            case R.id.myself_btn_group:
                mainTitleBar.setVisibility(View.VISIBLE);
                mainViewPager.setCurrentItem(3, false);
                setProfileTitleBar();
                mProfileSelfBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_selected_text_color)));
                mProfileSelfBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_profile_selected_bg)));
                break;
            default:
                break;
        }
    }

    private void setCommunityBackground() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(getResources().getColor(R.color.demo_community_page_status_bar_color));
        }
        mainNavigationBar.setBackgroundColor(getResources().getColor(R.color.demo_community_page_navigate_bar_color));
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

    private void setProfileTitleBar() {
        mainTitleBar.getLeftGroup().setVisibility(View.GONE);
        mainTitleBar.getRightGroup().setVisibility(View.GONE);
        mainTitleBar.setTitle(getResources().getString(R.string.profile), ITitleBarLayout.Position.MIDDLE);
    }

    private void resetMenuState() {
        mConversationBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_normal_text_color)));
        mConversationBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_conversation_normal_bg)));
        mCommunityBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_normal_text_color)));
        mCommunityBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_community_normal_bg)));
        mContactBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_normal_text_color)));
        mContactBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_contact_normal_bg)));
        mProfileSelfBtnText.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_normal_text_color)));
        mProfileSelfBtnIcon.setBackground(getResources().getDrawable(TUIThemeManager.getAttrResId(this, R.attr.demo_main_tab_profile_normal_bg)));

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(getResources().getColor(TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_header_start_color)));
        }
        mainNavigationBar.setBackgroundResource(TUIThemeManager.getAttrResId(this, R.attr.demo_navigate_bar_bg));
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
        handleOfflinePush();
    }

    private void handleOfflinePush() {
        Intent intent = getIntent();
        if (intent == null) {
            DemoLog.d(TAG, "handleOfflinePush intent is null");
            return;
        }

        if (OfflinePushConfigs.getOfflinePushConfigs().getClickNotificationCallbackMode() == OfflinePushConfigs.CLICK_NOTIFICATION_CALLBACK_INTENT) {
            if (DemoApplication.tuikit_demo_style == 1) {
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
                        int unreadCount = v2TIMFriendApplicationResult.getUnreadCount();
                        if (unreadCount > 0) {
                            mNewFriendUnread.setVisibility(View.VISIBLE);
                        } else {
                            mNewFriendUnread.setVisibility(View.GONE);
                        }
                        String unreadStr = "" + unreadCount;
                        if (unreadCount > 100) {
                            unreadStr = "99+";
                        }
                        mNewFriendUnread.setText(unreadStr);
                    }
                });
            }

            @Override
            public void onError(int code, String desc) {

            }
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
    }

    public static void finishMainActivity() {
        if (instance != null && instance.get() != null) {
            instance.get().finish();
        }
    }

}
