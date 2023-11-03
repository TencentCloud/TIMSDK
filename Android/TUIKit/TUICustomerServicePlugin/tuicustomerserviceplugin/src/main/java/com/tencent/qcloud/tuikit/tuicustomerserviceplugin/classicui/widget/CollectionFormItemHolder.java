package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionBean;

public class CollectionFormItemHolder extends RecyclerView.ViewHolder {
    private View rootView;
    private TextView tvContent;
    private CollectionListAdapter adapter;
    public CollectionFormItemHolder(@NonNull View itemView) {
        super(itemView);
        rootView = itemView;
        tvContent = itemView.findViewById(R.id.collection_form_item_content);
    }

    public void layoutViews(CollectionBean.FormItem item, int position) {
        if (item == null) {
            return;
        }

        tvContent.setText(item.getContent());
        rootView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (adapter != null && adapter.getPresenter() != null && adapter.getPresenter().allowSelection()) {
                    adapter.getPresenter().OnItemContentSelected(item.getContent());
                }
            }
        });
    }

    public void setAdapter(CollectionListAdapter adapter) {
        this.adapter = adapter;
    }
}
