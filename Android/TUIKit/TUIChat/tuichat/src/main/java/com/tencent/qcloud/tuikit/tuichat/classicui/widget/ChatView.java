package com.tencent.qcloud.tuikit.tuichat.classicui.widget;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.AnimationDrawable;
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
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.UnreadCountTextView;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageTyping;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout.NoticeLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.setting.ChatLayoutSetting;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.component.AudioRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.face.Emoji;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.TotalUnreadCountListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.List;


public class ChatView extends LinearLayout  implements IChatLayout {
    private static final String TAG = ChatView.class.getSimpleName();
    // 逐条转发消息数量限制
    // Limit the number of messages forwarded one by one
    private static final int FORWARD_MSG_NUM_LIMIT = 30;

    protected MessageAdapter mAdapter;
    private ForwardSelectActivityListener mForwardSelectActivityListener;
    private TotalUnreadCountListener unreadCountListener;

    private AnimationDrawable mVolumeAnim;
    private Runnable mTypingRunnable = null;
    private ChatInfo mChatInfo;
    public ChatPresenter.TypingListener mTypingListener = new ChatPresenter.TypingListener() {
        @Override
        public void onTyping(int status) {
            if (!TUIChatConfigs.getConfigs().getGeneralConfig().isEnableMessageTyping()) {
                return;
            }

            if (mChatInfo == null) {
                return;
            }

            TUIChatLog.d(TAG, "mTypingListener status= " + status);
            String oldTitle = mChatInfo.getChatName();
            if (status == 1) {
                getTitleBar().getMiddleTitle().setText(R.string.typing);

                if (mTypingRunnable == null) {
                    mTypingRunnable = new Runnable() {
                        @Override
                        public void run() {
                            getTitleBar().getMiddleTitle().setText(oldTitle);
                        }
                    };
                }
                getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
                getTitleBar().getMiddleTitle().postDelayed(mTypingRunnable, TUIChatConstants.TYPING_PARSE_MESSAGE_INTERVAL * 1000);
            } else if (status == 0){
                getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
                getTitleBar().getMiddleTitle().setText(oldTitle);
            } else {
                TUIChatLog.e(TAG, "parseTypingMessage error status =" + status);
            }
        }
    };

    protected FrameLayout mCustomView;
    protected NoticeLayout mGroupApplyLayout;
    protected View mRecordingGroup;
    protected ImageView mRecordingIcon;
    protected TextView mRecordingTips;
    private TitleBarLayout mTitleBar;
    private MessageRecyclerView mMessageRecyclerView;
    private InputView mInputView;
    private NoticeLayout mNoticeLayout;
    private LinearLayout mJumpMessageLayout;
    private ImageView mArrowImageView;
    private TextView mJumpMessageTextView;
    private boolean mJumpNewMessageShow;
    private boolean mJumpGroupAtInfoShow;
    private boolean mClickLastMessageShow;

    private LinearLayout mForwardLayout;
    private View mForwardOneButton;
    private View mForwardMergeButton;
    private View mDeleteButton;
    private long lastTypingTime = 0;
    private boolean isSupportTyping = false;

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
        inflate(getContext(), R.layout.chat_layout, this);

        mTitleBar = findViewById(R.id.chat_title_bar);
        mMessageRecyclerView = findViewById(R.id.chat_message_layout);
        mInputView = findViewById(R.id.chat_input_layout);
        mInputView.setChatLayout(this);
        mRecordingGroup = findViewById(R.id.voice_recording_view);
        mRecordingIcon = findViewById(R.id.recording_icon);
        mRecordingTips = findViewById(R.id.recording_tips);
        mGroupApplyLayout = findViewById(R.id.chat_group_apply_layout);
        mNoticeLayout = findViewById(R.id.chat_notice_layout);
        mCustomView = findViewById(R.id.custom_layout);
        mCustomView.setVisibility(GONE);

        mForwardLayout = findViewById(R.id.forward_layout);
        mForwardOneButton = findViewById(R.id.forward_one_by_one_button);
        mForwardMergeButton = findViewById(R.id.forward_merge_button);
        mDeleteButton = findViewById(R.id.delete_button);

        mJumpMessageLayout = findViewById(R.id.jump_message_layout);
        mJumpMessageTextView = findViewById(R.id.jump_message_content);
        mArrowImageView = findViewById(R.id.arrow_icon);
        mJumpNewMessageShow = false;
        hideJumpMessageLayouts();

        mTitleBar.getMiddleTitle().setEllipsize(TextUtils.TruncateAt.END);
        lastTypingTime = 0;
        isSupportTyping = false;
    }

    public void displayBackToLastMessages(String messageId) {
        mJumpMessageLayout.setVisibility(VISIBLE);
        mArrowImageView.setBackgroundResource(TUIThemeManager.getAttrResId(getContext(), R.attr.chat_jump_recent_down_icon));
        mJumpMessageTextView.setText(getContext().getString(R.string.back_to_lastmessage));
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
        mArrowImageView.setBackgroundResource(TUIThemeManager.getAttrResId(getContext(), R.attr.chat_jump_recent_down_icon));
        mJumpMessageTextView.setText(String.valueOf(count) + getContext().getString(R.string.back_to_newmessage));
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

    public void displayBackToAtMessages(V2TIMGroupAtInfo groupAtInfo) {
        mJumpGroupAtInfoShow = true;
        mJumpMessageLayout.setVisibility(VISIBLE);
        mArrowImageView.setBackgroundResource(TUIThemeManager.getAttrResId(getContext(), R.attr.chat_jump_recent_up_icon));
        if (groupAtInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL) {
            mJumpMessageTextView.setText(getContext().getString(R.string.back_to_atmessage_all));
        } else {
            mJumpMessageTextView.setText(getContext().getString(R.string.back_to_atmessage_me));
        }
        mJumpMessageLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                locateOriginMessageBySeq(groupAtInfo.getSeq());
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
                V2TIMGroupAtInfo groupAtInfo = groupAtInfos.get(0);
                if (groupAtInfo != null) {
                    displayBackToAtMessages(groupAtInfo);
                } else {
                    mJumpGroupAtInfoShow = false;
                    hideJumpMessageLayouts();
                }
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

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            if (mAdapter != null) {
                mAdapter.resetSelectableText();
            }
        }
        return super.dispatchTouchEvent(ev);
    }

    public void setChatInfo(ChatInfo chatInfo) {
        mChatInfo = chatInfo;
        if (chatInfo == null) {
            return;
        }
        mInputView.setChatInfo(chatInfo);
        String chatTitle = chatInfo.getChatName();
        getTitleBar().setTitle(chatTitle, ITitleBarLayout.Position.MIDDLE);

        setChatHandler();

        if (!TUIChatUtils.isC2CChat(chatInfo.getType())) {
            loadApplyList();
            mGroupApplyLayout.setOnNoticeClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIChatConstants.GROUP_ID, chatInfo.getId());
                    TUICore.startActivity(getContext(), "GroupApplyManagerActivity", bundle);
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

        getTitleBar().setRightIcon(TUIThemeManager.getAttrResId(getContext(), R.attr.chat_title_bar_more_menu));
        loadMessages(chatInfo.getLocateMessage(), chatInfo.getLocateMessage() == null ? TUIChatConstants.GET_MESSAGE_FORWARD : TUIChatConstants.GET_MESSAGE_TWO_WAY);
        setTotalUnread();
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

    private void setTotalUnread() {
        UnreadCountTextView unreadCountTextView = mTitleBar.getUnreadCountTextView();
        unreadCountTextView.setPaintColor(getResources().getColor(TUIThemeManager.getAttrResId(getContext(), R.attr.chat_unread_dot_bg_color)));
        unreadCountTextView.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(getContext(), R.attr.chat_unread_dot_text_color)));
        long unreadCount = 0;
        Object result = TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME, TUIConstants.TUIConversation.METHOD_GET_TOTAL_UNREAD_COUNT, null);
        if (result != null && result instanceof Long) {
            unreadCount = (long) TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME, TUIConstants.TUIConversation.METHOD_GET_TOTAL_UNREAD_COUNT, null);
        }
        updateUnreadCount(unreadCountTextView, unreadCount);
        unreadCountListener = new TotalUnreadCountListener() {
            @Override
            public void onTotalUnreadCountChanged(long totalUnreadCount) {
                updateUnreadCount(unreadCountTextView, totalUnreadCount);
            }
        };
        TUIChatService.getInstance().addUnreadCountListener(unreadCountListener);
    }

    private void updateUnreadCount(UnreadCountTextView unreadCountTextView, long count) {
        if (count <= 0) {
            unreadCountTextView.setVisibility(GONE);
        } else {
            unreadCountTextView.setVisibility(VISIBLE);
            String unreadCountStr = count + "";
            if (count > 99) {
                unreadCountStr = "99+";
            }
            unreadCountTextView.setText(unreadCountStr);
        }
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
                    ChatView.this.onFriendNameChanged(newName);
                }
            });
        }
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
        getTitleBar().setTitle(newName, ITitleBarLayout.Position.MIDDLE);
    }

    public void onFriendNameChanged(String newName) {
        getTitleBar().setTitle(newName, ITitleBarLayout.Position.MIDDLE);
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

    public LinearLayout getForwardLayout() {
        return mForwardLayout;
    }
    public View getForwardOneButton() {
        return mForwardOneButton;
    }
    public View getDeleteButton() {
        return mDeleteButton;
    }

    public View getForwardMergeButton() {
        return mForwardMergeButton;
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

    @Override
    public TitleBarLayout getTitleBar() {
        return mTitleBar;
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
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                deleteMessage(msg);
                            }
                        })
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new View.OnClickListener() {
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
                        mRecordingIcon.setImageResource(R.drawable.recording_volume);
                        mVolumeAnim = (AnimationDrawable) mRecordingIcon.getDrawable();
                        mVolumeAnim.start();
                        mRecordingTips.setTextColor(Color.WHITE);
                        mRecordingTips.setText(TUIChatService.getAppContext().getString(R.string.down_cancle_send));
                    }
                });
            }

            private void stopRecording() {
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (mVolumeAnim != null) {
                            mVolumeAnim.stop();
                        }
                        mRecordingGroup.setVisibility(View.GONE);
                    }
                }, 500);
            }

            private void stopAbnormally(final int status) {
                post(new Runnable() {
                    @Override
                    public void run() {
                        mVolumeAnim.stop();
                        mRecordingIcon.setImageResource(R.drawable.ic_volume_dialog_length_short);
                        mRecordingTips.setTextColor(Color.WHITE);
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
                        mRecordingIcon.setImageResource(R.drawable.ic_volume_dialog_cancel);
                        mRecordingTips.setText(TUIChatService.getAppContext().getString(R.string.up_cancle_send));
                    }
                });
            }
        });
    }

    public boolean isSupportTyping(long time) {
        return presenter.isSupportTyping(time);
    }

    @Override
    public void initDefault() {
        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
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
        resetForwardState("");
    }

    @Override
    public void setParentLayout(Object parentContainer) {

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

    private void resetTitleBar(String leftTitle){
        getTitleBar().getRightGroup().setVisibility(VISIBLE);

        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().getLeftIcon().setVisibility(VISIBLE);
        if (!TextUtils.isEmpty(leftTitle)) {
            getTitleBar().setTitle(leftTitle, ITitleBarLayout.Position.LEFT);
        } else {
            getTitleBar().setTitle("", TitleBarLayout.Position.LEFT);
        }
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });

        getForwardLayout().setVisibility(GONE);
        getInputLayout().setVisibility(VISIBLE);
    }

    private void resetForwardState(String leftTitle){
        if(mAdapter != null){
            mAdapter.setShowMultiSelectCheckBox(false);
            mAdapter.notifyDataSetChanged();
        }

        resetTitleBar(leftTitle);
    }

    private void setTitleBarWhenMultiSelectMessage(){
        getTitleBar().getRightGroup().setVisibility(GONE);

        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().getLeftIcon().setVisibility(GONE);
        final CharSequence leftTitle = getTitleBar().getLeftTitle().getText();
        getTitleBar().setTitle(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), TitleBarLayout.Position.LEFT);
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                resetForwardState(leftTitle.toString());
            }
        });
        getInputLayout().setVisibility(GONE);
        getForwardLayout().setVisibility(VISIBLE);
        getForwardOneButton().setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                showForwardDialog(true, true, false);
            }
        });
        getForwardMergeButton().setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                showForwardDialog(true, false, false);
            }
        });
        getDeleteButton().setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                List<TUIMessageBean> msgIds =  mAdapter.getSelectedItem();

                if(msgIds == null || msgIds.isEmpty()){
                    ToastUtil.toastShortMessage("please select message!");
                    return;
                }

                deleteMessageInfos(msgIds);

                resetForwardState(leftTitle.toString());
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
                resetForwardState("");
            }
        } else {
            startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_MERGE, messageInfoList, onlyForTranslation);
            resetForwardState("");
        }
    }

    private void showForwardLimitDialog(final List<TUIMessageBean> messageInfoList) {
        TUIKitDialog tipsDialog = new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.forward_oneByOne_limit_number_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(R.string.forward_mode_merge), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_MERGE, messageInfoList, false);
                        resetForwardState("");
                    }
                })
                .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new View.OnClickListener() {
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
        getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
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
                .setPositiveButton(getResources().getString(R.string.chat_no_more_reminders), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().setNeverShow(true);
                    }
                })
                .setNegativeButton(getResources().getString(R.string.chat_i_know), new View.OnClickListener() {
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
