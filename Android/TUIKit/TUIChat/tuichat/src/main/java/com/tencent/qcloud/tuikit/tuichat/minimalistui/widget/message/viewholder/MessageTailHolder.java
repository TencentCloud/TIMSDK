package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import androidx.recyclerview.widget.RecyclerView;

// A transparent view for laying out other items from tail to head.
public class MessageTailHolder extends RecyclerView.ViewHolder {

    public MessageTailHolder(View itemView) {
        super(itemView);
        itemView.setLayoutParams(new ViewGroup.LayoutParams(1,1));
    }
}
