package com.tencent.qcloud.tim.demo.chat;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.liteav.model.CallModel;
import com.tencent.liteav.model.TRTCAVCallImpl;
import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.SplashActivity;
import com.tencent.qcloud.tim.demo.thirdpush.OfflineMessageDispatcher;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.base.OfflineMessageBean;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import static com.tencent.imsdk.v2.V2TIMManager.V2TIM_STATUS_LOGINED;

public class ChatActivity extends BaseActivity {

    private static final String TAG = ChatActivity.class.getSimpleName();

    private ChatFragment mChatFragment;
    private ChatInfo mChatInfo;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        DemoLog.i(TAG, "onCreate");

        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_activity);

        chat(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        DemoLog.i(TAG, "onNewIntent");
        super.onNewIntent(intent);
        chat(intent);
    }

    @Override
    protected void onResume() {
        DemoLog.i(TAG, "onResume");
        super.onResume();
    }

    private void chat(Intent intent) {
        Bundle bundle = intent.getExtras();
        DemoLog.i(TAG, "bundle: " + bundle + " intent: " + intent);
        if (bundle == null) {
            startSplashActivity(null);
        }
        final OfflineMessageBean bean = OfflineMessageDispatcher.parseOfflineMessage(intent);
        if (bean != null) {
            NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if (manager != null) {
                manager.cancelAll();
            }
        }

        if (V2TIMManager.getInstance().getLoginStatus() != V2TIM_STATUS_LOGINED) {
            startSplashActivity(bundle);
            finish();
            return;
        }

        if (bean != null) {
            if (bean.action == OfflineMessageBean.REDIRECT_ACTION_CALL) {
                DemoLog.i(TAG, "offline push  AV CALL . bean: " + bean);
                startAVCall(bean);
                finish();
                return;
            } else if (bean.action == OfflineMessageBean.REDIRECT_ACTION_CHAT) {
                mChatInfo = new ChatInfo();
                mChatInfo.setType(bean.chatType);
                mChatInfo.setId(bean.sender);
                mChatInfo.setChatName(bean.nickname);
                bundle.putSerializable(Constants.CHAT_INFO, mChatInfo);
                DemoLog.i(TAG, "offline push mChatInfo: " + mChatInfo);
            }
        } else {
            mChatInfo = (ChatInfo) bundle.getSerializable(Constants.CHAT_INFO);
            DemoLog.i(TAG, "start chatActivity chatInfo: " + mChatInfo);
        }
        if (mChatInfo != null) {
            mChatFragment = new ChatFragment();
            mChatFragment.setArguments(bundle);
            getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, mChatFragment).commitAllowingStateLoss();
            mChatInfo = null;
        } else {
            finish();
        }
    }

    private void startSplashActivity(Bundle bundle) {
        Intent intent = new Intent(ChatActivity.this, SplashActivity.class);
        if (bundle != null) {
            intent.putExtras(bundle);
        }
        startActivity(intent);
        finish();
    }

    private void startAVCall(OfflineMessageBean bean) {
        final CallModel model = new Gson().fromJson(bean.content, CallModel.class);
        DemoLog.i(TAG, "bean: "+ bean + " model: " + model);
        if (model != null) {
            long timeout = V2TIMManager.getInstance().getServerTime() - bean.sendTime;
            if (timeout >= model.timeout) {
                ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.call_time_out));
            } else {
                String callId = model.callId;
                if (TextUtils.isEmpty(model.groupId)) {
                    callId = ((TRTCAVCallImpl) TRTCAVCallImpl.sharedInstance(DemoApplication.instance())).c2cCallId;
                }
                ((TRTCAVCallImpl) (TRTCAVCallImpl.sharedInstance(DemoApplication.instance()))).
                        processInvite(callId, bean.sender, model.groupId, model.invitedList, bean.content);
            }
        }

    }
}
