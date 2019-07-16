package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.view.View;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public class MessageCustomHolder extends MessageContentHolder implements ICustomMessageViewGroup {

    public MessageCustomHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return 0;
    }

    @Override
    public void initVariableViews() {

    }

    @Override
    public void layoutViews(MessageInfo msg, int position) {
        super.layoutViews(msg, position);
    }

    @Override
    public void layoutVariableViews(MessageInfo msg, int position) {

    }

    @Override
    public void addMessageItemView(View view) {
        ((RelativeLayout) rootView).removeAllViews();
        ((RelativeLayout) rootView).addView(chatTimeText, 0);
        if (view != null) {
            ((RelativeLayout) rootView).addView(view, 1);
        }
    }

    @Override
    public void addMessageContentView(View view) {
        if (view != null) {
            msgContentFrame.removeAllViews();
            msgContentFrame.addView(view);
        }
    }

}
