package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.component.BeginnerGuidePage;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.MessageProperties;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.face.Emoji;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnChatPopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.IMessageLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.MessageReplyDetailActivity;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MessageRecyclerView extends RecyclerView implements IMessageRecyclerView, IMessageLayout {
    private static final String TAG = MessageRecyclerView.class.getSimpleName();

    // 取一个足够大的偏移保证能一次性滚动到最底部
    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = -999999;
    private static final int SOUND_PLAY_DELAYED = 500;

    protected OnItemClickListener mOnItemClickListener;
    protected MessageRecyclerView.OnLoadMoreHandler mHandler;
    protected MessageRecyclerView.OnEmptySpaceClickListener mEmptySpaceClickListener;
    protected MessageAdapter mAdapter;
    protected List<ChatPopMenu.ChatPopMenuAction> mPopActions = new ArrayList<>();
    protected List<ChatPopMenu.ChatPopMenuAction> mMorePopActions = new ArrayList<>();
    protected OnChatPopActionClickListener mOnPopActionClickListener;
    private final MessageProperties properties = MessageProperties.getInstance();

    private Set<String> downloadList = new HashSet<>();

    private OnMenuEmojiClickListener menuEmojiOnClickListener;

    private ChatPresenter presenter;

    private int mSelectedPosition = -1;
    private ChatPopMenu mChatPopMenu;

    private final Handler soundPlayHandler = new Handler();

    public MessageRecyclerView(Context context) {
        super(context);
        init();
    }

    public MessageRecyclerView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public MessageRecyclerView(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    private void init() {
        TUIChatLog.d(TAG, "init()");
        setLayoutFrozen(false);
        setItemViewCacheSize(0);
        setHasFixedSize(true);
        setFocusableInTouchMode(false);
        setFocusable(true);
        setClickable(true);
        LinearLayoutManager linearLayoutManager = new CustomLinearLayoutManager(getContext());
        linearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        setLayoutManager(linearLayoutManager);
        SimpleItemAnimator animator = (SimpleItemAnimator) getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
        setClickEmptySpaceEvent();
    }

    public void setPresenter(ChatPresenter presenter) {
        this.presenter = presenter;
    }

    private void setClickEmptySpaceEvent() {
        GestureDetector.OnGestureListener gestureListener = new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (mEmptySpaceClickListener != null) {
                    mEmptySpaceClickListener.onClick();
                    return true;
                }
                return false;
            }
        };

        GestureDetector gestureDetector = new GestureDetector(getContext(), gestureListener);
        setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (v instanceof RecyclerView) {
                    gestureDetector.onTouchEvent(event);
                }
                return false;
            }
        });
    }

    public void setSelectedPosition(int position) {
        this.mSelectedPosition = position;
    }

    public int getSelectedPosition() {
        return mSelectedPosition;
    }

    public void showItemPopMenu(final int index, final TUIMessageBean messageInfo, View view) {
        initPopActions(messageInfo);

        if (mChatPopMenu != null) {
            mChatPopMenu.hide();
            mChatPopMenu = null;
        }
        mChatPopMenu = new ChatPopMenu(getContext());
        mChatPopMenu.setShowFaces(TUIChatConfigs.getConfigs().getGeneralConfig().isReactEnable());
        mChatPopMenu.setChatPopMenuActionList(mPopActions);
        mChatPopMenu.setEmojiOnClickListener(new ChatPopMenu.EmojiOnClickListener() {
            @Override
            public void onClick(Emoji emoji) {
                if (menuEmojiOnClickListener != null) {
                    menuEmojiOnClickListener.onClick(emoji, messageInfo);
                }
            }
        });

        int[] location = new int[2];
        getLocationOnScreen(location);
        mChatPopMenu.setEmptySpaceClickListener(new MessageRecyclerView.OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                if (mAdapter != null) {
                    mAdapter.resetSelectableText();
                }
            }
        });
        mChatPopMenu.show(view, location[1]);
    }

    public void onMsgAddBack() {
        if (mAdapter != null) {
            if (isLastItemVisibleCompleted()) {
                scrollToEnd();
            }
        }
    }

    public boolean isDisplayJumpMessageLayout() {
        TUIChatLog.d(TAG,
            "computeVerticalScrollRange() = " + computeVerticalScrollRange() + ", computeVerticalScrollExtent() = " + computeVerticalScrollExtent()
                + ", computeVerticalScrollOffset() = " + computeVerticalScrollOffset());
        int toBottom = computeVerticalScrollRange() - computeVerticalScrollExtent() - computeVerticalScrollOffset();
        TUIChatLog.d(TAG, "toBottom = " + toBottom);
        if (toBottom > 0 && toBottom >= 2 * computeVerticalScrollExtent()) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isLastItemVisibleCompleted() {
        LinearLayoutManager linearLayoutManager = (LinearLayoutManager) getLayoutManager();
        if (linearLayoutManager == null) {
            return false;
        }
        int lastPosition = linearLayoutManager.findLastCompletelyVisibleItemPosition();
        int childCount = linearLayoutManager.getChildCount();
        int firstPosition = linearLayoutManager.findFirstVisibleItemPosition();
        if (lastPosition >= firstPosition + childCount - 1) {
            return true;
        }
        return false;
    }

    private boolean isDefaultMessage(TUIMessageBean messageBean) {
        Set<Class<? extends TUIMessageBean>> extensionMessageClassSet = TUIChatService.getInstance().getExtensionMessageClassSet();
        return !extensionMessageClassSet.contains(messageBean.getClass());
    }

    private void initPopActions(final TUIMessageBean msg) {
        if (msg == null) {
            return;
        }
        mPopActions.clear();

        ChatPopMenu.ChatPopMenuAction copyAction = null;
        ChatPopMenu.ChatPopMenuAction forwardAction = null;
        ChatPopMenu.ChatPopMenuAction multiSelectAction = null;
        ChatPopMenu.ChatPopMenuAction quoteAction = null;
        ChatPopMenu.ChatPopMenuAction replyAction = null;
        ChatPopMenu.ChatPopMenuAction revokeAction = null;
        ChatPopMenu.ChatPopMenuAction deleteAction = null;

        boolean textIsAllSelected = true;
        if (msg instanceof TextMessageBean || msg instanceof QuoteMessageBean) {
            String selectText = msg.getSelectText();
            if (!TextUtils.isEmpty(selectText)) {
                String text = msg.getExtra();
                if (!text.equals(selectText)) {
                    textIsAllSelected = false;
                }
            }
        }
        if (msg instanceof TextMessageBean || msg instanceof QuoteMessageBean) {
            copyAction = new ChatPopMenu.ChatPopMenuAction();
            copyAction.setActionName(getContext().getString(R.string.copy_action));
            copyAction.setActionIcon(R.drawable.pop_menu_copy);
            copyAction.setActionClickListener(() -> mOnPopActionClickListener.onCopyClick(msg));
        }

        if (textIsAllSelected) {
            deleteAction = new ChatPopMenu.ChatPopMenuAction();
            deleteAction.setActionName(getContext().getString(R.string.delete_action));
            deleteAction.setActionIcon(R.drawable.pop_menu_delete);
            deleteAction.setActionClickListener(() -> mOnPopActionClickListener.onDeleteMessageClick(msg));
            if (msg.isSelf()) {
                if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                    long timeInterval = TUIChatUtils.getServerTime() - msg.getMessageTime();
                    if (timeInterval < TUIChatConfigs.getConfigs().getGeneralConfig().getTimeIntervalForMessageRecall()) {
                        revokeAction = new ChatPopMenu.ChatPopMenuAction();
                        revokeAction.setActionName(getContext().getString(R.string.revoke_action));
                        revokeAction.setActionIcon(R.drawable.pop_menu_revoke);
                        revokeAction.setActionClickListener(() -> mOnPopActionClickListener.onRevokeMessageClick(msg));
                    }
                }
            }

            multiSelectAction = new ChatPopMenu.ChatPopMenuAction();
            multiSelectAction.setActionName(getContext().getString(R.string.titlebar_mutiselect));
            multiSelectAction.setActionIcon(R.drawable.pop_menu_multi_select);
            multiSelectAction.setActionClickListener(() -> mOnPopActionClickListener.onMultiSelectMessageClick(msg));
        }

        if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            forwardAction = new ChatPopMenu.ChatPopMenuAction();
            forwardAction.setActionName(getContext().getString(R.string.forward_button));
            forwardAction.setActionIcon(R.drawable.pop_menu_forward);
            forwardAction.setActionClickListener(() -> mOnPopActionClickListener.onForwardMessageClick(msg));
        }

        if (textIsAllSelected) {
            if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                replyAction = new ChatPopMenu.ChatPopMenuAction();
                replyAction.setActionName(getContext().getString(R.string.reply_button));
                replyAction.setActionIcon(R.drawable.pop_menu_reply);
                replyAction.setActionClickListener(() -> mOnPopActionClickListener.onReplyMessageClick(msg));

                quoteAction = new ChatPopMenu.ChatPopMenuAction();
                quoteAction.setActionName(getContext().getString(R.string.quote_button));
                quoteAction.setActionIcon(R.drawable.pop_menu_quote);
                quoteAction.setActionClickListener(() -> mOnPopActionClickListener.onQuoteMessageClick(msg));
            }
        }

        if (multiSelectAction != null) {
            multiSelectAction.setPriority(8000);
            mPopActions.add(multiSelectAction);
        }
        if (quoteAction != null && TUIChatConfigs.getConfigs().getGeneralConfig().isQuoteEnable()) {
            quoteAction.setPriority(7000);
            mPopActions.add(quoteAction);
        }
        if (replyAction != null && TUIChatConfigs.getConfigs().getGeneralConfig().isReplyEnable()) {
            replyAction.setPriority(6000);
            mPopActions.add(replyAction);
        }
        if (revokeAction != null) {
            revokeAction.setPriority(5000);
            mPopActions.add(revokeAction);
        }
        if (deleteAction != null) {
            deleteAction.setPriority(4000);
            mPopActions.add(deleteAction);
        }

        if (isDefaultMessage(msg)) {
            if (copyAction != null) {
                copyAction.setPriority(10000);
                mPopActions.add(copyAction);
            }
            if (forwardAction != null) {
                forwardAction.setPriority(9000);
                mPopActions.add(forwardAction);
            }
        }

        mPopActions.addAll(mMorePopActions);
        mPopActions.addAll(getExtensionActions(msg));
        Collections.sort(mPopActions, new Comparator<ChatPopMenu.ChatPopMenuAction>() {
            @Override
            public int compare(ChatPopMenu.ChatPopMenuAction o1, ChatPopMenu.ChatPopMenuAction o2) {
                return o2.getPriority() - o1.getPriority();
            }
        });
    }

    private List<ChatPopMenu.ChatPopMenuAction> getExtensionActions(TUIMessageBean messageBean) {
        List<ChatPopMenu.ChatPopMenuAction> actionList = new ArrayList<>();
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.MessagePopMenu.MESSAGE_BEAN, messageBean);
        param.put(TUIConstants.TUIChat.Extension.MessagePopMenu.ON_POP_CLICK_LISTENER, mOnPopActionClickListener);
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID, param);
        for (TUIExtensionInfo extensionInfo : extensionInfoList) {
            ChatPopMenu.ChatPopMenuAction popMenuAction = new ChatPopMenu.ChatPopMenuAction();
            popMenuAction.setActionIcon((Integer) extensionInfo.getIcon());
            popMenuAction.setActionName(extensionInfo.getText());
            popMenuAction.setPriority(extensionInfo.getWeight());
            popMenuAction.setActionClickListener(new ChatPopMenu.ChatPopMenuAction.OnClickListener() {
                @Override
                public void onClick() {
                    TUIExtensionEventListener eventListener = extensionInfo.getExtensionListener();
                    if (eventListener != null) {
                        eventListener.onClicked(null);
                    }
                }
            });
            actionList.add(popMenuAction);
        }

        return actionList;
    }

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
        if (mAdapter != null) {
            mAdapter.resetSelectableText();
        }
        if (state == RecyclerView.SCROLL_STATE_IDLE) {
            if (mHandler != null) {
                LinearLayoutManager layoutManager = (LinearLayoutManager) getLayoutManager();
                int firstPosition = layoutManager.findFirstCompletelyVisibleItemPosition();
                int lastPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                if (firstPosition == 0 && ((lastPosition - firstPosition + 1) < getAdapter().getItemCount())) {
                    if (getAdapter() instanceof MessageAdapter) {
                        ((MessageAdapter) getAdapter()).showLoading();
                    }
                    mHandler.loadMore(TUIChatConstants.GET_MESSAGE_FORWARD);
                } else if (isLastItemVisibleCompleted()) {
                    if (getAdapter() instanceof MessageAdapter) {
                        ((MessageAdapter) getAdapter()).showLoading();
                    }
                    mHandler.loadMore(TUIChatConstants.GET_MESSAGE_BACKWARD);

                    mHandler.displayBackToLastMessage(false);
                    mHandler.displayBackToNewMessage(false, "", 0);
                    presenter.resetCurrentChatUnreadCount();
                }

                if (isDisplayJumpMessageLayout()) {
                    mHandler.displayBackToLastMessage(true);
                } else {
                    mHandler.displayBackToLastMessage(false);
                }
            }
        } else if (state == RecyclerView.SCROLL_STATE_DRAGGING) {
            if (mHandler != null) {
                mHandler.hideBackToAtMessage();
            }
        }
    }

    public void displayBackToNewMessage(boolean display, String messageId, int count) {
        if (mHandler != null) {
            mHandler.displayBackToNewMessage(display, messageId, count);
        }
    }

    public void scrollToEnd() {
        if (Thread.currentThread() != Looper.getMainLooper().getThread()) {
            ThreadUtils.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    scrollToEnd();
                }
            });
            return;
        }

        if (getAdapter() != null) {
            RecyclerView.LayoutManager layoutManager = getLayoutManager();
            int itemCount = getAdapter().getItemCount();
            if (layoutManager instanceof LinearLayoutManager && itemCount > 0) {
                ((LinearLayoutManager) layoutManager).scrollToPositionWithOffset(itemCount - 1, SCROLL_TO_END_OFFSET);
            }
        }
    }

    @Override
    public void scrollToPosition(int position) {
        if (getAdapter() != null && position < getAdapter().getItemCount()) {
            super.scrollToPosition(position);
        }
    }

    public void smoothScrollToPosition(int position) {
        if (getAdapter() != null && position < getAdapter().getItemCount()) {
            super.smoothScrollToPosition(position);
        }
    }

    public void setHighShowPosition(int position) {
        if (mAdapter != null) {
            mAdapter.setHighShowPosition(position);
        }
    }

    public OnLoadMoreHandler getLoadMoreHandler() {
        return mHandler;
    }

    public void setLoadMoreMessageHandler(OnLoadMoreHandler mHandler) {
        this.mHandler = mHandler;
    }

    public OnEmptySpaceClickListener getEmptySpaceClickListener() {
        return mEmptySpaceClickListener;
    }

    public void setEmptySpaceClickListener(OnEmptySpaceClickListener mEmptySpaceClickListener) {
        this.mEmptySpaceClickListener = mEmptySpaceClickListener;
    }

    public void setPopActionClickListener(OnChatPopActionClickListener listener) {
        mOnPopActionClickListener = listener;
    }

    public void setMenuEmojiOnClickListener(OnMenuEmojiClickListener menuEmojiOnClickListener) {
        this.menuEmojiOnClickListener = menuEmojiOnClickListener;
    }

    public void setAdapterListener() {
        mAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    BeginnerGuidePage.showBeginnerGuideThen(view, new Runnable() {
                        @Override
                        public void run() {
                            mOnItemClickListener.onMessageLongClick(view, position, messageInfo);
                        }
                    });
                }
            }

            @Override
            public void onUserIconClick(View view, int position, TUIMessageBean info) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onUserIconClick(view, position, info);
                }
            }

            @Override
            public void onUserIconLongClick(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onUserIconLongClick(view, position, messageInfo);
                }
            }

            @Override
            public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onReEditRevokeMessage(view, position, messageInfo);
                }
            }

            @Override
            public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onRecallClick(view, position, messageInfo);
                }
            }

            @Override
            public void onReplyMessageClick(View view, int position, TUIMessageBean messageBean) {
                if (messageBean instanceof ReplyMessageBean) {
                    showRootMessageReplyDetail(((ReplyMessageBean) messageBean).getMsgRootId());
                } else if (messageBean instanceof QuoteMessageBean) {
                    locateOriginMessage(((QuoteMessageBean) messageBean).getOriginMsgId());
                }
            }

            @Override
            public void onReplyDetailClick(TUIMessageBean messageBean) {
                showRootMessageReplyDetail(messageBean);
            }

            @Override
            public void onReactOnClick(String emojiId, TUIMessageBean messageBean) {
                presenter.reactMessage(emojiId, messageBean);
            }

            @Override
            public void onSendFailBtnClick(View view, int position, TUIMessageBean messageInfo) {
                new TUIKitDialog(getContext())
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getContext().getString(R.string.resend_tips))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mOnPopActionClickListener.onSendMessageClick(messageInfo, true);
                            }
                        })
                    .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        })
                    .show();
            }

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onTextSelected(view, position, messageInfo);
                }
            }

            @Override
            public void onMessageClick(View view, int position, TUIMessageBean messageBean) {
                if (messageBean instanceof SoundMessageBean) {
                    onSoundMessageClicked((SoundMessageBean) messageBean);
                    return;
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageClick(view, position, messageBean);
                }
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageReadStatusClick(view, messageBean);
                }
            }
        });
    }

    private void onSoundMessageClicked(SoundMessageBean messageBean) {
        soundPlayHandler.removeCallbacksAndMessages(null);
        if (AudioPlayer.getInstance().isPlaying()) {
            AudioPlayer.getInstance().stopPlay();
            soundPlayHandler.removeCallbacksAndMessages(null);
            if (TextUtils.equals(AudioPlayer.getInstance().getPath(), messageBean.getDataPath())) {
                return;
            }
        }
        if (TextUtils.isEmpty(messageBean.getDataPath())) {
            ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.voice_play_tip));
            getSound(messageBean);
            return;
        }

        final boolean needPlayNext = !messageBean.hasPlayed() && !messageBean.isSelf();
        messageBean.setPlaying(true);
        messageBean.setPlayed();
        updateMessageView(messageBean);
        AudioPlayer.getInstance().startPlay(messageBean.getDataPath(), new AudioPlayer.Callback() {
            @Override
            public void onCompletion(Boolean success) {
                messageBean.setPlaying(false);
                updateMessageView(messageBean);
                if (needPlayNext) {
                    soundPlayHandler.postDelayed(() -> playNext(messageBean), SOUND_PLAY_DELAYED);
                }
            }
        });
    }

    private void playNext(SoundMessageBean soundMessageBean) {
        Adapter adapter = getAdapter();
        if (adapter instanceof MessageAdapter) {
            List<TUIMessageBean> messageBeans = ((MessageAdapter) adapter).getDataSource();
            int index = messageBeans.indexOf(soundMessageBean);
            if (index == -1) {
                return;
            }
            for (int i = index + 1; i < messageBeans.size(); i++) {
                TUIMessageBean messageBean = messageBeans.get(i);
                if (messageBean instanceof SoundMessageBean) {
                    if (!((SoundMessageBean) messageBean).hasPlayed()) {
                        onSoundMessageClicked((SoundMessageBean) messageBean);
                        break;
                    }
                }
            }
        }
    }

    private void updateMessageView(TUIMessageBean messageBean) {
        Adapter adapter = getAdapter();
        if (adapter instanceof MessageAdapter) {
            ((MessageAdapter) adapter).onViewNeedRefresh(DATA_CHANGE_TYPE_UPDATE, messageBean);
        }
    }

    private void getSound(final SoundMessageBean messageBean) {
        if (downloadList.contains(messageBean.getUUID())) {
            return;
        }
        downloadList.add(messageBean.getUUID());
        final String path = TUIConfig.getRecordDownloadDir() + messageBean.getUUID();
        File file = new File(path);
        if (!file.exists()) {
            messageBean.downloadSound(path, new SoundMessageBean.SoundDownloadCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.i("downloadSound progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    downloadList.remove(messageBean.getUUID());
                    TUIChatLog.e("getSoundToFile failed code = ", code + ", info = " + desc);
                    ToastUtil.toastLongMessage("getSoundToFile failed code = " + code + ", info = " + desc);
                }

                @Override
                public void onSuccess() {
                    downloadList.remove(messageBean.getUUID());
                    messageBean.setDataPath(path);
                    onSoundMessageClicked(messageBean);
                }
            });
        } else {
            messageBean.setDataPath(path);
        }
    }

    private void locateOriginMessage(String originMsgId) {
        if (TextUtils.isEmpty(originMsgId)) {
            ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
            return;
        }
        presenter.locateMessage(originMsgId, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {}

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
            }
        });
    }

    private void showRootMessageReplyDetail(TUIMessageBean messageBean) {
        if (presenter.getChatInfo() == null) {
            return;
        }
        Intent intent = new Intent(getContext(), MessageReplyDetailActivity.class);
        intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageBean);
        intent.putExtra(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getContext().startActivity(intent);
    }

    private void showRootMessageReplyDetail(String rootMessageId) {
        if (presenter.getChatInfo() == null) {
            return;
        }
        presenter.findMessage(rootMessageId, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                if (data.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
                    ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
                    return;
                }
                Intent intent = new Intent(getContext(), MessageReplyDetailActivity.class);
                intent.putExtra(TUIChatConstants.MESSAGE_BEAN, data);
                intent.putExtra(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getContext().startActivity(intent);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip) + " code = " + errCode + " message = " + errMsg);
            }
        });
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (soundPlayHandler != null) {
            AudioPlayer.getInstance().stopPlay();
            soundPlayHandler.removeCallbacksAndMessages(null);
        }
    }

    @Override
    public int getAvatarRadius() {
        return properties.getAvatarRadius();
    }

    @Override
    public void setAvatarRadius(int radius) {
        properties.setAvatarRadius(radius);
    }

    @Override
    public int[] getAvatarSize() {
        return properties.getAvatarSize();
    }

    @Override
    public void setAvatarSize(int[] size) {
        properties.setAvatarSize(size);
    }

    @Override
    public int getAvatar() {
        return properties.getAvatar();
    }

    @Override
    public void setAvatar(int resId) {
        properties.setAvatar(resId);
    }

    @Override
    public Drawable getRightBubble() {
        return properties.getRightBubble();
    }

    @Override
    public void setRightBubble(Drawable bubble) {
        properties.setRightBubble(bubble);
    }

    @Override
    public Drawable getLeftBubble() {
        return properties.getLeftBubble();
    }

    @Override
    public void setLeftBubble(Drawable bubble) {
        properties.setLeftBubble(bubble);
    }

    @Override
    public int getNameFontSize() {
        return properties.getNameFontSize();
    }

    @Override
    public void setNameFontSize(int size) {
        properties.setNameFontSize(size);
    }

    @Override
    public int getNameFontColor() {
        return properties.getNameFontColor();
    }

    @Override
    public void setNameFontColor(int color) {
        properties.setNameFontColor(color);
    }

    @Override
    public int getLeftNameVisibility() {
        return properties.getLeftNameVisibility();
    }

    @Override
    public void setLeftNameVisibility(int visibility) {
        properties.setLeftNameVisibility(visibility);
    }

    @Override
    public int getRightNameVisibility() {
        return properties.getRightNameVisibility();
    }

    @Override
    public void setRightNameVisibility(int visibility) {
        properties.setRightNameVisibility(visibility);
    }

    @Override
    public int getChatContextFontSize() {
        return properties.getChatContextFontSize();
    }

    @Override
    public void setChatContextFontSize(int size) {
        properties.setChatContextFontSize(size);
    }

    @Override
    public int getRightChatContentFontColor() {
        return properties.getRightChatContentFontColor();
    }

    @Override
    public void setRightChatContentFontColor(int color) {
        properties.setRightChatContentFontColor(color);
    }

    @Override
    public int getLeftChatContentFontColor() {
        return properties.getLeftChatContentFontColor();
    }

    @Override
    public void setLeftChatContentFontColor(int color) {
        properties.setLeftChatContentFontColor(color);
    }

    @Override
    public Drawable getTipsMessageBubble() {
        return properties.getTipsMessageBubble();
    }

    @Override
    public void setTipsMessageBubble(Drawable bubble) {
        properties.setTipsMessageBubble(bubble);
    }

    @Override
    public int getTipsMessageFontSize() {
        return properties.getTipsMessageFontSize();
    }

    @Override
    public void setTipsMessageFontSize(int size) {
        properties.setTipsMessageFontSize(size);
    }

    @Override
    public int getTipsMessageFontColor() {
        return properties.getTipsMessageFontColor();
    }

    @Override
    public void setTipsMessageFontColor(int color) {
        properties.setTipsMessageFontColor(color);
    }

    @Override
    public Drawable getChatTimeBubble() {
        return properties.getChatTimeBubble();
    }

    @Override
    public void setChatTimeBubble(Drawable bubble) {
        properties.setChatTimeBubble(bubble);
    }

    @Override
    public int getChatTimeFontSize() {
        return properties.getChatTimeFontSize();
    }

    @Override
    public void setChatTimeFontSize(int size) {
        properties.setChatTimeFontSize(size);
    }

    @Override
    public int getChatTimeFontColor() {
        return properties.getChatTimeFontColor();
    }

    @Override
    public void setChatTimeFontColor(int color) {
        properties.setChatTimeFontColor(color);
    }

    @Override
    public OnItemClickListener getOnItemClickListener() {
        return mAdapter.getOnItemClickListener();
    }

    @Override
    public void setOnItemClickListener(OnItemClickListener listener) {
        mOnItemClickListener = listener;
        setAdapterListener();
    }

    @Override
    public void setAdapter(MessageAdapter adapter) {
        super.setAdapter(adapter);
        mAdapter = adapter;
    }

    @Override
    public List<ChatPopMenu.ChatPopMenuAction> getPopActions() {
        return mPopActions;
    }

    @Override
    public void addPopAction(ChatPopMenu.ChatPopMenuAction action) {
        mMorePopActions.add(action);
    }

    public void loadMessageFinish() {
        if (mHandler != null) {
            mHandler.loadMessageFinish();
        }
    }

    public void scrollMessageFinish() {
        if (mHandler != null) {
            mHandler.scrollMessageFinish();
        }
    }

    public interface OnMenuEmojiClickListener {
        void onClick(Emoji emoji, TUIMessageBean messageBean);
    }

    public interface OnLoadMoreHandler {
        void loadMore(int type);

        boolean isListEnd(int position);

        void displayBackToLastMessage(boolean display);

        void displayBackToNewMessage(boolean display, String messageId, int count);

        void hideBackToAtMessage();

        void loadMessageFinish();

        void scrollMessageFinish();
    }

    public interface OnEmptySpaceClickListener {
        void onClick();
    }
}
