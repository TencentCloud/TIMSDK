package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BranchBean;

public class BranchItemHolder extends RecyclerView.ViewHolder {
    private View rootView;
    private TextView tvContent;
    private BranchListAdapter adapter;
    public BranchItemHolder(@NonNull View itemView) {
        super(itemView);
        rootView = itemView;
        tvContent = itemView.findViewById(R.id.branch_item_content);
    }

    public void layoutViews(BranchBean.Item item, int position) {
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

    public void setAdapter(BranchListAdapter adapter) {
        this.adapter = adapter;
    }
}
