package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import java.util.ArrayList;
import java.util.List;

public class CollectionListAdapter extends RecyclerView.Adapter {
    private TUICustomerServicePresenter presenter;
    private List<CollectionBean.FormItem> collectionFormItemList = new ArrayList<>();

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        View rootView = inflater.inflate(R.layout.collection_form_item_layout, parent, false);
        CollectionFormItemHolder holder = new CollectionFormItemHolder(rootView);
        holder.setAdapter(this);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        CollectionBean.FormItem collectionFormItem = collectionFormItemList.get(position);
        CollectionFormItemHolder collectionItemHolder = (CollectionFormItemHolder) holder;
        collectionItemHolder.layoutViews(collectionFormItem, position);
    }

    @Override
    public int getItemCount() {
        return collectionFormItemList.size();
    }

    public void setPresenter(TUICustomerServicePresenter presenter) {
        this.presenter = presenter;
    }

    public TUICustomerServicePresenter getPresenter() {
        return this.presenter;
    }

    public void setCollectionItemList(List<CollectionBean.FormItem> itemList) {
        this.collectionFormItemList = itemList;
        notifyDataSetChanged();
    }
}
