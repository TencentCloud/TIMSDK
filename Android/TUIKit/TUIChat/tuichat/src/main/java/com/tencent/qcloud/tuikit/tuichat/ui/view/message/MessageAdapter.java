package com.tencent.qcloud.tuikit.tuichat.ui.view.message;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.FileMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageHeaderHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageBaseHolder;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.TextMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder.MessageBaseHolder.MSG_TYPE_HEADER_VIEW;


public class MessageAdapter extends RecyclerView.Adapter implements IMessageAdapter, ICommonMessageAdapter {

    private static final String TAG = MessageAdapter.class.getSimpleName();
    private boolean mLoading = true;
    private MessageRecyclerView mRecycleView;
    private List<TUIMessageBean> mDataSource = new ArrayList<>();
    private OnItemClickListener mOnItemClickListener;

    //消息转发
    private HashMap<String, Boolean> mSelectedPositions = new HashMap<String, Boolean>();
    protected boolean isShowMultiSelectCheckBox = false;

    private int mHighShowPosition;

    private boolean isForwardMode = false;
    private boolean isReplyDetailMode = false;

    private ChatPresenter presenter;

    public void setPresenter(ChatPresenter chatPresenter) {
        this.presenter = chatPresenter;
    }

    public void setForwardMode(boolean forwardMode) {
        isForwardMode = forwardMode;
    }

    public void setReplyDetailMode(boolean replyDetailMode) {
        isReplyDetailMode = replyDetailMode;
    }

    //获得选中条目的结果，msgId
    public ArrayList<TUIMessageBean> getSelectedItem() {
        if (mSelectedPositions == null || mSelectedPositions.size() == 0) {
            return null;
        }
        ArrayList<TUIMessageBean> selectList = new ArrayList<>();
        for (int i = 0; i < getItemCount() - 1; i++) {
            if (isItemChecked(mDataSource.get(i).getId())) {
                selectList.add(mDataSource.get(i));
            }
        }

        return selectList;
    }

    public void setShowMultiSelectCheckBox(boolean show) {
        isShowMultiSelectCheckBox = show;

        if (!isShowMultiSelectCheckBox && mSelectedPositions != null) {
            mSelectedPositions.clear();
        }

    }

    //设置给定位置条目的选择状态
    public void setItemChecked(String msgID, boolean isChecked) {
        if (mSelectedPositions == null) {
            return;
        }

        mSelectedPositions.put(msgID, isChecked);
    }

    //根据位置判断条目是否选中
    private boolean isItemChecked(String id) {
        if (mSelectedPositions.size() <= 0) {
            return false;
        }

        if (mSelectedPositions.containsKey(id)) {
            return mSelectedPositions.get(id);
        } else {
            return false;
        }
    }

    public OnItemClickListener getOnItemClickListener() {
        return this.mOnItemClickListener;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.mOnItemClickListener = listener;
    }

    public void setHighShowPosition(int mHighShowPosition) {
        this.mHighShowPosition = mHighShowPosition;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder holder = MessageViewHolderFactory.getInstance(parent, this, viewType);
        if (holder instanceof MessageContentHolder) {
            MessageContentHolder messageContentHolder = (MessageContentHolder) holder;
            messageContentHolder.isForwardMode = isForwardMode;
            messageContentHolder.isReplyDetailMode = isReplyDetailMode;
            messageContentHolder.setPresenter(presenter);

            if (isForwardMode) {
                messageContentHolder.setDataSource(mDataSource);
            }
        }
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull final RecyclerView.ViewHolder holder, final int position) {
        final TUIMessageBean msg = getItem(position);
        if (holder instanceof MessageBaseHolder) {
            if (holder instanceof MessageContentHolder) {
                ((MessageContentHolder) holder).isMultiSelectMode = isShowMultiSelectCheckBox;
            }
            final MessageBaseHolder baseHolder = (MessageBaseHolder) holder;
            baseHolder.setOnItemClickListener(mOnItemClickListener);
            String msgId = "";
            if (msg != null) {
                msgId = msg.getId();
            }

            switch (getItemViewType(position)) {
                case MSG_TYPE_HEADER_VIEW:
                    if (isForwardMode) {
                        ((MessageHeaderHolder) baseHolder).setLoadingStatus(false);
                    } else {
                        ((MessageHeaderHolder) baseHolder).setLoadingStatus(mLoading);
                    }
                    break;
                default:
                    if (position == mHighShowPosition && baseHolder.mContentLayout != null) {
                        baseHolder.startHighLight();
                        mHighShowPosition = -1;
                    }
                    break;
            }
            setCheckBoxStatus(position, msgId, baseHolder);
            baseHolder.layoutViews(msg, position);
        }
    }

    // 设置多选框的选中状态和点击事件
    private void setCheckBoxStatus(final int position, final String msgId, MessageBaseHolder baseHolder) {
        if (baseHolder.mMutiSelectCheckBox == null) {
            return;
        }
        if (!isShowMultiSelectCheckBox) {
            baseHolder.mMutiSelectCheckBox.setVisibility(View.GONE);
            baseHolder.setOnItemClickListener(mOnItemClickListener);
            if (baseHolder.msgContentFrame != null) {
                baseHolder.msgContentFrame.setOnClickListener(null);
            }
        } else {
            baseHolder.mMutiSelectCheckBox.setVisibility(View.VISIBLE);

            //设置条目状态
            baseHolder.mMutiSelectCheckBox.setChecked(isItemChecked(msgId));
            //checkBox的监听
            baseHolder.mMutiSelectCheckBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    changeCheckedStatus(msgId, position);
                }
            });

            //条目view的监听
            baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    changeCheckedStatus(msgId, position);
                }
            });

            baseHolder.setOnItemClickListener(new OnItemClickListener() {
                @Override
                public void onMessageLongClick(View view, int position, TUIMessageBean messageInfo) {
                }

                @Override
                public void onUserIconClick(View view, int position, TUIMessageBean messageInfo) {
                    changeCheckedStatus(msgId, position);
                }

                @Override
                public void onUserIconLongClick(View view, int position, TUIMessageBean messageInfo) {
                    changeCheckedStatus(msgId, position);
                }

                @Override
                public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {

                }

                @Override
                public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {

                }

                @Override
                public void onReplyMessageClick(View view, int position, QuoteMessageBean messageBean) {
                    changeCheckedStatus(msgId, position);
                }

                @Override
                public void onMessageClick(View view, int position, TUIMessageBean messageInfo) {
                    changeCheckedStatus(msgId, position);
                }
            });

            if (baseHolder.msgContentFrame != null) {
                baseHolder.msgContentFrame.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        changeCheckedStatus(msgId, position);
                    }
                });
            }
        }
    }

    private void changeCheckedStatus(String msgId, int position) {
        if (isItemChecked(msgId)) {
            setItemChecked(msgId, false);
        } else {
            setItemChecked(msgId, true);
        }
        notifyItemChanged(position);
    }

    public void resetSelectableText() {
        int index = mRecycleView.getSelectedPosition();
        if (index < 0) {
            return;
        }
        RecyclerView.ViewHolder holder = mRecycleView.findViewHolderForAdapterPosition(index);
        if (holder != null) {
            if (holder instanceof MessageContentHolder) {
                ((MessageContentHolder) holder).resetSelectableText();
            }
        } else {
            TUIChatLog.d(TAG, "holder == null");
        }
    }

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        mRecycleView = (MessageRecyclerView) recyclerView;
        mRecycleView.setItemViewCacheSize(5);
    }

    public void showLoading() {
        if (isForwardMode) {
            return;
        }
        if (mLoading) {
            return;
        }
        mLoading = true;
        notifyItemChanged(0);
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        if (holder instanceof MessageContentHolder) {
            ((MessageContentHolder) holder).msgArea.setBackground(null);
            ((MessageContentHolder) holder).stopHighLight();
            ((MessageContentHolder) holder).onRecycled();
        }
    }

    @Override
    public void onViewNeedRefresh(final int type, TUIMessageBean locateMessage) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mLoading = false;
                if (type == MessageRecyclerView.DATA_CHANGE_LOCATE_TO_POSITION) {
                    notifyDataSetChanged();
                    int position = getMessagePosition(locateMessage);
                    mRecycleView.scrollToPosition(position);
                    mRecycleView.setHighShowPosition(position);
                } else if (type == MessageRecyclerView.SCROLL_TO_POSITION) {
                    int position = getMessagePosition(locateMessage);
                    mRecycleView.setHighShowPosition(position);
                    mRecycleView.scrollToPosition(position);
                    notifyItemChanged(position);
                    mRecycleView.scrollMessageFinish();
                } else if (type == MessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION) {
                    notifyDataSetChanged();
                    int position = getMessagePosition(locateMessage);
                    mRecycleView.setHighShowPosition(position);
                    mRecycleView.scrollToEnd();
                    mRecycleView.smoothScrollToPosition(position);
                    notifyItemChanged(position);
                    mRecycleView.scrollMessageFinish();
                } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE) {
                    int position = getMessagePosition(locateMessage);
                    notifyItemChanged(position);
                }
                refreshLoadView();
            }
        });
    }

    @Override
    public void onViewNeedRefresh(final int type, final int value) {
        BackgroundTasks.getInstance().postDelayed(new Runnable() {
            @Override
            public void run() {
                mLoading = false;
                if (type == MessageRecyclerView.DATA_CHANGE_TYPE_REFRESH) {
                    notifyDataSetChanged();
                    mRecycleView.scrollToEnd();
                } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_ADD_BACK) {
                    notifyItemRangeInserted(mDataSource.size() + 1, value);
                } else if (type == MessageRecyclerView.DATA_CHANGE_NEW_MESSAGE) {
                    notifyItemRangeInserted(mDataSource.size() + 1, value);
                    mRecycleView.onMsgAddBack();
                } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE) {
                    notifyDataSetChanged();
                } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT) {
                    //加载条目为数0，只更新动画
                    if (value != 0) {
                        //加载过程中有可能之前第一条与新加载的最后一条的时间间隔不超过5分钟，时间条目需去掉，所以这里的刷新要多一个条目
                        if (getItemCount() > value) {
                            notifyItemRangeInserted(0, value);
                        } else {
                            notifyItemRangeInserted(0, value);
                        }
                    }
                } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_DELETE) {
                    notifyItemRemoved(value);
                    notifyDataSetChanged();
                } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_LOAD) {
                    notifyDataSetChanged();
                    mRecycleView.scrollToEnd();
                    mRecycleView.loadMessageFinish();
                }
                refreshLoadView();
            }
        }, 100);
    }

    private void refreshLoadView() {
        notifyItemChanged(0);
    }

    @Override
    public int getItemCount() {
        return mDataSource.size() + 1;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return MSG_TYPE_HEADER_VIEW;
        }
        TUIMessageBean msg = getItem(position);
        // 撤回消息显示为 TIPS 类型
        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            return TUIChatService.getInstance().getViewType(TipsMessageBean.class);
        }
        return TUIChatService.getInstance().getViewType(msg.getClass());
    }

    @Override
    public void onDataSourceChanged(List<TUIMessageBean> dataSource) {
        mDataSource = dataSource;
    }


    @Override
    public void onScrollToEnd() {
        if (mRecycleView != null) {
            mRecycleView.scrollToEnd();
        }
    }


    public int getMessagePosition(TUIMessageBean message) {
        int positon = 0;
        if (mDataSource == null || mDataSource.isEmpty()) {
            return positon;
        }

        for (int i = 0; i < mDataSource.size(); i++) {
            if (TextUtils.equals(mDataSource.get(i).getId(), message.getId())) {
                positon = i;
            }
        }
        return positon + 1;
    }

    public TUIMessageBean getItem(int position) {
        if (position == 0 || mDataSource == null || mDataSource.size() == 0) {
            return null;
        }
        if (position >= mDataSource.size() + 1) {
            return null;
        }
        return mDataSource.get(position - 1);
    }

    public List<TUIMessageBean> getItemList(int first, int last) {
        if (first < 0 || last < 0) {
            return new ArrayList<>(0);
        }
        if (first == 0) {
            first = 1;
        }
        if (last == 0) {
            last = 1;
        }
        if (mDataSource == null || mDataSource.size() == 0 || first > last) {
            return new ArrayList<>(0);
        }
        if (first >= mDataSource.size() + 1 || last >= mDataSource.size() + 1) {
            return new ArrayList<>(0);
        }

        return new ArrayList<>(mDataSource.subList(first - 1, last));
    }

}