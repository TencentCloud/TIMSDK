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

import com.tencent.imsdk.TIMManager;
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


public class MainActivity extends Activity implements ConversationManagerKit.MessageUnreadWatcher {

    private static final String TAG = MainActivity.class.getSimpleName();

    private ConversationFragment mConversationFragment;
    private ContactFragment mContactFragment;
    private ProfileFragment mProfileFragment;
    private TextView mConversationBtn;
    private TextView mContactBtn;
    private TextView mProfileSelfBtn;
    private TextView mMsgUnread;
    private TextView mLastButton;
    private int mCurrentTab;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomConfig();
        if (!TextUtils.isEmpty(TIMManager.getInstance().getLoginUser())) {
            handleLogin(true); // 如果账户不为空，就默认下次自动登录
        }
        initView();
    }

    private void initView() {
        setContentView(R.layout.main_activity);
        mConversationBtn = findViewById(R.id.conversation);
        mContactBtn = findViewById(R.id.contact);
        mProfileSelfBtn = findViewById(R.id.mine);
        mMsgUnread = findViewById(R.id.msg_total_unread);
        mConversationFragment = new ConversationFragment();
        getFragmentManager().beginTransaction().replace(R.id.empty_view, mConversationFragment).commitAllowingStateLoss();
        FileUtil.initPath(); // 从application移入到这里，原因在于首次装上app，需要获取一系列权限，如创建文件夹，图片下载需要指定创建好的文件目录，否则会下载本地失败，聊天页面从而获取不到图片、表情

        // 未读消息监视器
        ConversationManagerKit.getInstance().addUnreadWatcher(this);
        GroupChatManagerKit.getInstance();
        mLastButton = mConversationBtn;

        // 登录后，设置pushtoken
        ThirdPushTokenMgr.getInstance().setIsLogin(true);
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
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
                if (mConversationFragment == null) {
                    mConversationFragment = new ConversationFragment();
                }
                current = mConversationFragment;
                mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_selected), null, null);
                mLastButton = mConversationBtn;
                break;
            case R.id.contact_btn_group:
                if (mContactFragment == null) {
                    mContactFragment = new ContactFragment();
                }
                current = mContactFragment;
                mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_selected), null, null);
                mLastButton = mContactBtn;
                break;
            case R.id.myself_btn_group:
                if (mProfileFragment == null) {
                    mProfileFragment = new ProfileFragment();
                }
                current = mProfileFragment;
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
    protected void onDestroy() {
        super.onDestroy();
    }

    public void login(boolean autoLogin) {
        handleLogin(autoLogin);
        Intent intent = new Intent(this, LoginForDevActivity.class);
        intent.putExtra(Constants.LOGOUT, true);
        startActivity(intent);
    }

    private void handleLogin(boolean autoLogin) {
        SharedPreferences shareInfo = getSharedPreferences(Constants.USERINFO, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = shareInfo.edit();
        editor.putBoolean(Constants.AUTO_LOGIN, autoLogin);
        editor.commit();
    }


    private void setCustomConfig() {
        //注册IM事件回调，这里示例为用户被踢的回调，更多事件注册参考文档
        TUIKit.setIMEventListener(new IMEventListener() {
            @Override
            public void onForceOffline() {
                ToastUtil.toastLongMessage("您的帐号已在其它终端登录");
                login(false);
                finish();
            }

            @Override
            public void onDisconnected(int code, String desc) {
            }
        });
    }
}
