package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget;

import android.os.Build;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuichatbotplugin.R;
import com.tencent.qcloud.tuikit.tuichatbotplugin.TUIChatBotConstants;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchMessageBean;

public class BranchItemHolder extends RecyclerView.ViewHolder {
    private View rootView;
    private View vBranchLine;
    private TextView tvNumber;
    private TextView tvContent;
    private ImageView ivArrow;
    private BranchListAdapter adapter;
    public BranchItemHolder(@NonNull View itemView) {
        super(itemView);
        rootView = itemView;
        vBranchLine = itemView.findViewById(R.id.v_branch_line);
        tvNumber = itemView.findViewById(R.id.branch_item_number);
        tvContent = itemView.findViewById(R.id.branch_item_content);
        ivArrow = itemView.findViewById(R.id.branch_item_arrow);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            ivArrow.getBackground().setAutoMirrored(true);
        }
    }

    public void layoutViews(BranchBean.Item item, int position) {
        if (item == null) {
            return;
        }

        if (position == 0) {
            vBranchLine.setVisibility(View.GONE);
        } else {
            vBranchLine.setVisibility(View.VISIBLE);
        }

        BranchMessageBean branchMessageBean = adapter.getPresenter().getMessageBean();
        if (branchMessageBean != null) {
            if (TextUtils.equals(branchMessageBean.getBranchBean().getSubType(), TUIChatBotConstants.CHAT_BOT_SUBTYPE_WELCOME_MSG)) {
                tvNumber.setText(String.valueOf((position + 1)));
                tvNumber.setVisibility(View.VISIBLE);
            } else {
                tvNumber.setVisibility(View.GONE);
            }
        }

        tvContent.setText(item.getContent());
        rootView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (adapter != null && adapter.getPresenter() != null) {
                    adapter.getPresenter().OnItemContentSelected(item.getContent());
                }
            }
        });
    }

    public void setAdapter(BranchListAdapter adapter) {
        this.adapter = adapter;
    }
}
