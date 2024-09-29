package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityOptionsCompat;
import androidx.core.app.SharedElementCallback;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnChatPopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.config.minimalistui.TUIChatConfigMinimalist;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.interfaces.OnEmptySpaceClickListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.OnGestureScrollListener;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.IMessageLayout;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopDataHolder;
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

public class MessageRecyclerView extends RecyclerView implements IMessageRecyclerView, IMessageLayout {
    private static final String TAG = MessageRecyclerView.class.getSimpleName();

    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = -999999;

    protected OnItemClickListener mOnItemClickListener;
    protected ChatDelegate chatDelegate;
    protected OnEmptySpaceClickListener mEmptySpaceClickListener;
    protected OnGestureScrollListener onGestureScrollListener;
    protected MessageAdapter mAdapter;
    protected LinearLayoutManager linearLayoutManager;
    protected List<ChatPopActivity.ChatPopMenuAction> mPopActions = new ArrayList<>();
    protected List<ChatPopActivity.ChatPopMenuAction> mMorePopActions = new ArrayList<>();
    protected OnChatPopActionClickListener mOnPopActionClickListener;

    private ChatPresenter presenter;

    private int mSelectedPosition = -1;

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
        setItemAnimator(null);
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

    // Always return last visible item for laying out other items from tail to head.
    @Override
    public View getFocusedChild() {
        if (linearLayoutManager != null) {
            int position = linearLayoutManager.findLastVisibleItemPosition();
            return linearLayoutManager.findViewByPosition(position);
        }
        return super.getFocusedChild();
    }

    public void setSelectedPosition(int position) {
        this.mSelectedPosition = position;
    }

    public int getSelectedPosition() {
        return mSelectedPosition;
    }

    public void showItemPopMenu(final TUIMessageBean messageInfo, View view) {
        initPopActions(messageInfo);

        stopScroll();
        ChatPopDataHolder.setMsgAreaBackground(view.getBackground());
        if (messageInfo instanceof ImageMessageBean || messageInfo instanceof VideoMessageBean) {
            RoundCornerImageView roundCornerImageView = view.findViewById(R.id.content_image_iv);
            ChatPopDataHolder.setImageMessageView(roundCornerImageView);
        }
        Rect rect = new Rect();
        int[] location = new int[2];
        view.getLocationInWindow(location);
        rect.left = location[0];
        rect.top = location[1];
        rect.right = rect.left + view.getWidth();
        rect.bottom = rect.top + view.getHeight();
        ChatPopDataHolder.setMessageViewGlobalRect(rect);
        view.setVisibility(INVISIBLE);
        View decorView = ((Activity) getContext()).getWindow().getDecorView();
        Bitmap dialogBgBitmap = Bitmap.createBitmap(decorView.getWidth(), decorView.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas();
        canvas.setBitmap(dialogBgBitmap);
        decorView.draw(canvas);
        canvas.drawColor(Color.WHITE, PorterDuff.Mode.DST_OVER);
        ChatPopDataHolder.setChatPopBgBitmap(dialogBgBitmap);

        ChatPopDataHolder.setActionList(mPopActions);
        Intent intent = new Intent(getContext(), ChatPopActivity.class);
        ActivityOptionsCompat optionsCompat = ActivityOptionsCompat.makeSceneTransitionAnimation(getActivity(), view, "messageAreaTransition");
        Bundle bundle = optionsCompat.toBundle();
        intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageInfo);
        getActivity().startActivity(intent, bundle);
        getActivity().setExitSharedElementCallback(new SharedElementCallback() {
            @Override
            public void onSharedElementEnd(List<String> sharedElementNames, List<View> sharedElements, List<View> sharedElementSnapshots) {
                TUIChatService.getInstance().refreshMessage(messageInfo);
                getActivity().setExitSharedElementCallback((SharedElementCallback) null);
            }
        });
    }

    public AppCompatActivity getActivity() {
        return (AppCompatActivity) getContext();
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

        ChatPopActivity.ChatPopMenuAction speakerModeSwitchAction = null;
        ChatPopActivity.ChatPopMenuAction copyAction = null;
        ChatPopActivity.ChatPopMenuAction forwardAction = null;
        ChatPopActivity.ChatPopMenuAction multiSelectAction = null;
        ChatPopActivity.ChatPopMenuAction quoteAction = null;
        ChatPopActivity.ChatPopMenuAction replyAction = null;
        ChatPopActivity.ChatPopMenuAction revokeAction = null;
        ChatPopActivity.ChatPopMenuAction deleteAction = null;
        ChatPopActivity.ChatPopMenuAction infoAction = null;

        boolean textIsAllSelected = isTextIsAllSelected(msg);

        if (msg instanceof TextMessageBean || msg instanceof QuoteMessageBean) {
            copyAction = new ChatPopActivity.ChatPopMenuAction();
            copyAction.setActionName(getContext().getString(R.string.copy_action));
            copyAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_copy);
            copyAction.setActionClickListener(() -> mOnPopActionClickListener.onCopyClick(msg));
        }

        if (msg instanceof SoundMessageBean) {
            speakerModeSwitchAction = new ChatPopActivity.ChatPopMenuAction();
            int actionIcon = R.drawable.chat_minimalist_pop_menu_speaker;
            String actionName = getContext().getString(R.string.chat_speaker_mode_on_action);
            boolean isSpeakerMode = TUIChatConfigs.getGeneralConfig().isEnableSoundMessageSpeakerMode();
            if (isSpeakerMode) {
                actionIcon = R.drawable.chat_minimalist_pop_menu_ear;
                actionName = getContext().getString(R.string.chat_speaker_mode_off_action);
            }
            speakerModeSwitchAction.setActionIcon(actionIcon);
            speakerModeSwitchAction.setActionName(actionName);
            speakerModeSwitchAction.setActionClickListener(() -> mOnPopActionClickListener.onSpeakerModeSwitchClick(msg));
        }

        if (textIsAllSelected) {
            deleteAction = new ChatPopActivity.ChatPopMenuAction();
            deleteAction.setActionName(getContext().getString(R.string.delete_action));
            deleteAction.setTextColor(0xFFFF584C);
            deleteAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_delete);
            deleteAction.setActionClickListener(() -> mOnPopActionClickListener.onDeleteMessageClick(msg));
            if (msg.isSelf()) {
                if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                    long timeInterval = TUIChatUtils.getServerTime() - msg.getMessageTime();
                    if (timeInterval < TUIChatConfigMinimalist.getTimeIntervalForAllowedMessageRecall()) {
                        revokeAction = new ChatPopActivity.ChatPopMenuAction();
                        revokeAction.setActionName(getContext().getString(R.string.revoke_action));
                        revokeAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_revoke);
                        revokeAction.setActionClickListener(() -> mOnPopActionClickListener.onRevokeMessageClick(msg));
                    }
                }

                infoAction = new ChatPopActivity.ChatPopMenuAction();
                infoAction.setActionName(getContext().getString(R.string.info_button));
                infoAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_info);
                infoAction.setActionClickListener(() -> mOnPopActionClickListener.onInfoMessageClick(msg));
            }

            multiSelectAction = new ChatPopActivity.ChatPopMenuAction();
            multiSelectAction.setActionName(getContext().getString(R.string.titlebar_mutiselect));
            multiSelectAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_multi_select);
            multiSelectAction.setActionClickListener(() -> mOnPopActionClickListener.onMultiSelectMessageClick(msg));
        }

        if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            forwardAction = new ChatPopActivity.ChatPopMenuAction();
            forwardAction.setActionName(getContext().getString(R.string.forward_button));
            forwardAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_forward);
            forwardAction.setActionClickListener(() -> mOnPopActionClickListener.onForwardMessageClick(msg));
        }

        if (textIsAllSelected) {
            if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                replyAction = new ChatPopActivity.ChatPopMenuAction();
                replyAction.setActionName(getContext().getString(R.string.reply_button));
                replyAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_reply);
                replyAction.setActionClickListener(() -> mOnPopActionClickListener.onReplyMessageClick(msg));

                quoteAction = new ChatPopActivity.ChatPopMenuAction();
                quoteAction.setActionName(getContext().getString(R.string.quote_button));
                quoteAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_quote);
                quoteAction.setActionClickListener(() -> mOnPopActionClickListener.onQuoteMessageClick(msg));
            }
        }

        if (speakerModeSwitchAction != null && TUIChatConfigMinimalist.isEnableSpeakerModeSwitch()) {
            speakerModeSwitchAction.setPriority(11000);
            mPopActions.add(speakerModeSwitchAction);
        }
        if (multiSelectAction != null && TUIChatConfigMinimalist.isEnableSelect() && !msg.hasRiskContent()) {
            multiSelectAction.setPriority(8000);
            mPopActions.add(multiSelectAction);
        }
        if (quoteAction != null && TUIChatConfigMinimalist.isEnableQuote() && !msg.hasRiskContent()) {
            quoteAction.setPriority(7000);
            mPopActions.add(quoteAction);
        }
        if (replyAction != null && TUIChatConfigMinimalist.isEnableReply() && !msg.hasRiskContent()) {
            replyAction.setPriority(6000);
            mPopActions.add(replyAction);
        }
        if (revokeAction != null && TUIChatConfigMinimalist.isEnableRecall()) {
            revokeAction.setPriority(5000);
            mPopActions.add(revokeAction);
        }
        if (deleteAction != null && TUIChatConfigMinimalist.isEnableDelete()) {
            deleteAction.setPriority(4000);
            mPopActions.add(deleteAction);
        }

        if (isDefaultMessage(msg)) {
            if (copyAction != null && TUIChatConfigMinimalist.isEnableCopy() && !msg.hasRiskContent()) {
                copyAction.setPriority(10000);
                mPopActions.add(copyAction);
            }
            if (forwardAction != null && TUIChatConfigMinimalist.isEnableForward()) {
                forwardAction.setPriority(9000);
                mPopActions.add(forwardAction);
            }
            if (infoAction != null && TUIChatConfigMinimalist.isEnableInfo()  && !msg.hasRiskContent()) {
                infoAction.setPriority(2000);
                mPopActions.add(infoAction);
            }
        }

        ChatPopActivity.ChatPopMenuAction groupPinAction = getChatPopMenuPinAction(msg);
        if (groupPinAction != null && TUIChatConfigMinimalist.isEnablePin()) {
            groupPinAction.setPriority(3000);
            mPopActions.add(groupPinAction);
        }

        mPopActions.addAll(mMorePopActions);
        mPopActions.addAll(getExtensionActions(msg));
        Collections.sort(mPopActions, new Comparator<ChatPopActivity.ChatPopMenuAction>() {
            @Override
            public int compare(ChatPopActivity.ChatPopMenuAction o1, ChatPopActivity.ChatPopMenuAction o2) {
                return o2.getPriority() - o1.getPriority();
            }
        });
    }

    private ChatPopActivity.ChatPopMenuAction getChatPopMenuPinAction(TUIMessageBean msg) {
        ChatPopActivity.ChatPopMenuAction groupPinAction = null;
        if (presenter instanceof GroupChatPresenter && TUIChatConfigs.getGeneralConfig().isEnableGroupChatPinMessage()
            && ((GroupChatPresenter) presenter).canPinnedMessage() && msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL
                && msg.getStatus() != TUIMessageBean.MSG_STATUS_SENDING && !msg.hasRiskContent()) {
            groupPinAction = new ChatPopActivity.ChatPopMenuAction();
            if (((GroupChatPresenter) presenter).isMessagePinned(msg.getId())) {
                groupPinAction.setActionName(getContext().getResources().getString(R.string.chat_group_unpin_message));
                groupPinAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_cancel_pin);
                groupPinAction.setActionClickListener(new ChatPopActivity.ChatPopMenuAction.OnClickListener() {
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
                groupPinAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_pin);
                groupPinAction.setActionClickListener(new ChatPopActivity.ChatPopMenuAction.OnClickListener() {
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

    private List<ChatPopActivity.ChatPopMenuAction> getExtensionActions(TUIMessageBean messageBean) {
        List<ChatPopActivity.ChatPopMenuAction> actionList = new ArrayList<>();
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.MessagePopMenu.MESSAGE_BEAN, messageBean);
        param.put(TUIConstants.TUIChat.Extension.MessagePopMenu.ON_POP_CLICK_LISTENER, mOnPopActionClickListener);
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.MessagePopMenu.MINIMALIST_EXTENSION_ID, param);
        for (TUIExtensionInfo extensionInfo : extensionInfoList) {
            ChatPopActivity.ChatPopMenuAction popMenuAction = new ChatPopActivity.ChatPopMenuAction();
            popMenuAction.setActionIcon((Integer) extensionInfo.getIcon());
            popMenuAction.setActionName(extensionInfo.getText());
            popMenuAction.setPriority(extensionInfo.getWeight());
            popMenuAction.setActionClickListener(new ChatPopActivity.ChatPopMenuAction.OnClickListener() {
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
            LayoutManager layoutManager = getLayoutManager();
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

    public void setChatDelegate(ChatDelegate chatDelegate) {
        this.chatDelegate = chatDelegate;
    }

    public OnEmptySpaceClickListener getEmptySpaceClickListener() {
        return mEmptySpaceClickListener;
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
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageClick(view, messageBean);
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
            public void onUserIconLongClick(View view, TUIMessageBean messageBean) {
                if (TUIChatUtils.chatEventOnUserIconLongClicked(view, messageBean)) {
                    return;
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onUserIconLongClick(view, messageBean);
                }
            }

            @Override
            public void onReEditRevokeMessage(View view, TUIMessageBean messageBean) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onReEditRevokeMessage(view, messageBean);
                }
            }

            @Override
            public void onRecallClick(View view, TUIMessageBean messageBean) {
                if (TUIChatUtils.chatEventOnMessageClicked(view, messageBean)) {
                    return;
                }
                if (chatDelegate != null) {
                    chatDelegate.hideSoftInput();
                }
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onRecallClick(view, messageBean);
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
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mOnPopActionClickListener.onSendMessageClick(messageInfo, true);
                            }
                        })
                    .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        })
                    .show();
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                if (mOnItemClickListener != null && messageBean.isSelf()) {
                    mOnItemClickListener.onMessageReadStatusClick(view, messageBean);
                }
            }
        });
    }

    private void showRootMessageReplyDetail(TUIMessageBean messageBean) {
        ChatReplyDialogFragment replyDialogFragment = new ChatReplyDialogFragment();
        replyDialogFragment.setOriginMessage(messageBean);
        replyDialogFragment.setChatInfo(presenter.getChatInfo());
        replyDialogFragment.show(getActivity().getSupportFragmentManager(), "reply");
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
                ChatReplyDialogFragment replyDialogFragment = new ChatReplyDialogFragment();
                replyDialogFragment.setOriginMessage(data);
                replyDialogFragment.setChatInfo(presenter.getChatInfo());
                replyDialogFragment.show(getActivity().getSupportFragmentManager(), "reply");
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip) + " code = " + errCode + " message = " + errMsg);
            }
        });
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
    public List<ChatPopActivity.ChatPopMenuAction> getPopActions() {
        return mPopActions;
    }

    @Override
    public void addPopAction(ChatPopActivity.ChatPopMenuAction action) {
        mMorePopActions.add(action);
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
        void displayBackToLastMessage(boolean display);

        void displayBackToNewMessage(boolean display, String messageId, int count);

        void loadMessageFinish();

        void scrollMessageFinish();

        void hideSoftInput();
    }
}
