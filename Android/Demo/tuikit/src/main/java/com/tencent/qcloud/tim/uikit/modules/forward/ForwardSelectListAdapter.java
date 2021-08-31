package com.tencent.qcloud.tim.uikit.modules.forward;

import android.text.TextUtils;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationListAdapter;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationListLayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationProvider;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationCommonHolder;
import com.tencent.qcloud.tim.uikit.modules.conversation.interfaces.IConversationProvider;
import com.tencent.qcloud.tim.uikit.modules.forward.holder.ForwardBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.forward.holder.ForwardCommonHolder;
import com.tencent.qcloud.tim.uikit.modules.forward.holder.ForwardLableHolder;
import com.tencent.qcloud.tim.uikit.modules.forward.holder.ForwardSelectHolder;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

import java.util.ArrayList;
import java.util.List;

public class ForwardSelectListAdapter extends ConversationListAdapter {

    private boolean mHasShowUnreadDot = true;
    private int mItemAvatarRadius = ScreenUtil.getPxByDp(5);
    private int mTopTextSize;
    private int mBottomTextSize;
    private int mDateTextSize;
    private List<ConversationInfo> mDataSource = new ArrayList<>();
    private ConversationListLayout.OnItemClickListener mOnItemClickListener;
    private ConversationListLayout.OnItemLongClickListener mOnItemLongClickListener;

    protected boolean messageTextShow = true;
    protected boolean timelineTextShow = true;
    protected boolean unreadTextShow = true;
    protected boolean atInfoTextShow = true;

    private boolean isForwardFragment = true;
    private SparseBooleanArray mSelectedPositions = new SparseBooleanArray();
    private boolean isShowMutiSelectCheckBox = false;

    public ForwardSelectListAdapter() {

    }

    public List<ConversationInfo> getSelectConversations(){
        if(mSelectedPositions == null || mSelectedPositions.size() == 0){
            return new ArrayList<>();
        }

        List<ConversationInfo> selectList = new ArrayList<>();
        for (int i = 0; i < mSelectedPositions.size(); i++) {
            if (mSelectedPositions.valueAt(i)) { //mSelectedPositions存储下标从2开始
                selectList.add(mDataSource.get(mSelectedPositions.keyAt(i) - 2));
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
                if (dataSource.get(i).getId() == mDataSource.get(j).getId()){
                    setItemChecked(j+2, true);
                    notifyDataSetChanged();
                    break;
                }
            }
        }
    }

    //获得选中条目的结果
    public ArrayList<Integer> getSelectedItem() {
        ArrayList<Integer> selectList = new ArrayList<>();
        for (int i = 0; i < getItemCount(); i++) {
            if (isItemChecked(i)) {
                selectList.add(i-2);
            }
        }

        return selectList;
    }

    public void setShowMutiSelectCheckBox(boolean show){
        isShowMutiSelectCheckBox = show;

        if(!isShowMutiSelectCheckBox && mSelectedPositions != null){
            mSelectedPositions.clear();
        }
    }

    //设置给定位置条目的选择状态
    private void setItemChecked(int position, boolean isChecked) {
        mSelectedPositions.put(position, isChecked);
    }

    //根据位置判断条目是否选中
    private boolean isItemChecked(int position) {
        return mSelectedPositions.get(position);
    }

    public void setOnItemClickListener(ConversationListLayout.OnItemClickListener listener) {
        this.mOnItemClickListener = listener;
    }

    public void setOnItemLongClickListener(ConversationListLayout.OnItemLongClickListener listener) {
        this.mOnItemLongClickListener = listener;
    }

    public void setDataProvider(IConversationProvider provider) {
        mDataSource = provider.getDataSource();
        if (provider instanceof ConversationProvider) {
            provider.attachAdapter(this);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(TUIKit.getAppContext());
        RecyclerView.ViewHolder holder = null;
        // 创建不同的 ViewHolder
        View view;
        // 根据ViewType来创建条目
        if (viewType == ConversationInfo.TYPE_CUSTOM) {
            view = inflater.inflate(R.layout.conversation_custom_adapter, parent, false);
            holder = new ForwardCommonHolder(view);
        } else if (viewType == ConversationInfo.TYPE_FORWAR_SELECT){
            view = inflater.inflate(R.layout.conversation_forward_select_adapter, parent, false);
            holder = new ForwardSelectHolder(view);
        } else if (viewType == ConversationInfo.TYPE_RECENT_LABEL){
            view = inflater.inflate(R.layout.conversation_forward_label_adapter, parent, false);
            holder = new ForwardLableHolder(view);
        } else {
            view = inflater.inflate(R.layout.conversation_adapter, parent, false);
            holder = new ForwardCommonHolder(view);
        }
        if (holder != null) {
            ((ConversationBaseHolder) holder).setAdapter(this);
        }
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        final ConversationInfo conversationInfo;

        if (position > 1){
            conversationInfo = getItem(position - 2);
        } else {
            conversationInfo = null;
            if (position == 0){
                ForwardSelectHolder selectHolder = (ForwardSelectHolder) holder;
                selectHolder.refreshTitile(!isShowMutiSelectCheckBox);
            }
        }
        ForwardBaseHolder baseHolder = (ForwardBaseHolder) holder;

        switch (getItemViewType(position)) {
            case ConversationInfo.TYPE_CUSTOM:
            case ConversationInfo.TYPE_RECENT_LABEL:
                break;
            case ConversationInfo.TYPE_FORWAR_SELECT:
                //设置点击和长按事件
                if (mOnItemClickListener != null) {
                    holder.itemView.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mOnItemClickListener.onItemClick(view, position, conversationInfo);
                        }
                    });
                }
                if (mOnItemLongClickListener != null) {
                    holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                        @Override
                        public boolean onLongClick(View view) {
                            mOnItemLongClickListener.OnItemLongClick(view, position, conversationInfo);
                            return true;
                        }
                    });
                }
                break;
            default:
                if (!isShowMutiSelectCheckBox) {
                    ((ForwardCommonHolder) baseHolder).getMutiSelectCheckBox().setVisibility(View.GONE);

                    //设置点击和长按事件
                    if (mOnItemClickListener != null) {
                        holder.itemView.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                mOnItemClickListener.onItemClick(view, position, conversationInfo);
                            }
                        });
                    }
                    if (mOnItemLongClickListener != null) {
                        holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                            @Override
                            public boolean onLongClick(View view) {
                                mOnItemLongClickListener.OnItemLongClick(view, position, conversationInfo);
                                return true;
                            }
                        });
                    }
                } else {
                    ((ForwardCommonHolder) baseHolder).getMutiSelectCheckBox().setVisibility(View.VISIBLE);

                    //设置条目状态
                    ((ForwardCommonHolder) baseHolder).getMutiSelectCheckBox().setChecked(isItemChecked(position));
                    //checkBox的监听
                    ((ForwardCommonHolder) baseHolder).getMutiSelectCheckBox().setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (isItemChecked(position)) {
                                setItemChecked(position, false);
                            } else {
                                setItemChecked(position, true);
                            }
                        }
                    });

                    //条目view的监听
                    baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (isItemChecked(position)) {
                                setItemChecked(position, false);
                            } else {
                                setItemChecked(position, true);
                            }
                            notifyItemChanged(position);

                            mOnItemClickListener.onItemClick(v, position, conversationInfo);
                        }
                    });

                    if (mOnItemLongClickListener != null) {
                        holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                            @Override
                            public boolean onLongClick(View view) {
                                mOnItemLongClickListener.OnItemLongClick(view, position, conversationInfo);
                                return true;
                            }
                        });
                    }
                }
                break;
        }
        if (conversationInfo != null) {
            baseHolder.layoutViews(conversationInfo, position);
        }
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        if (holder instanceof ConversationCommonHolder) {
            ((ConversationCommonHolder) holder).conversationIconView.setBackground(null);
        }
    }

    public ConversationInfo getItem(int position) {
        if (mDataSource.size() == 0)
            return null;
        return mDataSource.get(position);
    }

    @Override
    public int getItemCount() {
        return mDataSource.size() + 2;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return ConversationInfo.TYPE_FORWAR_SELECT;
        } else if (position == 1) {
            return ConversationInfo.TYPE_RECENT_LABEL;
        }
        if (mDataSource != null) {
            ConversationInfo conversation = mDataSource.get(position-2);
            return conversation.getType();
        }

        return 1;
    }

    public void addItem(int position, ConversationInfo info) {
        mDataSource.add(position, info);
        notifyItemInserted(position);
        notifyDataSetChanged();
    }

    public void removeItem(int position) {
        mDataSource.remove(position);
        notifyItemRemoved(position);
        notifyDataSetChanged();
    }

    public void notifyDataSourceChanged(String info) {
        for (int i = 0; i < mDataSource.size(); i++) {
            if (TextUtils.equals(info, mDataSource.get(i).getConversationId())) {
                notifyItemChanged(i+2);
                return;
            }
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

    public boolean isAtInfoTextShow() {
        return atInfoTextShow;
    }

    public void setAtInfoTextShow(boolean atInfoTextShow) {
        this.atInfoTextShow = atInfoTextShow;
    }

    public boolean isMessageTextShow() {
        return messageTextShow;
    }

    public void setMessageTextShow(boolean messageTextShow) {
        this.messageTextShow = messageTextShow;
    }

    public boolean isTimelineTextShow() {
        return timelineTextShow;
    }

    public void setTimelineTextShow(boolean timelineTextShow) {
        this.timelineTextShow = timelineTextShow;
    }

    public boolean isUnreadTextShow() {
        return unreadTextShow;
    }

    public void setUnreadTextShow(boolean unreadTextShow) {
        this.unreadTextShow = unreadTextShow;
    }

    public boolean isForwardFragment() {
        return isForwardFragment;
    }

    public void setForwardFragment(boolean forwardFragment) {
        isForwardFragment = forwardFragment;
    }
}
