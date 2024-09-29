package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.highlight.HighlightPresenter;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.UserFaceUrlCache;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageHeadHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MessageAdapter extends RecyclerView.Adapter implements IMessageAdapter, ICommonMessageAdapter {
    private static final String TAG = MessageAdapter.class.getSimpleName();
    private static final int ITEM_POSITION_UNKNOWN = -1;

    private boolean mLoading = true;
    private MessageRecyclerView mRecycleView;
    private List<TUIMessageBean> mDataSource = new ArrayList<>();
    private OnItemClickListener mOnItemClickListener;
    private OnCheckListChangedListener onCheckListChangedListener;
    private HashMap<String, Boolean> mSelectedPositions = new HashMap<>();
    protected boolean isShowMultiSelectCheckBox = false;

    private boolean isForwardMode = false;

    private ChatPresenter presenter;
    private Fragment fragment;
    private UserFaceUrlCache faceUrlCache;

    public void setPresenter(ChatPresenter chatPresenter) {
        this.presenter = chatPresenter;
    }

    public void setFragment(Fragment fragment) {
        this.fragment = fragment;
    }

    public void setForwardMode(boolean forwardMode) {
        isForwardMode = forwardMode;
    }

    public ArrayList<TUIMessageBean> getSelectedItem() {
        if (mSelectedPositions == null || mSelectedPositions.size() == 0) {
            return null;
        }
        ArrayList<TUIMessageBean> selectList = new ArrayList<>();
        for (int i = 0; i < mDataSource.size(); i++) {
            if (isItemChecked(mDataSource.get(i))) {
                selectList.add(mDataSource.get(i));
            }
        }

        return selectList;
    }

    public void setOnCheckListChangedListener(OnCheckListChangedListener onCheckListChangedListener) {
        this.onCheckListChangedListener = onCheckListChangedListener;
    }

    public void setShowMultiSelectCheckBox(boolean show) {
        isShowMultiSelectCheckBox = show;

        if (!isShowMultiSelectCheckBox && mSelectedPositions != null) {
            mSelectedPositions.clear();
        }
    }

    public boolean isShowMultiSelectCheckBox() {
        return isShowMultiSelectCheckBox;
    }

    public void setItemChecked(TUIMessageBean messageBean, boolean isChecked) {
        if (mSelectedPositions == null) {
            return;
        }

        mSelectedPositions.put(messageBean.getId(), isChecked);

        if (onCheckListChangedListener != null) {
            onCheckListChangedListener.onCheckListChanged(getSelectedItem());
        }
    }

    private boolean isItemChecked(TUIMessageBean messageBean) {
        if (mSelectedPositions.size() <= 0) {
            return false;
        }

        if (mSelectedPositions.containsKey(messageBean.getId())) {
            return mSelectedPositions.get(messageBean.getId());
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

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder holder = MessageViewHolderFactory.getInstance(parent, this, viewType);
        if (holder instanceof MessageContentHolder) {
            MessageContentHolder messageContentHolder = (MessageContentHolder) holder;
            messageContentHolder.isForwardMode = isForwardMode;
            messageContentHolder.setShowRead(TUIChatConfigs.getGeneralConfig().isMsgNeedReadReceipt());
            messageContentHolder.setNeedShowBottom(presenter.isNeedShowBottom());
            messageContentHolder.setRecyclerView(mRecycleView);
            messageContentHolder.setFragment(fragment);
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
            setCheckBoxStatus(msg, baseHolder);
            baseHolder.layoutViews(msg, position);

        } else if (holder instanceof MessageHeadHolder) {
            if (isForwardMode) {
                ((MessageHeadHolder) holder).setLoadingStatus(false);
            } else {
                ((MessageHeadHolder) holder).setLoadingStatus(mLoading);
            }
        }
    }

    private void setCheckBoxStatus(TUIMessageBean messageBean, MessageBaseHolder baseHolder) {
        if (messageBean == null) {
            return;
        }
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
            if (messageBean.hasRiskContent()) {
                baseHolder.mMutiSelectCheckBox.setEnabled(false);
            } else {
                baseHolder.mMutiSelectCheckBox.setEnabled(true);
            }
            baseHolder.mMutiSelectCheckBox.setVisibility(View.VISIBLE);
            baseHolder.mMutiSelectCheckBox.setChecked(isItemChecked(messageBean));
            baseHolder.mMutiSelectCheckBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    changeCheckedStatus(messageBean);
                }
            });
            baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    changeCheckedStatus(messageBean);
                }
            });

            baseHolder.setOnItemClickListener(new OnItemClickListener() {
                @Override
                public void onMessageLongClick(View view, TUIMessageBean messageInfo) {}

                @Override
                public void onUserIconClick(View view, TUIMessageBean messageInfo) {
                    changeCheckedStatus(messageBean);
                }

                @Override
                public void onUserIconLongClick(View view, TUIMessageBean messageInfo) {
                    changeCheckedStatus(messageBean);
                }

                @Override
                public void onReEditRevokeMessage(View view, TUIMessageBean messageInfo) {}

                @Override
                public void onRecallClick(View view, TUIMessageBean messageInfo) {}

                @Override
                public void onReplyMessageClick(View view, TUIMessageBean messageBean) {
                    changeCheckedStatus(messageBean);
                }

                @Override
                public void onMessageClick(View view, TUIMessageBean messageInfo) {
                    changeCheckedStatus(messageBean);
                }

                @Override
                public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                    changeCheckedStatus(messageBean);
                }
            });

            if (baseHolder.msgContentFrame != null) {
                baseHolder.msgContentFrame.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        changeCheckedStatus(messageBean);
                    }
                });
            }
        }
    }

    public void changeCheckedStatus(TUIMessageBean messageBean) {
        if (messageBean.hasRiskContent()) {
            setItemChecked(messageBean, false);
            return;
        }

        if (isItemChecked(messageBean)) {
            setItemChecked(messageBean, false);
        } else {
            setItemChecked(messageBean, true);
        }

        onViewNeedRefresh(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, messageBean);
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
        if (holder instanceof MessageBaseHolder) {
            ((MessageBaseHolder) holder).setMessageBubbleBackground(null);
            ((MessageBaseHolder) holder).onRecycled();
        }
    }

    @Override
    @MainThread
    public void onViewNeedRefresh(final int type, TUIMessageBean messageBean) {
        mLoading = false;
        refreshLoadView();
        if (type == IMessageRecyclerView.DATA_CHANGE_LOCATE_TO_POSITION) {
            notifyDataSetChanged();
            int position = getMessagePosition(messageBean);
            if (position == ITEM_POSITION_UNKNOWN) {
                return;
            }
            mRecycleView.scrollToPosition(position);
            HighlightPresenter.startHighlight(messageBean.getId());
        } else if (type == IMessageRecyclerView.SCROLL_TO_POSITION) {
            int position = getMessagePosition(messageBean);
            if (position == ITEM_POSITION_UNKNOWN) {
                return;
            }
            mRecycleView.scrollToPosition(position);
            HighlightPresenter.startHighlight(messageBean.getId());
            mRecycleView.scrollMessageFinish();
        } else if (type == IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION) {
            notifyDataSetChanged();
            int position = getMessagePosition(messageBean);
            if (position == ITEM_POSITION_UNKNOWN) {
                return;
            }
            mRecycleView.scrollToEnd();
            mRecycleView.smoothScrollToPosition(position);
            HighlightPresenter.startHighlight(messageBean.getId());
            mRecycleView.scrollMessageFinish();
        } else if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE) {
            int position = getMessagePosition(messageBean);
            if (position == ITEM_POSITION_UNKNOWN) {
                return;
            }
            onItemChanged(position);
        } else if (type == IMessageRecyclerView.DATA_CHANGE_SCROLL_TO_POSITION_WITHOUT_HIGH_LIGHT) {
            notifyDataSetChanged();
            int position = getMessagePosition(messageBean);
            if (position == ITEM_POSITION_UNKNOWN) {
                return;
            }
            mRecycleView.scrollToPosition(position);
        }
    }

    @Override
    @MainThread
    public void onViewNeedRefresh(final int type, final int value) {
        mLoading = false;
        if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_REFRESH) {
            notifyDataSetChanged();
            mRecycleView.scrollToEnd();
        } else if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_ADD_BACK) {
            onItemInsert(mDataSource.size() + 1, value);
        } else if (type == IMessageRecyclerView.DATA_CHANGE_NEW_MESSAGE) {
            onItemInsert(mDataSource.size() + 1, value);
            mRecycleView.onMsgAddBack();
        } else if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE) {
            notifyDataSetChanged();
        } else if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_ADD_FRONT) {
            // The number of loaded entries is 0, only the animation is updated
            if (value != 0) {
                // During the loading process, it is possible that the time interval between the first item before
                // and the last item newly loaded is not more than 5 minutes, and the time entry needs to be removed,
                // so the refresh here needs one more entry
                onItemInsert(0, value);
            }
        } else if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_LOAD) {
            notifyDataSetChanged();
            mRecycleView.scrollToEnd();
            mRecycleView.loadMessageFinish();
        } else if (type == IMessageRecyclerView.DATA_CHANGE_TYPE_DELETE) {
            if (value == ITEM_POSITION_UNKNOWN) {
                return;
            }
            onItemRemove(getViewPositionByDataPosition(value));
        }
        refreshLoadView();
    }

    private void refreshLoadView() {
        notifyItemChanged(0);
    }

    private void onItemChanged(int position) {
        int start = position - 1;
        int end = position + 1;
        if (start < 0) {
            start = 0;
        }
        if (end > getItemCount()) {
            end = position;
        }
        int count = end - start;
        notifyItemRangeChanged(start, count);
    }

    private void onItemInsert(int start, int count) {
        notifyItemRangeInserted(start, count);
        int startTemp = start - 2;
        int endTemp = start + count + 2;
        notifyItemRangeChanged(startTemp, endTemp - startTemp);
    }

    private void onItemRemove(int position) {
        int start = position - 1;
        int end = position + 1;
        if (start >= 0) {
            notifyItemChanged(start);
        }
        if (end <= getItemCount()) {
            notifyItemChanged(end);
        }
        notifyItemRemoved(position);
    }

    @Override
    public void onItemRefresh(TUIMessageBean messageBean) {
        onViewNeedRefresh(IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE, messageBean);
    }

    @Override
    public int getItemCount() {
        return mDataSource.size() + 2;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return MessageViewHolderFactory.VIEW_TYPE_HEAD;
        }
        if (position == getItemCount() - 1) {
            return MessageViewHolderFactory.VIEW_TYPE_TAIL;
        }
        TUIMessageBean msg = getItem(position);
        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            return MinimalistUIService.getInstance().getViewType(TipsMessageBean.class);
        }
        return MinimalistUIService.getInstance().getViewType(msg.getClass());
    }

    @Override
    public void onDataSourceChanged(List<TUIMessageBean> dataSource) {
        mDataSource = dataSource;
    }

    public int getViewPositionByDataPosition(int position) {
        if (position == ITEM_POSITION_UNKNOWN) {
            return ITEM_POSITION_UNKNOWN;
        }
        return position + 1;
    }

    private int getMessagePosition(TUIMessageBean message) {
        int position = ITEM_POSITION_UNKNOWN;
        if (mDataSource == null || mDataSource.isEmpty()) {
            return position;
        }

        position = mDataSource.indexOf(message);
        if (position == -1) {
            return ITEM_POSITION_UNKNOWN;
        }
        return position + 1;
    }

    public TUIMessageBean getItem(int position) {
        if (position == 0 || mDataSource == null || mDataSource.isEmpty()) {
            return null;
        }
        if (position >= mDataSource.size() + 1) {
            return null;
        }
        return mDataSource.get(position - 1);
    }

    @Override
    public TUIMessageBean getFirstMessageBean() {
        if (mDataSource == null || mDataSource.isEmpty()) {
            return null;
        }
        return mDataSource.get(0);
    }

    @Override
    public TUIMessageBean getLastMessageBean() {
        if (mDataSource == null || mDataSource.isEmpty()) {
            return null;
        }
        return mDataSource.get(mDataSource.size() - 1);
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
        if (first >= mDataSource.size() + 1) {
            return new ArrayList<>(0);
        }

        return new ArrayList<>(mDataSource.subList(first - 1, last - 1));
    }

    @Override
    public UserFaceUrlCache getUserFaceUrlCache() {
        if (faceUrlCache == null) {
            faceUrlCache = new UserFaceUrlCache() {
                final Map<String, String> map = new HashMap();

                { map.put(TUILogin.getLoginUser(), TUILogin.getFaceUrl()); }

                @Override
                public String getCachedFaceUrl(String userID) {
                    return map.get(userID);
                }

                @Override
                public void pushFaceUrl(String userID, String faceUrl) {
                    map.put(userID, faceUrl);
                }
            };
        }
        return faceUrlCache;
    }

    public interface OnCheckListChangedListener {
        void onCheckListChanged(List<TUIMessageBean> checkedList);
    }
}