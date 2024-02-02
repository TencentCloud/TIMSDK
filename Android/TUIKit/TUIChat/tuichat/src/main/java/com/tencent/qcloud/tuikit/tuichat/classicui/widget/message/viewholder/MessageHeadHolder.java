package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.view.View;
import android.widget.LinearLayout;

import androidx.recyclerview.widget.RecyclerView;

public class MessageHeadHolder extends RecyclerView.ViewHolder {

    public MessageHeadHolder(View itemView) {
        super(itemView);
    }

    public void setLoadingStatus(boolean loading) {
        RecyclerView.LayoutParams param = (RecyclerView.LayoutParams) itemView.getLayoutParams();
        if (loading) {
            param.height = LinearLayout.LayoutParams.WRAP_CONTENT;
            param.width = LinearLayout.LayoutParams.MATCH_PARENT;
            itemView.setVisibility(View.VISIBLE);
        } else {
            param.height = 1;
            param.width = 0;
            itemView.setVisibility(View.INVISIBLE);
        }
        itemView.setLayoutParams(param);
    }
}
