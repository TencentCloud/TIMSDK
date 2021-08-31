package com.tencent.qcloud.tim.uikit.modules.chat.layout.message;

import android.content.Context;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.PopupList;
import com.tencent.qcloud.tim.uikit.component.action.PopActionClickListener;
import com.tencent.qcloud.tim.uikit.component.action.PopMenuAction;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;

import java.util.ArrayList;
import java.util.List;

public class MessageLayout extends MessageLayoutUI {

    public static final int DATA_CHANGE_TYPE_REFRESH = 0;
    public static final int DATA_CHANGE_TYPE_LOAD = 1;
    public static final int DATA_CHANGE_TYPE_ADD_FRONT = 2;
    public static final int DATA_CHANGE_TYPE_ADD_BACK = 3;
    public static final int DATA_CHANGE_TYPE_UPDATE = 4;
    public static final int DATA_CHANGE_TYPE_DELETE = 5;
    public static final int DATA_CHANGE_TYPE_CLEAR = 6;
    public static final int DATA_CHANGE_SCROLL_TO_POSITION = 7;
    public static final int DATA_CHANGE_TYPE_NEW_MESSAGE = 8;

    public MessageLayout(Context context) {
        super(context);
    }

    public MessageLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public MessageLayout(Context context, @Nullable AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent e) {
        if (e.getAction() == MotionEvent.ACTION_UP) {
            View child = findChildViewUnder(e.getX(), e.getY());
            if (child == null) {
                if (mEmptySpaceClickListener != null)
                    mEmptySpaceClickListener.onClick();
            } else if (child instanceof ViewGroup) {
                ViewGroup group = (ViewGroup) child;
                final int count = group.getChildCount();
                float x = e.getRawX();
                float y = e.getRawY();
                View touchChild = null;
                for (int i = count - 1; i >= 0; i--) {
                    final View innerChild = group.getChildAt(i);
                    int position[] = new int[2];
                    innerChild.getLocationOnScreen(position);
                    if (x >= position[0]
                            && x <= position[0] + innerChild.getMeasuredWidth()
                            && y >= position[1]
                            && y <= position[1] + innerChild.getMeasuredHeight()) {
                        touchChild = innerChild;
                        break;
                    }
                }
                if (touchChild == null) {
                    if (mEmptySpaceClickListener != null) {
                        mEmptySpaceClickListener.onClick();
                    }
                }
            }
        }
        return super.onInterceptTouchEvent(e);
    }

    public void showItemPopMenu(final int index, final MessageInfo messageInfo, View view) {
        initPopActions(messageInfo);
        if (mPopActions.size() == 0) {
            return;
        }

        final PopupList popupList = new PopupList(getContext());
        List<String> mItemList = new ArrayList<>();
        for (PopMenuAction action : mPopActions) {
            mItemList.add(action.getActionName());
        }
        popupList.show(view, mItemList, new PopupList.PopupListListener() {
            @Override
            public boolean showPopupList(View adapterView, View contextView, int contextPosition) {
                return true;
            }

            @Override
            public void onPopupListClick(View contextView, int contextPosition, int position) {
                PopMenuAction action = mPopActions.get(position);
                if (action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(index, messageInfo);
                }
            }
        });
        postDelayed(new Runnable() {
            @Override
            public void run() {
                if (popupList != null) {
                    popupList.hidePopupListWindow();
                }
            }
        }, 10000); // 10s后无操作自动消失
    }

    public void onMsgAddBack() {
        if (mAdapter != null) {
            // 如果当前显示最后一条消息，则消息刷新跳转到底部，否则不跳转
            if (isLastItemVisibleCompleted()) {
                scrollToEnd();
            }
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

    private void initPopActions(final MessageInfo msg) {
        if (msg == null) {
            return;
        }
        List<PopMenuAction> actions = new ArrayList<>();
        PopMenuAction action = new PopMenuAction();
        if (msg.getMsgType() == MessageInfo.MSG_TYPE_TEXT) {
            action.setActionName(getContext().getString(R.string.copy_action));
            action.setActionClickListener(new PopActionClickListener() {
                @Override
                public void onActionClick(int position, Object data) {
                    mOnPopActionClickListener.onCopyClick(position, (MessageInfo) data);
                }
            });
            actions.add(action);
        }
        action = new PopMenuAction();
        action.setActionName(getContext().getString(R.string.delete_action));
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                mOnPopActionClickListener.onDeleteMessageClick(position, (MessageInfo) data);
            }
        });
        actions.add(action);
        if (msg.isSelf()) {
            action = new PopMenuAction();
            if (msg.getStatus() != MessageInfo.MSG_STATUS_SEND_FAIL) {
                action.setActionName(getContext().getString(R.string.revoke_action));
                action.setActionClickListener(new PopActionClickListener() {
                    @Override
                    public void onActionClick(int position, Object data) {
                        mOnPopActionClickListener.onRevokeMessageClick(position, (MessageInfo) data);
                    }
                });
                actions.add(action);
            } else {
                action = new PopMenuAction();
                action.setActionName(getContext().getString(R.string.resend_action));
                action.setActionClickListener(new PopActionClickListener() {
                    @Override
                    public void onActionClick(int position, Object data) {
                        mOnPopActionClickListener.onSendMessageClick(msg, true);
                    }
                });
                actions.add(action);
            }
        }

        //多选
        action = new PopMenuAction();
        action.setActionName(getContext().getString(R.string.titlebar_mutiselect));
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                mOnPopActionClickListener.onMultiSelectMessageClick(position, (MessageInfo) data);
            }
        });
        actions.add(action);

        //转发
        if (msg.getStatus() != MessageInfo.MSG_STATUS_SEND_FAIL) {
            action = new PopMenuAction();
            action.setActionName(getContext().getString(R.string.forward_button));
            action.setActionClickListener(new PopActionClickListener() {
                @Override
                public void onActionClick(int position, Object data) {
                    mOnPopActionClickListener.onForwardMessageClick(position, (MessageInfo) data);
                }
            });
            actions.add(action);
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
                    if (getAdapter() instanceof MessageListAdapter) {
                        ((MessageListAdapter) getAdapter()).showLoading();
                    }
                    mHandler.loadMore(TUIKitConstants.GET_MESSAGE_FORWARD);
                } else if (lastPosition == getAdapter().getItemCount() -1 && !isListEnd(lastPosition)){
                    if (getAdapter() instanceof MessageListAdapter) {
                        ((MessageListAdapter) getAdapter()).showLoading();
                    }
                    mHandler.loadMore(TUIKitConstants.GET_MESSAGE_BACKWARD);
                }
            }
        }
    }

    private boolean isListEnd(int lastPosition) {
       return mHandler.isListEnd(lastPosition);
    }

    public void scrollToEnd() {
        if (getAdapter() != null) {
            scrollToPosition(getAdapter().getItemCount() - 1);
        }
    }

    public void scrollToPositon(int position) {
        if (getAdapter() != null && position < getAdapter().getItemCount()) {
            scrollToPosition(position);
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

    @Override
    public void postSetAdapter(MessageListAdapter adapter) {
        mAdapter.setOnItemClickListener(new OnItemLongClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, MessageInfo messageInfo) {
                if (mOnItemLongClickListener != null) {
                    mOnItemLongClickListener.onMessageLongClick(view, position, messageInfo);
                }
            }

            @Override
            public void onUserIconClick(View view, int position, MessageInfo info) {
                if (mOnItemLongClickListener != null) {
                    mOnItemLongClickListener.onUserIconClick(view, position, info);
                }
            }
        });
    }

    public interface OnLoadMoreHandler {
        void loadMore(int type);
        boolean isListEnd(int postion);
    }

    public interface OnEmptySpaceClickListener {
        void onClick();
    }

    public interface OnItemLongClickListener {
        void onMessageLongClick(View view, int position, MessageInfo messageInfo);

        void onUserIconClick(View view, int position, MessageInfo messageInfo);
    }

    public interface OnPopActionClickListener {

        void onCopyClick(int position, MessageInfo msg);

        void onSendMessageClick(MessageInfo msg, boolean retry);

        void onDeleteMessageClick(int position, MessageInfo msg);

        void onRevokeMessageClick(int position, MessageInfo msg);

        void onMultiSelectMessageClick(int position, MessageInfo msg);

        void onForwardMessageClick(int position, MessageInfo msg);
    }
}
