package com.tencent.qcloud.tim.demo.main;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.widget.ViewPager2;

import com.google.gson.Gson;
import com.heytap.msp.push.HeytapPushManager;
import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.common.ApiException;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.bean.CallModel;
import com.tencent.qcloud.tim.demo.bean.OfflineMessageBean;
import com.tencent.qcloud.tim.demo.profile.ProfileFragment;
import com.tencent.qcloud.tim.demo.thirdpush.HUAWEIHmsMessageService;
import com.tencent.qcloud.tim.demo.thirdpush.OPPOPushImpl;
import com.tencent.qcloud.tim.demo.thirdpush.OfflineMessageDispatcher;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.action.PopActionClickListener;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.menu.Menu;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.ui.pages.TUIContactFragment;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.ui.page.TUIConversationFragment;
import com.vivo.push.IPushActionListener;
import com.vivo.push.PushClient;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends BaseLightActivity {

    private static final String TAG = MainActivity.class.getSimpleName();

    private TextView mConversationBtn;
    private TextView mContactBtn;
    private TextView mProfileSelfBtn;
    private TextView mMsgUnread;
    private View mLastTab;

    private TitleBarLayout mainTitleBar;
    private Menu menu;

    private ViewPager2 mainViewPager;
    private List<Fragment> fragments;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        prepareThirdPushToken();
        initView();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        DemoLog.i(TAG, "onNewIntent");
        setIntent(intent);
        prepareThirdPushToken();
    }

    private void prepareThirdPushToken() {
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();

        if (BrandUtil.isBrandHuawei()) {
            // 华为离线推送
            new Thread() {
                @Override
                public void run() {
                    try {
                        // read from agconnect-services.json
                        String appId = AGConnectServicesConfig.fromContext(MainActivity.this).getString("client/app_id");
                        String token = HmsInstanceId.getInstance(MainActivity.this).getToken(appId, "HCM");
                        DemoLog.i(TAG, "huawei get token:" + token);
                        if(!TextUtils.isEmpty(token)) {
                            ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
                            ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
                        }
                    } catch (ApiException e) {
                        DemoLog.e(TAG, "huawei get token failed, " + e);
                    }
                }
            }.start();
        } else if (BrandUtil.isBrandVivo()) {
            // vivo离线推送
            DemoLog.i(TAG, "vivo support push: " + PushClient.getInstance(getApplicationContext()).isSupport());
            PushClient.getInstance(getApplicationContext()).turnOnPush(new IPushActionListener() {
                @Override
                public void onStateChanged(int state) {
                    if (state == 0) {
                        String regId = PushClient.getInstance(getApplicationContext()).getRegId();
                        DemoLog.i(TAG, "vivopush open vivo push success regId = " + regId);
                        ThirdPushTokenMgr.getInstance().setThirdPushToken(regId);
                        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
                    } else {
                        // 根据vivo推送文档说明，state = 101 表示该vivo机型或者版本不支持vivo推送，链接：https://dev.vivo.com.cn/documentCenter/doc/156
                        DemoLog.i(TAG, "vivopush open vivo push fail state = " + state);
                    }
                }
            });
        } else if (HeytapPushManager.isSupportPush()) {
            // oppo离线推送
            OPPOPushImpl oppo = new OPPOPushImpl();
            oppo.createNotificationChannel(this);
            // oppo接入文档要求，应用必须要调用init(...)接口，才能执行后续操作。
            HeytapPushManager.init(this, false);
            HeytapPushManager.register(this, PrivateConstants.OPPO_PUSH_APPKEY, PrivateConstants.OPPO_PUSH_APPSECRET, oppo);
        } else if (BrandUtil.isGoogleServiceSupport()) {
            // 谷歌推送
        }
    }

    private void initView() {
        setContentView(R.layout.main_activity);
        mainTitleBar = findViewById(R.id.main_title_bar);
        initMenuAction();
        mConversationBtn = findViewById(R.id.conversation);
        mContactBtn = findViewById(R.id.contact);
        mProfileSelfBtn = findViewById(R.id.mine);
        mMsgUnread = findViewById(R.id.msg_total_unread);

        fragments = new ArrayList<>();
        fragments.add(new TUIConversationFragment());
        fragments.add(new TUIContactFragment());
        fragments.add(new ProfileFragment());

        mainViewPager = findViewById(R.id.view_pager);
        FragmentAdapter fragmentAdapter = new FragmentAdapter(this);
        fragmentAdapter.setFragmentList(fragments);
        // 关闭左右滑动切换页面
        mainViewPager.setUserInputEnabled(false);
        // 设置缓存数量为4 避免销毁重建
        mainViewPager.setOffscreenPageLimit(4);
        mainViewPager.setAdapter(fragmentAdapter);
        mainViewPager.setCurrentItem(0, false);
        setConversationTitleBar();
        if (mLastTab == null) {
            mLastTab = findViewById(R.id.conversation_btn_group);
        } else {
            // 初始化时，强制切换tab到上一次的位置
            View tmp = mLastTab;
            mLastTab = null;
            tabClick(tmp);
            mLastTab = tmp;
        }

        prepareToClearAllUnreadMessage();
    }

    private void initMenuAction() {
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
                        // 移动的 x 和 y 轴坐标超过一定像素则触发一键清空所有会话未读
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
                Log.i(TAG, "markAllMessageAsRead success");
                ToastUtil.toastShortMessage(MainActivity.this.getString(R.string.mark_all_message_as_read_succ));
            }

            @Override
            public void onError(int code, String desc) {
                Log.i(TAG, "markAllMessageAsRead error:" + code + ", desc:" + desc);
                ToastUtil.toastShortMessage(MainActivity.this.getString(R.string.mark_all_message_as_read_err_format, code, desc));
                mMsgUnread.setVisibility(View.VISIBLE);
            }
        });
    }

    public void tabClick(View view) {

        DemoLog.i(TAG, "tabClick last: " + mLastTab + " current: " + view);
        if (mLastTab != null && mLastTab.getId() == view.getId()) {
            return;
        }
        mLastTab = view;
        resetMenuState();
        switch (view.getId()) {
            case R.id.conversation_btn_group:
                mainViewPager.setCurrentItem(0, false);
                setConversationTitleBar();
                mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_selected), null, null);
                break;
            case R.id.contact_btn_group:
                mainViewPager.setCurrentItem(1, false);
                setContactTitleBar();
                mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_selected), null, null);
                break;
            case R.id.myself_btn_group:
                mainViewPager.setCurrentItem(2, false);
                setProfileTitleBar();
                mProfileSelfBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mProfileSelfBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.myself_selected), null, null);
                break;
            default:
                break;
        }
    }

    private void setConversationTitleBar() {
        mainTitleBar.setTitle(getResources().getString(R.string.conversation_title), ITitleBarLayout.Position.MIDDLE);
        mainTitleBar.getLeftGroup().setVisibility(View.GONE);
        mainTitleBar.getRightGroup().setVisibility(View.VISIBLE);
        mainTitleBar.setRightIcon(R.drawable.more_btn);
        setConversationMenu();
    }

    private void setConversationMenu() {
        menu = new Menu(this, mainTitleBar);
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

        // 设置右上角+号显示PopAction
        List<PopMenuAction> menuActions = new ArrayList<>();

        PopMenuAction action = new PopMenuAction();

        action.setActionName(getResources().getString(R.string.start_conversation));
        action.setActionClickListener(popActionClickListener);
        action.setIconResId(R.drawable.create_c2c);
        menuActions.add(action);
        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_private_group));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_group_chat));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_chat_room));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_community));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        menu.setMenuAction(menuActions);
    }

    private void setContactTitleBar() {
        mainTitleBar.setTitle(getResources().getString(R.string.contact_title), ITitleBarLayout.Position.MIDDLE);
        mainTitleBar.getLeftGroup().setVisibility(View.GONE);
        mainTitleBar.getRightGroup().setVisibility(View.VISIBLE);
        mainTitleBar.getRightIcon().setImageResource(R.drawable.more_btn);
        setContactMenu();
    }

    public void setContactMenu() {
        menu = new Menu(this, mainTitleBar);
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
        action.setIconResId(R.drawable.group_new_friend);
        action.setActionClickListener(popActionClickListener);
        menuActionList.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.add_group));
        action.setIconResId(R.drawable.ic_contact_join_group);
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
        mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_normal), null, null);
        mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_normal), null, null);
        mProfileSelfBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mProfileSelfBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.myself_normal), null, null);
    }


    private final V2TIMConversationListener unreadListener = new V2TIMConversationListener() {
        @Override
        public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
            if (totalUnreadCount > 0) {
                mMsgUnread.setVisibility(View.VISIBLE);
            } else {
                mMsgUnread.setVisibility(View.GONE);
            }
            String unreadStr = "" + totalUnreadCount;
            if (totalUnreadCount > 100) {
                unreadStr = "99+";
            }
            mMsgUnread.setText(unreadStr);
            // 华为离线推送角标
            HUAWEIHmsMessageService.updateBadge(MainActivity.this, (int) totalUnreadCount);
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

    private void registerUnreadListener() {
        V2TIMManager.getConversationManager().addConversationListener(unreadListener);
        V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
            @Override
            public void onSuccess(Long aLong) {
                runOnUiThread(() -> unreadListener.onTotalUnreadMessageCountChanged(aLong));
            }

            @Override
            public void onError(int code, String desc) {

            }
        });
    }

    private void handleOfflinePush() {
        if (V2TIMManager.getInstance().getLoginStatus() == V2TIMManager.V2TIM_STATUS_LOGOUT) {
            Bundle bundle = new Bundle();
            if (getIntent() != null && getIntent().getExtras() != null) {
                bundle.putAll(getIntent().getExtras());
            }
            TUIUtils.startActivity("SplashActivity", bundle);
            finish();
            return;
        }

        final OfflineMessageBean bean = OfflineMessageDispatcher.parseOfflineMessage(getIntent());
        if (bean != null) {
            setIntent(null);
            NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if (manager != null) {
                manager.cancelAll();
            }

            if (bean.action == OfflineMessageBean.REDIRECT_ACTION_CHAT) {
                if (TextUtils.isEmpty(bean.sender)) {
                    return;
                }
                TUIUtils.startChat(bean.sender, bean.nickname, bean.chatType);
            } else if (bean.action == OfflineMessageBean.REDIRECT_ACTION_CALL) {
                handleOfflinePushCall(bean);
            }
        }
    }

    void handleOfflinePushCall(OfflineMessageBean bean) {
        if (bean == null || bean.content == null) {
            return;
        }
        final CallModel model = new Gson().fromJson(bean.content, CallModel.class);
        DemoLog.i(TAG, "bean: " + bean + " model: " + model);
        if (model != null) {
            long timeout = V2TIMManager.getInstance().getServerTime() - bean.sendTime;
            if (timeout >= model.timeout) {
                ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.call_time_out));
            } else {
                TUIUtils.startCall(bean.sender, bean.content);
            }
        }
    }

    @Override
    protected void onPause() {
        DemoLog.i(TAG, "onPause");
        super.onPause();
        V2TIMManager.getConversationManager().removeConversationListener(unreadListener);
    }

    @Override
    protected void onStop() {
        DemoLog.i(TAG, "onStop");
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        DemoLog.i(TAG, "onDestroy");
        mLastTab = null;
        super.onDestroy();
    }

}
