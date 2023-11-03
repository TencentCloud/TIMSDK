package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BranchBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import java.util.ArrayList;
import java.util.List;

public class BranchListAdapter extends RecyclerView.Adapter {
    private TUICustomerServicePresenter presenter;
    private List<BranchBean.Item> branchItemList = new ArrayList<>();

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        View rootView = inflater.inflate(R.layout.branch_item_layout, parent, false);
        BranchItemHolder holder = new BranchItemHolder(rootView);
        holder.setAdapter(this);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        BranchBean.Item branchItem = branchItemList.get(position);
        BranchItemHolder branchItemHolder = (BranchItemHolder) holder;
        branchItemHolder.layoutViews(branchItem, position);
    }

    @Override
    public int getItemCount() {
        return branchItemList.size();
    }

    public void setPresenter(TUICustomerServicePresenter presenter) {
        this.presenter = presenter;
    }

    public TUICustomerServicePresenter getPresenter() {
        return this.presenter;
    }

    public void setBranchItemList(List<BranchBean.Item> itemList) {
        this.branchItemList = itemList;
        notifyDataSetChanged();
    }
}
