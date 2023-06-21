package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.List;

public abstract class TUIBaseChatMinimalistActivity extends BaseMinimalistLightActivity {
    private static final String TAG = TUIBaseChatMinimalistActivity.class.getSimpleName();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "onCreate " + this);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_activity);
        chat(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        TUIChatLog.i(TAG, "onNewIntent");
        super.onNewIntent(intent);
        chat(intent);
    }

    @Override
    protected void onResume() {
        TUIChatLog.i(TAG, "onResume");
        super.onResume();
    }

    private void chat(Intent intent) {
        Bundle bundle = intent.getExtras();
        TUIChatLog.i(TAG, "bundle: " + bundle + " intent: " + intent);
        if (!TUILogin.isUserLogined()) {
            ToastUtil.toastShortMessage(getString(R.string.chat_tips_not_login));
            finish();
            return;
        }

        ChatInfo chatInfo = getChatInfo(intent);
        TUIChatLog.i(TAG, "start chatActivity chatInfo: " + chatInfo);

        if (chatInfo != null) {
            initChat(chatInfo);
        } else {
            ToastUtil.toastShortMessage("init chat failed , chatInfo is empty.");
            TUIChatLog.e(TAG, "init chat failed , chatInfo is empty.");
            finish();
        }
    }

    public abstract void initChat(ChatInfo chatInfo);

    private ChatInfo getChatInfo(Intent intent) {
        int chatType = intent.getIntExtra(TUIConstants.TUIChat.CHAT_TYPE, ChatInfo.TYPE_INVALID);
        ChatInfo chatInfo;
        if (chatType == ChatInfo.TYPE_C2C) {
            chatInfo = new ChatInfo();
        } else if (chatType == ChatInfo.TYPE_GROUP) {
            chatInfo = new GroupInfo();
        } else {
            return null;
        }
        chatInfo.setType(chatType);
        chatInfo.setId(intent.getStringExtra(TUIConstants.TUIChat.CHAT_ID));
        chatInfo.setChatName(intent.getStringExtra(TUIConstants.TUIChat.CHAT_NAME));
        DraftInfo draftInfo = new DraftInfo();
        draftInfo.setDraftText(intent.getStringExtra(TUIConstants.TUIChat.DRAFT_TEXT));
        draftInfo.setDraftTime(intent.getLongExtra(TUIConstants.TUIChat.DRAFT_TIME, 0));
        chatInfo.setDraft(draftInfo);
        chatInfo.setTopChat(intent.getBooleanExtra(TUIConstants.TUIChat.IS_TOP_CHAT, false));
        V2TIMMessage v2TIMMessage = (V2TIMMessage) intent.getSerializableExtra(TUIConstants.TUIChat.LOCATE_MESSAGE);
        TUIMessageBean messageInfo = ChatMessageBuilder.buildMessage(v2TIMMessage);
        chatInfo.setLocateMessage(messageInfo);
        chatInfo.setAtInfoList((List<V2TIMGroupAtInfo>) intent.getSerializableExtra(TUIConstants.TUIChat.AT_INFO_LIST));
        chatInfo.setFaceUrl(intent.getStringExtra(TUIConstants.TUIChat.FACE_URL));

        if (chatType == ChatInfo.TYPE_GROUP) {
            GroupInfo groupInfo = (GroupInfo) chatInfo;
            groupInfo.setGroupName(intent.getStringExtra(TUIConstants.TUIChat.GROUP_NAME));
            groupInfo.setGroupType(intent.getStringExtra(TUIConstants.TUIChat.GROUP_TYPE));
            groupInfo.setJoinType(intent.getIntExtra(TUIConstants.TUIChat.JOIN_TYPE, 0));
            groupInfo.setMemberCount(intent.getIntExtra(TUIConstants.TUIChat.MEMBER_COUNT, 0));
            groupInfo.setMessageReceiveOption(intent.getBooleanExtra(TUIConstants.TUIChat.RECEIVE_OPTION, false));
            groupInfo.setNotice(intent.getStringExtra(TUIConstants.TUIChat.NOTICE));
            groupInfo.setOwner(intent.getStringExtra(TUIConstants.TUIChat.OWNER));
            groupInfo.setMemberDetails((List<GroupMemberInfo>) intent.getSerializableExtra(TUIConstants.TUIChat.MEMBER_DETAILS));
            groupInfo.setIconUrlList((List<Object>) intent.getSerializableExtra(TUIConstants.TUIChat.FACE_URL_LIST));
        }

        if (TextUtils.isEmpty(chatInfo.getId())) {
            return null;
        }
        return chatInfo;
    }
}
