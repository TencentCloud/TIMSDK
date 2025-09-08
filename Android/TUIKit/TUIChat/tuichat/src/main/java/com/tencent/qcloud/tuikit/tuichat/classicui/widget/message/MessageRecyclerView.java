package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message;

import android.content.Context;
import android.content.Intent;
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
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.SelectionHelper;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.component.scroller.CenteredSmoothScroller;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnChatPopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.MessageReplyDetailActivity;
import com.tencent.qcloud.tuikit.tuichat.component.audio.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.config.classicui.TUIChatConfigClassic;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.interfaces.OnEmptySpaceClickListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.OnGestureScrollListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MessageRecyclerView extends RecyclerView implements IMessageRecyclerView {
    private static final String TAG = MessageRecyclerView.class.getSimpleName();

    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = -999999;
    private static final int SOUND_PLAY_DELAYED = 500;

    protected OnItemClickListener mOnItemClickListener;
    protected MessageRecyclerView.ChatDelegate chatDelegate;
    protected OnEmptySpaceClickListener mEmptySpaceClickListener;
    protected OnGestureScrollListener onGestureScrollListener;
    protected MessageAdapter mAdapter;
    protected LinearLayoutManager linearLayoutManager;
    protected List<ChatPopMenu.ChatPopMenuAction> mPopActions = new ArrayList<>();
    protected List<ChatPopMenu.ChatPopMenuAction> mMorePopActions = new ArrayList<>();
    protected OnChatPopActionClickListener mOnPopActionClickListener;

    private TUIValueCallback downloadSoundCallback;
    private ChatPresenter presenter;

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
        linearLayoutManager = new CustomLinearLayoutManager(getContext());
        linearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        setLayoutManager(linearLayoutManager);
        SimpleItemAnimator animator = (SimpleItemAnimator) getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
        setClickEmptySpaceEvent();
        addOnLayoutChangeListener(new OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                // When the view above the message list expands, scroll down the corresponding distance.
                int oldHeight = oldBottom - oldTop;
                int newHeight = bottom - top;
                if (oldHeight != 0 && oldHeight > newHeight && oldTop < top) {
                    scrollBy(0, oldHeight - newHeight);
                }
            }
        });
    }

    // Always return last visible item for laying out other items from tail to head.
    @Override
    public View getFocusedChild() {
        if (linearLayoutManager != null) {
            int position = linearLayoutManager.findLastVisibleItemPosition();
            return linearLayoutManager.findViewByPosition(position);
        }
        return super.getFocusedChild();
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

            @Override
            public boolean onDown(MotionEvent e) {
                if (mEmptySpaceClickListener != null) {
                    mEmptySpaceClickListener.onClick();
                    return true;
                }
                return false;
            }

            @Override
            public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
                if (onGestureScrollListener != null) {
                    onGestureScrollListener.onScroll(e1, e2, distanceX, distanceY);
                }
                return super.onScroll(e1, e2, distanceX, distanceY);
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

    public void showItemPopMenu(final TUIMessageBean messageInfo, View view) {
        initPopActions(messageInfo);

        if (mChatPopMenu != null) {
            mChatPopMenu.hide();
            mChatPopMenu = null;
        }
        mChatPopMenu = new ChatPopMenu(getContext());
        mChatPopMenu.setMessageBean(messageInfo);
        mChatPopMenu.setShowFaces(TUIChatConfigClassic.isEnableEmojiReaction() && getChatInfo().isPopMenuEnableExtension());
        mChatPopMenu.setChatPopMenuActionList(mPopActions);

        int[] location = new int[2];
        getLocationOnScreen(location);
        mChatPopMenu.setEmptySpaceClickListener(new OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                SelectionHelper.resetSelected();
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

        final boolean textIsAllSelected = isTextIsAllSelected(msg);

        final ChatPopMenu.ChatPopMenuAction speakerModeSwitchAction = createSpeakerModeSwitchAction(msg);
        final ChatPopMenu.ChatPopMenuAction copyAction = createCopyAction(msg);
        final ChatPopMenu.ChatPopMenuAction forwardAction = createForwardAction(msg);
        final ChatPopMenu.ChatPopMenuAction multiSelectAction = createMultiSelectAction(msg, textIsAllSelected);
        final ChatPopMenu.ChatPopMenuAction quoteAction = createQuoteAction(msg, textIsAllSelected);
        final ChatPopMenu.ChatPopMenuAction replyAction = createReplyAction(msg, textIsAllSelected);
        final ChatPopMenu.ChatPopMenuAction revokeAction = createRevokeAction(msg, textIsAllSelected);
        final ChatPopMenu.ChatPopMenuAction deleteAction = createDeleteAction(msg, textIsAllSelected);
        final ChatPopMenu.ChatPopMenuAction groupPinAction = getChatPopMenuAction(msg);

        addActionIfEnabled(groupPinAction, TUIChatConfigClassic.isEnablePin() && getChatInfo().isPopMenuEnablePin(), 3000);
        addActionIfEnabled(speakerModeSwitchAction, TUIChatConfigClassic.isEnableSpeakerModeSwitch(), 11000);
        addActionIfEnabled(
            multiSelectAction, TUIChatConfigClassic.isEnableSelect() && getChatInfo().isPopMenuEnableMultiSelect() && !msg.hasRiskContent(), 8000);
        addActionIfEnabled(quoteAction, TUIChatConfigClassic.isEnableQuote() && getChatInfo().isPopMenuEnableQuote() && !msg.hasRiskContent(), 7000);
        addActionIfEnabled(replyAction, TUIChatConfigClassic.isEnableReply() && getChatInfo().isPopMenuEnableReply() && !msg.hasRiskContent(), 6000);
        addActionIfEnabled(revokeAction, TUIChatConfigClassic.isEnableRecall() && getChatInfo().isPopMenuEnableRevoke(), 5000);
        addActionIfEnabled(deleteAction, TUIChatConfigClassic.isEnableDelete() && getChatInfo().isPopMenuEnableDelete(), 4000);

        addDefaultMessageActions(msg, copyAction, forwardAction);

        mPopActions.addAll(mMorePopActions);
        if (getChatInfo().isPopMenuEnableExtension()) {
            mPopActions.addAll(getExtensionActions(msg));
        }

        Collections.sort(mPopActions, (o1, o2) -> o2.getPriority() - o1.getPriority());
    }

    private ChatPopMenu.ChatPopMenuAction createSpeakerModeSwitchAction(TUIMessageBean msg) {
        if (!(msg instanceof SoundMessageBean)) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        boolean isSpeakerMode = TUIChatConfigs.getGeneralConfig().isEnableSoundMessageSpeakerMode();

        int actionIcon = isSpeakerMode ? R.drawable.pop_menu_ear : R.drawable.pop_menu_speaker;
        String actionName =
            isSpeakerMode ? getContext().getString(R.string.chat_speaker_mode_off_action) : getContext().getString(R.string.chat_speaker_mode_on_action);

        action.setActionIcon(actionIcon);
        action.setActionName(actionName);
        action.setActionClickListener(() -> mOnPopActionClickListener.onSpeakerModeSwitchClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createCopyAction(TUIMessageBean msg) {
        if (!(msg instanceof TextMessageBean || msg instanceof QuoteMessageBean)) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.copy_action));
        action.setActionIcon(R.drawable.pop_menu_copy);
        action.setActionClickListener(() -> mOnPopActionClickListener.onCopyClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createForwardAction(TUIMessageBean msg) {
        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL || msg.hasRiskContent()) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.forward_button));
        action.setActionIcon(R.drawable.pop_menu_forward);
        action.setActionClickListener(() -> mOnPopActionClickListener.onForwardMessageClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createMultiSelectAction(TUIMessageBean msg, boolean textIsAllSelected) {
        if (!textIsAllSelected) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.titlebar_mutiselect));
        action.setActionIcon(R.drawable.pop_menu_multi_select);
        action.setActionClickListener(() -> mOnPopActionClickListener.onMultiSelectMessageClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createQuoteAction(TUIMessageBean msg, boolean textIsAllSelected) {
        if (!textIsAllSelected || msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.quote_button));
        action.setActionIcon(R.drawable.pop_menu_quote);
        action.setActionClickListener(() -> mOnPopActionClickListener.onQuoteMessageClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createReplyAction(TUIMessageBean msg, boolean textIsAllSelected) {
        if (!textIsAllSelected || msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.reply_button));
        action.setActionIcon(R.drawable.pop_menu_reply);
        action.setActionClickListener(() -> mOnPopActionClickListener.onReplyMessageClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createRevokeAction(TUIMessageBean msg, boolean textIsAllSelected) {
        if (!textIsAllSelected || !msg.isSelf() || msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            return null;
        }

        long timeInterval = TUIChatUtils.getServerTime() - msg.getMessageTime();
        if (timeInterval >= TUIChatConfigClassic.getTimeIntervalForAllowedMessageRecall()) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.revoke_action));
        action.setActionIcon(R.drawable.pop_menu_revoke);
        action.setActionClickListener(() -> mOnPopActionClickListener.onRevokeMessageClick(msg));
        return action;
    }

    private ChatPopMenu.ChatPopMenuAction createDeleteAction(TUIMessageBean msg, boolean textIsAllSelected) {
        if (!textIsAllSelected) {
            return null;
        }

        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        action.setActionName(getContext().getString(R.string.delete_action));
        action.setActionIcon(R.drawable.pop_menu_delete);
        action.setActionClickListener(() -> mOnPopActionClickListener.onDeleteMessageClick(msg));
        return action;
    }

    private void addActionIfEnabled(ChatPopMenu.ChatPopMenuAction action, boolean enabled, int priority) {
        if (action != null && enabled) {
            action.setPriority(priority);
            mPopActions.add(action);
        }
    }

    private void addDefaultMessageActions(TUIMessageBean msg, ChatPopMenu.ChatPopMenuAction copyAction, ChatPopMenu.ChatPopMenuAction forwardAction) {
        if (!isDefaultMessage(msg)) {
            return;
        }

        if (copyAction != null && TUIChatConfigClassic.isEnableCopy() && getChatInfo().isPopMenuEnableCopy() && !msg.hasRiskContent()) {
            copyAction.setPriority(10000);
            mPopActions.add(copyAction);
        }

        if (forwardAction != null && TUIChatConfigClassic.isEnableForward() && getChatInfo().isPopMenuEnableForward()) {
            forwardAction.setPriority(9000);
            mPopActions.add(forwardAction);
        }
    }

    private static boolean isTextIsAllSelected(TUIMessageBean msg) {
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
        return textIsAllSelected;
    }

    private ChatPopMenu.ChatPopMenuAction getChatPopMenuAction(TUIMessageBean msg) {
        ChatPopMenu.ChatPopMenuAction groupPinAction = null;

        if (presenter instanceof GroupChatPresenter && TUIChatConfigs.getGeneralConfig().isEnableGroupChatPinMessage()
            && ((GroupChatPresenter) presenter).canPinnedMessage() && msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL
            && msg.getStatus() != TUIMessageBean.MSG_STATUS_SENDING && !msg.hasRiskContent()) {
            groupPinAction = new ChatPopMenu.ChatPopMenuAction();
            if (((GroupChatPresenter) presenter).isMessagePinned(msg.getId())) {
                groupPinAction.setActionName(getContext().getResources().getString(R.string.chat_group_unpin_message));
                groupPinAction.setActionIcon(R.drawable.chat_pop_menu_cancel_pin);
                groupPinAction.setActionClickListener(new ChatPopMenu.ChatPopMenuAction.OnClickListener() {
                    @Override
                    public void onClick() {
                        ((GroupChatPresenter) presenter).unpinnedMessage(msg, new TUICallback() {
                            @Override
                            public void onSuccess() {
                                // do nothing
                            }

                            @Override
                            public void onError(int errorCode, String errorMessage) {
                                ToastUtil.toastShortMessage(errorMessage);
                            }
                        });
                    }
                });
            } else {
                groupPinAction.setActionName(getContext().getResources().getString(R.string.chat_group_pin_message));
                groupPinAction.setActionIcon(R.drawable.chat_pop_menu_pin);
                groupPinAction.setActionClickListener(new ChatPopMenu.ChatPopMenuAction.OnClickListener() {
                    @Override
                    public void onClick() {
                        ((GroupChatPresenter) presenter).pinnedMessage(msg, new TUICallback() {
                            @Override
                            public void onSuccess() {
                                // do nothing
                            }

                            @Override
                            public void onError(int errorCode, String errorMessage) {
                                ToastUtil.toastShortMessage(errorMessage);
                            }
                        });
                    }
                });
            }
        }
        return groupPinAction;
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

    public void displayBackToNewMessage(boolean display, String messageId, int count) {
        if (chatDelegate != null) {
            chatDelegate.displayBackToNewMessage(display, messageId, count);
        }
    }

    @Override
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

    public void smoothScrollToPosition(int position) {
        if (getAdapter() != null && position < getAdapter().getItemCount()) {
            CenteredSmoothScroller smoothScroller = new CenteredSmoothScroller(getContext());
            smoothScroller.setTargetPosition(position);
            RecyclerView.LayoutManager layoutManager = getLayoutManager();
            if (layoutManager != null) {
                layoutManager.startSmoothScroll(smoothScroller);
            }
        }
    }

    public void setChatDelegate(ChatDelegate chatDelegate) {
        this.chatDelegate = chatDelegate;
    }

    public void setEmptySpaceClickListener(OnEmptySpaceClickListener mEmptySpaceClickListener) {
        this.mEmptySpaceClickListener = mEmptySpaceClickListener;
    }

    public void setOnGestureScrollListener(OnGestureScrollListener onGestureScrollListener) {
        this.onGestureScrollListener = onGestureScrollListener;
    }

    public void setPopActionClickListener(OnChatPopActionClickListener listener) {
        mOnPopActionClickListener = listener;
    }

    public void setAdapterListener() {
        mAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, TUIMessageBean messageInfo) {
                if (TUIChatUtils.chatEventOnMessageLongClicked(view, messageInfo)) {
                    return;
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageLongClick(view, messageInfo);
                }
            }

            @Override
            public void onMessageClick(View view, TUIMessageBean messageBean) {
                if (TUIChatUtils.chatEventOnMessageClicked(view, messageBean)) {
                    return;
                }

                if (chatDelegate != null) {
                    chatDelegate.hideSoftInput();
                }
                if (messageBean instanceof SoundMessageBean) {
                    onSoundMessageClicked((SoundMessageBean) messageBean);
                    return;
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageClick(view, messageBean);
                }
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageReadStatusClick(view, messageBean);
                }
            }

            @Override
            public void onUserIconClick(View view, TUIMessageBean messageBean) {
                if (TUIChatUtils.chatEventOnUserIconClicked(view, messageBean)) {
                    return;
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onUserIconClick(view, messageBean);
                }
            }

            @Override
            public void onUserIconLongClick(View view, TUIMessageBean messageInfo) {
                if (TUIChatUtils.chatEventOnUserIconLongClicked(view, messageInfo)) {
                    return;
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onUserIconLongClick(view, messageInfo);
                }
            }

            @Override
            public void onReEditRevokeMessage(View view, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onReEditRevokeMessage(view, messageInfo);
                }
            }

            @Override
            public void onRecallClick(View view, TUIMessageBean messageInfo) {
                if (TUIChatUtils.chatEventOnMessageClicked(view, messageInfo)) {
                    return;
                }
                if (chatDelegate != null) {
                    chatDelegate.hideSoftInput();
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onRecallClick(view, messageInfo);
                }
            }

            @Override
            public void onReplyMessageClick(View view, TUIMessageBean messageBean) {
                if (TUIChatUtils.chatEventOnMessageClicked(view, messageBean)) {
                    return;
                }
                if (messageBean instanceof ReplyMessageBean) {
                    showRootMessageReplyDetail(((ReplyMessageBean) messageBean).getMsgRootId());
                } else if (messageBean instanceof QuoteMessageBean) {
                    presenter.locateQuoteOriginMessage((QuoteMessageBean) messageBean);
                }
            }

            @Override
            public void onReplyDetailClick(TUIMessageBean messageBean) {
                showRootMessageReplyDetail(messageBean);
            }

            @Override
            public void onSendFailBtnClick(View view, TUIMessageBean messageInfo) {
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
                if (TUIChatUtils.chatEventOnMessageLongClicked(view, messageInfo)) {
                    return;
                }
                showItemPopMenu(messageInfo, view);
            }
        });
    }

    private void onSoundMessageClicked(SoundMessageBean messageBean) {
        soundPlayHandler.removeCallbacksAndMessages(null);
        String soundPath = ChatFileDownloadPresenter.getSoundPath(messageBean);
        if (AudioPlayer.getInstance().isPlaying()) {
            AudioPlayer.getInstance().stopPlay();
            soundPlayHandler.removeCallbacksAndMessages(null);
            if (TextUtils.equals(AudioPlayer.getInstance().getPath(), soundPath)) {
                return;
            }
        }
        if (!FileUtil.isFileExists(soundPath)) {
            ToastUtil.toastShortMessage(TUIChatService.getAppContext().getString(R.string.voice_play_tip));
            getSound(messageBean);
            return;
        }

        final boolean needPlayNext = !messageBean.hasPlayed() && !messageBean.isSelf();
        messageBean.setPlaying(true);
        messageBean.setPlayed();
        updateMessageView(messageBean);
        AudioPlayer.getInstance().startPlay(soundPath, new AudioPlayer.Callback() {
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
        ThreadUtils.runOnUiThread(() -> {
            Adapter adapter = getAdapter();
            if (adapter instanceof MessageAdapter) {
                ((MessageAdapter) adapter).onViewNeedRefresh(DATA_CHANGE_TYPE_UPDATE, messageBean);
            }
        });
    }

    private void getSound(final SoundMessageBean messageBean) {
        downloadSoundCallback = new TUIValueCallback() {
            @Override
            public void onSuccess(Object object) {
                onSoundMessageClicked(messageBean);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e("getSound failed code = ", errorCode + ", info = " + errorMessage);
                ToastUtil.toastLongMessage(ErrorMessageConverter.convertIMError(errorCode, errorMessage));
            }

            @Override
            public void onProgress(long current, long total) {
                TUIChatLog.d("getSound progress current:", current + ", total:" + total);
            }
        };
        ChatFileDownloadPresenter.downloadSound(messageBean, downloadSoundCallback);
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
        TUIMessageBean messageBean = presenter.getLoadedMessage(rootMessageId);
        if (messageBean != null) {
            showMessageReplyDetail(messageBean);
        } else {
            presenter.findMessage(rootMessageId, new IUIKitCallback<TUIMessageBean>() {
                @Override
                public void onSuccess(TUIMessageBean data) {
                    showMessageReplyDetail(data);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
                }
            });
        }
    }

    private void showMessageReplyDetail(TUIMessageBean messageBean) {
        if (messageBean.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
            return;
        }
        Intent intent = new Intent(getContext(), MessageReplyDetailActivity.class);
        intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageBean);
        intent.putExtra(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getContext().startActivity(intent);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (soundPlayHandler != null) {
            AudioPlayer.getInstance().stopPlay();
            soundPlayHandler.removeCallbacksAndMessages(null);
        }
    }

    public OnItemClickListener getOnItemClickListener() {
        return mAdapter.getOnItemClickListener();
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mOnItemClickListener = listener;
        setAdapterListener();
    }

    public void setAdapter(MessageAdapter adapter) {
        super.setAdapter(adapter);
        mAdapter = adapter;
    }

    private ChatInfo getChatInfo() {
        return presenter.getChatInfo();
    }

    public void loadMessageFinish() {
        if (chatDelegate != null) {
            chatDelegate.loadMessageFinish();
        }
    }

    public void scrollMessageFinish() {
        if (chatDelegate != null) {
            chatDelegate.scrollMessageFinish();
        }
    }

    public interface ChatDelegate {
        void displayBackToNewMessage(boolean display, String messageId, int count);

        void loadMessageFinish();

        void scrollMessageFinish();

        void hideSoftInput();
    }
}
