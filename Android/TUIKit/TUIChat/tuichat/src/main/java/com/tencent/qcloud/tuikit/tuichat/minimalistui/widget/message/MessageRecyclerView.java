package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.MessageProperties;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.face.Emoji;
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
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.IMessageLayout;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopDataHolder;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
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

    // 取一个足够大的偏移保证能一次性滚动到最底部
    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = -999999;

    protected OnItemClickListener mOnItemClickListener;
    protected OnLoadMoreHandler mHandler;
    protected OnEmptySpaceClickListener mEmptySpaceClickListener;
    protected MessageAdapter mAdapter;
    protected List<ChatPopActivity.ChatPopMenuAction> mPopActions = new ArrayList<>();
    protected ChatPopActivity.EmojiOnClickListener emojiOnClickListener;
    private Bitmap dialogBgBitmap;
    protected List<ChatPopActivity.ChatPopMenuAction> mMorePopActions = new ArrayList<>();
    protected OnChatPopActionClickListener mOnPopActionClickListener;
    private final MessageProperties properties = MessageProperties.getInstance();

    private OnMenuEmojiClickListener menuEmojiOnClickListener;

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
        LinearLayoutManager linearLayoutManager = new CustomLinearLayoutManager(getContext());
        linearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        setLayoutManager(linearLayoutManager);
        SimpleItemAnimator animator = (SimpleItemAnimator) getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
        setItemAnimator(null);
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

        emojiOnClickListener = new ChatPopActivity.EmojiOnClickListener() {
            @Override
            public void onClick(Emoji emoji) {
                if (menuEmojiOnClickListener != null) {
                    menuEmojiOnClickListener.onClick(emoji, messageInfo);
                }
            }
        };
        ChatPopDataHolder.setEmojiOnClickListener(emojiOnClickListener);
        ChatPopDataHolder.setActionList(mPopActions);
        Intent intent = new Intent(getContext(), ChatPopActivity.class);
        ActivityOptionsCompat optionsCompat = ActivityOptionsCompat.makeSceneTransitionAnimation(getActivity(), view, "messageAreaTransition");
        Bundle bundle = optionsCompat.toBundle();
        intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageInfo);
        getActivity().startActivity(intent, bundle);
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

        ChatPopActivity.ChatPopMenuAction copyAction = null;
        ChatPopActivity.ChatPopMenuAction forwardAction = null;
        ChatPopActivity.ChatPopMenuAction multiSelectAction = null;
        ChatPopActivity.ChatPopMenuAction quoteAction = null;
        ChatPopActivity.ChatPopMenuAction replyAction = null;
        ChatPopActivity.ChatPopMenuAction revokeAction = null;
        ChatPopActivity.ChatPopMenuAction deleteAction = null;
        ChatPopActivity.ChatPopMenuAction infoAction = null;

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
            copyAction = new ChatPopActivity.ChatPopMenuAction();
            copyAction.setActionName(getContext().getString(R.string.copy_action));
            copyAction.setActionIcon(R.drawable.chat_minimalist_pop_menu_copy);
            copyAction.setActionClickListener(() -> mOnPopActionClickListener.onCopyClick(msg));
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
                    if (timeInterval < TUIChatConfigs.getConfigs().getGeneralConfig().getTimeIntervalForMessageRecall()) {
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
            if (infoAction != null) {
                infoAction.setPriority(2000);
                mPopActions.add(infoAction);
            }
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

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
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
                } else if (isListEnd(lastPosition)) {
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

    private boolean isListEnd(int lastPosition) {
        return mHandler.isListEnd(lastPosition);
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
                    mOnItemClickListener.onMessageLongClick(view, position, messageInfo);
                }
            }

            @Override
            public void onMessageClick(View view, int position, TUIMessageBean messageBean) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onMessageClick(view, position, messageBean);
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
                showMessageReactDetail(messageBean);
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
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onTextSelected(view, position, messageInfo);
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

    private void showMessageReactDetail(TUIMessageBean messageBean) {
        ChatReactDialogFragment fragment = new ChatReactDialogFragment();
        fragment.setMessageBean(messageBean);
        fragment.setChatInfo(presenter.getChatInfo());
        fragment.setOnReactClickListener(new ChatReactDialogFragment.OnReactClickListener() {
            @Override
            public void onClick(String userID, String emojiKey) {
                if (TextUtils.equals(userID, TUILogin.getLoginUser())) {
                    presenter.reactMessage(emojiKey, messageBean);
                }
            }
        });
        fragment.show(getActivity().getSupportFragmentManager(), "react");
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
    public List<ChatPopActivity.ChatPopMenuAction> getPopActions() {
        return mPopActions;
    }

    @Override
    public void addPopAction(ChatPopActivity.ChatPopMenuAction action) {
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
