package com.tencent.qcloud.tuikit.tuichat.ui.view.message;

import android.content.ClipData;
import android.content.Context;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;

import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageProperties;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.IMessageLayout;
import com.tencent.qcloud.tuikit.tuichat.ui.view.ChatView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.List;

public class MessageRecyclerView extends RecyclerView implements IMessageLayout {
    private static final String TAG = MessageRecyclerView.class.getSimpleName();

    public static final int DATA_CHANGE_TYPE_REFRESH = 0;
    public static final int DATA_CHANGE_TYPE_LOAD = 1;
    public static final int DATA_CHANGE_TYPE_ADD_FRONT = 2;
    public static final int DATA_CHANGE_TYPE_ADD_BACK = 3;
    public static final int DATA_CHANGE_TYPE_UPDATE = 4;
    public static final int DATA_CHANGE_TYPE_DELETE = 5;
    public static final int DATA_CHANGE_TYPE_CLEAR = 6;
    // 先刷新消息再定位到消息位置
    public static final int DATA_CHANGE_LOCATE_TO_POSITION = 7;
    public static final int DATA_CHANGE_NEW_MESSAGE = 8;
    // 直接滚动到消息位置
    public static final int SCROLL_TO_POSITION = 9;
    // 先刷新消息再滚动到消息位置
    public static final int DATA_CHANGE_SCROLL_TO_POSITION = 10;

    // 取一个足够大的偏移保证能一次性滚动到最底部
    private static final int SCROLL_TO_END_OFFSET = -999999;

    protected OnItemClickListener mOnItemClickListener;
    protected MessageRecyclerView.OnLoadMoreHandler mHandler;
    protected MessageRecyclerView.OnEmptySpaceClickListener mEmptySpaceClickListener;
    protected MessageAdapter mAdapter;
    protected List<ChatPopMenu.ChatPopMenuAction> mPopActions = new ArrayList<>();
    protected List<ChatPopMenu.ChatPopMenuAction> mMorePopActions = new ArrayList<>();
    protected MessageRecyclerView.OnPopActionClickListener mOnPopActionClickListener;
    private final MessageProperties properties = MessageProperties.getInstance();

    private ChatPresenter presenter;

    private int mSelectedPosition = -1;
    private ChatPopMenu mChatPopMenu;
    private Handler handler = new Handler();
    Runnable runnable = new Runnable() {
        @Override
        public void run() {
            if (mChatPopMenu != null) {
                mChatPopMenu.hide();
            }
            if (mAdapter != null) {
                mAdapter.resetSelectableText();
            }
        }
    };

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
        if (mPopActions.size() == 0) {
            return;
        }

        if (mChatPopMenu != null) {
            mChatPopMenu.hide();
            mChatPopMenu = null;
            handler.removeCallbacks(runnable);
        }
        mChatPopMenu = new ChatPopMenu(getContext());
        mChatPopMenu.setChatPopMenuActionList(mPopActions);
        int[] location = new int[2];
        getLocationOnScreen(location);
        mChatPopMenu.show(view, location[1]);
        mChatPopMenu.setEmptySpaceClickListener(new MessageRecyclerView.OnEmptySpaceClickListener() {
            @Override
            public void onClick() {
                if (mAdapter != null) {
                    mAdapter.resetSelectableText();
                }
            }
        });

        handler.postDelayed(runnable, 10000);

        /*postDelayed(new Runnable() {
            @Override
            public void run() {
                if (mChatPopMenu != null) {
                    mChatPopMenu.hide();
                }
                if (mAdapter != null) {
                    mAdapter.resetSelectableText();
                }
            }
        }, 10000); // 10s后无操作自动消失*/
    }

    public void onMsgAddBack() {
        if (mAdapter != null) {
            // 如果当前显示最后一条消息，则消息刷新跳转到底部，否则不跳转
            if (isLastItemVisibleCompleted()) {
                scrollToEnd();
            }
        }
    }
    
    public boolean isDisplayJumpMessageLayout() {
        TUIChatLog.d(TAG, "computeVerticalScrollRange() = " + computeVerticalScrollRange() + ", computeVerticalScrollExtent() = "
                + computeVerticalScrollExtent() + ", computeVerticalScrollOffset() = " + computeVerticalScrollOffset());
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

    private void initPopActions(final TUIMessageBean msg) {
        if (msg == null) {
            return;
        }

        boolean textIsAllSelected = true;
        if (msg instanceof TextMessageBean) {
            String selectText = ((TextMessageBean) msg).getSelectText();
            String text = ((TextMessageBean) msg).getText();
            if (!text.equals(selectText)) {
                textIsAllSelected = false;
            }
        }

        List<ChatPopMenu.ChatPopMenuAction> actions = new ArrayList<>();
        actions.clear();
        ChatPopMenu.ChatPopMenuAction action = new ChatPopMenu.ChatPopMenuAction();
        if (msg instanceof TextMessageBean || msg instanceof ReplyMessageBean) {
            action.setActionName(getContext().getString(R.string.copy_action));
            action.setActionIcon(R.drawable.pop_menu_copy);
            action.setActionClickListener(() -> mOnPopActionClickListener.onCopyClick(msg));
            actions.add(action);
        }

        if (textIsAllSelected) {
            action = new ChatPopMenu.ChatPopMenuAction();
            action.setActionName(getContext().getString(R.string.delete_action));
            action.setActionIcon(R.drawable.pop_menu_delete);
            action.setActionClickListener(() -> mOnPopActionClickListener.onDeleteMessageClick(msg));
            actions.add(action);
            if (msg.isSelf()) {
                action = new ChatPopMenu.ChatPopMenuAction();
                if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                    action.setActionName(getContext().getString(R.string.revoke_action));
                    action.setActionIcon(R.drawable.pop_menu_revoke);
                    action.setActionClickListener(() -> mOnPopActionClickListener.onRevokeMessageClick(msg));
                    actions.add(action);
                }
            }

            //多选
            action = new ChatPopMenu.ChatPopMenuAction();
            action.setActionName(getContext().getString(R.string.titlebar_mutiselect));
            action.setActionIcon(R.drawable.pop_menu_multi_select);
            action.setActionClickListener(() -> mOnPopActionClickListener.onMultiSelectMessageClick(msg));
            actions.add(action);
        }

        //转发
        if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            action = new ChatPopMenu.ChatPopMenuAction();
            action.setActionName(getContext().getString(R.string.forward_button));
            action.setActionIcon(R.drawable.pop_menu_forward);
            action.setActionClickListener(()-> mOnPopActionClickListener.onForwardMessageClick(msg));
            actions.add(action);
        }

        if (textIsAllSelected) {
            // 回复
            if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                action = new ChatPopMenu.ChatPopMenuAction();
                action.setActionName(getContext().getString(R.string.reply_button));
                action.setActionIcon(R.drawable.pop_menu_reply);
                action.setActionClickListener(() -> mOnPopActionClickListener.onReplyMessageClick(msg));
                actions.add(action);
            }
        }

        mPopActions.clear();
        mPopActions.addAll(actions);
        mPopActions.addAll(mMorePopActions);
    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);
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
                } else if (isListEnd(lastPosition)){
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

    public void setPopActionClickListener(OnPopActionClickListener listener) {
        mOnPopActionClickListener = listener;
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
            public void onReplyMessageClick(View view, int position, String originMsgId) {
                // 点击转发消息进行跳转
                locateOriginMessage(originMsgId);
            }

            @Override
            public void onSendFailBtnClick(View view, int position, TUIMessageBean messageInfo) {
                new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.resend_tips))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(R.string.sure), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mOnPopActionClickListener.onSendMessageClick(messageInfo, true);
                            }
                        })
                        .setNegativeButton(getContext().getString(R.string.cancel), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
                        })
                        .show();
            }

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onTextSelected(view, position, messageInfo);
                }
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

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
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

    public interface OnPopActionClickListener {

        void onCopyClick(TUIMessageBean msg);

        void onSendMessageClick(TUIMessageBean msg, boolean retry);

        void onDeleteMessageClick(TUIMessageBean msg);

        void onRevokeMessageClick(TUIMessageBean msg);

        void onMultiSelectMessageClick(TUIMessageBean msg);

        void onForwardMessageClick(TUIMessageBean msg);

        void onReplyMessageClick(TUIMessageBean msg);
    }
}
