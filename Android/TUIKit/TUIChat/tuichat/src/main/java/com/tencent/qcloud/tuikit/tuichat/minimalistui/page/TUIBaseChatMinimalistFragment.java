package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Supplier;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.audio.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.DataStoreUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class TUIBaseChatMinimalistFragment extends BaseFragment {
    private static final String TAG = TUIBaseChatMinimalistFragment.class.getSimpleName();

    protected View baseView;

    protected ChatView chatView;
    protected ChatInfo chatInfo;
    private MessageRecyclerView messageRecyclerView;
    private int messageViewBackgroundHeight;
    protected String mChatBackgroundUrl;
    protected String mChatBackgroundThumbnailUrl;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "onCreateView " + this);

        baseView = inflater.inflate(R.layout.chat_minimalist_fragment, container, false);
        
        //        // Example of setting various properties of ChatLayout through api
        //        ChatLayoutSetting helper = new ChatLayoutSetting(getActivity());
        //        helper.setGroupId(mChatInfo.getId());
        //        helper.customizeChatLayout(mChatLayout);
        return baseView;
    }

    protected void initView() {
        chatView = baseView.findViewById(R.id.chat_layout);
        chatView.initDefault(TUIBaseChatMinimalistFragment.this);
        messageRecyclerView = chatView.getMessageLayout();

        chatView.setOnBackClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(chatView.getWindowToken(), 0);
                getActivity().finish();
            }
        });

        chatView.setForwardSelectActivityListener(new ChatView.ForwardSelectActivityListener() {
            @Override
            public void forwardMessages(int forwardMode, List<TUIMessageBean> messageBeans) {
                if (messageBeans == null || messageBeans.isEmpty()) {
                    return;
                }
                selectConversationsToForwardMessages(() -> messageBeans, forwardMode);
            }

            @Override
            public void forwardText(String text) {
                if (TextUtils.isEmpty(text)) {
                    return;
                }
                selectConversationsToForwardMessages(
                    () -> Collections.singletonList(ChatMessageBuilder.buildTextMessage(text)), TUIChatConstants.FORWARD_MODE_NEW_MESSAGE);
            }
        });

        chatView.getMessageLayout().setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, TUIMessageBean message) {
                onMessageLongClicked(view, message);
            }

            @Override
            public void onMessageClick(View view, TUIMessageBean messageBean) {
                onMessageClicked(view, messageBean);
            }

            @Override
            public void onUserIconClick(View view, TUIMessageBean message) {
                onUserIconClicked(message);
            }

            @Override
            public void onUserIconLongClick(View view, TUIMessageBean messageBean) {
                onUserIconLongClicked(messageBean);
            }

            @Override
            public void onReEditRevokeMessage(View view, TUIMessageBean messageInfo) {
                onReEditMessageClicked(messageInfo);
            }

            @Override
            public void onRecallClick(View view, TUIMessageBean messageInfo) {
                onRecallClicked(messageInfo);
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                onMessageReadStatusClicked(messageBean);
            }
        });

        chatView.getInputLayout().setOnInputViewListener(new InputView.OnInputViewListener() {
            @Override
            public void onStartGroupMemberSelectActivity() {
                Bundle param = new Bundle();
                param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, getChatInfo().getId());
                TUICore.startActivityForResult(TUIBaseChatMinimalistFragment.this, "StartGroupMemberSelectMinimalistActivity", param, result -> {
                    if (result.getData() != null) {
                        ArrayList<String> resultIds = result.getData().getStringArrayListExtra(TUIChatConstants.Selection.USER_ID_SELECT);
                        ArrayList<String> resultNames = result.getData().getStringArrayListExtra(TUIChatConstants.Selection.USER_NAMECARD_SELECT);
                        chatView.getInputLayout().updateInputText(resultNames, resultIds);
                    }
                });
            }

            @Override
            public void onClickCapture() {
                startCapture();
            }

            @Override
            public void onUpdateChatBackground() {
                setChatViewBackground(mChatBackgroundUrl);
            }
        });

        messageRecyclerView.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {

            @Override
            public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                if (messageViewBackgroundHeight == 0) {
                    messageViewBackgroundHeight = messageRecyclerView.getHeight();
                }
                if (messageViewBackgroundHeight < messageRecyclerView.getHeight()) {
                    messageViewBackgroundHeight = messageRecyclerView.getHeight();
                    setChatViewBackground(mChatBackgroundUrl);
                }
            }
        });
    }

    private void onMessageReadStatusClicked(TUIMessageBean messageBean) {
        if (getChatInfo() != null) {
            Intent intent = new Intent(getContext(), MessageDetailMinimalistActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageBean);
            intent.putExtra(TUIChatConstants.CHAT_INFO, getChatInfo());
            startActivity(intent);
        }
    }

    protected void onRecallClicked(TUIMessageBean messageInfo) {
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
        map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[] {messageInfo.getUserId()});
        map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, callTypeString);
        TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
    }

    protected void onReEditMessageClicked(TUIMessageBean messageInfo) {
        if (messageInfo == null) {
            return;
        }
        int messageType = messageInfo.getMsgType();
        if (messageType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
            chatView.getInputLayout().appendText(messageInfo.getV2TIMMessage().getTextElem().getText());
        } else {
            TUIChatLog.e(TAG, "error type: " + messageType);
        }
    }

    protected void onUserIconLongClicked(TUIMessageBean messageBean) {

    }

    protected void onUserIconClicked(TUIMessageBean message) {
        if (null == message) {
            return;
        }
        String userID = message.getSender();
        if (TextUtils.isEmpty(userID)) {
            return;
        }

        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, userID);
        TUICore.startActivity("FriendProfileMinimalistActivity", bundle);
    }

    protected void onMessageClicked(View view, TUIMessageBean messageBean) {
        if (messageBean instanceof MergeMessageBean) {
            if (getChatInfo() == null) {
                return;
            }
            Intent intent = new Intent(view.getContext(), TUIForwardChatMinimalistActivity.class);
            intent.putExtra(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, messageBean);
            intent.putExtra(TUIChatConstants.CHAT_INFO, getChatInfo());
            startActivity(intent);
        }
    }

    protected void onMessageLongClicked(View view, TUIMessageBean message) {
        chatView.getMessageLayout().showItemPopMenu(message, view);
    }

    protected void selectConversationsToForwardMessages(Supplier<List<TUIMessageBean>> messageBeans, int forwardMode) {
        TUICore.startActivityForResult(TUIBaseChatMinimalistFragment.this, "TUIForwardSelectMinimalistActivity", null, result -> {
            Intent data = result.getData();
            if (data != null) {
                HashMap<String, Boolean> chatMap = (HashMap<String, Boolean>) data.getSerializableExtra(TUIChatConstants.FORWARD_SELECT_CONVERSATION_KEY);
                if (chatMap == null || chatMap.isEmpty()) {
                    return;
                }

                for (Map.Entry<String, Boolean> entry : chatMap.entrySet()) {
                    String id = entry.getKey();
                    String title = "";
                    ChatInfo chatInfo = getChatInfo();
                    if (chatInfo == null) {
                        return;
                    }
                    title = getOfflinePushTitle(chatInfo);

                    boolean selfConversation = false;
                    if (id != null && id.equals(chatInfo.getId())) {
                        selfConversation = true;
                    }
                    boolean isGroup = entry.getValue();
                    ChatPresenter chatPresenter = getPresenter();
                    chatPresenter.forwardMessage(messageBeans.get(), isGroup, id, title, forwardMode, selfConversation, new IUIKitCallback() {
                        @Override
                        public void onSuccess(Object data) {
                            TUIChatLog.v(TAG, "forwardMessage onSuccess:");
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            TUIChatLog.v(TAG, "sendMessage fail:" + errCode + "=" + errMsg);
                            ToastUtil.toastLongMessage(getString(R.string.send_failed) + ", " + errMsg);
                        }
                    });
                }
            }
        });
    }

    @NonNull
    private String getOfflinePushTitle(ChatInfo chatInfo) {
        String title;
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
            title = senderName + getString(R.string.and_text) + chatName + getString(R.string.forward_chats_c2c);
        }
        return title;
    }

    protected void initChatViewBackground() {
        if (getChatInfo() == null) {
            TUIChatLog.e(TAG, "initChatViewBackground getChatInfo is null");
            return;
        }
        DataStoreUtil.getInstance().getValueAsync(getChatInfo().getId(), new DataStoreUtil.GetResult<String>() {
            @Override
            public void onSuccess(String result) {
                setChatViewBackground(result);
            }

            @Override
            public void onFail() {
                TUIChatLog.e(TAG, "initChatViewBackground onFail");
            }
        }, String.class);
    }

    protected void setChatViewBackground(String uri) {
        TUIChatLog.d(TAG, "setChatViewBackground uri = " + uri);
        if (TextUtils.isEmpty(uri)) {
            return;
        }

        if (chatView == null) {
            TUIChatLog.e(TAG, "setChatViewBackground chatview is null");
            return;
        }

        if (messageRecyclerView == null) {
            TUIChatLog.e(TAG, "setChatViewBackground messageRecyclerView is null");
            return;
        }

        String[] list = uri.split(",");
        if (list.length > 0) {
            mChatBackgroundThumbnailUrl = list[0];
        }

        if (list.length > 1) {
            mChatBackgroundUrl = list[1];
        }

        if (TextUtils.equals(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundUrl)) {
            mChatBackgroundThumbnailUrl = TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL;
            messageRecyclerView.setBackgroundResource(R.color.chat_background_color);
            return;
        }

        messageRecyclerView.post(new Runnable() {
            @Override
            public void run() {
                int imageWidth = messageRecyclerView.getWidth();
                int imageHeight = messageRecyclerView.getHeight();
                if (imageHeight > messageViewBackgroundHeight) {
                    messageViewBackgroundHeight = imageHeight;
                }
                TUIChatLog.d(TAG, "messageRecyclerView  width = " + imageWidth + ", height = " + messageViewBackgroundHeight);
                if (imageWidth == 0 || messageViewBackgroundHeight == 0) {
                    return;
                }
                Glide.with(getContext()).asBitmap().load(mChatBackgroundUrl).into(new CustomTarget<Bitmap>(imageWidth, messageViewBackgroundHeight) {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        TUIChatLog.d(TAG, "messageRecyclerView onGlobalLayout url = " + mChatBackgroundUrl);
                        Bitmap srcBitmap = ImageUtil.zoomImg(resource, imageWidth, messageViewBackgroundHeight);
                        messageRecyclerView.setBackground(new BitmapDrawable(getResources(), resource) {
                            @Override
                            public void draw(@NonNull Canvas canvas) {
                                // TUIChatLog.d(TAG, "draw canvas =" + canvas.getClipBounds());
                                canvas.drawBitmap(srcBitmap, canvas.getClipBounds(), canvas.getClipBounds(), null);
                            }
                        });
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {}
                });
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        if (getPresenter() != null) {
            getPresenter().setChatFragmentShow(true);
        }
        initChatViewBackground();
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

    protected void startCapture() {
        chatView.getInputLayout().startCaptureCheckPermission();
    }

    public ChatPresenter getPresenter() {
        return null;
    }

    public abstract ChatInfo getChatInfo();

    public ChatView getChatView() {
        return chatView;
    }

}
