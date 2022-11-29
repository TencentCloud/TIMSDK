package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.graphics.Color;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.swipe.RecyclerSwipeAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.swipe.SimpleSwipeListener;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.swipe.SwipeLayout;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ConversationListAdapter extends RecyclerSwipeAdapter<RecyclerView.ViewHolder> implements IConversationListAdapter {

    public static final int ITEM_TYPE_HEADER_HIDE = 101;
    public static final int ITEM_TYPE_FOOTER_LOADING = -99;
    public static final int HEADER_COUNT = 1;
    public static final int FOOTER_COUNT = 1;
    public static final int SELECT_COUNT = 1;
    public static final int SELECT_LABEL_COUNT = 1;

    private boolean mHasShowUnreadDot = true;
    private int mItemAvatarRadius = ScreenUtil.getPxByDp(5);
    private int mTopTextSize;
    private int mBottomTextSize;
    private int mDateTextSize;
    protected List<ConversationInfo> mDataSource = new ArrayList<>();
    private OnConversationAdapterListener mOnConversationAdapterListener;

    //消息转发
    private final HashMap<String, Boolean> mSelectedPositions = new HashMap<>();
    private boolean isShowMultiSelectCheckBox = false;
    private boolean isForwardFragment = false;

    private boolean mIsLoading = false;

    // 长按高亮显示
    private boolean isClick = false;
    private int currentPosition = -1;

    private View hideView;
    // 展示折叠样式
    private boolean showFoldedStyle = true;
    public ConversationListAdapter() {

    }

    public int getCurrentPosition() {
        return currentPosition;
    }

    public boolean isClick() {
        return isClick;
    }

    public void setClick(boolean click) {
        isClick = click;
    }

    public void setCurrentPosition(int currentPosition , boolean isClick) {
        this.currentPosition = currentPosition;
        this.isClick = isClick;
    }

    public void setShowMultiSelectCheckBox(boolean show) {
        isShowMultiSelectCheckBox = show;

        if (!isShowMultiSelectCheckBox) {
            mSelectedPositions.clear();
        }
    }

    public void setForwardFragment(boolean forwardFragment) {
        isForwardFragment = forwardFragment;
    }

    public void setShowFoldedStyle(boolean showFoldedStyle) {
        this.showFoldedStyle = showFoldedStyle;
    }

    //设置给定位置条目的选择状态
    public void setItemChecked(String conversationId, boolean isChecked) {
        mSelectedPositions.put(conversationId, isChecked);
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

    // 获得选中条目的结果
    public List<ConversationInfo> getSelectedItem() {
        if (mSelectedPositions.size() == 0) {
            return null;
        }
        List<ConversationInfo> selectList = new ArrayList<>();
        for (int i = 0; i < getItemCount() - 1; i++) {
            ConversationInfo conversationInfo = getItem(i);
            if (conversationInfo == null) {
                continue;
            }
            if (isItemChecked(conversationInfo.getConversationId())) {
                selectList.add(conversationInfo);
            }
        }
        return selectList;
    }

    public void setSelectConversations(List<ConversationInfo> dataSource){
        if(dataSource == null || dataSource.size() == 0){
            mSelectedPositions.clear();
            notifyDataSetChanged();
            return;
        }

        mSelectedPositions.clear();
        for (int i = 0; i < dataSource.size(); i++) {
            for (int j =0; j<mDataSource.size(); j++){
                if (TextUtils.equals(dataSource.get(i).getConversationId(), mDataSource.get(j).getConversationId())){
                    setItemChecked(mDataSource.get(j).getConversationId(), true);
                    notifyDataSetChanged();
                    break;
                }
            }
        }
    }

    public void setOnConversationAdapterListener(OnConversationAdapterListener listener) {
        this.mOnConversationAdapterListener = listener;
    }

    @Override
    public void onDataSourceChanged(List<ConversationInfo> dataSource) {
        this.mDataSource = dataSource;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        ConversationBaseHolder holder = null;
        // 创建不同的 ViewHolder
        View view;
        // 根据ViewType来创建条目
        if (viewType == ITEM_TYPE_HEADER_HIDE) {
            // 如果 searchView 不显示，添加一个隐藏的 view，防止 recyclerview 自动滑到最底部
            return new HeaderViewHolder(new View(parent.getContext()));
        } else if (viewType == ConversationInfo.TYPE_CUSTOM) {
            view = inflater.inflate(R.layout.conversation_custom_adapter, parent, false);
            holder = new ConversationCustomHolder(view);
        } else if (viewType == ITEM_TYPE_FOOTER_LOADING) {
            view = inflater.inflate(R.layout.loading_progress_bar, parent, false);
            return new FooterViewHolder(view);
        } else if (viewType == ConversationInfo.TYPE_FORWAR_SELECT) {
            view = inflater.inflate(R.layout.conversation_forward_select_adapter, parent, false);
            return new ForwardSelectHolder(view);
        }  else if (viewType == ConversationInfo.TYPE_RECENT_LABEL) {
            view = inflater.inflate(R.layout.conversation_forward_label_adapter, parent, false);
            return new ForwardLabelHolder(view);
        } else {
            view = inflater.inflate(R.layout.minimalistui_conversation_list_item_layout, parent, false);
            holder = new ConversationCommonHolder(view);
            ((ConversationCommonHolder) holder).setForwardMode(isForwardFragment);
            ((ConversationCommonHolder) holder).setShowFoldedStyle(showFoldedStyle);
        }
        holder.setAdapter(this);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        final ConversationInfo conversationInfo = getItem(position);
        ConversationBaseHolder baseHolder = null;
        if (conversationInfo != null) {
            baseHolder = (ConversationBaseHolder) holder;
        }

        switch (getItemViewType(position)) {
            case ConversationInfo.TYPE_CUSTOM:
            case ConversationInfo.TYPE_RECENT_LABEL:
                break;
            case ITEM_TYPE_FOOTER_LOADING: {
                if (holder instanceof FooterViewHolder) {
                    ((ConversationBaseHolder) holder).layoutViews(null, position);
                }
                break;
            }
            case ConversationInfo.TYPE_FORWAR_SELECT : {
                ForwardSelectHolder selectHolder = (ForwardSelectHolder) holder;
                selectHolder.refreshTitle(!isShowMultiSelectCheckBox);
                setOnClickListener(holder, getItemViewType(position), conversationInfo);
                break;
            }
            default: {
                if (baseHolder instanceof ConversationCommonHolder) {
                    ConversationCommonHolder viewHolder = (ConversationCommonHolder) baseHolder;
                    viewHolder.swipeLayout.setShowMode(SwipeLayout.ShowMode.LayDown);
                    if (conversationInfo.isMarkFold()) {
                        viewHolder.swipeLayout.setOnDoubleClickListener(new SwipeLayout.DoubleClickListener() {
                            @Override
                            public void onDoubleClick(SwipeLayout layout, boolean surface) {

                            }

                            @Override
                            public void onClick() {
                                if (mOnConversationAdapterListener != null) {
                                    mOnConversationAdapterListener.onItemClick(viewHolder.itemView, getItemViewType(position), conversationInfo);
                                }
                            }
                        });

                        viewHolder.markReadView.setVisibility(View.GONE);
                        viewHolder.moreView.setVisibility(View.GONE);
                        viewHolder.notDisplayView.setVisibility(View.VISIBLE);
                        viewHolder.notDisplayView.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                if (mOnConversationAdapterListener != null) {
                                    mItemManger.removeShownLayouts(viewHolder.swipeLayout);
                                    mOnConversationAdapterListener.onMarkConversationHidden(view, conversationInfo);
                                }
                                mItemManger.closeAllSwipeItems();
                            }
                        });
                        mItemManger.bind(viewHolder.itemView, position);
                    } else {
                        viewHolder.notDisplayView.setVisibility(View.GONE);
                        viewHolder.markReadView.setVisibility(View.VISIBLE);
                        viewHolder.moreView.setVisibility(View.VISIBLE);
                        viewHolder.swipeLayout.addSwipeListener(new SimpleSwipeListener() {
                            @Override
                            public void onOpen(SwipeLayout layout) {
                                if (mOnConversationAdapterListener != null) {
                                    mOnConversationAdapterListener.onSwipeConversationChanged(conversationInfo);
                                }
                            }

                            @Override
                            public void onClose(SwipeLayout layout) {
                                if (mOnConversationAdapterListener != null) {
                                    mOnConversationAdapterListener.onSwipeConversationChanged(null);
                                }
                            }

                            @Override
                            public void onStartOpen(SwipeLayout layout) {
                                int unReadNum = conversationInfo.getUnRead();
                                boolean isMarkUnread = conversationInfo.isMarkUnread();
                                if (unReadNum > 0) {
                                    viewHolder.markReadTextView.setText(R.string.mark_read);
                                    viewHolder.markReadView.setBackgroundColor(viewHolder.itemView.getResources().getColor(R.color.conversation_mark_swipe_bg));
                                    viewHolder.markReadIconView.setBackgroundResource(R.drawable.conversation_minimalist_message_status_send_all_read);
                                } else {
                                    if (isMarkUnread) {
                                        viewHolder.markReadTextView.setText(R.string.mark_read);
                                        viewHolder.markReadView.setBackgroundColor(viewHolder.itemView.getResources().getColor(R.color.conversation_mark_swipe_bg));
                                        viewHolder.markReadIconView.setBackgroundResource(R.drawable.conversation_minimalist_message_status_send_all_read);
                                    } else {
                                        viewHolder.markReadTextView.setText(R.string.mark_unread);
                                        viewHolder.markReadView.setBackgroundColor(viewHolder.itemView.getResources().getColor(R.color.conversation_mark_swipe_dark_bg));
                                        viewHolder.markReadIconView.setBackgroundResource(R.drawable.conversation_minimalist_message_status_send_no_read);
                                    }
                                }
                            }
                        });
                        viewHolder.swipeLayout.setOnDoubleClickListener(new SwipeLayout.DoubleClickListener() {
                            @Override
                            public void onDoubleClick(SwipeLayout layout, boolean surface) {

                            }

                            @Override
                            public void onClick() {
                                if (mOnConversationAdapterListener != null) {
                                    mOnConversationAdapterListener.onItemClick(viewHolder.itemView, getItemViewType(position), conversationInfo);
                                }
                            }
                        });

                        viewHolder.markReadView.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                if (mOnConversationAdapterListener != null) {
                                    boolean markRead = TUIConversationService.getAppContext().getString(R.string.mark_read).equals(viewHolder.markReadTextView.getText());
                                    mOnConversationAdapterListener.onMarkConversationUnread(view, conversationInfo, !markRead);
                                }
                                mItemManger.closeAllSwipeItems();
                            }
                        });

                        viewHolder.moreView.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                if (mOnConversationAdapterListener != null) {
                                    mOnConversationAdapterListener.onClickMoreView(view, conversationInfo);
                                }
                                mItemManger.closeAllSwipeItems();
                            }
                        });

                        mItemManger.bind(viewHolder.itemView, position);
                    }
                } else {
                    setOnClickListener(holder, getItemViewType(position), conversationInfo);
                }
            }
        }
        if (baseHolder != null) {
            baseHolder.layoutViews(conversationInfo, position);
            setCheckBoxStatus(conversationInfo, position, baseHolder);
        }

        if (getCurrentPosition() == position && isClick()){
            baseHolder.itemView.setBackgroundResource(R.color.conversation_item_clicked_color);
        } else {
            if (conversationInfo == null) {
                return;
            }
            if (conversationInfo.isTop() && !isForwardFragment) {
                baseHolder.itemView.setBackgroundColor(baseHolder.rootView.getResources().getColor(R.color.conversation_item_top_color));
            } else {
                baseHolder.itemView.setBackgroundColor(Color.WHITE);
            }
        }

    }

    private void setOnClickListener(RecyclerView.ViewHolder holder, int viewType, ConversationInfo conversationInfo) {
        if (holder instanceof HeaderViewHolder) {
            return;
        }
        //设置点击和长按事件
        if (mOnConversationAdapterListener != null) {
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mOnConversationAdapterListener.onItemClick(view, viewType, conversationInfo);
                }
            });

            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    mOnConversationAdapterListener.OnItemLongClick(view, conversationInfo);
                    int position = getIndexInAdapter(conversationInfo);
                    if (position != -1) {
                        setCurrentPosition(position, true);
                        notifyItemChanged(position);
                    }
                    return true;
                }
            });
        }
    }

    // 设置多选框的选中状态和点击事件
    private void setCheckBoxStatus(final ConversationInfo conversationInfo, int position, ConversationBaseHolder baseHolder) {
        if (!(baseHolder instanceof ConversationCommonHolder) || ((ConversationCommonHolder) baseHolder).multiSelectCheckBox == null) {
            return;
        }
        int viewType = getItemViewType(position);
        String conversationId = conversationInfo.getConversationId();
        ConversationCommonHolder commonHolder = (ConversationCommonHolder) baseHolder;
        if (!isShowMultiSelectCheckBox || conversationInfo.isMarkFold()) {
            commonHolder.multiSelectCheckBox.setVisibility(View.GONE);
            baseHolder.itemView.setOnClickListener(null);
        } else {
            commonHolder.multiSelectCheckBox.setVisibility(View.VISIBLE);

            //设置条目状态
            commonHolder.multiSelectCheckBox.setChecked(isItemChecked(conversationId));
            //checkBox的监听
            commonHolder.multiSelectCheckBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    setItemChecked(conversationId, !isItemChecked(conversationId));
                    if (mOnConversationAdapterListener != null) {
                        mOnConversationAdapterListener.onItemClick(v, viewType, conversationInfo);
                    }
                }
            });

            //条目view的监听
            baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    setItemChecked(conversationId, !isItemChecked(conversationId));
                    int currentPosition = getIndexInAdapter(conversationInfo);
                    if (currentPosition != -1) {
                        notifyItemChanged(currentPosition);
                    }
                    if (mOnConversationAdapterListener != null) {
                        mOnConversationAdapterListener.onItemClick(v, viewType, conversationInfo);
                    }
                }
            });
        }
    }

    public int getIndexInAdapter(ConversationInfo conversationInfo) {
        int position = -1;
        if (mDataSource != null) {
            int indexInData = mDataSource.indexOf(conversationInfo);
            if (indexInData != -1) {
                position = getItemIndexInAdapter(indexInData);
            }
        }
        return position;
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        // ViewHolder 被回收时要清空头像 view 并且停止异步加载头像
        if (holder instanceof ConversationCommonHolder) {
            ((ConversationCommonHolder) holder).conversationIconView.clearImage();
        }
    }

    public ConversationInfo getItem(int position) {
        if (mDataSource.isEmpty() || position == getItemCount() - 1) {
            return null;
        }

        int dataPosition;
        if (isForwardFragment) {
            dataPosition = position - SELECT_COUNT - SELECT_LABEL_COUNT;
        } else {
            dataPosition = position - HEADER_COUNT;
        }
        if (dataPosition < mDataSource.size() && dataPosition >= 0) {
            return mDataSource.get(dataPosition);
        }

        return null;
    }

    @Override
    public int getItemCount() {
        int listSize = mDataSource.size();
        if (isForwardFragment) {
            return listSize + SELECT_COUNT + SELECT_LABEL_COUNT + FOOTER_COUNT;
        }
        return listSize + HEADER_COUNT + FOOTER_COUNT;
    }

    @Override
    public int getItemViewType(int position) {
        if (isForwardFragment) {
            if (position == 0) {
                return ConversationInfo.TYPE_FORWAR_SELECT;
            } else if (position == 1) {
                return ConversationInfo.TYPE_RECENT_LABEL;
            }
        } else {
            if (position == 0) {
                return ITEM_TYPE_HEADER_HIDE;
            }
        }
        if (position == getItemCount() - 1) {
            return ITEM_TYPE_FOOTER_LOADING;
        } else if (mDataSource != null) {
            ConversationInfo conversationInfo = getItem(position);
            if (conversationInfo != null) {
                return conversationInfo.getType();
            }
        }
        return ConversationInfo.TYPE_COMMON;
    }

    private int getItemIndexInAdapter(int index) {
        int itemIndex;
        if (isForwardFragment) {
            itemIndex = index + SELECT_LABEL_COUNT + SELECT_COUNT;
        } else {
            itemIndex = index + HEADER_COUNT;
        }
        return itemIndex;
    }

    @Override
    public void onItemRemoved(int position) {
        int itemIndex = getItemIndexInAdapter(position);
        notifyItemRemoved(itemIndex);
    }

    @Override
    public void onItemInserted(int position) {
        int itemIndex = getItemIndexInAdapter(position);
        notifyItemInserted(itemIndex);
    }

    @Override
    public void onItemChanged(int position) {
        int itemIndex = getItemIndexInAdapter(position);
        notifyItemChanged(itemIndex);
    }

    @Override
    public void onItemRangeChanged(int startPosition, int count) {
        int itemStartIndex = getItemIndexInAdapter(startPosition);
        notifyItemRangeChanged(itemStartIndex, count);
    }

    @Override
    public void onConversationChanged(List<ConversationInfo> conversationInfoList) {
        if (mOnConversationAdapterListener != null) {
            mOnConversationAdapterListener.onConversationChanged(conversationInfoList);
        }
    }

    public void setItemTopTextSize(int size) {
        mTopTextSize = size;
    }

    public int getItemTopTextSize() {
        return mTopTextSize;
    }

    public void setItemBottomTextSize(int size) {
        mBottomTextSize = size;
    }

    public int getItemBottomTextSize() {
        return mBottomTextSize;
    }

    public void setItemDateTextSize(int size) {
        mDateTextSize = size;
    }

    public int getItemDateTextSize() {
        return mDateTextSize;
    }

    public void setItemAvatarRadius(int radius) {
        mItemAvatarRadius = radius;
    }

    public int getItemAvatarRadius() {
        return mItemAvatarRadius;
    }

    public void disableItemUnreadDot(boolean flag) {
        mHasShowUnreadDot = !flag;
    }

    public boolean hasItemUnreadDot() {
        return mHasShowUnreadDot;
    }

    @Override
    public void onLoadingStateChanged(boolean isLoading) {
        this.mIsLoading = isLoading;
        notifyItemChanged(getItemCount() - 1);
    }

    @Override
    public void onViewNeedRefresh() {
        notifyDataSetChanged();
    }

    @Override
    public int getSwipeLayoutResourceId(int position) {
        return R.id.swipe;
    }

    //header
    static class HeaderViewHolder extends RecyclerView.ViewHolder {
        public HeaderViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }

    //footer
    class FooterViewHolder extends ConversationBaseHolder {
        public FooterViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @Override
        public void layoutViews(ConversationInfo conversationInfo, int position) {
            RecyclerView.LayoutParams param = (RecyclerView.LayoutParams) rootView.getLayoutParams();
            if (mIsLoading) {
                param.height = LinearLayout.LayoutParams.WRAP_CONTENT;
                param.width = LinearLayout.LayoutParams.MATCH_PARENT;
                rootView.setVisibility(View.VISIBLE);
            } else {
                param.height = 0;
                param.width = 0;
                rootView.setVisibility(View.GONE);
            }
            rootView.setLayoutParams(param);
        }
    }

    static class ForwardLabelHolder extends ConversationBaseHolder {
        public ForwardLabelHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void layoutViews(ConversationInfo conversationInfo, int position) {

        }
    }

    static class ForwardSelectHolder extends ConversationBaseHolder {
        private final TextView titleView;
        public ForwardSelectHolder(View itemView) {
            super(itemView);
            titleView = itemView.findViewById(R.id.forward_title);
        }

        @Override
        public void layoutViews(ConversationInfo conversationInfo, int position) {

        }

        public void refreshTitle(boolean isCreateGroup){
            if (titleView == null)return;

            if (isCreateGroup){
                titleView.setText(TUIConversationService.getAppContext().getString(R.string.forward_select_new_chat));
            } else {
                titleView.setText(TUIConversationService.getAppContext().getString(R.string.forward_select_from_contact));
            }
        }
    }

}
