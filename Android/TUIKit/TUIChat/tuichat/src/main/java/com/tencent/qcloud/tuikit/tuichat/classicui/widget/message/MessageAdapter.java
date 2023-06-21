package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message;

import static com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageBaseHolder.MSG_TYPE_HEADER_VIEW;
import static com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION_AND_UPDATE;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.ClassicUIService;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.MessageHeaderHolder;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MessageAdapter extends RecyclerView.Adapter implements IMessageAdapter, ICommonMessageAdapter {
    private static final String TAG = MessageAdapter.class.getSimpleName();
    private static final int ITEM_POSITION_UNKNOWN = -1;

    private boolean mLoading = true;
    private MessageRecyclerView mRecycleView;
    private List<TUIMessageBean> dataSource = new ArrayList<>();
    private OnItemClickListener mOnItemClickListener;

    private HashMap<String, Boolean> mSelectedPositions = new HashMap<String, Boolean>();
    protected boolean isShowMultiSelectCheckBox = false;

    private int mHighShowPosition;

    private boolean isForwardMode = false;
    private boolean isReplyDetailMode = false;

    private ChatPresenter presenter;
    private BaseFragment fragment;

    public void setPresenter(ChatPresenter chatPresenter) {
        this.presenter = chatPresenter;
    }

    public void setFragment(BaseFragment fragment) {
        this.fragment = fragment;
    }

    public void setForwardMode(boolean forwardMode) {
        isForwardMode = forwardMode;
    }

    public void setReplyDetailMode(boolean replyDetailMode) {
        isReplyDetailMode = replyDetailMode;
    }

    public ArrayList<TUIMessageBean> getSelectedItem() {
        if (mSelectedPositions == null || mSelectedPositions.size() == 0) {
            return null;
        }
        ArrayList<TUIMessageBean> selectList = new ArrayList<>();
        for (int i = 0; i < getItemCount() - 1; i++) {
            if (isItemChecked(dataSource.get(i).getId())) {
                selectList.add(dataSource.get(i));
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

    public List<TUIMessageBean> getDataSource() {
        return dataSource;
    }

    public void setItemChecked(String msgID, boolean isChecked) {
        if (mSelectedPositions == null) {
            return;
        }

        mSelectedPositions.put(msgID, isChecked);
    }

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
            messageContentHolder.setShowRead(TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead());
            messageContentHolder.setNeedShowTranslation(presenter.isNeedShowTranslation());
            messageContentHolder.setRecyclerView(mRecycleView);
            messageContentHolder.setFragment(fragment);

            if (isForwardMode) {
                messageContentHolder.setDataSource(dataSource);
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

            setCheckBoxStatus(position, msgId, baseHolder);
            baseHolder.layoutViews(msg, position);

            if (getItemViewType(position) == MSG_TYPE_HEADER_VIEW) {
                if (isForwardMode) {
                    ((MessageHeaderHolder) baseHolder).setLoadingStatus(false);
                } else {
                    ((MessageHeaderHolder) baseHolder).setLoadingStatus(mLoading);
                }
                return;
            } else {
                if (position == mHighShowPosition && baseHolder.mContentLayout != null) {
                    baseHolder.startHighLight();
                    mHighShowPosition = -1;
                }
            }
        }
    }

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
            baseHolder.mMutiSelectCheckBox.setChecked(isItemChecked(msgId));
            baseHolder.mMutiSelectCheckBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    changeCheckedStatus(msgId, position);
                }
            });
            baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    changeCheckedStatus(msgId, position);
                }
            });

            baseHolder.setOnItemClickListener(new OnItemClickListener() {
                @Override
                public void onMessageLongClick(View view, int position, TUIMessageBean messageInfo) {}

                @Override
                public void onUserIconClick(View view, int position, TUIMessageBean messageInfo) {
                    changeCheckedStatus(msgId, position);
                }

                @Override
                public void onUserIconLongClick(View view, int position, TUIMessageBean messageInfo) {
                    changeCheckedStatus(msgId, position);
                }

                @Override
                public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {}

                @Override
                public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {}

                @Override
                public void onReplyMessageClick(View view, int position, TUIMessageBean messageBean) {
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
    public void onViewNeedRefresh(final int type, TUIMessageBean messageBean) {
        ThreadUtils.postOnUiThread(() -> {
            mLoading = false;
            refreshLoadView();
            if (type == MessageRecyclerView.DATA_CHANGE_LOCATE_TO_POSITION) {
                notifyDataSetChanged();
                int position = getMessagePosition(messageBean);
                if (position == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                mRecycleView.scrollToPosition(position);
                mRecycleView.setHighShowPosition(position);
            } else if (type == MessageRecyclerView.SCROLL_TO_POSITION) {
                int position = getMessagePosition(messageBean);
                if (position == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                mRecycleView.scrollToPosition(position);
                mRecycleView.setHighShowPosition(position);
                notifyItemChanged(position);
                mRecycleView.scrollMessageFinish();
            } else if (type == MessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION) {
                notifyDataSetChanged();
                int position = getMessagePosition(messageBean);
                if (position == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                mRecycleView.scrollToEnd();
                mRecycleView.smoothScrollToPosition(position);
                mRecycleView.setHighShowPosition(position);
                notifyItemChanged(position);
                mRecycleView.scrollMessageFinish();
            } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE) {
                int position = getMessagePosition(messageBean);
                if (position == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                notifyItemChanged(position);
            } else if (type == IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION_WITHOUT_HIGH_LIGHT) {
                notifyDataSetChanged();
                int position = getMessagePosition(messageBean);
                if (position == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                mRecycleView.scrollToPosition(position);
            } else if (type == DATA_CHANGE_SCROLL_TO_POSITION_AND_UPDATE) {
                int position = getMessagePosition(messageBean);
                if (position == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                notifyItemChanged(position);
                mRecycleView.scrollToPosition(position);
            }
        });
    }

    @Override
    public void onViewNeedRefresh(final int type, final int value) {
        ThreadUtils.postOnUiThread(() -> {
            mLoading = false;
            if (type == MessageRecyclerView.DATA_CHANGE_TYPE_REFRESH) {
                notifyDataSetChanged();
                mRecycleView.scrollToEnd();
            } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_ADD_BACK) {
                notifyItemRangeInserted(dataSource.size() + 1, value);
            } else if (type == MessageRecyclerView.DATA_CHANGE_NEW_MESSAGE) {
                notifyItemRangeInserted(dataSource.size() + 1, value);
                mRecycleView.onMsgAddBack();
            } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE) {
                notifyDataSetChanged();
            } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT) {
                // 加载条目为数0，只更新动画
                // The number of loaded entries is 0, only the animation is updated
                if (value != 0) {
                    // 加载过程中有可能之前第一条与新加载的最后一条的时间间隔不超过5分钟，时间条目需去掉，所以这里的刷新要多一个条目
                    // During the loading process, it is possible that the time interval between the first item before
                    // and the last item newly loaded is not more than 5 minutes, and the time entry needs to be removed,
                    // so the refresh here needs one more entry
                    notifyItemRangeInserted(0, value);
                }
            } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_LOAD) {
                notifyDataSetChanged();
                mRecycleView.scrollToEnd();
                mRecycleView.loadMessageFinish();
            } else if (type == MessageRecyclerView.DATA_CHANGE_TYPE_DELETE) {
                if (value == ITEM_POSITION_UNKNOWN) {
                    return;
                }
                notifyItemRemoved(getViewPositionByDataPosition(value));
            }
            refreshLoadView();
        });
    }

    private void refreshLoadView() {
        notifyItemChanged(0);
    }

    @Override
    public int getItemCount() {
        return dataSource.size() + 1;
    }

    public int getViewPositionByDataPosition(int position) {
        if (position == ITEM_POSITION_UNKNOWN) {
            return ITEM_POSITION_UNKNOWN;
        }
        return position + 1;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return MSG_TYPE_HEADER_VIEW;
        }
        TUIMessageBean msg = getItem(position);
        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            return ClassicUIService.getInstance().getViewType(TipsMessageBean.class);
        }
        return ClassicUIService.getInstance().getViewType(msg.getClass());
    }

    @Override
    public void onDataSourceChanged(List<TUIMessageBean> dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void onScrollToEnd() {
        if (mRecycleView != null) {
            mRecycleView.scrollToEnd();
        }
    }

    private int getMessagePosition(TUIMessageBean message) {
        int position = ITEM_POSITION_UNKNOWN;
        if (dataSource == null || dataSource.isEmpty()) {
            return position;
        }

        position = dataSource.indexOf(message);
        if (position == -1) {
            return ITEM_POSITION_UNKNOWN;
        }
        return position + 1;
    }

    public TUIMessageBean getItem(int position) {
        if (position == 0 || dataSource == null || dataSource.size() == 0) {
            return null;
        }
        if (position >= dataSource.size() + 1) {
            return null;
        }
        return dataSource.get(position - 1);
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
        if (dataSource == null || dataSource.size() == 0 || first > last) {
            return new ArrayList<>(0);
        }
        if (first >= dataSource.size() + 1 || last >= dataSource.size() + 1) {
            return new ArrayList<>(0);
        }

        return new ArrayList<>(dataSource.subList(first - 1, last));
    }
}