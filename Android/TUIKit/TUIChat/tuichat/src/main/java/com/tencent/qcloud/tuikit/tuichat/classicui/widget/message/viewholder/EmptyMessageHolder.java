package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

// A transparent view holder that is used to display empty message when no message is available.
public class EmptyMessageHolder extends RecyclerView.ViewHolder {

    public EmptyMessageHolder(View itemView) {
        super(itemView);
        itemView.setLayoutParams(new ViewGroup.LayoutParams(0,0));
    }
}
