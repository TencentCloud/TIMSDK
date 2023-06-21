package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
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

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.tencent.imsdk.v2.V2TIMManager;
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
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.DataStoreUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIBaseChatMinimalistFragment extends BaseFragment {
    private static final String TAG = TUIBaseChatMinimalistFragment.class.getSimpleName();

    protected View baseView;

    protected ChatView chatView;

    private List<TUIMessageBean> mForwardSelectMsgInfos = null;
    private int mForwardMode;

    private MessageRecyclerView messageRecyclerView;
    private int messageViewBackgroundHeight;
    protected String mChatBackgroundUrl;
    protected String mChatBackgroundThumbnailUrl;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = inflater.inflate(R.layout.chat_minimalist_fragment, container, false);
        //        // TODO 通过api设置ChatLayout各种属性的样例
        //        // Example of setting various properties of ChatLayout through api
        //        ChatLayoutSetting helper = new ChatLayoutSetting(getActivity());
        //        helper.setGroupId(mChatInfo.getId());
        //        helper.customizeChatLayout(mChatLayout);
        return baseView;
    }

    protected void initView() {
        chatView = baseView.findViewById(R.id.chat_layout);
        chatView.initDefault(TUIBaseChatMinimalistFragment.this);

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
            public void onStartForwardSelectActivity(int mode, List<TUIMessageBean> msgIds) {
                mForwardMode = mode;
                mForwardSelectMsgInfos = msgIds;
                Bundle bundle = new Bundle();
                bundle.putInt(TUIChatConstants.FORWARD_MODE, mode);
                TUICore.startActivityForResult(TUIBaseChatMinimalistFragment.this, "TUIForwardSelectMinimalistActivity", bundle, result -> {
                    Intent data = result.getData();
                    if (data != null) {
                        if (mForwardSelectMsgInfos == null || mForwardSelectMsgInfos.isEmpty()) {
                            return;
                        }

                        HashMap<String, Boolean> chatMap =
                            (HashMap<String, Boolean>) data.getSerializableExtra(TUIChatConstants.FORWARD_SELECT_CONVERSATION_KEY);
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

                            boolean selfConversation = false;
                            if (id != null && id.equals(chatInfo.getId())) {
                                selfConversation = true;
                            }
                            boolean isGroup = entry.getValue();
                            ChatPresenter chatPresenter = getPresenter();
                            chatPresenter.forwardMessage(mForwardSelectMsgInfos, isGroup, id, title, mForwardMode, selfConversation, new IUIKitCallback() {
                                @Override
                                public void onSuccess(Object data) {
                                    TUIChatLog.v(TAG, "sendMessage onSuccess:");
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
        });

        chatView.getMessageLayout().setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, TUIMessageBean message) {
                chatView.getMessageLayout().showItemPopMenu(message, view);
            }

            @Override
            public void onMessageClick(View view, int position, TUIMessageBean messageBean) {
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

            @Override
            public void onUserIconClick(View view, int position, TUIMessageBean message) {
                if (null == message) {
                    return;
                }
                String userID = null;
                if (message.getV2TIMMessage().getGroupID() != null) {
                    userID = message.getSender();
                } else {
                    if (message.isUseMsgReceiverAvatar()) {
                        if (message.getV2TIMMessage().isSelf()) {
                            userID = message.getV2TIMMessage().getUserID();
                        } else {
                            userID = V2TIMManager.getInstance().getLoginUser();
                        }
                    } else {
                        userID = message.getSender();
                    }
                }
                if (null == userID) {
                    return;
                }

                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, userID);
                TUICore.startActivity("FriendProfileMinimalistActivity", bundle);
            }

            @Override
            public void onUserIconLongClick(View view, int position, TUIMessageBean message) {}

            @Override
            public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {
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
                map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[] {messageInfo.getUserId()});
                map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, callTypeString);
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
            }

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().setSelectedPosition(position);
                chatView.getMessageLayout().showItemPopMenu(messageInfo, view);
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                if (getChatInfo() != null) {
                    Intent intent = new Intent(getContext(), MessageDetailMinimalistActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageBean);
                    intent.putExtra(TUIChatConstants.CHAT_INFO, getChatInfo());
                    startActivity(intent);
                }
            }
        });

        chatView.getInputLayout().setOnInputViewListener(new InputView.OnInputViewListener() {
            @Override
            public void onStartGroupMemberSelectActivity() {
                Bundle param = new Bundle();
                param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, getChatInfo().getId());
                TUICore.startActivityForResult(TUIBaseChatMinimalistFragment.this, "StartGroupMemberSelectActivity", param, result -> {
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

        messageRecyclerView = chatView.getMessageLayout();
    }

    public ChatInfo getChatInfo() {
        return null;
    }

    public ChatView getChatView() {
        return chatView;
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

    public ChatPresenter getPresenter() {
        return null;
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
                        Bitmap srcBitmap = zoomImg(resource, imageWidth, messageViewBackgroundHeight);
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

    private Bitmap zoomImg(Bitmap bm, int targetWidth, int targetHeight) {
        int srcWidth = bm.getWidth();
        int srcHeight = bm.getHeight();
        float widthScale = targetWidth * 1.0f / srcWidth;
        float heightScale = targetHeight * 1.0f / srcHeight;
        Matrix matrix = new Matrix();
        matrix.postScale(widthScale, heightScale, 0, 0);
        Bitmap bmpRet = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(bmpRet);
        Paint paint = new Paint();
        canvas.drawBitmap(bm, matrix, paint);
        return bmpRet;
    }

    protected void startCapture() {
        chatView.getInputLayout().startCaptureCheckPermission();
    }
}
