package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.gatherimage.SynthesizedImageView;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageTyping;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.UserStatusBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.component.AudioRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.face.Emoji;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.dialog.ChatBottomSelectSheet;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout.NoticeLayout;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.MessageDetailMinimalistActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.setting.ChatLayoutSetting;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class ChatView extends LinearLayout  implements IChatLayout {
    private static final String TAG = ChatView.class.getSimpleName();
    // 逐条转发消息数量限制
    // Limit the number of messages forwarded one by one
    private static final int FORWARD_MSG_NUM_LIMIT = 30;
    protected static final int CALL_MEMBER_LIMIT = 8;

    protected MessageAdapter mAdapter;
    private ForwardSelectActivityListener mForwardSelectActivityListener;

    private ChatInfo mChatInfo;

    protected FrameLayout mCustomView;
    protected NoticeLayout mGroupApplyLayout;
    protected View mRecordingGroup;
    protected TextView mRecordingTips;
    private MessageRecyclerView mMessageRecyclerView;
    private InputView mInputView;
    private NoticeLayout mNoticeLayout;
    private LinearLayout mJumpMessageLayout;
    private ImageView mArrowImageView;
    private TextView mJumpMessageTextView;
    private boolean mJumpNewMessageShow;
    private boolean mJumpGroupAtInfoShow;
    private boolean mClickLastMessageShow;

    private View forwardArea;
    private View forwardButton;
    private View deleteButton;
    private View forwardCancelButton;
    private ChatBottomSelectSheet forwardSelectSheet;
    private TextView forwardText;
    private long lastTypingTime = 0;
    private boolean isSupportTyping = false;

    private View voiceCallBtn;
    private View videoCallBtn;
    private View chatHeaderBackBtn;
    private TextView chatName;
    private TextView chatDescription;
    private SynthesizedImageView chatAvatar;
    private View userNameArea;
    private OnClickListener onBackClickListener;
    private OnClickListener onAvatarClickListener;
    private ChatPresenter presenter;

    public ChatView(Context context) {
        super(context);
        initViews();
    }

    public ChatView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initViews();
    }

    public ChatView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initViews();
    }

    private void initViews() {
        inflate(getContext(), R.layout.chat_minimalist_layout, this);

        mMessageRecyclerView = findViewById(R.id.chat_message_layout);
        mInputView = findViewById(R.id.chat_input_layout);
        mInputView.setChatLayout(this);
        mRecordingGroup = findViewById(R.id.voice_recording_view);
        mRecordingTips = findViewById(R.id.recording_tips);
        mGroupApplyLayout = findViewById(R.id.chat_group_apply_layout);
        mNoticeLayout = findViewById(R.id.chat_notice_layout);
        mCustomView = findViewById(R.id.custom_layout);
        mCustomView.setVisibility(GONE);

        forwardArea = findViewById(R.id.forward_area);
        forwardButton = findViewById(R.id.forward_image);
        deleteButton = findViewById(R.id.delete_image);
        forwardText = findViewById(R.id.forward_select_text);
        forwardCancelButton = findViewById(R.id.forward_cancel_btn);

        mJumpMessageLayout = findViewById(R.id.jump_message_layout);
        mJumpMessageTextView = findViewById(R.id.jump_message_content);
        mArrowImageView = findViewById(R.id.arrow_icon);
        mJumpNewMessageShow = false;
        hideJumpMessageLayouts();

        voiceCallBtn = findViewById(R.id.voice_call);
        videoCallBtn = findViewById(R.id.video_call);
        chatName = findViewById(R.id.chat_name);
        chatDescription = findViewById(R.id.chat_description);
        chatAvatar = findViewById(R.id.avatar_img);
        chatHeaderBackBtn = findViewById(R.id.back_btn);
        userNameArea = findViewById(R.id.user_name_area);

        lastTypingTime = 0;
        isSupportTyping = false;
    }

    public void displayBackToLastMessages(String messageId) {
        mJumpMessageLayout.setVisibility(VISIBLE);
        mArrowImageView.setBackgroundResource(R.drawable.chat_minimalist_jump_down_icon);
        mJumpMessageTextView.setVisibility(GONE);
        mJumpMessageLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                locateOriginMessage(messageId);
                mClickLastMessageShow = true;
            }
        });
    }

    public void displayBackToNewMessages(String messageId, int count) {
        mJumpNewMessageShow = true;
        mJumpMessageLayout.setVisibility(VISIBLE);
        mArrowImageView.setBackgroundResource(R.drawable.chat_minimalist_jump_down_icon);
        mJumpMessageTextView.setVisibility(VISIBLE);
        mJumpMessageTextView.setText(String.valueOf(count));
        mJumpMessageLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                locateOriginMessage(messageId);
                presenter.markMessageAsRead(mChatInfo);
                mJumpNewMessageShow = false;
                presenter.resetNewMessageCount();
            }
        });
    }

    public void displayBackToAtMessages(List<V2TIMGroupAtInfo> groupAtInfos) {
        mJumpGroupAtInfoShow = true;
        mJumpMessageLayout.setVisibility(VISIBLE);
        mArrowImageView.setBackgroundResource(R.drawable.chat_minimalist_jump_at_icon);
        int atTimes = groupAtInfos.size();
        mJumpMessageTextView.setText(atTimes + "");
        mJumpMessageTextView.setVisibility(VISIBLE);
        mJumpMessageLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                locateOriginMessageBySeq(groupAtInfos.get(0).getSeq());
                hideJumpMessageLayouts();
                mJumpGroupAtInfoShow = false;
            }
        });
    }

    public void hideJumpMessageLayouts() {
        mJumpMessageLayout.setVisibility(GONE);
    }

    public void hideBackToAtMessages() {
        if (mJumpGroupAtInfoShow) {
            mJumpGroupAtInfoShow = false;
            hideJumpMessageLayouts();
        }
    }

    private void initGroupAtInfoLayout() {
        if (mChatInfo != null) {
            List<V2TIMGroupAtInfo> groupAtInfos = mChatInfo.getAtInfoList();
            if (groupAtInfos != null && groupAtInfos.size() > 0) {
                displayBackToAtMessages(groupAtInfos);
            } else {
                TUIChatLog.d(TAG, "initGroupAtInfoLayout groupAtInfos == null");
                mJumpGroupAtInfoShow = false;
                hideJumpMessageLayouts();
            }
        } else {
            TUIChatLog.d(TAG, "initGroupAtInfoLayout mChatInfo == null");
            mJumpGroupAtInfoShow = false;
            hideJumpMessageLayouts();
        }
    }

    private void locateOriginMessageBySeq(long seq) {
        presenter.locateMessageBySeq(mChatInfo.getId(), seq, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                hideJumpMessageLayouts();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                hideJumpMessageLayouts();
                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
            }
        });
    }

    private void locateOriginMessage(String originMsgId) {
        if (TextUtils.isEmpty(originMsgId)) {
            ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
            return;
        }
        presenter.locateMessage(originMsgId, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                hideJumpMessageLayouts();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                hideJumpMessageLayouts();
                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
            }
        });
        hideJumpMessageLayouts();
    }

    public void setPresenter(ChatPresenter presenter) {
        this.presenter = presenter;
        mMessageRecyclerView.setPresenter(presenter);
        mInputView.setPresenter(presenter);
        presenter.setMessageListAdapter(mAdapter);
        mAdapter.setPresenter(presenter);
        presenter.setMessageRecycleView(mMessageRecyclerView);
    }

    public void setOnBackClickListener(OnClickListener onBackClickListener) {
        this.onBackClickListener = onBackClickListener;
    }

    public void setOnAvatarClickListener(OnClickListener onAvatarClickListener) {
        this.onAvatarClickListener = onAvatarClickListener;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        mChatInfo = chatInfo;
        if (chatInfo == null) {
            return;
        }
        mInputView.setChatInfo(chatInfo);
        setChatHandler();

        if (!TUIChatUtils.isC2CChat(chatInfo.getType())) {
            loadApplyList();
            mGroupApplyLayout.setOnNoticeClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIChatConstants.GROUP_ID, chatInfo.getId());
                    TUICore.startActivity(getContext(), "GroupApplyManagerMinimalistActivity", bundle);
                }
            });
        }
        mMessageRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                LinearLayoutManager linearLayoutManager = (LinearLayoutManager) getMessageLayout().getLayoutManager();
                int firstVisiblePosition = linearLayoutManager.findFirstCompletelyVisibleItemPosition();
                int lastVisiblePosition = linearLayoutManager.findLastCompletelyVisibleItemPosition();
                sendMsgReadReceipt(firstVisiblePosition, lastVisiblePosition);
            }
        });

        mMessageRecyclerView.setMenuEmojiOnClickListener(new MessageRecyclerView.OnMenuEmojiClickListener() {
            @Override
            public void onClick(Emoji emoji, TUIMessageBean messageBean) {
                reactMessage(emoji, messageBean);
            }
        });

        loadMessages(chatInfo.getLocateMessage(), chatInfo.getLocateMessage() == null ? TUIChatConstants.GET_MESSAGE_FORWARD : TUIChatConstants.GET_MESSAGE_TWO_WAY);
        initHeader();

    }

    private void initHeader() {
        initCall();
        chatName.setText(mChatInfo.getChatName());
        if (TUIChatUtils.isGroupChat(mChatInfo.getType())) {
            String chatId = mChatInfo.getId();
            chatAvatar.setImageId(chatId);
            chatAvatar.displayImage(mChatInfo.getIconUrlList()).load(chatId);
            ((GroupChatPresenter) presenter).loadGroupMembers(mChatInfo.getId(), new IUIKitCallback<List<GroupMemberInfo>>() {
                @Override
                public void onSuccess(List<GroupMemberInfo> data) {
                    StringBuilder builder = new StringBuilder();
                    for (GroupMemberInfo memberInfo : data) {
                        builder.append(memberInfo.getDisplayName());
                        builder.append("、");
                    }
                    builder.deleteCharAt(builder.lastIndexOf("、"));
                    chatDescription.setText(builder);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    chatDescription.setText(R.string.chat_user_status_unknown);
                }
            });
        } else {
            Glide.with(this)
                    .load(mChatInfo.getFaceUrl())
                    .apply(new RequestOptions()
                            .error(com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light)
                            .placeholder(com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light))
                    .into(chatAvatar);
            presenter.loadUserStatus(Collections.singletonList(mChatInfo.getId()), new IUIKitCallback<Map<String, UserStatusBean>>() {
                @Override
                public void onSuccess(Map<String, UserStatusBean> data) {
                    UserStatusBean statusBean = data.get(mChatInfo.getId());
                    if (statusBean == null || statusBean.getOnlineStatus() != UserStatusBean.STATUS_ONLINE) {
                        chatDescription.setText(R.string.chat_user_status_offline);
                    } else {
                        chatDescription.setText(R.string.chat_user_status_online);
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    chatDescription.setText(R.string.chat_user_status_unknown);
                }
            });

        }
        chatAvatar.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                onHeaderUserClick(v);
            }
        });

        userNameArea.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                onHeaderUserClick(v);
            }
        });

        chatHeaderBackBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onBackClickListener != null) {
                    onBackClickListener.onClick(v);
                }
            }
        });
    }

    private void onHeaderUserClick(View v) {
        if (onAvatarClickListener != null) {
            onAvatarClickListener.onClick(v);
        }
    }

    private void initCall() {
        // topic not support call yet.
        if (TUIChatUtils.isTopicGroup(mChatInfo.getId())) {
            return;
        }

        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.CHAT_ID, mChatInfo.getId());
        param.put(TUIConstants.TUIChat.CHAT_NAME, mChatInfo.getChatName());
        param.put(TUIConstants.TUIChat.CHAT_TYPE, mChatInfo.getType());
        param.put(TUIConstants.TUIChat.CONTEXT, getContext());

        Map<String, Object> voiceCallExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL, param);
        if (voiceCallExtension != null && TUIChatConfigs.getConfigs().getGeneralConfig().isEnableVoiceCall()) {
            voiceCallBtn.setVisibility(VISIBLE);
        }

        Map<String, Object> videoCallExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL, param);
        if (videoCallExtension != null && TUIChatConfigs.getConfigs().getGeneralConfig().isEnableVideoCall()) {
            videoCallBtn.setVisibility(VISIBLE);
        }

        voiceCallBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                startCall(TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL);
            }
        });

        videoCallBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                startCall(TUIConstants.TUICalling.ACTION_ID_VIDEO_CALL);
            }
        });
    }

    private void startCall(int callActionType) {
        if (callActionType == TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL || callActionType == TUIConstants.TUICalling.ACTION_ID_VIDEO_CALL) {
            String type = callActionType == TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL ? TUIConstants.TUICalling.TYPE_AUDIO
                    : TUIConstants.TUICalling.TYPE_VIDEO;
            if (TUIChatUtils.isGroupChat(getChatInfo().getType())) {
                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUICalling.GROUP_ID, getChatInfo().getId());
                bundle.putString(TUIConstants.TUICalling.PARAM_NAME_TYPE, type);
                bundle.putString(TUIChatConstants.GROUP_ID, getChatInfo().getId());
                bundle.putBoolean(TUIChatConstants.SELECT_FOR_CALL, true);
                bundle.putInt(TUIChatConstants.Selection.LIMIT, CALL_MEMBER_LIMIT);
                TUICore.startActivity(getContext(), "StartGroupMemberSelectMinimalistActivity", bundle, 11);
            } else {
                Map<String, Object> map = new HashMap<>();
                map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[]{getChatInfo().getId()});
                map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, type);
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
            }
        }
    }

    private void sendMsgReadReceipt(int firstPosition, int lastPosition) {
        if (mAdapter == null || presenter == null) {
            return;
        }
        List<TUIMessageBean> tuiMessageBeans = mAdapter.getItemList(firstPosition, lastPosition);
        presenter.sendMessageReadReceipt(tuiMessageBeans, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (errCode == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    showNotSupportDialog();
                }
            }
        });
    }

    private void setChatHandler() {
        if (presenter instanceof GroupChatPresenter) {
            presenter.setChatNotifyHandler(new ChatPresenter.ChatNotifyHandler() {
                @Override
                public void onGroupForceExit() {
                    ChatView.this.onExitChat();
                }

                @Override
                public void onGroupNameChanged(String newName) {
                    ChatView.this.onGroupNameChanged(newName);
                }

                @Override
                public void onGroupFaceUrlChanged(String faceUrl) {
                    Glide.with(getContext())
                            .load(faceUrl)
                            .apply(new RequestOptions()
                                    .error(com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light)
                                    .placeholder(com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light))
                            .into(chatAvatar);
                }

                @Override
                public void onApplied(int size) {
                    ChatView.this.onApplied(size);
                }

                @Override
                public void onExitChat(String chatId) {
                    ChatView.this.onExitChat();
                }
            });
        } else if (presenter instanceof C2CChatPresenter) {
            presenter.setChatNotifyHandler(new ChatPresenter.ChatNotifyHandler() {
                @Override
                public void onExitChat(String chatId) {
                    ChatView.this.onExitChat();
                }

                @Override
                public void onFriendNameChanged(String newName) {
                    if (isActivityDestroyed()) {
                        return;
                    }
                    ChatView.this.onFriendNameChanged(newName);
                }

                @Override
                public void onFriendFaceUrlChanged(String faceUrl) {
                    if (isActivityDestroyed()) {
                        return;
                    }
                    Glide.with(getContext())
                            .load(faceUrl)
                            .apply(new RequestOptions()
                                    .error(com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light)
                                    .placeholder(com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light))
                            .into(chatAvatar);
                }
            });
        }
    }

    private boolean isActivityDestroyed() {
        Context context = getContext();
        if (context instanceof Activity) {
            if (((Activity) context).isFinishing() || ((Activity) context).isDestroyed()) {
                return true;
            }
        }
        return false;
    }

    private void loadApplyList() {
        presenter.loadApplyList(new IUIKitCallback<List<GroupApplyInfo>>() {
            @Override
            public void onSuccess(List<GroupApplyInfo> data) {
                if (data != null && data.size() > 0) {
                    mGroupApplyLayout.getContent().setText(getContext().getString(R.string.group_apply_tips, data.size()));
                    mGroupApplyLayout.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.e(TAG, "loadApplyList onError: " + errMsg);
            }
        });
    }

    public void onExitChat() {
        if (getContext() instanceof Activity) {
            ((Activity) getContext()).finish();
        }
    }

    public void onGroupNameChanged(String newName) {
        chatName.setText(newName);
    }

    public void onFriendNameChanged(String newName) {
        chatName.setText(newName);
    }

    public void onApplied(int size) {
        if (size == 0) {
            mGroupApplyLayout.setVisibility(View.GONE);
        } else {
            mGroupApplyLayout.getContent().setText(getContext().getString(R.string.group_apply_tips, size));
            mGroupApplyLayout.setVisibility(View.VISIBLE);
        }
    }

    public void loadMessages(TUIMessageBean lastMessage, int type) {
        if (presenter != null) {
            presenter.loadMessage(type, lastMessage);
        }
    }

    @Override
    public InputView getInputLayout() {
        return mInputView;
    }

    @Override
    public MessageRecyclerView getMessageLayout() {
        return mMessageRecyclerView;
    }

    @Override
    public NoticeLayout getNoticeLayout() {
        return mNoticeLayout;
    }

    public FrameLayout getCustomView() {
        return mCustomView;
    }

    @Override
    public ChatInfo getChatInfo() {
        return mChatInfo;
    }

    private void initListener() {
        getMessageLayout().setPopActionClickListener(new MessageRecyclerView.OnPopActionClickListener() {
            @Override
            public void onCopyClick(TUIMessageBean msg) {
                ClipboardManager clipboard = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                if (clipboard == null || msg == null) {
                    return;
                }
                String copyContent = msg.getSelectText();
                ClipData clip = ClipData.newPlainText("message", copyContent);
                clipboard.setPrimaryClip(clip);

                if (!TextUtils.isEmpty(copyContent)) {
                    String copySuccess = getResources().getString(R.string.copy_success_tip);
                    ToastUtil.toastShortMessage(copySuccess);
                }
            }

            @Override
            public void onSendMessageClick(TUIMessageBean msg, boolean retry) {
                sendMessage(msg, retry);
            }

            @Override
            public void onDeleteMessageClick(TUIMessageBean msg) {
                TUIKitDialog tipsDialog = new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.chat_delete_msg_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                deleteMessage(msg);
                            }
                        })
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
                        });
                tipsDialog.show();
            }

            @Override
            public void onRevokeMessageClick(TUIMessageBean msg) {
                revokeMessage(msg);
            }

            @Override
            public void onMultiSelectMessageClick(TUIMessageBean msg) {
                multiSelectMessage(msg);
            }

            @Override
            public void onForwardMessageClick(TUIMessageBean msg){
                forwardMessage(msg, false);
            }

            @Override
            public void onReplyMessageClick(TUIMessageBean msg) {
                replyMessage(msg);
            }

            @Override
            public void onQuoteMessageClick(TUIMessageBean msg) {
                quoteMessage(msg);
            }

            @Override
            public void onInfoMessageClick(TUIMessageBean msg) {
                showMessageInfo(msg);
            }

            @Override
            public void onTranslateMessageClick(TUIMessageBean msg) {
                translateMessage(msg);
            }
        });
        getMessageLayout().setTranslationPopActionClickListener(new MessageRecyclerView.OnTranslationPopActionClickListener() {
            @Override
            public void onCopyTranslationClick(String translationContent) {
                ClipboardManager clipboard = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                if (clipboard == null || TextUtils.isEmpty(translationContent)) {
                    return;
                }
                ClipData clip = ClipData.newPlainText("message", translationContent);
                clipboard.setPrimaryClip(clip);
                String copySuccess = getResources().getString(R.string.copy_success_tip);
                ToastUtil.toastShortMessage(copySuccess);
            }

            @Override
            public void onForwardTranslationClick(TUIMessageBean msg) {
                forwardMessage(msg, true);
            }

            @Override
            public void onHideTranslationClick(TUIMessageBean msg) {
                msg.setTranslationStatus(TUIMessageBean.MSG_TRANSLATE_STATUS_HIDDEN);
                presenter.updateTranslationMessage(msg);
            }
        });
        getMessageLayout().setLoadMoreMessageHandler(new MessageRecyclerView.OnLoadMoreHandler() {
            @Override
            public void loadMore(int type) {
                loadMessages(type);
            }

            @Override
            public boolean isListEnd(int position) {
                return getMessageLayout().isLastItemVisibleCompleted();
            }

            @Override
            public void displayBackToLastMessage(boolean display) {
                if (mJumpNewMessageShow) {
                    return;
                }
                if (display) {
                    if (mAdapter != null) {
                        TUIMessageBean messageBean = null;
                        for (int i = mAdapter.getItemCount() - 1; i >= 0; i--) {
                            TUIMessageBean tuiMessageBean = mAdapter.getItem(i);
                            if (tuiMessageBean == null || tuiMessageBean.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                                continue;
                            } else {
                                messageBean = mAdapter.getItem(i);
                                break;
                            }
                        }

                        if (messageBean != null) {
                            displayBackToLastMessages(messageBean.getId());
                        } else {
                            TUIChatLog.e(TAG, "displayJumpLayout messageBean is null");
                        }
                    } else {
                        TUIChatLog.e(TAG, "displayJumpLayout mAdapter is null");
                    }
                } else {
                    hideJumpMessageLayouts();
                }
            }

            @Override
            public void displayBackToNewMessage(boolean display, String messageId, int count) {
                if (display) {
                    displayBackToNewMessages(messageId, count);
                } else {
                    mJumpNewMessageShow = false;
                    hideJumpMessageLayouts();
                }
            }

            @Override
            public void hideBackToAtMessage() {
                hideBackToAtMessages();
            }

            @Override
            public void loadMessageFinish() {
                initGroupAtInfoLayout();
            }

            @Override
            public void scrollMessageFinish() {
                if (mClickLastMessageShow && mMessageRecyclerView != null) {
                    mClickLastMessageShow = false;
                    mMessageRecyclerView.setHighShowPosition(-1);
                }
            }
        });
        getMessageLayout().setEmptySpaceClickListener(new MessageRecyclerView.OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                getInputLayout().onEmptyClick();
            }
        });

        getInputLayout().setChatInputHandler(new InputView.ChatInputHandler() {
            @Override
            public void onInputAreaClick() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        if (presenter != null) {
                            presenter.scrollToNewestMessage();
                        }
                    }
                });
            }

            @Override
            public void onRecordStatusChanged(int status) {
                switch (status) {
                    case RECORD_START:
                        startRecording();
                        break;
                    case RECORD_STOP:
                        stopRecording();
                        break;
                    case RECORD_CANCEL:
                        cancelRecording();
                        break;
                    case RECORD_TOO_SHORT:
                    case RECORD_FAILED:
                        stopAbnormally(status);
                        break;
                    default:
                        break;
                }
            }

            @Override
            public void onUserTyping(boolean status, long curTime) {
                if (!TUIChatConfigs.getConfigs().getGeneralConfig().isEnableMessageTyping()) {
                    return;
                }

                if (!isSupportTyping) {
                    if (!isSupportTyping(curTime)) {
                        TUIChatLog.d(TAG, "onUserTyping trigger condition not met");
                        return;
                    } else {
                        isSupportTyping = true;
                    }
                }

                if (!status) {
                    sendTypingStatusMessage(false);
                    return;
                }

                if (lastTypingTime != 0) {
                    if ((curTime - lastTypingTime) < TUIChatConstants.TYPING_SEND_MESSAGE_INTERVAL) {
                        return;
                    }
                }

                lastTypingTime = curTime;
                sendTypingStatusMessage(true);
            }

            private void startRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        AudioPlayer.getInstance().stopPlay();
                        mRecordingGroup.setVisibility(View.VISIBLE);
                        mRecordingTips.setText(TUIChatService.getAppContext().getString(R.string.left_cancle_send));
                    }
                });
            }

            private void stopRecording() {
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 500);
            }

            private void stopAbnormally(final int status) {
                post(new Runnable() {
                    @Override
                    public void run() {
                        if (status == RECORD_TOO_SHORT) {
                            mRecordingTips.setText(TUIChatService.getAppContext().getString(R.string.say_time_short));
                        } else {
                            mRecordingTips.setText(TUIChatService.getAppContext().getString(R.string.record_fail));
                        }
                    }
                });
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 1000);
            }

            private void cancelRecording() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingTips.setText(TUIChatService.getAppContext().getString(R.string.up_cancle_send));
                    }
                });
            }
        });

        forwardCancelButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                resetForwardState();
            }
        });

    }

    public boolean isSupportTyping(long time) {
        return presenter.isSupportTyping(time);
    }

    @Override
    public void initDefault() {
        getInputLayout().setMessageHandler(new InputView.MessageHandler() {
            @Override
            public void sendMessage(TUIMessageBean msg) {
                if (msg instanceof ReplyMessageBean) {
                    ChatView.this.sendReplyMessage(msg, false);
                } else {
                    ChatView.this.sendMessage(msg, false);
                }
            }

            @Override
            public void scrollToEnd() {
                ChatView.this.scrollToEnd();
            }
        });
        getInputLayout().clearCustomActionList();
        if (getMessageLayout().getAdapter() == null) {
            mAdapter = new MessageAdapter();
            mMessageRecyclerView.setAdapter(mAdapter);
        }
        ChatLayoutSetting chatLayoutSetting = new ChatLayoutSetting(getContext());
        chatLayoutSetting.customizeChatLayout(this);
        initListener();
        resetForwardState();
    }

    public void scrollToEnd() {
        getMessageLayout().scrollToEnd();
    }

    @Override
    public void loadMessages(int type) {
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD) {
            loadMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(1) : null, type);
        } else if (type == TUIChatConstants.GET_MESSAGE_BACKWARD){
            loadMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(mAdapter.getItemCount() -1) : null, type);
        }
    }

    protected void deleteMessage(TUIMessageBean msg) {
        presenter.deleteMessage(msg);
    }

    protected void deleteMessages(final List<Integer> positions) {
        presenter.deleteMessages(positions);
    }

    protected void deleteMessageInfos(final List<TUIMessageBean> msgIds) {
        presenter.deleteMessageInfos(msgIds);
    }

    protected boolean checkFailedMessageInfos(final List<TUIMessageBean> msgIds){
        return presenter.checkFailedMessageInfos(msgIds);
    }

    protected void revokeMessage(TUIMessageBean msg) {
        presenter.revokeMessage(msg);
    }

    protected void multiSelectMessage(TUIMessageBean msg) {
        if(mAdapter != null){
            mInputView.hideSoftInput();
            mAdapter.setShowMultiSelectCheckBox(true);
            mAdapter.setOnCheckListChangedListener(new MessageAdapter.OnCheckListChangedListener() {
                @Override
                public void onCheckListChanged(List<TUIMessageBean> checkedList) {
                    int size = checkedList != null ? checkedList.size() : 0;
                    forwardText.setText(getResources().getString(R.string.chat_forward_checked_num, size));
                }
            });
            mAdapter.setItemChecked(msg.getId(), true);
            mAdapter.notifyDataSetChanged();
            setTitleBarWhenMultiSelectMessage();
        }
    }

    protected void forwardMessage(TUIMessageBean msg, boolean onlyForTranslation) {
        if (mAdapter != null) {
            mInputView.hideSoftInput();
            mAdapter.setItemChecked(msg.getId(), true);
            mAdapter.notifyDataSetChanged();
            showForwardDialog(false, true, onlyForTranslation);
        }
    }

    // Reply Message need MessageRootId
    protected void replyMessage(TUIMessageBean messageBean) {
        ReplyPreviewBean replyPreviewBean = ChatMessageBuilder.buildReplyPreviewBean(messageBean);
        mInputView.showReplyPreview(replyPreviewBean);
    }

    // Quote Message not need MessageRootId
    protected void quoteMessage(TUIMessageBean messageBean) {
        ReplyPreviewBean replyPreviewBean = ChatMessageBuilder.buildReplyPreviewBean(messageBean);
        replyPreviewBean.setMessageRootID(null);
        mInputView.showReplyPreview(replyPreviewBean);
    }

    protected void reactMessage(Emoji emoji, TUIMessageBean messageBean) {
        presenter.reactMessage(emoji.getFaceKey(), messageBean);
    }

    protected void translateMessage(TUIMessageBean messageBean) {
        presenter.translateMessage(messageBean);
    }

    protected void showMessageInfo(TUIMessageBean messageBean) {
        Intent intent = new Intent(getContext(), MessageDetailMinimalistActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageBean);
        intent.putExtra(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
        getContext().startActivity(intent);
    }

    private void resetForwardState(){
        if(mAdapter != null){
            mAdapter.setShowMultiSelectCheckBox(false);
            mAdapter.notifyDataSetChanged();
        }
        forwardArea.setVisibility(GONE);
        forwardText.setText("");
        getInputLayout().setVisibility(VISIBLE);
    }

    private void setTitleBarWhenMultiSelectMessage(){
        getInputLayout().setVisibility(GONE);
        forwardArea.setVisibility(VISIBLE);
        requestFocus();
        forwardButton.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v) {
                forwardSelectSheet = new ChatBottomSelectSheet(getContext());
                List<String> stringList = new ArrayList<>();
                String forwardOneByOne = getResources().getString(R.string.forward_mode_onebyone);
                String forwardMerge = getResources().getString(R.string.forward_mode_merge);
                stringList.add(forwardOneByOne);
                stringList.add(forwardMerge);
                forwardSelectSheet.setSelectList(stringList);
                forwardSelectSheet.setOnClickListener(new ChatBottomSelectSheet.BottomSelectSheetOnClickListener() {
                    @Override
                    public void onSheetClick(int index) {
                        if (index == 0) {
                            showForwardDialog(true, true, false);
                        } else if (index == 1) {
                            showForwardDialog(true, false, false);
                        }
                    }
                });
                forwardSelectSheet.show();
            }

        });

        deleteButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                final List<TUIMessageBean> messageInfoList = mAdapter.getSelectedItem();
                if (messageInfoList == null || messageInfoList.isEmpty()) {
                    return;
                }
                TUIKitDialog tipsDialog = new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.chat_delete_msg_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                final List<TUIMessageBean> messageInfoList = mAdapter.getSelectedItem();
                                deleteMessageInfos(messageInfoList);
                                resetForwardState();
                            }
                        })
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
                        });
                tipsDialog.show();
            }
        });
    }

    private void showForwardDialog(boolean isMultiSelect, boolean isOneByOne, boolean onlyForTranslation) {
        if (mAdapter == null){
            return;
        }

        final List<TUIMessageBean> messageInfoList = mAdapter.getSelectedItem();

        if(messageInfoList == null || messageInfoList.isEmpty()){
            ToastUtil.toastShortMessage(getContext().getString(R.string.forward_tip));
            return;
        }

        if(!onlyForTranslation && checkFailedMessageInfos(messageInfoList)){
            ToastUtil.toastShortMessage(getContext().getString(R.string.forward_failed_tip));
            return;
        }

        if (!isMultiSelect) {
            mAdapter.setShowMultiSelectCheckBox(false);
        }

        if (isOneByOne) {
            if (messageInfoList.size() > FORWARD_MSG_NUM_LIMIT) {
                showForwardLimitDialog(messageInfoList);
            } else {
                startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_ONE_BY_ONE, messageInfoList, onlyForTranslation);
                resetForwardState();
            }
        } else {
            startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_MERGE, messageInfoList, onlyForTranslation);
            resetForwardState();
        }
    }

    private void showForwardLimitDialog(final List<TUIMessageBean> messageInfoList) {
        TUIKitDialog tipsDialog = new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.forward_oneByOne_limit_number_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(R.string.forward_mode_merge), new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_MERGE, messageInfoList, false);
                        resetForwardState();
                    }
                })
                .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new OnClickListener() {
                    @Override
                    public void onClick(View v) {

                    }
                });
        tipsDialog.show();
    }

    private void startSelectForwardActivity(int mode, List<TUIMessageBean> msgIds, boolean onlyForTranslation){
        if (mForwardSelectActivityListener != null) {
            mForwardSelectActivityListener.onStartForwardSelectActivity(mode, msgIds, onlyForTranslation);
        }
    }

    public void setForwardSelectActivityListener(ForwardSelectActivityListener listener) {
        this.mForwardSelectActivityListener = listener;
    }

    @Override
    public void sendMessage(TUIMessageBean msg, boolean retry) {
        presenter.sendMessage(msg, retry, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                String toastMsg = errCode + ", " + errMsg;
                if (errCode == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    showNotSupportDialog();
                    if (msg.isNeedReadReceipt()) {
                        toastMsg = getResources().getString(R.string.chat_message_read_receipt)
                                + getResources().getString(com.tencent.qcloud.tuicore.R.string.TUIKitErrorUnsupporInterfaceSuffix);
                    }
                }
                ToastUtil.toastLongMessage(toastMsg);
            }

            @Override
            public void onProgress(Object data) {
                ProgressPresenter.getInstance().updateProgress(msg.getId(), (Integer) data);
            }
        });
    }

    public void sendReplyMessage(TUIMessageBean msg, boolean retry) {
        presenter.sendMessage(msg, retry, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
                    }
                });
                presenter.modifyRootMessageToAddReplyInfo((ReplyMessageBean) data, new IUIKitCallback<Void>() {
                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage("modify message failed code = " + errCode + " message = " + errMsg);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                String toastMsg = errCode + ", " + errMsg;
                if (errCode == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    showNotSupportDialog();
                    if (msg.isNeedReadReceipt()) {
                        toastMsg = getResources().getString(R.string.chat_message_read_receipt)
                                + getResources().getString(com.tencent.qcloud.tuicore.R.string.TUIKitErrorUnsupporInterfaceSuffix);
                    }
                }
                ToastUtil.toastLongMessage(toastMsg);
            }
        });
    }

    public void sendTypingStatusMessage(boolean status) {
        if (mChatInfo == null || TextUtils.isEmpty(getChatInfo().getId())) {
            TUIChatLog.e(TAG, "sendTypingStatusMessage receiver is invalid");
            return;
        }

        Gson gson = new Gson();
        MessageTyping typingMessageBean = new MessageTyping();
        typingMessageBean.setTypingStatus(status);
        String data = gson.toJson(typingMessageBean);
        TUIChatLog.d(TAG, "sendTypingStatusMessage data = " + data);
        TUIMessageBean msg = ChatMessageBuilder.buildCustomMessage(data, "", null);

        presenter.sendTypingStatusMessage(msg, mChatInfo.getId(), new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                TUIChatLog.d(TAG, "sendTypingStatusMessage onSuccess:" + data.getId());
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.d(TAG, "sendTypingStatusMessage fail:" + errCode + "=" + errMsg);
            }
        });
    }

    public void exitChat() {
//        getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
        AudioRecorder.getInstance().stopRecord();
        AudioPlayer.getInstance().stopPlay();
        presenter.markMessageAsRead(mChatInfo);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mCustomView.removeAllViews();
        exitChat();
    }

    public interface ForwardSelectActivityListener {
        public void onStartForwardSelectActivity(int mode, List<TUIMessageBean> msgIds, boolean onlyForTranslation);
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        // 从其他界面会到 Chat ，也要上报一次已读回执
        // You will go to Chat from other interfaces, and you must also report a read receipt
        if (visibility == VISIBLE) {
            if (getMessageLayout() == null) {
                return;
            }
            LinearLayoutManager linearLayoutManager = (LinearLayoutManager) getMessageLayout().getLayoutManager();
            if (linearLayoutManager == null) {
                return;
            }
            int firstVisiblePosition = linearLayoutManager.findFirstCompletelyVisibleItemPosition();
            int lastVisiblePosition = linearLayoutManager.findLastCompletelyVisibleItemPosition();
            sendMsgReadReceipt(firstVisiblePosition, lastVisiblePosition);
        }
    }

    private void showNotSupportDialog() {
        String string = getResources().getString(R.string.chat_im_flagship_edition_update_tip, getResources().getString(R.string.chat_message_read_receipt));
        String buyingGuidelines = getResources().getString(R.string.chat_buying_guidelines);
        int buyingGuidelinesIndex = string.lastIndexOf(buyingGuidelines);
        final int foregroundColor = getResources().getColor(TUIThemeManager.getAttrResId(getContext(), com.tencent.qcloud.tuicore.R.attr.core_primary_color));
        SpannableString spannedString = new SpannableString(string);
        ForegroundColorSpan colorSpan2 = new ForegroundColorSpan(foregroundColor);
        spannedString.setSpan(colorSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        ClickableSpan clickableSpan2 = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                if (TextUtils.equals(TUIThemeManager.getInstance().getCurrentLanguage(), "zh")) {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC);
                } else {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC_EN);
                }
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        TUIKitDialog.TUIIMUpdateDialog.getInstance()
                .createDialog(getContext())
                .setShowOnlyDebug(true)
                .setMovementMethod(LinkMovementMethod.getInstance())
                .setHighlightColor(Color.TRANSPARENT)
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(spannedString)
                .setDialogWidth(0.75f)
                .setDialogFeatureName(TUIConstants.BuyingFeature.BUYING_FEATURE_MESSAGE_RECEIPT)
                .setPositiveButton(getResources().getString(R.string.chat_no_more_reminders), new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().setNeverShow(true);
                    }
                })
                .setNegativeButton(getResources().getString(R.string.chat_i_know), new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                    }
                })
                .show();
    }

    private void openWebUrl(String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getContext().startActivity(intent);
    }
}
