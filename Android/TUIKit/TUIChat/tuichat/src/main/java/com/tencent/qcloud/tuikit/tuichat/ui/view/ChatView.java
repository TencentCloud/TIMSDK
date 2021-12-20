package com.tencent.qcloud.tuikit.tuichat.ui.view;

import android.app.Activity;
import android.app.Dialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import android.graphics.Color;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.UnreadCountTextView;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuicore.component.NoticeLayout;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.tuichat.interfaces.TotalUnreadCountListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.setting.ChatLayoutSetting;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.ui.view.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.MessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.List;


public class ChatView extends LinearLayout  implements IChatLayout {
    private static final String TAG = ChatView.class.getSimpleName();
    // 逐条转发消息数量限制
    private static final int FORWARD_MSG_NUM_LIMIT = 30;

    protected MessageAdapter mAdapter;
    private ForwardSelectActivityListener mForwardSelectActivityListener;
    private TotalUnreadCountListener unreadCountListener;
    private TUIMessageBean mConversationLastMessage;

    private AnimationDrawable mVolumeAnim;
    private Runnable mTypingRunnable = null;
    private ChatPresenter.TypingListener mTypingListener = new ChatPresenter.TypingListener() {
        @Override
        public void onTyping() {
            final String oldTitle = getTitleBar().getMiddleTitle().getText().toString();
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
            getTitleBar().getMiddleTitle().postDelayed(mTypingRunnable, 3000);
        }
    };

    protected NoticeLayout mGroupApplyLayout;
    protected View mRecordingGroup;
    protected ImageView mRecordingIcon;
    protected TextView mRecordingTips;
    private TitleBarLayout mTitleBar;
    private MessageRecyclerView mMessageRecyclerView;
    private InputView mInputView;
    private NoticeLayout mNoticeLayout;
    protected ChatInfo mChatInfo;
    private TextView mChatAtInfoLayout;

    private LinearLayout mForwardLayout;
    private Button mForwardButton;
    private Button mDeleteButton;
    private boolean isGroup = false;

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
        mChatAtInfoLayout = findViewById(R.id.chat_at_text_view);

        mForwardLayout = findViewById(R.id.forward_layout);
        mForwardButton = findViewById(R.id.forward_button);
        mDeleteButton = findViewById(R.id.delete_button);

        mTitleBar.getMiddleTitle().setEllipsize(TextUtils.TruncateAt.END);
        mTitleBar.setBackgroundColor(getResources().getColor(R.color.chat_title_bar_bg));
    }

    public void setPresenter(ChatPresenter presenter) {
        this.presenter = presenter;
        mMessageRecyclerView.setPresenter(presenter);
        mInputView.setPresenter(presenter);
        presenter.setMessageListAdapter(mAdapter);
        mAdapter.setPresenter(presenter);
    }

    public void setChatInfo(ChatInfo chatInfo) {
        mChatInfo = chatInfo;
        if (chatInfo == null) {
            return;
        }

        mInputView.setChatInfo(chatInfo);
        String chatTitle = chatInfo.getChatName();
        getTitleBar().setTitle(chatTitle, ITitleBarLayout.Position.MIDDLE);

        if (TUIChatUtils.isC2CChat(chatInfo.getType())) {
            isGroup = false;
        } else {
            isGroup = true;
        }

        setChatHandler();

        if (isGroup) {
            loadApplyList();
            getTitleBar().setOnRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIChatConstants.Group.GROUP_ID, chatInfo.getId());
                    TUICore.startActivity(getContext(), "GroupInfoActivity", bundle);
                }
            });
            mGroupApplyLayout.setOnNoticeClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIChatConstants.GROUP_ID, chatInfo.getId());
                    TUICore.startActivity(getContext(), "GroupApplyManagerActivity", bundle);
                }
            });
        }
        getTitleBar().getRightIcon().setImageResource(R.drawable.chat_more);
        getTitleBar().getLeftIcon().setImageResource(R.drawable.chat_back);

        getConversationLastMessage(TUIChatUtils.getConversationIdByUserId(chatInfo.getId(), isGroup));
        loadMessages(chatInfo.getLocateMessage(), chatInfo.getLocateMessage() == null ? TUIChatConstants.GET_MESSAGE_FORWARD : TUIChatConstants.GET_MESSAGE_TWO_WAY);

        setTotalUnread();
    }

    private void setTotalUnread() {
        UnreadCountTextView unreadCountTextView = mTitleBar.getUnreadCountTextView();
        unreadCountTextView.setPaintColor(getResources().getColor(R.color.chat_unread_count_tip_color));
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
        TUIChatService.getInstance().setUnreadCountListener(unreadCountListener);
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
                ToastUtil.toastLongMessage("loadApplyList onError: " + errMsg);
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
    public Button getForwardButton() {
        return mForwardButton;
    }
    public Button getDeleteButton() {
        return mDeleteButton;
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

    @Override
    public ChatInfo getChatInfo() {
        return mChatInfo;
    }

    @Override
    public TextView getAtInfoLayout() {
        return mChatAtInfoLayout;
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
                if (msg instanceof TextMessageBean) {
                    String copyContent = ((TextMessageBean) msg).getText();
                    ClipData clip = ClipData.newPlainText("message", copyContent);
                    clipboard.setPrimaryClip(clip);
                } else if (msg instanceof ReplyMessageBean) {
                    TUIMessageBean contentMsgBean = ((ReplyMessageBean) msg).getContentMessageBean();
                    if (contentMsgBean != null) {
                        String copyContent = contentMsgBean.getExtra();
                        ClipData clip = ClipData.newPlainText("message", copyContent);
                        clipboard.setPrimaryClip(clip);
                    }
                }
                String copySuccess = getResources().getString(R.string.copy_success_tip);
                ToastUtil.toastShortMessage(copySuccess);
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
                        .setPositiveButton(getContext().getString(R.string.sure), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                deleteMessage(msg);
                            }
                        })
                        .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
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
                forwardMessage(msg);
            }

            @Override
            public void onReplyMessageClick(TUIMessageBean msg) {
                replyMessage(msg);
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
        });
        getMessageLayout().setEmptySpaceClickListener(new MessageRecyclerView.OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                getInputLayout().hideSoftInput();
            }
        });

        getInputLayout().setChatInputHandler(new InputView.ChatInputHandler() {
            @Override
            public void onInputAreaClick() {
                post(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
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
                        mVolumeAnim.stop();
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
                ChatView.this.sendMessage(msg, false);
            }

            @Override
            public void scrollToEnd() {
                ChatView.this.scrollToEnd();
            }
        });
        getInputLayout().clearCustomActionList();
        if (getMessageLayout().getAdapter() == null) {
            mAdapter = new MessageAdapter();
            getMessageLayout().setAdapter(mAdapter);
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

    public void getConversationLastMessage(String id) {
        presenter.getConversationLastMessage(id, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                if (data == null) {
                    Log.d(TAG, "getConversationLastMessage failed");
                    return;
                }
                mConversationLastMessage = data;
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
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

    protected boolean checkFailedMessage(final List<Integer> positions) {
        return presenter.checkFailedMessages(positions);
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

    protected void forwardMessage(TUIMessageBean msg) {
        if (mAdapter != null) {
            mInputView.hideSoftInput();
            mAdapter.setItemChecked(msg.getId(), true);
            mAdapter.notifyDataSetChanged();
            showForwardDialog(false);
        }
    }

    protected void replyMessage(TUIMessageBean messageBean) {
        ReplyPreviewBean replyPreviewBean = ChatMessageBuilder.buildReplyPreviewBean(messageBean);
        mInputView.showReplyPreview(replyPreviewBean);
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
    }

    private void resetForwardState(String leftTitle){
        //取消多选界面
        if(mAdapter != null){
            mAdapter.setShowMultiSelectCheckBox(false);
            mAdapter.notifyDataSetChanged();
        }

        //重置titlebar
        resetTitleBar(leftTitle);
    }

    private void setTitleBarWhenMultiSelectMessage(){
        getTitleBar().getRightGroup().setVisibility(GONE);

        getTitleBar().getLeftGroup().setVisibility(View.VISIBLE);
        getTitleBar().getLeftIcon().setVisibility(GONE);
        final CharSequence leftTitle = getTitleBar().getLeftTitle().getText();
        getTitleBar().setTitle(getContext().getString(R.string.cancel), TitleBarLayout.Position.LEFT);
        //点击取消
        getTitleBar().setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                resetForwardState(leftTitle.toString());
            }
        });

        getForwardLayout().setVisibility(VISIBLE);
        //点击转发
        getForwardButton().setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                showForwardDialog(true);
            }
        });

        //点击删除
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

    private void showForwardDialog(boolean isMultiSelect) {
        if (mAdapter == null){
            return;
        }

        final List<TUIMessageBean> messageInfoList = mAdapter.getSelectedItem();
        if(messageInfoList == null || messageInfoList.isEmpty()){
            ToastUtil.toastShortMessage(getContext().getString(R.string.forward_tip));
            return;
        }

        if(checkFailedMessageInfos(messageInfoList)){
            ToastUtil.toastShortMessage(getContext().getString(R.string.forward_failed_tip));
            return;
        }

        if (!isMultiSelect) {
            mAdapter.setShowMultiSelectCheckBox(false);//发送完清理选中
        }

        final Dialog bottomDialog = new Dialog(getContext(), R.style.BottomDialog);
        View contentView = LayoutInflater.from(getContext()).inflate(R.layout.forward_dialog_layout, null);
        bottomDialog.setContentView(contentView);
        ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) contentView.getLayoutParams();
        params.width = getResources().getDisplayMetrics().widthPixels - 8;
        contentView.setLayoutParams(params);
        bottomDialog.getWindow().setGravity(Gravity.BOTTOM);
        bottomDialog.getWindow().setWindowAnimations(R.style.BottomDialog_Animation);
        bottomDialog.show();

        contentView.findViewById(R.id.forward_one_by_one).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (messageInfoList.size() > FORWARD_MSG_NUM_LIMIT) {
                    showForwardLimitDialog(bottomDialog, messageInfoList);
                } else {
                    bottomDialog.dismiss();
                    startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_ONE_BY_ONE, messageInfoList);
                    resetForwardState("");
                    ;//发送完清理选中
                }
            }
        });
        contentView.findViewById(R.id.forward_merge).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                bottomDialog.dismiss();

                startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_MERGE, messageInfoList);
                resetForwardState("");;//发送完清理选中
            }
        });
        contentView.findViewById(R.id.cancel_action).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                bottomDialog.dismiss();
            }
        });
    }

    private void showForwardLimitDialog(final Dialog bottomDialog, final List<TUIMessageBean> messageInfoList) {
        TUIKitDialog tipsDialog = new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.forward_oneByOne_limit_number_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(R.string.forward_mode_merge), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        bottomDialog.dismiss();
                        startSelectForwardActivity(TUIChatConstants.FORWARD_MODE_MERGE, messageInfoList);
                        resetForwardState("");;//发送完清理选中
                    }
                })
                .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                    }
                });
        tipsDialog.show();
    }

    private void startSelectForwardActivity(int mode, List<TUIMessageBean> msgIds){
        if (mForwardSelectActivityListener != null) {
            mForwardSelectActivityListener.onStartForwardSelectActivity(mode, msgIds);
        }
    }

    public void setForwardSelectActivityListener(ForwardSelectActivityListener listener) {
        this.mForwardSelectActivityListener = listener;
    }

    @Override
    public void sendMessage(TUIMessageBean msg, boolean retry) {
        presenter.sendMessage(msg, retry, new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        scrollToEnd();
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void exitChat() {
        getTitleBar().getMiddleTitle().removeCallbacks(mTypingRunnable);
        AudioPlayer.getInstance().stopRecord();
        AudioPlayer.getInstance().stopPlay();
        presenter.markMessageAsRead(mChatInfo);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        exitChat();
    }

    public interface ForwardSelectActivityListener {
        public void onStartForwardSelectActivity(int mode, List<TUIMessageBean> msgIds);
    }
}
