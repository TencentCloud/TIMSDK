package com.tencent.qcloud.uipojo.chat;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uipojo.R;
import com.tencent.qcloud.uipojo.utils.Constants;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class ChatActivity extends Activity {

    BaseFragment mCurrentFragment = null;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        Bundle bundle = getIntent().getExtras();
        boolean isGroup = bundle.getBoolean(Constants.IS_GROUP);
        if (isGroup) {
            mCurrentFragment = new GroupChatFragment();
        } else {
            mCurrentFragment = new PersonalChatFragment();
        }
        if (mCurrentFragment != null) {
            mCurrentFragment.setArguments(bundle);
            getFragmentManager().beginTransaction().replace(R.id.empty_view, mCurrentFragment).commitAllowingStateLoss();
        }


    }

    /**
     * 跳转到C2C聊天
     *
     * @param context  跳转容器的Context
     * @param chatInfo 会话ID(对方identify)
     */
    public static void startC2CChat(Context context, String chatInfo) {
        Intent intent = new Intent(context, ChatActivity.class);
        intent.putExtra(Constants.IS_GROUP, false);
        intent.putExtra(Constants.INTENT_DATA, chatInfo);
        context.startActivity(intent);
    }

    /**
     * 跳转到群聊
     *
     * @param context  跳转容器的Context
     * @param chatInfo 会话ID（群ID）
     */
    public static void startGroupChat(Context context, String chatInfo) {
        Intent intent = new Intent(context, ChatActivity.class);
        intent.putExtra(Constants.IS_GROUP, true);
        intent.putExtra(Constants.INTENT_DATA, chatInfo);
        context.startActivity(intent);
    }


    @Override
    public void finish() {
        if (mCurrentFragment instanceof GroupChatFragment) {
            //退出Activity时释放群聊相关资源
            GroupChatManager.getInstance().destroyGroupChat();
        } else if (mCurrentFragment instanceof PersonalChatFragment) {
            //退出Activity时释放单聊相关资源
            C2CChatManager.getInstance().destroyC2CChat();
        }
        super.finish();
    }

}
