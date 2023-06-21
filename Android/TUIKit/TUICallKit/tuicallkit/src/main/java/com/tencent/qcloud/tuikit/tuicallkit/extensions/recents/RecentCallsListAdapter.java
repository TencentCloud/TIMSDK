package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.interfaces.ICallRecordItemListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class RecentCallsListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int ITEM_TYPE_HEADER = 101;
    private static final int ITEM_TYPE_NORMAL = -98;
    private static final int HEADER_COUNT     = 1;

    private Context                         mContext;
    private List<TUICallDefine.CallRecords> mDataSource        = new ArrayList<>();
    private ICallRecordItemListener         mItemListener;
    private HashMap<String, Boolean>        mSelectedPositions = new HashMap<>();
    private boolean                         mIsMultiSelectMode = false;

    public void setOnCallRecordItemListener(ICallRecordItemListener listener) {
        this.mItemListener = listener;
    }

    public void onDataSourceChanged(List<TUICallDefine.CallRecords> dataSource) {
        mDataSource.clear();
        mDataSource.addAll(dataSource);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        mContext = parent.getContext().getApplicationContext();
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        if (viewType == ITEM_TYPE_HEADER) {
            View view = inflater.inflate(R.layout.tuicallkit_item_head_view, parent, false);
            return new HeaderViewHolder(view);
        } else {
            View view = inflater.inflate(R.layout.tuicallkit_layout_call_list_item, parent, false);
            return new RecentCallsItemHolder(view);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof RecentCallsItemHolder) {
            RecentCallsItemHolder viewHolder = (RecentCallsItemHolder) holder;
            viewHolder.mLayoutView.setOnClickListener(v -> {
                if (mItemListener != null) {
                    int curPos = viewHolder.getBindingAdapterPosition();
                    mItemListener.onItemClick(viewHolder.itemView, getItemViewType(curPos), getItem(curPos));
                }
            });
            viewHolder.mImageDetails.setOnClickListener(view -> {
                if (mItemListener != null) {
                    mItemListener.onDetailViewClick(view, getItem(viewHolder.getBindingAdapterPosition()));
                }
            });
            //左滑删除按钮事件监听
            if (!viewHolder.mLayoutDelete.hasOnClickListeners()) {
                viewHolder.mLayoutDelete.setOnClickListener(view -> {
                    int curPos = viewHolder.getBindingAdapterPosition();
                    TUICallDefine.CallRecords record = getItem(curPos);
                    if (record == null || TextUtils.isEmpty(record.callId)) {
                        return;
                    }
                    setItemChecked(record.callId, true);
                    if (mItemListener != null) {
                        mItemListener.onItemDeleteClick(view, getItemViewType(curPos), record);
                    }
                });
            }

            viewHolder.layoutViews(mContext, getItem(position), position);
            setCheckBoxStatus(viewHolder);
        }
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        if (holder instanceof RecentCallsItemHolder) {
            ((RecentCallsItemHolder) holder).mCallIconView.clear();
        }
    }

    private TUICallDefine.CallRecords getItem(int position) {
        if (mDataSource == null || mDataSource.isEmpty()) {
            return null;
        }

        int dataPosition = position - HEADER_COUNT;
        if (dataPosition < mDataSource.size() && dataPosition >= 0) {
            return mDataSource.get(dataPosition);
        }
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getItemCount() {
        if (mDataSource == null) {
            return HEADER_COUNT;
        }
        return mDataSource.size() + HEADER_COUNT;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return ITEM_TYPE_HEADER;
        }
        return ITEM_TYPE_NORMAL;
    }

    private void setCheckBoxStatus(RecentCallsItemHolder holder) {
        if (holder == null || holder.mCheckBoxSelectCall == null) {
            return;
        }
        if (!mIsMultiSelectMode) {
            holder.mCheckBoxSelectCall.setVisibility(View.GONE);
            holder.itemView.setOnClickListener(null);
        } else {
            holder.mCheckBoxSelectCall.setVisibility(View.VISIBLE);
        }
    }

    private int getIndexInAdapter(TUICallDefine.CallRecords records) {
        int position = -1;
        if (mDataSource != null) {
            int indexInData = mDataSource.indexOf(records);
            if (indexInData != -1) {
                position = indexInData + HEADER_COUNT;
            }
        }
        return position;
    }

    public void setShowMultiSelectCheckBox(boolean show) {
        mIsMultiSelectMode = show;
        for (TUICallDefine.CallRecords records : mDataSource) {
            if (records == null || TextUtils.isEmpty(records.callId)) {
                continue;
            }
            setItemChecked(records.callId, show);
            int currentPosition = getIndexInAdapter(records);
            if (currentPosition != -1) {
                notifyItemChanged(currentPosition);
            }
        }
    }

    private void setItemChecked(String callId, boolean isChecked) {
        mSelectedPositions.put(callId, isChecked);
    }

    public boolean isMultiSelectMode() {
        return mIsMultiSelectMode;
    }

    public List<TUICallDefine.CallRecords> getSelectedItem() {
        if (mSelectedPositions.size() == 0) {
            return null;
        }
        List<TUICallDefine.CallRecords> selectList = new ArrayList<>();
        for (int i = 0; i < getItemCount(); i++) {
            TUICallDefine.CallRecords records = getItem(i);
            if (records != null && isItemChecked(records.callId)) {
                selectList.add(records);
            }
        }
        return selectList;
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

    static class HeaderViewHolder extends RecyclerView.ViewHolder {
        public HeaderViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }
}
