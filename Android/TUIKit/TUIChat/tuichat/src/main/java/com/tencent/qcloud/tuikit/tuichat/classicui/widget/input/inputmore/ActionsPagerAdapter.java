package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;

import java.util.ArrayList;
import java.util.List;

public class ActionsPagerAdapter extends RecyclerView.Adapter<ActionsPagerAdapter.ActionsViewHolder> {
    private static final int ITEM_COUNT_PER_GRID_VIEW = 8;
    private static final int COLUMN_COUNT = 4;
    private final List<InputMoreActionUnit> mInputMoreList;
    private final int mGridViewCount;

    public ActionsPagerAdapter(List<InputMoreActionUnit> mInputMoreList) {
        this.mInputMoreList = new ArrayList<>(mInputMoreList);
        this.mGridViewCount = (mInputMoreList.size() + ITEM_COUNT_PER_GRID_VIEW - 1) / ITEM_COUNT_PER_GRID_VIEW;
    }

    @NonNull
    @Override
    public ActionsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        GridView gridView = new GridView(parent.getContext());
        gridView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        return new ActionsViewHolder(gridView);
    }

    @Override
    public void onBindViewHolder(@NonNull ActionsViewHolder holder, int position) {
        int end = (position + 1) * ITEM_COUNT_PER_GRID_VIEW > mInputMoreList.size() ? mInputMoreList.size() : (position + 1) * ITEM_COUNT_PER_GRID_VIEW;
        List<InputMoreActionUnit> subBaseActions = mInputMoreList.subList(position * ITEM_COUNT_PER_GRID_VIEW, end);

        GridView gridView = holder.gridView;
        holder.setActions(subBaseActions);
        gridView.setNumColumns(COLUMN_COUNT);
        gridView.setSelector(R.color.transparent);
        gridView.setHorizontalSpacing(60);
        gridView.setVerticalSpacing(60);
        gridView.setGravity(Gravity.CENTER);
        gridView.setTag(Integer.valueOf(position));
        gridView.setOnItemClickListener(new GridView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                int index = ((Integer) parent.getTag()) * ITEM_COUNT_PER_GRID_VIEW + position;
                mInputMoreList.get(index).getOnClickListener().onClick();
            }
        });
    }

    @Override
    public int getItemCount() {
        return mGridViewCount;
    }

    static class ActionsViewHolder extends RecyclerView.ViewHolder {
        GridView gridView;
        private final ActionsGridViewAdapter adapter;

        public ActionsViewHolder(@NonNull View itemView) {
            super(itemView);
            gridView = (GridView) itemView;
            adapter = new ActionsGridViewAdapter();
            gridView.setAdapter(adapter);
        }

        public void setActions(List<InputMoreActionUnit> actions) {
            adapter.setBaseActions(actions);
            adapter.notifyDataSetChanged();
        }
    }
}
