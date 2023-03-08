package com.tencent.qcloud.tim.demo.main;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
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
import com.tencent.qcloud.tim.demo.push.OfflineMessageDispatcher;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.TUIContactMinimalistFragment;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page.TUIConversationMinimalistFragment;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class MainMinimalistActivity extends BaseMinimalistLightActivity {

    private static final String TAG = MainMinimalistActivity.class.getSimpleName();
    private TextView mConversationBtnText;
    private TextView mContactBtnText;
    private TextView mProfileSelfBtnText;
    private ImageView mConversationBtnIcon;
    private ImageView mContactBtnIcon;
    private ImageView mProfileSelfBtnIcon;
    private TextView mMsgUnread;
    private TextView mNewFriendUnread;

    private ViewPager2 mainViewPager;
    private List<Fragment> fragments;

    private HashMap<String, V2TIMConversation> markUnreadMap = new HashMap<>();

    private static WeakReference<MainMinimalistActivity> instance;
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
                OfflineMessageDispatcher.updateBadge(MainMinimalistActivity.this, (int) unreadCount);
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
        setContentView(R.layout.overseas_main_activity);

        mConversationBtnText = findViewById(R.id.conversation);
        mContactBtnText = findViewById(R.id.contact);
        mProfileSelfBtnText = findViewById(R.id.mine);
        mConversationBtnIcon = findViewById(R.id.tab_conversation_icon);
        mContactBtnIcon = findViewById(R.id.tab_contact_icon);
        mProfileSelfBtnIcon = findViewById(R.id.tab_profile_icon);
        mMsgUnread = findViewById(R.id.msg_total_unread);
        mNewFriendUnread = findViewById(R.id.new_friend_total_unread);

        fragments = new ArrayList<>();
        fragments.add(new TUIConversationMinimalistFragment());
        fragments.add(new TUIContactMinimalistFragment());
        fragments.add(new ProfileMinimalistFragment());

        mainViewPager = findViewById(R.id.view_pager);
        FragmentAdapter fragmentAdapter = new FragmentAdapter(this);
        fragmentAdapter.setFragmentList(fragments);
        mainViewPager.setUserInputEnabled(false);
        mainViewPager.setOffscreenPageLimit(4);
        mainViewPager.setAdapter(fragmentAdapter);
        mainViewPager.setCurrentItem(0, false);
        prepareToClearAllUnreadMessage();
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
                ToastUtil.toastShortMessage(MainMinimalistActivity.this.getString(R.string.mark_all_message_as_read_succ));
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.i(TAG, "markAllMessageAsRead error:" + code + ", desc:" + ErrorMessageConverter.convertIMError(code, desc));
                ToastUtil.toastShortMessage(MainMinimalistActivity.this.getString(R.string.mark_all_message_as_read_err_format, code, ErrorMessageConverter.convertIMError(code, desc)));
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
                mainViewPager.setCurrentItem(0, false);
                mConversationBtnText.setTextColor(getResources().getColor(R.color.demo_main_tab_text_selected_color_light));
                mConversationBtnIcon.setBackground(getResources().getDrawable(R.drawable.demo_overseas_main_tab_conversation_selected));
                break;
            case R.id.contact_btn_group:
                mainViewPager.setCurrentItem(1, false);
                mContactBtnText.setTextColor(getResources().getColor(R.color.demo_main_tab_text_selected_color_light));
                mContactBtnIcon.setBackground(getResources().getDrawable(R.drawable.demo_overseas_main_tab_contact_selected_bg));
                break;
            case R.id.myself_btn_group:
                mainViewPager.setCurrentItem(2, false);
                mProfileSelfBtnText.setTextColor(getResources().getColor(R.color.demo_main_tab_text_selected_color_light));
                mProfileSelfBtnIcon.setBackground(getResources().getDrawable(R.drawable.demo_overseas_main_tab_settings_selected_bg));
                break;
            default:
                break;
        }
    }

    private void resetMenuState() {
        mConversationBtnText.setTextColor(getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_light_bg_secondary_text_color_light));
        mConversationBtnIcon.setBackground(getResources().getDrawable(R.drawable.demo_overseas_main_tab_conversation_normal));
        mContactBtnText.setTextColor(getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_light_bg_secondary_text_color_light));
        mContactBtnIcon.setBackground(getResources().getDrawable(R.drawable.demo_overseas_main_tab_contact_normal_bg));
        mProfileSelfBtnText.setTextColor(getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_light_bg_secondary_text_color_light));
        mProfileSelfBtnIcon.setBackground(getResources().getDrawable(R.drawable.demo_overseas_main_tab_settings_normal_bg));
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
