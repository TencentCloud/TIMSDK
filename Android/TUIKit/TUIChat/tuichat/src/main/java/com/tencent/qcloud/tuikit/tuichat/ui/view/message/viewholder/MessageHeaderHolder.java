package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.view.View;
import android.widget.LinearLayout;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;

public class MessageHeaderHolder extends MessageBaseHolder {

    private boolean mLoading;

    public MessageHeaderHolder(View itemView) {
        super(itemView);
    }

    public void setLoadingStatus(boolean loading) {
        mLoading = loading;
    }

    @Override
    public void layoutViews(MessageInfo msg, int position) {
        RecyclerView.LayoutParams param = (RecyclerView.LayoutParams) rootView.getLayoutParams();
        if (mLoading) {
            param.height = LinearLayout.LayoutParams.WRAP_CONTENT;
            param.width = LinearLayout.LayoutParams.MATCH_PARENT;
            rootView.setVisibility(View.VISIBLE);
        } else {
            param.height = 0;
            param.width = 0;
            rootView.setVisibility(View.GONE);
        }
        rootView.setLayoutParams(param);
    }
}
