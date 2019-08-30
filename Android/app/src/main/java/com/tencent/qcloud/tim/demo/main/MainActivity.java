package com.tencent.qcloud.tim.demo.main;

import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.TextView;

import com.huawei.android.hms.agent.HMSAgent;
import com.huawei.android.hms.agent.common.handler.ConnectHandler;
import com.huawei.android.hms.agent.push.handler.GetTokenHandler;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.utils.IMFunc;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.contact.ContactFragment;
import com.tencent.qcloud.tim.demo.conversation.ConversationFragment;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.profile.ProfileFragment;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IMEventListener;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;
import com.vivo.push.IPushActionListener;
import com.vivo.push.PushClient;


public class MainActivity extends Activity implements ConversationManagerKit.MessageUnreadWatcher {

    private static final String TAG = MainActivity.class.getSimpleName();

    private TextView mConversationBtn;
    private TextView mContactBtn;
    private TextView mProfileSelfBtn;
    private TextView mMsgUnread;
    private TextView mLastButton;
    private int mCurrentTab;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        setCustomConfig();
        if (!TextUtils.isEmpty(TIMManager.getInstance().getLoginUser())) {
            autoLogin(true); // 如果账户不为空，就默认下次自动登录
        }
        initView();

        prepareThirdPushToken();
    }

    private void prepareThirdPushToken() {
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();

        if ( ThirdPushTokenMgr.USER_GOOGLE_FCM ) {
            return;
        }
        if (IMFunc.isBrandHuawei()) {
            // 华为离线推送
            HMSAgent.connect(this, new ConnectHandler() {
                @Override
                public void onConnect(int rst) {
                    DemoLog.i(TAG, "huawei push HMS connect end:" + rst);
                }
            });
            getHuaWeiPushToken();
        }
        if (IMFunc.isBrandVivo()) {
            // vivo离线推送
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
        }
    }

    private void initView() {
        setContentView(R.layout.main_activity);
        mConversationBtn = findViewById(R.id.conversation);
        mContactBtn = findViewById(R.id.contact);
        mProfileSelfBtn = findViewById(R.id.mine);
        mMsgUnread = findViewById(R.id.msg_total_unread);
        getFragmentManager().beginTransaction().replace(R.id.empty_view, new ConversationFragment()).commitAllowingStateLoss();
        FileUtil.initPath(); // 从application移入到这里，原因在于首次装上app，需要获取一系列权限，如创建文件夹，图片下载需要指定创建好的文件目录，否则会下载本地失败，聊天页面从而获取不到图片、表情

        // 未读消息监视器
        ConversationManagerKit.getInstance().addUnreadWatcher(this);
        GroupChatManagerKit.getInstance();
        mLastButton = mConversationBtn;

    }

    public void tabClick(View view) {
        if (mCurrentTab == view.getId()) {
            return;
        }
        mCurrentTab = view.getId();
        Fragment current = null;
        changeMenuState();
        switch (view.getId()) {
            case R.id.conversation_btn_group:
                if (mLastButton == mConversationBtn) {
                    return;
                }
                current = new ConversationFragment();;
                mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_selected), null, null);
                mLastButton = mConversationBtn;
                break;
            case R.id.contact_btn_group:
                if (mLastButton == mContactBtn) {
                    return;
                }
                current = new ContactFragment();
                mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_selected), null, null);
                mLastButton = mContactBtn;
                break;
            case R.id.myself_btn_group:
                if (mLastButton == mProfileSelfBtn) {
                    return;
                }
                current = new ProfileFragment();
                mProfileSelfBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mProfileSelfBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.myself_selected), null, null);
                mLastButton = mProfileSelfBtn;
                break;
        }

        if (current != null && !current.isAdded()) {
            getFragmentManager().beginTransaction().replace(R.id.empty_view, current).commitAllowingStateLoss();
            getFragmentManager().executePendingTransactions();
        } else {
            DemoLog.w(TAG, "fragment added!");
        }
    }

    private void changeMenuState() {
        if (mLastButton == null) {
            return;
        }
        switch (mLastButton.getId()) {
            case R.id.conversation:
                mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
                mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_normal), null, null);
                break;
            case R.id.contact:
                mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
                mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_normal), null, null);
                break;
            case R.id.mine:
                mProfileSelfBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
                mProfileSelfBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.myself_normal), null, null);
                break;
        }
    }


    @Override
    public void updateUnread(int count) {
        if (count > 0) {
            mMsgUnread.setVisibility(View.VISIBLE);
        } else {
            mMsgUnread.setVisibility(View.GONE);
        }
        String unreadStr = "" + count;
        if (count > 100) {
            unreadStr = "99+";
        }
        mMsgUnread.setText(unreadStr);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            finish();
        }
        return true;

    }

    @Override
    public void finish() {
        super.finish();
    }

    @Override
    protected void onResume() {
        DemoLog.i(TAG, "onResume");
        super.onResume();
    }

    @Override
    protected void onPause() {
        DemoLog.i(TAG, "onPause");
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        DemoLog.i(TAG, "onDestroy");
        super.onDestroy();
        clean();
    }

    public void logout(boolean autoLogin) {
        DemoLog.i(TAG, "logout");
        autoLogin(autoLogin);
        clean();
        Intent intent = new Intent(this, LoginForDevActivity.class);
        intent.putExtra(Constants.LOGOUT, true);
        startActivity(intent);
    }

    private void autoLogin(boolean autoLogin) {
        SharedPreferences shareInfo = getSharedPreferences(Constants.USERINFO, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = shareInfo.edit();
        editor.putBoolean(Constants.AUTO_LOGIN, autoLogin);
        editor.commit();
    }

    private void clean() {
        ConversationManagerKit.getInstance().destroyConversation();
        TUIKit.setIMEventListener(null);
    }

    private void setCustomConfig() {
        //注册IM事件回调，这里示例为用户被踢的回调，更多事件注册参考文档
        TUIKit.setIMEventListener(new IMEventListener() {
            @Override
            public void onForceOffline() {
                ToastUtil.toastLongMessage("您的帐号已在其它终端登录");
                logout(false);
                finish();
            }

            @Override
            public void onDisconnected(int code, String desc) {
            }
        });
    }

    private void getHuaWeiPushToken() {
        HMSAgent.Push.getToken(new GetTokenHandler() {
            @Override
            public void onResult(int rtnCode) {
                DemoLog.i(TAG, "huawei push get token result code: " + rtnCode);
            }
        });
    }
}
