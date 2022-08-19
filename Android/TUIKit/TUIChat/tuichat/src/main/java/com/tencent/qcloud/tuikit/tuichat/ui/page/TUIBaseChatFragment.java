package com.tencent.qcloud.tuikit.tuichat.ui.page;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.ui.view.ChatView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class TUIBaseChatFragment extends BaseFragment {
    private static final String TAG = TUIBaseChatFragment.class.getSimpleName();

    protected View baseView;
    protected TitleBarLayout titleBar;

    protected ChatView chatView;

    private List<TUIMessageBean> mForwardSelectMsgInfos = null;
    private int mForwardMode;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = inflater.inflate(R.layout.chat_fragment, container, false);
        Bundle bundle = getArguments();
        if (bundle == null) {
            return baseView;
        }

//        // TODO 通过api设置ChatLayout各种属性的样例
//        // Example of setting various properties of ChatLayout through api
//        ChatLayoutSetting helper = new ChatLayoutSetting(getActivity());
//        helper.setGroupId(mChatInfo.getId());
//        helper.customizeChatLayout(mChatLayout);
        return baseView;
    }

    protected void initView() {
        chatView = baseView.findViewById(R.id.chat_layout);
        chatView.initDefault();
        titleBar = chatView.getTitleBar();
        titleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(chatView.getWindowToken(), 0);
                getActivity().finish();
            }
        });

        chatView.setForwardSelectActivityListener(new ChatView.ForwardSelectActivityListener(){
            @Override
            public void onStartForwardSelectActivity(int mode, List<TUIMessageBean> msgIds) {
                mForwardMode = mode;
                mForwardSelectMsgInfos = msgIds;
                Bundle bundle = new Bundle();
                bundle.putInt(TUIChatConstants.FORWARD_MODE, mode);
                TUICore.startActivity(TUIBaseChatFragment.this, "TUIForwardSelectActivity", bundle, TUIChatConstants.FORWARD_SELECT_ACTIVTY_CODE);

            }
        });

        chatView.getMessageLayout().setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, TUIMessageBean message) {
                // 因为adapter中第一条为加载条目，位置需减1
                // Because the first entry in the adapter is the load entry, the position needs to be decremented by 1
                TUIChatLog.d(TAG, "chatfragment onTextSelected selectedText = ");
                chatView.getMessageLayout().showItemPopMenu(position - 1, message, view);
            }

            @Override
            public void onUserIconClick(View view, int position, TUIMessageBean message) {
                if (null == message) {
                    return;
                }

                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, message.getSender());
                TUICore.startActivity("FriendProfileActivity", bundle);

            }

            @Override
            public void onUserIconLongClick(View view, int position, TUIMessageBean message) {

            }

            @Override
            public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {
                if (messageInfo == null) {
                    return;
                }
                int messageType = messageInfo.getMsgType();
                if (messageType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT){
                    chatView.getInputLayout().appendText(messageInfo.getV2TIMMessage().getTextElem().getText());
                } else {
                    TUIChatLog.e(TAG, "error type: " + messageType);
                }
            }

            @Override
            public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {
                if (messageInfo == null) {
                    return;
                }
                CallingMessageBean callingMessageBean = (CallingMessageBean) messageInfo;
                String callTypeString = "";
                int callType = callingMessageBean.getCallType();
                if (callType == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
                    callTypeString = TUIConstants.TUICalling.TYPE_VIDEO;
                } else if (callType == CallingMessageBean.ACTION_ID_AUDIO_CALL) {
                    callTypeString = TUIConstants.TUICalling.TYPE_AUDIO;
                }
                Map<String, Object> map = new HashMap<>();
                map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[]{messageInfo.getUserId()});
                map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, callTypeString);
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
            }

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().setSelectedPosition(position);
                chatView.getMessageLayout().showItemPopMenu(position - 1, messageInfo, view);
            }
        });

        chatView.getInputLayout().setStartActivityListener(new InputView.OnStartActivityListener() {
            @Override
            public void onStartGroupMemberSelectActivity() {
                Bundle param = new Bundle();
                param.putString(TUIChatConstants.GROUP_ID, getChatInfo().getId());
                TUICore.startActivity(TUIBaseChatFragment.this, "StartGroupMemberSelectActivity", param, 1);

            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == 3) {
            ArrayList<String> result_ids = data.getStringArrayListExtra(TUIChatConstants.Selection.USER_ID_SELECT);
            ArrayList<String> result_names = data.getStringArrayListExtra(TUIChatConstants.Selection.USER_NAMECARD_SELECT);
            chatView.getInputLayout().updateInputText(result_names, result_ids);
        } else if (requestCode == TUIChatConstants.FORWARD_SELECT_ACTIVTY_CODE && resultCode == TUIChatConstants.FORWARD_SELECT_ACTIVTY_CODE) {
            if (data != null) {
                if (mForwardSelectMsgInfos == null || mForwardSelectMsgInfos.isEmpty()) {
                    return;
                }

                HashMap<String, Boolean> chatMap = (HashMap<String, Boolean>) data.getSerializableExtra(TUIChatConstants.FORWARD_SELECT_CONVERSATION_KEY);
                if (chatMap == null || chatMap.isEmpty()) {
                    return;
                }

                for (Map.Entry<String, Boolean> entry : chatMap.entrySet()) {
                    boolean isGroup = entry.getValue();
                    String id = entry.getKey();
                    String title = "";
                    ChatInfo chatInfo = getChatInfo();
                    if (chatInfo == null) {
                        return;
                    }
                    if (TUIChatUtils.isGroupChat(chatInfo.getType())) {
                        title = getString(R.string.forward_chats);
                    } else {
                        String senderName;
                        String userNickName = TUIConfig.getSelfNickName();
                        if (!TextUtils.isEmpty(userNickName)) {
                            senderName = userNickName;
                        } else {
                            senderName = TUILogin.getLoginUser();
                        }
                        String chatName;
                        if (!TextUtils.isEmpty(getChatInfo().getChatName())) {
                            chatName = getChatInfo().getChatName();
                        } else {
                            chatName = getChatInfo().getId();
                        }
                        title = senderName + getString(R.string.and_text) + chatName + getString(R.string.forward_chats_c2c);                    }

                    boolean selfConversation = false;
                    if (id != null && id.equals(chatInfo.getId())) {
                        selfConversation = true;
                    }

                    ChatPresenter chatPresenter = getPresenter();
                    chatPresenter.forwardMessage(mForwardSelectMsgInfos, isGroup, id, title, mForwardMode, selfConversation, new IUIKitCallback() {
                        @Override
                        public void onSuccess(Object data) {
                            TUIChatLog.v(TAG, "sendMessage onSuccess:");
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                        }
                    });
                }
            }
        }
    }

    public ChatInfo getChatInfo() {
        return null;
    }
    
    @Override
    public void onResume() {
        super.onResume();
        if (getPresenter() != null) {
            getPresenter().setChatFragmentShow(true);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (chatView != null) {
            if (chatView.getInputLayout() != null) {
                chatView.getInputLayout().setDraft();
            }

            if (getPresenter() != null) {
                getPresenter().setChatFragmentShow(false);
            }
        }
        AudioPlayer.getInstance().stopPlay();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (chatView != null) {
            chatView.exitChat();
        }
    }

    public ChatPresenter getPresenter() {
        return null;
    }
}
