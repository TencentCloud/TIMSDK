package com.tencent.qcloud.tim.demo.main;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.TextView;

import com.heytap.msp.push.HeytapPushManager;
import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.common.ApiException;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.liteav.model.CallModel;
import com.tencent.liteav.model.TRTCAVCallImpl;
import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.contact.ContactFragment;
import com.tencent.qcloud.tim.demo.conversation.ConversationFragment;
import com.tencent.qcloud.tim.demo.profile.ProfileFragment;
import com.tencent.qcloud.tim.demo.scenes.ScenesFragment;
import com.tencent.qcloud.tim.demo.thirdpush.HUAWEIHmsMessageService;
import com.tencent.qcloud.tim.demo.thirdpush.OPPOPushImpl;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.vivo.push.IPushActionListener;
import com.vivo.push.PushClient;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

public class MainActivity extends BaseActivity implements ConversationManagerKit.MessageUnreadWatcher {

    private static final String TAG = MainActivity.class.getSimpleName();

    private TextView mConversationBtn;
    private TextView mContactBtn;
    private TextView mProfileSelfBtn;
    private TextView mScenesBtn;
    private TextView mMsgUnread;
    private View mLastTab;

    private CallModel mCallModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        prepareThirdPushToken();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        DemoLog.i(TAG, "onNewIntent");
        mCallModel = (CallModel) intent.getSerializableExtra(Constants.CHAT_INFO);
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
            HeytapPushManager.register(this, PrivateConstants.OPPO_PUSH_APPKEY, PrivateConstants.OPPO_PUSH_APPSECRET, oppo);
        } else if (BrandUtil.isGoogleServiceSupport()) {
            // 谷歌推送
        }
    }

    private void initView() {
        setContentView(R.layout.main_activity);
        mConversationBtn = findViewById(R.id.conversation);
        mContactBtn = findViewById(R.id.contact);
        mProfileSelfBtn = findViewById(R.id.mine);
        mScenesBtn = findViewById(R.id.scenes);
        mMsgUnread = findViewById(R.id.msg_total_unread);
        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, new ConversationFragment()).commitAllowingStateLoss();
        FileUtil.initPath(); // 从application移入到这里，原因在于首次装上app，需要获取一系列权限，如创建文件夹，图片下载需要指定创建好的文件目录，否则会下载本地失败，聊天页面从而获取不到图片、表情

        // 未读消息监视器
        ConversationManagerKit.getInstance().addUnreadWatcher(this);
        GroupChatManagerKit.getInstance();
        if (mLastTab == null) {
            mLastTab = findViewById(R.id.conversation_btn_group);
        } else {
            // 初始化时，强制切换tab到上一次的位置
            View tmp = mLastTab;
            mLastTab = null;
            tabClick(tmp);
            mLastTab = tmp;
        }
    }

    public void tabClick(View view) {
        DemoLog.i(TAG, "tabClick last: " + mLastTab + " current: " + view);
        if (mLastTab != null && mLastTab.getId() == view.getId()) {
            return;
        }
        mLastTab = view;
        resetMenuState();
        Fragment current = null;
        switch (view.getId()) {
            case R.id.conversation_btn_group:
                current = new ConversationFragment();
                mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_selected), null, null);
                break;
            case R.id.contact_btn_group:
                current = new ContactFragment();
                mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_selected), null, null);
                break;
            case R.id.scenes_btn_group:
                current = new ScenesFragment();
                mScenesBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mScenesBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.live_selected), null, null);
                break;
            case R.id.myself_btn_group:
                current = new ProfileFragment();
                mProfileSelfBtn.setTextColor(getResources().getColor(R.color.tab_text_selected_color));
                mProfileSelfBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.myself_selected), null, null);
                break;
            default:
                break;
        }

        if (current != null && !current.isAdded()) {
            getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, current).commitAllowingStateLoss();
            getSupportFragmentManager().executePendingTransactions();
        } else {
            DemoLog.w(TAG, "fragment added!");
        }
    }

    private void resetMenuState() {
        mConversationBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mConversationBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.conversation_normal), null, null);
        mContactBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mContactBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.contact_normal), null, null);
        mProfileSelfBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mProfileSelfBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.myself_normal), null, null);
        mScenesBtn.setTextColor(getResources().getColor(R.color.tab_text_normal_color));
        mScenesBtn.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.drawable.live_normal), null, null);
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
        // 华为离线推送角标
        HUAWEIHmsMessageService.updateBadge(this, count);
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
    protected void onStart() {
        DemoLog.i(TAG, "onStart");
        super.onStart();
        initView();
    }

    @Override
    protected void onResume() {
        DemoLog.i(TAG, "onResume");
        super.onResume();
        if (mCallModel != null) {
            TRTCAVCallImpl impl = (TRTCAVCallImpl) TRTCAVCallImpl.sharedInstance(DemoApplication.instance());
            impl.stopCall();
            final V2TIMSignalingInfo info = new V2TIMSignalingInfo();
            info.setInviteID(mCallModel.callId);
            info.setInviteeList(mCallModel.invitedList);
            info.setGroupID(mCallModel.groupId);
            info.setInviter(mCallModel.sender);
            info.setData(mCallModel.data);
            ((TRTCAVCallImpl)(TRTCAVCallImpl.sharedInstance(DemoApplication.instance()))).processInvite(
                    info.getInviteID(), info.getInviter(), info.getGroupID(), info.getInviteeList(), info.getData());
            mCallModel = null;
        }
    }

    @Override
    protected void onPause() {
        DemoLog.i(TAG, "onPause");
        super.onPause();
    }

    @Override
    protected void onStop() {
        DemoLog.i(TAG, "onStop");
        ConversationManagerKit.getInstance().destroyConversation();
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        DemoLog.i(TAG, "onDestroy");
        mLastTab = null;
        super.onDestroy();
    }

}
